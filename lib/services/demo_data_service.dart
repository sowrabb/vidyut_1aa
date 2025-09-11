import 'package:flutter/foundation.dart';
import '../features/sell/models.dart';
import '../features/admin/models/hero_section.dart';
import '../features/admin/store/admin_store.dart';
import '../features/messaging/models.dart';
import '../features/categories/categories_page.dart';
import '../features/stateinfo/models/state_info_models.dart';

/// Centralized demo data service for consistent data across all features
class DemoDataService extends ChangeNotifier {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal() {
    _initializeDemoData();
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
  List<Conversation> get allConversations => List.unmodifiable(_allConversations);

  // Users data
  final List<AdminUser> _allUsers = [];
  List<AdminUser> get allUsers => List.unmodifiable(_allUsers);

  // Categories data
  final List<CategoryData> _allCategories = [];
  List<CategoryData> get allCategories => List.unmodifiable(_allCategories);

  // State Info data
  final List<PowerGenerator> _allPowerGenerators = [];
  List<PowerGenerator> get allPowerGenerators => List.unmodifiable(_allPowerGenerators);

  void _initializeDemoData() {
    _seedProducts();
    _seedHeroSections();
    _seedLeads();
    _seedConversations();
    _seedUsers();
    _seedCategories();
    _seedPowerGenerators();
  }

