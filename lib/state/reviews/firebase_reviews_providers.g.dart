// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_reviews_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseProductReviewsHash() =>
    r'9127247205febfd0082ddfc9c075af01ff824e93';

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

/// Stream all reviews for a product
///
/// Copied from [firebaseProductReviews].
@ProviderFor(firebaseProductReviews)
const firebaseProductReviewsProvider = FirebaseProductReviewsFamily();

/// Stream all reviews for a product
///
/// Copied from [firebaseProductReviews].
class FirebaseProductReviewsFamily extends Family<AsyncValue<List<Review>>> {
  /// Stream all reviews for a product
  ///
  /// Copied from [firebaseProductReviews].
  const FirebaseProductReviewsFamily();

  /// Stream all reviews for a product
  ///
  /// Copied from [firebaseProductReviews].
  FirebaseProductReviewsProvider call(
    String productId,
  ) {
    return FirebaseProductReviewsProvider(
      productId,
    );
  }

  @override
  FirebaseProductReviewsProvider getProviderOverride(
    covariant FirebaseProductReviewsProvider provider,
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
  String? get name => r'firebaseProductReviewsProvider';
}

/// Stream all reviews for a product
///
/// Copied from [firebaseProductReviews].
class FirebaseProductReviewsProvider
    extends AutoDisposeStreamProvider<List<Review>> {
  /// Stream all reviews for a product
  ///
  /// Copied from [firebaseProductReviews].
  FirebaseProductReviewsProvider(
    String productId,
  ) : this._internal(
          (ref) => firebaseProductReviews(
            ref as FirebaseProductReviewsRef,
            productId,
          ),
          from: firebaseProductReviewsProvider,
          name: r'firebaseProductReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseProductReviewsHash,
          dependencies: FirebaseProductReviewsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseProductReviewsFamily._allTransitiveDependencies,
          productId: productId,
        );

  FirebaseProductReviewsProvider._internal(
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
    Stream<List<Review>> Function(FirebaseProductReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseProductReviewsProvider._internal(
        (ref) => create(ref as FirebaseProductReviewsRef),
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
  AutoDisposeStreamProviderElement<List<Review>> createElement() {
    return _FirebaseProductReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseProductReviewsProvider &&
        other.productId == productId;
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
mixin FirebaseProductReviewsRef on AutoDisposeStreamProviderRef<List<Review>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _FirebaseProductReviewsProviderElement
    extends AutoDisposeStreamProviderElement<List<Review>>
    with FirebaseProductReviewsRef {
  _FirebaseProductReviewsProviderElement(super.provider);

  @override
  String get productId => (origin as FirebaseProductReviewsProvider).productId;
}

String _$firebaseUserReviewsHash() =>
    r'b942ac04ea39d600bb4ef35bd667f16b943ad16b';

/// Stream reviews by user
///
/// Copied from [firebaseUserReviews].
@ProviderFor(firebaseUserReviews)
final firebaseUserReviewsProvider =
    AutoDisposeStreamProvider<List<Review>>.internal(
  firebaseUserReviews,
  name: r'firebaseUserReviewsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseUserReviewsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseUserReviewsRef = AutoDisposeStreamProviderRef<List<Review>>;
String _$firebaseReviewSummaryHash() =>
    r'061b38e614b9091d8d6aa3a33c915476ba809265';

/// Get review summary for a product
///
/// Copied from [firebaseReviewSummary].
@ProviderFor(firebaseReviewSummary)
const firebaseReviewSummaryProvider = FirebaseReviewSummaryFamily();

/// Get review summary for a product
///
/// Copied from [firebaseReviewSummary].
class FirebaseReviewSummaryFamily extends Family<AsyncValue<ReviewSummary>> {
  /// Get review summary for a product
  ///
  /// Copied from [firebaseReviewSummary].
  const FirebaseReviewSummaryFamily();

  /// Get review summary for a product
  ///
  /// Copied from [firebaseReviewSummary].
  FirebaseReviewSummaryProvider call(
    String productId,
  ) {
    return FirebaseReviewSummaryProvider(
      productId,
    );
  }

  @override
  FirebaseReviewSummaryProvider getProviderOverride(
    covariant FirebaseReviewSummaryProvider provider,
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
  String? get name => r'firebaseReviewSummaryProvider';
}

/// Get review summary for a product
///
/// Copied from [firebaseReviewSummary].
class FirebaseReviewSummaryProvider
    extends AutoDisposeStreamProvider<ReviewSummary> {
  /// Get review summary for a product
  ///
  /// Copied from [firebaseReviewSummary].
  FirebaseReviewSummaryProvider(
    String productId,
  ) : this._internal(
          (ref) => firebaseReviewSummary(
            ref as FirebaseReviewSummaryRef,
            productId,
          ),
          from: firebaseReviewSummaryProvider,
          name: r'firebaseReviewSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseReviewSummaryHash,
          dependencies: FirebaseReviewSummaryFamily._dependencies,
          allTransitiveDependencies:
              FirebaseReviewSummaryFamily._allTransitiveDependencies,
          productId: productId,
        );

  FirebaseReviewSummaryProvider._internal(
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
    Stream<ReviewSummary> Function(FirebaseReviewSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseReviewSummaryProvider._internal(
        (ref) => create(ref as FirebaseReviewSummaryRef),
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
  AutoDisposeStreamProviderElement<ReviewSummary> createElement() {
    return _FirebaseReviewSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseReviewSummaryProvider &&
        other.productId == productId;
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
mixin FirebaseReviewSummaryRef on AutoDisposeStreamProviderRef<ReviewSummary> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _FirebaseReviewSummaryProviderElement
    extends AutoDisposeStreamProviderElement<ReviewSummary>
    with FirebaseReviewSummaryRef {
  _FirebaseReviewSummaryProviderElement(super.provider);

  @override
  String get productId => (origin as FirebaseReviewSummaryProvider).productId;
}

String _$firebaseFilteredReviewsHash() =>
    r'098dbcd9689caac1029cf3800e4c3b0f2b9aeaab';

/// Stream paginated reviews with filters
/// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
///
/// Copied from [firebaseFilteredReviews].
@ProviderFor(firebaseFilteredReviews)
const firebaseFilteredReviewsProvider = FirebaseFilteredReviewsFamily();

/// Stream paginated reviews with filters
/// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
///
/// Copied from [firebaseFilteredReviews].
class FirebaseFilteredReviewsFamily extends Family<AsyncValue<List<Review>>> {
  /// Stream paginated reviews with filters
  /// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
  ///
  /// Copied from [firebaseFilteredReviews].
  const FirebaseFilteredReviewsFamily();

  /// Stream paginated reviews with filters
  /// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
  ///
  /// Copied from [firebaseFilteredReviews].
  FirebaseFilteredReviewsProvider call(
    ReviewListQuery query,
  ) {
    return FirebaseFilteredReviewsProvider(
      query,
    );
  }

  @override
  FirebaseFilteredReviewsProvider getProviderOverride(
    covariant FirebaseFilteredReviewsProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'firebaseFilteredReviewsProvider';
}

/// Stream paginated reviews with filters
/// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
///
/// Copied from [firebaseFilteredReviews].
class FirebaseFilteredReviewsProvider
    extends AutoDisposeStreamProvider<List<Review>> {
  /// Stream paginated reviews with filters
  /// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
  ///
  /// Copied from [firebaseFilteredReviews].
  FirebaseFilteredReviewsProvider(
    ReviewListQuery query,
  ) : this._internal(
          (ref) => firebaseFilteredReviews(
            ref as FirebaseFilteredReviewsRef,
            query,
          ),
          from: firebaseFilteredReviewsProvider,
          name: r'firebaseFilteredReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseFilteredReviewsHash,
          dependencies: FirebaseFilteredReviewsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseFilteredReviewsFamily._allTransitiveDependencies,
          query: query,
        );

  FirebaseFilteredReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final ReviewListQuery query;

  @override
  Override overrideWith(
    Stream<List<Review>> Function(FirebaseFilteredReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseFilteredReviewsProvider._internal(
        (ref) => create(ref as FirebaseFilteredReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Review>> createElement() {
    return _FirebaseFilteredReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseFilteredReviewsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseFilteredReviewsRef on AutoDisposeStreamProviderRef<List<Review>> {
  /// The parameter `query` of this provider.
  ReviewListQuery get query;
}

class _FirebaseFilteredReviewsProviderElement
    extends AutoDisposeStreamProviderElement<List<Review>>
    with FirebaseFilteredReviewsRef {
  _FirebaseFilteredReviewsProviderElement(super.provider);

  @override
  ReviewListQuery get query =>
      (origin as FirebaseFilteredReviewsProvider).query;
}

String _$reviewServiceHash() => r'd0a849dde5d19b66014cdd7dbbe447793d284814';

/// Service for review operations
///
/// Copied from [reviewService].
@ProviderFor(reviewService)
final reviewServiceProvider = AutoDisposeProvider<ReviewService>.internal(
  reviewService,
  name: r'reviewServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewServiceRef = AutoDisposeProviderRef<ReviewService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
