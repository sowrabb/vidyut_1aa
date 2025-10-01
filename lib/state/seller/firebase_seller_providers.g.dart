// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_seller_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseSellerProfileHash() =>
    r'69c40051c0e55780c1e634e00fba302be1cc198b';

/// Stream the current user's seller profile
///
/// Copied from [firebaseSellerProfile].
@ProviderFor(firebaseSellerProfile)
final firebaseSellerProfileProvider =
    AutoDisposeStreamProvider<SellerProfile?>.internal(
  firebaseSellerProfile,
  name: r'firebaseSellerProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSellerProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSellerProfileRef = AutoDisposeStreamProviderRef<SellerProfile?>;
String _$firebaseSellerProfileByIdHash() =>
    r'05cd898c11168873c2159e4ced8ed76878dc6215';

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

/// Get a seller profile by seller ID (for viewing other sellers)
///
/// Copied from [firebaseSellerProfileById].
@ProviderFor(firebaseSellerProfileById)
const firebaseSellerProfileByIdProvider = FirebaseSellerProfileByIdFamily();

/// Get a seller profile by seller ID (for viewing other sellers)
///
/// Copied from [firebaseSellerProfileById].
class FirebaseSellerProfileByIdFamily
    extends Family<AsyncValue<SellerProfile?>> {
  /// Get a seller profile by seller ID (for viewing other sellers)
  ///
  /// Copied from [firebaseSellerProfileById].
  const FirebaseSellerProfileByIdFamily();

  /// Get a seller profile by seller ID (for viewing other sellers)
  ///
  /// Copied from [firebaseSellerProfileById].
  FirebaseSellerProfileByIdProvider call(
    String sellerId,
  ) {
    return FirebaseSellerProfileByIdProvider(
      sellerId,
    );
  }

  @override
  FirebaseSellerProfileByIdProvider getProviderOverride(
    covariant FirebaseSellerProfileByIdProvider provider,
  ) {
    return call(
      provider.sellerId,
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
  String? get name => r'firebaseSellerProfileByIdProvider';
}

/// Get a seller profile by seller ID (for viewing other sellers)
///
/// Copied from [firebaseSellerProfileById].
class FirebaseSellerProfileByIdProvider
    extends AutoDisposeStreamProvider<SellerProfile?> {
  /// Get a seller profile by seller ID (for viewing other sellers)
  ///
  /// Copied from [firebaseSellerProfileById].
  FirebaseSellerProfileByIdProvider(
    String sellerId,
  ) : this._internal(
          (ref) => firebaseSellerProfileById(
            ref as FirebaseSellerProfileByIdRef,
            sellerId,
          ),
          from: firebaseSellerProfileByIdProvider,
          name: r'firebaseSellerProfileByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseSellerProfileByIdHash,
          dependencies: FirebaseSellerProfileByIdFamily._dependencies,
          allTransitiveDependencies:
              FirebaseSellerProfileByIdFamily._allTransitiveDependencies,
          sellerId: sellerId,
        );

  FirebaseSellerProfileByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sellerId,
  }) : super.internal();

  final String sellerId;

  @override
  Override overrideWith(
    Stream<SellerProfile?> Function(FirebaseSellerProfileByIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseSellerProfileByIdProvider._internal(
        (ref) => create(ref as FirebaseSellerProfileByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sellerId: sellerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<SellerProfile?> createElement() {
    return _FirebaseSellerProfileByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseSellerProfileByIdProvider &&
        other.sellerId == sellerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sellerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseSellerProfileByIdRef
    on AutoDisposeStreamProviderRef<SellerProfile?> {
  /// The parameter `sellerId` of this provider.
  String get sellerId;
}

class _FirebaseSellerProfileByIdProviderElement
    extends AutoDisposeStreamProviderElement<SellerProfile?>
    with FirebaseSellerProfileByIdRef {
  _FirebaseSellerProfileByIdProviderElement(super.provider);

  @override
  String get sellerId => (origin as FirebaseSellerProfileByIdProvider).sellerId;
}

String _$firebaseVerifiedSellersHash() =>
    r'80635b4400d46c0ecc1f4a14365f35a77b550792';

/// Stream all verified sellers
///
/// Copied from [firebaseVerifiedSellers].
@ProviderFor(firebaseVerifiedSellers)
final firebaseVerifiedSellersProvider =
    AutoDisposeStreamProvider<List<SellerProfile>>.internal(
  firebaseVerifiedSellers,
  name: r'firebaseVerifiedSellersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseVerifiedSellersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseVerifiedSellersRef
    = AutoDisposeStreamProviderRef<List<SellerProfile>>;
String _$sellerProfileServiceHash() =>
    r'3afae51acc40b732309db7628d8449e560acf7d1';

/// Service for seller profile operations
///
/// Copied from [sellerProfileService].
@ProviderFor(sellerProfileService)
final sellerProfileServiceProvider =
    AutoDisposeProvider<SellerProfileService>.internal(
  sellerProfileService,
  name: r'sellerProfileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sellerProfileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SellerProfileServiceRef = AutoDisposeProviderRef<SellerProfileService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
