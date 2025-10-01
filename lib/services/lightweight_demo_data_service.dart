import 'package:flutter/foundation.dart';
import 'dart:async';
import '../features/sell/models.dart';
import '../features/admin/models/hero_section.dart';
import '../features/admin/models/admin_user.dart';
import '../features/auth/models/user_role_models.dart';
import '../features/admin/models/billing_models.dart';
import '../features/admin/models/notification.dart' as admin_notif;
import '../features/messaging/models.dart';
import '../features/categories/categories_page.dart';
import '../features/stateinfo/models/state_info_models.dart';

/// Lightweight demo data service with only essential data
class LightweightDemoDataService extends ChangeNotifier {
  // Remove singleton pattern to allow proper disposal
  bool _isInitialized = false;
  Completer<void>? _initializationCompleter;
  Timer? _initializationTimer;

  bool get isInitialized => _isInitialized;

  /// Future that completes when initialization is done
  Future<void> get initializationFuture =>
      _initializationCompleter?.future ?? Future.value();

  LightweightDemoDataService() {
    _initializeDemoDataAsync();
  }

  Future<void> _initializeDemoDataAsync() async {
    _initializationCompleter = Completer<void>();
    try {
      // For tests and debug mode, use synchronous initialization to avoid timer issues
      if (kDebugMode) {
        _initializeDemoData();
      } else {
        await _seedProductsAsync();
        await _seedHeroSectionsAsync();
        await _seedLeadsAsync();
        await _seedConversationsAsync();
        await _seedCategoriesAsync();
        await _seedAdminUsersAsync();
        await _seedPowerGeneratorsAsync();
        await _seedBillingAsync();
        await _seedNotificationTemplatesAsync();
      }

      _isInitialized = true;
      notifyListeners();
      _initializationCompleter!.complete();
    } catch (e) {
      debugPrint('Demo data initialization failed: $e');
      // Fallback to synchronous initialization
      _initializeDemoData();
      _isInitialized = true;
      notifyListeners();
      _initializationCompleter!.complete();
    }
  }

  void _initializeDemoData() {
    _seedProducts();
    _seedHeroSections();
    _seedLeads();
    _seedConversations();
    _seedCategories();
    _seedAdminUsers();
    _seedPowerGenerators();
    _seedBilling();
    _seedNotificationTemplates();
  }

  // Products data - single source of truth
  final List<Product> _allProducts = [];
  List<Product> get allProducts => List.unmodifiable(_allProducts);

  // Hero sections data
  final List<HeroSection> _heroSections = [];
  List<HeroSection> get heroSections => List.unmodifiable(_heroSections);

  // Leads data
  final List<Lead> _allLeads = [];
  List<Lead> get allLeads => List.unmodifiable(_allLeads);

  // Conversations data
  final List<Conversation> _allConversations = [];
  List<Conversation> get allConversations =>
      List.unmodifiable(_allConversations);

  // Categories data
  final List<CategoryData> _allCategories = [];
  List<CategoryData> get allCategories => List.unmodifiable(_allCategories);

  // Admin users data
  final List<AdminUser> _allUsers = [];
  List<AdminUser> get allUsers => List.unmodifiable(_allUsers);

  // RBAC role permissions
  final Map<String, Set<String>> _rolePermissions = {
    'admin': {
      'users.read',
      'users.write',
      'sellers.read',
      'sellers.write',
      'kyc.review',
      'products.read',
      'products.write',
      'uploads.review',
      'ads.manage',
      'leads.manage',
      'orders.manage',
      'messaging.moderate',
      'cms.manage',
      'billing.manage',
      'search.tune',
      'geo.manage',
      'analytics.view',
      'compliance.manage',
      'system.ops',
      'feature.flags',
      'rbac.manage',
      'audit.read',
      'bulk.ops',
      'notifications.send',
      'export.data',
      'dev.tools',
      'media.manage',
    },
    'seller': {
      'products.read',
      'products.write',
      'orders.manage',
      'leads.manage',
      'messaging.use',
    },
    'buyer': {'products.read', 'messaging.use', 'orders.manage'},
    'marketing': {
      'users.read',
      'users.write',
      'sellers.read',
      'sellers.write',
      'products.read',
      'leads.manage',
      'orders.manage',
      'uploads.review',
      'ads.manage',
    },
    'support': {
      'users.read',
      'messaging.moderate',
      'orders.manage',
      'audit.read',
    },
    'ops': {'system.ops', 'audit.read', 'bulk.ops', 'export.data'},
  };

