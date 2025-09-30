import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for OpenStreetMap Nominatim API integration
class OpenStreetMapService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Search for locations based on query
  static Future<List<LocationSuggestion>> searchLocations(String query,
      {String? currentCity}) async {
    if (query.trim().isEmpty) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$_baseUrl/search?format=json&q=$encodedQuery&countrycodes=in&limit=15&addressdetails=1&extratags=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'VidyutApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final suggestions =
            data.map((item) => LocationSuggestion.fromJson(item)).toList();

        // Prioritize current city suggestions
        return _prioritizeSuggestions(suggestions, currentCity);
      }
    } catch (e) {
      print('Error searching locations: $e');
    }

    return [];
  }

  /// Prioritize suggestions from current city
  static List<LocationSuggestion> _prioritizeSuggestions(
      List<LocationSuggestion> suggestions, String? currentCity) {
    if (currentCity == null || currentCity.isEmpty) return suggestions;

    final currentCityLower = currentCity.toLowerCase();
    final currentCitySuggestions = <LocationSuggestion>[];
    final otherSuggestions = <LocationSuggestion>[];

    for (final suggestion in suggestions) {
      if (suggestion.city.toLowerCase() == currentCityLower) {
        currentCitySuggestions.add(suggestion);
      } else {
        otherSuggestions.add(suggestion);
      }
    }

    // Take first 5 from current city, then add others
    final prioritized = <LocationSuggestion>[];
    prioritized.addAll(currentCitySuggestions.take(5));
    prioritized.addAll(otherSuggestions);

    return prioritized;
  }

  /// Reverse geocode coordinates to get address
  static Future<LocationSuggestion?> reverseGeocode(
      double lat, double lng) async {
    try {
      final url =
          '$_baseUrl/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'VidyutApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LocationSuggestion.fromReverseGeocode(data);
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }

    return null;
  }
}

/// Model for location suggestions from OpenStreetMap
class LocationSuggestion {
  final String displayName;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final String? area;
  final String? pincode;

  const LocationSuggestion({
    required this.displayName,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.area,
    this.pincode,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};

    // Extract city name with better fallbacks
    String city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['hamlet'] ??
        address['county'] ??
        'Unknown';

    // Extract state name
    String state = address['state'] ?? address['region'] ?? 'Unknown';

    // Extract comprehensive area information
    final areaParts = <String>[];

    // Add specific area components
    if (address['suburb'] != null) areaParts.add(address['suburb']);
    if (address['neighbourhood'] != null)
      areaParts.add(address['neighbourhood']);
    if (address['quarter'] != null) areaParts.add(address['quarter']);
    if (address['road'] != null) areaParts.add(address['road']);
    if (address['house_number'] != null) areaParts.add(address['house_number']);

    String? area;
    if (areaParts.isNotEmpty) {
      area = areaParts.join(', ');
    }

    // Extract pincode
    String? pincode = address['postcode'];

    // Create comprehensive display name
    String displayName = json['display_name'] ?? '';

    // If display name is too long, create a shorter version
    if (displayName.length > 80) {
      final shortParts = <String>[];
      if (area != null && area.isNotEmpty) shortParts.add(area);
      shortParts.add(city);
      shortParts.add(state);
      displayName = shortParts.join(', ');
    }

    return LocationSuggestion(
      displayName: displayName,
      city: city,
      state: state,
      country: address['country'] ?? 'India',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      area: area,
      pincode: pincode,
    );
  }

  factory LocationSuggestion.fromReverseGeocode(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};

    String city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['hamlet'] ??
        'Unknown';

    String state = address['state'] ?? 'Unknown';
    String? area =
        address['suburb'] ?? address['neighbourhood'] ?? address['quarter'];
    String? pincode = address['postcode'];

    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      city: city,
      state: state,
      country: address['country'] ?? 'India',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      area: area,
      pincode: pincode,
    );
  }

  /// Get a formatted display string for the location
  String get formattedAddress {
    final parts = <String>[];

    // Add area components if available
    if (area != null && area!.isNotEmpty) {
      parts.add(area!);
    }

    // Add city
    parts.add(city);

    // Add state only if it's different from city
    if (state != 'Unknown' && state.toLowerCase() != city.toLowerCase()) {
      parts.add(state);
    }

    return parts.join(', ');
  }

  /// Get a short display string
  String get shortDisplay {
    return '$city, $state';
  }
}
