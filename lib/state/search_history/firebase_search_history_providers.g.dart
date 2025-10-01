// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_search_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseUserSearchHistoryHash() =>
    r'3e5da0be581f636a553bc714ac4db1c5fb9ca3dd';

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

/// Stream user's recent searches
///
/// Copied from [firebaseUserSearchHistory].
@ProviderFor(firebaseUserSearchHistory)
const firebaseUserSearchHistoryProvider = FirebaseUserSearchHistoryFamily();

/// Stream user's recent searches
///
/// Copied from [firebaseUserSearchHistory].
class FirebaseUserSearchHistoryFamily
    extends Family<AsyncValue<List<SearchHistoryEntry>>> {
  /// Stream user's recent searches
  ///
  /// Copied from [firebaseUserSearchHistory].
  const FirebaseUserSearchHistoryFamily();

  /// Stream user's recent searches
  ///
  /// Copied from [firebaseUserSearchHistory].
  FirebaseUserSearchHistoryProvider call({
    int limit = 20,
  }) {
    return FirebaseUserSearchHistoryProvider(
      limit: limit,
    );
  }

  @override
  FirebaseUserSearchHistoryProvider getProviderOverride(
    covariant FirebaseUserSearchHistoryProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'firebaseUserSearchHistoryProvider';
}

/// Stream user's recent searches
///
/// Copied from [firebaseUserSearchHistory].
class FirebaseUserSearchHistoryProvider
    extends AutoDisposeStreamProvider<List<SearchHistoryEntry>> {
  /// Stream user's recent searches
  ///
  /// Copied from [firebaseUserSearchHistory].
  FirebaseUserSearchHistoryProvider({
    int limit = 20,
  }) : this._internal(
          (ref) => firebaseUserSearchHistory(
            ref as FirebaseUserSearchHistoryRef,
            limit: limit,
          ),
          from: firebaseUserSearchHistoryProvider,
          name: r'firebaseUserSearchHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseUserSearchHistoryHash,
          dependencies: FirebaseUserSearchHistoryFamily._dependencies,
          allTransitiveDependencies:
              FirebaseUserSearchHistoryFamily._allTransitiveDependencies,
          limit: limit,
        );

  FirebaseUserSearchHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    Stream<List<SearchHistoryEntry>> Function(
            FirebaseUserSearchHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseUserSearchHistoryProvider._internal(
        (ref) => create(ref as FirebaseUserSearchHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SearchHistoryEntry>> createElement() {
    return _FirebaseUserSearchHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseUserSearchHistoryProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseUserSearchHistoryRef
    on AutoDisposeStreamProviderRef<List<SearchHistoryEntry>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FirebaseUserSearchHistoryProviderElement
    extends AutoDisposeStreamProviderElement<List<SearchHistoryEntry>>
    with FirebaseUserSearchHistoryRef {
  _FirebaseUserSearchHistoryProviderElement(super.provider);

  @override
  int get limit => (origin as FirebaseUserSearchHistoryProvider).limit;
}

String _$firebasePopularSearchesHash() =>
    r'14681bc1b86af1ce001bbd0f252e202de434d6ab';

/// Stream popular searches (trending)
///
/// Copied from [firebasePopularSearches].
@ProviderFor(firebasePopularSearches)
const firebasePopularSearchesProvider = FirebasePopularSearchesFamily();

/// Stream popular searches (trending)
///
/// Copied from [firebasePopularSearches].
class FirebasePopularSearchesFamily
    extends Family<AsyncValue<List<PopularSearch>>> {
  /// Stream popular searches (trending)
  ///
  /// Copied from [firebasePopularSearches].
  const FirebasePopularSearchesFamily();

  /// Stream popular searches (trending)
  ///
  /// Copied from [firebasePopularSearches].
  FirebasePopularSearchesProvider call({
    int limit = 10,
  }) {
    return FirebasePopularSearchesProvider(
      limit: limit,
    );
  }

  @override
  FirebasePopularSearchesProvider getProviderOverride(
    covariant FirebasePopularSearchesProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'firebasePopularSearchesProvider';
}

/// Stream popular searches (trending)
///
/// Copied from [firebasePopularSearches].
class FirebasePopularSearchesProvider
    extends AutoDisposeStreamProvider<List<PopularSearch>> {
  /// Stream popular searches (trending)
  ///
  /// Copied from [firebasePopularSearches].
  FirebasePopularSearchesProvider({
    int limit = 10,
  }) : this._internal(
          (ref) => firebasePopularSearches(
            ref as FirebasePopularSearchesRef,
            limit: limit,
          ),
          from: firebasePopularSearchesProvider,
          name: r'firebasePopularSearchesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebasePopularSearchesHash,
          dependencies: FirebasePopularSearchesFamily._dependencies,
          allTransitiveDependencies:
              FirebasePopularSearchesFamily._allTransitiveDependencies,
          limit: limit,
        );

  FirebasePopularSearchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    Stream<List<PopularSearch>> Function(FirebasePopularSearchesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebasePopularSearchesProvider._internal(
        (ref) => create(ref as FirebasePopularSearchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PopularSearch>> createElement() {
    return _FirebasePopularSearchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebasePopularSearchesProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebasePopularSearchesRef
    on AutoDisposeStreamProviderRef<List<PopularSearch>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FirebasePopularSearchesProviderElement
    extends AutoDisposeStreamProviderElement<List<PopularSearch>>
    with FirebasePopularSearchesRef {
  _FirebasePopularSearchesProviderElement(super.provider);

  @override
  int get limit => (origin as FirebasePopularSearchesProvider).limit;
}

String _$firebaseSearchSuggestionsHash() =>
    r'cd76102ed2f5d534e000e90fa8ba3cd4acac343b';

/// Stream search suggestions based on query
///
/// Copied from [firebaseSearchSuggestions].
@ProviderFor(firebaseSearchSuggestions)
const firebaseSearchSuggestionsProvider = FirebaseSearchSuggestionsFamily();

/// Stream search suggestions based on query
///
/// Copied from [firebaseSearchSuggestions].
class FirebaseSearchSuggestionsFamily extends Family<AsyncValue<List<String>>> {
  /// Stream search suggestions based on query
  ///
  /// Copied from [firebaseSearchSuggestions].
  const FirebaseSearchSuggestionsFamily();

  /// Stream search suggestions based on query
  ///
  /// Copied from [firebaseSearchSuggestions].
  FirebaseSearchSuggestionsProvider call(
    String query,
  ) {
    return FirebaseSearchSuggestionsProvider(
      query,
    );
  }

  @override
  FirebaseSearchSuggestionsProvider getProviderOverride(
    covariant FirebaseSearchSuggestionsProvider provider,
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
  String? get name => r'firebaseSearchSuggestionsProvider';
}

/// Stream search suggestions based on query
///
/// Copied from [firebaseSearchSuggestions].
class FirebaseSearchSuggestionsProvider
    extends AutoDisposeStreamProvider<List<String>> {
  /// Stream search suggestions based on query
  ///
  /// Copied from [firebaseSearchSuggestions].
  FirebaseSearchSuggestionsProvider(
    String query,
  ) : this._internal(
          (ref) => firebaseSearchSuggestions(
            ref as FirebaseSearchSuggestionsRef,
            query,
          ),
          from: firebaseSearchSuggestionsProvider,
          name: r'firebaseSearchSuggestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseSearchSuggestionsHash,
          dependencies: FirebaseSearchSuggestionsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseSearchSuggestionsFamily._allTransitiveDependencies,
          query: query,
        );

  FirebaseSearchSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    Stream<List<String>> Function(FirebaseSearchSuggestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseSearchSuggestionsProvider._internal(
        (ref) => create(ref as FirebaseSearchSuggestionsRef),
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
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _FirebaseSearchSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseSearchSuggestionsProvider && other.query == query;
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
mixin FirebaseSearchSuggestionsRef
    on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _FirebaseSearchSuggestionsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with FirebaseSearchSuggestionsRef {
  _FirebaseSearchSuggestionsProviderElement(super.provider);

  @override
  String get query => (origin as FirebaseSearchSuggestionsProvider).query;
}

String _$firebaseSearchesByCategoryHash() =>
    r'fdcef9437eab2565fdff20cc6d2b47e68cd4fd89';

/// Stream searches by category
///
/// Copied from [firebaseSearchesByCategory].
@ProviderFor(firebaseSearchesByCategory)
const firebaseSearchesByCategoryProvider = FirebaseSearchesByCategoryFamily();

/// Stream searches by category
///
/// Copied from [firebaseSearchesByCategory].
class FirebaseSearchesByCategoryFamily
    extends Family<AsyncValue<List<SearchHistoryEntry>>> {
  /// Stream searches by category
  ///
  /// Copied from [firebaseSearchesByCategory].
  const FirebaseSearchesByCategoryFamily();

  /// Stream searches by category
  ///
  /// Copied from [firebaseSearchesByCategory].
  FirebaseSearchesByCategoryProvider call(
    String category,
  ) {
    return FirebaseSearchesByCategoryProvider(
      category,
    );
  }

  @override
  FirebaseSearchesByCategoryProvider getProviderOverride(
    covariant FirebaseSearchesByCategoryProvider provider,
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
  String? get name => r'firebaseSearchesByCategoryProvider';
}

/// Stream searches by category
///
/// Copied from [firebaseSearchesByCategory].
class FirebaseSearchesByCategoryProvider
    extends AutoDisposeStreamProvider<List<SearchHistoryEntry>> {
  /// Stream searches by category
  ///
  /// Copied from [firebaseSearchesByCategory].
  FirebaseSearchesByCategoryProvider(
    String category,
  ) : this._internal(
          (ref) => firebaseSearchesByCategory(
            ref as FirebaseSearchesByCategoryRef,
            category,
          ),
          from: firebaseSearchesByCategoryProvider,
          name: r'firebaseSearchesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseSearchesByCategoryHash,
          dependencies: FirebaseSearchesByCategoryFamily._dependencies,
          allTransitiveDependencies:
              FirebaseSearchesByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  FirebaseSearchesByCategoryProvider._internal(
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
    Stream<List<SearchHistoryEntry>> Function(
            FirebaseSearchesByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseSearchesByCategoryProvider._internal(
        (ref) => create(ref as FirebaseSearchesByCategoryRef),
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
  AutoDisposeStreamProviderElement<List<SearchHistoryEntry>> createElement() {
    return _FirebaseSearchesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseSearchesByCategoryProvider &&
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
mixin FirebaseSearchesByCategoryRef
    on AutoDisposeStreamProviderRef<List<SearchHistoryEntry>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _FirebaseSearchesByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<SearchHistoryEntry>>
    with FirebaseSearchesByCategoryRef {
  _FirebaseSearchesByCategoryProviderElement(super.provider);

  @override
  String get category =>
      (origin as FirebaseSearchesByCategoryProvider).category;
}

String _$searchHistoryServiceHash() =>
    r'f221805591def80b6f1ffe944105dfc190b62d9f';

/// Service for search history operations
///
/// Copied from [searchHistoryService].
@ProviderFor(searchHistoryService)
final searchHistoryServiceProvider =
    AutoDisposeProvider<SearchHistoryService>.internal(
  searchHistoryService,
  name: r'searchHistoryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchHistoryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchHistoryServiceRef = AutoDisposeProviderRef<SearchHistoryService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
