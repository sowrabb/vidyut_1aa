import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

@immutable
class AppStateData {
  final String city;
  final String area;
  final String state;
  final double radiusKm;
  final LocationMode mode;
  final double? latitude;
  final double? longitude;
  final bool isAdmin;

  const AppStateData({
    this.city = 'Hyderabad',
    this.area = '',
    this.state = 'Telangana',
    this.radiusKm = 25,
    this.mode = LocationMode.manual,
    this.latitude,
    this.longitude,
    this.isAdmin = false,
  });

  AppStateData copyWith({
    String? city,
    String? area,
    String? state,
    double? radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
    bool? isAdmin,
  }) {
    return AppStateData(
      city: city ?? this.city,
      area: area ?? this.area,
      state: state ?? this.state,
      radiusKm: radiusKm ?? this.radiusKm,
      mode: mode ?? this.mode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AppStateNotifier extends Notifier<AppStateData> {
  @override
  AppStateData build() {
    return const AppStateData();
  }

  void setLocation({
    required String city,
    String? area,
    required String stateName,
    required double radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      city: city,
      area: area ?? state.area,
      state: stateName,
      radiusKm: radiusKm,
      mode: mode ?? state.mode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void setCity(String city) {
    if (state.city != city) {
      state = state.copyWith(city: city);
    }
  }

  void setStateName(String newState) {
    if (state.state != newState) {
      state = state.copyWith(state: newState);
    }
  }

  void setRadius(double radiusKm) {
    if (state.radiusKm != radiusKm) {
      state = state.copyWith(radiusKm: radiusKm);
    }
  }

  void setAdmin(bool value) {
    state = state.copyWith(isAdmin: value);
  }
}