  Map<String, Set<String>> get rolePermissions => {
        for (final entry in _rolePermissions.entries)
          entry.key: Set<String>.from(entry.value)
      };

  bool hasRole(String role) => _rolePermissions.containsKey(role);

  void replaceRolePermissions(Map<String, Set<String>> permissions) {
    _rolePermissions
      ..clear()
      ..addAll({
        for (final entry in permissions.entries)
          entry.key: Set<String>.from(entry.value)
      });
    notifyListeners();
  }

  bool createRole(String role, {Iterable<String> permissions = const []}) {
    if (_rolePermissions.containsKey(role)) return false;
    _rolePermissions[role] = {...permissions};
    notifyListeners();
    return true;
  }

  bool removeRole(String role) {
    final removed = _rolePermissions.remove(role) != null;
    if (removed) notifyListeners();
    return removed;
  }

  bool grantPermissionToRole(String role, String permission) {
    final set = _rolePermissions.putIfAbsent(role, () => <String>{});
    final added = set.add(permission);
    if (added) notifyListeners();
    return added;
  }

  bool revokePermissionFromRole(String role, String permission) {
    final set = _rolePermissions[role];
    final removed = set != null && set.remove(permission);
    if (removed) notifyListeners();
    return removed;
  }

  bool roleHasPermission(String role, String permission) {
    final set = _rolePermissions[role];
    if (set == null) return false;
    if (set.contains(permission)) return true;
    for (final perm in set) {
      if (perm.endsWith('.*')) {
        final prefix = perm.substring(0, perm.length - 2);
        if (permission.startsWith(prefix)) return true;
      }
    }
    return false;
  }

  // Billing demo data
  final List<Payment> _allPayments = [];
  final List<Invoice> _allInvoices = [];
  BillingStats? _billingSnapshot;
  List<Payment> get allPayments => List.unmodifiable(_allPayments);
  List<Invoice> get allInvoices => List.unmodifiable(_allInvoices);
  BillingStats get billingSnapshot =>
      _billingSnapshot ??
      BillingStats(
        totalRevenue: 0,
        monthlyRevenue: 0,
        pendingPayments: 0,
        overdueAmount: 0,
        totalInvoices: 0,
        pendingInvoices: 0,
        overdueInvoices: 0,
        totalPayments: 0,
        successfulPayments: 0,
        failedPayments: 0,
        averagePaymentValue: 0,
        refundRate: 0,
      );

  // Notification templates (demo library)
  final List<admin_notif.NotificationTemplate> _notificationTemplates = [];
  List<admin_notif.NotificationTemplate> get notificationTemplates =>
      List.unmodifiable(_notificationTemplates);

  // Power generators data
  final List<PowerGenerator> _allPowerGenerators = [];
  List<PowerGenerator> get allPowerGenerators =>
      List.unmodifiable(_allPowerGenerators);

