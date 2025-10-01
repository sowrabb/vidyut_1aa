// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseSellerLeadsHash() =>
    r'3d5883192e8ba4c6379aaf01193c30c8ff35726d';

/// Stream all leads for the current seller (matched leads)
///
/// Copied from [firebaseSellerLeads].
@ProviderFor(firebaseSellerLeads)
final firebaseSellerLeadsProvider =
    AutoDisposeStreamProvider<List<Lead>>.internal(
  firebaseSellerLeads,
  name: r'firebaseSellerLeadsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSellerLeadsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSellerLeadsRef = AutoDisposeStreamProviderRef<List<Lead>>;
String _$firebaseBuyerLeadsHash() =>
    r'1b779e4c7d5186abde30a291f88a25e32d112003';

/// Stream leads created by current user (buyer)
///
/// Copied from [firebaseBuyerLeads].
@ProviderFor(firebaseBuyerLeads)
final firebaseBuyerLeadsProvider =
    AutoDisposeStreamProvider<List<Lead>>.internal(
  firebaseBuyerLeads,
  name: r'firebaseBuyerLeadsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseBuyerLeadsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseBuyerLeadsRef = AutoDisposeStreamProviderRef<List<Lead>>;
String _$firebaseLeadsByStatusHash() =>
    r'8f7fb1fc3493a02aeb00a11ea1031f72506e0b78';

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

/// Stream leads by status
///
/// Copied from [firebaseLeadsByStatus].
@ProviderFor(firebaseLeadsByStatus)
const firebaseLeadsByStatusProvider = FirebaseLeadsByStatusFamily();

/// Stream leads by status
///
/// Copied from [firebaseLeadsByStatus].
class FirebaseLeadsByStatusFamily extends Family<AsyncValue<List<Lead>>> {
  /// Stream leads by status
  ///
  /// Copied from [firebaseLeadsByStatus].
  const FirebaseLeadsByStatusFamily();

  /// Stream leads by status
  ///
  /// Copied from [firebaseLeadsByStatus].
  FirebaseLeadsByStatusProvider call(
    String status,
  ) {
    return FirebaseLeadsByStatusProvider(
      status,
    );
  }

  @override
  FirebaseLeadsByStatusProvider getProviderOverride(
    covariant FirebaseLeadsByStatusProvider provider,
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
  String? get name => r'firebaseLeadsByStatusProvider';
}

/// Stream leads by status
///
/// Copied from [firebaseLeadsByStatus].
class FirebaseLeadsByStatusProvider
    extends AutoDisposeStreamProvider<List<Lead>> {
  /// Stream leads by status
  ///
  /// Copied from [firebaseLeadsByStatus].
  FirebaseLeadsByStatusProvider(
    String status,
  ) : this._internal(
          (ref) => firebaseLeadsByStatus(
            ref as FirebaseLeadsByStatusRef,
            status,
          ),
          from: firebaseLeadsByStatusProvider,
          name: r'firebaseLeadsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseLeadsByStatusHash,
          dependencies: FirebaseLeadsByStatusFamily._dependencies,
          allTransitiveDependencies:
              FirebaseLeadsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  FirebaseLeadsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    Stream<List<Lead>> Function(FirebaseLeadsByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseLeadsByStatusProvider._internal(
        (ref) => create(ref as FirebaseLeadsByStatusRef),
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
  AutoDisposeStreamProviderElement<List<Lead>> createElement() {
    return _FirebaseLeadsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseLeadsByStatusProvider && other.status == status;
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
mixin FirebaseLeadsByStatusRef on AutoDisposeStreamProviderRef<List<Lead>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _FirebaseLeadsByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<Lead>>
    with FirebaseLeadsByStatusRef {
  _FirebaseLeadsByStatusProviderElement(super.provider);

  @override
  String get status => (origin as FirebaseLeadsByStatusProvider).status;
}

String _$firebaseLeadHash() => r'7b895f76055d7fbd072b000c16c2ed780e4d2535';

/// Get a single lead by ID
///
/// Copied from [firebaseLead].
@ProviderFor(firebaseLead)
const firebaseLeadProvider = FirebaseLeadFamily();

/// Get a single lead by ID
///
/// Copied from [firebaseLead].
class FirebaseLeadFamily extends Family<AsyncValue<Lead?>> {
  /// Get a single lead by ID
  ///
  /// Copied from [firebaseLead].
  const FirebaseLeadFamily();

  /// Get a single lead by ID
  ///
  /// Copied from [firebaseLead].
  FirebaseLeadProvider call(
    String leadId,
  ) {
    return FirebaseLeadProvider(
      leadId,
    );
  }

  @override
  FirebaseLeadProvider getProviderOverride(
    covariant FirebaseLeadProvider provider,
  ) {
    return call(
      provider.leadId,
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
  String? get name => r'firebaseLeadProvider';
}

/// Get a single lead by ID
///
/// Copied from [firebaseLead].
class FirebaseLeadProvider extends AutoDisposeStreamProvider<Lead?> {
  /// Get a single lead by ID
  ///
  /// Copied from [firebaseLead].
  FirebaseLeadProvider(
    String leadId,
  ) : this._internal(
          (ref) => firebaseLead(
            ref as FirebaseLeadRef,
            leadId,
          ),
          from: firebaseLeadProvider,
          name: r'firebaseLeadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseLeadHash,
          dependencies: FirebaseLeadFamily._dependencies,
          allTransitiveDependencies:
              FirebaseLeadFamily._allTransitiveDependencies,
          leadId: leadId,
        );

  FirebaseLeadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.leadId,
  }) : super.internal();

  final String leadId;

  @override
  Override overrideWith(
    Stream<Lead?> Function(FirebaseLeadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseLeadProvider._internal(
        (ref) => create(ref as FirebaseLeadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        leadId: leadId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Lead?> createElement() {
    return _FirebaseLeadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseLeadProvider && other.leadId == leadId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, leadId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseLeadRef on AutoDisposeStreamProviderRef<Lead?> {
  /// The parameter `leadId` of this provider.
  String get leadId;
}

class _FirebaseLeadProviderElement
    extends AutoDisposeStreamProviderElement<Lead?> with FirebaseLeadRef {
  _FirebaseLeadProviderElement(super.provider);

  @override
  String get leadId => (origin as FirebaseLeadProvider).leadId;
}

String _$leadServiceHash() => r'055bdc2693dd3e816f9c20a54daa92ea9c7592f8';

/// Service for lead operations
///
/// Copied from [leadService].
@ProviderFor(leadService)
final leadServiceProvider = AutoDisposeProvider<LeadService>.internal(
  leadService,
  name: r'leadServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$leadServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeadServiceRef = AutoDisposeProviderRef<LeadService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
