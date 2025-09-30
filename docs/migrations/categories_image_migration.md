Categories image URL migration

Objective
- Ensure every category has a canonical `imageUrl` with an HTTPS download URL.
- Backfill legacy records that may store `gs://` or `storagePath` instead of `https://`.

Scope
- Categories collection/documents only. Other modules are out-of-scope.

Plan
1) Data audit
- List categories missing `imageUrl` or with non-HTTPS values.
- Detect `gs://` or relative paths.

2) Backfill strategy
- If `imageUrl` is empty and `storagePath`/`gs://` exists, resolve to HTTPS via Firebase Storage `getDownloadURL()` and persist it into `imageUrl`.
- If the referenced object is missing, set a default fallback image and flag for manual review.
- Ensure only HTTPS URLs are saved.

3) Idempotency
- Re-running should skip records that already have a valid HTTPS `imageUrl`.

Sample backfill snippet (Flutter runtime)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> backfillCategoryImageUrls() async {
  final fs = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final cats = await fs.collection('categories').get();
  for (final doc in cats.docs) {
    final data = doc.data();
    final imageUrl = (data['imageUrl'] as String?)?.trim() ?? '';
    final storagePath = (data['storagePath'] as String?)?.trim() ?? '';

    final isHttps = imageUrl.startsWith('https://');
    if (isHttps) continue;

    if (storagePath.isNotEmpty) {
      try {
        // Supports both 'path/in/bucket' and 'gs://bucket/path'
        Reference ref;
        if (storagePath.startsWith('gs://')) {
          ref = storage.refFromURL(storagePath);
        } else {
          ref = storage.ref().child(storagePath);
        }
        final url = await ref.getDownloadURL();
        await doc.reference.update({'imageUrl': url});
      } catch (e) {
        // Default fallback; optionally record a review flag
        await doc.reference.update({
          'imageUrl': 'https://picsum.photos/seed/category-fallback/400/300',
          'imageUrlError': e.toString(),
        });
      }
    } else {
      // No path; set fallback and flag
      await doc.reference.update({
        'imageUrl': 'https://picsum.photos/seed/category-fallback/400/300',
        'imageUrlError': 'missing storagePath',
      });
    }
  }
}
```

Operational notes
- Run once in a controlled environment with proper credentials.
- Verify Android/iOS apps render images correctly post-migration.
- No cleartext HTTP should remain; iOS ATS and Android network security remain default.

Roll-forward/rollback
- Roll-forward: re-run the script safely; it is idempotent for already-correct records.
- Rollback: keep a backup export of affected fields before the run if needed.

