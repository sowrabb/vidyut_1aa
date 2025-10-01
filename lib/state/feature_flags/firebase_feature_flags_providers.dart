/// Firebase-backed feature flags providers for remote configuration
/// Allows toggling features on/off without app deployment
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';

part 'firebase_feature_flags_providers.g.dart';

/// Model for feature flag
class FeatureFlagData {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final Map<String, dynamic> config;
  final DateTime updatedAt;

  FeatureFlagData({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    required this.config,
    required this.updatedAt,
  });

  factory FeatureFlagData.fromJson(Map<String, dynamic> json) {
    return FeatureFlagData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Stream all feature flags
@riverpod
Stream<Map<String, FeatureFlagData>> firebaseFeatureFlags(
  FirebaseFeatureFlagsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('system')
      .doc('feature_flags')
      .snapshots()
      .map((doc) {
    if (!doc.exists) return <String, FeatureFlagData>{};

    final data = doc.data()!;
    final flags = data['flags'] as Map<String, dynamic>? ?? {};

    return flags.map((key, value) {
      final flagData = value as Map<String, dynamic>;
      return MapEntry(
        key,
        FeatureFlagData.fromJson({...flagData, 'id': key}),
      );
    });
  });
}

/// Check if a specific feature is enabled
@riverpod
Stream<bool> firebaseFeatureFlagEnabled(
  FirebaseFeatureFlagEnabledRef ref,
  String featureName,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('feature_flags')
      .doc(featureName)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    return data['enabled'] as bool? ?? false;
  });
}

/// Service for feature flag operations (admin only)
@riverpod
FeatureFlagService featureFlagService(FeatureFlagServiceRef ref) {
  return FeatureFlagService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// Feature flag service class
class FeatureFlagService {
  final FirebaseFirestore firestore;

  FeatureFlagService({required this.firestore});

  /// Set or update a feature flag
  Future<void> setFlag({
    required String name,
    required bool enabled,
    String? description,
    Map<String, dynamic>? config,
  }) async {
    final docRef = firestore.collection('system').doc('feature_flags');
    
    await docRef.set({
      'flags.$name': {
        'enabled': enabled,
        'description': description ?? '',
        'config': config ?? {},
        'updated_at': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  /// Toggle a feature flag
  Future<void> toggleFlag(String name) async {
    final docRef = firestore.collection('system').doc('feature_flags');
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final flags = data['flags'] as Map<String, dynamic>? ?? {};
      final currentFlag = flags[name] as Map<String, dynamic>?;
      final currentEnabled = currentFlag?['enabled'] as bool? ?? false;

      await docRef.update({
        'flags.$name.enabled': !currentEnabled,
        'flags.$name.updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Delete a feature flag
  Future<void> deleteFlag(String name) async {
    final docRef = firestore.collection('system').doc('feature_flags');
    
    await docRef.update({
      'flags.$name': FieldValue.delete(),
    });
  }

  /// Get flag configuration
  Future<Map<String, dynamic>> getFlagConfig(String name) async {
    final docRef = firestore.collection('system').doc('feature_flags');
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final flags = data['flags'] as Map<String, dynamic>? ?? {};
      final flag = flags[name] as Map<String, dynamic>?;
      return flag?['config'] as Map<String, dynamic>? ?? {};
    }

    return {};
  }

  /// Initialize default feature flags
  Future<void> initializeDefaultFlags() async {
    final defaultFlags = {
      'messaging': {
        'enabled': true,
        'description': 'Enable real-time messaging',
        'config': {'max_attachments': 5, 'max_file_size_mb': 10},
        'updated_at': FieldValue.serverTimestamp(),
      },
      'reviews': {
        'enabled': true,
        'description': 'Enable product reviews',
        'config': {'require_purchase': false, 'max_images': 5},
        'updated_at': FieldValue.serverTimestamp(),
      },
      'leads': {
        'enabled': true,
        'description': 'Enable B2B lead generation',
        'config': {'auto_match': true, 'match_radius_km': 100},
        'updated_at': FieldValue.serverTimestamp(),
      },
      'subscriptions': {
        'enabled': true,
        'description': 'Enable subscription system',
        'config': {'trial_days': 14, 'payment_gateway': 'razorpay'},
        'updated_at': FieldValue.serverTimestamp(),
      },
      'analytics': {
        'enabled': true,
        'description': 'Enable analytics tracking',
        'config': {'track_views': true, 'track_clicks': true},
        'updated_at': FieldValue.serverTimestamp(),
      },
    };

    await firestore.collection('system').doc('feature_flags').set({
      'flags': defaultFlags,
      'initialized_at': FieldValue.serverTimestamp(),
    });
  }
}

