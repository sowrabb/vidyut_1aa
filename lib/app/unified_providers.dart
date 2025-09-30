import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core imports
import '../services/lightweight_demo_data_service.dart';
import '../services/firebase_auth_service.dart';
import '../features/admin/rbac/rbac_service.dart';

// Models
import '../features/sell/models.dart';
import '../features/messaging/models.dart';
import '../features/categories/categories_page.dart';

// =============================================================================
// CORE AUTH & SESSION PROVIDERS
// =============================================================================

/// Raw Firebase auth state
final firebaseAuthServiceProvider =
    ChangeNotifierProvider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Session state derived from Firebase auth
final sessionProvider =
    NotifierProvider<SessionStore, SessionState>(SessionStore.new);

class SessionState {
  final bool isLoggedIn;
  final String? userId;
  final String? email;
  final String role;
  final bool emailVerified;
  final String? displayName;
  final String? phoneNumber;

  const SessionState({
    required this.isLoggedIn,
    this.userId,
    this.email,
    required this.role,
    required this.emailVerified,
    this.displayName,
    this.phoneNumber,
  });

  SessionState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? email,
    String? role,
    bool? emailVerified,
    String? displayName,
    String? phoneNumber,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class SessionStore extends Notifier<SessionState> {
  @override
  SessionState build() {
    final authService = ref.watch(firebaseAuthServiceProvider);

    // Listen to auth changes
    ref.listen(firebaseAuthServiceProvider, (previous, next) {
      if (previous?.user != next.user) {
        _updateSessionState();
      }
    });

    return _deriveSessionState(authService);
  }

  void _updateSessionState() {
    final authService = ref.read(firebaseAuthServiceProvider);
    state = _deriveSessionState(authService);
  }

  SessionState _deriveSessionState(FirebaseAuthService authService) {
    final user = authService.user;

    if (user == null) {
      return const SessionState(
        isLoggedIn: false,
        role: 'guest',
        emailVerified: false,
      );
    }

    // Determine role based on user properties or admin status
    String role = 'buyer'; // default role

    // Check if user is admin (this would typically come from user claims or database)
    if (user.email?.endsWith('@admin.vidyut.com') == true) {
      role = 'admin';
    } else if (user.displayName?.contains('Seller') == true) {
      role = 'seller';
    }

    return SessionState(
      isLoggedIn: true,
      userId: user.uid,
      email: user.email,
      role: role,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
    );
  }
}

// =============================================================================
// RBAC PROVIDER
// =============================================================================

final rbacProvider = NotifierProvider<RbacStore, RbacState>(RbacStore.new);

// RBAC Service Provider (for backward compatibility)
final rbacServiceProvider = ChangeNotifierProvider<RbacService>((ref) {
  final svc = RbacService()..hydrate();
  return svc;
});

class RbacState {
  final String role;
  final Map<String, Set<String>> roleToPermissions;

  const RbacState({
    required this.role,
    required this.roleToPermissions,
  });

  bool can(String permission) {
    final perms = roleToPermissions[role];
    if (perms == null) return false;
    if (perms.contains(permission)) return true;

    // Check wildcard permissions
    for (final p in perms) {
      if (p.endsWith('.*') &&
          permission.startsWith(p.substring(0, p.length - 2))) {
        return true;
      }
    }
    return false;
  }
}

class RbacStore extends Notifier<RbacState> {
  @override
  RbacState build() {
    final session = ref.watch(sessionProvider);
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final roleToPermissions = demoDataService.rolePermissions;

    return RbacState(
      role: session.role,
      roleToPermissions: roleToPermissions,
    );
  }

