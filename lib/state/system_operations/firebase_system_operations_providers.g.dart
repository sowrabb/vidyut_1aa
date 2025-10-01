// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_system_operations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebasePendingOperationsHash() =>
    r'c7b1fbd8b4755bd8a0daa8f5793230ef79f40187';

/// Stream pending operations
///
/// Copied from [firebasePendingOperations].
@ProviderFor(firebasePendingOperations)
final firebasePendingOperationsProvider =
    AutoDisposeStreamProvider<List<SystemOperation>>.internal(
  firebasePendingOperations,
  name: r'firebasePendingOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebasePendingOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebasePendingOperationsRef
    = AutoDisposeStreamProviderRef<List<SystemOperation>>;
String _$firebaseOperationsByStatusHash() =>
    r'0a4700189b24fba77f4c3c13867f6e5e614473c0';

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

/// Stream operations by status
///
/// Copied from [firebaseOperationsByStatus].
@ProviderFor(firebaseOperationsByStatus)
const firebaseOperationsByStatusProvider = FirebaseOperationsByStatusFamily();

/// Stream operations by status
///
/// Copied from [firebaseOperationsByStatus].
class FirebaseOperationsByStatusFamily
    extends Family<AsyncValue<List<SystemOperation>>> {
  /// Stream operations by status
  ///
  /// Copied from [firebaseOperationsByStatus].
  const FirebaseOperationsByStatusFamily();

  /// Stream operations by status
  ///
  /// Copied from [firebaseOperationsByStatus].
  FirebaseOperationsByStatusProvider call(
    OperationStatus status,
  ) {
    return FirebaseOperationsByStatusProvider(
      status,
    );
  }

  @override
  FirebaseOperationsByStatusProvider getProviderOverride(
    covariant FirebaseOperationsByStatusProvider provider,
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
  String? get name => r'firebaseOperationsByStatusProvider';
}

/// Stream operations by status
///
/// Copied from [firebaseOperationsByStatus].
class FirebaseOperationsByStatusProvider
    extends AutoDisposeStreamProvider<List<SystemOperation>> {
  /// Stream operations by status
  ///
  /// Copied from [firebaseOperationsByStatus].
  FirebaseOperationsByStatusProvider(
    OperationStatus status,
  ) : this._internal(
          (ref) => firebaseOperationsByStatus(
            ref as FirebaseOperationsByStatusRef,
            status,
          ),
          from: firebaseOperationsByStatusProvider,
          name: r'firebaseOperationsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseOperationsByStatusHash,
          dependencies: FirebaseOperationsByStatusFamily._dependencies,
          allTransitiveDependencies:
              FirebaseOperationsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  FirebaseOperationsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final OperationStatus status;

  @override
  Override overrideWith(
    Stream<List<SystemOperation>> Function(
            FirebaseOperationsByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseOperationsByStatusProvider._internal(
        (ref) => create(ref as FirebaseOperationsByStatusRef),
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
  AutoDisposeStreamProviderElement<List<SystemOperation>> createElement() {
    return _FirebaseOperationsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseOperationsByStatusProvider &&
        other.status == status;
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
mixin FirebaseOperationsByStatusRef
    on AutoDisposeStreamProviderRef<List<SystemOperation>> {
  /// The parameter `status` of this provider.
  OperationStatus get status;
}

class _FirebaseOperationsByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<SystemOperation>>
    with FirebaseOperationsByStatusRef {
  _FirebaseOperationsByStatusProviderElement(super.provider);

  @override
  OperationStatus get status =>
      (origin as FirebaseOperationsByStatusProvider).status;
}

String _$firebaseRecentOperationsHash() =>
    r'06529c6ada088f9b861e7369f4b682e85a7783e6';

/// Stream recent operations
///
/// Copied from [firebaseRecentOperations].
@ProviderFor(firebaseRecentOperations)
const firebaseRecentOperationsProvider = FirebaseRecentOperationsFamily();

/// Stream recent operations
///
/// Copied from [firebaseRecentOperations].
class FirebaseRecentOperationsFamily
    extends Family<AsyncValue<List<SystemOperation>>> {
  /// Stream recent operations
  ///
  /// Copied from [firebaseRecentOperations].
  const FirebaseRecentOperationsFamily();

  /// Stream recent operations
  ///
  /// Copied from [firebaseRecentOperations].
  FirebaseRecentOperationsProvider call({
    int limit = 50,
  }) {
    return FirebaseRecentOperationsProvider(
      limit: limit,
    );
  }

  @override
  FirebaseRecentOperationsProvider getProviderOverride(
    covariant FirebaseRecentOperationsProvider provider,
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
  String? get name => r'firebaseRecentOperationsProvider';
}

/// Stream recent operations
///
/// Copied from [firebaseRecentOperations].
class FirebaseRecentOperationsProvider
    extends AutoDisposeStreamProvider<List<SystemOperation>> {
  /// Stream recent operations
  ///
  /// Copied from [firebaseRecentOperations].
  FirebaseRecentOperationsProvider({
    int limit = 50,
  }) : this._internal(
          (ref) => firebaseRecentOperations(
            ref as FirebaseRecentOperationsRef,
            limit: limit,
          ),
          from: firebaseRecentOperationsProvider,
          name: r'firebaseRecentOperationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseRecentOperationsHash,
          dependencies: FirebaseRecentOperationsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseRecentOperationsFamily._allTransitiveDependencies,
          limit: limit,
        );

  FirebaseRecentOperationsProvider._internal(
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
    Stream<List<SystemOperation>> Function(FirebaseRecentOperationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseRecentOperationsProvider._internal(
        (ref) => create(ref as FirebaseRecentOperationsRef),
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
  AutoDisposeStreamProviderElement<List<SystemOperation>> createElement() {
    return _FirebaseRecentOperationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseRecentOperationsProvider && other.limit == limit;
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
mixin FirebaseRecentOperationsRef
    on AutoDisposeStreamProviderRef<List<SystemOperation>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FirebaseRecentOperationsProviderElement
    extends AutoDisposeStreamProviderElement<List<SystemOperation>>
    with FirebaseRecentOperationsRef {
  _FirebaseRecentOperationsProviderElement(super.provider);

  @override
  int get limit => (origin as FirebaseRecentOperationsProvider).limit;
}

String _$firebaseSystemOperationHash() =>
    r'c9aa7422e97c1849c232687762e91ab7032d61bf';

/// Get a single operation
///
/// Copied from [firebaseSystemOperation].
@ProviderFor(firebaseSystemOperation)
const firebaseSystemOperationProvider = FirebaseSystemOperationFamily();

/// Get a single operation
///
/// Copied from [firebaseSystemOperation].
class FirebaseSystemOperationFamily
    extends Family<AsyncValue<SystemOperation?>> {
  /// Get a single operation
  ///
  /// Copied from [firebaseSystemOperation].
  const FirebaseSystemOperationFamily();

  /// Get a single operation
  ///
  /// Copied from [firebaseSystemOperation].
  FirebaseSystemOperationProvider call(
    String operationId,
  ) {
    return FirebaseSystemOperationProvider(
      operationId,
    );
  }

  @override
  FirebaseSystemOperationProvider getProviderOverride(
    covariant FirebaseSystemOperationProvider provider,
  ) {
    return call(
      provider.operationId,
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
  String? get name => r'firebaseSystemOperationProvider';
}

/// Get a single operation
///
/// Copied from [firebaseSystemOperation].
class FirebaseSystemOperationProvider
    extends AutoDisposeStreamProvider<SystemOperation?> {
  /// Get a single operation
  ///
  /// Copied from [firebaseSystemOperation].
  FirebaseSystemOperationProvider(
    String operationId,
  ) : this._internal(
          (ref) => firebaseSystemOperation(
            ref as FirebaseSystemOperationRef,
            operationId,
          ),
          from: firebaseSystemOperationProvider,
          name: r'firebaseSystemOperationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseSystemOperationHash,
          dependencies: FirebaseSystemOperationFamily._dependencies,
          allTransitiveDependencies:
              FirebaseSystemOperationFamily._allTransitiveDependencies,
          operationId: operationId,
        );

  FirebaseSystemOperationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.operationId,
  }) : super.internal();

  final String operationId;

  @override
  Override overrideWith(
    Stream<SystemOperation?> Function(FirebaseSystemOperationRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseSystemOperationProvider._internal(
        (ref) => create(ref as FirebaseSystemOperationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        operationId: operationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<SystemOperation?> createElement() {
    return _FirebaseSystemOperationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseSystemOperationProvider &&
        other.operationId == operationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, operationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseSystemOperationRef
    on AutoDisposeStreamProviderRef<SystemOperation?> {
  /// The parameter `operationId` of this provider.
  String get operationId;
}

class _FirebaseSystemOperationProviderElement
    extends AutoDisposeStreamProviderElement<SystemOperation?>
    with FirebaseSystemOperationRef {
  _FirebaseSystemOperationProviderElement(super.provider);

  @override
  String get operationId =>
      (origin as FirebaseSystemOperationProvider).operationId;
}

String _$systemOperationServiceHash() =>
    r'e36f5e728d03efa363e9975cb4506fe4894ae95a';

/// Service for system operation management
///
/// Copied from [systemOperationService].
@ProviderFor(systemOperationService)
final systemOperationServiceProvider =
    AutoDisposeProvider<SystemOperationService>.internal(
  systemOperationService,
  name: r'systemOperationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemOperationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SystemOperationServiceRef
    = AutoDisposeProviderRef<SystemOperationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
