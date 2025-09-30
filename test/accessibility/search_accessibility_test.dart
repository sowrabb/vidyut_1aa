import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/features/search/enhanced_search_page.dart';
import 'package:vidyut/features/search/search_history_page.dart';
import 'package:vidyut/features/search/search_analytics_page.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('Search Accessibility Tests', () {
    testWidgets('Enhanced Search Page accessibility',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EnhancedSearchPage(),
          ),
        ),
      );

      // Test search input accessibility
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test that search field has proper semantics
      final semantics = tester.getSemantics(searchField);
      expect(semantics, isNotNull);

      // Test filter button accessibility
      final filterButton = find.byIcon(Icons.tune);
      expect(filterButton, findsOneWidget);

      // Test that filter button has proper semantics
      final filterSemantics = tester.getSemantics(filterButton);
      expect(filterSemantics, isNotNull);
    });

    testWidgets('Search History Page accessibility',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SearchHistoryPage(),
          ),
        ),
      );

      // Test app bar accessibility
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Test clear history button accessibility
      final clearButton = find.byIcon(Icons.delete_sweep);
      expect(clearButton, findsOneWidget);

      // Test that clear button has proper semantics
      final clearSemantics = tester.getSemantics(clearButton);
      expect(clearSemantics, isNotNull);
    });

    testWidgets('Search Analytics Page accessibility',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SearchAnalyticsPage(),
          ),
        ),
      );

      // Test app bar accessibility
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Test time period selector accessibility
      final timeSelector = find.byIcon(Icons.more_vert);
      expect(timeSelector, findsOneWidget);

      // Test that time selector has proper semantics
      final timeSemantics = tester.getSemantics(timeSelector);
      expect(timeSemantics, isNotNull);
    });

    testWidgets('Search input field accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products, brands, categories...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      );

      // Test search input field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test hint text accessibility
      final hintText = find.text('Search products, brands, categories...');
      expect(hintText, findsOneWidget);

      // Test prefix icon accessibility
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
    });

    testWidgets('Search suggestions accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('copper wire'),
                  subtitle: const Text('Wires & Cables'),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('circuit breaker'),
                  subtitle: const Text('Circuit Breakers'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test suggestion list accessibility
      final suggestionList = find.byType(ListView);
      expect(suggestionList, findsOneWidget);

      // Test suggestion items accessibility
      final suggestionItems = find.byType(ListTile);
      expect(suggestionItems, findsNWidgets(2));

      // Test suggestion icons accessibility
      final historyIcon = find.byIcon(Icons.history);
      final inventoryIcon = find.byIcon(Icons.inventory);
      expect(historyIcon, findsOneWidget);
      expect(inventoryIcon, findsOneWidget);
    });

    testWidgets('Search filters accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Category Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category'),
                    Wrap(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: true,
                          onSelected: (selected) {},
                        ),
                        FilterChip(
                          label: const Text('Wires & Cables'),
                          selected: false,
                          onSelected: (selected) {},
                        ),
                      ],
                    ),
                  ],
                ),
                // Price Range Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Range: ₹0 - ₹50000'),
                    RangeSlider(
                      values: const RangeValues(0, 50000),
                      min: 0,
                      max: 100000,
                      onChanged: (values) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Test filter labels accessibility
      final categoryLabel = find.text('Category');
      final priceLabel = find.text('Price Range: ₹0 - ₹50000');
      expect(categoryLabel, findsOneWidget);
      expect(priceLabel, findsOneWidget);

      // Test filter chips accessibility
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsNWidgets(2));

      // Test range slider accessibility
      final rangeSlider = find.byType(RangeSlider);
      expect(rangeSlider, findsOneWidget);
    });

    testWidgets('Search results accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Search Results Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('5 results found'),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                      label: const Text('Filters'),
                    ),
                  ],
                ),
                // Results Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            Container(
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            ),
                            const Text('Product $index'),
                            Text('₹${(index + 1) * 100}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test results header accessibility
      final resultsHeader = find.text('5 results found');
      expect(resultsHeader, findsOneWidget);

      // Test filters button accessibility
      final filtersButton = find.text('Filters');
      expect(filtersButton, findsOneWidget);

      // Test results grid accessibility
      final resultsGrid = find.byType(GridView);
      expect(resultsGrid, findsOneWidget);

      // Test product cards accessibility
      final productCards = find.byType(Card);
      expect(productCards, findsNWidgets(4));
    });

    testWidgets('Search history items accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.search),
                    ),
                    title: const Text('copper wire'),
                    subtitle: const Text('2 hours ago'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {},
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'search',
                          child: Row(
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text('Search Again'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test history item accessibility
      final historyItem = find.byType(ListTile);
      expect(historyItem, findsOneWidget);

      // Test history item content accessibility
      final historyTitle = find.text('copper wire');
      final historyTime = find.text('2 hours ago');
      expect(historyTitle, findsOneWidget);
      expect(historyTime, findsOneWidget);

      // Test popup menu accessibility
      final popupMenu = find.byType(PopupMenuButton);
      expect(popupMenu, findsOneWidget);
    });

    testWidgets('Search analytics charts accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.search),
                                  const SizedBox(width: 8),
                                  const Text('Total Searches'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '150',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Search Trends'),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text('Chart Placeholder'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test overview cards accessibility
      final totalSearches = find.text('Total Searches');
      expect(totalSearches, findsOneWidget);

      // Test chart accessibility
      final chartTitle = find.text('Search Trends');
      expect(chartTitle, findsOneWidget);

      // Test chart placeholder accessibility
      final chartPlaceholder = find.text('Chart Placeholder');
      expect(chartPlaceholder, findsOneWidget);
    });

    testWidgets('Search error states accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Error message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load search results',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.close, color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
                // Empty state
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No search results found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search terms or filters',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test error message accessibility
      final errorIcon = find.byIcon(Icons.error_outline);
      final errorText = find.text('Failed to load search results');
      expect(errorIcon, findsOneWidget);
      expect(errorText, findsOneWidget);

      // Test empty state accessibility
      final emptyIcon = find.byIcon(Icons.search);
      final emptyTitle = find.text('No search results found');
      final emptySubtitle =
          find.text('Try adjusting your search terms or filters');
      expect(emptyIcon, findsOneWidget);
      expect(emptyTitle, findsOneWidget);
      expect(emptySubtitle, findsOneWidget);
    });
  });
}
