/// Admin analytics providers
///
/// Provides aggregated analytics data for admin dashboard.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/admin/models/analytics_models.dart';
import '../core/firebase_providers.dart';

part 'analytics_providers.g.dart';

/// Dashboard analytics snapshot
@riverpod
Future<AnalyticsSnapshot> adminDashboardAnalytics(AdminDashboardAnalyticsRef ref) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  final usersSnap = await firestore.collection('users').count().get();
  final productsSnap = await firestore.collection('products').count().get();
  final ordersSnap = await firestore.collection('orders').count().get();
  final sellersSnap = await firestore.collection('users').where('role', isEqualTo: 'seller').count().get();

  final usersCount = usersSnap.count ?? 0;
  final productsCount = productsSnap.count ?? 0;
  final ordersCount = ordersSnap.count ?? 0;
  final sellersCount = sellersSnap.count ?? 0;

  return AnalyticsSnapshot(
    totalUsers: usersCount,
    activeSellers: sellersCount,
    totalProducts: productsCount,
    totalOrders: ordersCount,
    metrics: {
      'total_users': usersCount,
      'active_sellers': sellersCount,
      'total_products': productsCount,
      'total_orders': ordersCount,
    },
    events: [],
    lastUpdated: DateTime.now(),
  );
}

/// Product analytics
@riverpod
Future<ProductAnalytics> adminProductAnalytics(AdminProductAnalyticsRef ref) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  final totalSnap = await firestore.collection('products').count().get();
  final activeSnap = await firestore.collection('products').where('status', isEqualTo: 'active').count().get();

  return ProductAnalytics(
    totalProducts: totalSnap.count ?? 0,
    activeProducts: activeSnap.count ?? 0,
    topProducts: [],
    productViews: {},
  );
}

/// User analytics
@riverpod
Future<UserAnalytics> adminUserAnalytics(AdminUserAnalyticsRef ref) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  final totalSnap = await firestore.collection('users').count().get();
  final activeSnap = await firestore.collection('users').where('status', isEqualTo: 'active').count().get();

  return UserAnalytics(
    totalUsers: totalSnap.count ?? 0,
    activeUsers: activeSnap.count ?? 0,
    userGrowth: {},
    activeUserSessions: {},
  );
}

/// Activity feed stream
@riverpod
Stream<List<ActivityEvent>> adminActivityFeed(AdminActivityFeedRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('activity_logs')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ActivityEvent.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
}

/// Moderation queue stream
@riverpod
Stream<List<Map<String, dynamic>>> adminModerationQueue(AdminModerationQueueRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('products')
      .where('status', isEqualTo: 'pending_approval')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList());
}