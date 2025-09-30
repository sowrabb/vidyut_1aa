import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vidyut/services/location_service.dart';

import 'location_service_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
])
void main() {
  group('LocationService', () {
    late LocationService locationService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);

      locationService = LocationService(mockPrefs);
    });

    group('Location Data', () {
      test('should create location data with correct properties', () {
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          area: 'HITEC City',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        expect(locationData.latitude, equals(17.3850));
        expect(locationData.longitude, equals(78.4867));
        expect(locationData.city, equals('Hyderabad'));
        expect(locationData.area, equals('HITEC City'));
        expect(locationData.state, equals('Telangana'));
        expect(locationData.country, equals('India'));
        expect(locationData.accuracy, equals(10.0));
      });

      test('should serialize and deserialize location data', () {
        final originalData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          area: 'HITEC City',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        final json = originalData.toJson();
        final deserializedData = LocationData.fromJson(json);

        expect(deserializedData.latitude, equals(originalData.latitude));
        expect(deserializedData.longitude, equals(originalData.longitude));
        expect(deserializedData.city, equals(originalData.city));
        expect(deserializedData.area, equals(originalData.area));
        expect(deserializedData.state, equals(originalData.state));
        expect(deserializedData.country, equals(originalData.country));
        expect(deserializedData.accuracy, equals(originalData.accuracy));
      });
    });

    group('Distance Calculations', () {
      test('should calculate distance between two points', () {
        // Distance between Hyderabad and Bangalore (approximately 570 km)
        final distance = LocationService.calculateDistance(
          17.3850, 78.4867, // Hyderabad
          12.9716, 77.5946, // Bangalore
        );

        expect(distance, greaterThan(500));
        expect(distance, lessThan(600));
      });

      test('should calculate distance from current location', () {
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        // Set current location
        locationService.currentLocation = locationData;

        final distance = locationService.calculateDistanceTo(12.9716, 77.5946);
        expect(distance, isNotNull);
        expect(distance!, greaterThan(500));
        expect(distance, lessThan(600));
      });

      test('should return null when no current location', () {
        final distance = locationService.calculateDistanceTo(12.9716, 77.5946);
        expect(distance, isNull);
      });

      test('should check if location is within radius', () {
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        locationService.currentLocation = locationData;

        // Test point within 10km radius
        final isWithin = locationService.isWithinRadius(17.4, 78.5, 10);
        expect(isWithin, isTrue);

        // Test point outside 1km radius
        final isOutside = locationService.isWithinRadius(12.9716, 77.5946, 1);
        expect(isOutside, isFalse);
      });
    });

    group('Filtering and Sorting', () {
      test('should filter items by radius', () {
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        locationService.currentLocation = locationData;

        final items = [
          {'name': 'Item 1', 'lat': 17.4, 'lng': 78.5}, // Within 10km
          {'name': 'Item 2', 'lat': 12.9716, 'lng': 77.5946}, // Far away
          {'name': 'Item 3', 'lat': 17.39, 'lng': 78.48}, // Within 10km
        ];

        final filtered = locationService.filterByRadius(
          items,
          (item) => item['lat'] as double,
          (item) => item['lng'] as double,
          10.0,
        );

        expect(filtered.length, equals(2));
        expect(filtered.any((item) => item['name'] == 'Item 1'), isTrue);
        expect(filtered.any((item) => item['name'] == 'Item 3'), isTrue);
        expect(filtered.any((item) => item['name'] == 'Item 2'), isFalse);
      });

      test('should sort items by distance', () {
        final locationData = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        locationService.currentLocation = locationData;

        final items = [
          {'name': 'Far Item', 'lat': 12.9716, 'lng': 77.5946}, // Far away
          {'name': 'Close Item', 'lat': 17.39, 'lng': 78.48}, // Close
          {'name': 'Medium Item', 'lat': 17.4, 'lng': 78.5}, // Medium distance
        ];

        final sorted = locationService.sortByDistance(
          items,
          (item) => item['lat'] as double,
          (item) => item['lng'] as double,
        );

        expect(sorted.first['name'], equals('Close Item'));
        expect(sorted.last['name'], equals('Far Item'));
      });
    });

    group('Data Persistence', () {
      test('should load cached location from preferences', () async {
        final cachedLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );

        final locationJson = '''
        {
          "latitude": 17.3850,
          "longitude": 78.4867,
          "city": "Hyderabad",
          "area": null,
          "state": "Telangana",
          "country": "India",
          "accuracy": 10.0,
          "timestamp": "${cachedLocation.timestamp.toIso8601String()}"
        }
        ''';

        when(mockPrefs.getString('cached_location')).thenReturn(locationJson);

        final service = LocationService(mockPrefs);

        expect(service.currentLocation, isNotNull);
        expect(service.currentLocation!.city, equals('Hyderabad'));
      });

      test('should not load expired cached location', () async {
        final expiredLocation = LocationData(
          latitude: 17.3850,
          longitude: 78.4867,
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          accuracy: 10.0,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        );

        final locationJson = '''
        {
          "latitude": 17.3850,
          "longitude": 78.4867,
          "city": "Hyderabad",
          "area": null,
          "state": "Telangana",
          "country": "India",
          "accuracy": 10.0,
          "timestamp": "${expiredLocation.timestamp.toIso8601String()}"
        }
        ''';

        when(mockPrefs.getString('cached_location')).thenReturn(locationJson);

        final service = LocationService(mockPrefs);

        expect(service.currentLocation, isNull);
      });

      test('should clear cached location', () async {
        await locationService.clearCachedLocation();

        verify(mockPrefs.remove('cached_location')).called(1);
        expect(locationService.currentLocation, isNull);
      });

      test('should handle invalid JSON gracefully', () async {
        when(mockPrefs.getString('cached_location')).thenReturn('invalid json');

        final service = LocationService(mockPrefs);

        expect(service.currentLocation, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle errors gracefully', () {
        expect(() => locationService.clearError(), returnsNormally);
        expect(locationService.error, isNull);
      });

      test('should set loading state correctly', () {
        expect(locationService.isLoading, isFalse);
      });
    });
  });
}
