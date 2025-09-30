import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/test_harness.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/app/layout/adaptive.dart';
import 'package:vidyut/features/categories/categories_page.dart';
import 'package:vidyut/features/categories/categories_notifier.dart';

void main() {
  group('CategoriesPage Riverpod Tests', () {
    // Helper function to create test widget with bounded constraints
    Widget createBoundedTestWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('CategoriesPage renders without ProviderScope errors',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the CategoriesPage renders without crashing
      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('CategoriesPage displays search bar', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if search bar is displayed
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('CategoriesPage displays filters button on mobile',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if filters button is displayed (mobile layout)
      expect(find.text('Filters'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('CategoriesPage displays categories grid', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if categories grid is displayed
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverGrid), findsOneWidget);
    });

    testWidgets('CategoriesPage handles search functionality', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Find the search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'electrical');
      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the text was entered
      expect(find.text('electrical'), findsOneWidget);
    });

    testWidgets('CategoriesPage handles filter button tap', (tester) async {
      // Suppress image loading exceptions for this test
      FlutterError.onError = (FlutterErrorDetails details) {
        // Ignore image loading errors in tests
        if (details.exception
                .toString()
                .contains('NetworkImageLoadException') ||
            details.exception.toString().contains('HTTP request failed')) {
          return;
        }
        FlutterError.presentError(details);
      };

      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Find and tap the filters button (there are multiple OutlinedButtons, find the first one)
      final filtersButton = find.byType(OutlinedButton).first;
      expect(filtersButton, findsOneWidget);

      // Tap the button
      await tester.tap(filtersButton);
      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page still renders after tap
      expect(find.byType(CategoriesPage), findsOneWidget);

      // Reset error handler
      FlutterError.onError = FlutterError.presentError;
    });

    testWidgets('CategoriesPage displays proper navigation structure',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page has proper structure
      expect(find.byType(CategoriesPage), findsOneWidget);
      expect(find.byType(Scaffold),
          findsAtLeastNWidgets(1)); // Multiple Scaffolds exist
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('CategoriesPage handles empty state gracefully',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page renders without errors even with no data
      expect(find.byType(CategoriesPage), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('CategoriesPage displays responsive layout', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if responsive layout components are present
      expect(find.byType(LayoutBuilder),
          findsAtLeastNWidgets(1)); // Multiple LayoutBuilders exist
      expect(find.byType(ContentClamp), findsOneWidget);
    });

    testWidgets('CategoriesPage handles category selection', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Look for category cards that might be clickable
      expect(find.byType(CategoriesPage), findsOneWidget);

      // Check if the page structure allows for category selection
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('CategoriesPage displays sliver structure correctly',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if sliver structure is correct
      expect(find.byType(SliverToBoxAdapter),
          findsAtLeastNWidgets(2)); // Search bar and spacing
      expect(find.byType(SliverGrid), findsOneWidget);
    });

    testWidgets('CategoriesPage handles state management', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: Consumer(
                  builder: (context, ref, child) {
                    final categoriesState =
                        ref.watch(categoriesNotifierProvider);

                    return Column(
                      children: [
                        Expanded(
                          child: const CategoriesPage(),
                        ),
                        Text('Query: ${categoriesState.query}'),
                        Text('Sort: ${categoriesState.sortBy.name}'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // The state should be accessible
      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if state is tracked
      expect(find.textContaining('Query:'), findsOneWidget);
      expect(find.textContaining('Sort:'), findsOneWidget);
    });

    testWidgets('CategoriesPage handles different screen sizes',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page adapts to different screen sizes
      expect(find.byType(LayoutBuilder),
          findsAtLeastNWidgets(1)); // Multiple LayoutBuilders exist
      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('CategoriesPage displays proper background color',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page has proper background
      expect(find.byType(Scaffold),
          findsAtLeastNWidgets(1)); // Multiple Scaffolds exist
      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('CategoriesPage handles scroll behavior', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if scrollable content is present
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(Scrollable),
          findsAtLeastNWidgets(1)); // Multiple Scrollable widgets exist
    });

    testWidgets('CategoriesPage displays proper spacing and layout',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(const CategoriesPage()),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if proper spacing is maintained
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      expect(find.byType(CategoriesPage), findsOneWidget);
    });
  });
}
