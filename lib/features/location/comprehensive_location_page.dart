import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/location_service.dart';
import '../../../app/provider_registry.dart';

class ComprehensiveLocationPage extends ConsumerStatefulWidget {
  const ComprehensiveLocationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ComprehensiveLocationPage> createState() =>
      _ComprehensiveLocationPageState();
}

class _ComprehensiveLocationPageState
    extends ConsumerState<ComprehensiveLocationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<LocationData> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationServiceAsync = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Services'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Current'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: locationServiceAsync.when(
        data: (locationService) => TabBarView(
          controller: _tabController,
          children: [
            _buildCurrentLocationTab(locationService),
            _buildLocationSearchTab(locationService),
            _buildLocationHistoryTab(locationService),
            _buildLocationSettingsTab(locationService),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading location services: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(locationServiceProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTab(LocationService locationService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (locationService.currentLocation != null) ...[
                    _buildLocationInfo(locationService.currentLocation!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await locationService.getCurrentLocation();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              locationService.startEnhancedLocationTracking();
                            },
                            icon: const Icon(Icons.track_changes),
                            label: const Text('Track'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text('No location available'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await locationService.getCurrentLocation();
                      },
                      icon: const Icon(Icons.location_searching),
                      label: const Text('Get Current Location'),
                    ),
                  ],
                  if (locationService.isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (locationService.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationService.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location Features Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    Icons.gps_fixed,
                    'GPS Location Detection',
                    'Automatic location detection enabled',
                    locationService.isAutoLocationEnabled,
                    onToggle: (value) async {
                      await locationService.setAutoLocationEnabled(value);
                    },
                  ),
                  _buildFeatureTile(
                    Icons.offline_bolt,
                    'Offline Mode',
                    'Use last known location when offline',
                    locationService.isOfflineMode,
                    onToggle: (value) async {
                      await locationService.setOfflineMode(value);
                    },
                  ),
                  _buildFeatureTile(
                    Icons.filter_list,
                    'Area-based Filtering',
                    'Filter products by your area',
                    true, // Always enabled
                  ),
                  _buildFeatureTile(
                    Icons.straighten,
                    'Distance Calculation',
                    'Calculate distances to sellers',
                    true, // Always enabled
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(LocationData location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('City', location.city),
        if (location.area != null) _buildInfoRow('Area', location.area!),
        _buildInfoRow('State', location.state),
        _buildInfoRow('Country', location.country),
        _buildInfoRow('Accuracy', '${location.accuracy.toStringAsFixed(1)}m'),
        _buildInfoRow('Coordinates',
            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'),
        _buildInfoRow('Last Updated', _formatTimestamp(location.timestamp)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    IconData icon,
    String title,
    String subtitle,
    bool value, {
    Function(bool)? onToggle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onToggle != null
          ? Switch(
              value: value,
              onChanged: onToggle,
            )
          : Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: value ? Colors.green : Colors.red,
            ),
    );
  }

  Widget _buildLocationSearchTab(LocationService locationService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for cities or locations...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _performLocationSearch(locationService, value);
            },
          ),

          const SizedBox(height: 16),

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchQuery.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Search for cities or locations',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No locations found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final location = _searchResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.location_city),
                                  title: Text(location.city),
                                  subtitle: Text(
                                      '${location.state}, ${location.country}'),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      await locationService
                                          .setLocationFromSearch(location);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Location set to ${location.city}'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Select'),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHistoryTab(LocationService locationService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (locationService.locationHistory.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                            'Are you sure you want to clear all location history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await locationService.clearLocationHistory();
                    }
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: locationService.locationHistory.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No location history yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: locationService.locationHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem =
                          locationService.locationHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(historyItem.location),
                          subtitle: Text(
                            'Used ${historyItem.usageCount} time${historyItem.usageCount > 1 ? 's' : ''} • ${_formatTimestamp(historyItem.timestamp)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.location_searching),
                                onPressed: () async {
                                  if (historyItem.latitude != null &&
                                      historyItem.longitude != null) {
                                    final location = LocationData(
                                      latitude: historyItem.latitude!,
                                      longitude: historyItem.longitude!,
                                      city: historyItem.location,
                                      state: 'Unknown',
                                      country: 'India',
                                      accuracy: 100.0,
                                      timestamp: DateTime.now(),
                                    );
                                    await locationService
                                        .setLocationFromSearch(location);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Location set to ${historyItem.location}'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await locationService
                                      .removeLocationFromHistory(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSettingsTab(LocationService locationService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Services Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Automatic Location Detection'),
                    subtitle: const Text(
                        'Automatically detect and update your location'),
                    value: locationService.isAutoLocationEnabled,
                    onChanged: (value) async {
                      await locationService.setAutoLocationEnabled(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Offline Mode'),
                    subtitle:
                        const Text('Use last known location when offline'),
                    value: locationService.isOfflineMode,
                    onChanged: (value) async {
                      await locationService.setOfflineMode(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Permission Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permission Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (locationService.permissionStatus != null) ...[
                    _buildPermissionStatus(locationService.permissionStatus!),
                    const SizedBox(height: 16),
                    if (!locationService.permissionStatus!.isGranted)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await locationService.requestPermission();
                        },
                        icon: const Icon(Icons.security),
                        label: const Text('Request Permission'),
                      ),
                  ] else ...[
                    const Text('Checking permission status...'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text('Clear Cached Location'),
                    subtitle: const Text('Remove stored location data'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await locationService.clearCachedLocation();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cached location cleared'),
                            ),
                          );
                        }
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatus(LocationPermissionStatus status) {
    return Column(
      children: [
        _buildStatusRow('Granted', status.isGranted),
        _buildStatusRow('Denied', status.isDenied),
        _buildStatusRow('Permanently Denied', status.isPermanentlyDenied),
        _buildStatusRow('Can Request', status.canRequest),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Future<void> _performLocationSearch(
      LocationService locationService, String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await locationService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
