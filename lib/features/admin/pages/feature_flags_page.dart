import 'package:flutter/material.dart';
import '../models/feature_flags_models.dart';

class FeatureFlagsPage extends StatefulWidget {
  const FeatureFlagsPage({super.key});

  @override
  State<FeatureFlagsPage> createState() => _FeatureFlagsPageState();
}

class _FeatureFlagsPageState extends State<FeatureFlagsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Flags'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Flags', icon: Icon(Icons.flag)),
            Tab(text: 'Kill Switches', icon: Icon(Icons.power_settings_new)),
            Tab(text: 'Experiments', icon: Icon(Icons.science)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeatureFlagsTab(),
          KillSwitchesTab(),
          ExperimentsTab(),
        ],
      ),
    );
  }
}

class FeatureFlagsTab extends StatefulWidget {
  const FeatureFlagsTab({super.key});

  @override
  State<FeatureFlagsTab> createState() => _FeatureFlagsTabState();
}

class _FeatureFlagsTabState extends State<FeatureFlagsTab> {
  List<FeatureFlag> _featureFlags = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFeatureFlags();
  }

  Future<void> _loadFeatureFlags() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));

      _featureFlags = [
        FeatureFlag(
          id: '1',
          name: 'New Dashboard UI',
          description: 'Enable the new dashboard user interface',
          key: 'new_dashboard_ui',
          isEnabled: true,
          type: FeatureFlagType.boolean,
          defaultValue: {'value': true},
          environments: [
            FeatureFlagEnvironment(
              id: '1',
              name: 'Production',
              environment: 'production',
              isEnabled: true,
              value: {'value': true},
              targetingRules: [],
              lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            FeatureFlagEnvironment(
              id: '2',
              name: 'Staging',
              environment: 'staging',
              isEnabled: true,
              value: {'value': true},
              targetingRules: [],
              lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
          targetingRules: [
            TargetingRule(
              id: '1',
              name: 'Admin Users',
              type: TargetingRuleType.user,
              conditions: {'role': 'admin'},
              value: {'value': true},
              priority: 1,
              isActive: true,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
            ),
          ],
          tags: ['ui', 'dashboard'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdBy: 'admin@vidyut.com',
          isActive: true,
        ),
        FeatureFlag(
          id: '2',
          name: 'Advanced Search',
          description: 'Enable advanced search functionality with filters',
          key: 'advanced_search',
          isEnabled: false,
          type: FeatureFlagType.boolean,
          defaultValue: {'value': false},
          environments: [
            FeatureFlagEnvironment(
              id: '3',
              name: 'Production',
              environment: 'production',
              isEnabled: false,
              value: {'value': false},
              targetingRules: [],
              lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          targetingRules: [],
          tags: ['search', 'beta'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          createdBy: 'product@vidyut.com',
          isActive: true,
        ),
        FeatureFlag(
          id: '3',
          name: 'Payment Gateway',
          description: 'Select payment gateway provider',
          key: 'payment_gateway',
          isEnabled: true,
          type: FeatureFlagType.string,
          defaultValue: {'value': 'stripe'},
          environments: [
            FeatureFlagEnvironment(
              id: '4',
              name: 'Production',
              environment: 'production',
              isEnabled: true,
              value: {'value': 'stripe'},
              targetingRules: [],
              lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
            ),
          ],
          targetingRules: [
            TargetingRule(
              id: '2',
              name: 'India Users',
              type: TargetingRuleType.geo,
              conditions: {'country': 'IN'},
              value: {'value': 'razorpay'},
              priority: 1,
              isActive: true,
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              updatedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          tags: ['payment', 'integration'],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
          createdBy: 'engineering@vidyut.com',
          isActive: true,
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<FeatureFlag> get _filteredFlags {
    var filtered = _featureFlags;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((flag) =>
              flag.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              flag.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              flag.key.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_showActiveOnly) {
      filtered = filtered.where((flag) => flag.isActive).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeatureFlags,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search feature flags...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _createFeatureFlag,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Flag'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Active Only'),
                    selected: _showActiveOnly,
                    onSelected: (selected) {
                      setState(() {
                        _showActiveOnly = selected;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${_filteredFlags.length} flags'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Feature Flags List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFeatureFlags,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredFlags.length,
              itemBuilder: (context, index) {
                final flag = _filteredFlags[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          flag.isEnabled ? Colors.green : Colors.grey,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(flag.name)),
                        if (flag.isEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ON',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(flag.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Key: ${flag.key}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Type: ${flag.type.value}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (flag.tags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: flag.tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleFlagAction(flag, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(Icons.toggle_on),
                              SizedBox(width: 8),
                              Text('Toggle'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _createFeatureFlag() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Feature Flag'),
        content: const Text('Feature flag creation dialog - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleFlagAction(FeatureFlag flag, String action) {
    switch (action) {
      case 'toggle':
        _toggleFeatureFlag(flag);
        break;
      case 'edit':
        _editFeatureFlag(flag);
        break;
      case 'view':
        _viewFlagDetails(flag);
        break;
      case 'delete':
        _deleteFeatureFlag(flag);
        break;
    }
  }

  void _toggleFeatureFlag(FeatureFlag flag) {
    setState(() {
      final index = _featureFlags.indexWhere((f) => f.id == flag.id);
      if (index != -1) {
        _featureFlags[index] = FeatureFlag(
          id: flag.id,
          name: flag.name,
          description: flag.description,
          key: flag.key,
          isEnabled: !flag.isEnabled,
          type: flag.type,
          defaultValue: flag.defaultValue,
          environments: flag.environments,
          targetingRules: flag.targetingRules,
          tags: flag.tags,
          createdAt: flag.createdAt,
          updatedAt: DateTime.now(),
          createdBy: flag.createdBy,
          isActive: flag.isActive,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Feature flag "${flag.name}" ${flag.isEnabled ? 'disabled' : 'enabled'}'),
      ),
    );
  }

  void _editFeatureFlag(FeatureFlag flag) {
    // Implement edit feature flag dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit "${flag.name}" - Coming soon')),
    );
  }

  void _viewFlagDetails(FeatureFlag flag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(flag.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${flag.description}'),
              const SizedBox(height: 8),
              Text('Key: ${flag.key}'),
              Text('Type: ${flag.type.value}'),
              Text('Status: ${flag.isEnabled ? 'Enabled' : 'Disabled'}'),
              const SizedBox(height: 8),
              Text('Default Value: ${flag.defaultValue}'),
              const SizedBox(height: 8),
              const Text('Environments:'),
              ...flag.environments.map((env) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('${env.environment}: ${env.value}'),
                  )),
              const SizedBox(height: 8),
              Text('Targeting Rules: ${flag.targetingRules.length}'),
              const SizedBox(height: 8),
              Text('Tags: ${flag.tags.join(', ')}'),
              const SizedBox(height: 8),
              Text('Created By: ${flag.createdBy}'),
              Text('Created At: ${_formatDateTime(flag.createdAt)}'),
              Text('Updated At: ${_formatDateTime(flag.updatedAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteFeatureFlag(FeatureFlag flag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feature Flag'),
        content: Text('Are you sure you want to delete "${flag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _featureFlags.removeWhere((f) => f.id == flag.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Feature flag "${flag.name}" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class KillSwitchesTab extends StatelessWidget {
  const KillSwitchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.power_settings_new, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Kill Switches'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}

class ExperimentsTab extends StatelessWidget {
  const ExperimentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Feature Flag Experiments'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}
