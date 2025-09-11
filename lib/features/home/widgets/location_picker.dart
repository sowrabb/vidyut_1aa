import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// tiny model shared with location button
class LocationResult {
  final String city;
  final String? area;
  final String state;
  final double radiusKm;
  final bool isAuto;
  final double? latitude;
  final double? longitude;
  const LocationResult(this.city, this.state, this.radiusKm,
      {this.area, this.isAuto = false, this.latitude, this.longitude});
}

class LocationPicker extends StatefulWidget {
  final String city;
  final String state;
  final double radiusKm;

  const LocationPicker({
    super.key,
    required this.city,
    required this.state,
    required this.radiusKm,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late TextEditingController _city;
  late TextEditingController _state;
  late double _radius;
  bool _auto = false;
  double? _lat;
  double? _lng;
  String? _area;

  @override
  void initState() {
    super.initState();
    _city = TextEditingController(text: widget.city);
    _state = TextEditingController(text: widget.state);
    _radius = widget.radiusKm;
  }

  @override
  void dispose() {
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center =
        LatLng(_lat ?? 17.3850, _lng ?? 78.4867); // default: Hyderabad
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Manual'),
                    icon: Icon(Icons.edit_location_alt_outlined)),
                ButtonSegment(
                    value: true,
                    label: Text('Auto'),
                    icon: Icon(Icons.my_location_outlined)),
              ],
              selected: {_auto},
              onSelectionChanged: (s) => setState(() => _auto = s.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _state,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_auto)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 12,
                      onTap: (tapPos, latLng) {
                        setState(() {
                          _lat = latLng.latitude;
                          _lng = latLng.longitude;
                        });
                        _reverseGeocode(latLng.latitude, latLng.longitude);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.vidyut.app',
                      ),
                      if (_lat != null && _lng != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(_lat!, _lng!),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 32),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            if (_auto)
              Row(children: [
                Expanded(
                    child: Text(_lat == null
                        ? 'Location not fetched'
                        : '${_area ?? 'Fetching area...'} • Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}')),
                TextButton(
                  onPressed: () => _getCurrentLocation(),
                  child: const Text('Use current location'),
                ),
              ]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Radius: ${_radius.toStringAsFixed(0)} km',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Slider(
              value: _radius.clamp(5, 200),
              min: 5,
              max: 200,
              divisions: 39,
              label: '${_radius.toStringAsFixed(0)} km',
              onChanged: (v) => setState(() => _radius = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        LocationResult(
                          _city.text.trim(),
                          _state.text.trim(),
                          _radius,
                          area: _area,
                          isAuto: _auto,
                          latitude: _lat,
                          longitude: _lng,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon');
      final resp = await http.get(uri, headers: {'User-Agent': 'vidyut/1.0'});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>?;
        final suburb = addr?['suburb'] ??
            addr?['neighbourhood'] ??
            addr?['city_district'] ??
            addr?['village'] ??
            addr?['town'];
        final city = addr?['city'] ??
            addr?['town'] ??
            addr?['village'] ??
            addr?['state_district'] ??
            '';
        if (!mounted) return;
        setState(() {
          _area = suburb?.toString();
          // Only overwrite if city was empty or differs significantly
          _city.text = (city?.toString().isNotEmpty == true)
              ? city.toString()
              : _city.text;
        });
      }
    } catch (_) {
      // ignore failure silently
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
            ),
          );
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied. Please grant permission to use auto-location.'),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
            ),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
        await _reverseGeocode(_lat!, _lng!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
          ),
        );
        // Fallback to Hyderabad coordinates
        setState(() {
          _lat = 17.3850;
          _lng = 78.4867;
        });
        await _reverseGeocode(_lat!, _lng!);
      }
    }
  }
}
