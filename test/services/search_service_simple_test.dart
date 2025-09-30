import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/search_service.dart';

void main() {
  group('SearchService Simple Tests', () {
    late SearchService searchService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      searchService = SearchService(prefs);
    });

    group('Search Suggestions', () {
      test('should return empty suggestions for empty query', () async {
        await searchService.searchWithSuggestions('');
        expect(searchService.suggestions, isEmpty);
      });

      test('should handle search suggestions without errors', () async {
        await searchService.searchWithSuggestions('test query');
        expect(searchService.error, isNull);
      });
    });

    group('Search History', () {
      test('should add search to history', () async {
        await searchService.addToHistory('test query', 5, category: 'wires');

        expect(searchService.searchHistory, isNotEmpty);
        expect(searchService.searchHistory.first.query, equals('test query'));
        expect(searchService.searchHistory.first.resultCount, equals(5));
        expect(searchService.searchHistory.first.category, equals('wires'));
      });

      test('should limit history to 50 items', () async {
        for (int i = 0; i < 60; i++) {
          await searchService.addToHistory('query $i', i);
        }

        expect(searchService.searchHistory.length, equals(50));
        expect(searchService.searchHistory.first.query, equals('query 59'));
      });

      test('should clear history', () async {
        await searchService.addToHistory('test query', 5);
        expect(searchService.searchHistory, isNotEmpty);

        await searchService.clearHistory();
        expect(searchService.searchHistory, isEmpty);
      });

      test('should remove specific history item', () async {
        await searchService.addToHistory('query 1', 5);
        await searchService.addToHistory('query 2', 3);
        await searchService.addToHistory('query 3', 7);

        expect(searchService.searchHistory.length, equals(3));

        await searchService.removeHistoryItem(1);
        expect(searchService.searchHistory.length, equals(2));
        expect(searchService.searchHistory[1].query, equals('query 3'));
      });
    });

    group('Search Analytics', () {
      test('should track search analytics without errors', () async {
        await searchService.trackSearch('test query', 10,
            userId: 'user123', category: 'wires');
        expect(searchService.error, isNull);
      });

      test('should track search result clicks without errors', () async {
        await searchService.trackClick('test query', userId: 'user123');
        expect(searchService.error, isNull);
      });

      test('should get search trends without errors', () async {
        final trends = await searchService.getSearchTrends(days: 7);
        expect(trends, isA<List<Map<String, dynamic>>>());
      });
    });

    group('Data Persistence', () {
      test('should handle data persistence', () async {
        await searchService.addToHistory('persistence test', 5);

        // Create new service instance to test persistence
        final prefs = await SharedPreferences.getInstance();
        final newSearchService = SearchService(prefs);

        // Data should persist across service instances
        expect(newSearchService.searchHistory, isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle errors gracefully', () async {
        await searchService.searchWithSuggestions('');
        await searchService.addToHistory('', -1);
        await searchService.addToHistory('valid query', 0);

        expect(searchService.error, isNull);
      });

      test('should clear errors', () {
        searchService.clearError();
        expect(searchService.error, isNull);
      });
    });
  });
}
