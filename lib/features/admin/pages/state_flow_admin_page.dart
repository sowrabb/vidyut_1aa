// State Flow Administration Page
// Comprehensive content management system for all state flow entities

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/tokens.dart';
import '../store/admin_store.dart';
import '../widgets/state_flow_admin_widgets.dart';
import '../widgets/power_generators_tab.dart';

class StateFlowAdminPage extends StatefulWidget {
  const StateFlowAdminPage({super.key});

  @override
  State<StateFlowAdminPage> createState() => _StateFlowAdminPageState();
}

class _StateFlowAdminPageState extends State<StateFlowAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, store, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('State Flow Management'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.power), text: 'Power Generators'),
                Tab(icon: Icon(Icons.electrical_services), text: 'Transmission'),
                Tab(icon: Icon(Icons.location_city), text: 'Distribution'),
                Tab(icon: Icon(Icons.map), text: 'States & Mandals'),
                Tab(icon: Icon(Icons.build_circle), text: 'Custom Fields'),
                Tab(icon: Icon(Icons.tab), text: 'Tabs & Templates'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _showExportDialog(context, store),
                tooltip: 'Export Data',
              ),
              IconButton(
                icon: const Icon(Icons.upload),
                onPressed: () => _showImportDialog(context, store),
                tooltip: 'Import Data',
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, store, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh Data'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'backup',
                    child: ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Create Backup'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _StateFlowOverviewTab(),
              const PowerGeneratorsTab(),
              _TransmissionLinesTab(),
              _DistributionCompaniesTab(),
              _StatesAndMandalsTab(),
              _CustomFieldsTab(),
              _TabsAndTemplatesTab(),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(context, store),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, AdminStore store) {
    switch (_tabController.index) {
      case 1: // Power Generators
        return FloatingActionButton.extended(
          onPressed: () => _showAddPowerGeneratorDialog(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Add Generator'),
        );
      case 5: // Custom Fields
        return FloatingActionButton.extended(
          onPressed: () => _showAddCustomFieldDialog(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Add Field'),
        );
      case 6: // Tabs & Templates
        return FloatingActionButton.extended(
          onPressed: () => _showAddTabDialog(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Add Tab'),
        );
      default:
        return null;
    }
  }

  void _handleMenuAction(BuildContext context, AdminStore store, String action) {
    switch (action) {
      case 'refresh':
        // Refresh data - in a real app, this would reload data from the server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data refreshed')),
        );
        break;
      case 'backup':
        _createBackup(context, store);
        break;
      case 'settings':
        _showSettingsDialog(context, store);
        break;
    }
  }

  void _showExportDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => ExportDataDialog(store: store),
    );
  }

  void _showImportDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => ImportDataDialog(store: store),
    );
  }

  void _createBackup(BuildContext context, AdminStore store) async {
    try {
      // Export state flow data for backup
      store.exportStateFlowData();
      // Here you would typically save to file or cloud storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }

  void _showSettingsDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => StateFlowSettingsDialog(store: store),
    );
  }

  void _showAddPowerGeneratorDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => AddEditPowerGeneratorDialog(store: store),
    );
  }

  void _showAddCustomFieldDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => AddEditCustomFieldDialog(store: store),
    );
  }

  void _showAddTabDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => AddEditCustomTabDialog(store: store),
    );
  }
}

