import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class LocationData {
  final double latitude;
  final double longitude;
  final String city;
  final String? area;
  final String state;
  final String country;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.area,
    required this.state,
    required this.country,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'area': area,
        'state': state,
        'country': country,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
        city: json['city'],
        area: json['area'],
        state: json['state'],
        country: json['country'],
        accuracy: json['accuracy'].toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class LocationPermissionStatus {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final bool canRequest;

  LocationPermissionStatus({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.canRequest,
  });
}

class LocationHistoryItem {
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final int usageCount;

  LocationHistoryItem({
    required this.location,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.usageCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'usageCount': usageCount,
      };

  factory LocationHistoryItem.fromJson(Map<String, dynamic> json) =>
      LocationHistoryItem(
        location: json['location'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        usageCount: json['usageCount'] ?? 1,
      );
}

class LocationService extends ChangeNotifier {
  final SharedPreferences _prefs;

  LocationData? _currentLocation;
  LocationPermissionStatus? _permissionStatus;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Position>? _positionStream;

  // Enhanced location features
  List<LocationHistoryItem> _locationHistory = [];
  bool _isAutoLocationEnabled = true;
  bool _isOfflineMode = false;
  LocationData? _lastKnownLocation;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  LocationPermissionStatus? get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocation => _currentLocation != null;
  List<LocationHistoryItem> get locationHistory => _locationHistory;
  bool get isAutoLocationEnabled => _isAutoLocationEnabled;
  bool get isOfflineMode => _isOfflineMode;
  LocationData? get lastKnownLocation => _lastKnownLocation;

  LocationService(this._prefs) {
    _loadCachedLocation();
    _loadLocationHistory();
    _loadLocationSettings();
    _checkPermissionStatus();

    // Initialize auto location detection if enabled
    if (_isAutoLocationEnabled) {
      _initializeAutoLocation();
    }
  }

  // Check location permission status
  Future<void> _checkPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();

      _permissionStatus = LocationPermissionStatus(
        isGranted: permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse,
        isDenied: permission == LocationPermission.denied,
        isPermanentlyDenied: permission == LocationPermission.deniedForever,
        canRequest: permission == LocationPermission.denied && isServiceEnabled,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to check location permissions: ${e.toString()}');
    }
  }

  // Request location permission
  Future<bool> requestPermission() async {
    _setLoading(true);
    _clearError();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError(
            'Location services are disabled. Please enable them in settings.');
        return false;
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permissions are denied.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError(
            'Location permissions are permanently denied. Please enable them in app settings.');
        return false;
      }

      await _checkPermissionStatus();
      return _permissionStatus?.isGranted ?? false;
    } catch (e) {
      _setError('Failed to request location permission: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get current location
  Future<LocationData?> getCurrentLocation() async {
    if (!(_permissionStatus?.isGranted ?? false)) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'Unknown', // Will be updated by reverse geocoding
        state: 'Unknown',
        country: 'Unknown',
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      // Reverse geocode to get address
      final address =
          await _reverseGeocode(position.latitude, position.longitude);
      final updatedLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        city: address['city'] ?? 'Unknown',
        area: address['area'],
        state: address['state'] ?? 'Unknown',
        country: address['country'] ?? 'Unknown',
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      _currentLocation = updatedLocation;
      await _cacheLocation(updatedLocation);
      notifyListeners();
      return updatedLocation;
    } catch (e) {
      _setError('Failed to get current location: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Start location tracking
  Future<void> startLocationTracking() async {
    if (!(_permissionStatus?.isGranted ?? false)) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(
        (Position position) async {
          final address =
              await _reverseGeocode(position.latitude, position.longitude);
          // Update location data
          final locationData = LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            city: address['city'] ?? 'Unknown',
            area: address['area'],
            state: address['state'] ?? 'Unknown',
            country: address['country'] ?? 'Unknown',
            accuracy: position.accuracy,
            timestamp: DateTime.now(),
          );

          _currentLocation = locationData;
          await _cacheLocation(locationData);
          notifyListeners();
        },
        onError: (error) {
          _setError('Location tracking error: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Failed to start location tracking: ${e.toString()}');
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // Calculate distance between two points (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Calculate distance from current location to a point
  double? calculateDistanceTo(double latitude, double longitude) {
    if (_currentLocation == null) return null;

    return calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      latitude,
      longitude,
    );
  }

  // Check if a location is within radius
  bool isWithinRadius(double latitude, double longitude, double radiusKm) {
    final distance = calculateDistanceTo(latitude, longitude);
    return distance != null && distance <= radiusKm;
  }

  // Get locations within radius
  List<T> filterByRadius<T>(
    List<T> items,
    double Function(T) getLatitude,
    double Function(T) getLongitude,
    double radiusKm,
  ) {
    if (_currentLocation == null) return items;

    return items.where((item) {
      final lat = getLatitude(item);
      final lng = getLongitude(item);
      return isWithinRadius(lat, lng, radiusKm);
    }).toList();
  }

  // Sort by distance
  List<T> sortByDistance<T>(
    List<T> items,
    double Function(T) getLatitude,
    double Function(T) getLongitude,
  ) {
    if (_currentLocation == null) return items;

    final itemsWithDistance = items.map((item) {
      final lat = getLatitude(item);
      final lng = getLongitude(item);
      final distance = calculateDistanceTo(lat, lng) ?? double.infinity;
      return MapEntry(item, distance);
    }).toList();

    itemsWithDistance.sort((a, b) => a.value.compareTo(b.value));
    return itemsWithDistance.map((entry) => entry.key).toList();
  }

  // Reverse geocoding
  Future<Map<String, String?>> _reverseGeocode(
      double latitude, double longitude) async {
    try {
      // In a real implementation, you would use a geocoding service
      // For now, we'll return mock data based on coordinates
      return {
        'city': _getCityFromCoordinates(latitude, longitude),
        'area': _getAreaFromCoordinates(latitude, longitude),
        'state': _getStateFromCoordinates(latitude, longitude),
        'country': 'India',
      };
    } catch (e) {
      return {
        'city': 'Unknown',
        'area': null,
        'state': 'Unknown',
        'country': 'Unknown',
      };
    }
  }

  // Mock city detection based on coordinates
  String _getCityFromCoordinates(double lat, double lng) {
    // Simple coordinate-based city detection
    if (lat >= 17.0 && lat <= 18.0 && lng >= 78.0 && lng <= 79.0) {
      return 'Hyderabad';
    } else if (lat >= 12.0 && lat <= 13.0 && lng >= 77.0 && lng <= 78.0) {
      return 'Bangalore';
    } else if (lat >= 19.0 && lat <= 20.0 && lng >= 72.0 && lng <= 73.0) {
      return 'Mumbai';
    } else if (lat >= 28.0 && lat <= 29.0 && lng >= 77.0 && lng <= 78.0) {
      return 'Delhi';
    } else if (lat >= 13.0 && lat <= 14.0 && lng >= 80.0 && lng <= 81.0) {
      return 'Chennai';
    }
    return 'Unknown';
  }

  String? _getAreaFromCoordinates(double lat, double lng) {
    // Mock area detection
    return null; // Would be implemented with real geocoding service
  }

  String _getStateFromCoordinates(double lat, double lng) {
    // Simple coordinate-based state detection
    if (lat >= 17.0 && lat <= 18.0 && lng >= 78.0 && lng <= 79.0) {
      return 'Telangana';
    } else if (lat >= 12.0 && lat <= 13.0 && lng >= 77.0 && lng <= 78.0) {
      return 'Karnataka';
    } else if (lat >= 19.0 && lat <= 20.0 && lng >= 72.0 && lng <= 73.0) {
      return 'Maharashtra';
    } else if (lat >= 28.0 && lat <= 29.0 && lng >= 77.0 && lng <= 78.0) {
      return 'Delhi';
    } else if (lat >= 13.0 && lat <= 14.0 && lng >= 80.0 && lng <= 81.0) {
      return 'Tamil Nadu';
    }
    return 'Unknown';
  }

  // Cache location data
  Future<void> _cacheLocation(LocationData location) async {
    try {
      final locationJson = jsonEncode(location.toJson());
      await _prefs.setString('cached_location', locationJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Load cached location
  Future<void> _loadCachedLocation() async {
    try {
      final locationJson = _prefs.getString('cached_location');
      if (locationJson != null) {
        final locationData = LocationData.fromJson(jsonDecode(locationJson));

        // Check if cached location is not too old (24 hours)
        final age = DateTime.now().difference(locationData.timestamp);
        if (age.inHours < 24) {
          _currentLocation = locationData;
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear cached location
  Future<void> clearCachedLocation() async {
    try {
      await _prefs.remove('cached_location');
      _currentLocation = null;
      notifyListeners();
    } catch (e) {
      // Handle error silently
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

  // Enhanced Location Features

  // Initialize automatic location detection
  Future<void> _initializeAutoLocation() async {
    if (!_isAutoLocationEnabled) return;

    try {
      // Check if we have permission
      if (!(_permissionStatus?.isGranted ?? false)) {
        await requestPermission();
      }

      // Get current location automatically
      if (_permissionStatus?.isGranted ?? false) {
        await getCurrentLocation();
      }
    } catch (e) {
      _setError('Failed to initialize auto location: ${e.toString()}');
    }
  }

  // Enable/disable automatic location detection
  Future<void> setAutoLocationEnabled(bool enabled) async {
    _isAutoLocationEnabled = enabled;
    await _saveLocationSettings();

    if (enabled) {
      await _initializeAutoLocation();
    } else {
      stopLocationTracking();
    }

    notifyListeners();
  }

  // Search by specific locations
  Future<List<LocationData>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    // In a real implementation, this would use a geocoding service
    // For demo purposes, we'll return mock results based on the query
    final mockLocations = <LocationData>[];

    final cities = [
      'Hyderabad',
      'Bangalore',
      'Mumbai',
      'Delhi',
      'Chennai',
      'Kolkata',
      'Pune'
    ];
    final matchingCities = cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();

    for (final city in matchingCities) {
      final coordinates = _getCoordinatesForCity(city);
      if (coordinates != null) {
        mockLocations.add(LocationData(
          latitude: coordinates['lat']!,
          longitude: coordinates['lng']!,
          city: city,
          state: _getStateForCity(city),
          country: 'India',
          accuracy: 100.0,
          timestamp: DateTime.now(),
        ));
      }
    }

    return mockLocations;
  }

  // Set location from search
  Future<void> setLocationFromSearch(LocationData location) async {
    _currentLocation = location;
    _lastKnownLocation = location;
    await _cacheLocation(location);
    await _addToLocationHistory(
        location.city, location.latitude, location.longitude);
    notifyListeners();
  }

  // Add location to history
  Future<void> _addToLocationHistory(
      String location, double? lat, double? lng) async {
    final existingIndex =
        _locationHistory.indexWhere((item) => item.location == location);

    if (existingIndex >= 0) {
      // Update existing entry
      final existing = _locationHistory[existingIndex];
      _locationHistory[existingIndex] = LocationHistoryItem(
        location: location,
        latitude: lat ?? existing.latitude,
        longitude: lng ?? existing.longitude,
        timestamp: DateTime.now(),
        usageCount: existing.usageCount + 1,
      );
    } else {
      // Add new entry
      _locationHistory.insert(
          0,
          LocationHistoryItem(
            location: location,
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            usageCount: 1,
          ));
    }

    // Keep only last 20 locations
    if (_locationHistory.length > 20) {
      _locationHistory = _locationHistory.take(20).toList();
    }

    await _saveLocationHistory();
  }

  // Clear location history
  Future<void> clearLocationHistory() async {
    _locationHistory.clear();
    await _saveLocationHistory();
    notifyListeners();
  }

  // Remove specific location from history
  Future<void> removeLocationFromHistory(int index) async {
    if (index >= 0 && index < _locationHistory.length) {
      _locationHistory.removeAt(index);
      await _saveLocationHistory();
      notifyListeners();
    }
  }

  // Enhanced area-based filtering
  List<T> filterByArea<T>(
    List<T> items,
    String? Function(T) getCity,
    String? Function(T) getState,
    String? Function(T) getArea,
  ) {
    if (_currentLocation == null) return items;

    return items.where((item) {
      final itemCity = getCity(item);
      final itemState = getState(item);
      final itemArea = getArea(item);

      // Match by city
      if (itemCity != null &&
          itemCity.toLowerCase() == _currentLocation!.city.toLowerCase()) {
        return true;
      }

      // Match by state
      if (itemState != null &&
          itemState.toLowerCase() == _currentLocation!.state.toLowerCase()) {
        return true;
      }

      // Match by area (if available)
      if (itemArea != null &&
          _currentLocation!.area != null &&
          itemArea.toLowerCase() == _currentLocation!.area!.toLowerCase()) {
        return true;
      }

      return false;
    }).toList();
  }

  // Enhanced distance calculation with area consideration
  Map<String, dynamic> calculateDistanceWithArea(
    double latitude,
    double longitude,
    String? city,
    String? state,
  ) {
    final distance = calculateDistanceTo(latitude, longitude);

    return {
      'distance': distance,
      'distanceText':
          distance != null ? '${distance.toStringAsFixed(1)} km' : 'Unknown',
      'isInSameCity': city != null &&
          _currentLocation != null &&
          city.toLowerCase() == _currentLocation!.city.toLowerCase(),
      'isInSameState': state != null &&
          _currentLocation != null &&
          state.toLowerCase() == _currentLocation!.state.toLowerCase(),
      'isWithinRadius':
          distance != null && distance <= 25.0, // Default 25km radius
    };
  }

  // Offline location handling
  Future<void> setOfflineMode(bool offline) async {
    _isOfflineMode = offline;

    if (offline) {
      // Use last known location when offline
      if (_currentLocation != null) {
        _lastKnownLocation = _currentLocation;
      }
      stopLocationTracking();
    } else {
      // Resume location services when back online
      if (_isAutoLocationEnabled) {
        await _initializeAutoLocation();
      }
    }

    await _saveLocationSettings();
    notifyListeners();
  }

  // Get location for offline use
  LocationData? getLocationForOfflineUse() {
    if (!_isOfflineMode) return _currentLocation;
    return _lastKnownLocation ?? _currentLocation;
  }

  // Load location history from storage
  Future<void> _loadLocationHistory() async {
    try {
      final historyJson = _prefs.getString('location_history');
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _locationHistory = historyList
            .map((item) => LocationHistoryItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      _locationHistory = [];
    }
  }

  // Save location history to storage
  Future<void> _saveLocationHistory() async {
    try {
      final historyJson = jsonEncode(
        _locationHistory.map((item) => item.toJson()).toList(),
      );
      await _prefs.setString('location_history', historyJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Load location settings
  Future<void> _loadLocationSettings() async {
    try {
      _isAutoLocationEnabled = _prefs.getBool('auto_location_enabled') ?? true;
      _isOfflineMode = _prefs.getBool('offline_mode') ?? false;
    } catch (e) {
      _isAutoLocationEnabled = true;
      _isOfflineMode = false;
    }
  }

  // Save location settings
  Future<void> _saveLocationSettings() async {
    try {
      await _prefs.setBool('auto_location_enabled', _isAutoLocationEnabled);
      await _prefs.setBool('offline_mode', _isOfflineMode);
    } catch (e) {
      // Handle error silently
    }
  }

  // Helper methods for mock data
  Map<String, double>? _getCoordinatesForCity(String city) {
    switch (city.toLowerCase()) {
      case 'hyderabad':
        return {'lat': 17.3850, 'lng': 78.4867};
      case 'bangalore':
        return {'lat': 12.9716, 'lng': 77.5946};
      case 'mumbai':
        return {'lat': 19.0760, 'lng': 72.8777};
      case 'delhi':
        return {'lat': 28.7041, 'lng': 77.1025};
      case 'chennai':
        return {'lat': 13.0827, 'lng': 80.2707};
      case 'kolkata':
        return {'lat': 22.5726, 'lng': 88.3639};
      case 'pune':
        return {'lat': 18.5204, 'lng': 73.8567};
      default:
        return null;
    }
  }

  String _getStateForCity(String city) {
    switch (city.toLowerCase()) {
      case 'hyderabad':
        return 'Telangana';
      case 'bangalore':
        return 'Karnataka';
      case 'mumbai':
      case 'pune':
        return 'Maharashtra';
      case 'delhi':
        return 'Delhi';
      case 'chennai':
        return 'Tamil Nadu';
      case 'kolkata':
        return 'West Bengal';
      default:
        return 'Unknown';
    }
  }

  // Enhanced location tracking with area detection
  Future<void> startEnhancedLocationTracking() async {
    if (!(_permissionStatus?.isGranted ?? false)) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters for better area detection
        ),
      ).listen(
        (Position position) async {
          if (_isOfflineMode) return; // Skip updates in offline mode

          final address =
              await _reverseGeocode(position.latitude, position.longitude);
          final locationData = LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            city: address['city'] ?? 'Unknown',
            area: address['area'],
            state: address['state'] ?? 'Unknown',
            country: address['country'] ?? 'Unknown',
            accuracy: position.accuracy,
            timestamp: DateTime.now(),
          );

          // Check if location has changed significantly
          if (_currentLocation == null ||
              _calculateLocationChange(_currentLocation!, locationData) > 0.1) {
            _currentLocation = locationData;
            _lastKnownLocation = locationData;
            await _cacheLocation(locationData);
            await _addToLocationHistory(locationData.city,
                locationData.latitude, locationData.longitude);
            notifyListeners();
          }
        },
        onError: (error) {
          _setError('Enhanced location tracking error: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Failed to start enhanced location tracking: ${e.toString()}');
    }
  }

  // Calculate location change distance
  double _calculateLocationChange(
      LocationData oldLocation, LocationData newLocation) {
    return calculateDistance(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}

// Helper functions for distance calculations
double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
