// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_advertisements_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseActiveAdsHash() => r'2e86e40b761b163240ab1aab71ff57ec23e8ecda';

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

/// Stream active ads for a specific ad type
///
/// Copied from [firebaseActiveAds].
@ProviderFor(firebaseActiveAds)
const firebaseActiveAdsProvider = FirebaseActiveAdsFamily();

/// Stream active ads for a specific ad type
///
/// Copied from [firebaseActiveAds].
class FirebaseActiveAdsFamily
    extends Family<AsyncValue<List<AdvertisementCampaign>>> {
  /// Stream active ads for a specific ad type
  ///
  /// Copied from [firebaseActiveAds].
  const FirebaseActiveAdsFamily();

  /// Stream active ads for a specific ad type
  ///
  /// Copied from [firebaseActiveAds].
  FirebaseActiveAdsProvider call(
    AdType adType,
  ) {
    return FirebaseActiveAdsProvider(
      adType,
    );
  }

  @override
  FirebaseActiveAdsProvider getProviderOverride(
    covariant FirebaseActiveAdsProvider provider,
  ) {
    return call(
      provider.adType,
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
  String? get name => r'firebaseActiveAdsProvider';
}

/// Stream active ads for a specific ad type
///
/// Copied from [firebaseActiveAds].
class FirebaseActiveAdsProvider
    extends AutoDisposeStreamProvider<List<AdvertisementCampaign>> {
  /// Stream active ads for a specific ad type
  ///
  /// Copied from [firebaseActiveAds].
  FirebaseActiveAdsProvider(
    AdType adType,
  ) : this._internal(
          (ref) => firebaseActiveAds(
            ref as FirebaseActiveAdsRef,
            adType,
          ),
          from: firebaseActiveAdsProvider,
          name: r'firebaseActiveAdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseActiveAdsHash,
          dependencies: FirebaseActiveAdsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseActiveAdsFamily._allTransitiveDependencies,
          adType: adType,
        );

  FirebaseActiveAdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.adType,
  }) : super.internal();

  final AdType adType;

  @override
  Override overrideWith(
    Stream<List<AdvertisementCampaign>> Function(FirebaseActiveAdsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseActiveAdsProvider._internal(
        (ref) => create(ref as FirebaseActiveAdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        adType: adType,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AdvertisementCampaign>>
      createElement() {
    return _FirebaseActiveAdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseActiveAdsProvider && other.adType == adType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, adType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseActiveAdsRef
    on AutoDisposeStreamProviderRef<List<AdvertisementCampaign>> {
  /// The parameter `adType` of this provider.
  AdType get adType;
}

class _FirebaseActiveAdsProviderElement
    extends AutoDisposeStreamProviderElement<List<AdvertisementCampaign>>
    with FirebaseActiveAdsRef {
  _FirebaseActiveAdsProviderElement(super.provider);

  @override
  AdType get adType => (origin as FirebaseActiveAdsProvider).adType;
}

String _$firebaseSellerAdsHash() => r'20950935b14d8b54fb3786a84a10d7626085f920';

/// Stream seller's ads
///
/// Copied from [firebaseSellerAds].
@ProviderFor(firebaseSellerAds)
final firebaseSellerAdsProvider =
    AutoDisposeStreamProvider<List<AdvertisementCampaign>>.internal(
  firebaseSellerAds,
  name: r'firebaseSellerAdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSellerAdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSellerAdsRef
    = AutoDisposeStreamProviderRef<List<AdvertisementCampaign>>;
String _$firebaseAdsByStatusHash() =>
    r'360061ebdec6f247780c6f2ffefef79228077231';

/// Stream ads by status (admin)
///
/// Copied from [firebaseAdsByStatus].
@ProviderFor(firebaseAdsByStatus)
const firebaseAdsByStatusProvider = FirebaseAdsByStatusFamily();

/// Stream ads by status (admin)
///
/// Copied from [firebaseAdsByStatus].
class FirebaseAdsByStatusFamily
    extends Family<AsyncValue<List<AdvertisementCampaign>>> {
  /// Stream ads by status (admin)
  ///
  /// Copied from [firebaseAdsByStatus].
  const FirebaseAdsByStatusFamily();

  /// Stream ads by status (admin)
  ///
  /// Copied from [firebaseAdsByStatus].
  FirebaseAdsByStatusProvider call(
    AdStatus status,
  ) {
    return FirebaseAdsByStatusProvider(
      status,
    );
  }

  @override
  FirebaseAdsByStatusProvider getProviderOverride(
    covariant FirebaseAdsByStatusProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'firebaseAdsByStatusProvider';
}

/// Stream ads by status (admin)
///
/// Copied from [firebaseAdsByStatus].
class FirebaseAdsByStatusProvider
    extends AutoDisposeStreamProvider<List<AdvertisementCampaign>> {
  /// Stream ads by status (admin)
  ///
  /// Copied from [firebaseAdsByStatus].
  FirebaseAdsByStatusProvider(
    AdStatus status,
  ) : this._internal(
          (ref) => firebaseAdsByStatus(
            ref as FirebaseAdsByStatusRef,
            status,
          ),
          from: firebaseAdsByStatusProvider,
          name: r'firebaseAdsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseAdsByStatusHash,
          dependencies: FirebaseAdsByStatusFamily._dependencies,
          allTransitiveDependencies:
              FirebaseAdsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  FirebaseAdsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final AdStatus status;

  @override
  Override overrideWith(
    Stream<List<AdvertisementCampaign>> Function(
            FirebaseAdsByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseAdsByStatusProvider._internal(
        (ref) => create(ref as FirebaseAdsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AdvertisementCampaign>>
      createElement() {
    return _FirebaseAdsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseAdsByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseAdsByStatusRef
    on AutoDisposeStreamProviderRef<List<AdvertisementCampaign>> {
  /// The parameter `status` of this provider.
  AdStatus get status;
}

class _FirebaseAdsByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<AdvertisementCampaign>>
    with FirebaseAdsByStatusRef {
  _FirebaseAdsByStatusProviderElement(super.provider);

  @override
  AdStatus get status => (origin as FirebaseAdsByStatusProvider).status;
}

String _$firebaseAllAdsHash() => r'717b400aafe66a1e4ddeeb9ce5cb2ad730380213';

/// Stream all ads (admin)
///
/// Copied from [firebaseAllAds].
@ProviderFor(firebaseAllAds)
final firebaseAllAdsProvider =
    AutoDisposeStreamProvider<List<AdvertisementCampaign>>.internal(
  firebaseAllAds,
  name: r'firebaseAllAdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAllAdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAllAdsRef
    = AutoDisposeStreamProviderRef<List<AdvertisementCampaign>>;
String _$firebaseAdvertisementHash() =>
    r'bde387d96d1f5f0f7bec17ab7990ba8a93d1de24';

/// Get a single ad
///
/// Copied from [firebaseAdvertisement].
@ProviderFor(firebaseAdvertisement)
const firebaseAdvertisementProvider = FirebaseAdvertisementFamily();

/// Get a single ad
///
/// Copied from [firebaseAdvertisement].
class FirebaseAdvertisementFamily
    extends Family<AsyncValue<AdvertisementCampaign?>> {
  /// Get a single ad
  ///
  /// Copied from [firebaseAdvertisement].
  const FirebaseAdvertisementFamily();

  /// Get a single ad
  ///
  /// Copied from [firebaseAdvertisement].
  FirebaseAdvertisementProvider call(
    String adId,
  ) {
    return FirebaseAdvertisementProvider(
      adId,
    );
  }

  @override
  FirebaseAdvertisementProvider getProviderOverride(
    covariant FirebaseAdvertisementProvider provider,
  ) {
    return call(
      provider.adId,
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
  String? get name => r'firebaseAdvertisementProvider';
}

/// Get a single ad
///
/// Copied from [firebaseAdvertisement].
class FirebaseAdvertisementProvider
    extends AutoDisposeStreamProvider<AdvertisementCampaign?> {
  /// Get a single ad
  ///
  /// Copied from [firebaseAdvertisement].
  FirebaseAdvertisementProvider(
    String adId,
  ) : this._internal(
          (ref) => firebaseAdvertisement(
            ref as FirebaseAdvertisementRef,
            adId,
          ),
          from: firebaseAdvertisementProvider,
          name: r'firebaseAdvertisementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseAdvertisementHash,
          dependencies: FirebaseAdvertisementFamily._dependencies,
          allTransitiveDependencies:
              FirebaseAdvertisementFamily._allTransitiveDependencies,
          adId: adId,
        );

  FirebaseAdvertisementProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.adId,
  }) : super.internal();

  final String adId;

  @override
  Override overrideWith(
    Stream<AdvertisementCampaign?> Function(FirebaseAdvertisementRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseAdvertisementProvider._internal(
        (ref) => create(ref as FirebaseAdvertisementRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        adId: adId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AdvertisementCampaign?> createElement() {
    return _FirebaseAdvertisementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseAdvertisementProvider && other.adId == adId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, adId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseAdvertisementRef
    on AutoDisposeStreamProviderRef<AdvertisementCampaign?> {
  /// The parameter `adId` of this provider.
  String get adId;
}

class _FirebaseAdvertisementProviderElement
    extends AutoDisposeStreamProviderElement<AdvertisementCampaign?>
    with FirebaseAdvertisementRef {
  _FirebaseAdvertisementProviderElement(super.provider);

  @override
  String get adId => (origin as FirebaseAdvertisementProvider).adId;
}

String _$advertisementServiceHash() =>
    r'99ae1daa912be18a72c2c124235341e568f8ae4c';

/// Service for advertisement operations
///
/// Copied from [advertisementService].
@ProviderFor(advertisementService)
final advertisementServiceProvider =
    AutoDisposeProvider<AdvertisementService>.internal(
  advertisementService,
  name: r'advertisementServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$advertisementServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdvertisementServiceRef = AutoDisposeProviderRef<AdvertisementService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
