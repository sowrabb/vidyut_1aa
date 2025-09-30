import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../features/sell/models.dart';

// Add a category getter to Product without breaking your model file:
extension ProductCategory on Product {
  String get subtitleCategorySafe {
    // For demo, reuse subtitle to emulate category; fallback to first category.
    if (subtitle.isNotEmpty && kCategories.contains(subtitle)) return subtitle;
    return kCategories.first;
  }
}

class SearchSuggestion {
  final String text;
  final String type; // 'query', 'product', 'category', 'brand'
  final String? category;
  final int popularity;
  final DateTime lastUsed;

  SearchSuggestion({
    required this.text,
    required this.type,
    this.category,
    required this.popularity,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'type': type,
        'category': category,
        'popularity': popularity,
        'lastUsed': lastUsed.toIso8601String(),
      };

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      SearchSuggestion(
        text: json['text'],
        type: json['type'],
        category: json['category'],
        popularity: json['popularity'] ?? 0,
        lastUsed: DateTime.parse(json['lastUsed']),
      );
}

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final int resultCount;
  final String? category;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    required this.resultCount,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'timestamp': timestamp.toIso8601String(),
        'resultCount': resultCount,
        'category': category,
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      SearchHistoryItem(
        query: json['query'],
        timestamp: DateTime.parse(json['timestamp']),
        resultCount: json['resultCount'],
        category: json['category'],
      );
}

class SearchAnalytics {
  final String query;
  final int resultCount;
  final int clickCount;
  final DateTime timestamp;
  final String? userId;
  final String? category;

  SearchAnalytics({
    required this.query,
    required this.resultCount,
    required this.clickCount,
    required this.timestamp,
    this.userId,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'resultCount': resultCount,
        'clickCount': clickCount,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'category': category,
      };

  factory SearchAnalytics.fromJson(Map<String, dynamic> json) =>
      SearchAnalytics(
        query: json['query'],
        resultCount: json['resultCount'],
        clickCount: json['clickCount'],
        timestamp: DateTime.parse(json['timestamp']),
        userId: json['userId'],
        category: json['category'],
      );
}

class SearchService extends ChangeNotifier {
  final FirebaseFirestore? _firestore;
  final SharedPreferences _prefs;

  List<SearchSuggestion> _suggestions = [];
  List<SearchHistoryItem> _searchHistory = [];
  List<Product> _allProducts = [];
  List<String> _popularQueries = [];
  List<String> _categories = [];
  List<String> _brands = [];

  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  // Getters
  List<SearchSuggestion> get suggestions => _suggestions;
  List<SearchHistoryItem> get searchHistory => _searchHistory;
  List<Product> get allProducts => _allProducts;
  List<String> get popularQueries => _popularQueries;
  List<String> get categories => _categories;
  List<String> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SearchService(this._prefs, {FirebaseFirestore? firestore})
      : _firestore = firestore {
    _loadSearchHistory();
    _loadSuggestions();
    _loadPopularQueries();
    _loadCategories();
    _loadBrands();
  }

  // Initialize with product data for demo mode
  void initializeWithProducts(List<Product> products) {
    _allProducts = products;
    _extractCategoriesAndBrands();
    notifyListeners();
  }

