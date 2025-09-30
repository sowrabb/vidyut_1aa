import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/test_harness.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/search/search_page.dart';
import 'package:vidyut/features/search/search_store.dart';

void main() {
  group('SearchPage Riverpod Tests', () {
    testWidgets('SearchPage renders without ProviderScope errors',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(SearchPage()),
      );

      await tester.pumpAndSettle();

      // Check if the SearchPage renders without crashing
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('SearchPage renders with initial query', (tester) async {
      await tester.pumpWidget(
        createTestWidget(SearchPage(initialQuery: 'test query')),
      );

      await tester.pumpAndSettle();

      // Check if the SearchPage renders with initial query
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('SearchPage renders with initial mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(SearchPage(initialMode: SearchMode.profiles)),
      );

      await tester.pumpAndSettle();

      // Check if the SearchPage renders with initial mode
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('SearchStore provider works correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final searchStore = ref.watch(searchStoreProvider);
              return Scaffold(
                body: Text('Search Mode: ${searchStore.mode}'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the search store is working (should default to products mode)
      expect(find.text('Search Mode: SearchMode.products'), findsOneWidget);
    });

    testWidgets('SearchPage displays search bar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(SearchPage()),
      );

      await tester.pumpAndSettle();

      // Look for common search UI elements
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('SearchPage handles navigation arguments', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MaterialApp(
            home: SearchPage(),
            routes: {
              '/search': (context) => SearchPage(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the SearchPage renders correctly
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('SearchPage filters and sorting work', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final searchStore = ref.watch(searchStoreProvider);

              // Test filter functionality
              searchStore.selectedCategories.add('Electronics');
              searchStore.selectedMaterials.add('Copper');
              searchStore.minPrice = 100;
              searchStore.maxPrice = 1000;
              searchStore.sortBy = SortBy.priceAsc;

              return Scaffold(
                body: Column(
                  children: [
                    Text(
                        'Categories: ${searchStore.selectedCategories.length}'),
                    Text('Materials: ${searchStore.selectedMaterials.length}'),
                    Text(
                        'Price Range: ${searchStore.minPrice}-${searchStore.maxPrice}'),
                    Text('Sort By: ${searchStore.sortBy}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if filters are working
      expect(find.text('Categories: 1'), findsOneWidget);
      expect(find.text('Materials: 1'), findsOneWidget);
      expect(find.text('Price Range: 100.0-1000.0'), findsOneWidget);
      expect(find.text('Sort By: SortBy.priceAsc'), findsOneWidget);
    });

    testWidgets('SearchPage mode switching works', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final searchStore = ref.watch(searchStoreProvider);

              return Scaffold(
                body: Column(
                  children: [
                    Text('Current Mode: ${searchStore.mode}'),
                    ElevatedButton(
                      onPressed: () {
                        searchStore.mode =
                            searchStore.mode == SearchMode.products
                                ? SearchMode.profiles
                                : SearchMode.products;
                        searchStore.notifyListeners(); // Trigger UI update
                      },
                      child: Text('Switch Mode'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be in products mode
      expect(find.text('Current Mode: SearchMode.products'), findsOneWidget);

      // Tap the switch button
      await tester.tap(find.text('Switch Mode'));
      await tester
          .pump(); // Use pump() instead of pumpAndSettle() for immediate update

      // Should now be in profiles mode
      expect(find.text('Current Mode: SearchMode.profiles'), findsOneWidget);
    });
  });
}
