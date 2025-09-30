import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/search_service.dart';

void main() {
  group('SearchService Basic Tests', () {
    late SearchService searchService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      searchService = SearchService(prefs);
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
        // History is stored newest first, so: [query 3, query 2, query 1]

        await searchService.removeHistoryItem(1); // Remove query 2
        expect(searchService.searchHistory.length, equals(2));
        expect(searchService.searchHistory[0].query, equals('query 3'));
        expect(searchService.searchHistory[1].query, equals('query 1'));
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