  void _seedProducts() {
    _allProducts.clear();
    _allProducts.addAll([
      // Cables & Wires (5 products)
      Product(
        id: '1',
        title: 'Copper Cable 1.5sqmm',
        brand: 'Finolex',
        category: 'Cables & Wires',
        subtitle: 'PVC | 1.5 sqmm | 1100V',
        description: 'High-quality copper cable suitable for electrical wiring in residential and commercial buildings.',
        images: [
          'assets/demo-images/wires-cables/wire01.jpeg',
          'assets/demo-images/wires-cables/wire02.jpeg',
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
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
        description: 'Durable aluminum wire with XLPE insulation for industrial applications.',
        images: [
          'assets/demo-images/wires-cables/wire06.jpeg',
          'assets/demo-images/wires-cables/wire07.jpeg',
          'assets/demo-images/wires-cables/wire08.jpeg',
          'assets/demo-images/wires-cables/wire09.jpeg',
          'assets/demo-images/wires-cables/wire01.jpeg',
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
        title: 'Multi-Core Cable 4sqmm',
        brand: 'Havells',
        category: 'Cables & Wires',
        subtitle: 'PVC | 4 sqmm | 3 Core',
        description: 'Multi-core copper cable for three-phase electrical installations.',
        images: [
          'assets/demo-images/wires-cables/wire02.jpeg',
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
          'assets/demo-images/wires-cables/wire06.jpeg',
        ],
        price: 799.0,
        moq: 25,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'cores': '3', 'rating': '4 sqmm'},
        rating: 4.5,
      ),
      Product(
        id: '4',
        title: 'Control Cable 1.5sqmm',
        brand: 'RR Kabel',
        category: 'Cables & Wires',
        subtitle: 'FR | 1.5 sqmm | 12 Core',
        description: 'Control cable for automation and control panel wiring.',
        images: [
          'assets/demo-images/wires-cables/wire07.jpeg',
          'assets/demo-images/wires-cables/wire08.jpeg',
          'assets/demo-images/wires-cables/wire09.jpeg',
          'assets/demo-images/wires-cables/wire01.jpeg',
          'assets/demo-images/wires-cables/wire02.jpeg',
        ],
        price: 1299.0,
        moq: 20,
        gstRate: 18.0,
        materials: ['Copper', 'FR'],
        customValues: {'cores': '12', 'application': 'Control'},
        rating: 4.3,
      ),
      Product(
        id: '5',
        title: 'House Wire 2.5sqmm',
        brand: 'KEI',
        category: 'Cables & Wires',
        subtitle: 'PVC | 2.5 sqmm | 1100V',
        description: 'Standard house wiring cable for residential installations.',
        images: [
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
          'assets/demo-images/wires-cables/wire06.jpeg',
          'assets/demo-images/wires-cables/wire07.jpeg',
        ],
        price: 399.0,
        moq: 100,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'color': 'Blue', 'length': '90m'},
        rating: 4.1,
      ),

      // Circuit Breakers (5 products)
      Product(
        id: '6',
        title: 'MCB 32A Single Pole',
        brand: 'Schneider',
        category: 'Circuit Breakers',
        subtitle: 'C Curve | 32A | 1P',
        description: 'Miniature Circuit Breaker for overload and short circuit protection.',
        images: [
          'assets/demo-images/circuit-breakers/cb01.jpeg',
          'assets/demo-images/circuit-breakers/cb02.jpeg',
          'assets/demo-images/circuit-breakers/cb03.jpeg',
          'assets/demo-images/circuit-breakers/cb04.jpeg',
          'assets/demo-images/circuit-breakers/cb05.jpeg',
        ],
        price: 450.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Plastic', 'Copper'],
        customValues: {'rating': '32A', 'curve': 'C', 'poles': '1'},
        rating: 4.6,
      ),
      Product(
        id: '7',
        title: 'RCCB 63A 4 Pole',
        brand: 'Legrand',
        category: 'Circuit Breakers',
        subtitle: '63A | 4P | 30mA',
        description: 'Residual Current Circuit Breaker for earth leakage protection.',
        images: [
          'assets/demo-images/circuit-breakers/cb06.jpeg',
          'assets/demo-images/circuit-breakers/cb07.jpeg',
          'assets/demo-images/circuit-breakers/cb08.jpeg',
          'assets/demo-images/circuit-breakers/cb09.jpeg',
          'assets/demo-images/circuit-breakers/cb10.jpeg',
        ],
        price: 2200.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Plastic', 'Copper'],
        customValues: {'rating': '63A', 'sensitivity': '30mA', 'poles': '4'},
        rating: 4.4,
      ),
      Product(
        id: '8',
        title: 'MCCB 100A 3 Pole',
        brand: 'ABB',
        category: 'Circuit Breakers',
        subtitle: '100A | 3P | 25kA',
        description: 'Molded Case Circuit Breaker for industrial applications.',
        images: [
          'assets/demo-images/circuit-breakers/cb11.jpeg',
          'assets/demo-images/circuit-breakers/cb12.jpeg',
          'assets/demo-images/circuit-breakers/cb13.jpeg',
          'assets/demo-images/circuit-breakers/cb14.jpeg',
          'assets/demo-images/circuit-breakers/cb01.jpeg',
        ],
        price: 3500.0,
        moq: 3,
        gstRate: 18.0,
        materials: ['Plastic', 'Copper'],
        customValues: {'rating': '100A', 'breaking_capacity': '25kA', 'poles': '3'},
        rating: 4.7,
      ),

      // Add more diverse products
      Product(
        id: '9',
        title: '1 HP Single Phase Motor',
        brand: 'Crompton',
        category: 'Motors',
        subtitle: '1 HP | 1440 RPM | Single Phase',
        description: 'Single phase induction motor for general purpose applications.',
        images: [
          'assets/demo-images/motors/motor01.jpeg',
          'assets/demo-images/motors/motor02.jpeg',
          'assets/demo-images/motors/motor03.jpeg',
          'assets/demo-images/motors/motor04.jpeg',
          'assets/demo-images/motors/motor05.jpeg',
        ],
        price: 3200.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Steel', 'Copper', 'Iron'],
        customValues: {'power': '1 HP', 'speed': '1440 RPM', 'phase': 'Single'},
        rating: 4.2,
      ),
      Product(
        id: '10',
        title: 'LED Tube Light 18W',
        brand: 'Philips',
        category: 'Lights',
        subtitle: '18W | 4000K | 1800 Lumen',
        description: 'Energy efficient LED tube light for commercial spaces.',
        images: [
          'assets/demo-images/lights/light01.jpeg',
          'assets/demo-images/lights/light02.jpeg',
          'assets/demo-images/lights/light03.jpeg',
          'assets/demo-images/lights/light04.jpeg',
          'assets/demo-images/lights/light05.jpeg',
        ],
        price: 450.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Aluminum', 'Plastic'],
        customValues: {'wattage': '18W', 'color_temp': '4000K', 'lumen': '1800'},
        rating: 4.3,
      ),
    ]);
  }

