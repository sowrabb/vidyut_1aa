// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseUserPaymentOrdersHash() =>
    r'e2c5c242be8e5001452c5905b75e3fd3368d9860';

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

/// Stream all payment orders for a user (for history/audit)
///
/// Copied from [firebaseUserPaymentOrders].
@ProviderFor(firebaseUserPaymentOrders)
const firebaseUserPaymentOrdersProvider = FirebaseUserPaymentOrdersFamily();

/// Stream all payment orders for a user (for history/audit)
///
/// Copied from [firebaseUserPaymentOrders].
class FirebaseUserPaymentOrdersFamily
    extends Family<AsyncValue<List<PaymentOrder>>> {
  /// Stream all payment orders for a user (for history/audit)
  ///
  /// Copied from [firebaseUserPaymentOrders].
  const FirebaseUserPaymentOrdersFamily();

  /// Stream all payment orders for a user (for history/audit)
  ///
  /// Copied from [firebaseUserPaymentOrders].
  FirebaseUserPaymentOrdersProvider call(
    String userId,
  ) {
    return FirebaseUserPaymentOrdersProvider(
      userId,
    );
  }

  @override
  FirebaseUserPaymentOrdersProvider getProviderOverride(
    covariant FirebaseUserPaymentOrdersProvider provider,
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
  String? get name => r'firebaseUserPaymentOrdersProvider';
}

/// Stream all payment orders for a user (for history/audit)
///
/// Copied from [firebaseUserPaymentOrders].
class FirebaseUserPaymentOrdersProvider
    extends AutoDisposeStreamProvider<List<PaymentOrder>> {
  /// Stream all payment orders for a user (for history/audit)
  ///
  /// Copied from [firebaseUserPaymentOrders].
  FirebaseUserPaymentOrdersProvider(
    String userId,
  ) : this._internal(
          (ref) => firebaseUserPaymentOrders(
            ref as FirebaseUserPaymentOrdersRef,
            userId,
          ),
          from: firebaseUserPaymentOrdersProvider,
          name: r'firebaseUserPaymentOrdersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseUserPaymentOrdersHash,
          dependencies: FirebaseUserPaymentOrdersFamily._dependencies,
          allTransitiveDependencies:
              FirebaseUserPaymentOrdersFamily._allTransitiveDependencies,
          userId: userId,
        );

  FirebaseUserPaymentOrdersProvider._internal(
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
    Stream<List<PaymentOrder>> Function(FirebaseUserPaymentOrdersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseUserPaymentOrdersProvider._internal(
        (ref) => create(ref as FirebaseUserPaymentOrdersRef),
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
  AutoDisposeStreamProviderElement<List<PaymentOrder>> createElement() {
    return _FirebaseUserPaymentOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseUserPaymentOrdersProvider && other.userId == userId;
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
mixin FirebaseUserPaymentOrdersRef
    on AutoDisposeStreamProviderRef<List<PaymentOrder>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FirebaseUserPaymentOrdersProviderElement
    extends AutoDisposeStreamProviderElement<List<PaymentOrder>>
    with FirebaseUserPaymentOrdersRef {
  _FirebaseUserPaymentOrdersProviderElement(super.provider);

  @override
  String get userId => (origin as FirebaseUserPaymentOrdersProvider).userId;
}

String _$firebaseCurrentUserPaymentOrdersHash() =>
    r'a0d2ae55c001911e3f9f5965d430ef3e1560e35a';

/// Stream current user's payment orders
///
/// Copied from [firebaseCurrentUserPaymentOrders].
@ProviderFor(firebaseCurrentUserPaymentOrders)
final firebaseCurrentUserPaymentOrdersProvider =
    AutoDisposeStreamProvider<List<PaymentOrder>>.internal(
  firebaseCurrentUserPaymentOrders,
  name: r'firebaseCurrentUserPaymentOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseCurrentUserPaymentOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseCurrentUserPaymentOrdersRef
    = AutoDisposeStreamProviderRef<List<PaymentOrder>>;
String _$firebasePaymentOrderHash() =>
    r'713af8e2c613f15aea096baf416a79b61b358645';

/// Stream a specific payment order (for real-time status tracking)
///
/// Copied from [firebasePaymentOrder].
@ProviderFor(firebasePaymentOrder)
const firebasePaymentOrderProvider = FirebasePaymentOrderFamily();

/// Stream a specific payment order (for real-time status tracking)
///
/// Copied from [firebasePaymentOrder].
class FirebasePaymentOrderFamily extends Family<AsyncValue<PaymentOrder?>> {
  /// Stream a specific payment order (for real-time status tracking)
  ///
  /// Copied from [firebasePaymentOrder].
  const FirebasePaymentOrderFamily();

  /// Stream a specific payment order (for real-time status tracking)
  ///
  /// Copied from [firebasePaymentOrder].
  FirebasePaymentOrderProvider call(
    String orderId,
  ) {
    return FirebasePaymentOrderProvider(
      orderId,
    );
  }

  @override
  FirebasePaymentOrderProvider getProviderOverride(
    covariant FirebasePaymentOrderProvider provider,
  ) {
    return call(
      provider.orderId,
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
  String? get name => r'firebasePaymentOrderProvider';
}

/// Stream a specific payment order (for real-time status tracking)
///
/// Copied from [firebasePaymentOrder].
class FirebasePaymentOrderProvider
    extends AutoDisposeStreamProvider<PaymentOrder?> {
  /// Stream a specific payment order (for real-time status tracking)
  ///
  /// Copied from [firebasePaymentOrder].
  FirebasePaymentOrderProvider(
    String orderId,
  ) : this._internal(
          (ref) => firebasePaymentOrder(
            ref as FirebasePaymentOrderRef,
            orderId,
          ),
          from: firebasePaymentOrderProvider,
          name: r'firebasePaymentOrderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebasePaymentOrderHash,
          dependencies: FirebasePaymentOrderFamily._dependencies,
          allTransitiveDependencies:
              FirebasePaymentOrderFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  FirebasePaymentOrderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    Stream<PaymentOrder?> Function(FirebasePaymentOrderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebasePaymentOrderProvider._internal(
        (ref) => create(ref as FirebasePaymentOrderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<PaymentOrder?> createElement() {
    return _FirebasePaymentOrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebasePaymentOrderProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebasePaymentOrderRef on AutoDisposeStreamProviderRef<PaymentOrder?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _FirebasePaymentOrderProviderElement
    extends AutoDisposeStreamProviderElement<PaymentOrder?>
    with FirebasePaymentOrderRef {
  _FirebasePaymentOrderProviderElement(super.provider);

  @override
  String get orderId => (origin as FirebasePaymentOrderProvider).orderId;
}

String _$firebaseSuccessfulPaymentsHash() =>
    r'2570648f220dea677a32f0b92d65ce890c3ebdd8';

/// Stream all successful payment orders (for admin analytics)
///
/// Copied from [firebaseSuccessfulPayments].
@ProviderFor(firebaseSuccessfulPayments)
final firebaseSuccessfulPaymentsProvider =
    AutoDisposeStreamProvider<List<PaymentOrder>>.internal(
  firebaseSuccessfulPayments,
  name: r'firebaseSuccessfulPaymentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSuccessfulPaymentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSuccessfulPaymentsRef
    = AutoDisposeStreamProviderRef<List<PaymentOrder>>;
String _$firebaseFailedPaymentsHash() =>
    r'82b4943f4dbb4c2739be37f30c9a7412577488ec';

/// Stream failed payment orders (for admin monitoring)
///
/// Copied from [firebaseFailedPayments].
@ProviderFor(firebaseFailedPayments)
final firebaseFailedPaymentsProvider =
    AutoDisposeStreamProvider<List<PaymentOrder>>.internal(
  firebaseFailedPayments,
  name: r'firebaseFailedPaymentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFailedPaymentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFailedPaymentsRef
    = AutoDisposeStreamProviderRef<List<PaymentOrder>>;
String _$firebasePaymentStatsHash() =>
    r'9e520c0857c9ad7f634ff6696f6c1eaca028e38e';

/// Stream payment statistics (for admin dashboard)
///
/// Copied from [firebasePaymentStats].
@ProviderFor(firebasePaymentStats)
final firebasePaymentStatsProvider =
    AutoDisposeStreamProvider<Map<String, dynamic>>.internal(
  firebasePaymentStats,
  name: r'firebasePaymentStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebasePaymentStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebasePaymentStatsRef
    = AutoDisposeStreamProviderRef<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
