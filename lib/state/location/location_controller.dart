import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase_providers.dart';
import 'location_state.dart';

const _locationPrefsKey = 'app_location_state';

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>(LocationController.new);

class LocationController extends StateNotifier<LocationState> {
  LocationController(this._ref) : super(const LocationState()) {
    _restoreFromStorage();
  }

  final Ref _ref;

  Future<void> setLocation({
    required String city,
    String? area,
    required String stateName,
    required double radiusKm,
    LocationMode? mode,
    double? latitude,
    double? longitude,
  }) async {
    final next = state.copyWith(
      city: city,
      area: area,
      stateName: stateName,
      radiusKm: radiusKm,
      mode: mode,
      latitude: latitude,
      longitude: longitude,
      lastUpdated: DateTime.now(),
    );
    state = next;
    await _persist(next);
  }

  Future<void> setCity(String city) async {
    if (city == state.city) return;
    await setLocation(
      city: city,
      area: state.area,
      stateName: state.stateName,
      radiusKm: state.radiusKm,
      mode: state.mode,
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

  Future<void> setStateName(String newState) async {
    if (newState == state.stateName) return;
    await setLocation(
      city: state.city,
      area: state.area,
      stateName: newState,
      radiusKm: state.radiusKm,
      mode: state.mode,
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

  Future<void> setRadius(double radiusKm) async {
    if (radiusKm == state.radiusKm) return;
    await setLocation(
      city: state.city,
      area: state.area,
      stateName: state.stateName,
      radiusKm: radiusKm,
      mode: state.mode,
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

  Future<void> setMode(LocationMode mode) async {
    if (mode == state.mode) return;
    await setLocation(
      city: state.city,
      area: state.area,
      stateName: state.stateName,
      radiusKm: state.radiusKm,
      mode: mode,
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

  Future<void> setCoordinates(double latitude, double longitude) async {
    await setLocation(
      city: state.city,
      area: state.area,
      stateName: state.stateName,
      radiusKm: state.radiusKm,
      mode: state.mode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> resetToDefault() async {
    const defaults = LocationState();
    state = defaults;
    await _persist(defaults);
  }

  Future<void> _restoreFromStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = prefs.getString(_locationPrefsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return;
      }
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final restored = LocationState(
        city: data['city'] as String? ?? 'Hyderabad',
        area: data['area'] as String? ?? '',
        stateName: data['state'] as String? ?? 'Telangana',
        radiusKm: (data['radiusKm'] as num?)?.toDouble() ?? 25,
        mode: LocationMode.values.firstWhere(
          (mode) => mode.name == (data['mode'] as String? ?? 'manual'),
          orElse: () => LocationMode.manual,
        ),
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        lastUpdated: data['lastUpdated'] != null
            ? DateTime.tryParse(data['lastUpdated'] as String)
            : null,
      );
      state = restored;
    } catch (e) {
      // Ignore corrupted data but reset to defaults for safety.
      state = const LocationState();
    }
  }

  Future<void> _persist(LocationState value) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final payload = json.encode({
      'city': value.city,
      'area': value.area,
      'state': value.stateName,
      'radiusKm': value.radiusKm,
      'mode': value.mode.name,
      'latitude': value.latitude,
      'longitude': value.longitude,
      'lastUpdated': value.lastUpdated?.toIso8601String(),
    });
    await prefs.setString(_locationPrefsKey, payload);
  }
}
