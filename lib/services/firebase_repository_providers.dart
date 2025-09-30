// Firebase Repository Providers with StreamProvider/FutureProvider patterns
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_repository_service.dart';
import 'cloud_functions_service.dart';
import 'notification_service.dart';
import '../features/sell/models.dart';
import '../features/profile/models/user_models.dart';
import '../features/admin/models/admin_user.dart';
import '../features/reviews/models.dart';
import '../features/messaging/models.dart';
import '../features/stateinfo/models/state_info_models.dart';

// =============================================================================
// SERVICE PROVIDERS
// =============================================================================

/// Firestore Repository Service Provider
final firestoreRepositoryProvider = Provider<FirestoreRepositoryService>((ref) {
  return FirestoreRepositoryService();
});

/// Cloud Functions Service Provider
final cloudFunctionsProvider = Provider<CloudFunctionsService>((ref) {
  return CloudFunctionsService();
});

// =============================================================================
// USER PROVIDERS
// =============================================================================

/// Firebase User profile provider (single user)
final firebaseUserProfileProvider =
    StreamProvider.family<UserProfile?, String>((ref, userId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamUser(userId);
});

/// Firebase Current user profile provider
final firebaseCurrentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  final userId = repository.currentUserId;
  if (userId == null) return Stream.value(null);
  return repository.streamUser(userId);
});

/// Firebase All users provider (admin only)
final firebaseAllUsersProvider = StreamProvider<List<AdminUser>>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamAllUsers();
});

// =============================================================================
// PRODUCT PROVIDERS
// =============================================================================

/// Firebase Products provider with filters
final firebaseProductsProvider =
    StreamProvider.family<List<Product>, Map<String, dynamic>>((ref, filters) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamProducts(
    category: filters['category'] as String?,
    sellerId: filters['sellerId'] as String?,
    status: filters['status'] as ProductStatus?,
    limit: filters['limit'] as int? ?? 20,
  );
});

/// Firebase Single product provider
final firebaseProductProvider =
    StreamProvider.family<Product?, String>((ref, productId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamProduct(productId);
});

/// Firebase Product detail provider (with additional data)
final firebaseProductDetailProvider =
    FutureProvider.family<Product?, String>((ref, productId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.getProduct(productId);
});

/// Featured products provider
final featuredProductsProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamProducts(
    status: ProductStatus.active,
    limit: 10,
  );
});

/// User's products provider
final userProductsProvider =
    StreamProvider.family<List<Product>, String>((ref, sellerId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamProducts(
    sellerId: sellerId,
    status: ProductStatus.active,
    limit: 50,
  );
});

// =============================================================================
// REVIEW PROVIDERS
// =============================================================================

/// Firebase Product reviews provider
final firebaseProductReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, productId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamProductReviews(productId);
});

/// Firebase Reviews summary provider
final firebaseReviewsSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  final reviews = await repository.getProductReviews(productId);

  if (reviews.isEmpty) {
    return {
      'averageRating': 0.0,
      'totalReviews': 0,
      'ratingDistribution': <int, int>{},
    };
  }

  final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
  final averageRating = totalRating / reviews.length;

  final ratingDistribution = <int, int>{};
  for (int i = 1; i <= 5; i++) {
    ratingDistribution[i] = reviews.where((r) => r.rating == i).length;
  }

  return {
    'averageRating': averageRating,
    'totalReviews': reviews.length,
    'ratingDistribution': ratingDistribution,
  };
});

// =============================================================================
// LEAD PROVIDERS
// =============================================================================

/// Firebase User leads provider
final firebaseUserLeadsProvider =
    StreamProvider.family<List<Lead>, String>((ref, userId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamUserLeads(userId);
});

/// Firebase Lead detail provider
final firebaseLeadDetailProvider =
    FutureProvider.family<Lead?, String>((ref, leadId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  // Note: This would need a getLead method in the repository
  // For now, we'll get it from the user leads
  final leads = await repository.getUserLeads(repository.currentUserId ?? '');
  return leads.where((l) => l.id == leadId).firstOrNull;
});

