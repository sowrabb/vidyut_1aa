import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_aware_filter_service.dart';
import '../services/location_service.dart';
import '../../../app/provider_registry.dart';
import '../features/sell/models.dart';

class LocationAwareProductFilter extends ConsumerStatefulWidget {
  final VoidCallback? onFilterChanged;
  final bool showAdvancedOptions;

  const LocationAwareProductFilter({
    Key? key,
    this.onFilterChanged,
    this.showAdvancedOptions = true,
  }) : super(key: key);

  @override
  ConsumerState<LocationAwareProductFilter> createState() =>
      _LocationAwareProductFilterState();
}

class _LocationAwareProductFilterState
    extends ConsumerState<LocationAwareProductFilter> {
  double _currentDistance = 25.0;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final locationServiceAsync = ref.watch(locationServiceProvider);
    final filterServiceAsync = ref.watch(locationAwareFilterServiceProvider);

    return filterServiceAsync.when(
      data: (filterService) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
            // Filter Header
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location Filter'),
              subtitle:
                  _buildFilterSubtitle(locationServiceAsync, filterService),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showAdvancedOptions)
                  IconButton(
                    icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    filterServiceAsync.whenData((filterService) {
                      filterService.clearFilterSettings();
                      widget.onFilterChanged?.call();
                    });
                  },
                ),
              ],
            ),
          ),

          // Quick Filter Toggles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: filterServiceAsync.when(
              data: (filterService) => Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Same Area'),
                      selected: filterService.currentFilter.filterByArea,
                      onSelected: (selected) {
                        filterService.setAreaFiltering(selected);
                        widget.onFilterChanged?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Sort by Distance'),
                      selected: filterService.currentFilter.sortByDistance,
                      onSelected: (selected) {
                        filterService.setDistanceSorting(selected);
                        widget.onFilterChanged?.call();
                      },
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),

          // Advanced Options
          if (_isExpanded && widget.showAdvancedOptions) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance Filter
                  Text(
                    'Maximum Distance: ${_currentDistance.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: _currentDistance,
                    min: 5.0,
                    max: 100.0,
                    divisions: 19,
                    onChanged: (value) {
                      setState(() {
                        _currentDistance = value;
                      });
                      filterService.setMaxDistance(value);
                      widget.onFilterChanged?.call();
                    },
                  ),

                  // Location Status
                  locationServiceAsync.when(
                    data: (locationService) =>
                        _buildLocationStatus(locationService),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) => Text(
                      'Location error: $error',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),

                  // Filter Statistics
                  _buildFilterStatistics(filterService),
                ],
              ),
            ),
          ],

          // Current Filter Summary
          if (filterService.currentFilter.maxDistance != null ||
              filterService.currentFilter.preferredCity != null ||
              filterService.currentFilter.preferredState != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildFilterSummary(filterService),
            ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading location filter: $error'),
      ),
    );
  }

  Widget _buildFilterSubtitle(AsyncValue<LocationService> locationServiceAsync,
      LocationAwareFilterService filterService) {
    return locationServiceAsync.when(
      data: (locationService) {
        if (locationService.currentLocation != null) {
          final stats = filterService.getLocationBasedStats();
          return Text(
            '${stats['productsInSameCity']} in ${locationService.currentLocation!.city} • ${stats['productsWithin25km']} within 25km',
          );
        } else {
          return const Text('Enable location to filter by area');
        }
      },
      loading: () => const Text('Loading location...'),
      error: (error, stack) => const Text('Location unavailable'),
    );
  }

  Widget _buildLocationStatus(LocationService locationService) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            locationService.hasLocation ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: locationService.hasLocation
              ? Colors.green[200]!
              : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            locationService.hasLocation
                ? Icons.location_on
                : Icons.location_off,
            color: locationService.hasLocation
                ? Colors.green[600]
                : Colors.orange[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationService.hasLocation
                      ? 'Location Active'
                      : 'Location Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: locationService.hasLocation
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
                if (locationService.hasLocation) ...[
                  Text(
                    '${locationService.currentLocation!.city}, ${locationService.currentLocation!.state}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Tap to enable location services',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!locationService.hasLocation)
            TextButton(
              onPressed: () async {
                await locationService.getCurrentLocation();
              },
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterStatistics(LocationAwareFilterService filterService) {
    final stats = filterService.getLocationBasedStats();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Statistics',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Products',
                  '${stats['totalProducts']}',
                  Icons.inventory,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'With Location',
                  '${stats['productsWithLocation']}',
                  Icons.location_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Same City',
                  '${stats['productsInSameCity']}',
                  Icons.location_city,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Within 25km',
                  '${stats['productsWithin25km']}',
                  Icons.straighten,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSummary(LocationAwareFilterService filterService) {
    final activeFilters = <String>[];

    if (filterService.currentFilter.maxDistance != null) {
      activeFilters.add(
          'Max ${filterService.currentFilter.maxDistance!.toStringAsFixed(0)}km');
    }

    if (filterService.currentFilter.preferredCity != null) {
      activeFilters.add('City: ${filterService.currentFilter.preferredCity}');
    }

    if (filterService.currentFilter.preferredState != null) {
      activeFilters.add('State: ${filterService.currentFilter.preferredState}');
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Active filters: ${activeFilters.join(', ')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationAwareProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const LocationAwareProductCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterServiceAsync = ref.watch(locationAwareFilterServiceProvider);

    return filterServiceAsync.when(
      data: (filterService) {
        final distanceInfo = filterService.getProductDistanceInfo(product);
        return Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Product Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location Info
              if (product.location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: distanceInfo['isInSameArea']
                          ? Colors.green[600]
                          : Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${product.location!.city}, ${product.location!.state}',
                        style: TextStyle(
                          fontSize: 12,
                          color: distanceInfo['isInSameArea']
                              ? Colors.green[600]
                              : Colors.orange[600],
                        ),
                      ),
                    ),
                    if (distanceInfo['distance'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: distanceInfo['isWithinRadius']
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          distanceInfo['distanceText'],
                          style: TextStyle(
                            fontSize: 10,
                            color: distanceInfo['isWithinRadius']
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.location_off, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Location not available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading filter: $error'),
        ),
      ),
    );
  }
}
