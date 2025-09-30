import 'package:flutter/foundation.dart';
import '../models.dart';
import '../../../services/lightweight_demo_data_service.dart';

class SellerStore extends ChangeNotifier {
  final LightweightDemoDataService _demoDataService;
  List<CustomFieldDef> _profileFields = [];
  String _bannerUrl = '';
  List<String> _profileMaterials = [];
  List<AdCampaign> _ads = [];

  // Contact information
  String _primaryPhone = '';
  String _primaryEmail = '';
  String _website = '';
  List<String> _additionalPhones = [];
  List<String> _additionalEmails = [];

  // Analytics (demo, in-memory)
  int _profileViews = 0;
  int _sellerContactCalls = 0;
  int _sellerContactWhatsapps = 0;

  // Subscription plan
  String _currentPlan = 'free'; // free, plus, pro
  final Map<String, int> _productViews = <String, int>{};
  final Map<String, int> _productContactCalls = <String, int>{};
  final Map<String, int> _productContactWhatsapps = <String, int>{};

  // Product performance tracking
  final Map<String, int> _productClicks = <String, int>{};
  final Map<String, DateTime> _productLastViewed = <String, DateTime>{};

  // Getters - delegate to DemoDataService for products and leads
  List<Product> get products => _demoDataService.allProducts;
  List<CustomFieldDef> get profileFields => List.unmodifiable(_profileFields);
  List<Lead> get leads => _demoDataService.allLeads;
  String get bannerUrl => _bannerUrl;
  List<String> get profileMaterials => List.unmodifiable(_profileMaterials);
  List<AdCampaign> get ads => List.unmodifiable(_ads);

  // Contact information getters
  String get primaryPhone => _primaryPhone;
  String get primaryEmail => _primaryEmail;
  String get website => _website;
  List<String> get additionalPhones => List.unmodifiable(_additionalPhones);
  List<String> get additionalEmails => List.unmodifiable(_additionalEmails);

  // Analytics getters
  int get profileViews => _profileViews;
  int get sellerContactCalls => _sellerContactCalls;
  int get sellerContactWhatsapps => _sellerContactWhatsapps;
  int get totalSellerContacts => _sellerContactCalls + _sellerContactWhatsapps;

  // Subscription plan getters
  String get currentPlan => _currentPlan;
  bool get isFreePlan => _currentPlan == 'free';
  bool get isPlusPlan => _currentPlan == 'plus';
  bool get isProPlan => _currentPlan == 'pro';

  // Subscription plan limits
  int get maxProducts {
    switch (_currentPlan) {
      case 'free':
        return 5;
      case 'plus':
        return 25;
      case 'pro':
        return 100;
      default:
        return 5;
    }
  }

  int get maxAds {
    switch (_currentPlan) {
      case 'free':
        return 1;
      case 'plus':
        return 5;
      case 'pro':
        return 20;
      default:
        return 1;
    }
  }

  bool get hasAnalytics {
    return _currentPlan != 'free';
  }

  bool get hasAdvancedFeatures {
    return _currentPlan == 'pro';
  }

  int productViewsOf(String productId) => _productViews[productId] ?? 0;
  int productContactCallsOf(String productId) =>
      _productContactCalls[productId] ?? 0;
  int productContactWhatsappsOf(String productId) =>
      _productContactWhatsapps[productId] ?? 0;
  int productClicksOf(String productId) => _productClicks[productId] ?? 0;
  DateTime? productLastViewedOf(String productId) =>
      _productLastViewed[productId];

  int get totalProductViews => _productViews.values.fold(0, (a, b) => a + b);
  int get totalProductClicks => _productClicks.values.fold(0, (a, b) => a + b);
  int get totalProductContacts =>
      _productContactCalls.values.fold(0, (a, b) => a + b) +
      _productContactWhatsapps.values.fold(0, (a, b) => a + b);
  List<Product> get topViewedProducts {
    final byViews = [...products];
    byViews
        .sort((a, b) => (productViewsOf(b.id)).compareTo(productViewsOf(a.id)));
    return byViews.take(10).toList();
  }

  List<Product> get topClickedProducts {
    final byClicks = [...products];
    byClicks.sort(
        (a, b) => (productClicksOf(b.id)).compareTo(productClicksOf(a.id)));
    return byClicks.take(10).toList();
  }

  List<Product> get topContactedProducts {
    final byContacts = [...products];
    byContacts.sort((a, b) =>
        (productContactCallsOf(b.id) + productContactWhatsappsOf(b.id))
            .compareTo(
                productContactCallsOf(a.id) + productContactWhatsappsOf(a.id)));
    return byContacts.take(10).toList();
  }

