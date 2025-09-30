// Test data setup for E2E tests
// This file contains all the test data and utilities needed for E2E testing

/// Test data setup for E2E tests
class TestDataSetup {
  static const String testUserEmail = 'testuser@vidyut.com';
  static const String testUserPassword = 'TestPassword123!';
  static const String testUserName = 'Test User';
  static const String testUserPhone = '+919876543210';
  static const String testCompany = 'Test Electrical Company';
  static const String testAddress =
      '123 Test Street, Test City, Test State 123456';

  // Test locations
  static const List<Map<String, String>> testLocations = [
    {'city': 'Mumbai', 'state': 'Maharashtra'},
    {'city': 'Delhi', 'state': 'Delhi'},
    {'city': 'Bangalore', 'state': 'Karnataka'},
    {'city': 'Chennai', 'state': 'Tamil Nadu'},
    {'city': 'Hyderabad', 'state': 'Telangana'},
    {'city': 'Kolkata', 'state': 'West Bengal'},
  ];

  // Test search queries
  static const List<String> testSearchQueries = [
    'copper wire',
    'circuit breaker',
    'LED lights',
    'electric motor',
    'electrical tools',
    'cable',
    'switch',
    'transformer',
  ];

  // Test product categories
  static const List<String> testCategories = [
    'Wires & Cables',
    'Circuit Breakers',
    'Lights',
    'Motors',
    'Tools',
    'Switches',
    'Transformers',
    'Generators',
  ];

  // Test materials
  static const List<String> testMaterials = [
    'Copper',
    'Aluminium',
    'PVC',
    'XLPE',
    'Steel',
    'Iron',
    'Plastic',
    'Rubber',
  ];

  /// Create test user data
  static Map<String, dynamic> createTestUser() {
    return {
      'displayName': testUserName,
      'email': testUserEmail,
      'phoneNumber': testUserPhone,
      'company': testCompany,
      'address': testAddress,
      'bio': 'Test user for E2E testing',
      'role': 'buyer',
      'isVerified': true,
    };
  }

  /// Create test product data
  static Map<String, dynamic> createTestProduct() {
    return {
      'id': 'test_product_001',
      'title': 'Test Copper Wire 2.5mm',
      'brand': 'Test Brand',
      'category': 'Wires & Cables',
      'price': 1500.0,
      'description': 'High quality copper wire for electrical applications',
      'materials': ['Copper', 'PVC'],
      'moq': 100,
      'gstRate': 18.0,
      'status': 'available',
      'images': [
        'https://picsum.photos/seed/test_product_001/800/600',
        'https://picsum.photos/seed/test_product_002/800/600',
      ],
    };
  }

  /// Create test seller data
  static Map<String, dynamic> createTestSeller() {
    return {
      'id': 'test_seller_001',
      'name': 'Test Electrical Distributors',
      'email': 'seller@testcompany.com',
      'phone': '+919876543211',
      'company': 'Test Electrical Company',
      'address': '456 Seller Street, Seller City, Seller State 654321',
      'materials': ['Copper', 'Aluminium', 'PVC'],
      'categories': ['Wires & Cables', 'Circuit Breakers'],
      'isVerified': true,
      'rating': 4.5,
      'reviewCount': 127,
    };
  }

  /// Get random test location
  static Map<String, String> getRandomTestLocation() {
    final random = DateTime.now().millisecondsSinceEpoch % testLocations.length;
    return testLocations[random];
  }

  /// Get random test search query
  static String getRandomTestSearchQuery() {
    final random =
        DateTime.now().millisecondsSinceEpoch % testSearchQueries.length;
    return testSearchQueries[random];
  }

  /// Get random test category
  static String getRandomTestCategory() {
    final random =
        DateTime.now().millisecondsSinceEpoch % testCategories.length;
    return testCategories[random];
  }

  /// Get random test material
  static String getRandomTestMaterial() {
    final random = DateTime.now().millisecondsSinceEpoch % testMaterials.length;
    return testMaterials[random];
  }

  /// Create test RFQ data
  static Map<String, dynamic> createTestRFQ() {
    return {
      'id': 'test_rfq_001',
      'productId': 'test_product_001',
      'quantity': 500,
      'specifications': '2.5mm copper wire, PVC insulation',
      'deliveryDate': DateTime.now().add(const Duration(days: 30)),
      'budget': 75000.0,
      'notes': 'Urgent requirement for construction project',
      'status': 'pending',
      'createdAt': DateTime.now(),
    };
  }

  /// Create test message data
  static Map<String, dynamic> createTestMessage() {
    return {
      'id': 'test_message_001',
      'senderId': 'test_user_001',
      'receiverId': 'test_seller_001',
      'content':
          'Hi, I am interested in your copper wire products. Can you provide more details?',
      'timestamp': DateTime.now(),
      'type': 'text',
      'isRead': false,
    };
  }

  /// Create test inquiry data
  static Map<String, dynamic> createTestInquiry() {
    return {
      'id': 'test_inquiry_001',
      'productId': 'test_product_001',
      'sellerId': 'test_seller_001',
      'buyerId': 'test_user_001',
      'message':
          'I need 500 meters of 2.5mm copper wire. What is your best price?',
      'quantity': 500,
      'expectedDelivery': DateTime.now().add(const Duration(days: 15)),
      'status': 'pending',
      'createdAt': DateTime.now(),
    };
  }

