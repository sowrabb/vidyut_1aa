enum LocationMode { manual, auto }

class LocationState {
  final String city;
  final String area;
  final String stateName;
  final double radiusKm;
  final LocationMode mode;
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdated;

  const LocationState({
    this.city = 'Hyderabad',
    this.area = '',
    this.stateName = 'Telangana',
    this.radiusKm = 25,
    this.mode = LocationMode.manual,
    this.latitude,
    this.longitude,
    this.lastUpdated,
  });

  LocationState copyWith({
    String? city,
    String? area,
    String? stateName,
    double? radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
  }) {
    return LocationState(
      city: city ?? this.city,
      area: area ?? this.area,
      stateName: stateName ?? this.stateName,
      radiusKm: radiusKm ?? this.radiusKm,
      mode: mode ?? this.mode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