  // Performance metrics
  double getProductClickThroughRate(String productId) {
    final views = productViewsOf(productId);
    if (views == 0) return 0.0;
    return productClicksOf(productId) / views;
  }

  double getProductContactRate(String productId) {
    final views = productViewsOf(productId);
    if (views == 0) return 0.0;
    return (productContactCallsOf(productId) +
            productContactWhatsappsOf(productId)) /
        views;
  }

  double get overallClickThroughRate {
    final totalViews = totalProductViews;
    if (totalViews == 0) return 0.0;
    return totalProductClicks / totalViews;
  }

  double get overallContactRate {
    final totalViews = totalProductViews;
    if (totalViews == 0) return 0.0;
    return totalProductContacts / totalViews;
  }

  // Performance metrics (simple, demo-based)
  double get profileToContactRate {
    if (_profileViews == 0) return 0.0;
    return totalSellerContacts / _profileViews;
  }

  double get productViewToContactRate {
    final views = totalProductViews;
    if (views == 0) return 0.0;
    return totalProductContacts / views;
  }

  // Marketplace metrics (no revenue tracking for marketplace)
  int get totalMarketplaceInteractions =>
      totalProductViews + totalProductClicks + totalProductContacts;

  // Product performance report (CSV) - marketplace analytics
  Future<String> generateProductPerformanceCsv() async {
    final buffer = StringBuffer();
    buffer.writeln('Product ID,Title,Views,Clicks,Contact Rate,Last Viewed');
    for (final p in products) {
      final views = productViewsOf(p.id);
      final clicks = productClicksOf(p.id);
      final contactRate = getProductContactRate(p.id);
      final lastViewed = productLastViewedOf(p.id);
      buffer.writeln(
          '${p.id},"${p.title}",$views,$clicks,${(contactRate * 100).toStringAsFixed(1)}%,${lastViewed?.toString().split(' ')[0] ?? 'Never'}');
    }
    buffer.writeln(',,');
    buffer.writeln('Totals,');
    buffer.writeln('Total Views,$totalProductViews');
    buffer.writeln('Total Clicks,$totalProductClicks');
    buffer.writeln('Total Contacts,$totalProductContacts');
    buffer.writeln(
        'Overall CTR,${(overallClickThroughRate * 100).toStringAsFixed(1)}%');
    buffer.writeln(
        'Overall Contact Rate,${(overallContactRate * 100).toStringAsFixed(1)}%');
    return buffer.toString();
  }

  SellerStore(this._demoDataService) {
    _seedDemoData();

    // Listen to demo data changes
    _demoDataService.addListener(_onDemoDataChanged);
  }

  @override
  void dispose() {
    _demoDataService.removeListener(_onDemoDataChanged);
    super.dispose();
  }

  void _onDemoDataChanged() {
    notifyListeners();
  }