  /// Update permissions for testing or dynamic configuration
  void updatePermissions(Map<String, Set<String>> permissions) {
    final session = ref.read(sessionProvider);
    state = RbacState(
      role: session.role,
      roleToPermissions: permissions,
    );
  }
}

// =============================================================================
// USER PROFILE PROVIDER
// =============================================================================

final userProfileProvider =
    AsyncNotifierProvider<UserProfileStore, UserProfile>(UserProfileStore.new);

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final List<String> favoriteProductIds;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.favoriteProductIds,
    required this.preferences,
    required this.createdAt,
    required this.lastActive,
  });

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    List<String>? favoriteProductIds,
    Map<String, dynamic>? preferences,
    DateTime? lastActive,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class UserProfileStore extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final session = ref.watch(sessionProvider);

    if (!session.isLoggedIn || session.userId == null) {
      throw Exception('User not logged in');
    }

    return _loadUserProfile(session.userId!);
  }

  Future<UserProfile> _loadUserProfile(String userId) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);

    // Try to find user in demo data first
    final adminUsers = demoDataService.allUsers;
    final adminUser = adminUsers.where((u) => u.id == userId).firstOrNull;

    if (adminUser != null) {
      return UserProfile(
        userId: adminUser.id,
        name: adminUser.name,
        email: adminUser.email,
        phoneNumber: adminUser.phone,
        role: adminUser.role.name,
        favoriteProductIds: const [], // TODO: implement favorites
        preferences: const {}, // TODO: implement preferences
        createdAt: adminUser.createdAt,
        lastActive: adminUser.lastActive,
      );
    }

    // Create default profile for new users
    return UserProfile(
      userId: userId,
      name: 'User',
      email: 'user@example.com',
      role: 'buyer',
      favoriteProductIds: const [],
      preferences: const {},
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
  }

  Future<void> updateFavorites(List<String> productIds) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(favoriteProductIds: productIds));
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(preferences: preferences));
  }
}

// =============================================================================
// CORE DATA SERVICE PROVIDER
// =============================================================================

final lightweightDemoDataServiceProvider =
    ChangeNotifierProvider<LightweightDemoDataService>((ref) {
  return LightweightDemoDataService();
});

// =============================================================================
// CATEGORIES PROVIDER
// =============================================================================

final categoriesProvider =
    AsyncNotifierProvider<CategoriesStore, CategoryTree>(CategoriesStore.new);

class CategoryTree {
  final List<CategoryData> categories;
  final Map<String, List<CategoryData>> parentChildrenMap;

  const CategoryTree({
    required this.categories,
    required this.parentChildrenMap,
  });

  List<CategoryData> getRootCategories() {
    // Note: CategoryData doesn't have parentId in current model
    // Return all categories as root categories for now
    return categories;
  }

  List<CategoryData> getChildren(String parentId) {
    // Note: CategoryData doesn't have parentId in current model
    // This is a placeholder for future hierarchical categories
    return [];
  }

  List<String> getBreadcrumbs(String categoryId) {
    final category = categories.firstWhere((c) => c.name == categoryId);
    return [category.name];
  }
}

class CategoriesStore extends AsyncNotifier<CategoryTree> {
  @override
  Future<CategoryTree> build() async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final categories = demoDataService.allCategories;

    final parentChildrenMap = <String, List<CategoryData>>{};
    // Note: CategoryData doesn't have parentId in current model
    // This is a placeholder for future hierarchical categories

    return CategoryTree(
      categories: categories,
      parentChildrenMap: parentChildrenMap,
    );
  }
}

// =============================================================================
// SEARCH PROVIDERS
// =============================================================================

class SearchQuery {
  final String query;
  final List<String> categories;
  final String? location;
  final double? radiusKm;
  final Map<String, dynamic> filters;

  const SearchQuery({
    required this.query,
    required this.categories,
    this.location,
    this.radiusKm,
    required this.filters,
  });

  SearchQuery copyWith({
    String? query,
    List<String>? categories,
    String? location,
    double? radiusKm,
    Map<String, dynamic>? filters,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      filters: filters ?? this.filters,
    );
  }
}

class SearchResults {
  final List<Product> products;
  final int totalCount;
  final List<String> suggestions;
  final Map<String, int> categoryCounts;

  const SearchResults({
    required this.products,
    required this.totalCount,
    required this.suggestions,
    required this.categoryCounts,
  });
}

final searchQueryProvider = StateProvider<SearchQuery>((ref) {
  return const SearchQuery(
    query: '',
    categories: [],
    filters: {},
  );
});

final searchResultsProvider =
    AsyncNotifierProvider<SearchResultsStore, SearchResults>(
        SearchResultsStore.new);

class SearchResultsStore extends AsyncNotifier<SearchResults> {
  @override
  Future<SearchResults> build() async {
    final query = ref.watch(searchQueryProvider);
    return _performSearch(query);
  }

  Future<SearchResults> _performSearch(SearchQuery query) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allProducts = demoDataService.allProducts;

    // Simple search implementation
    List<Product> results = allProducts;

