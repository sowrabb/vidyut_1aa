// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_subscriptions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseSubscriptionPlansHash() =>
    r'cc06055afecb6d6407b187e2b86e9a777175afaa';

/// Stream all active subscription plans
///
/// Copied from [firebaseSubscriptionPlans].
@ProviderFor(firebaseSubscriptionPlans)
final firebaseSubscriptionPlansProvider =
    AutoDisposeStreamProvider<List<SubscriptionPlanData>>.internal(
  firebaseSubscriptionPlans,
  name: r'firebaseSubscriptionPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseSubscriptionPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseSubscriptionPlansRef
    = AutoDisposeStreamProviderRef<List<SubscriptionPlanData>>;
String _$firebaseUserSubscriptionHash() =>
    r'49c19ded673e9489f2dc3678e592137da672c3b4';

/// Get current user's subscription
///
/// Copied from [firebaseUserSubscription].
@ProviderFor(firebaseUserSubscription)
final firebaseUserSubscriptionProvider =
    AutoDisposeStreamProvider<UserSubscriptionData?>.internal(
  firebaseUserSubscription,
  name: r'firebaseUserSubscriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseUserSubscriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseUserSubscriptionRef
    = AutoDisposeStreamProviderRef<UserSubscriptionData?>;
String _$subscriptionServiceHash() =>
    r'e3c33134b515ad121d861a2f81af06d0dbdc7739';

/// Service for subscription operations
///
/// Copied from [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider =
    AutoDisposeProvider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionServiceRef = AutoDisposeProviderRef<SubscriptionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
