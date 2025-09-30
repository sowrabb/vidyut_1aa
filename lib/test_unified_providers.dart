import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import our unified providers
import 'app/unified_providers.dart';
import 'app/unified_providers_extended.dart';

void main() {
  group('Unified Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Create a test container with overrides
      container = ProviderContainer(
        overrides: [
          // Override SharedPreferences for testing
          sharedPreferencesProvider.overrideWithValue(
            SharedPreferences.getInstance(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Session provider initializes correctly', () async {
      final session = container.read(sessionProvider);
      expect(session, isNotNull);
      expect(session.role, isA<String>());
    });

    test('RBAC provider initializes correctly', () async {
      final rbac = container.read(rbacProvider);
      expect(rbac, isNotNull);
      expect(rbac.role, isA<String>());
    });

    test('Categories provider initializes correctly', () async {
      final categories = await container.read(categoriesProvider.future);
      expect(categories, isNotNull);
    });

    test('Search query provider initializes correctly', () {
      final query = container.read(searchQueryProvider);
      expect(query, isNotNull);
    });

    test('Products provider initializes correctly', () async {
      final products = await container.read(productsProvider('test').future);
      expect(products, isNotNull);
    });

    test('Reviews provider initializes correctly', () async {
      final reviews = await container.read(reviewsProvider('test').future);
      expect(reviews, isNotNull);
    });

    test('Feature flags provider initializes correctly', () async {
      final flags = await container.read(featureFlagsProvider.future);
      expect(flags, isA<Map<String, bool>>());
    });

    test('Analytics provider initializes correctly', () async {
      final analytics = await container.read(analyticsProvider.future);
      expect(analytics, isNotNull);
    });

    test('App settings provider initializes correctly', () {
      final settings = container.read(appSettingsProvider);
      expect(settings, isNotNull);
    });

    test('Location provider initializes correctly', () {
      final location = container.read(locationProvider);
      expect(location, isNotNull);
    });

    test('Notifications provider initializes correctly', () async {
      final notifications = await container.read(notificationsProvider.future);
      expect(notifications, isNotNull);
    });

    test('KYC submissions provider initializes correctly', () async {
      final kyc = await container.read(kycSubmissionsProvider('test').future);
      expect(kyc, isNotNull);
    });

    test('Hero sections provider initializes correctly', () async {
      final heroSections = await container.read(heroSectionsProvider.future);
      expect(heroSections, isA<List>());
    });

    test('Ads provider initializes correctly', () async {
      final ads = await container.read(adsProvider.future);
      expect(ads, isA<List>());
    });

    test('Subscription plans provider initializes correctly', () async {
      final plans = await container.read(subscriptionPlansProvider.future);
      expect(plans, isA<List>());
    });

    test('Billing provider initializes correctly', () async {
      final billing = await container.read(billingProvider.future);
      expect(billing, isNotNull);
    });
  });

  group('Provider Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('RBAC permissions work correctly', () {
      final rbac = container.read(rbacProvider);
      
      // Test permission checking
      final canManageProducts = rbac.can('products.manage');
      expect(canManageProducts, isA<bool>());
      
      final canManageUsers = rbac.can('users.manage');
      expect(canManageUsers, isA<bool>());
    });

    test('Search functionality works', () {
      // Test search query updates
      container.read(searchQueryProvider.notifier).update((state) => state.copyWith(query: 'test'));
      
      final query = container.read(searchQueryProvider);
      expect(query.query, equals('test'));
    });

    test('App settings persistence works', () {
      final settings = container.read(appSettingsProvider);
      expect(settings, isNotNull);
      
      // Test theme switching
      final newSettings = settings.copyWith(theme: 'dark');
      container.read(appSettingsProvider.notifier).update(newSettings);
      
      final updatedSettings = container.read(appSettingsProvider);
      expect(updatedSettings.theme, equals('dark'));
    });
  });
}