    // Filter by query
    if (query.query.isNotEmpty) {
      final queryLower = query.query.toLowerCase();
      results = results
          .where((product) =>
              product.name.toLowerCase().contains(queryLower) ||
              product.description.toLowerCase().contains(queryLower) ||
              product.category.toLowerCase().contains(queryLower))
          .toList();
    }

    // Filter by categories
    if (query.categories.isNotEmpty) {
      results = results
          .where((product) => query.categories.contains(product.category))
          .toList();
    }

    // Generate suggestions based on product names and categories
    final suggestions = results.take(5).map((p) => p.name).toList();

    // Count products by category
    final categoryCounts = <String, int>{};
    for (final product in results) {
      categoryCounts[product.category] =
          (categoryCounts[product.category] ?? 0) + 1;
    }

    return SearchResults(
      products: results,
      totalCount: results.length,
      suggestions: suggestions,
      categoryCounts: categoryCounts,
    );
  }

  Future<void> updateQuery(SearchQuery query) async {
    ref.read(searchQueryProvider.notifier).state = query;
    // The provider will automatically rebuild due to the watch dependency
  }
}

// =============================================================================
// SEARCH HISTORY PROVIDER
// =============================================================================

class SearchEntry {
  final String query;
  final DateTime timestamp;
  final Map<String, dynamic> filters;

  const SearchEntry({
    required this.query,
    required this.timestamp,
    required this.filters,
  });
}

final searchHistoryProvider =
    NotifierProvider<SearchHistoryStore, List<SearchEntry>>(
        SearchHistoryStore.new);

class SearchHistoryStore extends Notifier<List<SearchEntry>> {
  @override
  List<SearchEntry> build() {
    _loadHistory();
    return [];
  }

  void _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('search_history') ?? [];

    final history = historyJson
        .map((json) {
          // Simple JSON parsing - in real app, use proper JSON parsing
          final parts = json.split('|');
          if (parts.length >= 2) {
            return SearchEntry(
              query: parts[0],
              timestamp: DateTime.tryParse(parts[1]) ?? DateTime.now(),
              filters: const {}, // TODO: implement proper JSON parsing
            );
          }
          return null;
        })
        .whereType<SearchEntry>()
        .toList();

    state = history;
  }

  void addEntry(SearchEntry entry) {
    final updated = [entry, ...state.where((e) => e.query != entry.query)];
    state = updated.take(20).toList(); // Keep last 20 entries

    _saveHistory();
  }

  void _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = state
        .map((e) => '${e.query}|${e.timestamp.toIso8601String()}')
        .toList();
    await prefs.setStringList('search_history', historyJson);
  }

  void clearHistory() {
    state = [];
    _saveHistory();
  }
}

// =============================================================================
// SEARCH INSIGHTS PROVIDER
// =============================================================================

class SearchInsights {
  final List<String> popularQueries;
  final List<String> topCategories;
  final Map<String, int> queryFrequency;

  const SearchInsights({
    required this.popularQueries,
    required this.topCategories,
    required this.queryFrequency,
  });
}

final searchInsightsProvider = Provider<SearchInsights>((ref) {
  final history = ref.watch(searchHistoryProvider);

  // Derive insights from search history
  final queryFrequency = <String, int>{};
  final categoryFrequency = <String, int>{};

  for (final entry in history) {
    queryFrequency[entry.query] = (queryFrequency[entry.query] ?? 0) + 1;

    // Extract categories from filters if available
    final categories = entry.filters['categories'] as List<String>? ?? [];
    for (final category in categories) {
      categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
    }
  }

  final popularQueries = queryFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value))
    ..take(10);

  final topCategories = categoryFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value))
    ..take(10);

  return SearchInsights(
    popularQueries: popularQueries.map((e) => e.key).toList(),
    topCategories: topCategories.map((e) => e.key).toList(),
    queryFrequency: queryFrequency,
  );
});

// =============================================================================
// PRODUCTS PROVIDERS
// =============================================================================

class ProductSummaryPage {
  final List<Product> products;
  final bool hasMore;
  final String? nextPageToken;

  const ProductSummaryPage({
    required this.products,
    required this.hasMore,
    this.nextPageToken,
  });
}

final productsProvider = AsyncNotifierProvider.family<ProductsStore,
    ProductSummaryPage, Map<String, dynamic>>(ProductsStore.new);