  // Banner management
  void setBannerUrl(String url) {
    _bannerUrl = url;
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  void setProfileMaterials(List<String> materials) {
    _profileMaterials = List.of(materials);
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  // Contact information management
  void setPrimaryPhone(String phone) {
    _primaryPhone = phone;
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  void setPrimaryEmail(String email) {
    _primaryEmail = email;
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  void setWebsite(String website) {
    _website = website;
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  void setAdditionalPhones(List<String> phones) {
    _additionalPhones = List.of(phones);
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  void setAdditionalEmails(List<String> emails) {
    _additionalEmails = List.of(emails);
    notifyListeners();
    // Pending(firebase): sync to backend
  }

  // Ads management (max 3 campaigns)
  void upsertAd(AdCampaign ad) {
    final i = _ads.indexWhere((a) => a.id == ad.id);
    if (i == -1) {
      if (_ads.length >= 3) return; // cap at 3
      _ads.add(ad);
    } else {
      _ads[i] = ad;
    }
    notifyListeners();
  }

  void deleteAd(String id) {
    _ads.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // Analytics mutators
  void incrementProfileView() {
    _profileViews += 1;
    notifyListeners();
  }

  void recordSellerContactCall() {
    _sellerContactCalls += 1;
    notifyListeners();
  }

  void recordSellerContactWhatsapp() {
    _sellerContactWhatsapps += 1;
    notifyListeners();
  }

  void recordProductView(String productId) {
    _productViews[productId] = (_productViews[productId] ?? 0) + 1;
    _productLastViewed[productId] = DateTime.now();
    notifyListeners();
  }

  void recordProductContactCall(String productId) {
    _productContactCalls[productId] =
        (_productContactCalls[productId] ?? 0) + 1;
    notifyListeners();
  }

  void recordProductContactWhatsapp(String productId) {
    _productContactWhatsapps[productId] =
        (_productContactWhatsapps[productId] ?? 0) + 1;
    notifyListeners();
  }

  void recordProductClick(String productId) {
    _productClicks[productId] = (_productClicks[productId] ?? 0) + 1;
    notifyListeners();
  }

  void _seedDemoData() {
    // Products and leads are now managed by DemoDataService
    // Only seed seller-specific data here

    // Seed demo profile fields
    _profileFields = const [
      CustomFieldDef(
        id: 'business_type',
        label: 'Business Type',
        type: FieldType.dropdown,
        options: ['Manufacturer', 'Distributor', 'Retailer', 'Wholesaler'],
      ),
      CustomFieldDef(
        id: 'certification',
        label: 'ISO Certification',
        type: FieldType.boolean,
      ),
      CustomFieldDef(
        id: 'established_year',
        label: 'Established Year',
        type: FieldType.number,
      ),
    ];

    // Seed demo profile materials
    _profileMaterials = const ['Copper', 'PVC'];

    // Seed demo contact information
    _primaryPhone = '+91 98765 43210';
    _primaryEmail = 'contact@electricalsupplies.com';
    _website = 'https://www.electricalsupplies.com';
    _additionalPhones = ['+91 98765 43211', '+91 98765 43212'];
    _additionalEmails = [
      'sales@electricalsupplies.com',
      'support@electricalsupplies.com'
    ];

    // Seed demo ads
    _ads = [
      AdCampaign(id: 'ad1', type: AdType.search, term: 'copper', slot: 2),
      AdCampaign(
          id: 'ad2', type: AdType.category, term: 'Cables & Wires', slot: 3),
    ];

    // Seed demo product performance data
    _seedDemoProductPerformance();
  }

  // Product CRUD - delegate to DemoDataService
  void addProduct(Product product) {
    _demoDataService.addProduct(product);
    // Demo data service will notify listeners, which will trigger our _onDemoDataChanged
  }

  void updateProduct(Product product) {
    _demoDataService.updateProduct(product);
    // Demo data service will notify listeners, which will trigger our _onDemoDataChanged
  }

  void deleteProduct(String productId) {
    _demoDataService.removeProduct(productId);
    // Demo data service will notify listeners, which will trigger our _onDemoDataChanged
  }

  Product? duplicateProduct(String productId) {
    return _demoDataService.duplicateProduct(productId);
  }

  bool softDeleteProduct(String productId) {
    return _demoDataService.softDeleteProduct(productId);
  }

  bool hardDeleteProduct(String productId) {
    return _demoDataService.hardDeleteProduct(productId);
  }

  void bulkSetStatus(Iterable<String> productIds, ProductStatus status) {
    _demoDataService.bulkUpdateStatus(productIds, status);
  }

  void bulkDelete(Iterable<String> productIds, {bool hard = false}) {
    _demoDataService.bulkDelete(productIds, hard: hard);
  }

  void bulkEdit(
      Iterable<String> productIds, Product Function(Product) transform) {
    _demoDataService.bulkEdit(productIds, transform);
  }

  Product? getProduct(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Profile Fields CRUD
  void addProfileField(CustomFieldDef field) {
    _profileFields.add(field);
    notifyListeners();
    // Pending(firebase): sync to Firestore
  }

  void updateProfileField(CustomFieldDef field) {
    final index = _profileFields.indexWhere((f) => f.id == field.id);
    if (index != -1) {
      _profileFields[index] = field;
      notifyListeners();
      // Pending(firebase): sync to Firestore
    }
  }

  void deleteProfileField(String fieldId) {
    _profileFields.removeWhere((f) => f.id == fieldId);
    notifyListeners();
    // Pending(firebase): sync to Firestore
  }

  // Profile data management methods
  Future<void> saveProfileData({
    required String legalName,
    required String gstin,
    required String phone,
    required String email,
    required String address,
    required String website,
    String? bannerUrl,
    List<String>? materials,
    List<CustomFieldDef>? customFields,
  }) async {
    // Update profile materials if provided
    if (materials != null) {
      setProfileMaterials(materials);
    }

    // Update custom fields if provided
    if (customFields != null) {
      _profileFields = List.of(customFields);
    }

    // For demo purposes, we'll just store the data in memory
    // In a real app, this would save to a backend service
    _profileData = {
      'legalName': legalName,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'bannerUrl': bannerUrl,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    notifyListeners();
  }

  Map<String, dynamic> _profileData = {};

  Map<String, dynamic> get profileData => Map.unmodifiable(_profileData);

  Future<void> loadProfileData() async {
    // For demo purposes, load from memory
    // In a real app, this would load from a backend service
    if (_profileData.isEmpty) {
      _profileData = {
        'legalName': '',
        'gstin': '',
        'phone': '',
        'email': '',
        'address': '',
        'website': '',
        'bannerUrl': '',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
    notifyListeners();
  }

  // Lead management - delegate to DemoDataService
  void updateLead(Lead lead) {
    _demoDataService.updateLead(lead);
  }

  Future<void> createLead(Lead lead) async {
    _demoDataService.addLead(lead);
  }

  Future<void> deleteLead(String leadId) async {
    _demoDataService.removeLead(leadId);
  }

  Lead? getLead(String leadId) {
    return _demoDataService.getLead(leadId);
  }

  List<Lead> get allLeads => _demoDataService.allLeads;

  // Lead interaction tracking
  void recordLeadView(String leadId) {
    // Track lead views for analytics
    // In a real app, this would be sent to analytics service
  }

  void recordLeadContact(String leadId, String contactMethod) {
    // Track lead contact attempts (call, email, quote request)
    // In a real app, this would be sent to analytics service
  }

  void addLead(Lead lead) {
    _demoDataService.addLead(lead);
  }

  // Subscription plan management
  void updateSubscriptionPlan(String plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  bool canAddProduct() {
    return products.length < maxProducts;
  }

  bool canAddAd() {
    return ads.length < maxAds;
  }

  String getSubscriptionStatus() {
    return 'Current Plan: ${_currentPlan.toUpperCase()}';
  }

  Map<String, dynamic> getSubscriptionLimits() {
    return {
      'products': '${products.length}/$maxProducts',
      'ads': '${ads.length}/$maxAds',
      'analytics': hasAnalytics ? 'Enabled' : 'Disabled',
      'advancedFeatures': hasAdvancedFeatures ? 'Enabled' : 'Disabled',
    };
  }

  void _seedDemoProductPerformance() {
    // Seed demo performance data for products
    final now = DateTime.now();

    // Product 1 - High engagement
    _productViews['1'] = 45;
    _productClicks['1'] = 12;
    _productContactCalls['1'] = 2;
    _productContactWhatsapps['1'] = 1;
    _productLastViewed['1'] = now.subtract(const Duration(hours: 2));

    // Product 2 - Medium engagement
    _productViews['2'] = 28;
    _productClicks['2'] = 8;
    _productContactCalls['2'] = 1;
    _productContactWhatsapps['2'] = 1;
    _productLastViewed['2'] = now.subtract(const Duration(hours: 5));

    // Product 3 - Low engagement
    _productViews['3'] = 15;
    _productClicks['3'] = 3;
    _productContactCalls['3'] = 0;
    _productContactWhatsapps['3'] = 1;
    _productLastViewed['3'] = now.subtract(const Duration(days: 1));

    // Product 4 - Good engagement
    _productViews['4'] = 32;
    _productClicks['4'] = 9;
    _productContactCalls['4'] = 1;
    _productContactWhatsapps['4'] = 0;
    _productLastViewed['4'] = now.subtract(const Duration(hours: 3));

    // Product 5 - Average engagement
    _productViews['5'] = 22;
    _productClicks['5'] = 6;
    _productContactCalls['5'] = 0;
    _productContactWhatsapps['5'] = 1;
    _productLastViewed['5'] = now.subtract(const Duration(hours: 8));

    // Product 6 - High views, low contact
    _productViews['6'] = 38;
    _productClicks['6'] = 5;
    _productContactCalls['6'] = 0;
    _productContactWhatsapps['6'] = 0;
    _productLastViewed['6'] = now.subtract(const Duration(hours: 1));

    // Product 7 - Low views, high contact
    _productViews['7'] = 12;
    _productClicks['7'] = 8;
    _productContactCalls['7'] = 2;
    _productContactWhatsapps['7'] = 1;
    _productLastViewed['7'] = now.subtract(const Duration(hours: 4));

    // Product 8 - New product
    _productViews['8'] = 8;
    _productClicks['8'] = 2;
    _productContactCalls['8'] = 0;
    _productContactWhatsapps['8'] = 0;
    _productLastViewed['8'] = now.subtract(const Duration(hours: 6));
  }
}