  Future<void> _seedProductsAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedProducts();
  }

  Future<void> _seedBillingAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedBilling();
  }

  Future<void> _seedNotificationTemplatesAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedNotificationTemplates();
  }

  void _seedProducts() {
    _allProducts.clear();
    _allProducts.addAll([
      // Cables & Wires (3 products)
      Product(
        id: '1',
        title: 'Copper Cable 1.5sqmm',
        brand: 'Finolex',
        category: 'Cables & Wires',
        subtitle: 'PVC | 1.5 sqmm | 1100V',
        description:
            'High-quality copper cable suitable for electrical wiring.',
        images: [
          _getFallbackImageUrl('wire01'),
          _getFallbackImageUrl('wire02'),
          _getFallbackImageUrl('wire03'),
        ],
        price: 499.0,
        moq: 100,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'color': 'Red', 'length': '100m'},
        rating: 4.2,
      ),
      Product(
        id: '2',
        title: 'Aluminum Wire 2.5sqmm',
        brand: 'Polycab',
        category: 'Cables & Wires',
        subtitle: 'XLPE | 2.5 sqmm | 1100V',
        description: 'Durable aluminum wire with XLPE insulation.',
        images: [
          _getFallbackImageUrl('wire04'),
          _getFallbackImageUrl('wire05'),
          _getFallbackImageUrl('wire06'),
        ],
        price: 299.0,
        moq: 50,
        gstRate: 18.0,
        materials: ['Aluminum', 'XLPE'],
        customValues: {'color': 'Black', 'length': '50m'},
        rating: 4.0,
      ),
      Product(
        id: '3',
        title: 'Control Cable 4-core',
        brand: 'Havells',
        category: 'Cables & Wires',
        subtitle: 'Control | 4-core | 1.5sqmm',
        description: 'Multi-core control cable for automation systems.',
        images: [
          _getFallbackImageUrl('wire07'),
          _getFallbackImageUrl('wire08'),
          _getFallbackImageUrl('wire09'),
        ],
        price: 899.0,
        moq: 25,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'cores': '4', 'voltage': '1100V'},
        rating: 4.5,
      ),

      // Circuit Breakers (3 products)
      Product(
        id: '4',
        title: 'MCB 16A 2-Pole',
        brand: 'Schneider',
        category: 'Circuit Breakers',
        subtitle: 'Miniature Circuit Breaker | 16A | 2-Pole',
        description: 'High-quality MCB for residential and commercial use.',
        images: [
          _getFallbackImageUrl('breaker01'),
        ],
        price: 1250.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'current': '16A', 'poles': '2'},
        rating: 4.3,
      ),
      Product(
        id: '5',
        title: 'RCCB 30mA 4-Pole',
        brand: 'Legrand',
        category: 'Circuit Breakers',
        subtitle: 'Residual Current Circuit Breaker | 30mA',
        description: 'Safety device for protection against electrical shock.',
        images: [
          _getFallbackImageUrl('breaker02'),
        ],
        price: 2800.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'sensitivity': '30mA', 'poles': '4'},
        rating: 4.4,
      ),

      // Lights (3 products)
      Product(
        id: '6',
        title: 'LED Panel Light 18W',
        brand: 'Philips',
        category: 'Lights',
        subtitle: 'LED Panel | 18W | 4000K',
        description: 'Energy-efficient LED panel light for offices.',
        images: [
          _getFallbackImageUrl('light01'),
        ],
        price: 850.0,
        moq: 20,
        gstRate: 18.0,
        materials: ['LED', 'Aluminum'],
        customValues: {'wattage': '18W', 'color': '4000K'},
        rating: 4.6,
      ),

      // Motors (3 products)
      Product(
        id: '7',
        title: 'Induction Motor 1HP',
        brand: 'Crompton',
        category: 'Motors',
        subtitle: 'Single Phase | 1HP | 1440 RPM',
        description: 'Reliable induction motor for industrial applications.',
        images: [
          _getFallbackImageUrl('motor01'),
        ],
        price: 8500.0,
        moq: 2,
        gstRate: 18.0,
        materials: ['Cast Iron', 'Copper'],
        customValues: {'power': '1HP', 'speed': '1440 RPM'},
        rating: 4.1,
      ),

      // Tools (3 products)
      Product(
        id: '8',
        title: 'Digital Multimeter',
        brand: 'Fluke',
        category: 'Tools',
        subtitle: 'Digital | Auto Range | True RMS',
        description: 'Professional digital multimeter for electrical testing.',
        images: [
          _getFallbackImageUrl('tool01'),
        ],
        price: 4500.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'type': 'Digital', 'accuracy': '0.025%'},
        rating: 4.7,
      ),
    ]);
  }

  Future<void> _seedHeroSectionsAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedHeroSections();
  }

  void _seedHeroSections() {
    _heroSections.clear();
    final now = DateTime.now();
    _heroSections.addAll([
      HeroSection(
        id: '1',
        title: 'First time in India, largest Electricity platform',
        subtitle: 'B2B • D2C • C2C',
        imagePath: 'assets/banner/1.JPG',
        isActive: true,
        priority: 1,
        createdAt: now,
        updatedAt: now,
      ),
      HeroSection(
        id: '2',
        title: 'Find the right components fast',
        subtitle: 'Search by brand, spec, materials',
        imagePath: 'assets/banner/2.webp',
        isActive: true,
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      HeroSection(
        id: '3',
        title: 'Post RFQs & get quotes',
        subtitle: 'Verified sellers, transparent pricing',
        imagePath: 'assets/banner/3.jpg',
        isActive: true,
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  Future<void> _seedLeadsAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedLeads();
  }

  void _seedLeads() {
    _allLeads.clear();
    _allLeads.addAll([
      Lead(
        id: '1',
        title: 'Industrial Cable Requirement',
        industry: 'Construction',
        materials: ['Copper', 'PVC'],
        city: 'Mumbai',
        state: 'Maharashtra',
        qty: 1000,
        turnoverCr: 0.5,
        needBy: DateTime.now().add(const Duration(days: 30)),
        status: 'Open',
        about: 'Need 1000m of 4-core control cable for automation project',
      ),
      Lead(
        id: '2',
        title: 'LED Lighting Solution',
        industry: 'Commercial',
        materials: ['LED', 'Aluminum'],
        city: 'Delhi',
        state: 'Delhi',
        qty: 100,
        turnoverCr: 0.25,
        needBy: DateTime.now().add(const Duration(days: 15)),
        status: 'In Progress',
        about: 'Looking for energy-efficient LED lights for office space',
      ),
    ]);
  }

  Future<void> _seedConversationsAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedConversations();
  }

  void _seedConversations() {
    _allConversations.clear();
    _allConversations.addAll([
      Conversation(
        id: '1',
        title: 'Product Inquiry - Copper Cable',
        subtitle: 'Thank you for your interest in our products.',
        isPinned: false,
        isSupport: false,
        messages: [],
        participants: ['user1', 'user2'],
        updatedAt: DateTime(2024, 1, 15, 10, 30),
      ),
      Conversation(
        id: '2',
        title: 'Product Inquiry - Aluminum Wire',
        subtitle: 'Can you provide more details about the specifications?',
        isPinned: false,
        isSupport: false,
        messages: [],
        participants: ['user1', 'user2'],
        updatedAt: DateTime(2024, 1, 15, 10, 30),
      ),
    ]);
  }

  Future<void> _seedCategoriesAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedCategories();
  }

  void _seedCategories() {
    _allCategories.clear();
    _allCategories.addAll([
      CategoryData(
        name: 'Cables & Wires',
        imageUrl: _getFallbackImageUrl('cat-wires'),
        productCount: 3,
        industries: ['Construction', 'Industrial', 'Commercial'],
        materials: ['Copper', 'Aluminum', 'PVC', 'XLPE'],
      ),
      CategoryData(
        name: 'Circuit Breakers',
        imageUrl: _getFallbackImageUrl('cat-breakers'),
        productCount: 2,
        industries: ['Construction', 'Industrial', 'Commercial'],
        materials: ['Plastic', 'Metal'],
      ),
      CategoryData(
        name: 'Lights',
        imageUrl: _getFallbackImageUrl('cat-lights'),
        productCount: 1,
        industries: ['Commercial', 'Residential'],
        materials: ['LED', 'Aluminum'],
      ),
      CategoryData(
        name: 'Motors',
        imageUrl: _getFallbackImageUrl('cat-motors'),
        productCount: 1,
        industries: ['Industrial', 'EPC'],
        materials: ['Cast Iron', 'Copper'],
      ),
      CategoryData(
        name: 'Tools',
        imageUrl: _getFallbackImageUrl('cat-tools'),
        productCount: 1,
        industries: ['Industrial', 'MEP'],
        materials: ['Plastic', 'Metal'],
      ),
    ]);
  }

  // Product filtering methods
  List<Product> getProductsByCategory(String category) {
    return _allProducts
        .where((product) => product.category == category)
        .toList();
  }

  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _allProducts.where((product) {
      return product.title.toLowerCase().contains(lowercaseQuery) ||
          product.brand.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lead methods
  void addLead(Lead lead) {
    _allLeads.add(lead);
    notifyListeners();
  }

  void updateLeadStatus(String leadId, String status) {
    final leadIndex = _allLeads.indexWhere((lead) => lead.id == leadId);
    if (leadIndex != -1) {
      _allLeads[leadIndex] = _allLeads[leadIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  // Conversation methods
  void addConversation(Conversation conversation) {
    _allConversations.add(conversation);
    notifyListeners();
  }

  void updateConversation(
      String conversationId, Conversation updatedConversation) {
    final convIndex =
        _allConversations.indexWhere((conv) => conv.id == conversationId);
    if (convIndex != -1) {
      _allConversations[convIndex] = updatedConversation;
      notifyListeners();
    }
  }

  Conversation? getConversation(String conversationId) {
    try {
      return _allConversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Admin user methods
  Future<void> _seedAdminUsersAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedAdminUsers();
  }

  void _seedAdminUsers() {
    _allUsers.clear();
    final now = DateTime.now();
    _allUsers.addAll([
      AdminUser(
        id: '1',
        name: 'Admin User',
        email: 'admin@vidyut.com',
        phone: '+91 98765 43210',
        role: UserRole.admin,
        status: UserStatus.active,
        subscription: SubscriptionPlan.enterprise,
        joinDate: now.subtract(const Duration(days: 30)),
        lastActive: now,
        location: 'Mumbai',
        industry: 'Technology',
        materials: const ['Software', 'Hardware'],
        createdAt: now.subtract(const Duration(days: 30)),
        plan: 'enterprise',
        isSeller: false,
        sellerProfile: null,
      ),
      AdminUser(
        id: '2',
        name: 'Moderator User',
        email: 'moderator@vidyut.com',
        phone: '+91 98765 43211',
        role: UserRole.seller,
        status: UserStatus.active,
        subscription: SubscriptionPlan.pro,
        joinDate: now.subtract(const Duration(days: 15)),
        lastActive: now,
        location: 'Delhi',
        industry: 'Electronics',
        materials: const ['Cables', 'Wires'],
        createdAt: now.subtract(const Duration(days: 15)),
        plan: 'premium',
        isSeller: true,
        sellerProfile: SellerProfile(
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
      ),
      // Pending seller
      AdminUser(
        id: '3',
        name: 'Shreya Components',
        email: 'shreya@components.example',
        phone: '+91 90123 45678',
        role: UserRole.seller,
        status: UserStatus.pending,
        subscription: SubscriptionPlan.free,
        joinDate: now.subtract(const Duration(days: 5)),
        lastActive: now.subtract(const Duration(days: 1)),
        location: 'Bengaluru',
        industry: 'Electricals',
        materials: const ['Copper', 'PVC'],
        createdAt: now.subtract(const Duration(days: 5)),
        plan: 'free',
        isSeller: true,
        sellerProfile: SellerProfile(
          companyName: 'Shreya Components LLP',
          gstNumber: '29ABCDE1234F1Z5',
          address: 'HSR Layout',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560102',
          phone: '+91 90123 45678',
          email: 'sales@shreyacomponents.example',
          website: 'https://shreyacomponents.example',
          description: 'Distributor of cables and accessories',
          categories: const ['Cables & Wires'],
          materials: const ['Copper', 'PVC'],
          logoUrl: '',
          isVerified: false,
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
      ),
      // Suspended seller
      AdminUser(
        id: '4',
        name: 'Eastern Electrics',
        email: 'ops@eastern.example',
        phone: '+91 98888 77777',
        role: UserRole.seller,
        status: UserStatus.suspended,
        subscription: SubscriptionPlan.pro,
        joinDate: now.subtract(const Duration(days: 60)),
        lastActive: now.subtract(const Duration(days: 10)),
        location: 'Kolkata',
        industry: 'Industrial',
        materials: const ['Aluminum', 'Steel'],
        createdAt: now.subtract(const Duration(days: 60)),
        plan: 'premium',
        isSeller: true,
        sellerProfile: SellerProfile(
          companyName: 'Eastern Electrics Pvt Ltd',
          gstNumber: '19ABCDE1234F1Z7',
          address: 'Salt Lake',
          city: 'Kolkata',
          state: 'West Bengal',
          pincode: '700091',
          phone: '+91 98888 77777',
          email: 'ops@eastern.example',
          website: 'https://eastern-electrics.example',
          description: 'Industrial electrical components supplier',
          categories: const ['Motors', 'Tools'],
          materials: const ['Aluminum', 'Steel'],
          logoUrl: '',
          isVerified: false,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
      ),
    ]);
  }

  void addUser(AdminUser user) {
    _allUsers.add(user);
    notifyListeners();
  }

  void updateUser(AdminUser user) {
    final userIndex = _allUsers.indexWhere((u) => u.id == user.id);
    if (userIndex != -1) {
      _allUsers[userIndex] = user;
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    _allUsers.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  AdminUser? getUser(String userId) {
    try {
      return _allUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Category management methods
  void addCategory(CategoryData category) {
    _allCategories.add(category);
    notifyListeners();
  }

  void updateCategory(CategoryData category) {
    final categoryIndex =
        _allCategories.indexWhere((c) => c.name == category.name);
    if (categoryIndex != -1) {
      _allCategories[categoryIndex] = category;
      notifyListeners();
    }
  }

  void removeCategory(String categoryName) {
    _allCategories.removeWhere((category) => category.name == categoryName);
    notifyListeners();
  }

  // Hero section management methods
  void addHeroSection(HeroSection heroSection) {
    _heroSections.add(heroSection);
    notifyListeners();
  }

  void updateHeroSection(HeroSection heroSection) {
    final heroIndex = _heroSections.indexWhere((h) => h.id == heroSection.id);
    if (heroIndex != -1) {
      _heroSections[heroIndex] = heroSection;
      notifyListeners();
    }
  }

  void removeHeroSection(String heroId) {
    _heroSections.removeWhere((hero) => hero.id == heroId);
    notifyListeners();
  }

  // Power generator methods
  Future<void> _seedPowerGeneratorsAsync() async {
    // Use a shorter delay for tests to avoid timer issues
    await Future.delayed(const Duration(milliseconds: 1));
    _seedPowerGenerators();
  }

  void _seedPowerGenerators() {
    _allPowerGenerators.clear();
    _allPowerGenerators.addAll([
      const PowerGenerator(
        id: '1',
        name: 'Solar Power Plant',
        type: 'Solar',
        capacity: '100 MW',
        location: 'Rajasthan',
        logo: 'assets/logo.png',
        established: '2020',
        founder: 'John Doe',
        ceo: 'Jane Smith',
        ceoPhoto: 'assets/logo.png',
        headquarters: 'Jaipur',
        phone: '+91 98765 43210',
        email: 'contact@solarplant.com',
        website: 'https://solarplant.com',
        description: 'Large-scale solar power generation facility',
        totalPlants: 5,
        employees: '500',
        revenue: '₹100 Cr',
        posts: [],
      ),
      const PowerGenerator(
        id: '2',
        name: 'Wind Farm',
        type: 'Wind',
        capacity: '50 MW',
        location: 'Tamil Nadu',
        logo: 'assets/logo.png',
        established: '2019',
        founder: 'Mike Johnson',
        ceo: 'Sarah Wilson',
        ceoPhoto: 'assets/logo.png',
        headquarters: 'Chennai',
        phone: '+91 98765 43211',
        email: 'contact@windfarm.com',
        website: 'https://windfarm.com',
        description: 'Wind energy generation facility',
        totalPlants: 3,
        employees: '200',
        revenue: '₹50 Cr',
        posts: [],
      ),
    ]);
  }

  void addPowerGenerator(PowerGenerator generator) {
    _allPowerGenerators.add(generator);
    notifyListeners();
  }

  void updatePowerGenerator(PowerGenerator generator) {
    final generatorIndex =
        _allPowerGenerators.indexWhere((g) => g.id == generator.id);
    if (generatorIndex != -1) {
      _allPowerGenerators[generatorIndex] = generator;
      notifyListeners();
    }
  }

  void removePowerGenerator(String generatorId) {
    _allPowerGenerators.removeWhere((generator) => generator.id == generatorId);
    notifyListeners();
  }

  PowerGenerator? getPowerGenerator(String generatorId) {
    try {
      return _allPowerGenerators
          .firstWhere((generator) => generator.id == generatorId);
    } catch (e) {
      return null;
    }
  }

  void _seedBilling() {
    _allPayments
      ..clear()
      ..addAll([
        Payment(
          id: 'pay_demo_1',
          userId: 'U1001',
          userName: 'John Demo',
          userEmail: 'john.demo@example.com',
          amount: 2500,
          currency: Currency.inr,
          status: PaymentStatus.completed,
          method: PaymentMethod.card,
          transactionId: 'TXN-DEMO-001',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          processedAt: DateTime.now().subtract(const Duration(hours: 26)),
        ),
        Payment(
          id: 'pay_demo_2',
          userId: 'U1002',
          userName: 'Acme Industries',
          userEmail: 'accounts@acme.example',
          amount: 4200,
          currency: Currency.inr,
          status: PaymentStatus.pending,
          method: PaymentMethod.upi,
          transactionId: 'TXN-DEMO-002',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Payment(
          id: 'pay_demo_3',
          userId: 'U1003',
          userName: 'Sunrise Power',
          userEmail: 'finance@sunrise.example',
          amount: 1800,
          currency: Currency.inr,
          status: PaymentStatus.failed,
          method: PaymentMethod.netbanking,
          transactionId: 'TXN-DEMO-003',
          failureReason: 'Insufficient funds',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);

    _allInvoices
      ..clear()
      ..addAll([
        Invoice(
          id: 'inv_demo_1',
          userId: 'U1001',
          userName: 'John Demo',
          userEmail: 'john.demo@example.com',
          invoiceNumber: 'INV-DEMO-001',
          issueDate: DateTime.now().subtract(const Duration(days: 7)),
          dueDate: DateTime.now().add(const Duration(days: 21)),
          subtotal: 2500,
          taxAmount: 450,
          totalAmount: 2950,
          currency: Currency.inr,
          status: InvoiceStatus.sent,
          items: [
            InvoiceItem(
              description: 'Plus Plan Subscription',
              quantity: 1,
              unitPrice: 2500,
              totalPrice: 2500,
              planId: 'plan_plus',
            ),
          ],
          taxes: [
            InvoiceTax(
              type: TaxType.gst,
              name: 'GST',
              rate: 18,
              amount: 450,
            ),
          ],
        ),
        Invoice(
          id: 'inv_demo_2',
          userId: 'U1002',
          userName: 'Acme Industries',
          userEmail: 'accounts@acme.example',
          invoiceNumber: 'INV-DEMO-002',
          issueDate: DateTime.now().subtract(const Duration(days: 30)),
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          subtotal: 4200,
          taxAmount: 756,
          totalAmount: 4956,
          currency: Currency.inr,
          status: InvoiceStatus.overdue,
          items: [
            InvoiceItem(
              description: 'Enterprise Seller Retainer',
              quantity: 1,
              unitPrice: 4200,
              totalPrice: 4200,
              planId: 'plan_enterprise',
            ),
          ],
          taxes: [
            InvoiceTax(
              type: TaxType.gst,
              name: 'GST',
              rate: 18,
              amount: 756,
            ),
          ],
        ),
      ]);

    _billingSnapshot = BillingStats(
      totalRevenue: _allPayments
          .where((payment) => payment.status == PaymentStatus.completed)
          .fold(0.0, (sum, payment) => sum + payment.amount),
      monthlyRevenue: 145000,
      pendingPayments: _allPayments
          .where((payment) => payment.status == PaymentStatus.pending)
          .fold(0.0, (sum, payment) => sum + payment.amount),
      overdueAmount: _allInvoices
          .where((invoice) => invoice.status == InvoiceStatus.overdue)
          .fold(0.0, (sum, invoice) => sum + invoice.totalAmount),
      totalInvoices: _allInvoices.length,
      pendingInvoices: _allInvoices
          .where((invoice) => invoice.status == InvoiceStatus.pending)
          .length,
      overdueInvoices: _allInvoices
          .where((invoice) => invoice.status == InvoiceStatus.overdue)
          .length,
      totalPayments: _allPayments.length,
      successfulPayments: _allPayments
          .where((payment) => payment.status == PaymentStatus.completed)
          .length,
      failedPayments: _allPayments
          .where((payment) => payment.status == PaymentStatus.failed)
          .length,
      averagePaymentValue: _allPayments.isEmpty
          ? 0
          : _allPayments.fold<double>(
                  0, (sum, payment) => sum + payment.amount) /
              _allPayments.length,
      refundRate: 0.02,
    );
  }

  void _seedNotificationTemplates() {
    _notificationTemplates
      ..clear()
      ..addAll([
        const admin_notif.NotificationTemplate(
          id: 'tmpl_welcome',
          name: 'Seller Welcome',
          channel: admin_notif.NotificationChannel.email,
          title: 'Welcome to Vidyut, {{name}}',
          body:
              'Hi {{name}}, your seller account is ready. Start listing your products to reach new buyers!',
        ),
        const admin_notif.NotificationTemplate(
          id: 'tmpl_payment_failed',
          name: 'Payment Failed Alert',
          channel: admin_notif.NotificationChannel.push,
          title: 'Payment attempt unsuccessful',
          body:
              'Hello {{name}}, your recent payment could not be processed. Please update your billing method.',
        ),
        const admin_notif.NotificationTemplate(
          id: 'tmpl_campaign',
          name: 'Campaign Broadcast',
          channel: admin_notif.NotificationChannel.inApp,
          title: 'New procurement campaign is live',
          body:
              'Explore the latest procurement drives tailored for your segment.',
        ),
        const admin_notif.NotificationTemplate(
          id: 'tmpl_sms_otp',
          name: 'Login OTP',
          channel: admin_notif.NotificationChannel.sms,
          title: 'Your OTP is {{code}}',
          body: 'Use {{code}} to verify your login. Do not share.',
        ),
        const admin_notif.NotificationTemplate(
          id: 'tmpl_email_invoice',
          name: 'Invoice Ready',
          channel: admin_notif.NotificationChannel.email,
          title: 'Your invoice {{invoice}} is ready',
          body: 'Download your invoice {{invoice}} totaling {{amount}}.',
        ),
      ]);
  }

  // Product management methods
  void addProduct(Product product) {
    _allProducts.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final productIndex = _allProducts.indexWhere((p) => p.id == product.id);
    if (productIndex != -1) {
      _allProducts[productIndex] = product;
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _allProducts.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  Product? duplicateProduct(String productId) {
    try {
      final original = _allProducts.firstWhere((p) => p.id == productId);
      final copy = original.copyWith(
        id: 'dup_${DateTime.now().millisecondsSinceEpoch}',
        title: '${original.title} (Copy)',
        status: ProductStatus.draft,
        createdAt: DateTime.now(),
      );
      _allProducts.add(copy);
      notifyListeners();
      return copy;
    } catch (e) {
      return null;
    }
  }

  bool softDeleteProduct(String productId) {
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index == -1) return false;
    final current = _allProducts[index];
    _allProducts[index] = current.copyWith(status: ProductStatus.archived);
    notifyListeners();
    return true;
  }

  bool hardDeleteProduct(String productId) {
    final before = _allProducts.length;
    _allProducts.removeWhere((p) => p.id == productId);
    final after = _allProducts.length;
    if (after != before) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void bulkUpdateStatus(Iterable<String> productIds, ProductStatus status) {
    for (final id in productIds) {
      final i = _allProducts.indexWhere((p) => p.id == id);
      if (i != -1) {
        _allProducts[i] = _allProducts[i].copyWith(status: status);
      }
    }
    notifyListeners();
  }

  void bulkDelete(Iterable<String> productIds, {bool hard = false}) {
    if (hard) {
      _allProducts.removeWhere((p) => productIds.contains(p.id));
    } else {
      for (final id in productIds) {
        final i = _allProducts.indexWhere((p) => p.id == id);
        if (i != -1) {
          _allProducts[i] =
              _allProducts[i].copyWith(status: ProductStatus.archived);
        }
      }
    }
    notifyListeners();
  }

  void bulkEdit(
      Iterable<String> productIds, Product Function(Product) transform) {
    for (var i = 0; i < _allProducts.length; i++) {
      final p = _allProducts[i];
      if (productIds.contains(p.id)) {
        _allProducts[i] = transform(p);
      }
    }
    notifyListeners();
  }

  // Lead management methods
  void updateLead(Lead lead) {
    final leadIndex = _allLeads.indexWhere((l) => l.id == lead.id);
    if (leadIndex != -1) {
      _allLeads[leadIndex] = lead;
      notifyListeners();
    }
  }

  // Notification methods for mutations
  void notifyDataChanged() {
    notifyListeners();
  }

  // Batch operations
  void batchUpdate(List<Function> operations) {
    for (final operation in operations) {
      operation();
    }
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    _initializationTimer?.cancel();
    _initializationTimer = null;
    super.dispose();
  }

  // Helper method to get image URL with fallback
  String _getImageUrl(String assetPath, {String? fallbackSeed}) {
    // In production, you might want to check if the asset exists
    // For now, we'll use the asset path as-is
    return assetPath;
  }

  // Helper method to get fallback image URL
  String _getFallbackImageUrl(String seed) {
    return 'https://picsum.photos/seed/$seed/400/300';
  }

  void removeLead(String leadId) {
    _allLeads.removeWhere((lead) => lead.id == leadId);
    notifyListeners();
  }

  Lead? getLead(String leadId) {
    try {
      return _allLeads.firstWhere((lead) => lead.id == leadId);
    } catch (e) {
      return null;
    }
  }
}
