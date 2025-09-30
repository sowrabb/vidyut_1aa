import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class InboxItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic> meta;
  final String? jobId;

  InboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.meta = const {},
    this.jobId,
  });

  factory InboxItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = (data['createdAt'] as Timestamp?);
    final readTs = (data['readAt'] as Timestamp?);
    return InboxItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      createdAt: ts?.toDate() ?? DateTime.now(),
      readAt: readTs?.toDate(),
      meta: Map<String, dynamic>.from(data['meta'] as Map? ?? {}),
      jobId: data['jobId'] as String?,
    );
  }
}

class NotificationsRepository {
  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  NotificationsRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    return user.uid;
  }

  Stream<List<InboxItem>> getInbox({int limit = 20, DocumentSnapshot? startAfter}) {
    final query = _db
        .collection('users')
        .doc(_uid)
        .collection('inbox')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final paged = startAfter != null ? query.startAfterDocument(startAfter) : query;
    return paged.snapshots().map(
      (snap) => snap.docs.map((d) => InboxItem.fromDoc(d)).toList(),
    );
  }

  Future<void> markRead(String notifId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('inbox')
        .doc(notifId)
        .update({'readAt': FieldValue.serverTimestamp()});
  }

  Future<void> markAllRead() async {
    final batch = _db.batch();
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('inbox')
        .where('readAt', isNull: true)
        .limit(500)
        .get();
    for (final d in snap.docs) {
      batch.update(d.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }
}


