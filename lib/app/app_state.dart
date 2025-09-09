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

  void setLocation({
    required String city,
    String? area,
    required String state,
    required double radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
  }) {
    this.city = city;
    this.area = area ?? this.area;
    this.state = state;
    this.radiusKm = radiusKm;
    this.mode = mode ?? this.mode;
    this.latitude = latitude;
    this.longitude = longitude;
    notifyListeners();
  }

  void setAdmin(bool value) {
    isAdmin = value;
    notifyListeners();
  }
}
