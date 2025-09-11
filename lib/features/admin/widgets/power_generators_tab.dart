// Power Generators Management Tab
// Complete CRUD interface for managing power generator entities

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/tokens.dart';
import '../store/admin_store.dart';
import '../models/state_flow_admin_models.dart';
import 'state_flow_admin_widgets.dart';

class PowerGeneratorsTab extends StatefulWidget {
  const PowerGeneratorsTab({super.key});

  @override
  State<PowerGeneratorsTab> createState() => _PowerGeneratorsTabState();
}

class _PowerGeneratorsTabState extends State<PowerGeneratorsTab> {
  final _searchController = TextEditingController();
  StateFlowSearchFilter _currentFilter = const StateFlowSearchFilter();
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _showPublishedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, store, child) {
        final generators = _getFilteredAndSortedGenerators(store);
        
        return Column(
          children: [
            _buildHeader(context, store),
            _buildFiltersBar(context, store),
            Expanded(
              child: generators.isEmpty 
                  ? _buildEmptyState(context, store)
                  : _buildGeneratorsList(context, store, generators),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AdminStore store) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.power, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Power Generators',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _buildStatsChips(store),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddGeneratorDialog(context, store),
            icon: const Icon(Icons.add),
            label: const Text('Add Generator'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChips(AdminStore store) {
    final total = store.adminPowerGenerators.length;
    final published = store.publishedPowerGenerators.length;
    final drafts = total - published;

    return Row(
      children: [
        _StatsChip(
          label: 'Total',
          count: total,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _StatsChip(
          label: 'Published',
          count: published,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _StatsChip(
          label: 'Drafts',
          count: drafts,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFiltersBar(BuildContext context, AdminStore store) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search generators...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              _buildSortDropdown(),
              const SizedBox(width: 12),
              _buildFilterChips(),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      items: const [
        DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
        DropdownMenuItem(value: 'type', child: Text('Sort by Type')),
        DropdownMenuItem(value: 'capacity', child: Text('Sort by Capacity')),
        DropdownMenuItem(value: 'created', child: Text('Sort by Created')),
        DropdownMenuItem(value: 'updated', child: Text('Sort by Updated')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortBy = value;
          });
        }
      },
      underline: const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Published Only'),
          selected: _showPublishedOnly,
          onSelected: (selected) {
            setState(() {
              _showPublishedOnly = selected;
            });
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          tooltip: _sortAscending ? 'Sort Descending' : 'Sort Ascending',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showAdvancedFilters(context),
          tooltip: 'Advanced Filters',
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final filters = <Widget>[];
    
    if (_currentFilter.query?.isNotEmpty == true) {
      filters.add(_FilterChip(
        label: 'Search: ${_currentFilter.query}',
        onRemove: () => _removeFilter('query'),
      ));
    }
    
    if (_currentFilter.location?.isNotEmpty == true) {
      filters.add(_FilterChip(
        label: 'Location: ${_currentFilter.location}',
        onRemove: () => _removeFilter('location'),
      ));
    }
    
    if (_currentFilter.tags?.isNotEmpty == true) {
      filters.add(_FilterChip(
        label: 'Tags: ${_currentFilter.tags!.join(', ')}',
        onRemove: () => _removeFilter('tags'),
      ));
    }

    if (filters.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Text('Active filters: '),
        ...filters,
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text('Clear all'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AdminStore store) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.power_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Power Generators Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters() 
                ? 'Try adjusting your filters or search terms'
                : 'Get started by adding your first power generator',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGeneratorDialog(context, store),
            icon: const Icon(Icons.add),
            label: const Text('Add Generator'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorsList(BuildContext context, AdminStore store, List<AdminPowerGenerator> generators) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: generators.length,
      itemBuilder: (context, index) {
        final generator = generators[index];
        return _GeneratorCard(
          generator: generator,
          onEdit: () => _showEditGeneratorDialog(context, store, generator),
          onDelete: () => _showDeleteConfirmation(context, store, generator),
          onTogglePublished: () => _togglePublished(store, generator),
          onViewAnalytics: () => _showAnalytics(context, store, generator),
        );
      },
    );
  }

  List<AdminPowerGenerator> _getFilteredAndSortedGenerators(AdminStore store) {
    var generators = store.adminPowerGenerators.toList();

    // Apply published filter
    if (_showPublishedOnly) {
      generators = generators.where((g) => g.isPublished).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      generators = generators.where((g) {
        return g.name.toLowerCase().contains(query) ||
               g.description.toLowerCase().contains(query) ||
               g.location.toLowerCase().contains(query) ||
               g.type.toLowerCase().contains(query);
      }).toList();
    }

    // Apply advanced filters
    if (_currentFilter.location?.isNotEmpty == true) {
      generators = generators.where((g) => 
          g.location.toLowerCase().contains(_currentFilter.location!.toLowerCase())).toList();
    }

    if (_currentFilter.tags?.isNotEmpty == true) {
      generators = generators.where((g) => 
          _currentFilter.tags!.any((tag) => g.tags.contains(tag))).toList();
    }

    // Sort generators
    generators.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'capacity':
          comparison = a.capacity.compareTo(b.capacity);
          break;
        case 'created':
          // Note: AdminPowerGenerator doesn't have createdAt, using name as fallback
          comparison = a.name.compareTo(b.name);
          break;
        case 'updated':
          // Note: AdminPowerGenerator doesn't have updatedAt, using name as fallback
          comparison = a.name.compareTo(b.name);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return generators;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(query: query.isEmpty ? null : query);
    });
  }

  void _removeFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'query':
          _searchController.clear();
          _currentFilter = _currentFilter.copyWith(query: null);
          break;
        case 'location':
          _currentFilter = _currentFilter.copyWith(location: null);
          break;
        case 'tags':
          _currentFilter = _currentFilter.copyWith(tags: null);
          break;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _currentFilter = const StateFlowSearchFilter();
      _showPublishedOnly = false;
    });
  }

  bool _hasActiveFilters() {
    return _currentFilter.query?.isNotEmpty == true ||
           _currentFilter.location?.isNotEmpty == true ||
           _currentFilter.tags?.isNotEmpty == true ||
           _showPublishedOnly;
  }

  void _showAdvancedFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AdvancedFiltersDialog(
        currentFilter: _currentFilter,
        onApply: (filter) {
          setState(() {
            _currentFilter = filter;
          });
        },
      ),
    );
  }

  void _showAddGeneratorDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => AddEditPowerGeneratorDialog(store: store),
    );
  }

  void _showEditGeneratorDialog(BuildContext context, AdminStore store, AdminPowerGenerator generator) {
    showDialog(
      context: context,
      builder: (context) => AddEditPowerGeneratorDialog(
        store: store,
        generator: generator,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AdminStore store, AdminPowerGenerator generator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Generator'),
        content: Text('Are you sure you want to delete "${generator.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await store.deleteAdminPowerGenerator(generator.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${generator.name} deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _togglePublished(AdminStore store, AdminPowerGenerator generator) async {
    await store.togglePowerGeneratorPublished(generator.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${generator.name} ${generator.isPublished ? 'unpublished' : 'published'} successfully',
          ),
        ),
      );
    }
  }

  void _showAnalytics(BuildContext context, AdminStore store, AdminPowerGenerator generator) {
    showDialog(
      context: context,
      builder: (context) => _AnalyticsDialog(
        generator: generator,
        store: store,
      ),
    );
  }
}

