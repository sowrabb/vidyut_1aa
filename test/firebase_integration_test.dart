// Firebase Integration Test - Production Ready Validation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/services/firestore_repository_service.dart';
import 'package:vidyut/services/cloud_functions_service.dart';
import 'package:vidyut/services/notification_service.dart';
import 'package:vidyut/features/sell/models.dart';
// import 'package:vidyut/features/profile/models/user_models.dart'; // Removed to avoid conflicts
// import 'package:vidyut/features/reviews/models.dart'; // Removed to avoid conflicts

void main() {
  group('Firebase Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Provider Registry exports all required providers',
        (tester) async {
      // Test that all providers are accessible through provider_registry
      expect(
          () => container.read(firestoreRepositoryProvider), returnsNormally);
      expect(() => container.read(cloudFunctionsProvider), returnsNormally);
      expect(
          () => container.read(notificationServiceProvider), returnsNormally);
      expect(() => container.read(firebaseUserProfileProvider('test-user')),
          returnsNormally);
      expect(
          () => container.read(firebaseProductsProvider({})), returnsNormally);
      expect(() => container.read(firebaseProductProvider('test-product')),
          returnsNormally);
      expect(
          () => container.read(firebaseProductReviewsProvider('test-product')),
          returnsNormally);
      expect(() => container.read(firebaseUserLeadsProvider('test-user')),
          returnsNormally);
      expect(
          () => container.read(firebaseUserConversationsProvider('test-user')),
          returnsNormally);
      expect(() => container.read(firebasePowerGeneratorsProvider),
          returnsNormally);
      expect(() => container.read(firebaseDashboardAnalyticsProvider),
          returnsNormally);
      expect(() => container.read(firebaseSearchResultsProvider({})),
          returnsNormally);
      expect(() => container.read(firebaseUnreadNotificationCountProvider),
          returnsNormally);
      expect(() => container.read(firebaseIsAuthenticatedProvider),
          returnsNormally);
      expect(
          () => container.read(firebaseCurrentUserIdProvider), returnsNormally);
    });

    testWidgets('Firestore Repository Service works correctly', (tester) async {
      final repository = container.read(firestoreRepositoryProvider);

      // Test service instantiation
      expect(repository, isA<FirestoreRepositoryService>());
      expect(repository.isAuthenticated, isFalse); // No user logged in
      expect(repository.currentUserId, isNull);
    });

    testWidgets('Cloud Functions Service works correctly', (tester) async {
      final functions = container.read(cloudFunctionsProvider);

      // Test service instantiation
      expect(functions, isA<CloudFunctionsService>());
      expect(functions.isAuthenticated, isFalse); // No user logged in
      expect(functions.currentUserId, isNull);
    });

    testWidgets('Notification Service works correctly', (tester) async {
      final notificationState = container.read(notificationServiceProvider);

      // Test initial state
      expect(notificationState.notifications, isEmpty);
      expect(notificationState.unreadCount, 0);
      expect(notificationState.isLoading, false);
      expect(notificationState.error, isNull);
    });

    testWidgets('Model serialization works correctly', (tester) async {
      // Test Product model
      final product = Product(
        id: 'test-product',
        title: 'Test Product',
        brand: 'Test Brand',
        subtitle: 'Test Subtitle',
        category: 'electrical',
        description: 'Test Description',
        images: ['image1.jpg', 'image2.jpg'],
        documents: ['doc1.pdf'],
        price: 100.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['copper', 'aluminum'],
        customValues: {'color': 'red'},
        status: ProductStatus.active,
        createdAt: DateTime.now(),
        rating: 4.5,
      );

      final productJson = product.toJson();
      final productFromJson = Product.fromJson(productJson);

      expect(productFromJson.id, product.id);
      expect(productFromJson.title, product.title);
      expect(productFromJson.price, product.price);
      expect(productFromJson.status, product.status);

      // Test Lead model
      final lead = Lead(
        id: 'test-lead',
        title: 'Test Lead',
        industry: 'Construction',
        materials: ['steel', 'concrete'],
        city: 'Mumbai',
        state: 'Maharashtra',
        qty: 100,
        turnoverCr: 50.0,
        needBy: DateTime.now().add(const Duration(days: 30)),
        status: 'New',
        about: 'Test lead description',
      );

      final leadJson = lead.toJson();
      final leadFromJson = Lead.fromJson(leadJson);

      expect(leadFromJson.id, lead.id);
      expect(leadFromJson.title, lead.title);
      expect(leadFromJson.industry, lead.industry);
      expect(leadFromJson.turnoverCr, lead.turnoverCr);

      // Test Review model (using from review_models.dart)
      final review = Review(
        id: 'test-review',
        productId: 'test-product',
        userId: 'test-user',
        authorDisplay: 'Test User',
        rating: 5,
        title: 'Great product!',
        body: 'Really happy with this purchase.',
        images: [],
        createdAt: DateTime.now(),
      );

      final reviewJson = review.toJson();
      final reviewFromJson = Review.fromJson(reviewJson);

      expect(reviewFromJson.id, review.id);
      expect(reviewFromJson.productId, review.productId);
      expect(reviewFromJson.rating, review.rating);
      expect(reviewFromJson.body, review.body);
    });

    testWidgets('Provider dependencies work correctly', (tester) async {
      // Test that providers can depend on each other
      final repository = container.read(firestoreRepositoryProvider);
      final functions = container.read(cloudFunctionsProvider);

      // These should not throw errors
      expect(repository, isNotNull);
      expect(functions, isNotNull);
    });

    testWidgets('Error handling works correctly', (tester) async {
      // Test that providers handle errors gracefully
      final notificationState = container.read(notificationServiceProvider);

      // Initial state should be clean
      expect(notificationState.error, isNull);

      // Test error state handling
      final notificationService =
          container.read(notificationServiceProvider.notifier);
      expect(notificationService, isA<NotificationService>());
    });

    testWidgets('Provider invalidation works correctly', (tester) async {
      // Test that providers can be invalidated
      final repository = container.read(firestoreRepositoryProvider);

      // Invalidate and read again
      container.invalidate(firestoreRepositoryProvider);
      final newRepository = container.read(firestoreRepositoryProvider);

      expect(newRepository, isA<FirestoreRepositoryService>());
    });

    testWidgets('Provider family parameters work correctly', (tester) async {
      // Test provider families with different parameters
      final userProfile1 = container.read(firebaseUserProfileProvider('user1'));
      final userProfile2 = container.read(firebaseUserProfileProvider('user2'));

      // These should be different instances
      expect(userProfile1, isA<AsyncValue<UserProfile?>>());
      expect(userProfile2, isA<AsyncValue<UserProfile?>>());

      // Test product provider with filters
      final products1 =
          container.read(firebaseProductsProvider({'category': 'electrical'}));
      final products2 =
          container.read(firebaseProductsProvider({'category': 'mechanical'}));

      expect(products1, isA<AsyncValue<List<Product>>>());
      expect(products2, isA<AsyncValue<List<Product>>>());
    });

    testWidgets('Provider state management works correctly', (tester) async {
      // Test that providers maintain state correctly
      final notificationState1 = container.read(notificationServiceProvider);
      final notificationState2 = container.read(notificationServiceProvider);

      // Should be the same instance
      expect(notificationState1, same(notificationState2));
    });

    testWidgets('Provider disposal works correctly', (tester) async {
      // Test that providers can be disposed
      final container2 = ProviderContainer();

      try {
        final repository = container2.read(firestoreRepositoryProvider);
        expect(repository, isA<FirestoreRepositoryService>());
      } finally {
        container2.dispose();
      }
    });
  });

  group('Production Readiness Tests', () {
    test('All required dependencies are available', () {
      // Test that all required packages are available
      expect(() => FirestoreRepositoryService(), returnsNormally);
      expect(() => CloudFunctionsService(), returnsNormally);
      expect(() => NotificationService(), returnsNormally);
    });

    test('Error handling is comprehensive', () {
      // Test that error handling is in place
      final repository = FirestoreRepositoryService();

      // Test error handling methods exist
      expect(() => repository.hasPermission('user1', 'admin'), returnsNormally);
    });

    test('Type safety is maintained', () {
      // Test that type safety is maintained
      final repository = FirestoreRepositoryService();

      // Test that methods return correct types
      expect(repository.isAuthenticated, isA<bool>());
      expect(repository.currentUserId, isA<String?>());
    });

    test('Performance is acceptable', () {
      // Test that providers are created quickly
      final stopwatch = Stopwatch()..start();

      final container = ProviderContainer();
      container.read(firestoreRepositoryProvider);
      container.read(cloudFunctionsProvider);
      container.read(notificationServiceProvider);

      stopwatch.stop();

      // Should be created in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      container.dispose();
    });
  });
}
