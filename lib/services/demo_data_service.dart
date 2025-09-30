// This file has been replaced by lightweight_demo_data_service.dart
// Please use LightweightDemoDataService instead of DemoDataService

import 'lightweight_demo_data_service.dart';

// Alias for backward compatibility
class DemoDataService {
  static final LightweightDemoDataService _instance =
      LightweightDemoDataService();

  // Delegate all methods to the lightweight service
  static LightweightDemoDataService get instance => _instance;

  // Add any missing methods that might be expected
  static List<dynamic> get allPowerGenerators => _instance.allPowerGenerators;
}
