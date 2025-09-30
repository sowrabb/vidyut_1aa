import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidyut/services/search_service.dart';

import 'search_service_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
])
void main() {
  group('SearchService', () {
    late SearchService searchService;
    late MockSharedPreferences mockPrefs;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      mockQuerySnapshot = MockQuerySnapshot();

      // Setup mocks
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.where(any, isEqualTo: any)).thenReturn(mockQuery);
      when(mockCollection.where(any, isGreaterThanOrEqualTo: any))
          .thenReturn(mockQuery);
      when(mockCollection.where(any, isLessThan: any)).thenReturn(mockQuery);
      when(mockQuery.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      searchService = SearchService(mockPrefs);
    });

    group('Search Suggestions', () {
      test('should return empty suggestions for empty query', () async {
        await searchService.searchWithSuggestions('');
        expect(searchService.suggestions, isEmpty);
      });

      test('should get popular queries suggestions', () async {
        final mockDocs = [
          MockDocumentSnapshot(),
          MockDocumentSnapshot(),
        ];

        when(mockQuerySnapshot.docs).thenReturn(mockDocs);
        when(mockDocs[0].data()).thenReturn({
          'query': 'copper wire',
          'clickCount': 10,
          'timestamp': DateTime.now().toIso8601String(),
        });
        when(mockDocs[1].data()).thenReturn({
          'query': 'circuit breaker',
          'clickCount': 5,
          'timestamp': DateTime.now().toIso8601String(),
        });

        await searchService.searchWithSuggestions('copper');

        expect(searchService.suggestions, isNotEmpty);
        expect(searchService.suggestions.any((s) => s.text == 'copper wire'),
            isTrue);
      });

      test('should handle errors gracefully', () async {
        when(mockQuery.get()).thenThrow(Exception('Network error'));

        await searchService.searchWithSuggestions('test');

        expect(searchService.error, isNotNull);
        expect(searchService.suggestions, isEmpty);
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
      test('should track search analytics', () async {
        when(mockCollection.add(any))
            .thenAnswer((_) async => MockDocumentReference());

        await searchService.trackSearch('test query', 10,
            userId: 'user123', category: 'wires');

        verify(mockCollection.add(any)).called(1);
      });

      test('should track search result clicks', () async {
        final mockDoc = MockDocumentSnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
        when(mockDoc.reference).thenReturn(MockDocumentReference());
        when(mockDoc.reference.update(any)).thenAnswer((_) async {});

        await searchService.trackClick('test query', userId: 'user123');

        verify(mockDoc.reference.update(any)).called(1);
      });

      test('should get search trends', () async {
        final mockDocs = [
          MockDocumentSnapshot(),
          MockDocumentSnapshot(),
        ];

        when(mockQuerySnapshot.docs).thenReturn(mockDocs);
        when(mockDocs[0].data()).thenReturn({
          'query': 'copper wire',
          'clickCount': 10,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        });
        when(mockDocs[1].data()).thenReturn({
          'query': 'circuit breaker',
          'clickCount': 5,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        });

        final trends = await searchService.getSearchTrends(days: 7);

        expect(trends, isNotEmpty);
        expect(trends.first['query'], equals('copper wire'));
        expect(trends.first['count'], equals(10));
      });
    });

    group('Data Persistence', () {
      test('should load search history from preferences', () async {
        final historyJson = '''
        [
          {
            "query": "test query",
            "timestamp": "${DateTime.now().toIso8601String()}",
            "resultCount": 5,
            "category": "wires"
          }
        ]
        ''';

        when(mockPrefs.getString('search_history')).thenReturn(historyJson);

        final service = SearchService(mockPrefs);

        expect(service.searchHistory, isNotEmpty);
        expect(service.searchHistory.first.query, equals('test query'));
      });

      test('should save search history to preferences', () async {
        await searchService.addToHistory('test query', 5);

        verify(mockPrefs.setString('search_history', any)).called(1);
      });

      test('should handle invalid JSON gracefully', () async {
        when(mockPrefs.getString('search_history')).thenReturn('invalid json');

        final service = SearchService(mockPrefs);

        expect(service.searchHistory, isEmpty);
      });
    });
  });
}