// =============================================================================
// MESSAGING PROVIDERS
// =============================================================================

/// Firebase User conversations provider
final firebaseUserConversationsProvider =
    StreamProvider.family<List<Conversation>, String>((ref, userId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamUserConversations(userId);
});

/// Firebase Conversation messages provider
final firebaseConversationMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamConversationMessages(conversationId);
});

/// Firebase Unread messages count provider
final firebaseUnreadMessagesCountProvider = Provider<int>((ref) {
  final conversations = ref.watch(firebaseUserConversationsProvider(
      ref.watch(firestoreRepositoryProvider).currentUserId ?? ''));
  return conversations.when(
    data: (conversations) => conversations.fold(
        0, (sum, conv) => sum + conv.messages.where((m) => !m.isRead).length),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// =============================================================================
// STATE INFO PROVIDERS
// =============================================================================

/// Firebase Power generators provider
final firebasePowerGeneratorsProvider =
    StreamProvider<List<PowerGenerator>>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.streamPowerGenerators();
});

/// Firebase State info posts provider
final firebaseStateInfoPostsProvider =
    StreamProvider.family<List<Post>, String>((ref, generatorId) {
  // This would need to be implemented in the repository
  // For now, return empty list
  return Stream.value([]);
});

// =============================================================================
// ANALYTICS PROVIDERS
// =============================================================================

/// Firebase Dashboard analytics provider
final firebaseDashboardAnalyticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) {
  final functions = ref.watch(cloudFunctionsProvider);
  return functions.getDashboardStats();
});

/// Firebase Product analytics provider
final firebaseProductAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) {
  final functions = ref.watch(cloudFunctionsProvider);
  return functions.getProductAnalytics(productId);
});

/// Firebase User analytics provider
final firebaseUserAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final functions = ref.watch(cloudFunctionsProvider);
  return functions.getUserAnalytics(userId);
});

// =============================================================================
// SEARCH PROVIDERS
// =============================================================================

/// Firebase Search results provider
final firebaseSearchResultsProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, searchParams) {
  final functions = ref.watch(cloudFunctionsProvider);
  return functions.searchProducts(
    query: searchParams['query'] as String?,
    category: searchParams['category'] as String?,
    minPrice: searchParams['minPrice'] as double?,
    maxPrice: searchParams['maxPrice'] as double?,
    location: searchParams['location'] as String?,
    materials: searchParams['materials'] as List<String>?,
    limit: searchParams['limit'] as int? ?? 20,
    offset: searchParams['offset'] as int? ?? 0,
  );
});

// =============================================================================
// NOTIFICATION PROVIDERS
// =============================================================================

/// Notification state provider (already defined in notification_service.dart)
// final notificationServiceProvider = StateNotifierProvider<NotificationService, NotificationState>((ref) {
//   return NotificationService();
// });

/// Firebase Unread notification count provider
final firebaseUnreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationServiceProvider);
  return notificationState.unreadCount;
});

// =============================================================================
// PERMISSION PROVIDERS
// =============================================================================

/// Firebase User permissions provider
final firebaseUserPermissionsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  final permissions = <String>[];

  if (await repository.hasPermission(userId, 'admin')) {
    permissions.addAll(['admin', 'seller', 'user']);
  } else if (await repository.hasPermission(userId, 'seller')) {
    permissions.addAll(['seller', 'user']);
  } else {
    permissions.add('user');
  }

  return permissions;
});

/// Firebase Can manage products provider
final firebaseCanManageProductsProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.hasPermission(userId, 'seller');
});

/// Firebase Can access admin provider
final firebaseCanAccessAdminProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.hasPermission(userId, 'admin');
});

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

/// Firebase Is authenticated provider
final firebaseIsAuthenticatedProvider = Provider<bool>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.isAuthenticated;
});

/// Firebase Current user ID provider
final firebaseCurrentUserIdProvider = Provider<String?>((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.currentUserId;
});

/// Firebase App health provider
final firebaseAppHealthProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final functions = ref.watch(cloudFunctionsProvider);
  return functions.getSystemHealth();
});
