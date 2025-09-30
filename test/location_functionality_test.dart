import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/location_service.dart';
import 'package:vidyut/services/location_aware_filter_service.dart';
import 'package:vidyut/features/sell/models.dart';

void main() {
  group('Location Functionality Tests', () {
    late SharedPreferences prefs;
    late LocationService locationService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() {
      locationService = LocationService(prefs);
    });

    tearDown(() {
      locationService.dispose();
    });

    group('GPS Location Detection', () {
      testWidgets('Location permission handling works correctly',
          (tester) async {
        // Test permission status checking
        await locationService.requestPermission();
        expect(locationService.permissionStatus, isNotNull);
        expect(locationService.permissionStatus!.isGranted, isA<bool>());
      });

      testWidgets('Automatic location detection can be enabled/disabled',
          (tester) async {
        // Test auto location enable/disable
        await locationService.setAutoLocationEnabled(true);
        expect(locationService.isAutoLocationEnabled, isTrue);

        await locationService.setAutoLocationEnabled(false);
        expect(locationService.isAutoLocationEnabled, isFalse);
      });

      testWidgets('Location tracking can be started and stopped',
          (tester) async {
        // Test location tracking controls
        await locationService.startEnhancedLocationTracking();
        expect(locationService.isLoading,
            isFalse); // Should handle gracefully without permission

        locationService.stopLocationTracking();
        // No exception should be thrown
        expect(true, isTrue);
      });
    });

    group('Location Permission Handling', () {
      testWidgets('Permission status is properly tracked', (tester) async {
        final status = locationService.permissionStatus;
        if (status != null) {
          expect(status.isGranted, isA<bool>());
          expect(status.isDenied, isA<bool>());
          expect(status.isPermanentlyDenied, isA<bool>());
          expect(status.canRequest, isA<bool>());
        }
      });

      testWidgets('Permission request handles different states',
          (tester) async {
        final result = await locationService.requestPermission();
        expect(result, isA<bool>());
      });
    });

    group('Area-based Filtering', () {
      testWidgets('Products can be filtered by area', (tester) async {
        // Mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        // Set mock location
        await locationService.setLocationFromSearch(mockLocation);

        // Mock products with different locations
        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867,
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946,
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        // Test area-based filtering
        final filteredProducts = locationService.filterByArea(
          products,
          (product) => product.location?.city,
          (product) => product.location?.state,
          (product) => product.location?.area,
        );

        expect(filteredProducts.length, equals(1));
        expect(filteredProducts.first.id, equals('1'));
      });
    });

    group('Distance Calculation', () {
      testWidgets('Distance between two points is calculated correctly',
          (tester) async {
        // Test distance calculation between Hyderabad and Bangalore
        final distance = LocationService.calculateDistance(
          17.3850, 78.4867, // Hyderabad
          12.9716, 77.5946, // Bangalore
        );

        expect(distance, isA<double>());
        expect(distance, greaterThan(0));
        // Hyderabad to Bangalore is approximately 570km
        expect(distance, greaterThan(500));
        expect(distance, lessThan(600));
      });

      testWidgets('Distance from current location is calculated',
          (tester) async {
        // Set mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        // Calculate distance to another point
        final distance = locationService.calculateDistanceTo(12.9716, 77.5946);
        expect(distance, isNotNull);
        expect(distance!, greaterThan(0));
      });

      testWidgets('Products can be sorted by distance', (tester) async {
        // Set mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867, // Same as current location
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946, // Far from current location
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        // Sort by distance
        final sortedProducts = locationService.sortByDistance(
          products,
          (product) => product.location?.latitude ?? 0.0,
          (product) => product.location?.longitude ?? 0.0,
        );

        expect(sortedProducts.length, equals(2));
        expect(sortedProducts.first.id, equals('1')); // Should be closer
        expect(sortedProducts.last.id, equals('2')); // Should be farther
      });
    });

    group('Location Search', () {
      testWidgets('Location search returns relevant results', (tester) async {
        final results = await locationService.searchLocations('Hyderabad');
        expect(results, isA<List<LocationData>>());
        expect(results.length, greaterThan(0));
        expect(results.first.city, equals('Hyderabad'));
      });

      testWidgets('Location search handles empty queries', (tester) async {
        final results = await locationService.searchLocations('');
        expect(results, isEmpty);
      });

      testWidgets('Location can be set from search results', (tester) async {
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);
        expect(locationService.currentLocation, isNotNull);
        expect(locationService.currentLocation!.city, equals('Hyderabad'));
      });
    });

    group('Location History', () {
      testWidgets('Location history is maintained', (tester) async {
        // Add locations to history
        await locationService.setLocationFromSearch(LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));

        await locationService.setLocationFromSearch(LocationData(
          latitude: 12.9716,
          longitude: 77.5946,
          city: 'Bangalore',
          state: 'Karnataka',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));

        expect(locationService.locationHistory.length, equals(2));
        expect(locationService.locationHistory.first.location,
            equals('Bangalore'));
        expect(
            locationService.locationHistory.last.location, equals('Hyderabad'));
      });

      testWidgets('Location history can be cleared', (tester) async {
        // Add a location to history
        await locationService.setLocationFromSearch(LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));

        expect(locationService.locationHistory.length, equals(1));

        // Clear history
        await locationService.clearLocationHistory();
        expect(locationService.locationHistory, isEmpty);
      });

      testWidgets('Specific location can be removed from history',
          (tester) async {
        // Add locations to history
        await locationService.setLocationFromSearch(LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));

        await locationService.setLocationFromSearch(LocationData(
          latitude: 12.9716,
          longitude: 77.5946,
          city: 'Bangalore',
          state: 'Karnataka',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));

        expect(locationService.locationHistory.length, equals(2));

        // Remove first item
        await locationService.removeLocationFromHistory(0);
        expect(locationService.locationHistory.length, equals(1));
        expect(locationService.locationHistory.first.location,
            equals('Hyderabad'));
      });
    });

    group('Offline Location Handling', () {
      testWidgets('Offline mode can be enabled and disabled', (tester) async {
        await locationService.setOfflineMode(true);
        expect(locationService.isOfflineMode, isTrue);

        await locationService.setOfflineMode(false);
        expect(locationService.isOfflineMode, isFalse);
      });

      testWidgets('Last known location is preserved in offline mode',
          (tester) async {
        // Set a location first
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);
        expect(locationService.currentLocation, isNotNull);

        // Enable offline mode
        await locationService.setOfflineMode(true);
        expect(locationService.lastKnownLocation, isNotNull);
        expect(locationService.lastKnownLocation!.city, equals('Hyderabad'));
      });

      testWidgets('Offline location is returned when offline', (tester) async {
        // Set a location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        // Enable offline mode
        await locationService.setOfflineMode(true);

        final offlineLocation = locationService.getLocationForOfflineUse();
        expect(offlineLocation, isNotNull);
        expect(offlineLocation!.city, equals('Hyderabad'));
      });
    });

    group('Location-Aware Filter Service', () {
      late LocationAwareFilterService filterService;

      setUp(() {
        filterService = LocationAwareFilterService(locationService, prefs);
      });

      tearDown(() {
        filterService.dispose();
      });

      testWidgets('Filter service initializes correctly', (tester) async {
        expect(filterService.currentFilter, isA<LocationAwareFilter>());
        expect(filterService.filteredProducts, isEmpty);
      });

      testWidgets('Products can be filtered by distance', (tester) async {
        // Set mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        // Initialize with products
        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867, // Same as current location
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946, // Far from current location
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        filterService.initializeWithProducts(products);

        // Set distance filter
        filterService.setMaxDistance(10.0);

        expect(filterService.filteredProducts.length, equals(1));
        expect(filterService.filteredProducts.first.id, equals('1'));
      });

      testWidgets('Products can be filtered by preferred location',
          (tester) async {
        // Initialize with products
        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867,
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946,
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        filterService.initializeWithProducts(products);

        // Set preferred city
        filterService.setPreferredLocation('Hyderabad', null);

        expect(filterService.filteredProducts.length, equals(1));
        expect(filterService.filteredProducts.first.id, equals('1'));
      });

      testWidgets('Distance information is calculated for products',
          (tester) async {
        // Set mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        final product = Product(
          id: '1',
          title: 'Product 1',
          brand: 'Brand 1',
          price: 100.0,
          category: 'Electrical',
          materials: ['Copper'],
          location: ProductLocation(
            latitude: 17.3850,
            longitude: 78.4867,
            city: 'Hyderabad',
            state: 'Telangana',
          ),
          rating: 4.5,
        );

        final distanceInfo = filterService.getProductDistanceInfo(product);
        expect(distanceInfo['distance'], isNotNull);
        expect(distanceInfo['distanceText'], isA<String>());
        expect(distanceInfo['isInSameArea'], isTrue);
        expect(distanceInfo['isWithinRadius'], isTrue);
      });

      testWidgets('Location-based statistics are calculated', (tester) async {
        // Set mock current location
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        // Initialize with products
        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867,
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946,
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        filterService.initializeWithProducts(products);

        final stats = filterService.getLocationBasedStats();
        expect(stats['totalProducts'], equals(2));
        expect(stats['productsWithLocation'], equals(2));
        expect(stats['productsInSameCity'], equals(1));
        expect(stats['cities'], isA<Set<String>>());
        expect(stats['states'], isA<Set<String>>());
      });

      testWidgets('Filter settings can be cleared', (tester) async {
        // Set some filter settings
        filterService.setMaxDistance(50.0);
        filterService.setPreferredLocation('Hyderabad', 'Telangana');

        expect(filterService.currentFilter.maxDistance, equals(50.0));
        expect(filterService.currentFilter.preferredCity, equals('Hyderabad'));

        // Clear settings
        await filterService.clearFilterSettings();

        expect(filterService.currentFilter.maxDistance, isNull);
        expect(filterService.currentFilter.preferredCity, isNull);
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete location workflow works end-to-end',
          (tester) async {
        // 1. Enable location services
        await locationService.setAutoLocationEnabled(true);

        // 2. Search for a location
        final searchResults =
            await locationService.searchLocations('Hyderabad');
        expect(searchResults.length, greaterThan(0));

        // 3. Set location from search
        await locationService.setLocationFromSearch(searchResults.first);
        expect(locationService.currentLocation, isNotNull);

        // 4. Verify location is in history
        expect(locationService.locationHistory.length, greaterThan(0));

        // 5. Test offline mode
        await locationService.setOfflineMode(true);
        expect(locationService.isOfflineMode, isTrue);

        // 6. Verify offline location is available
        final offlineLocation = locationService.getLocationForOfflineUse();
        expect(offlineLocation, isNotNull);

        // 7. Disable offline mode
        await locationService.setOfflineMode(false);
        expect(locationService.isOfflineMode, isFalse);

        print('✅ Complete location workflow test passed');
      });

      testWidgets('Location-aware filtering workflow works end-to-end',
          (tester) async {
        // 1. Set up location service
        final mockLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        );

        await locationService.setLocationFromSearch(mockLocation);

        // 2. Set up filter service
        final filterService =
            LocationAwareFilterService(locationService, prefs);

        // 3. Initialize with products
        final products = [
          Product(
            id: '1',
            title: 'Product 1',
            brand: 'Brand 1',
            price: 100.0,
            category: 'Electrical',
            materials: ['Copper'],
            location: ProductLocation(
              latitude: 17.3850,
              longitude: 78.4867,
              city: 'Hyderabad',
              state: 'Telangana',
            ),
            rating: 4.5,
          ),
          Product(
            id: '2',
            title: 'Product 2',
            brand: 'Brand 2',
            price: 200.0,
            category: 'Electrical',
            materials: ['Aluminum'],
            location: ProductLocation(
              latitude: 12.9716,
              longitude: 77.5946,
              city: 'Bangalore',
              state: 'Karnataka',
            ),
            rating: 4.0,
          ),
        ];

        filterService.initializeWithProducts(products);

        // 4. Test area-based filtering
        filterService.setAreaFiltering(true);
        expect(filterService.filteredProducts.length, equals(1));

        // 5. Test distance-based filtering
        filterService.setMaxDistance(10.0);
        expect(filterService.filteredProducts.length, equals(1));

        // 6. Test distance-based sorting
        filterService.setDistanceSorting(true);
        expect(filterService.filteredProducts.first.id, equals('1'));

        // 7. Get statistics
        final stats = filterService.getLocationBasedStats();
        expect(stats['totalProducts'], equals(2));

        filterService.dispose();
        print('✅ Location-aware filtering workflow test passed');
      });
    });
  });
}
