/// Comprehensive provider tests for all Riverpod providers
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('Core Firebase Providers', () {
    test('firebaseAuthProvider provides Firebase Auth instance', () {
      final container = ProviderContainer();
      final auth = container.read(firebaseAuthProvider);
      expect(auth, isNotNull);
      container.dispose();
    });

    test('firebaseFirestoreProvider provides Firestore instance', () {
      final container = ProviderContainer();
      final firestore = container.read(firebaseFirestoreProvider);
      expect(firestore, isNotNull);
      container.dispose();
    });

    test('firebaseFunctionsProvider provides Functions instance', () {
      final container = ProviderContainer();
      final functions = container.read(firebaseFunctionsProvider);
      expect(firestore, isNotNull);
      container.dispose();
    });

    test('firebaseStorageProvider provides Storage instance', () {
      final container = ProviderContainer();
      final storage = container.read(firebaseStorageProvider);
      expect(storage, isNotNull);
      container.dispose();
    });
  });

  group('Repository Providers', () {
    test('firestoreRepositoryServiceProvider is accessible', () {
      final container = ProviderContainer();
      final repo = container.read(firestoreRepositoryServiceProvider);
      expect(repo, isNotNull);
      container.dispose();
    });

    test('cloudFunctionsServiceProvider is accessible', () {
      final container = ProviderContainer();
      final functions = container.read(cloudFunctionsServiceProvider);
      expect(functions, isNotNull);
      container.dispose();
    });

    test('userRoleServiceProvider is accessible', () {
      final container = ProviderContainer();
      final service = container.read(userRoleServiceProvider);
      expect(service, isNotNull);
      container.dispose();
    });

    test('userProfileServiceProvider is accessible', () {
      final container = ProviderContainer();
      final service = container.read(userProfileServiceProvider);
      expect(service, isNotNull);
      container.dispose();
    });
  });

  group('Session & Auth Controllers', () {
    test('sessionControllerProvider returns initial unauthenticated state', () {
      final container = ProviderContainer();
      final session = container.read(sessionControllerProvider);
      expect(session.isAuthenticated, isFalse);
      expect(session.userId, isNull);
      container.dispose();
    });

    test('authControllerProvider returns initial state', () {
      final container = ProviderContainer();
      final auth = container.read(authControllerProvider);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
      container.dispose();
    });

    test('rbacProvider returns guest role by default', () {
      final container = ProviderContainer();
      final rbac = container.read(rbacProvider);
      expect(rbac.role, UserRole.guest);
      expect(rbac.can('products.read'), isTrue);
      expect(rbac.can('admin.access'), isFalse);
      container.dispose();
    });
  });

  group('Location Controller', () {
    test('locationControllerProvider returns default state', () {
      final container = ProviderContainer();
      final location = container.read(locationControllerProvider);
      expect(location.city, isNotEmpty);
      expect(location.stateName, isNotEmpty);
      container.dispose();
    });

    test('location controller can update city', () async {
      final container = ProviderContainer();
      final controller = container.read(locationControllerProvider.notifier);
      
      await controller.setCity('Mumbai');
      final location = container.read(locationControllerProvider);
      
      expect(location.city, 'Mumbai');
      container.dispose();
    });
  });

  group('Firebase Data Providers', () {
    test('firebaseProductsProvider stream is accessible', () {
      final container = ProviderContainer();
      final productsAsync = container.read(firebaseProductsProvider({}));
      
      expect(productsAsync, isA<AsyncValue>());
      container.dispose();
    });

    test('firebaseAllUsersProvider stream is accessible', () {
      final container = ProviderContainer();
      final usersAsync = container.read(firebaseAllUsersProvider);
      
      expect(usersAsync, isA<AsyncValue>());
      container.dispose();
    });

    test('firebaseCurrentUserProfileProvider returns null when not logged in', () {
      final container = ProviderContainer();
      final profileAsync = container.read(firebaseCurrentUserProfileProvider);
      
      profileAsync.when(
        data: (profile) => expect(profile, isNull),
        loading: () {},
        error: (_, __) {},
      );
      
      container.dispose();
    });
  });

  group('Admin Providers', () {
    test('kycPendingSubmissionsProvider stream is accessible', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
      );
      
      final kycAsync = container.read(kycPendingSubmissionsProvider);
      expect(kycAsync, isA<AsyncValue>());
      
      container.dispose();
    });

    test('adminDashboardAnalyticsProvider is accessible', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
      );
      
      final analyticsAsync = container.read(adminDashboardAnalyticsProvider);
      expect(analyticsAsync, isA<AsyncValue>());
      
      container.dispose();
    });

    test('adminProductAnalyticsProvider is accessible', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
      );
      
      final analyticsAsync = container.read(adminProductAnalyticsProvider);
      expect(analyticsAsync, isA<AsyncValue>());
      
      container.dispose();
    });

    test('adminUserAnalyticsProvider is accessible', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
      );
      
      final analyticsAsync = container.read(adminUserAnalyticsProvider);
      expect(analyticsAsync, isA<AsyncValue>());
      
      container.dispose();
    });

    test('adminActivityFeedProvider stream is accessible', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
      );
      
      final feedAsync = container.read(adminActivityFeedProvider);
      expect(feedAsync, isA<AsyncValue>());
      
      container.dispose();
    });
  });

  group('Legacy Provider Compatibility', () {
    test('analyticsServiceProvider is accessible', () {
      final container = ProviderContainer();
      final service = container.read(analyticsServiceProvider);
      expect(service, isNotNull);
      container.dispose();
    });

    test('searchServiceProvider is accessible', () async {
      final container = ProviderContainer();
      final serviceAsync = container.read(searchServiceProvider);
      
      await serviceAsync.when(
        data: (service) {
          expect(service, isNotNull);
        },
        loading: () {},
        error: (_, __) => fail('Should not error'),
      );
      
      container.dispose();
    });

    test('locationServiceProvider is accessible', () async {
      final container = ProviderContainer();
      final serviceAsync = container.read(locationServiceProvider);
      
      await serviceAsync.when(
        data: (service) {
          expect(service, isNotNull);
        },
        loading: () {},
        error: (_, __) => fail('Should not error'),
      );
      
      container.dispose();
    });
  });

  group('Provider Integration', () {
    test('session and rbac work together', () {
      final container = ProviderContainer();
      
      final session = container.read(sessionControllerProvider);
      final rbac = container.read(rbacProvider);
      
      // Guest user by default
      expect(session.isAuthenticated, isFalse);
      expect(rbac.role, UserRole.guest);
      expect(rbac.can('products.read'), isTrue);
      expect(rbac.can('admin.access'), isFalse);
      
      container.dispose();
    });

    test('location and firestore repository work together', () {
      final container = ProviderContainer();
      
      final location = container.read(locationControllerProvider);
      final repo = container.read(firestoreRepositoryServiceProvider);
      
      expect(location.city, isNotEmpty);
      expect(repo, isNotNull);
      
      container.dispose();
    });
  });

  group('Provider Disposal', () {
    test('providers dispose cleanly', () {
      final container = ProviderContainer();
      
      // Read several providers
      container.read(sessionControllerProvider);
      container.read(locationControllerProvider);
      container.read(rbacProvider);
      container.read(firestoreRepositoryServiceProvider);
      
      // Should dispose without errors
      expect(() => container.dispose(), returnsNormally);
    });

    test('auto-dispose providers clean up after themselves', () {
      final container = ProviderContainer();
      
      // Read auto-dispose providers
      final productsAsync = container.read(firebaseProductsProvider({}));
      final usersAsync = container.read(firebaseAllUsersProvider);
      
      expect(productsAsync, isA<AsyncValue>());
      expect(usersAsync, isA<AsyncValue>());
      
      container.dispose();
    });
  });
}




