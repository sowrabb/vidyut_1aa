// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_products_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseSellerProductsHash() =>
    r'f82d5eb9c3143002ff45c9973a339105a964abee';

/// Stream all products for the current seller
///
/// Copied from [firebaseSellerProducts].
@ProviderFor(firebaseSellerProducts)
final firebaseSellerProductsProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
  firebaseSellerProducts,
  name: r'firebaseSellerProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSellerProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSellerProductsRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$firebaseActiveProductsHash() =>
    r'01385206a422c296dd556b9a6f12363a0effea25';

/// Stream all active products (for buyers/users)
///
/// Copied from [firebaseActiveProducts].
@ProviderFor(firebaseActiveProducts)
final firebaseActiveProductsProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
  firebaseActiveProducts,
  name: r'firebaseActiveProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseActiveProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseActiveProductsRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$firebaseProductsByCategoryHash() =>
    r'286c9a6338a471ec07316c10d5c598af2e9424c9';

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

/// Stream products by category
///
/// Copied from [firebaseProductsByCategory].
@ProviderFor(firebaseProductsByCategory)
const firebaseProductsByCategoryProvider = FirebaseProductsByCategoryFamily();

/// Stream products by category
///
/// Copied from [firebaseProductsByCategory].
class FirebaseProductsByCategoryFamily
    extends Family<AsyncValue<List<Product>>> {
  /// Stream products by category
  ///
  /// Copied from [firebaseProductsByCategory].
  const FirebaseProductsByCategoryFamily();

  /// Stream products by category
  ///
  /// Copied from [firebaseProductsByCategory].
  FirebaseProductsByCategoryProvider call(
    String category,
  ) {
    return FirebaseProductsByCategoryProvider(
      category,
    );
  }

  @override
  FirebaseProductsByCategoryProvider getProviderOverride(
    covariant FirebaseProductsByCategoryProvider provider,
  ) {
    return call(
      provider.category,
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
  String? get name => r'firebaseProductsByCategoryProvider';
}

/// Stream products by category
///
/// Copied from [firebaseProductsByCategory].
class FirebaseProductsByCategoryProvider
    extends AutoDisposeStreamProvider<List<Product>> {
  /// Stream products by category
  ///
  /// Copied from [firebaseProductsByCategory].
  FirebaseProductsByCategoryProvider(
    String category,
  ) : this._internal(
          (ref) => firebaseProductsByCategory(
            ref as FirebaseProductsByCategoryRef,
            category,
          ),
          from: firebaseProductsByCategoryProvider,
          name: r'firebaseProductsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseProductsByCategoryHash,
          dependencies: FirebaseProductsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              FirebaseProductsByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  FirebaseProductsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(FirebaseProductsByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseProductsByCategoryProvider._internal(
        (ref) => create(ref as FirebaseProductsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _FirebaseProductsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseProductsByCategoryProvider &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseProductsByCategoryRef
    on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _FirebaseProductsByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with FirebaseProductsByCategoryRef {
  _FirebaseProductsByCategoryProviderElement(super.provider);

  @override
  String get category =>
      (origin as FirebaseProductsByCategoryProvider).category;
}

String _$firebaseProductHash() => r'1affbae1bcf424d2ee32b57c3fa89669a0e6ec20';

/// Get a single product by ID
///
/// Copied from [firebaseProduct].
@ProviderFor(firebaseProduct)
const firebaseProductProvider = FirebaseProductFamily();

/// Get a single product by ID
///
/// Copied from [firebaseProduct].
class FirebaseProductFamily extends Family<AsyncValue<Product?>> {
  /// Get a single product by ID
  ///
  /// Copied from [firebaseProduct].
  const FirebaseProductFamily();

  /// Get a single product by ID
  ///
  /// Copied from [firebaseProduct].
  FirebaseProductProvider call(
    String productId,
  ) {
    return FirebaseProductProvider(
      productId,
    );
  }

  @override
  FirebaseProductProvider getProviderOverride(
    covariant FirebaseProductProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'firebaseProductProvider';
}

/// Get a single product by ID
///
/// Copied from [firebaseProduct].
class FirebaseProductProvider extends AutoDisposeStreamProvider<Product?> {
  /// Get a single product by ID
  ///
  /// Copied from [firebaseProduct].
  FirebaseProductProvider(
    String productId,
  ) : this._internal(
          (ref) => firebaseProduct(
            ref as FirebaseProductRef,
            productId,
          ),
          from: firebaseProductProvider,
          name: r'firebaseProductProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseProductHash,
          dependencies: FirebaseProductFamily._dependencies,
          allTransitiveDependencies:
              FirebaseProductFamily._allTransitiveDependencies,
          productId: productId,
        );

  FirebaseProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    Stream<Product?> Function(FirebaseProductRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseProductProvider._internal(
        (ref) => create(ref as FirebaseProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Product?> createElement() {
    return _FirebaseProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseProductProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseProductRef on AutoDisposeStreamProviderRef<Product?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _FirebaseProductProviderElement
    extends AutoDisposeStreamProviderElement<Product?> with FirebaseProductRef {
  _FirebaseProductProviderElement(super.provider);

  @override
  String get productId => (origin as FirebaseProductProvider).productId;
}

String _$productServiceHash() => r'c799d1f14ba3f0df26df9b8f23e420b16bd50baa';

/// Service for product CRUD operations
///
/// Copied from [productService].
@ProviderFor(productService)
final productServiceProvider = AutoDisposeProvider<ProductService>.internal(
  productService,
  name: r'productServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductServiceRef = AutoDisposeProviderRef<ProductService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
