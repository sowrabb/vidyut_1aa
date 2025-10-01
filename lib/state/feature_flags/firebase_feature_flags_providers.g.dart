// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_feature_flags_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseFeatureFlagsHash() =>
    r'b154c6a0934aaccf4b5700399827b6dc4f9ebd13';

/// Stream all feature flags
///
/// Copied from [firebaseFeatureFlags].
@ProviderFor(firebaseFeatureFlags)
final firebaseFeatureFlagsProvider =
    AutoDisposeStreamProvider<Map<String, FeatureFlagData>>.internal(
  firebaseFeatureFlags,
  name: r'firebaseFeatureFlagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFeatureFlagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFeatureFlagsRef
    = AutoDisposeStreamProviderRef<Map<String, FeatureFlagData>>;
String _$firebaseFeatureFlagEnabledHash() =>
    r'f3fba38d24c927b4395816efd66466bfb36c53d0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Check if a specific feature is enabled
///
/// Copied from [firebaseFeatureFlagEnabled].
@ProviderFor(firebaseFeatureFlagEnabled)
const firebaseFeatureFlagEnabledProvider = FirebaseFeatureFlagEnabledFamily();

/// Check if a specific feature is enabled
///
/// Copied from [firebaseFeatureFlagEnabled].
class FirebaseFeatureFlagEnabledFamily extends Family<AsyncValue<bool>> {
  /// Check if a specific feature is enabled
  ///
  /// Copied from [firebaseFeatureFlagEnabled].
  const FirebaseFeatureFlagEnabledFamily();

  /// Check if a specific feature is enabled
  ///
  /// Copied from [firebaseFeatureFlagEnabled].
  FirebaseFeatureFlagEnabledProvider call(
    String featureName,
  ) {
    return FirebaseFeatureFlagEnabledProvider(
      featureName,
    );
  }

  @override
  FirebaseFeatureFlagEnabledProvider getProviderOverride(
    covariant FirebaseFeatureFlagEnabledProvider provider,
  ) {
    return call(
      provider.featureName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'firebaseFeatureFlagEnabledProvider';
}

/// Check if a specific feature is enabled
///
/// Copied from [firebaseFeatureFlagEnabled].
class FirebaseFeatureFlagEnabledProvider
    extends AutoDisposeStreamProvider<bool> {
  /// Check if a specific feature is enabled
  ///
  /// Copied from [firebaseFeatureFlagEnabled].
  FirebaseFeatureFlagEnabledProvider(
    String featureName,
  ) : this._internal(
          (ref) => firebaseFeatureFlagEnabled(
            ref as FirebaseFeatureFlagEnabledRef,
            featureName,
          ),
          from: firebaseFeatureFlagEnabledProvider,
          name: r'firebaseFeatureFlagEnabledProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseFeatureFlagEnabledHash,
          dependencies: FirebaseFeatureFlagEnabledFamily._dependencies,
          allTransitiveDependencies:
              FirebaseFeatureFlagEnabledFamily._allTransitiveDependencies,
          featureName: featureName,
        );

  FirebaseFeatureFlagEnabledProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.featureName,
  }) : super.internal();

  final String featureName;

  @override
  Override overrideWith(
    Stream<bool> Function(FirebaseFeatureFlagEnabledRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseFeatureFlagEnabledProvider._internal(
        (ref) => create(ref as FirebaseFeatureFlagEnabledRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        featureName: featureName,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _FirebaseFeatureFlagEnabledProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseFeatureFlagEnabledProvider &&
        other.featureName == featureName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, featureName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseFeatureFlagEnabledRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `featureName` of this provider.
  String get featureName;
}

class _FirebaseFeatureFlagEnabledProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with FirebaseFeatureFlagEnabledRef {
  _FirebaseFeatureFlagEnabledProviderElement(super.provider);

  @override
  String get featureName =>
      (origin as FirebaseFeatureFlagEnabledProvider).featureName;
}

String _$featureFlagServiceHash() =>
    r'2d43913abf15a62be075f56ea9569f1daa32a03a';

/// Service for feature flag operations (admin only)
///
/// Copied from [featureFlagService].
@ProviderFor(featureFlagService)
final featureFlagServiceProvider =
    AutoDisposeProvider<FeatureFlagService>.internal(
  featureFlagService,
  name: r'featureFlagServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featureFlagServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeatureFlagServiceRef = AutoDisposeProviderRef<FeatureFlagService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