// Helper Widgets

class _StatsChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatsChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  final AdminPowerGenerator generator;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublished;
  final VoidCallback onViewAnalytics;

  const _GeneratorCard({
    required this.generator,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            generator.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(isPublished: generator.isPublished),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${generator.type} • ${generator.capacity} • ${generator.location}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onTogglePublished();
                        break;
                      case 'analytics':
                        onViewAnalytics();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(generator.isPublished ? Icons.visibility_off : Icons.visibility),
                        title: Text(generator.isPublished ? 'Unpublish' : 'Publish'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'analytics',
                      child: ListTile(
                        leading: Icon(Icons.analytics),
                        title: Text('Analytics'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              generator.description,
              style: TextStyle(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.business,
                  label: generator.totalPlants.toString(),
                  tooltip: 'Total Plants',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people,
                  label: generator.employees,
                  tooltip: 'Employees',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.monetization_on,
                  label: generator.revenue,
                  tooltip: 'Revenue',
                ),
                if (generator.tags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ...generator.tags.take(3).map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )),
                  if (generator.tags.length > 3)
                    Text('+${generator.tags.length - 3} more'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPublished;

  const _StatusBadge({required this.isPublished});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPublished ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isPublished ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Advanced Filters Dialog
class _AdvancedFiltersDialog extends StatefulWidget {
  final StateFlowSearchFilter currentFilter;
  final Function(StateFlowSearchFilter) onApply;

  const _AdvancedFiltersDialog({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<_AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<_AdvancedFiltersDialog> {
  late StateFlowSearchFilter _filter;
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _locationController.text = _filter.location ?? '';
    if (_filter.tags != null) {
      _selectedTags.addAll(_filter.tags!);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Advanced Filters'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedTags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedTags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  },
                )).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _tagController.clear();
      _selectedTags.clear();
    });
  }

  void _applyFilters() {
    final filter = StateFlowSearchFilter(
      query: _filter.query,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
      isPublished: _filter.isPublished,
    );
    widget.onApply(filter);
    Navigator.of(context).pop();
  }
}

// Analytics Dialog
class _AnalyticsDialog extends StatelessWidget {
  final AdminPowerGenerator generator;
  final AdminStore store;

  const _AnalyticsDialog({
    required this.generator,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Analytics - ${generator.name}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: FutureBuilder<StateFlowAnalytics>(
          future: store.getEntityAnalytics(generator.id, EntityType.powerGenerator),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            
            final analytics = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnalyticsCard(
                    title: 'Views',
                    value: analytics.viewCount.toString(),
                    subtitle: '${analytics.uniqueViewers} unique viewers',
                    icon: Icons.visibility,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _AnalyticsCard(
                    title: 'Avg. Time Spent',
                    value: '${analytics.avgTimeSpent.toStringAsFixed(1)}s',
                    subtitle: 'Per session',
                    icon: Icons.timer,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Top Tab Views',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...analytics.tabViews.entries.map((entry) => ListTile(
                    title: Text(entry.key),
                    trailing: Text('${entry.value} views'),
                    dense: true,
                  )),
                  const SizedBox(height: 16),
                  const Text(
                    'Device Types',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...analytics.deviceTypes.entries.map((entry) => ListTile(
                    title: Text(entry.key),
                    trailing: Text('${entry.value}%'),
                    dense: true,
                  )),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
