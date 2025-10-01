// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'razorpay_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$razorpayServiceHash() => r'a3be1be33ad47cf7dbaba5be6d0ad9318ba5b8b9';

/// Razorpay service provider
///
/// Copied from [razorpayService].
@ProviderFor(razorpayService)
final razorpayServiceProvider = AutoDisposeProvider<RazorpayService>.internal(
  razorpayService,
  name: r'razorpayServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$razorpayServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RazorpayServiceRef = AutoDisposeProviderRef<RazorpayService>;
String _$subscriptionPlanPricingHash() =>
    r'352d06de822a6f8332cd7723bc928f5cd0d53094';

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

/// Get subscription plan pricing (admin-configurable)
///
/// Copied from [subscriptionPlanPricing].
@ProviderFor(subscriptionPlanPricing)
const subscriptionPlanPricingProvider = SubscriptionPlanPricingFamily();

/// Get subscription plan pricing (admin-configurable)
///
/// Copied from [subscriptionPlanPricing].
class SubscriptionPlanPricingFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Get subscription plan pricing (admin-configurable)
  ///
  /// Copied from [subscriptionPlanPricing].
  const SubscriptionPlanPricingFamily();

  /// Get subscription plan pricing (admin-configurable)
  ///
  /// Copied from [subscriptionPlanPricing].
  SubscriptionPlanPricingProvider call(
    SubscriptionPlan plan,
  ) {
    return SubscriptionPlanPricingProvider(
      plan,
    );
  }

  @override
  SubscriptionPlanPricingProvider getProviderOverride(
    covariant SubscriptionPlanPricingProvider provider,
  ) {
    return call(
      provider.plan,
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
  String? get name => r'subscriptionPlanPricingProvider';
}

/// Get subscription plan pricing (admin-configurable)
///
/// Copied from [subscriptionPlanPricing].
class SubscriptionPlanPricingProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Get subscription plan pricing (admin-configurable)
  ///
  /// Copied from [subscriptionPlanPricing].
  SubscriptionPlanPricingProvider(
    SubscriptionPlan plan,
  ) : this._internal(
          (ref) => subscriptionPlanPricing(
            ref as SubscriptionPlanPricingRef,
            plan,
          ),
          from: subscriptionPlanPricingProvider,
          name: r'subscriptionPlanPricingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subscriptionPlanPricingHash,
          dependencies: SubscriptionPlanPricingFamily._dependencies,
          allTransitiveDependencies:
              SubscriptionPlanPricingFamily._allTransitiveDependencies,
          plan: plan,
        );

  SubscriptionPlanPricingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.plan,
  }) : super.internal();

  final SubscriptionPlan plan;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(SubscriptionPlanPricingRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubscriptionPlanPricingProvider._internal(
        (ref) => create(ref as SubscriptionPlanPricingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        plan: plan,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _SubscriptionPlanPricingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionPlanPricingProvider && other.plan == plan;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, plan.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubscriptionPlanPricingRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `plan` of this provider.
  SubscriptionPlan get plan;
}

class _SubscriptionPlanPricingProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with SubscriptionPlanPricingRef {
  _SubscriptionPlanPricingProviderElement(super.provider);

  @override
  SubscriptionPlan get plan => (origin as SubscriptionPlanPricingProvider).plan;
}

String _$allSubscriptionPlansHash() =>
    r'8aa61e666b31e848492cf34b344bf0ba734dacce';

/// Get all subscription plans with pricing
///
/// Copied from [allSubscriptionPlans].
@ProviderFor(allSubscriptionPlans)
final allSubscriptionPlansProvider = AutoDisposeFutureProvider<
    Map<SubscriptionPlan, Map<String, dynamic>>>.internal(
  allSubscriptionPlans,
  name: r'allSubscriptionPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allSubscriptionPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllSubscriptionPlansRef
    = AutoDisposeFutureProviderRef<Map<SubscriptionPlan, Map<String, dynamic>>>;
String _$userActiveSubscriptionHash() =>
    r'83c99c165226034c3dae71afaaa161e5507f920b';

/// Get user's active subscription
///
/// Copied from [userActiveSubscription].
@ProviderFor(userActiveSubscription)
const userActiveSubscriptionProvider = UserActiveSubscriptionFamily();

/// Get user's active subscription
///
/// Copied from [userActiveSubscription].
class UserActiveSubscriptionFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// Get user's active subscription
  ///
  /// Copied from [userActiveSubscription].
  const UserActiveSubscriptionFamily();

  /// Get user's active subscription
  ///
  /// Copied from [userActiveSubscription].
  UserActiveSubscriptionProvider call(
    String userId,
  ) {
    return UserActiveSubscriptionProvider(
      userId,
    );
  }

  @override
  UserActiveSubscriptionProvider getProviderOverride(
    covariant UserActiveSubscriptionProvider provider,
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
  String? get name => r'userActiveSubscriptionProvider';
}

/// Get user's active subscription
///
/// Copied from [userActiveSubscription].
class UserActiveSubscriptionProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// Get user's active subscription
  ///
  /// Copied from [userActiveSubscription].
  UserActiveSubscriptionProvider(
    String userId,
  ) : this._internal(
          (ref) => userActiveSubscription(
            ref as UserActiveSubscriptionRef,
            userId,
          ),
          from: userActiveSubscriptionProvider,
          name: r'userActiveSubscriptionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userActiveSubscriptionHash,
          dependencies: UserActiveSubscriptionFamily._dependencies,
          allTransitiveDependencies:
              UserActiveSubscriptionFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserActiveSubscriptionProvider._internal(
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
    Stream<Map<String, dynamic>?> Function(UserActiveSubscriptionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserActiveSubscriptionProvider._internal(
        (ref) => create(ref as UserActiveSubscriptionRef),
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
  AutoDisposeStreamProviderElement<Map<String, dynamic>?> createElement() {
    return _UserActiveSubscriptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserActiveSubscriptionProvider && other.userId == userId;
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
mixin UserActiveSubscriptionRef
    on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserActiveSubscriptionProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with UserActiveSubscriptionRef {
  _UserActiveSubscriptionProviderElement(super.provider);

  @override
  String get userId => (origin as UserActiveSubscriptionProvider).userId;
}

String _$userPaymentOrdersHash() => r'21d16ddf45faed2c86b3728c9342e9a37e8da2be';

/// Stream payment orders for a user
///
/// Copied from [userPaymentOrders].
@ProviderFor(userPaymentOrders)
const userPaymentOrdersProvider = UserPaymentOrdersFamily();

/// Stream payment orders for a user
///
/// Copied from [userPaymentOrders].
class UserPaymentOrdersFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Stream payment orders for a user
  ///
  /// Copied from [userPaymentOrders].
  const UserPaymentOrdersFamily();

  /// Stream payment orders for a user
  ///
  /// Copied from [userPaymentOrders].
  UserPaymentOrdersProvider call(
    String userId,
  ) {
    return UserPaymentOrdersProvider(
      userId,
    );
  }

  @override
  UserPaymentOrdersProvider getProviderOverride(
    covariant UserPaymentOrdersProvider provider,
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
  String? get name => r'userPaymentOrdersProvider';
}

/// Stream payment orders for a user
///
/// Copied from [userPaymentOrders].
class UserPaymentOrdersProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// Stream payment orders for a user
  ///
  /// Copied from [userPaymentOrders].
  UserPaymentOrdersProvider(
    String userId,
  ) : this._internal(
          (ref) => userPaymentOrders(
            ref as UserPaymentOrdersRef,
            userId,
          ),
          from: userPaymentOrdersProvider,
          name: r'userPaymentOrdersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userPaymentOrdersHash,
          dependencies: UserPaymentOrdersFamily._dependencies,
          allTransitiveDependencies:
              UserPaymentOrdersFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserPaymentOrdersProvider._internal(
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
    Stream<List<Map<String, dynamic>>> Function(UserPaymentOrdersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPaymentOrdersProvider._internal(
        (ref) => create(ref as UserPaymentOrdersRef),
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
  AutoDisposeStreamProviderElement<List<Map<String, dynamic>>> createElement() {
    return _UserPaymentOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPaymentOrdersProvider && other.userId == userId;
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
mixin UserPaymentOrdersRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPaymentOrdersProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with UserPaymentOrdersRef {
  _UserPaymentOrdersProviderElement(super.provider);

  @override
  String get userId => (origin as UserPaymentOrdersProvider).userId;
}

String _$paymentStateHash() => r'24e32b61ba095c884cf7662863ad4681e471a9bd';

/// Payment state notifier for managing payment flow
///
/// Copied from [PaymentState].
@ProviderFor(PaymentState)
final paymentStateProvider =
    AutoDisposeNotifierProvider<PaymentState, Map<String, dynamic>>.internal(
  PaymentState.new,
  name: r'paymentStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$paymentStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaymentState = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
