/// Firebase-backed search history providers
/// Tracks user searches for better UX and analytics
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_search_history_providers.g.dart';

/// Model for search history entry
class SearchHistoryEntry {
  final String id;
  final String userId;
  final String query;
  final String category;
  final DateTime timestamp;
  final int resultCount;
  final bool clicked; // Did user click on a result?

  SearchHistoryEntry({
    required this.id,
    required this.userId,
    required this.query,
    required this.category,
    required this.timestamp,
    required this.resultCount,
    required this.clicked,
  });

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      query: json['query'] as String,
      category: json['category'] as String? ?? 'general',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      resultCount: json['result_count'] as int? ?? 0,
      clicked: json['clicked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'query': query,
    'category': category,
    'timestamp': Timestamp.fromDate(timestamp),
    'result_count': resultCount,
    'clicked': clicked,
  };
}

/// Model for popular search
class PopularSearch {
  final String query;
  final int count;
  final DateTime lastSearched;

  PopularSearch({
    required this.query,
    required this.count,
    required this.lastSearched,
  });

  factory PopularSearch.fromJson(Map<String, dynamic> json) {
    return PopularSearch(
      query: json['query'] as String,
      count: json['count'] as int,
      lastSearched: (json['last_searched'] as Timestamp).toDate(),
    );
  }
}

/// Stream user's recent searches
@riverpod
Stream<List<SearchHistoryEntry>> firebaseUserSearchHistory(
  FirebaseUserSearchHistoryRef ref, {
  int limit = 20,
}) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('search_history')
      .where('user_id', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchHistoryEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream popular searches (trending)
@riverpod
Stream<List<PopularSearch>> firebasePopularSearches(
  FirebasePopularSearchesRef ref, {
  int limit = 10,
}) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('popular_searches')
      .orderBy('count', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularSearch.fromJson(data);
    }).toList();
  });
}

/// Stream search suggestions based on query
@riverpod
Stream<List<String>> firebaseSearchSuggestions(
  FirebaseSearchSuggestionsRef ref,
  String query,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  if (query.isEmpty) {
    return Stream.value([]);
  }

  // Get popular searches that match the query
  return firestore
      .collection('popular_searches')
      .orderBy('count', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    final allSearches = snapshot.docs.map((doc) {
      return doc.data()['query'] as String;
    }).toList();

    // Filter by query prefix (case-insensitive)
    final lowerQuery = query.toLowerCase();
    return allSearches
        .where((s) => s.toLowerCase().startsWith(lowerQuery))
        .take(5)
        .toList();
  });
}

/// Stream searches by category
@riverpod
Stream<List<SearchHistoryEntry>> firebaseSearchesByCategory(
  FirebaseSearchesByCategoryRef ref,
  String category,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('search_history')
      .where('user_id', isEqualTo: userId)
      .where('category', isEqualTo: category)
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchHistoryEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Service for search history operations
@riverpod
SearchHistoryService searchHistoryService(SearchHistoryServiceRef ref) {
  return SearchHistoryService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Search history service class
class SearchHistoryService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  SearchHistoryService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Record a search query
  Future<void> recordSearch({
    required String query,
    String category = 'general',
    int resultCount = 0,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return; // Don't track anonymous searches

    // Add to user's search history
    await firestore.collection('search_history').add({
      'user_id': userId,
      'query': query.trim(),
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
      'result_count': resultCount,
      'clicked': false,
    });

    // Update popular searches (aggregated)
    await _updatePopularSearches(query.trim());
  }

  /// Mark a search as clicked (user found what they wanted)
  Future<void> markSearchClicked(String searchHistoryId) async {
    await firestore.collection('search_history').doc(searchHistoryId).update({
      'clicked': true,
    });
  }

  /// Clear user's search history
  Future<void> clearSearchHistory() async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    final snapshot = await firestore
        .collection('search_history')
        .where('user_id', isEqualTo: userId)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Delete a specific search entry
  Future<void> deleteSearchEntry(String searchHistoryId) async {
    await firestore.collection('search_history').doc(searchHistoryId).delete();
  }

  /// Get recent searches (for suggestions)
  Future<List<String>> getRecentSearchQueries({int limit = 5}) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final snapshot = await firestore
        .collection('search_history')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['query'] as String)
        .toSet() // Remove duplicates
        .toList();
  }

  /// Get popular searches
  Future<List<PopularSearch>> getPopularSearches({int limit = 10}) async {
    final snapshot = await firestore
        .collection('popular_searches')
        .orderBy('count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularSearch.fromJson(data);
    }).toList();
  }

  /// Get search analytics (admin)
  Future<Map<String, dynamic>> getSearchAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = firestore.collection('search_history');

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    final totalSearches = snapshot.docs.length;
    final uniqueUsers = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['user_id'] as String)
        .toSet()
        .length;

    final clickedSearches = snapshot.docs
        .where((doc) => (doc.data() as Map<String, dynamic>)['clicked'] as bool? ?? false)
        .length;

    final clickThroughRate = totalSearches > 0
        ? (clickedSearches / totalSearches) * 100
        : 0.0;

    // Group by category
    final categoryCount = <String, int>{};
    for (final doc in snapshot.docs) {
      final category = (doc.data() as Map<String, dynamic>)['category'] as String? ?? 'general';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return {
      'total_searches': totalSearches,
      'unique_users': uniqueUsers,
      'clicked_searches': clickedSearches,
      'click_through_rate': clickThroughRate,
      'category_breakdown': categoryCount,
    };
  }

  /// Update popular searches aggregation
  Future<void> _updatePopularSearches(String query) async {
    final docRef = firestore
        .collection('popular_searches')
        .doc(_sanitizeQueryForDocId(query));

    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (doc.exists) {
        // Increment count
        transaction.update(docRef, {
          'count': FieldValue.increment(1),
          'last_searched': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new entry
        transaction.set(docRef, {
          'query': query,
          'count': 1,
          'last_searched': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Sanitize query to use as document ID
  String _sanitizeQueryForDocId(String query) {
    // Remove special characters, convert to lowercase
    return query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, query.length > 50 ? 50 : query.length);
  }

  /// Get zero-result searches (for improving search)
  Future<List<SearchHistoryEntry>> getZeroResultSearches({int limit = 50}) async {
    final snapshot = await firestore
        .collection('search_history')
        .where('result_count', isEqualTo: 0)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchHistoryEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Clean up old search history (older than 90 days)
  Future<void> cleanupOldSearchHistory() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));

    final snapshot = await firestore
        .collection('search_history')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

