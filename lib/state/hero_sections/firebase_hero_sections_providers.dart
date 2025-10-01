/// Firebase-backed hero sections providers for homepage banners
/// Allows admin to dynamically update homepage content without app deployment
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/admin/models/hero_section.dart';
import '../core/firebase_providers.dart';

part 'firebase_hero_sections_providers.g.dart';

/// Stream all active hero sections sorted by priority
@riverpod
Stream<List<HeroSection>> firebaseActiveHeroSections(
  FirebaseActiveHeroSectionsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('hero_sections')
      .where('is_active', isEqualTo: true)
      .orderBy('priority', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HeroSection.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream all hero sections (admin view - includes inactive)
@riverpod
Stream<List<HeroSection>> firebaseAllHeroSections(
  FirebaseAllHeroSectionsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('hero_sections')
      .orderBy('priority', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HeroSection.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single hero section by ID
@riverpod
Stream<HeroSection?> firebaseHeroSection(
  FirebaseHeroSectionRef ref,
  String heroSectionId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('hero_sections')
      .doc(heroSectionId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return HeroSection.fromJson({...data, 'id': doc.id});
  });
}

/// Service for hero section operations (admin only)
@riverpod
HeroSectionService heroSectionService(HeroSectionServiceRef ref) {
  return HeroSectionService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// Hero section service class
class HeroSectionService {
  final FirebaseFirestore firestore;

  HeroSectionService({required this.firestore});

  /// Create a new hero section
  Future<String> createHeroSection({
    required String title,
    required String subtitle,
    required String imagePath,
    bool isActive = false,
    int priority = 0,
    String? actionUrl,
  }) async {
    final heroSectionData = {
      'title': title,
      'subtitle': subtitle,
      'image_path': imagePath,
      'is_active': isActive,
      'priority': priority,
      'action_url': actionUrl,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'view_count': 0,
      'click_count': 0,
    };

    final docRef = await firestore.collection('hero_sections').add(heroSectionData);
    return docRef.id;
  }

  /// Update an existing hero section
  Future<void> updateHeroSection({
    required String heroSectionId,
    String? title,
    String? subtitle,
    String? imagePath,
    bool? isActive,
    int? priority,
    String? actionUrl,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (title != null) updateData['title'] = title;
    if (subtitle != null) updateData['subtitle'] = subtitle;
    if (imagePath != null) updateData['image_path'] = imagePath;
    if (isActive != null) updateData['is_active'] = isActive;
    if (priority != null) updateData['priority'] = priority;
    if (actionUrl != null) updateData['action_url'] = actionUrl;

    await firestore
        .collection('hero_sections')
        .doc(heroSectionId)
        .update(updateData);
  }

  /// Delete a hero section
  Future<void> deleteHeroSection(String heroSectionId) async {
    await firestore.collection('hero_sections').doc(heroSectionId).delete();
  }

  /// Toggle active status
  Future<void> toggleActive(String heroSectionId) async {
    final doc = await firestore
        .collection('hero_sections')
        .doc(heroSectionId)
        .get();

    if (doc.exists) {
      final currentActive = doc.data()?['is_active'] as bool? ?? false;
      await firestore.collection('hero_sections').doc(heroSectionId).update({
        'is_active': !currentActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Reorder hero sections (batch update priorities)
  Future<void> reorderHeroSections(Map<String, int> priorities) async {
    final batch = firestore.batch();

    for (final entry in priorities.entries) {
      final docRef = firestore.collection('hero_sections').doc(entry.key);
      batch.update(docRef, {
        'priority': entry.value,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Track hero section view
  Future<void> trackView(String heroSectionId) async {
    await firestore.collection('hero_sections').doc(heroSectionId).update({
      'view_count': FieldValue.increment(1),
      'last_viewed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Track hero section click
  Future<void> trackClick(String heroSectionId) async {
    await firestore.collection('hero_sections').doc(heroSectionId).update({
      'click_count': FieldValue.increment(1),
      'last_clicked_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get hero section analytics
  Future<Map<String, dynamic>> getHeroSectionAnalytics(String heroSectionId) async {
    final doc = await firestore
        .collection('hero_sections')
        .doc(heroSectionId)
        .get();

    if (!doc.exists) return {};

    final data = doc.data()!;
    final viewCount = data['view_count'] as int? ?? 0;
    final clickCount = data['click_count'] as int? ?? 0;
    final clickThroughRate = viewCount > 0 ? (clickCount / viewCount) * 100 : 0.0;

    return {
      'view_count': viewCount,
      'click_count': clickCount,
      'click_through_rate': clickThroughRate,
      'is_active': data['is_active'] as bool? ?? false,
      'priority': data['priority'] as int? ?? 0,
    };
  }
}




