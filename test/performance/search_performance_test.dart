import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/search_service.dart';
import 'package:vidyut/services/location_service.dart';
import 'dart:io';

void main() {
  group('Search Performance Tests', () {
    late SearchService searchService;
    late LocationService locationService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      searchService = SearchService(prefs);
      locationService = LocationService(prefs);
    });

    group('Search Service Performance', () {
      test('Search suggestions performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Test with various query lengths
        final queries = [
          'a',
          'copper',
          'circuit breaker',
          'electrical wire cable',
          'very long search query that should test performance',
        ];

        for (final query in queries) {
          await searchService.searchWithSuggestions(query);
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        print(
            'Search suggestions completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Search history performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Add many search history items
        for (int i = 0; i < 100; i++) {
          await searchService.addToHistory('query $i', i % 10);
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        print(
            'Search history operations completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Search analytics performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Track many search analytics
        for (int i = 0; i < 50; i++) {
          await searchService.trackSearch('query $i', i % 20);
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        print(
            'Search analytics operations completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Memory usage test', () async {
        // Get initial memory usage
        final initialMemory = ProcessInfo.currentRss;

        // Perform memory-intensive operations
        for (int i = 0; i < 1000; i++) {
          await searchService.addToHistory('memory test query $i', i % 10);
        }

        // Get final memory usage
        final finalMemory = ProcessInfo.currentRss;
        final memoryIncrease = finalMemory - initialMemory;

        // Memory assertion: should not increase excessively
        expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // 50MB limit
        print('Memory increase: ${memoryIncrease / 1024 / 1024}MB');
      });
    });

    group('Location Service Performance', () {
      test('Distance calculation performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Test distance calculations with many points
        final points = List.generate(
            1000,
            (i) => {
                  'lat': 17.0 + (i * 0.01),
                  'lng': 78.0 + (i * 0.01),
                });

        for (int i = 0; i < points.length - 1; i++) {
          final point1 = points[i];
          final point2 = points[i + 1];
          LocationService.calculateDistance(
            point1['lat'] as double,
            point1['lng'] as double,
            point2['lat'] as double,
            point2['lng'] as double,
          );
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print(
            'Distance calculations completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Radius filtering performance test', () async {
        // Set up test data
        final testLocation = {
          'lat': 17.3850,
          'lng': 78.4867,
        };

        final items = List.generate(
            10000,
            (i) => {
                  'id': i,
                  'lat': 17.0 + (i * 0.001),
                  'lng': 78.0 + (i * 0.001),
                });

        final stopwatch = Stopwatch()..start();

        // Test radius filtering
        final filtered = locationService.filterByRadius(
          items,
          (item) => item['lat'] as double,
          (item) => item['lng'] as double,
          10.0,
        );

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        print(
            'Radius filtering completed in ${stopwatch.elapsedMilliseconds}ms');
        print('Filtered ${filtered.length} items from ${items.length} total');
      });

      test('Distance sorting performance test', () async {
        // Set up test data
        final items = List.generate(
            5000,
            (i) => {
                  'id': i,
                  'lat': 17.0 + (i * 0.01),
                  'lng': 78.0 + (i * 0.01),
                });

        final stopwatch = Stopwatch()..start();

        // Test distance sorting
        final sorted = locationService.sortByDistance(
          items,
          (item) => item['lat'] as double,
          (item) => item['lng'] as double,
        );

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print(
            'Distance sorting completed in ${stopwatch.elapsedMilliseconds}ms');
        print('Sorted ${sorted.length} items');
      });
    });

    group('Search UI Performance', () {
      test('Search suggestions UI performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Simulate rapid typing
        final queries = [
          'c',
          'co',
          'cop',
          'copp',
          'coppe',
          'copper',
          'copper ',
          'copper w',
          'copper wi',
          'copper wir',
          'copper wire',
        ];

        for (final query in queries) {
          await searchService.searchWithSuggestions(query);
          // Simulate UI update delay
          await Future.delayed(const Duration(milliseconds: 50));
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        print(
            'Search suggestions UI completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Search results rendering performance test', () async {
        final stopwatch = Stopwatch()..start();

        // Simulate search results rendering
        final results = List.generate(
            100,
            (i) => {
                  'id': i,
                  'title': 'Product $i',
                  'price': 100.0 + i,
                  'category': 'Category ${i % 5}',
                });

        // Simulate rendering time
        for (final result in results) {
          // Simulate widget creation time
          await Future.delayed(const Duration(microseconds: 100));
        }

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print(
            'Search results rendering completed in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Concurrent Operations Performance', () {
      test('Concurrent search operations test', () async {
        final stopwatch = Stopwatch()..start();

        // Run multiple search operations concurrently
        final futures = List.generate(10, (i) async {
          await searchService.searchWithSuggestions('concurrent query $i');
          await searchService.addToHistory('concurrent query $i', i % 5);
        });

        await Future.wait(futures);

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        print(
            'Concurrent search operations completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Concurrent location operations test', () async {
        final stopwatch = Stopwatch()..start();

        // Run multiple location operations concurrently
        final items = List.generate(
            1000,
            (i) => {
                  'id': i,
                  'lat': 17.0 + (i * 0.001),
                  'lng': 78.0 + (i * 0.001),
                });

        final futures = List.generate(5, (i) async {
          locationService.filterByRadius(
            items,
            (item) => item['lat'] as double,
            (item) => item['lng'] as double,
            10.0 + i,
          );
        });

        await Future.wait(futures);

        stopwatch.stop();

        // Performance assertion: should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        print(
            'Concurrent location operations completed in ${stopwatch.elapsedMilliseconds}ms');
      });
    });
  });
}
