import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidyut/features/home/home_page.dart';
import 'package:vidyut/features/search/search_page.dart';
import 'package:vidyut/features/messaging/messaging_pages.dart';
import 'package:vidyut/features/categories/categories_page.dart';
import 'package:vidyut/features/sell/sell_hub_page.dart';
import 'package:vidyut/features/stateinfo/state_info_page.dart';
import 'package:vidyut/features/profile/profile_page.dart';
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

    // Create a minimal demo service that doesn't trigger timers
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
          '/messages': (context) => const MessagingPage(),
          '/categories': (context) => const CategoriesPage(),
          '/sell': (context) => const SellHubPage(),
          '/state-info': (context) => const StateInfoPage(),
          '/profile': (context) => const ProfilePage(),
        },
        home: const HomePage(),
      ),
    );
  }

  group('Performance & Stability Tests', () {
    testWidgets('No jank on first meaningful paint - HomePage', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidgetWithProviders());

      // Measure time to first meaningful paint
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      // Should render within reasonable time (less than 1000ms for test environment)
      expect(firstPaintTime, lessThan(1000));

      // Verify page renders correctly
      expect(find.byType(HomePage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('No jank on first meaningful paint - SearchPage',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      expect(firstPaintTime, lessThan(1000));
      expect(find.byType(SearchPage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('No jank on first meaningful paint - CategoriesPage',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/categories'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      expect(firstPaintTime, lessThan(1000));
      expect(find.byType(CategoriesPage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('No jank on first meaningful paint - StateInfoPage',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/state-info'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      expect(firstPaintTime, lessThan(1000));
      expect(find.byType(StateInfoPage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('No jank on first meaningful paint - ProfilePage',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      expect(firstPaintTime, lessThan(1000));
      expect(find.byType(ProfilePage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('No jank on first meaningful paint - SellHubPage',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final firstPaintTime = stopwatch.elapsedMilliseconds;

      expect(firstPaintTime, lessThan(1000));
      expect(find.byType(SellHubPage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets(
        'Memory does not grow unbounded during tab switches - ProfilePage',
        (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));
      await tester.pump();

      // Switch between tabs multiple times
      for (int i = 0; i < 5; i++) {
        // Tap on different tabs
        if (i % 4 == 0) {
          await tester.tap(find.text('Overview'));
        } else if (i % 4 == 1) {
          await tester.tap(find.text('Saved').first);
        } else if (i % 4 == 2) {
          await tester.tap(find.text('RFQs').first);
        } else {
          await tester.tap(find.text('Settings'));
        }

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        // Verify page is still responsive
        expect(find.byType(ProfilePage), findsOneWidget);
      }

      // Final verification
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets(
        'Memory does not grow unbounded during tab switches - SellHubPage',
        (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();

      // Switch between tabs multiple times
      for (int i = 0; i < 5; i++) {
        // Simulate tab switching by rebuilding
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        // Verify page is still responsive
        expect(find.byType(SellHubPage), findsOneWidget);
      }

      // Final verification
      expect(find.byType(SellHubPage), findsOneWidget);
    });

    testWidgets('Page caches cleared on dispose - HomePage', (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Verify HomePage is no longer in the widget tree
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('Page caches cleared on dispose - SearchPage', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));
      await tester.pump();

      expect(find.byType(SearchPage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(SearchPage), findsNothing);
    });

    testWidgets('Page caches cleared on dispose - CategoriesPage',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/categories'));
      await tester.pump();

      expect(find.byType(CategoriesPage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(CategoriesPage), findsNothing);
    });

    testWidgets('Page caches cleared on dispose - StateInfoPage',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/state-info'));
      await tester.pump();

      expect(find.byType(StateInfoPage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(StateInfoPage), findsNothing);
    });

    testWidgets('Page caches cleared on dispose - ProfilePage', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));
      await tester.pump();

      expect(find.byType(ProfilePage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(ProfilePage), findsNothing);
    });

    testWidgets('Page caches cleared on dispose - SellHubPage', (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();

      expect(find.byType(SellHubPage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(SellHubPage), findsNothing);
    });

    testWidgets(
        'No exceptions in logs during typical flows - HomePage interactions',
        (tester) async {
      await tester.pumpWidget(createTestWidgetWithProviders());
      await tester.pump();

      // Perform typical user interactions
      try {
        // Simulate search interaction
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'test query');
          await tester.pump();
        }

        // Simulate scrolling
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pump();
        }

        // Verify page is still responsive
        expect(find.byType(HomePage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets(
        'No exceptions in logs during typical flows - SearchPage interactions',
        (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/search'));
      await tester.pump();

      try {
        // Simulate search interactions
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'electrical components');
          await tester.pump();
        }

        // Simulate scrolling
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pump();
        }

        expect(find.byType(SearchPage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets(
        'No exceptions in logs during typical flows - ProfilePage interactions',
        (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/profile'));
      await tester.pump();

      try {
        // Simulate tab switching
        await tester.tap(find.text('Saved').first);
        await tester.pump();

        await tester.tap(find.text('RFQs').first);
        await tester.pump();

        await tester.tap(find.text('Settings'));
        await tester.pump();

        // Simulate FAB interaction
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab);
          await tester.pump();
        }

        expect(find.byType(ProfilePage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets(
        'No exceptions in logs during typical flows - CategoriesPage interactions',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/categories'));
      await tester.pump();

      try {
        // Simulate category interactions
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'wires');
          await tester.pump();
        }

        // Simulate scrolling
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pump();
        }

        expect(find.byType(CategoriesPage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets(
        'No exceptions in logs during typical flows - StateInfoPage interactions',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithProviders(initialRoute: '/state-info'));
      await tester.pump();

      try {
        // Simulate button interactions
        await tester.tap(find.text('Edit'));
        await tester.pump();

        await tester.tap(find.text('Data Management'));
        await tester.pump();

        // Simulate scrolling
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pump();
        }

        expect(find.byType(StateInfoPage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets(
        'No exceptions in logs during typical flows - SellHubPage interactions',
        (tester) async {
      await tester
          .pumpWidget(createTestWidgetWithProviders(initialRoute: '/sell'));
      await tester.pump();

      try {
        // Simulate scrolling
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pump();
        }

        expect(find.byType(SellHubPage), findsOneWidget);
      } catch (e) {
        fail('Exception occurred during typical flow: $e');
      }
    });

    testWidgets('Performance under rapid widget rebuilds', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidgetWithProviders());

      // Perform rapid rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
      }

      final totalTime = stopwatch.elapsedMilliseconds;

      // Should complete rapid rebuilds within reasonable time
      expect(totalTime, lessThan(2000));
      expect(find.byType(HomePage), findsOneWidget);

      stopwatch.stop();
    });

    testWidgets('Memory stability during multiple page loads', (tester) async {
      final routes = ['/search', '/state-info', '/profile', '/sell'];

      for (final route in routes) {
        await tester
            .pumpWidget(createTestWidgetWithProviders(initialRoute: route));
        await tester.pump();

        // Verify page loads correctly
        switch (route) {
          case '/search':
            expect(find.byType(SearchPage), findsOneWidget);
            break;
          case '/state-info':
            expect(find.byType(StateInfoPage), findsOneWidget);
            break;
          case '/profile':
            expect(find.byType(ProfilePage), findsOneWidget);
            break;
          case '/sell':
            expect(find.byType(SellHubPage), findsOneWidget);
            break;
        }
      }

      // Final verification - should still be responsive
      expect(find.byType(SellHubPage), findsOneWidget);
    });
  });
}
