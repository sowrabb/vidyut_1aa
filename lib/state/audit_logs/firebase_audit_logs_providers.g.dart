// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_audit_logs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseRecentAuditLogsHash() =>
    r'd6cae186a2060eb3987b4a4e071637800f4dde0f';

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

/// Stream recent audit logs (admin only)
///
/// Copied from [firebaseRecentAuditLogs].
@ProviderFor(firebaseRecentAuditLogs)
const firebaseRecentAuditLogsProvider = FirebaseRecentAuditLogsFamily();

/// Stream recent audit logs (admin only)
///
/// Copied from [firebaseRecentAuditLogs].
class FirebaseRecentAuditLogsFamily
    extends Family<AsyncValue<List<AuditLogEntry>>> {
  /// Stream recent audit logs (admin only)
  ///
  /// Copied from [firebaseRecentAuditLogs].
  const FirebaseRecentAuditLogsFamily();

  /// Stream recent audit logs (admin only)
  ///
  /// Copied from [firebaseRecentAuditLogs].
  FirebaseRecentAuditLogsProvider call({
    int limit = 50,
  }) {
    return FirebaseRecentAuditLogsProvider(
      limit: limit,
    );
  }

  @override
  FirebaseRecentAuditLogsProvider getProviderOverride(
    covariant FirebaseRecentAuditLogsProvider provider,
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
  String? get name => r'firebaseRecentAuditLogsProvider';
}

/// Stream recent audit logs (admin only)
///
/// Copied from [firebaseRecentAuditLogs].
class FirebaseRecentAuditLogsProvider
    extends AutoDisposeStreamProvider<List<AuditLogEntry>> {
  /// Stream recent audit logs (admin only)
  ///
  /// Copied from [firebaseRecentAuditLogs].
  FirebaseRecentAuditLogsProvider({
    int limit = 50,
  }) : this._internal(
          (ref) => firebaseRecentAuditLogs(
            ref as FirebaseRecentAuditLogsRef,
            limit: limit,
          ),
          from: firebaseRecentAuditLogsProvider,
          name: r'firebaseRecentAuditLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseRecentAuditLogsHash,
          dependencies: FirebaseRecentAuditLogsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseRecentAuditLogsFamily._allTransitiveDependencies,
          limit: limit,
        );

  FirebaseRecentAuditLogsProvider._internal(
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
    Stream<List<AuditLogEntry>> Function(FirebaseRecentAuditLogsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseRecentAuditLogsProvider._internal(
        (ref) => create(ref as FirebaseRecentAuditLogsRef),
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
  AutoDisposeStreamProviderElement<List<AuditLogEntry>> createElement() {
    return _FirebaseRecentAuditLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseRecentAuditLogsProvider && other.limit == limit;
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
mixin FirebaseRecentAuditLogsRef
    on AutoDisposeStreamProviderRef<List<AuditLogEntry>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FirebaseRecentAuditLogsProviderElement
    extends AutoDisposeStreamProviderElement<List<AuditLogEntry>>
    with FirebaseRecentAuditLogsRef {
  _FirebaseRecentAuditLogsProviderElement(super.provider);

  @override
  int get limit => (origin as FirebaseRecentAuditLogsProvider).limit;
}

String _$firebaseEntityAuditLogsHash() =>
    r'66d7b6230830469ef3e588c46e7c0f86f7fd5ad4';

/// Stream audit logs by entity (e.g., all logs for a specific product)
///
/// Copied from [firebaseEntityAuditLogs].
@ProviderFor(firebaseEntityAuditLogs)
const firebaseEntityAuditLogsProvider = FirebaseEntityAuditLogsFamily();

/// Stream audit logs by entity (e.g., all logs for a specific product)
///
/// Copied from [firebaseEntityAuditLogs].
class FirebaseEntityAuditLogsFamily
    extends Family<AsyncValue<List<AuditLogEntry>>> {
  /// Stream audit logs by entity (e.g., all logs for a specific product)
  ///
  /// Copied from [firebaseEntityAuditLogs].
  const FirebaseEntityAuditLogsFamily();

  /// Stream audit logs by entity (e.g., all logs for a specific product)
  ///
  /// Copied from [firebaseEntityAuditLogs].
  FirebaseEntityAuditLogsProvider call(
    String entityType,
    String entityId,
  ) {
    return FirebaseEntityAuditLogsProvider(
      entityType,
      entityId,
    );
  }

  @override
  FirebaseEntityAuditLogsProvider getProviderOverride(
    covariant FirebaseEntityAuditLogsProvider provider,
  ) {
    return call(
      provider.entityType,
      provider.entityId,
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
  String? get name => r'firebaseEntityAuditLogsProvider';
}

/// Stream audit logs by entity (e.g., all logs for a specific product)
///
/// Copied from [firebaseEntityAuditLogs].
class FirebaseEntityAuditLogsProvider
    extends AutoDisposeStreamProvider<List<AuditLogEntry>> {
  /// Stream audit logs by entity (e.g., all logs for a specific product)
  ///
  /// Copied from [firebaseEntityAuditLogs].
  FirebaseEntityAuditLogsProvider(
    String entityType,
    String entityId,
  ) : this._internal(
          (ref) => firebaseEntityAuditLogs(
            ref as FirebaseEntityAuditLogsRef,
            entityType,
            entityId,
          ),
          from: firebaseEntityAuditLogsProvider,
          name: r'firebaseEntityAuditLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseEntityAuditLogsHash,
          dependencies: FirebaseEntityAuditLogsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseEntityAuditLogsFamily._allTransitiveDependencies,
          entityType: entityType,
          entityId: entityId,
        );

  FirebaseEntityAuditLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entityType,
    required this.entityId,
  }) : super.internal();

  final String entityType;
  final String entityId;

  @override
  Override overrideWith(
    Stream<List<AuditLogEntry>> Function(FirebaseEntityAuditLogsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseEntityAuditLogsProvider._internal(
        (ref) => create(ref as FirebaseEntityAuditLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entityType: entityType,
        entityId: entityId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AuditLogEntry>> createElement() {
    return _FirebaseEntityAuditLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseEntityAuditLogsProvider &&
        other.entityType == entityType &&
        other.entityId == entityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entityType.hashCode);
    hash = _SystemHash.combine(hash, entityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseEntityAuditLogsRef
    on AutoDisposeStreamProviderRef<List<AuditLogEntry>> {
  /// The parameter `entityType` of this provider.
  String get entityType;

  /// The parameter `entityId` of this provider.
  String get entityId;
}

class _FirebaseEntityAuditLogsProviderElement
    extends AutoDisposeStreamProviderElement<List<AuditLogEntry>>
    with FirebaseEntityAuditLogsRef {
  _FirebaseEntityAuditLogsProviderElement(super.provider);

  @override
  String get entityType =>
      (origin as FirebaseEntityAuditLogsProvider).entityType;
  @override
  String get entityId => (origin as FirebaseEntityAuditLogsProvider).entityId;
}

String _$firebaseUserAuditLogsHash() =>
    r'59612e9bb15176d65011f33ef5c9140d8fd7c8ed';

/// Stream audit logs by user (track what a specific user did)
///
/// Copied from [firebaseUserAuditLogs].
@ProviderFor(firebaseUserAuditLogs)
const firebaseUserAuditLogsProvider = FirebaseUserAuditLogsFamily();

/// Stream audit logs by user (track what a specific user did)
///
/// Copied from [firebaseUserAuditLogs].
class FirebaseUserAuditLogsFamily
    extends Family<AsyncValue<List<AuditLogEntry>>> {
  /// Stream audit logs by user (track what a specific user did)
  ///
  /// Copied from [firebaseUserAuditLogs].
  const FirebaseUserAuditLogsFamily();

  /// Stream audit logs by user (track what a specific user did)
  ///
  /// Copied from [firebaseUserAuditLogs].
  FirebaseUserAuditLogsProvider call(
    String userId,
  ) {
    return FirebaseUserAuditLogsProvider(
      userId,
    );
  }

  @override
  FirebaseUserAuditLogsProvider getProviderOverride(
    covariant FirebaseUserAuditLogsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'firebaseUserAuditLogsProvider';
}

/// Stream audit logs by user (track what a specific user did)
///
/// Copied from [firebaseUserAuditLogs].
class FirebaseUserAuditLogsProvider
    extends AutoDisposeStreamProvider<List<AuditLogEntry>> {
  /// Stream audit logs by user (track what a specific user did)
  ///
  /// Copied from [firebaseUserAuditLogs].
  FirebaseUserAuditLogsProvider(
    String userId,
  ) : this._internal(
          (ref) => firebaseUserAuditLogs(
            ref as FirebaseUserAuditLogsRef,
            userId,
          ),
          from: firebaseUserAuditLogsProvider,
          name: r'firebaseUserAuditLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseUserAuditLogsHash,
          dependencies: FirebaseUserAuditLogsFamily._dependencies,
          allTransitiveDependencies:
              FirebaseUserAuditLogsFamily._allTransitiveDependencies,
          userId: userId,
        );

  FirebaseUserAuditLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<AuditLogEntry>> Function(FirebaseUserAuditLogsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseUserAuditLogsProvider._internal(
        (ref) => create(ref as FirebaseUserAuditLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AuditLogEntry>> createElement() {
    return _FirebaseUserAuditLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseUserAuditLogsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseUserAuditLogsRef
    on AutoDisposeStreamProviderRef<List<AuditLogEntry>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FirebaseUserAuditLogsProviderElement
    extends AutoDisposeStreamProviderElement<List<AuditLogEntry>>
    with FirebaseUserAuditLogsRef {
  _FirebaseUserAuditLogsProviderElement(super.provider);

  @override
  String get userId => (origin as FirebaseUserAuditLogsProvider).userId;
}

String _$auditLogServiceHash() => r'bdc35e6366d0a012c1b48af41f0b6ad9767568b3';

/// Service for audit log operations
///
/// Copied from [auditLogService].
@ProviderFor(auditLogService)
final auditLogServiceProvider = AutoDisposeProvider<AuditLogService>.internal(
  auditLogService,
  name: r'auditLogServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditLogServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuditLogServiceRef = AutoDisposeProviderRef<AuditLogService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