  /// Create test saved product data
  static Map<String, dynamic> createTestSavedProduct() {
    return {
      'id': 'test_saved_001',
      'userId': 'test_user_001',
      'productId': 'test_product_001',
      'savedAt': DateTime.now(),
      'notes': 'Good quality wire for project',
    };
  }

  /// Create test profile completion data
  static Map<String, dynamic> createTestProfileCompletion() {
    return {
      'userId': 'test_user_001',
      'completionPercentage': 100,
      'completedFields': [
        'displayName',
        'email',
        'phoneNumber',
        'company',
        'address',
        'bio',
      ],
      'completedAt': DateTime.now(),
    };
  }

  /// Create test onboarding progress data
  static Map<String, dynamic> createTestOnboardingProgress() {
    return {
      'userId': 'test_user_001',
      'steps': [
        {
          'step': 'app_launch',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'location_selection',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'browse_categories',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'search_products',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'view_product_details',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'contact_seller',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'create_account',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'complete_profile',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'save_products',
          'completed': true,
          'completedAt': DateTime.now()
        },
        {
          'step': 'make_purchase_inquiry',
          'completed': true,
          'completedAt': DateTime.now()
        },
      ],
      'currentStep': 'make_purchase_inquiry',
      'isCompleted': true,
      'completedAt': DateTime.now(),
    };
  }

  /// Create test error scenarios
  static Map<String, dynamic> createTestErrorScenario() {
    return {
      'networkError': 'No internet connection',
      'serverError': 'Server temporarily unavailable',
      'validationError': 'Invalid email format',
      'authError': 'Authentication failed',
      'permissionError': 'Location permission denied',
    };
  }

  /// Create test performance metrics
  static Map<String, dynamic> createTestPerformanceMetrics() {
    return {
      'appLaunchTime': 2.5, // seconds
      'homePageLoadTime': 1.8, // seconds
      'searchResponseTime': 0.8, // seconds
      'productDetailLoadTime': 1.2, // seconds
      'locationSelectionTime': 1.5, // seconds
      'profileCompletionTime': 3.2, // seconds
      'totalOnboardingTime': 45.6, // seconds
    };
  }

  /// Create test accessibility data
  static Map<String, dynamic> createTestAccessibilityData() {
    return {
      'screenReaderEnabled': true,
      'highContrastEnabled': false,
      'fontScale': 1.0,
      'colorBlindMode': 'none',
      'reducedMotion': false,
    };
  }

  /// Create test device information
  static Map<String, dynamic> createTestDeviceInfo() {
    return {
      'platform': 'android',
      'version': '13',
      'model': 'Pixel 6',
      'screenSize': '6.4 inches',
      'resolution': '1080x2400',
      'density': 411.0,
    };
  }

  /// Create test environment configuration
  static Map<String, dynamic> createTestEnvironmentConfig() {
    return {
      'environment': 'test',
      'apiBaseUrl': 'https://api-test.vidyut.com',
      'firebaseProjectId': 'vidyut-test',
      'enableAnalytics': false,
      'enableCrashReporting': false,
      'logLevel': 'debug',
    };
  }

  /// Create test user journey data
  static Map<String, dynamic> createTestUserJourney() {
    return {
      'journeyId': 'test_journey_001',
      'userId': 'test_user_001',
      'startTime': DateTime.now(),
      'endTime': DateTime.now().add(const Duration(minutes: 10)),
      'steps': [
        {
          'step': 'app_launch',
          'timestamp': DateTime.now(),
          'duration': 2.5,
          'success': true,
        },
        {
          'step': 'location_selection',
          'timestamp': DateTime.now().add(const Duration(seconds: 30)),
          'duration': 15.2,
          'success': true,
        },
        {
          'step': 'browse_categories',
          'timestamp': DateTime.now().add(const Duration(minutes: 1)),
          'duration': 45.8,
          'success': true,
        },
        {
          'step': 'search_products',
          'timestamp': DateTime.now().add(const Duration(minutes: 2)),
          'duration': 23.4,
          'success': true,
        },
        {
          'step': 'view_product_details',
          'timestamp': DateTime.now().add(const Duration(minutes: 3)),
          'duration': 18.7,
          'success': true,
        },
        {
          'step': 'contact_seller',
          'timestamp': DateTime.now().add(const Duration(minutes: 4)),
          'duration': 12.3,
          'success': true,
        },
        {
          'step': 'create_account',
          'timestamp': DateTime.now().add(const Duration(minutes: 5)),
          'duration': 67.8,
          'success': true,
        },
        {
          'step': 'complete_profile',
          'timestamp': DateTime.now().add(const Duration(minutes: 6)),
          'duration': 89.2,
          'success': true,
        },
        {
          'step': 'save_products',
          'timestamp': DateTime.now().add(const Duration(minutes: 8)),
          'duration': 8.9,
          'success': true,
        },
        {
          'step': 'make_purchase_inquiry',
          'timestamp': DateTime.now().add(const Duration(minutes: 9)),
          'duration': 34.6,
          'success': true,
        },
      ],
      'totalDuration': 318.4, // seconds
      'successRate': 100.0,
      'completionRate': 100.0,
    };
  }
}
