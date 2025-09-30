import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/location_service.dart';
import 'package:vidyut/services/location_aware_filter_service.dart';
import 'package:vidyut/features/sell/models.dart';

void main() {
  group('Basic Location Functionality Tests', () {
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

    group('Distance Calculation', () {
      test('Distance between two points is calculated correctly', () {
        // Test distance calculation between Hyderabad and Bangalore
        final distance = LocationService.calculateDistance(
          17.3850, 78.4867, // Hyderabad
          12.9716, 77.5946, // Bangalore
        );

        expect(distance, isA<double>());
        expect(distance, greaterThan(0));
        // Hyderabad to Bangalore is approximately 570km
        expect(distance, greaterThan(490));
        expect(distance, lessThan(600));
        print(
            '✅ Distance calculation test passed: ${distance.toStringAsFixed(1)}km');
      });

      test('Distance calculation with same coordinates returns 0', () {
        final distance = LocationService.calculateDistance(
          17.3850,
          78.4867,
          17.3850,
          78.4867,
        );

        expect(distance, equals(0.0));
        print('✅ Same coordinates distance test passed');
      });
    });

    group('Location Search', () {
      test('Location search returns relevant results', () async {
        final results = await locationService.searchLocations('Hyderabad');
        expect(results, isA<List<LocationData>>());
        expect(results.length, greaterThan(0));
        expect(results.first.city, equals('Hyderabad'));
        print('✅ Location search test passed: Found ${results.length} results');
      });

      test('Location search handles empty queries', () async {
        final results = await locationService.searchLocations('');
        expect(results, isEmpty);
        print('✅ Empty query search test passed');
      });

      test('Location search handles non-matching queries', () async {
        final results =
            await locationService.searchLocations('NonExistentCity');
        expect(results, isEmpty);
        print('✅ Non-matching query search test passed');
      });
    });

    group('Location History', () {
      test('Location history can be managed', () async {
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
        print('✅ Location history management test passed');
      });

      test('Location history can be cleared', () async {
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

        // Note: History length might be 2 due to previous test, so we check it's at least 1
        expect(locationService.locationHistory.length, greaterThanOrEqualTo(1));

        // Clear history
        await locationService.clearLocationHistory();
        expect(locationService.locationHistory, isEmpty);
        print('✅ Location history clear test passed');
      });
    });

    group('Area-based Filtering', () {
      test('Products can be filtered by area', () {
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
        locationService.setLocationFromSearch(mockLocation);

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
        print('✅ Area-based filtering test passed');
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

      test('Filter service initializes correctly', () {
        expect(filterService.currentFilter, isA<LocationAwareFilter>());
        expect(filterService.filteredProducts, isEmpty);
        print('✅ Filter service initialization test passed');
      });

      test('Products can be filtered by distance', () {
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

        locationService.setLocationFromSearch(mockLocation);

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
        print('✅ Distance filtering test passed');
      });

      test('Distance information is calculated for products', () {
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

        locationService.setLocationFromSearch(mockLocation);

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
        print('✅ Distance info calculation test passed');
      });

      test('Location-based statistics are calculated', () {
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

        locationService.setLocationFromSearch(mockLocation);

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
        print('✅ Location statistics test passed');
      });
    });

    group('Integration Tests', () {
      test('Complete location workflow works end-to-end', () async {
        // 1. Search for a location
        final searchResults =
            await locationService.searchLocations('Hyderabad');
        expect(searchResults.length, greaterThan(0));

        // 2. Set location from search
        await locationService.setLocationFromSearch(searchResults.first);
        expect(locationService.currentLocation, isNotNull);

        // 3. Verify location is in history
        expect(locationService.locationHistory.length, greaterThan(0));

        // 4. Test offline mode
        await locationService.setOfflineMode(true);
        expect(locationService.isOfflineMode, isTrue);

        // 5. Verify offline location is available
        final offlineLocation = locationService.getLocationForOfflineUse();
        expect(offlineLocation, isNotNull);

        // 6. Disable offline mode
        await locationService.setOfflineMode(false);
        expect(locationService.isOfflineMode, isFalse);

        print('✅ Complete location workflow test passed');
      });

      test('Location-aware filtering workflow works end-to-end', () {
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

        locationService.setLocationFromSearch(mockLocation);

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
