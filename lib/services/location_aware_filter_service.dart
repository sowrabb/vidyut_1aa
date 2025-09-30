import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/sell/models.dart';
import 'location_service.dart';

class LocationAwareFilter {
  final double? maxDistance;
  final bool filterByArea;
  final bool sortByDistance;
  final String? preferredCity;
  final String? preferredState;

  LocationAwareFilter({
    this.maxDistance,
    this.filterByArea = true,
    this.sortByDistance = true,
    this.preferredCity,
    this.preferredState,
  });
}

class LocationAwareFilterService extends ChangeNotifier {
  final LocationService _locationService;
  final SharedPreferences _prefs;

  LocationAwareFilter _currentFilter = LocationAwareFilter();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // Getters
  LocationAwareFilter get currentFilter => _currentFilter;
  List<Product> get filteredProducts => _filteredProducts;
  List<Product> get allProducts => _allProducts;

  LocationAwareFilterService(this._locationService, this._prefs) {
    _loadFilterSettings();
    _locationService.addListener(_onLocationChanged);
  }

  // Initialize with products
  void initializeWithProducts(List<Product> products) {
    _allProducts = products;
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Update filter settings
  void updateFilter(LocationAwareFilter filter) {
    _currentFilter = filter;
    _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Set maximum distance filter
  void setMaxDistance(double? maxDistance) {
    _currentFilter = LocationAwareFilter(
      maxDistance: maxDistance,
      filterByArea: _currentFilter.filterByArea,
      sortByDistance: _currentFilter.sortByDistance,
      preferredCity: _currentFilter.preferredCity,
      preferredState: _currentFilter.preferredState,
    );
    _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Set area-based filtering
  void setAreaFiltering(bool enabled) {
    _currentFilter = LocationAwareFilter(
      maxDistance: _currentFilter.maxDistance,
      filterByArea: enabled,
      sortByDistance: _currentFilter.sortByDistance,
      preferredCity: _currentFilter.preferredCity,
      preferredState: _currentFilter.preferredState,
    );
    _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Set distance-based sorting
  void setDistanceSorting(bool enabled) {
    _currentFilter = LocationAwareFilter(
      maxDistance: _currentFilter.maxDistance,
      filterByArea: _currentFilter.filterByArea,
      sortByDistance: enabled,
      preferredCity: _currentFilter.preferredCity,
      preferredState: _currentFilter.preferredState,
    );
    _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Set preferred location
  void setPreferredLocation(String? city, String? state) {
    _currentFilter = LocationAwareFilter(
      maxDistance: _currentFilter.maxDistance,
      filterByArea: _currentFilter.filterByArea,
      sortByDistance: _currentFilter.sortByDistance,
      preferredCity: city,
      preferredState: state,
    );
    _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Apply location-aware filtering
  void _applyLocationAwareFiltering() {
    if (_allProducts.isEmpty) {
      _filteredProducts = [];
      return;
    }

    List<Product> filtered = List.from(_allProducts);

    // Apply area-based filtering if enabled and location is available
    if (_currentFilter.filterByArea &&
        _locationService.currentLocation != null) {
      filtered = _locationService.filterByArea(
        filtered,
        (product) => product.location?.city,
        (product) => product.location?.state,
        (product) => product.location?.area,
      );
    }

    // Apply preferred location filtering if set
    if (_currentFilter.preferredCity != null ||
        _currentFilter.preferredState != null) {
      filtered = filtered.where((product) {
        if (_currentFilter.preferredCity != null &&
            product.location?.city?.toLowerCase() !=
                _currentFilter.preferredCity!.toLowerCase()) {
          return false;
        }
        if (_currentFilter.preferredState != null &&
            product.location?.state?.toLowerCase() !=
                _currentFilter.preferredState!.toLowerCase()) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply distance-based filtering if location is available
    if (_currentFilter.maxDistance != null &&
        _locationService.currentLocation != null) {
      filtered = filtered.where((product) {
        if (product.location?.latitude == null ||
            product.location?.longitude == null) {
          return true; // Keep products without location data
        }

        final distance = _locationService.calculateDistanceTo(
          product.location!.latitude,
          product.location!.longitude,
        );

        return distance == null || distance <= _currentFilter.maxDistance!;
      }).toList();
    }

    // Apply distance-based sorting if enabled and location is available
    if (_currentFilter.sortByDistance &&
        _locationService.currentLocation != null) {
      filtered = _locationService.sortByDistance(
        filtered,
        (product) => product.location?.latitude ?? 0.0,
        (product) => product.location?.longitude ?? 0.0,
      );
    }

    _filteredProducts = filtered;
  }

  // Get distance information for a product
  Map<String, dynamic> getProductDistanceInfo(Product product) {
    if (product.location?.latitude == null ||
        product.location?.longitude == null) {
      return {
        'distance': null,
        'distanceText': 'Unknown',
        'isInSameArea': false,
        'isWithinRadius': false,
      };
    }

    final distance = _locationService.calculateDistanceTo(
      product.location!.latitude,
      product.location!.longitude,
    );

    final distanceInfo = _locationService.calculateDistanceWithArea(
      product.location!.latitude,
      product.location!.longitude,
      product.location?.city,
      product.location?.state,
    );

    return {
      'distance': distance,
      'distanceText':
          distance != null ? '${distance.toStringAsFixed(1)} km' : 'Unknown',
      'isInSameArea':
          distanceInfo['isInSameCity'] || distanceInfo['isInSameState'],
      'isWithinRadius':
          distance != null && distance <= (_currentFilter.maxDistance ?? 25.0),
      'isInSameCity': distanceInfo['isInSameCity'],
      'isInSameState': distanceInfo['isInSameState'],
    };
  }

  // Get nearby products (within specified radius)
  List<Product> getNearbyProducts(double radiusKm) {
    if (_locationService.currentLocation == null) return [];

    return _allProducts.where((product) {
      if (product.location?.latitude == null ||
          product.location?.longitude == null) {
        return false;
      }

      return _locationService.isWithinRadius(
        product.location!.latitude,
        product.location!.longitude,
        radiusKm,
      );
    }).toList();
  }

  // Get products by city
  List<Product> getProductsByCity(String city) {
    return _allProducts
        .where((product) =>
            product.location?.city?.toLowerCase() == city.toLowerCase())
        .toList();
  }

  // Get products by state
  List<Product> getProductsByState(String state) {
    return _allProducts
        .where((product) =>
            product.location?.state?.toLowerCase() == state.toLowerCase())
        .toList();
  }

  // Get location-based product statistics
  Map<String, dynamic> getLocationBasedStats() {
    final stats = <String, dynamic>{
      'totalProducts': _allProducts.length,
      'productsWithLocation': _allProducts
          .where((p) =>
              p.location?.latitude != null && p.location?.longitude != null)
          .length,
      'productsInSameCity': 0,
      'productsInSameState': 0,
      'productsWithin25km': 0,
      'productsWithin50km': 0,
      'cities': <String>{},
      'states': <String>{},
    };

    if (_locationService.currentLocation != null) {
      for (final product in _allProducts) {
        if (product.location?.city != null) {
          stats['cities'].add(product.location!.city!);
        }
        if (product.location?.state != null) {
          stats['states'].add(product.location!.state!);
        }

        if (product.location?.latitude != null &&
            product.location?.longitude != null) {
          final distance = _locationService.calculateDistanceTo(
            product.location!.latitude,
            product.location!.longitude,
          );

          if (distance != null) {
            if (distance <= 25) stats['productsWithin25km']++;
            if (distance <= 50) stats['productsWithin50km']++;
          }

          final distanceInfo = _locationService.calculateDistanceWithArea(
            product.location!.latitude,
            product.location!.longitude,
            product.location?.city,
            product.location?.state,
          );

          if (distanceInfo['isInSameCity']) stats['productsInSameCity']++;
          if (distanceInfo['isInSameState']) stats['productsInSameState']++;
        }
      }
    }

    return stats;
  }

  // Handle location changes
  void _onLocationChanged() {
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  // Load filter settings from storage
  Future<void> _loadFilterSettings() async {
    try {
      final maxDistance = _prefs.getDouble('location_filter_max_distance');
      final filterByArea = _prefs.getBool('location_filter_by_area') ?? true;
      final sortByDistance =
          _prefs.getBool('location_sort_by_distance') ?? true;
      final preferredCity = _prefs.getString('location_preferred_city');
      final preferredState = _prefs.getString('location_preferred_state');

      _currentFilter = LocationAwareFilter(
        maxDistance: maxDistance,
        filterByArea: filterByArea,
        sortByDistance: sortByDistance,
        preferredCity: preferredCity,
        preferredState: preferredState,
      );
    } catch (e) {
      // Use default filter settings
      _currentFilter = LocationAwareFilter();
    }
  }

  // Save filter settings to storage
  Future<void> _saveFilterSettings() async {
    try {
      if (_currentFilter.maxDistance != null) {
        await _prefs.setDouble(
            'location_filter_max_distance', _currentFilter.maxDistance!);
      } else {
        await _prefs.remove('location_filter_max_distance');
      }

      await _prefs.setBool(
          'location_filter_by_area', _currentFilter.filterByArea);
      await _prefs.setBool(
          'location_sort_by_distance', _currentFilter.sortByDistance);

      if (_currentFilter.preferredCity != null) {
        await _prefs.setString(
            'location_preferred_city', _currentFilter.preferredCity!);
      } else {
        await _prefs.remove('location_preferred_city');
      }

      if (_currentFilter.preferredState != null) {
        await _prefs.setString(
            'location_preferred_state', _currentFilter.preferredState!);
      } else {
        await _prefs.remove('location_preferred_state');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear all filter settings
  Future<void> clearFilterSettings() async {
    _currentFilter = LocationAwareFilter();
    await _saveFilterSettings();
    _applyLocationAwareFiltering();
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    super.dispose();
  }
}

// Provider for the location-aware filter service (defined in provider_registry.dart)
