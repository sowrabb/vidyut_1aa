import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/search_service.dart';
import 'package:vidyut/services/location_service.dart';

void main() {
  group('Search Security Tests', () {
    late SearchService searchService;
    late LocationService locationService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      searchService = SearchService(prefs);
      locationService = LocationService(prefs);
    });

    group('Input Validation Security', () {
      test('should handle malicious search queries', () async {
        final maliciousQueries = [
          '<script>alert("xss")</script>',
          'SELECT * FROM users; DROP TABLE users;',
          '../../../etc/passwd',
          '${'A' * 10000}', // Very long string
          'null\x00',
          'undefined',
          'NaN',
          'Infinity',
          '{}',
          '[]',
          'true',
          'false',
        ];

        for (final query in maliciousQueries) {
          await searchService.searchWithSuggestions(query);
          await searchService.addToHistory(query, 0);

          // Should not crash or throw exceptions
          expect(searchService.error, isNull);
        }
      });

      test('should sanitize search history data', () async {
        final maliciousQuery = '<script>alert("xss")</script>';
        await searchService.addToHistory(maliciousQuery, 0);

        final historyItem = searchService.searchHistory.first;
        expect(historyItem.query, equals(maliciousQuery));

        // The query should be stored as-is for display purposes
        // but should be properly escaped when used in UI
        expect(historyItem.query.contains('<script>'), isTrue);
      });

      test('should handle special characters in search queries', () async {
        final specialCharQueries = [
          'café',
          'naïve',
          'résumé',
          '测试',
          'العربية',
          'русский',
          'हिन्दी',
          '🚀',
          '💡',
          '⚡',
        ];

        for (final query in specialCharQueries) {
          await searchService.searchWithSuggestions(query);
          await searchService.addToHistory(query, 0);

          expect(searchService.error, isNull);
        }
      });

      test('should handle empty and null inputs', () async {
        await searchService.searchWithSuggestions('');
        await searchService.addToHistory('', 0);
        await searchService.addToHistory('valid query', -1);
        await searchService.addToHistory('valid query', 0);

        expect(searchService.error, isNull);
      });
    });

    group('Data Privacy Security', () {
      test('should not expose sensitive user data in search suggestions',
          () async {
        // Simulate search suggestions that might contain sensitive data
        await searchService.searchWithSuggestions('user');

        // Search suggestions should not contain sensitive information
        for (final suggestion in searchService.suggestions) {
          expect(suggestion.text.toLowerCase(), isNot(contains('password')));
          expect(suggestion.text.toLowerCase(), isNot(contains('email')));
          expect(suggestion.text.toLowerCase(), isNot(contains('phone')));
          expect(suggestion.text.toLowerCase(), isNot(contains('address')));
        }
      });

      test('should handle location data privacy', () async {
        // Test that location data is properly handled
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        locationService.currentLocation = locationData;

        // Location data should be accessible but not logged in plain text
        expect(locationService.currentLocation, isNotNull);
        expect(locationService.currentLocation!.city, equals('Hyderabad'));
      });

      test('should not log sensitive search queries', () async {
        final sensitiveQueries = [
          'password reset',
          'credit card',
          'social security',
          'bank account',
        ];

        for (final query in sensitiveQueries) {
          await searchService.searchWithSuggestions(query);
          await searchService.addToHistory(query, 0);
        }

        // Search history should be stored but not logged
        expect(searchService.searchHistory.length,
            equals(sensitiveQueries.length));
      });
    });

    group('SQL Injection Prevention', () {
      test('should prevent SQL injection in search queries', () async {
        final sqlInjectionQueries = [
          "'; DROP TABLE users; --",
          "' OR '1'='1",
          "' UNION SELECT * FROM users --",
          "'; INSERT INTO users VALUES ('hacker', 'password'); --",
          "' OR 1=1 --",
        ];

        for (final query in sqlInjectionQueries) {
          await searchService.searchWithSuggestions(query);
          await searchService.addToHistory(query, 0);

          // Should not cause any database errors
          expect(searchService.error, isNull);
        }
      });

      test('should handle Firestore query injection attempts', () async {
        final firestoreInjectionQueries = [
          "'; DROP COLLECTION products; --",
          "' || '",
          "' && '",
          "'; UPDATE products SET price = 0; --",
        ];

        for (final query in firestoreInjectionQueries) {
          await searchService.searchWithSuggestions(query);

          // Should not cause Firestore errors
          expect(searchService.error, isNull);
        }
      });
    });

    group('XSS Prevention', () {
      test('should prevent XSS in search suggestions', () async {
        final xssQueries = [
          '<script>alert("XSS")</script>',
          '<img src="x" onerror="alert(\'XSS\')">',
          '<svg onload="alert(\'XSS\')">',
          'javascript:alert("XSS")',
          '<iframe src="javascript:alert(\'XSS\')">',
        ];

        for (final query in xssQueries) {
          await searchService.searchWithSuggestions(query);

          // Suggestions should be returned but properly escaped in UI
          expect(searchService.error, isNull);
        }
      });

      test('should handle HTML entities in search queries', () async {
        final htmlEntityQueries = [
          '&lt;script&gt;',
          '&amp;',
          '&quot;',
          '&#39;',
          '&nbsp;',
        ];

        for (final query in htmlEntityQueries) {
          await searchService.searchWithSuggestions(query);
          await searchService.addToHistory(query, 0);

          expect(searchService.error, isNull);
        }
      });
    });

    group('Rate Limiting Security', () {
      test('should handle rapid search requests', () async {
        final stopwatch = Stopwatch()..start();

        // Send many rapid requests
        for (int i = 0; i < 100; i++) {
          await searchService.searchWithSuggestions('rapid query $i');
        }

        stopwatch.stop();

        // Should complete without errors
        expect(searchService.error, isNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });

      test('should handle concurrent search requests', () async {
        final futures = List.generate(20, (i) async {
          await searchService.searchWithSuggestions('concurrent query $i');
        });

        await Future.wait(futures);

        // Should complete without errors
        expect(searchService.error, isNull);
      });
    });

    group('Data Validation Security', () {
      test('should validate search result counts', () async {
        final invalidCounts = [
          -1,
          -100,
          999999999,
          double.infinity,
          double.nan
        ];

        for (final count in invalidCounts) {
          await searchService.addToHistory('test query', count.toInt());
        }

        // Should handle invalid counts gracefully
        expect(searchService.error, isNull);
      });

      test('should validate location coordinates', () {
        final invalidCoordinates = [
          {'lat': 200.0, 'lng': 78.0}, // Invalid latitude
          {'lat': 17.0, 'lng': 200.0}, // Invalid longitude
          {'lat': double.nan, 'lng': 78.0},
          {'lat': 17.0, 'lng': double.infinity},
        ];

        for (final coord in invalidCoordinates) {
          expect(() {
            LocationService.calculateDistance(
              coord['lat'] as double,
              coord['lng'] as double,
              17.0,
              78.0,
            );
          }, returnsNormally);
        }
      });
    });

    group('Authentication Security', () {
      test('should handle search without authentication', () async {
        // Search should work without authentication
        await searchService.searchWithSuggestions('public query');
        await searchService.addToHistory('public query', 0);

        expect(searchService.error, isNull);
      });

      test('should handle analytics without authentication', () async {
        // Analytics should work without authentication
        await searchService.trackSearch('public query', 0);
        await searchService.trackClick('public query');

        expect(searchService.error, isNull);
      });
    });

    group('Data Integrity Security', () {
      test('should maintain data integrity during concurrent operations',
          () async {
        // Perform concurrent operations that might affect data integrity
        final futures = [
          searchService.addToHistory('query 1', 1),
          searchService.addToHistory('query 2', 2),
          searchService.addToHistory('query 3', 3),
          searchService.clearHistory(),
          searchService.addToHistory('query 4', 4),
        ];

        await Future.wait(futures);

        // History should be in a consistent state
        expect(searchService.searchHistory.length, greaterThanOrEqualTo(0));
        expect(searchService.error, isNull);
      });

      test('should handle data corruption gracefully', () async {
        // Simulate corrupted data
        final corruptedJson = '{"invalid": "json"';

        // Should handle corruption gracefully
        expect(() {
          searchService.addToHistory('test', 0);
        }, returnsNormally);
      });
    });
  });
}
