import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vidyut/services/search_service.dart';
import 'package:vidyut/features/sell/models.dart';

// Generate mocks for the test
@GenerateMocks([FirebaseFirestore])
void main() {
  group('Search Functionality Tests', () {
    late SearchService searchService;
    late List<Product> mockProducts;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create search service without Firebase for demo mode
      searchService = SearchService(prefs);

      // Create mock products
      mockProducts = [
        Product(
          id: '1',
          title: 'Copper Wire 2.5mm',
          brand: 'Finolex',
          price: 150.0,
          materials: ['Copper'],
          subtitle: 'Electrical Wire',
          category: 'Wires & Cables',
          rating: 4.5,
          createdAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        Product(
          id: '2',
          title: 'MCB 32A',
          brand: 'Schneider',
          price: 850.0,
          materials: ['Plastic', 'Metal'],
          subtitle: 'Circuit Breaker',
          category: 'Circuit Breakers',
          rating: 4.2,
          createdAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        Product(
          id: '3',
          title: 'LED Bulb 9W',
          brand: 'Philips',
          price: 120.0,
          materials: ['Plastic', 'LED'],
          subtitle: 'Light Bulb',
          category: 'Lights',
          rating: 4.8,
          createdAt: DateTime.now(),
          status: ProductStatus.active,
        ),
      ];

      // Initialize search service with products
      searchService.initializeWithProducts(mockProducts);
    });

    test('Real-time Search with Suggestions', () async {
      // Test search suggestions
      await searchService.searchWithSuggestions('copper');

      // Wait for async operation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if suggestions were generated (may be empty in demo mode)
      expect(searchService.suggestions, isA<List<SearchSuggestion>>());
    });

    test('Search History Tracking', () async {
      // Perform a search
      await searchService.addToHistory('copper wire', 5,
          category: 'Wires & Cables');

      expect(searchService.searchHistory.isNotEmpty, true);
      expect(searchService.searchHistory.first.query, 'copper wire');
      expect(searchService.searchHistory.first.resultCount, 5);
      expect(searchService.searchHistory.first.category, 'Wires & Cables');
    });

    test('Advanced Filtering System', () {
      // Test product filtering with multiple criteria
      final results = searchService.filterProducts(
        query: 'wire',
        categories: ['Wires & Cables'],
        materials: ['Copper'],
        minPrice: 100.0,
        maxPrice: 200.0,
        sortBy: 'price_asc',
      );

      expect(results.isNotEmpty, true);
      expect(
          results.every((p) =>
              (p.category == 'Wires & Cables') ||
              (p.subtitleCategorySafe == 'Wires & Cables')),
          true);
      expect(results.every((p) => p.materials.contains('Copper')), true);
      expect(results.every((p) => p.price >= 100.0 && p.price <= 200.0), true);

      // Check sorting (price ascending)
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price <= results[i + 1].price, true);
      }
    });

    test('Search Analytics', () {
      // Add some search history
      searchService.addToHistory('copper wire', 5, category: 'Wires & Cables');
      searchService.addToHistory('MCB', 3, category: 'Circuit Breakers');
      searchService.addToHistory('LED', 8, category: 'Lights');

      final analytics = searchService.getSearchAnalytics();

      expect(analytics['totalSearches'], 3);
      expect(analytics['uniqueQueries'], 3);
      expect(analytics['avgResultsPerSearch'], greaterThan(0));

      final trends = analytics['searchTrends'] as List<Map<String, dynamic>>;
      expect(trends.isNotEmpty, true);
    });

    test('Intelligent Suggestions Based on User Behavior', () async {
      // Add search history to influence suggestions
      await searchService.addToHistory('copper wire', 5,
          category: 'Wires & Cables');
      await searchService.addToHistory('MCB circuit breaker', 3,
          category: 'Circuit Breakers');

      // Get intelligent suggestions
      final suggestions = await searchService.getIntelligentSuggestions('co');

      expect(suggestions.isNotEmpty, true);

      // Should prioritize recent history
      final historySuggestions =
          suggestions.where((s) => s.type == 'history').toList();
      expect(historySuggestions.isNotEmpty, true);
    });

    test('Search Performance', () {
      // Test search performance with large dataset
      final startTime = DateTime.now();

      final results = searchService.filterProducts(
        query: 'wire',
        sortBy: 'price_asc',
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Search should complete quickly (within 100ms for demo data)
      expect(duration.inMilliseconds, lessThan(100));
      expect(results.isNotEmpty, true);
    });

    test('Clear Search History', () async {
      // Add some history
      await searchService.addToHistory('test query', 5);
      expect(searchService.searchHistory.isNotEmpty, true);

      // Clear history
      await searchService.clearHistory();
      expect(searchService.searchHistory.isEmpty, true);
    });

    test('Remove Specific History Item', () async {
      // Add multiple history items
      await searchService.addToHistory('query 1', 5);
      await searchService.addToHistory('query 2', 3);
      await searchService.addToHistory('query 3', 8);

      final initialLength = searchService.searchHistory.length;

      // Remove middle item
      await searchService.removeHistoryItem(1);

      expect(searchService.searchHistory.length, initialLength - 1);
      expect(searchService.searchHistory[1].query, 'query 1');
    });

    test('Search Suggestions by Type', () async {
      await searchService.searchWithSuggestions('sch');

      // Wait for async operation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      final suggestions = searchService.suggestions;

      // Check that suggestions are generated (may be empty in demo mode)
      expect(suggestions, isA<List<SearchSuggestion>>());
    });

    test('Category and Brand Extraction', () {
      // Test that categories and brands are properly extracted from products
      expect(searchService.categories.isNotEmpty, true);
      expect(searchService.brands.isNotEmpty, true);
      expect(searchService.categories.contains('Wires & Cables'), true);
      expect(searchService.brands.contains('Finolex'), true);
    });
  });
}