class ProductsStore
    extends FamilyAsyncNotifier<ProductSummaryPage, Map<String, dynamic>> {
  @override
  Future<ProductSummaryPage> build(Map<String, dynamic> filters) async {
    return _loadProducts(filters);
  }

  Future<ProductSummaryPage> _loadProducts(Map<String, dynamic> filters) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allProducts = demoDataService.allProducts;

    // Apply filters
    List<Product> filteredProducts = allProducts;

    if (filters['category'] != null) {
      filteredProducts = filteredProducts
          .where((p) => p.category == filters['category'])
          .toList();
    }

    // Note: Product model doesn't have sellerId in current implementation
    // This is a placeholder for future seller filtering

    // Simple pagination
    const pageSize = 20;
    final startIndex = (filters['page'] as int? ?? 0) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, filteredProducts.length);

    final products = filteredProducts.sublist(startIndex, endIndex);
    final hasMore = endIndex < filteredProducts.length;

    return ProductSummaryPage(
      products: products,
      hasMore: hasMore,
      nextPageToken:
          hasMore ? 'page_${(filters['page'] as int? ?? 0) + 1}' : null,
    );
  }
}

final productDetailProvider =
    AsyncNotifierProvider.family<ProductDetailStore, Product, String>(
        ProductDetailStore.new);

class ProductDetailStore extends FamilyAsyncNotifier<Product, String> {
  @override
  Future<Product> build(String productId) async {
    return _loadProduct(productId);
  }

  Future<Product> _loadProduct(String productId) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allProducts = demoDataService.allProducts;

    final product = allProducts.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      throw Exception('Product not found: $productId');
    }

    return product;
  }
}

// =============================================================================
// MESSAGING PROVIDERS
// =============================================================================

final threadsProvider =
    AsyncNotifierProvider<ThreadsStore, List<ThreadSummary>>(ThreadsStore.new);

class ThreadSummary {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? productId;

  const ThreadSummary({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.productId,
  });
}

class ThreadsStore extends AsyncNotifier<List<ThreadSummary>> {
  @override
  Future<List<ThreadSummary>> build() async {
    return _loadThreads();
  }

  Future<List<ThreadSummary>> _loadThreads() async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final conversations = demoDataService.allConversations;
    final session = ref.read(sessionProvider);

    if (!session.isLoggedIn || session.userId == null) {
      return [];
    }

    // Convert conversations to thread summaries
    final threads = conversations.map((conv) {
      // Note: Conversation model doesn't have participants, content, timestamp, senderId, isRead, productId
      // This is a placeholder implementation
      final otherUserName = 'Other User';
      final lastMessage =
          conv.messages.isNotEmpty ? conv.messages.last.text : null;
      final lastMessageTime =
          conv.messages.isNotEmpty ? conv.messages.last.sentAt : DateTime.now();
      final unreadCount =
          0; // Placeholder - no unread tracking in current model

      return ThreadSummary(
        id: conv.id,
        otherUserId: 'other_user_id',
        otherUserName: otherUserName,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: unreadCount,
        productId: null, // No productId in current Conversation model
      );
    }).toList();

    // Sort by last message time
    threads.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return threads;
  }

  Future<void> ensureThread(String productId, String sellerId) async {
    // Check if thread already exists
    final currentThreads = await future;
    final existingThread =
        currentThreads.where((t) => t.productId == productId).firstOrNull;

    if (existingThread != null) {
      return; // Thread already exists
    }

    // Create new thread (in real app, this would call messaging service)
    // For now, just refresh the threads
    ref.invalidateSelf();
  }
}

final threadMessagesProvider =
    AsyncNotifierProvider.family<ThreadMessagesStore, List<Message>, String>(
        ThreadMessagesStore.new);

class ThreadMessagesStore extends FamilyAsyncNotifier<List<Message>, String> {
  @override
  Future<List<Message>> build(String threadId) async {
    return _loadMessages(threadId);
  }

  Future<List<Message>> _loadMessages(String threadId) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final conversations = demoDataService.allConversations;

    final conversation =
        conversations.where((c) => c.id == threadId).firstOrNull;
    if (conversation == null) {
      return [];
    }

    return conversation.messages;
  }

  Future<void> send(String threadId, Map<String, dynamic> compose) async {
    // In real app, this would call messaging service
    // For now, just refresh the messages
    ref.invalidateSelf();
  }
}

