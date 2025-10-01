// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_state_info_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAllStatesHash() => r'1e71f04df2957cb46488101d103c94d23068d457';

/// Stream all Indian states with electrical info
///
/// Copied from [firebaseAllStates].
@ProviderFor(firebaseAllStates)
final firebaseAllStatesProvider =
    AutoDisposeStreamProvider<List<StateInfo>>.internal(
  firebaseAllStates,
  name: r'firebaseAllStatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAllStatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAllStatesRef = AutoDisposeStreamProviderRef<List<StateInfo>>;
String _$firebaseStateInfoHash() => r'2fea84f213453dcc410d050dcde44cec40c0bea0';

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

/// Get a single state by ID
///
/// Copied from [firebaseStateInfo].
@ProviderFor(firebaseStateInfo)
const firebaseStateInfoProvider = FirebaseStateInfoFamily();

/// Get a single state by ID
///
/// Copied from [firebaseStateInfo].
class FirebaseStateInfoFamily extends Family<AsyncValue<StateInfo?>> {
  /// Get a single state by ID
  ///
  /// Copied from [firebaseStateInfo].
  const FirebaseStateInfoFamily();

  /// Get a single state by ID
  ///
  /// Copied from [firebaseStateInfo].
  FirebaseStateInfoProvider call(
    String stateId,
  ) {
    return FirebaseStateInfoProvider(
      stateId,
    );
  }

  @override
  FirebaseStateInfoProvider getProviderOverride(
    covariant FirebaseStateInfoProvider provider,
  ) {
    return call(
      provider.stateId,
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
  String? get name => r'firebaseStateInfoProvider';
}

/// Get a single state by ID
///
/// Copied from [firebaseStateInfo].
class FirebaseStateInfoProvider extends AutoDisposeStreamProvider<StateInfo?> {
  /// Get a single state by ID
  ///
  /// Copied from [firebaseStateInfo].
  FirebaseStateInfoProvider(
    String stateId,
  ) : this._internal(
          (ref) => firebaseStateInfo(
            ref as FirebaseStateInfoRef,
            stateId,
          ),
          from: firebaseStateInfoProvider,
          name: r'firebaseStateInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseStateInfoHash,
          dependencies: FirebaseStateInfoFamily._dependencies,
          allTransitiveDependencies:
              FirebaseStateInfoFamily._allTransitiveDependencies,
          stateId: stateId,
        );

  FirebaseStateInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stateId,
  }) : super.internal();

  final String stateId;

  @override
  Override overrideWith(
    Stream<StateInfo?> Function(FirebaseStateInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseStateInfoProvider._internal(
        (ref) => create(ref as FirebaseStateInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stateId: stateId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<StateInfo?> createElement() {
    return _FirebaseStateInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseStateInfoProvider && other.stateId == stateId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stateId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseStateInfoRef on AutoDisposeStreamProviderRef<StateInfo?> {
  /// The parameter `stateId` of this provider.
  String get stateId;
}

class _FirebaseStateInfoProviderElement
    extends AutoDisposeStreamProviderElement<StateInfo?>
    with FirebaseStateInfoRef {
  _FirebaseStateInfoProviderElement(super.provider);

  @override
  String get stateId => (origin as FirebaseStateInfoProvider).stateId;
}

String _$firebaseStateByCodeHash() =>
    r'143e459e0979c600c7241fe3a1e15cdeb800cd22';

/// Get state by state code (e.g., "MH" for Maharashtra)
///
/// Copied from [firebaseStateByCode].
@ProviderFor(firebaseStateByCode)
const firebaseStateByCodeProvider = FirebaseStateByCodeFamily();

/// Get state by state code (e.g., "MH" for Maharashtra)
///
/// Copied from [firebaseStateByCode].
class FirebaseStateByCodeFamily extends Family<AsyncValue<StateInfo?>> {
  /// Get state by state code (e.g., "MH" for Maharashtra)
  ///
  /// Copied from [firebaseStateByCode].
  const FirebaseStateByCodeFamily();

  /// Get state by state code (e.g., "MH" for Maharashtra)
  ///
  /// Copied from [firebaseStateByCode].
  FirebaseStateByCodeProvider call(
    String stateCode,
  ) {
    return FirebaseStateByCodeProvider(
      stateCode,
    );
  }

  @override
  FirebaseStateByCodeProvider getProviderOverride(
    covariant FirebaseStateByCodeProvider provider,
  ) {
    return call(
      provider.stateCode,
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
  String? get name => r'firebaseStateByCodeProvider';
}

/// Get state by state code (e.g., "MH" for Maharashtra)
///
/// Copied from [firebaseStateByCode].
class FirebaseStateByCodeProvider
    extends AutoDisposeStreamProvider<StateInfo?> {
  /// Get state by state code (e.g., "MH" for Maharashtra)
  ///
  /// Copied from [firebaseStateByCode].
  FirebaseStateByCodeProvider(
    String stateCode,
  ) : this._internal(
          (ref) => firebaseStateByCode(
            ref as FirebaseStateByCodeRef,
            stateCode,
          ),
          from: firebaseStateByCodeProvider,
          name: r'firebaseStateByCodeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseStateByCodeHash,
          dependencies: FirebaseStateByCodeFamily._dependencies,
          allTransitiveDependencies:
              FirebaseStateByCodeFamily._allTransitiveDependencies,
          stateCode: stateCode,
        );

  FirebaseStateByCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stateCode,
  }) : super.internal();

  final String stateCode;

  @override
  Override overrideWith(
    Stream<StateInfo?> Function(FirebaseStateByCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseStateByCodeProvider._internal(
        (ref) => create(ref as FirebaseStateByCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stateCode: stateCode,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<StateInfo?> createElement() {
    return _FirebaseStateByCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseStateByCodeProvider && other.stateCode == stateCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stateCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseStateByCodeRef on AutoDisposeStreamProviderRef<StateInfo?> {
  /// The parameter `stateCode` of this provider.
  String get stateCode;
}

class _FirebaseStateByCodeProviderElement
    extends AutoDisposeStreamProviderElement<StateInfo?>
    with FirebaseStateByCodeRef {
  _FirebaseStateByCodeProviderElement(super.provider);

  @override
  String get stateCode => (origin as FirebaseStateByCodeProvider).stateCode;
}

String _$firebaseSearchStatesHash() =>
    r'3316d492b9b1cdc671aa028c5b23971085caf84c';

/// Search states by name
///
/// Copied from [firebaseSearchStates].
@ProviderFor(firebaseSearchStates)
const firebaseSearchStatesProvider = FirebaseSearchStatesFamily();

/// Search states by name
///
/// Copied from [firebaseSearchStates].
class FirebaseSearchStatesFamily extends Family<AsyncValue<List<StateInfo>>> {
  /// Search states by name
  ///
  /// Copied from [firebaseSearchStates].
  const FirebaseSearchStatesFamily();

  /// Search states by name
  ///
  /// Copied from [firebaseSearchStates].
  FirebaseSearchStatesProvider call(
    String searchQuery,
  ) {
    return FirebaseSearchStatesProvider(
      searchQuery,
    );
  }

  @override
  FirebaseSearchStatesProvider getProviderOverride(
    covariant FirebaseSearchStatesProvider provider,
  ) {
    return call(
      provider.searchQuery,
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
  String? get name => r'firebaseSearchStatesProvider';
}

/// Search states by name
///
/// Copied from [firebaseSearchStates].
class FirebaseSearchStatesProvider
    extends AutoDisposeStreamProvider<List<StateInfo>> {
  /// Search states by name
  ///
  /// Copied from [firebaseSearchStates].
  FirebaseSearchStatesProvider(
    String searchQuery,
  ) : this._internal(
          (ref) => firebaseSearchStates(
            ref as FirebaseSearchStatesRef,
            searchQuery,
          ),
          from: firebaseSearchStatesProvider,
          name: r'firebaseSearchStatesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseSearchStatesHash,
          dependencies: FirebaseSearchStatesFamily._dependencies,
          allTransitiveDependencies:
              FirebaseSearchStatesFamily._allTransitiveDependencies,
          searchQuery: searchQuery,
        );

  FirebaseSearchStatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
  }) : super.internal();

  final String searchQuery;

  @override
  Override overrideWith(
    Stream<List<StateInfo>> Function(FirebaseSearchStatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseSearchStatesProvider._internal(
        (ref) => create(ref as FirebaseSearchStatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<StateInfo>> createElement() {
    return _FirebaseSearchStatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseSearchStatesProvider &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseSearchStatesRef on AutoDisposeStreamProviderRef<List<StateInfo>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;
}

class _FirebaseSearchStatesProviderElement
    extends AutoDisposeStreamProviderElement<List<StateInfo>>
    with FirebaseSearchStatesRef {
  _FirebaseSearchStatesProviderElement(super.provider);

  @override
  String get searchQuery =>
      (origin as FirebaseSearchStatesProvider).searchQuery;
}

String _$stateInfoServiceHash() => r'7fe3a4113bed1c629ab0517168a3b5108da8c2b0';

/// Service for state info operations
///
/// Copied from [stateInfoService].
@ProviderFor(stateInfoService)
final stateInfoServiceProvider = AutoDisposeProvider<StateInfoService>.internal(
  stateInfoService,
  name: r'stateInfoServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stateInfoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StateInfoServiceRef = AutoDisposeProviderRef<StateInfoService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
