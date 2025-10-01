/// Unified provider registry for application state.
///
/// Importing this file gives access to the production-ready Riverpod providers
/// that power authentication, session/role management, location preferences and
/// all Firebase-backed data flows.

// Core dependencies & repositories
export '../state/core/firebase_providers.dart';
export '../state/core/repository_providers.dart';

// Auth & session
export '../state/auth/auth_controller.dart';
export '../state/auth/auth_state.dart';
export '../state/session/session_controller.dart';
export '../state/session/session_state.dart';
export '../state/session/rbac.dart';

// Location & app-level context
export '../state/location/location_controller.dart';
export '../state/location/location_state.dart';

// Firebase data providers (products, reviews, leads, messaging, etc.)
// Only re-export UI-facing firebase* providers to avoid ambiguity with
// core repository services defined in state/core/repository_providers.dart.
export '../services/firebase_repository_providers.dart' show
    firebaseUserProfileProvider,
    firebaseCurrentUserProfileProvider,
    firebaseAllUsersProvider,
    firebaseProductsProvider,
    firebaseProductProvider,
    firebaseProductDetailProvider,
    firebaseProductReviewsProvider,
    firebaseReviewsSummaryProvider,
    firebaseUserLeadsProvider,
    firebaseLeadDetailProvider,
    firebaseUserConversationsProvider,
    firebaseConversationMessagesProvider,
    firebaseUnreadMessagesCountProvider,
    firebasePowerGeneratorsProvider,
    firebaseStateInfoPostsProvider,
    firebaseDashboardAnalyticsProvider,
    firebaseProductAnalyticsProvider,
    firebaseUserAnalyticsProvider,
    firebaseSearchResultsProvider,
    firebaseUnreadNotificationCountProvider,
    firebaseUserPermissionsProvider,
    firebaseCanManageProductsProvider,
    firebaseCanAccessAdminProvider,
    firebaseIsAuthenticatedProvider,
    firebaseCurrentUserIdProvider,
    firebaseAppHealthProvider;

// Legacy providers kept for test compatibility (will be removed once tests migrate)
export '../app/unified_providers.dart' show firebaseAuthServiceProvider, rbacServiceProvider;
export '../app/unified_providers_extended.dart' show
    demoDataServiceProvider,
    messagingStoreProvider,
    categoriesStoreProvider,
    adminStoreProvider,
    enhancedAdminStoreProvider,
    adminAuthServiceProvider,
    sellerStoreProvider,
    stateInfoStoreProvider,
    stateInfoEditStoreProvider,
    lightweightStateInfoStoreProvider,
    // Keep analytics and location services for widgets that use them
    analyticsServiceProvider,
    locationServiceProvider,
    locationAwareFilterServiceProvider;

// Admin providers
export '../state/admin/kyc_providers.dart';
export '../state/admin/analytics_providers.dart';

// Messaging providers
export '../state/messaging/firebase_messaging_providers.dart';

// Product providers
export '../state/products/firebase_products_providers.dart';

// Seller providers
export '../state/seller/firebase_seller_providers.dart';

// Reviews providers
export '../state/reviews/firebase_reviews_providers.dart';

// Leads providers
export '../state/leads/firebase_leads_providers.dart';

// Hero sections providers
export '../state/hero_sections/firebase_hero_sections_providers.dart';

// Subscriptions providers
export '../state/subscriptions/firebase_subscriptions_providers.dart';

// Audit logs providers
export '../state/audit_logs/firebase_audit_logs_providers.dart';

// Feature flags providers
export '../state/feature_flags/firebase_feature_flags_providers.dart';

// State info providers
export '../state/state_info/firebase_state_info_providers.dart';

// Search history providers
export '../state/search_history/firebase_search_history_providers.dart';

// Product designs providers
export '../state/product_designs/firebase_product_designs_providers.dart';

// Payment providers
export '../state/payments/razorpay_providers.dart';
export '../state/payments/firebase_payment_providers.dart';
export '../services/razorpay_service.dart';

// Advertisements providers
export '../state/advertisements/firebase_advertisements_providers.dart';

// System operations providers
export '../state/system_operations/firebase_system_operations_providers.dart';

// Domain models used across features
export '../features/auth/models/user_role_models.dart';
export '../features/reviews/models.dart';
export '../features/admin/models/kyc_models.dart';
export '../features/admin/models/analytics_models.dart';

// Legacy providers that still need migration
export '../app/unified_providers_extended.dart' show
    reviewsRepositoryProvider,
    searchServiceProvider;
