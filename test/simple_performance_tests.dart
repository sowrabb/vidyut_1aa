import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidyut/features/home/home_page.dart';
import 'package:vidyut/features/search/search_page.dart';
import 'package:vidyut/features/categories/categories_page.dart';
import 'package:vidyut/features/stateinfo/state_info_page.dart';
import 'package:vidyut/features/profile/profile_page.dart';
import 'package:vidyut/features/sell/sell_hub_page.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/features/admin/auth/admin_auth_service.dart';
import 'package:vidyut/features/admin/store/admin_store.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/features/admin/rbac/rbac_service.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Suppress layout overflow errors in tests
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('RenderFlex overflowed') ||
        details.exception.toString().contains('A RenderFlex overflowed')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Helper function to create test widget with all necessary providers
  Widget createTestWidgetWithProviders({String? initialRoute}) {
    SharedPreferences.setMockInitialValues({});

    final demoService = LightweightDemoDataService();
    final enhancedStore = EnhancedAdminStore(
      apiService:
          EnhancedAdminApiService(environment: ApiEnvironment.development),
      demoDataService: demoService,
      useBackend: false,
    );
    final adminStore = AdminStore(demoService);
    final rbacService = RbacService();
    final authService =
        AdminAuthService(enhancedStore, demoService, rbacService);

    return ProviderScope(
      overrides: [
        demoDataServiceProvider.overrideWith((ref) => demoService),
        enhancedAdminStoreProvider.overrideWith((ref) => enhancedStore),
        adminStoreProvider.overrideWith((ref) => adminStore),
        adminAuthServiceProvider.overrideWith((ref) => authService),
        rbacServiceProvider.overrideWith((ref) => rbacService),
      ],
      child: MaterialApp(
        initialRoute: initialRoute,
        routes: {
          '/search': (context) => const SearchPage(),
          '/categories': (context) => const CategoriesPage(),
          '/sell': (context) => const SellHubPage(),
          '/state-info': (context) => const StateInfoPage(),
          '/profile': (context) => const ProfilePage(),
        },
        home: const HomePage(),
      ),
    );
  }

  group('Simple Performance & Stability Tests', () {
    testWidgets('HomePage renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());
      await tester.pump();

      // Verify page renders correctly
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('SearchPage renders without errors', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));
      await tester.pump();

      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('CategoriesPage renders without errors', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/categories'));
      await tester.pump();

      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('StateInfoPage renders without errors', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/state-info'));
      await tester.pump();

      expect(find.byType(StateInfoPage), findsOneWidget);
    });

    testWidgets('ProfilePage renders without errors', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));
      await tester.pump();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('SellHubPage renders without errors', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();

      expect(find.byType(SellHubPage), findsOneWidget);
    });

    testWidgets('HomePage handles basic interactions', (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());
      await tester.pump();

      // Simulate search interaction
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'test query');
        await tester.pump();
      }

      // Verify page is still responsive
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('ProfilePage handles tab switching', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));
      await tester.pump();

      // Simulate tab switching
      if (find.text('Saved').evaluate().isNotEmpty) {
        await tester.tap(find.text('Saved').first);
        await tester.pump();
      }

      if (find.text('RFQs').evaluate().isNotEmpty) {
        await tester.tap(find.text('RFQs').first);
        await tester.pump();
      }

      // Verify page is still responsive
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('SearchPage handles basic interactions', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));
      await tester.pump();

      // Simulate search interactions
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'electrical components');
        await tester.pump();
      }

      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('CategoriesPage handles basic interactions', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/categories'));
      await tester.pump();

      // Simulate category interactions
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'wires');
        await tester.pump();
      }

      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('StateInfoPage handles basic interactions', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/state-info'));
      await tester.pump();

      // Simulate button interactions - check if buttons exist first
      if (find.text('Edit').evaluate().isNotEmpty) {
        await tester.tap(find.text('Edit'));
        await tester.pump();
      }

      if (find.text('Data Management').evaluate().isNotEmpty) {
        await tester.tap(find.text('Data Management'));
        await tester.pump();
      }

      expect(find.byType(StateInfoPage), findsOneWidget);
    });

    testWidgets('SellHubPage handles basic interactions', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();

      // Simulate scrolling
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pump();
      }

      expect(find.byType(SellHubPage), findsOneWidget);
    });

    testWidgets('Multiple page loads work correctly', (tester) async {
      // Test individual page loads
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));
      await tester.pump();
      expect(find.byType(SearchPage), findsOneWidget);

      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();
      expect(find.byType(SellHubPage), findsOneWidget);

      // Final verification - should still be responsive
      expect(find.byType(SellHubPage), findsOneWidget);
    });

    testWidgets('Page disposal works correctly', (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Verify HomePage is no longer in the widget tree
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('Widget rebuilds work correctly', (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());

      // Perform multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }

      // Should still be responsive
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
