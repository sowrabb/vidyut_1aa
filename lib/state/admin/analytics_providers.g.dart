// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDashboardAnalyticsHash() =>
    r'af6ad90f7bfe3274ccc4a43da7eb772d71bd9045';

/// Dashboard analytics snapshot
///
/// Copied from [adminDashboardAnalytics].
@ProviderFor(adminDashboardAnalytics)
final adminDashboardAnalyticsProvider =
    AutoDisposeFutureProvider<AnalyticsSnapshot>.internal(
  adminDashboardAnalytics,
  name: r'adminDashboardAnalyticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminDashboardAnalyticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminDashboardAnalyticsRef
    = AutoDisposeFutureProviderRef<AnalyticsSnapshot>;
String _$adminProductAnalyticsHash() =>
    r'adca9ee4ddb5c9ffdcf0aab4eaaca56764ad9818';

/// Product analytics
///
/// Copied from [adminProductAnalytics].
@ProviderFor(adminProductAnalytics)
final adminProductAnalyticsProvider =
    AutoDisposeFutureProvider<ProductAnalytics>.internal(
  adminProductAnalytics,
  name: r'adminProductAnalyticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminProductAnalyticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminProductAnalyticsRef
    = AutoDisposeFutureProviderRef<ProductAnalytics>;
String _$adminUserAnalyticsHash() =>
    r'468a15ca29fcac8757d939da348c8c9ef5c9b072';

/// User analytics
///
/// Copied from [adminUserAnalytics].
@ProviderFor(adminUserAnalytics)
final adminUserAnalyticsProvider =
    AutoDisposeFutureProvider<UserAnalytics>.internal(
  adminUserAnalytics,
  name: r'adminUserAnalyticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminUserAnalyticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUserAnalyticsRef = AutoDisposeFutureProviderRef<UserAnalytics>;
String _$adminActivityFeedHash() => r'd526570c1fe89089aeeef3fc46d0d2b1a5e956c3';

/// Activity feed stream
///
/// Copied from [adminActivityFeed].
@ProviderFor(adminActivityFeed)
final adminActivityFeedProvider =
    AutoDisposeStreamProvider<List<ActivityEvent>>.internal(
  adminActivityFeed,
  name: r'adminActivityFeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminActivityFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminActivityFeedRef
    = AutoDisposeStreamProviderRef<List<ActivityEvent>>;
String _$adminModerationQueueHash() =>
    r'9a588b3f36f3d8c7cfdc4f61f71508fb3584701e';

/// Moderation queue stream
///
/// Copied from [adminModerationQueue].
@ProviderFor(adminModerationQueue)
final adminModerationQueueProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
  adminModerationQueue,
  name: r'adminModerationQueueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminModerationQueueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminModerationQueueRef
    = AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