final unreadCountProvider = Provider<int>((ref) {
  final threadsAsync = ref.watch(threadsProvider);
  return threadsAsync.when(
    data: (threads) =>
        threads.fold(0, (sum, thread) => sum + thread.unreadCount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// =============================================================================
// LEADS PROVIDERS
// =============================================================================

class LeadsScopePageKey {
  final String scope; // 'seller', 'buyer', 'admin'
  final String? sellerId; // for seller scope
  final int page;
  final int pageSize;

  const LeadsScopePageKey({
    required this.scope,
    this.sellerId,
    required this.page,
    required this.pageSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadsScopePageKey &&
          runtimeType == other.runtimeType &&
          scope == other.scope &&
          sellerId == other.sellerId &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(scope, sellerId, page, pageSize);
}

class LeadPage {
  final List<Lead> leads;
  final bool hasMore;
  final String? nextPageToken;

  const LeadPage({
    required this.leads,
    required this.hasMore,
    this.nextPageToken,
  });
}

final leadsProvider =
    AsyncNotifierProvider.family<LeadsStore, LeadPage, LeadsScopePageKey>(
        LeadsStore.new);

class LeadsStore extends FamilyAsyncNotifier<LeadPage, LeadsScopePageKey> {
  @override
  Future<LeadPage> build(LeadsScopePageKey key) async {
    return _loadLeads(key);
  }

  Future<LeadPage> _loadLeads(LeadsScopePageKey key) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allLeads = demoDataService.allLeads;

    // Apply scope filtering
    List<Lead> filteredLeads = allLeads;

    switch (key.scope) {
      case 'seller':
        // Note: Lead model doesn't have sellerId in current implementation
        // This is a placeholder for future seller filtering
        break;
      case 'buyer':
        // Note: Lead model doesn't have buyerId in current implementation
        // This is a placeholder for future buyer filtering
        break;
      case 'admin':
        // Admin sees all leads
        break;
    }

    // Apply pagination
    final startIndex = key.page * key.pageSize;
    final endIndex = (startIndex + key.pageSize).clamp(0, filteredLeads.length);

    final leads = filteredLeads.sublist(startIndex, endIndex);
    final hasMore = endIndex < filteredLeads.length;

    return LeadPage(
      leads: leads,
      hasMore: hasMore,
      nextPageToken: hasMore ? 'page_${key.page + 1}' : null,
    );
  }
}

final leadDetailProvider =
    AsyncNotifierProvider.family<LeadDetailStore, Lead, String>(
        LeadDetailStore.new);

class LeadDetailStore extends FamilyAsyncNotifier<Lead, String> {
  @override
  Future<Lead> build(String leadId) async {
    return _loadLead(leadId);
  }

  Future<Lead> _loadLead(String leadId) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allLeads = demoDataService.allLeads;

    final lead = allLeads.where((l) => l.id == leadId).firstOrNull;
    if (lead == null) {
      throw Exception('Lead not found: $leadId');
    }

    return lead;
  }
}

// =============================================================================
// APP SETTINGS PROVIDER
// =============================================================================

class AppSettings {
  final String theme;
  final String language;
  final String? location;
  final double radiusKm;
  final bool notificationsEnabled;

  const AppSettings({
    required this.theme,
    required this.language,
    this.location,
    required this.radiusKm,
    required this.notificationsEnabled,
  });

  AppSettings copyWith({
    String? theme,
    String? language,
    String? location,
    double? radiusKm,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsStore, AppSettings>(AppSettingsStore.new);

class AppSettingsStore extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings(
      theme: 'light',
      language: 'en',
      radiusKm: 25.0,
      notificationsEnabled: true,
    );
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'light';
    final language = prefs.getString('language') ?? 'en';
    final location = prefs.getString('location');
    final radiusKm = prefs.getDouble('radius_km') ?? 25.0;
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    state = AppSettings(
      theme: theme,
      language: language,
      location: location,
      radiusKm: radiusKm,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> updateTheme(String theme) async {
    state = state.copyWith(theme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> updateLocation(String? location, double radiusKm) async {
    state = state.copyWith(location: location, radiusKm: radiusKm);
    final prefs = await SharedPreferences.getInstance();
    if (location != null) {
      await prefs.setString('location', location);
    } else {
      await prefs.remove('location');
    }
    await prefs.setDouble('radius_km', radiusKm);
  }
}