  void _seedHeroSections() {
    _heroSections.clear();
    _heroSections.addAll([
      HeroSection(
        id: 'hero_1',
        title: 'First time in India, largest Electricity platform',
        subtitle: 'B2B • D2C • C2C',
        ctaText: null,
        ctaUrl: null,
        priority: 1,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      HeroSection(
        id: 'hero_2',
        title: 'Find the right components fast',
        subtitle: 'Search by brand, spec, materials',
        ctaText: 'Start Searching',
        ctaUrl: '/search',
        priority: 2,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      HeroSection(
        id: 'hero_3',
        title: 'Post RFQs & get quotes',
        subtitle: 'Verified sellers, transparent pricing',
        ctaText: 'Post RFQ',
        ctaUrl: '/rfq',
        priority: 3,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ]);
  }

  void _seedLeads() {
    _allLeads.clear();
    _allLeads.addAll([
      Lead(
        id: 'L1',
        title: 'EPC Contractor — Metro Depot Wiring',
        industry: 'Construction',
        materials: ['Copper', 'PVC'],
        city: 'Hyderabad',
        state: 'Telangana',
        qty: 1200,
        turnoverCr: 85,
        needBy: DateTime.now().add(const Duration(days: 30)),
        status: 'New',
        about: 'Large wiring scope for metro depot.',
      ),
      Lead(
        id: 'L2',
        title: 'MEP Vendor — IT Park',
        industry: 'MEP',
        materials: ['Aluminium', 'XLPE'],
        city: 'Bengaluru',
        state: 'Karnataka',
        qty: 800,
        turnoverCr: 120,
        needBy: DateTime.now().add(const Duration(days: 20)),
        status: 'New',
        about: 'Cables & switchgear for IT park.',
      ),
      Lead(
        id: 'L3',
        title: 'Solar EPC — 5MW',
        industry: 'Solar',
        materials: ['Aluminium', 'Steel'],
        city: 'Chennai',
        state: 'Tamil Nadu',
        qty: 2000,
        turnoverCr: 200,
        needBy: DateTime.now().add(const Duration(days: 45)),
        status: 'Active',
        about: 'Solar panel installation project.',
      ),
    ]);
  }

  // Methods to update data and notify listeners
  void updateProduct(Product product) {
    final index = _allProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _allProducts[index] = product;
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    _allProducts.add(product);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _allProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void updateHeroSection(HeroSection heroSection) {
    final index = _heroSections.indexWhere((h) => h.id == heroSection.id);
    if (index != -1) {
      _heroSections[index] = heroSection;
      notifyListeners();
    }
  }

  void addHeroSection(HeroSection heroSection) {
    _heroSections.add(heroSection);
    notifyListeners();
  }

  void removeHeroSection(String heroSectionId) {
    _heroSections.removeWhere((h) => h.id == heroSectionId);
    notifyListeners();
  }

  void addLead(Lead lead) {
    _allLeads.add(lead);
    notifyListeners();
  }

  void updateLead(Lead lead) {
    final index = _allLeads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _allLeads[index] = lead;
      notifyListeners();
    }
  }

  void removeLead(String leadId) {
    _allLeads.removeWhere((l) => l.id == leadId);
    notifyListeners();
  }

  Lead? getLead(String leadId) {
    try {
      return _allLeads.firstWhere((l) => l.id == leadId);
    } catch (e) {
      return null;
    }
  }

  // Reset all demo data
  void resetAllData() {
    _initializeDemoData();
    notifyListeners();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _allProducts.where((p) => p.category == category).toList();
  }

  // Get products by seller/brand
  List<Product> getProductsByBrand(String brand) {
    return _allProducts.where((p) => p.brand == brand).toList();
  }

  // Get active hero sections sorted by priority
  List<HeroSection> getActiveHeroSections() {
    final active = _heroSections.where((h) => h.isActive).toList();
    active.sort((a, b) => a.priority.compareTo(b.priority));
    return active;
  }

  // Conversation CRUD operations
  void addConversation(Conversation conversation) {
    _allConversations.add(conversation);
    notifyListeners();
  }

  void updateConversation(Conversation conversation) {
    final index = _allConversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _allConversations[index] = conversation;
      notifyListeners();
    }
  }

  void removeConversation(String conversationId) {
    _allConversations.removeWhere((c) => c.id == conversationId);
    notifyListeners();
  }

  Conversation? getConversation(String conversationId) {
    try {
      return _allConversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  void _seedConversations() {
    _allConversations.clear();
    _allConversations.addAll([
      Conversation(
        id: 'support',
        title: 'Vidyut Support',
        subtitle: 'We are here to help',
        isPinned: true,
        isSupport: true,
        messages: [
          Message(
            id: 'm1',
            conversationId: 'support',
            senderType: MessageSenderType.support,
            senderName: 'Support',
            text: 'Hello! How can we assist you today?',
            sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      Conversation(
        id: 'c1',
        title: 'Acme Traders',
        subtitle: 'B2B Partner',
        isPinned: false,
        isSupport: false,
        messages: [
          Message(
            id: 'm2',
            conversationId: 'c1',
            senderType: MessageSenderType.other,
            senderName: 'Anita',
            text: 'Can you share the latest price list?',
            sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Message(
            id: 'm3',
            conversationId: 'c1',
            senderType: MessageSenderType.me,
            senderName: 'Me',
            text: 'Sure, attaching here.',
            sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
            attachments: const [
              Attachment(id: 'a1', name: 'price-list.pdf', type: 'pdf')
            ],
          ),
        ],
      ),
      Conversation(
        id: 'c2',
        title: 'ElectroMax Solutions',
        subtitle: 'New Inquiry',
        isPinned: false,
        isSupport: false,
        messages: [
          Message(
            id: 'm4',
            conversationId: 'c2',
            senderType: MessageSenderType.other,
            senderName: 'Rajesh',
            text: 'Hi, I need copper cables for a residential project. What do you have available?',
            sentAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      ),
    ]);
  }

  // User CRUD operations
  void addUser(AdminUser user) {
    _allUsers.add(user);
    notifyListeners();
  }

  void updateUser(AdminUser user) {
    final index = _allUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _allUsers[index] = user;
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    _allUsers.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  AdminUser? getUser(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  void _seedUsers() {
    _allUsers.clear();
    _allUsers.addAll([
      AdminUser(
        id: 'user1',
        name: 'Rajesh Kumar',
        email: 'rajesh@electricalsupplies.com',
        role: 'seller',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isSeller: true,
        plan: 'basic',
        sellerProfile: SellerProfile(
          legalName: 'Rajesh Electrical Supplies',
          gstin: '29ABCDE1234F1Z5',
          address: 'Hyderabad, Telangana',
          materials: ['Copper', 'PVC'],
        ),
      ),
      AdminUser(
        id: 'user2',
        name: 'Priya Sharma',
        email: 'priya@electromax.com',
        role: 'seller',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isSeller: true,
        plan: 'premium',
        sellerProfile: SellerProfile(
          legalName: 'Priya Electromax Solutions',
          gstin: '27FGHIJ5678K2L6',
          address: 'Mumbai, Maharashtra',
          materials: ['Aluminium', 'XLPE'],
        ),
      ),
      AdminUser(
        id: 'user3',
        name: 'Amit Patel',
        email: 'amit@electricalworld.com',
        role: 'buyer',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isSeller: false,
        plan: 'free',
      ),
    ]);
  }

  // Category CRUD operations
  void addCategory(CategoryData category) {
    _allCategories.add(category);
    notifyListeners();
  }

  void updateCategory(CategoryData category) {
    final index = _allCategories.indexWhere((c) => c.name == category.name);
    if (index != -1) {
      _allCategories[index] = category;
      notifyListeners();
    }
  }

  void removeCategory(String categoryName) {
    _allCategories.removeWhere((c) => c.name == categoryName);
    notifyListeners();
  }

  CategoryData? getCategory(String categoryName) {
    try {
      return _allCategories.firstWhere((c) => c.name == categoryName);
    } catch (e) {
      return null;
    }
  }

  void _seedCategories() {
    _allCategories.clear();
    _allCategories.addAll([
      CategoryData(
        name: 'Cables & Wires',
        imageUrl: 'https://picsum.photos/seed/cables/400/300',
        productCount: 1250,
        industries: ['Construction', 'EPC', 'MEP', 'Industrial'],
        materials: ['Copper', 'Aluminium', 'PVC', 'XLPE'],
      ),
      CategoryData(
        name: 'Switchgear',
        imageUrl: 'https://picsum.photos/seed/switchgear/400/300',
        productCount: 890,
        industries: ['Industrial', 'Commercial', 'Infrastructure'],
        materials: ['Steel', 'Iron', 'Plastic'],
      ),
      CategoryData(
        name: 'Transformers',
        imageUrl: 'https://picsum.photos/seed/transformers/400/300',
        productCount: 450,
        industries: ['Industrial', 'Infrastructure', 'EPC'],
        materials: ['Steel', 'Iron', 'Copper'],
      ),
      CategoryData(
        name: 'Meters',
        imageUrl: 'https://picsum.photos/seed/meters/400/300',
        productCount: 320,
        industries: ['Commercial', 'Residential', 'Industrial'],
        materials: ['Plastic', 'Steel', 'Glass'],
      ),
      CategoryData(
        name: 'Solar & Storage',
        imageUrl: 'https://picsum.photos/seed/solar/400/300',
        productCount: 680,
        industries: ['Solar', 'EPC', 'Commercial'],
        materials: ['Steel', 'Aluminium', 'Glass'],
      ),
      CategoryData(
        name: 'Lighting',
        imageUrl: 'https://picsum.photos/seed/lighting/400/300',
        productCount: 2100,
        industries: ['Commercial', 'Residential', 'Infrastructure'],
        materials: ['Plastic', 'Aluminium', 'Glass'],
      ),
      CategoryData(
        name: 'Motors & Drives',
        imageUrl: 'https://picsum.photos/seed/motors/400/300',
        productCount: 750,
        industries: ['Industrial', 'Commercial'],
        materials: ['Steel', 'Iron', 'Copper'],
      ),
      CategoryData(
        name: 'Tools & Safety',
        imageUrl: 'https://picsum.photos/seed/tools/400/300',
        productCount: 1800,
        industries: ['Construction', 'Industrial', 'Commercial'],
        materials: ['Steel', 'Rubber', 'Plastic'],
      ),
      CategoryData(
        name: 'Services',
        imageUrl: 'https://picsum.photos/seed/services/400/300',
        productCount: 150,
        industries: ['Construction', 'EPC', 'MEP'],
        materials: [],
      ),
    ]);
  }

  // Power Generator CRUD operations
  void addPowerGenerator(PowerGenerator generator) {
    _allPowerGenerators.add(generator);
    notifyListeners();
  }

  void updatePowerGenerator(PowerGenerator generator) {
    final index = _allPowerGenerators.indexWhere((g) => g.id == generator.id);
    if (index != -1) {
      _allPowerGenerators[index] = generator;
      notifyListeners();
    }
  }

  void removePowerGenerator(String generatorId) {
    _allPowerGenerators.removeWhere((g) => g.id == generatorId);
    notifyListeners();
  }

  PowerGenerator? getPowerGenerator(String generatorId) {
    try {
      return _allPowerGenerators.firstWhere((g) => g.id == generatorId);
    } catch (e) {
      return null;
    }
  }

  void _seedPowerGenerators() {
    _allPowerGenerators.clear();
    _allPowerGenerators.addAll([
      PowerGenerator(
        id: 'ntpc',
        name: 'NTPC Limited',
        type: 'Thermal',
        capacity: '65,810 MW',
        location: 'New Delhi',
        logo: 'assets/logo.png',
        established: '1975',
        founder: 'Government of India',
        ceo: 'Mr. Gurdeep Singh',
        ceoPhoto: 'assets/logo.png',
        headquarters: 'New Delhi, India',
        phone: '+91-11-2345-6789',
        email: 'info@ntpc.co.in',
        website: 'https://www.ntpc.co.in',
        description: 'NTPC Limited is the largest power utility company in India.',
        employees: '25,000+',
        posts: [
          Post(
            id: '1',
            title: 'New Power Plant Commissioned',
            content: 'Successfully commissioned a new 500MW thermal power plant to meet growing energy demands.',
            author: 'Admin',
            time: '2 hours ago',
            tags: ['Power Generation', 'Infrastructure'],
          ),
        ],
        revenue: '₹1,20,000 Cr',
        totalPlants: 65,
      ),
    ]);
  }
}
