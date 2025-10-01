// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_product_designs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseActiveProductDesignsHash() =>
    r'b8d84d2144058d2b1a3df2cf3cd1a71a5812ff68';

/// Stream all active product designs
///
/// Copied from [firebaseActiveProductDesigns].
@ProviderFor(firebaseActiveProductDesigns)
final firebaseActiveProductDesignsProvider =
    AutoDisposeStreamProvider<List<ProductDesign>>.internal(
  firebaseActiveProductDesigns,
  name: r'firebaseActiveProductDesignsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseActiveProductDesignsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseActiveProductDesignsRef
    = AutoDisposeStreamProviderRef<List<ProductDesign>>;
String _$firebaseProductDesignsByCategoryHash() =>
    r'5cf44aa0d9ce594eb149f63bcd1478e2eb0b0293';

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

/// Stream product designs by category
///
/// Copied from [firebaseProductDesignsByCategory].
@ProviderFor(firebaseProductDesignsByCategory)
const firebaseProductDesignsByCategoryProvider =
    FirebaseProductDesignsByCategoryFamily();

/// Stream product designs by category
///
/// Copied from [firebaseProductDesignsByCategory].
class FirebaseProductDesignsByCategoryFamily
    extends Family<AsyncValue<List<ProductDesign>>> {
  /// Stream product designs by category
  ///
  /// Copied from [firebaseProductDesignsByCategory].
  const FirebaseProductDesignsByCategoryFamily();

  /// Stream product designs by category
  ///
  /// Copied from [firebaseProductDesignsByCategory].
  FirebaseProductDesignsByCategoryProvider call(
    String category,
  ) {
    return FirebaseProductDesignsByCategoryProvider(
      category,
    );
  }

  @override
  FirebaseProductDesignsByCategoryProvider getProviderOverride(
    covariant FirebaseProductDesignsByCategoryProvider provider,
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
  String? get name => r'firebaseProductDesignsByCategoryProvider';
}

/// Stream product designs by category
///
/// Copied from [firebaseProductDesignsByCategory].
class FirebaseProductDesignsByCategoryProvider
    extends AutoDisposeStreamProvider<List<ProductDesign>> {
  /// Stream product designs by category
  ///
  /// Copied from [firebaseProductDesignsByCategory].
  FirebaseProductDesignsByCategoryProvider(
    String category,
  ) : this._internal(
          (ref) => firebaseProductDesignsByCategory(
            ref as FirebaseProductDesignsByCategoryRef,
            category,
          ),
          from: firebaseProductDesignsByCategoryProvider,
          name: r'firebaseProductDesignsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseProductDesignsByCategoryHash,
          dependencies: FirebaseProductDesignsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              FirebaseProductDesignsByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  FirebaseProductDesignsByCategoryProvider._internal(
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
    Stream<List<ProductDesign>> Function(
            FirebaseProductDesignsByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseProductDesignsByCategoryProvider._internal(
        (ref) => create(ref as FirebaseProductDesignsByCategoryRef),
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
  AutoDisposeStreamProviderElement<List<ProductDesign>> createElement() {
    return _FirebaseProductDesignsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseProductDesignsByCategoryProvider &&
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
mixin FirebaseProductDesignsByCategoryRef
    on AutoDisposeStreamProviderRef<List<ProductDesign>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _FirebaseProductDesignsByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<ProductDesign>>
    with FirebaseProductDesignsByCategoryRef {
  _FirebaseProductDesignsByCategoryProviderElement(super.provider);

  @override
  String get category =>
      (origin as FirebaseProductDesignsByCategoryProvider).category;
}

String _$firebaseAllProductDesignsHash() =>
    r'4697fa511dc9385c014ce8590b129645b82e4099';

/// Stream all product designs (admin view)
///
/// Copied from [firebaseAllProductDesigns].
@ProviderFor(firebaseAllProductDesigns)
final firebaseAllProductDesignsProvider =
    AutoDisposeStreamProvider<List<ProductDesign>>.internal(
  firebaseAllProductDesigns,
  name: r'firebaseAllProductDesignsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAllProductDesignsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAllProductDesignsRef
    = AutoDisposeStreamProviderRef<List<ProductDesign>>;
String _$firebaseProductDesignHash() =>
    r'9a6ef8c59f8768e9d40c70e79bbf705f01e3700d';

/// Get a single product design
///
/// Copied from [firebaseProductDesign].
@ProviderFor(firebaseProductDesign)
const firebaseProductDesignProvider = FirebaseProductDesignFamily();

/// Get a single product design
///
/// Copied from [firebaseProductDesign].
class FirebaseProductDesignFamily extends Family<AsyncValue<ProductDesign?>> {
  /// Get a single product design
  ///
  /// Copied from [firebaseProductDesign].
  const FirebaseProductDesignFamily();

  /// Get a single product design
  ///
  /// Copied from [firebaseProductDesign].
  FirebaseProductDesignProvider call(
    String designId,
  ) {
    return FirebaseProductDesignProvider(
      designId,
    );
  }

  @override
  FirebaseProductDesignProvider getProviderOverride(
    covariant FirebaseProductDesignProvider provider,
  ) {
    return call(
      provider.designId,
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
  String? get name => r'firebaseProductDesignProvider';
}

/// Get a single product design
///
/// Copied from [firebaseProductDesign].
class FirebaseProductDesignProvider
    extends AutoDisposeStreamProvider<ProductDesign?> {
  /// Get a single product design
  ///
  /// Copied from [firebaseProductDesign].
  FirebaseProductDesignProvider(
    String designId,
  ) : this._internal(
          (ref) => firebaseProductDesign(
            ref as FirebaseProductDesignRef,
            designId,
          ),
          from: firebaseProductDesignProvider,
          name: r'firebaseProductDesignProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseProductDesignHash,
          dependencies: FirebaseProductDesignFamily._dependencies,
          allTransitiveDependencies:
              FirebaseProductDesignFamily._allTransitiveDependencies,
          designId: designId,
        );

  FirebaseProductDesignProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.designId,
  }) : super.internal();

  final String designId;

  @override
  Override overrideWith(
    Stream<ProductDesign?> Function(FirebaseProductDesignRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseProductDesignProvider._internal(
        (ref) => create(ref as FirebaseProductDesignRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        designId: designId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ProductDesign?> createElement() {
    return _FirebaseProductDesignProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseProductDesignProvider && other.designId == designId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, designId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseProductDesignRef on AutoDisposeStreamProviderRef<ProductDesign?> {
  /// The parameter `designId` of this provider.
  String get designId;
}

class _FirebaseProductDesignProviderElement
    extends AutoDisposeStreamProviderElement<ProductDesign?>
    with FirebaseProductDesignRef {
  _FirebaseProductDesignProviderElement(super.provider);

  @override
  String get designId => (origin as FirebaseProductDesignProvider).designId;
}

String _$productDesignServiceHash() =>
    r'3cc520875e258f306a5f60910404e80e41f921aa';

/// Service for product design operations
///
/// Copied from [productDesignService].
@ProviderFor(productDesignService)
final productDesignServiceProvider =
    AutoDisposeProvider<ProductDesignService>.internal(
  productDesignService,
  name: r'productDesignServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productDesignServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductDesignServiceRef = AutoDisposeProviderRef<ProductDesignService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
