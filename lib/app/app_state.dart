import 'package:flutter/foundation.dart';

enum LocationMode { manual, auto }

class AppState extends ChangeNotifier {
  String city = 'Hyderabad';
  String area = '';
  String state = 'Telangana';
  double radiusKm = 25;
  LocationMode mode = LocationMode.manual;
  double? latitude;
  double? longitude;
  bool isAdmin = false;
  
  // Callback system for location changes
  final List<VoidCallback> _locationChangeListeners = [];
  
  void addLocationChangeListener(VoidCallback listener) {
    _locationChangeListeners.add(listener);
  }
  
  void removeLocationChangeListener(VoidCallback listener) {
    _locationChangeListeners.remove(listener);
  }
  
  void _notifyLocationChange() {
    for (final listener in _locationChangeListeners) {
      listener();
    }
  }

  void setLocation({
    required String city,
    String? area,
    required String state,
    required double radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
  }) {
    final bool locationChanged = this.city != city || 
        this.state != state || 
        this.radiusKm != radiusKm ||
        this.latitude != latitude ||
        this.longitude != longitude;
        
    this.city = city;
    this.area = area ?? this.area;
    this.state = state;
    this.radiusKm = radiusKm;
    this.mode = mode ?? this.mode;
    this.latitude = latitude;
    this.longitude = longitude;
    
    notifyListeners();
    
    if (locationChanged) {
      _notifyLocationChange();
    }
  }
  
  void setCity(String city) {
    if (this.city != city) {
      this.city = city;
      notifyListeners();
      _notifyLocationChange();
    }
  }
  
  void setState(String state) {
    if (this.state != state) {
      this.state = state;
      notifyListeners();
      _notifyLocationChange();
    }
  }
  
  void setRadius(double radiusKm) {
    if (this.radiusKm != radiusKm) {
      this.radiusKm = radiusKm;
      notifyListeners();
      _notifyLocationChange();
    }
  }

  void setAdmin(bool value) {
    isAdmin = value;
    notifyListeners();
  }
}