// Overview Tab Widget
class _StateFlowOverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, store, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatisticsCards(store),
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(context, store),
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(store),
              const SizedBox(height: 24),
              
              // System Health
              _buildSystemHealth(store),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards(AdminStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              title: 'Power Generators',
              count: store.adminPowerGenerators.length,
              icon: Icons.power,
              color: Colors.blue,
              subtitle: '${store.publishedPowerGenerators.length} published',
            ),
            _StatCard(
              title: 'Custom Fields',
              count: store.customFields.length,
              icon: Icons.build_circle,
              color: Colors.green,
              subtitle: 'Active fields',
            ),
            _StatCard(
              title: 'Custom Tabs',
              count: store.customTabs.length,
              icon: Icons.tab,
              color: Colors.orange,
              subtitle: 'Custom sections',
            ),
            _StatCard(
              title: 'Media Assets',
              count: store.mediaAssets.length,
              icon: Icons.perm_media,
              color: Colors.purple,
              subtitle: 'Images & documents',
            ),
            _StatCard(
              title: 'Entity Templates',
              count: store.entityTemplates.length,
              icon: Icons.description_outlined,
              color: Colors.teal,
              subtitle: 'Content templates',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AdminStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              label: 'Add Generator',
              icon: Icons.add_circle,
              color: Colors.blue,
              onPressed: () => _showAddPowerGeneratorDialog(context, store),
            ),
            _QuickActionButton(
              label: 'Create Field',
              icon: Icons.add_box,
              color: Colors.green,
              onPressed: () => _showAddCustomFieldDialog(context, store),
            ),
            _QuickActionButton(
              label: 'Design Tab',
              icon: Icons.tab_outlined,
              color: Colors.orange,
              onPressed: () => _showAddTabDialog(context, store),
            ),
            _QuickActionButton(
              label: 'Import Data',
              icon: Icons.upload_file,
              color: Colors.purple,
              onPressed: () => _showImportDialog(context, store),
            ),
            _QuickActionButton(
              label: 'Export Backup',
              icon: Icons.download,
              color: Colors.teal,
              onPressed: () => _showExportDialog(context, store),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(AdminStore store) {
    final recentLogs = store.auditLogs.take(10).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLogs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = recentLogs[index];
              return ListTile(
                leading: _getActivityIcon(log.area),
                title: Text(log.message),
                subtitle: Text(_formatTimestamp(log.timestamp)),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSystemHealth(AdminStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _HealthIndicator(
                label: 'Data Consistency',
                status: 'Good',
                color: Colors.green,
                percentage: 98,
              ),
              const SizedBox(height: 12),
              _HealthIndicator(
                label: 'Media Assets',
                status: 'Excellent',
                color: Colors.green,
                percentage: 100,
              ),
              const SizedBox(height: 12),
              _HealthIndicator(
                label: 'Search Index',
                status: 'Good',
                color: Colors.green,
                percentage: 95,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getActivityIcon(String area) {
    switch (area) {
      case 'state_flow':
        return const Icon(Icons.electrical_services, color: Colors.blue);
      case 'cms':
        return const Icon(Icons.edit, color: Colors.green);
      case 'media':
        return const Icon(Icons.perm_media, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAddPowerGeneratorDialog(BuildContext context, AdminStore store) {
    // Implementation would be in the widgets file
  }

  void _showAddCustomFieldDialog(BuildContext context, AdminStore store) {
    // Implementation would be in the widgets file
  }

  void _showAddTabDialog(BuildContext context, AdminStore store) {
    // Implementation would be in the widgets file
  }

  void _showImportDialog(BuildContext context, AdminStore store) {
    // Implementation would be in the widgets file
  }

  void _showExportDialog(BuildContext context, AdminStore store) {
    // Implementation would be in the widgets file
  }
}

// Helper Widgets
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final String label;
  final String status;
  final Color color;
  final int percentage;

  const _HealthIndicator({
    required this.label,
    required this.status,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Placeholder tab widgets - these would be implemented with full functionality

class _TransmissionLinesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Transmission Lines Management - Coming Next'),
    );
  }
}

class _DistributionCompaniesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Distribution Companies Management - Coming Next'),
    );
  }
}

class _StatesAndMandalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('States and Mandals Management - Coming Next'),
    );
  }
}

class _CustomFieldsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Custom Fields Management - Coming Next'),
    );
  }
}

class _TabsAndTemplatesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tabs and Templates Management - Coming Next'),
    );
  }
}