  // Real-time search with suggestions
  Future<void> searchWithSuggestions(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _setLoading(true);
    _clearError();

    try {
      // Get suggestions from multiple sources
      final List<SearchSuggestion> allSuggestions = [];

      // 1. Popular queries
      final popularQueries = await _getPopularQueries(query);
      allSuggestions.addAll(popularQueries);

      // 2. Product suggestions
      final productSuggestions = await _getProductSuggestions(query);
      allSuggestions.addAll(productSuggestions);

      // 3. Category suggestions
      final categorySuggestions = await _getCategorySuggestions(query);
      allSuggestions.addAll(categorySuggestions);

      // 4. Brand suggestions
      final brandSuggestions = await _getBrandSuggestions(query);
      allSuggestions.addAll(brandSuggestions);

      // Sort by popularity and relevance
      allSuggestions.sort((a, b) {
        final relevanceA = _calculateRelevance(a.text, query);
        final relevanceB = _calculateRelevance(b.text, query);

        if (relevanceA != relevanceB) {
          return relevanceB.compareTo(relevanceA);
        }
        return b.popularity.compareTo(a.popularity);
      });

      _suggestions = allSuggestions.take(10).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to get search suggestions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get popular queries from analytics
  Future<List<SearchSuggestion>> _getPopularQueries(String query) async {
    if (_firestore == null) {
      // Demo mode - use local popular queries
      return _popularQueries
          .where((q) => q.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .map((q) => SearchSuggestion(
                text: q,
                type: 'query',
                popularity: 10,
                lastUsed: DateTime.now(),
              ))
          .toList();
    }

    try {
      final snapshot = await _firestore
          .collection('search_analytics')
          .where('query', isGreaterThanOrEqualTo: query)
          .where('query', isLessThan: query + 'z')
          .orderBy('query')
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchSuggestion(
          text: data['query'],
          type: 'query',
          popularity: data['clickCount'] ?? 0,
          lastUsed: DateTime.parse(data['timestamp']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get product suggestions
  Future<List<SearchSuggestion>> _getProductSuggestions(String query) async {
    if (_firestore == null) {
      // Demo mode - use local products
      return _allProducts
          .where((p) =>
              p.title.toLowerCase().contains(query.toLowerCase()) ||
              p.brand.toLowerCase().contains(query.toLowerCase()) ||
              p.subtitle.toLowerCase().contains(query.toLowerCase()))
          .take(3)
          .map((p) => SearchSuggestion(
                text: p.title,
                type: 'product',
                category: p.subtitleCategorySafe,
                popularity: p.rating.toInt(),
                lastUsed: DateTime.now(),
              ))
          .toList();
    }

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchSuggestion(
          text: data['title'],
          type: 'product',
          category: data['category'],
          popularity: data['viewCount'] ?? 0,
          lastUsed: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get category suggestions
  Future<List<SearchSuggestion>> _getCategorySuggestions(String query) async {
    if (_firestore == null) {
      // Demo mode - use local categories
      return _categories
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .take(3)
          .map((c) => SearchSuggestion(
                text: c,
                type: 'category',
                category: c,
                popularity: _allProducts
                    .where((p) => p.subtitleCategorySafe == c)
                    .length,
                lastUsed: DateTime.now(),
              ))
          .toList();
    }

    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchSuggestion(
          text: data['name'],
          type: 'category',
          category: data['name'],
          popularity: data['productCount'] ?? 0,
          lastUsed: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get brand suggestions
  Future<List<SearchSuggestion>> _getBrandSuggestions(String query) async {
    if (_firestore == null) {
      // Demo mode - use local brands
      return _brands
          .where((b) => b.toLowerCase().contains(query.toLowerCase()))
          .take(3)
          .map((b) => SearchSuggestion(
                text: b,
                type: 'brand',
                category: _allProducts
                    .firstWhere((p) => p.brand == b,
                        orElse: () => _allProducts.first)
                    .subtitleCategorySafe,
                popularity: _allProducts.where((p) => p.brand == b).length,
                lastUsed: DateTime.now(),
              ))
          .toList();
    }

    try {
      final snapshot = await _firestore
          .collection('brands')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchSuggestion(
          text: data['name'],
          type: 'brand',
          category: data['category'],
          popularity: data['productCount'] ?? 0,
          lastUsed: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Calculate relevance score
  int _calculateRelevance(String text, String query) {
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    if (textLower.startsWith(queryLower)) return 100;
    if (textLower.contains(queryLower)) return 50;
    return 0;
  }

  // Add search to history
  Future<void> addToHistory(String query, int resultCount,
      {String? category}) async {
    final historyItem = SearchHistoryItem(
      query: query,
      timestamp: DateTime.now(),
      resultCount: resultCount,
      category: category,
    );

    _searchHistory.insert(0, historyItem);

    // Keep only last 50 searches
    if (_searchHistory.length > 50) {
      _searchHistory = _searchHistory.take(50).toList();
    }

    await _saveSearchHistory();
    notifyListeners();
  }

  // Clear search history
  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _saveSearchHistory();
    notifyListeners();
  }

  // Remove specific history item
  Future<void> removeHistoryItem(int index) async {
    if (index >= 0 && index < _searchHistory.length) {
      _searchHistory.removeAt(index);
      await _saveSearchHistory();
      notifyListeners();
    }
  }

  // Track search analytics
  Future<void> trackSearch(String query, int resultCount,
      {String? userId, String? category}) async {
    if (_firestore == null) return;

    try {
      final analytics = SearchAnalytics(
        query: query,
        resultCount: resultCount,
        clickCount: 0,
        timestamp: DateTime.now(),
        userId: userId,
        category: category,
      );

      await _firestore.collection('search_analytics').add(analytics.toJson());
    } catch (e) {
      // Handle error silently
    }
  }

  // Track search result click
  Future<void> trackClick(String query, {String? userId}) async {
    if (_firestore == null) return;

    try {
      final snapshot = await _firestore
          .collection('search_analytics')
          .where('query', isEqualTo: query)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        await doc.reference.update({
          'clickCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Load search history from local storage
  Future<void> _loadSearchHistory() async {
    try {
      final historyJson = _prefs.getString('search_history');
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _searchHistory = historyList
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      _searchHistory = [];
    }
  }

  // Save search history to local storage
  Future<void> _saveSearchHistory() async {
    try {
      final historyJson = jsonEncode(
        _searchHistory.map((item) => item.toJson()).toList(),
      );
      await _prefs.setString('search_history', historyJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Load suggestions from local storage
  Future<void> _loadSuggestions() async {
    try {
      final suggestionsJson = _prefs.getString('search_suggestions');
      if (suggestionsJson != null) {
        final List<dynamic> suggestionsList = jsonDecode(suggestionsJson);
        _suggestions = suggestionsList
            .map((item) => SearchSuggestion.fromJson(item))
            .toList();
      }
    } catch (e) {
      _suggestions = [];
    }
  }

  // Get search trends
  Future<List<Map<String, dynamic>>> getSearchTrends({int days = 7}) async {
    if (_firestore == null) return [];

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('search_analytics')
          .where('timestamp', isGreaterThan: cutoffDate)
          .orderBy('timestamp', descending: true)
          .get();

      final Map<String, int> queryCounts = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final query = data['query'];
        queryCounts[query] = (queryCounts[query] ?? 0) + 1;
      }

      return queryCounts.entries
          .map((entry) => {
                'query': entry.key,
                'count': entry.value,
              })
          .toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    } catch (e) {
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Load popular queries from local storage
  Future<void> _loadPopularQueries() async {
    try {
      final queriesJson = _prefs.getString('popular_queries');
      if (queriesJson != null) {
        final List<dynamic> queriesList = jsonDecode(queriesJson);
        _popularQueries = queriesList.cast<String>();
      } else {
        // Default popular queries for demo
        _popularQueries = [
          'copper wire',
          'circuit breaker',
          'MCB',
          'LED lights',
          'cable',
          'switch',
          'motor',
          'transformer',
          'electrical panel',
          'wiring'
        ];
      }
    } catch (e) {
      _popularQueries = [];
    }
  }

  // Load categories from local storage
  Future<void> _loadCategories() async {
    try {
      final categoriesJson = _prefs.getString('categories');
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = jsonDecode(categoriesJson);
        _categories = categoriesList.cast<String>();
      } else {
        // Default categories
        _categories = [
          'Wires & Cables',
          'Circuit Breakers',
          'Lights',
          'Motors',
          'Tools',
          'Switches',
          'Transformers',
          'Electrical Panels'
        ];
      }
    } catch (e) {
      _categories = [];
    }
  }

  // Load brands from local storage
  Future<void> _loadBrands() async {
    try {
      final brandsJson = _prefs.getString('brands');
      if (brandsJson != null) {
        final List<dynamic> brandsList = jsonDecode(brandsJson);
        _brands = brandsList.cast<String>();
      } else {
        // Default brands
        _brands = [
          'Finolex',
          'Schneider',
          'Havells',
          'Bajaj',
          'Crompton',
          'Philips',
          'Syska',
          'Orient',
          'Polycab',
          'Legrand'
        ];
      }
    } catch (e) {
      _brands = [];
    }
  }

  // Extract categories and brands from products
  void _extractCategoriesAndBrands() {
    final Set<String> categoriesSet = {};
    final Set<String> brandsSet = {};

    for (final product in _allProducts) {
      // Use category field if available, otherwise use subtitleCategorySafe
      final category = product.category.isNotEmpty
          ? product.category
          : product.subtitleCategorySafe;
      if (category.isNotEmpty) {
        categoriesSet.add(category);
      }
      if (product.brand.isNotEmpty) {
        brandsSet.add(product.brand);
      }
    }

    _categories = categoriesSet.toList()..sort();
    _brands = brandsSet.toList()..sort();
  }

  // Enhanced search with intelligent suggestions based on user behavior
  Future<List<SearchSuggestion>> getIntelligentSuggestions(String query) async {
    if (query.isEmpty) return [];

    final List<SearchSuggestion> intelligentSuggestions = [];

    // 1. Recent search history (highest priority)
    final recentHistory = _searchHistory
        .where((item) => item.query.toLowerCase().contains(query.toLowerCase()))
        .take(3)
        .map((item) => SearchSuggestion(
              text: item.query,
              type: 'history',
              category: item.category,
              popularity: 100,
              lastUsed: item.timestamp,
            ))
        .toList();
    intelligentSuggestions.addAll(recentHistory);

    // 2. Popular queries
    final popularSuggestions = await _getPopularQueries(query);
    intelligentSuggestions.addAll(popularSuggestions);

    // 3. Product suggestions
    final productSuggestions = await _getProductSuggestions(query);
    intelligentSuggestions.addAll(productSuggestions);

    // 4. Category suggestions
    final categorySuggestions = await _getCategorySuggestions(query);
    intelligentSuggestions.addAll(categorySuggestions);

    // 5. Brand suggestions
    final brandSuggestions = await _getBrandSuggestions(query);
    intelligentSuggestions.addAll(brandSuggestions);

    // Remove duplicates and sort by relevance
    final Map<String, SearchSuggestion> uniqueSuggestions = {};
    for (final suggestion in intelligentSuggestions) {
      if (!uniqueSuggestions.containsKey(suggestion.text)) {
        uniqueSuggestions[suggestion.text] = suggestion;
      }
    }

    final sortedSuggestions = uniqueSuggestions.values.toList();
    sortedSuggestions.sort((a, b) {
      final relevanceA = _calculateRelevance(a.text, query);
      final relevanceB = _calculateRelevance(b.text, query);

      if (relevanceA != relevanceB) {
        return relevanceB.compareTo(relevanceA);
      }
      return b.popularity.compareTo(a.popularity);
    });

    return sortedSuggestions.take(10).toList();
  }

  // Advanced filtering with multiple criteria
  List<Product> filterProducts({
    String? query,
    List<String>? categories,
    List<String>? materials,
    List<String>? brands,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    List<Product> filtered = List.from(_allProducts);

    // Text search
    if (query != null && query.isNotEmpty) {
      final queryLower = query.toLowerCase();
      filtered = filtered.where((product) {
        return product.title.toLowerCase().contains(queryLower) ||
            product.brand.toLowerCase().contains(queryLower) ||
            product.subtitle.toLowerCase().contains(queryLower) ||
            product.materials
                .any((material) => material.toLowerCase().contains(queryLower));
      }).toList();
    }

    // Category filter
    if (categories != null && categories.isNotEmpty) {
      filtered = filtered.where((product) {
        final productCategory = product.category.isNotEmpty
            ? product.category
            : product.subtitleCategorySafe;
        return categories.contains(productCategory);
      }).toList();
    }

    // Material filter
    if (materials != null && materials.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              materials.any((material) => product.materials.contains(material)))
          .toList();
    }

    // Brand filter
    if (brands != null && brands.isNotEmpty) {
      filtered =
          filtered.where((product) => brands.contains(product.brand)).toList();
    }

    // Price filter
    if (minPrice != null) {
      filtered =
          filtered.where((product) => product.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filtered =
          filtered.where((product) => product.price <= maxPrice).toList();
    }

    // Sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name_asc':
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'name_desc':
          filtered.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        default:
          // Keep original order for relevance
          break;
      }
    }

    return filtered;
  }

  // Get search analytics summary
  Map<String, dynamic> getSearchAnalytics() {
    final totalSearches = _searchHistory.length;
    final uniqueQueries =
        _searchHistory.map((item) => item.query).toSet().length;
    final avgResultsPerSearch = _searchHistory.isNotEmpty
        ? _searchHistory
                .map((item) => item.resultCount)
                .reduce((a, b) => a + b) /
            _searchHistory.length
        : 0.0;

    return {
      'totalSearches': totalSearches,
      'uniqueQueries': uniqueQueries,
      'avgResultsPerSearch': avgResultsPerSearch,
      'mostSearchedCategories': _getMostSearchedCategories(),
      'searchTrends': _getSearchTrends(),
    };
  }

  // Get most searched categories
  Map<String, int> _getMostSearchedCategories() {
    final Map<String, int> categoryCounts = {};
    for (final item in _searchHistory) {
      if (item.category != null) {
        categoryCounts[item.category!] =
            (categoryCounts[item.category!] ?? 0) + 1;
      }
    }
    return categoryCounts;
  }

  // Get search trends (last 7 days)
  List<Map<String, dynamic>> _getSearchTrends() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    final recentSearches = _searchHistory
        .where((item) => item.timestamp.isAfter(cutoffDate))
        .toList();

    final Map<String, int> queryCounts = {};
    for (final search in recentSearches) {
      queryCounts[search.query] = (queryCounts[search.query] ?? 0) + 1;
    }

    return queryCounts.entries
        .map((entry) => {'query': entry.key, 'count': entry.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
