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
export '../services/firebase_repository_providers.dart';

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
    lightweightStateInfoStoreProvider;

// Domain models used across features
export '../features/auth/models/user_role_models.dart';
