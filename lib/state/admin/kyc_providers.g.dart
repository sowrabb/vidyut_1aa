// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kycPendingSubmissionsHash() =>
    r'df3270a9120e4ecd8feaf1405942d2ee02e4a915';

/// Stream of pending KYC submissions awaiting review
///
/// Copied from [kycPendingSubmissions].
@ProviderFor(kycPendingSubmissions)
final kycPendingSubmissionsProvider =
    AutoDisposeStreamProvider<List<KycSubmission>>.internal(
  kycPendingSubmissions,
  name: r'kycPendingSubmissionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycPendingSubmissionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycPendingSubmissionsRef
    = AutoDisposeStreamProviderRef<List<KycSubmission>>;
String _$kycSubmissionsByStatusHash() =>
    r'761c47696f78ad3a62d6bdb0974776f50c292b11';

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

/// Stream of all KYC submissions with optional status filter
///
/// Copied from [kycSubmissionsByStatus].
@ProviderFor(kycSubmissionsByStatus)
const kycSubmissionsByStatusProvider = KycSubmissionsByStatusFamily();

/// Stream of all KYC submissions with optional status filter
///
/// Copied from [kycSubmissionsByStatus].
class KycSubmissionsByStatusFamily
    extends Family<AsyncValue<List<KycSubmission>>> {
  /// Stream of all KYC submissions with optional status filter
  ///
  /// Copied from [kycSubmissionsByStatus].
  const KycSubmissionsByStatusFamily();

  /// Stream of all KYC submissions with optional status filter
  ///
  /// Copied from [kycSubmissionsByStatus].
  KycSubmissionsByStatusProvider call(
    String? status,
  ) {
    return KycSubmissionsByStatusProvider(
      status,
    );
  }

  @override
  KycSubmissionsByStatusProvider getProviderOverride(
    covariant KycSubmissionsByStatusProvider provider,
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
  String? get name => r'kycSubmissionsByStatusProvider';
}

/// Stream of all KYC submissions with optional status filter
///
/// Copied from [kycSubmissionsByStatus].
class KycSubmissionsByStatusProvider
    extends AutoDisposeStreamProvider<List<KycSubmission>> {
  /// Stream of all KYC submissions with optional status filter
  ///
  /// Copied from [kycSubmissionsByStatus].
  KycSubmissionsByStatusProvider(
    String? status,
  ) : this._internal(
          (ref) => kycSubmissionsByStatus(
            ref as KycSubmissionsByStatusRef,
            status,
          ),
          from: kycSubmissionsByStatusProvider,
          name: r'kycSubmissionsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kycSubmissionsByStatusHash,
          dependencies: KycSubmissionsByStatusFamily._dependencies,
          allTransitiveDependencies:
              KycSubmissionsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  KycSubmissionsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    Stream<List<KycSubmission>> Function(KycSubmissionsByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KycSubmissionsByStatusProvider._internal(
        (ref) => create(ref as KycSubmissionsByStatusRef),
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
  AutoDisposeStreamProviderElement<List<KycSubmission>> createElement() {
    return _KycSubmissionsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KycSubmissionsByStatusProvider && other.status == status;
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
mixin KycSubmissionsByStatusRef
    on AutoDisposeStreamProviderRef<List<KycSubmission>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _KycSubmissionsByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<KycSubmission>>
    with KycSubmissionsByStatusRef {
  _KycSubmissionsByStatusProviderElement(super.provider);

  @override
  String? get status => (origin as KycSubmissionsByStatusProvider).status;
}

String _$kycSubmissionDetailHash() =>
    r'5ef6e950a6d21c0139a736b53b1e5cfc526cbcd8';

/// Get a single KYC submission by ID
///
/// Copied from [kycSubmissionDetail].
@ProviderFor(kycSubmissionDetail)
const kycSubmissionDetailProvider = KycSubmissionDetailFamily();

/// Get a single KYC submission by ID
///
/// Copied from [kycSubmissionDetail].
class KycSubmissionDetailFamily extends Family<AsyncValue<KycSubmission?>> {
  /// Get a single KYC submission by ID
  ///
  /// Copied from [kycSubmissionDetail].
  const KycSubmissionDetailFamily();

  /// Get a single KYC submission by ID
  ///
  /// Copied from [kycSubmissionDetail].
  KycSubmissionDetailProvider call(
    String submissionId,
  ) {
    return KycSubmissionDetailProvider(
      submissionId,
    );
  }

  @override
  KycSubmissionDetailProvider getProviderOverride(
    covariant KycSubmissionDetailProvider provider,
  ) {
    return call(
      provider.submissionId,
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
  String? get name => r'kycSubmissionDetailProvider';
}

/// Get a single KYC submission by ID
///
/// Copied from [kycSubmissionDetail].
class KycSubmissionDetailProvider
    extends AutoDisposeFutureProvider<KycSubmission?> {
  /// Get a single KYC submission by ID
  ///
  /// Copied from [kycSubmissionDetail].
  KycSubmissionDetailProvider(
    String submissionId,
  ) : this._internal(
          (ref) => kycSubmissionDetail(
            ref as KycSubmissionDetailRef,
            submissionId,
          ),
          from: kycSubmissionDetailProvider,
          name: r'kycSubmissionDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kycSubmissionDetailHash,
          dependencies: KycSubmissionDetailFamily._dependencies,
          allTransitiveDependencies:
              KycSubmissionDetailFamily._allTransitiveDependencies,
          submissionId: submissionId,
        );

  KycSubmissionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.submissionId,
  }) : super.internal();

  final String submissionId;

  @override
  Override overrideWith(
    FutureOr<KycSubmission?> Function(KycSubmissionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KycSubmissionDetailProvider._internal(
        (ref) => create(ref as KycSubmissionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        submissionId: submissionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<KycSubmission?> createElement() {
    return _KycSubmissionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KycSubmissionDetailProvider &&
        other.submissionId == submissionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, submissionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin KycSubmissionDetailRef on AutoDisposeFutureProviderRef<KycSubmission?> {
  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _KycSubmissionDetailProviderElement
    extends AutoDisposeFutureProviderElement<KycSubmission?>
    with KycSubmissionDetailRef {
  _KycSubmissionDetailProviderElement(super.provider);

  @override
  String get submissionId =>
      (origin as KycSubmissionDetailProvider).submissionId;
}

String _$kycPendingCountHash() => r'821023080aaaacacdc89e797609986397c3f221e';

/// Count of pending KYC submissions for dashboard badge
///
/// Copied from [kycPendingCount].
@ProviderFor(kycPendingCount)
final kycPendingCountProvider = AutoDisposeStreamProvider<int>.internal(
  kycPendingCount,
  name: r'kycPendingCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycPendingCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycPendingCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
