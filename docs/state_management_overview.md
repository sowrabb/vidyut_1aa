# State Management Architecture (October 2024 Refresh)

This document describes the production-ready state layer introduced to replace the temporary demo wiring. The goal is to provide deterministic session handling, role-aware UI, and Firebase-backed data flows that can be composed from widgets and services consistently.

## Core building blocks

- **AuthController (`lib/state/auth/auth_controller.dart`)**
  - Connects to `FirebaseAuth` and exposes an `AuthState` via `authControllerProvider`.
  - Handles email/password signup & sign-in, guest sign-in, OTP flows, and email verification helpers.
  - Ensures a Firestore `users` document exists for every authenticated user.

- **SessionController (`lib/state/session/session_controller.dart`)**
  - Consumes `AuthState`, hydrates seller/admin metadata via `UserRoleService`, and exposes a rich `SessionState` with helpers (`isSeller`, `canBecomeSeller`, etc.).
  - Emits RBAC context through the lightweight `rbacProvider` that maps roles to permissions.

- **LocationController (`lib/state/location/location_controller.dart`)**
  - Centralises persisted location preferences (city/state/radius/geo) and stores them in `SharedPreferences`.
  - `locationControllerProvider` replaces the legacy `AppStateNotifier` and is used by search, seller previews, analytics logging, and profile settings.

- **Repository providers (`lib/state/core/repository_providers.dart`)**
  - Injects Firebase instances (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseFunctions`, `FirebaseStorage`) and wraps higher-level services such as `FirestoreRepositoryService`, `CloudFunctionsService`, `NotificationService`, `UserProfileService`, and `UserRoleService`.
  - These are intentionally overridable in tests to enable mocked backends.

- **Firebase data sources (`lib/services/firebase_repository_providers.dart`)**
  - Remain the single source of truth for Firestore streams/futures (products, reviews, leads, messaging, state info, analytics). They can be consumed alongside the new controllers for UI composition.

## Migration guidelines

1. Import `app/provider_registry.dart` and replace usages of the removed providers:
   - `firebaseAuthServiceProvider` → `authControllerProvider`
   - `sessionProvider` → `sessionControllerProvider`
   - `appStateNotifierProvider` → `locationControllerProvider`
2. When you need role/permission checks use `rbacProvider`. The matrix live in `lib/state/session/rbac.dart` and can be extended per product needs.
3. To mutate location, call `ref.read(locationControllerProvider.notifier).setLocation(...)` instead of instantiating `AppState` directly.
4. Existing `SearchStore` / seller widgets still depend on the old `AppState` class; when migrating them, prefer reading from `LocationState` and only bridge to `AppState` where unavoidable.
5. For auth mutations or sign-out, use the notifier from `authControllerProvider`.

## Outstanding follow-ups

- Replace the legacy `SearchStore` with a Riverpod-powered controller that works directly with `LocationState` and Firestore queries.
- Migrate seller/admin stores away from `LightweightDemoDataService` once the corresponding backend collections are populated.
- Add integration tests to cover the `AuthController` and `SessionController` flows once CI permissions to run `flutter test` are restored.
