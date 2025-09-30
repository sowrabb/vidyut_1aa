import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_operations_models.dart';
import '../../../app/provider_registry.dart';

class SystemOperationsPage extends ConsumerStatefulWidget {
  const SystemOperationsPage({super.key});

  @override
  ConsumerState<SystemOperationsPage> createState() =>
      _SystemOperationsPageState();
}

class _SystemOperationsPageState extends ConsumerState<SystemOperationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Operations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Health', icon: Icon(Icons.health_and_safety)),
            Tab(text: 'Maintenance', icon: Icon(Icons.build)),
            Tab(text: 'Backups', icon: Icon(Icons.backup)),
            Tab(text: 'Audit Logs', icon: Icon(Icons.assignment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SystemHealthTab(),
          SystemMaintenanceTab(),
          SystemBackupsTab(),
          SystemAuditLogsTab(),
        ],
      ),
    );
  }
}

class SystemHealthTab extends StatefulWidget {
  const SystemHealthTab({super.key});

  @override
  State<SystemHealthTab> createState() => _SystemHealthTabState();
}

class _SystemHealthTabState extends State<SystemHealthTab> {
  SystemHealthSummary? _healthSummary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealthSummary();
  }

  Future<void> _loadHealthSummary() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _healthSummary = SystemHealthSummary(
        services: {
          'api': SystemHealthCheck(
            id: '1',
            serviceName: 'API Server',
            status: HealthStatus.healthy,
            responseTime: 150.0,
            metrics: {'cpu': 45.2, 'memory': 67.8, 'requests_per_second': 1250},
            checkedAt: DateTime.now(),
          ),
          'database': SystemHealthCheck(
            id: '2',
            serviceName: 'Database',
            status: HealthStatus.healthy,
            responseTime: 25.0,
            metrics: {
              'connections': 45,
              'query_time': 12.5,
              'cache_hit_rate': 98.2
            },
            checkedAt: DateTime.now(),
          ),
          'storage': SystemHealthCheck(
            id: '3',
            serviceName: 'File Storage',
            status: HealthStatus.degraded,
            responseTime: 450.0,
            error: 'High latency detected',
            metrics: {'disk_usage': 89.5, 'io_operations': 12500},
            checkedAt: DateTime.now(),
          ),
        },
        overallStatus: HealthStatus.degraded,
        lastChecked: DateTime.now(),
        summary: {
          'total_services': 3,
          'healthy_services': 2,
          'degraded_services': 1,
          'unhealthy_services': 0,
        },
      );

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
              onPressed: _loadHealthSummary,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHealthSummary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(_healthSummary!.overallStatus),
                          color: _getStatusColor(_healthSummary!.overallStatus),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Overall System Status',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            _healthSummary!.overallStatus.value.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              _getStatusColor(_healthSummary!.overallStatus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last checked: ${_formatDateTime(_healthSummary!.lastChecked)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          'Total Services',
                          '${_healthSummary!.summary['total_services']}',
                          Icons.dns,
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Healthy',
                          '${_healthSummary!.summary['healthy_services']}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Degraded',
                          '${_healthSummary!.summary['degraded_services']}',
                          Icons.warning,
                          Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Unhealthy',
                          '${_healthSummary!.summary['unhealthy_services']}',
                          Icons.error,
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Services List
            Text(
              'Service Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            ...(_healthSummary!.services.entries.map((entry) {
              final service = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getStatusIcon(service.status),
                    color: _getStatusColor(service.status),
                  ),
                  title: Text(service.serviceName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Response time: ${service.responseTime.toStringAsFixed(0)}ms'),
                      if (service.error != null)
                        Text(
                          service.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'details') {
                        _showServiceDetails(service);
                      } else if (value == 'refresh') {
                        _refreshService(service.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Refresh'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Icons.check_circle;
      case HealthStatus.degraded:
        return Icons.warning;
      case HealthStatus.unhealthy:
        return Icons.error;
      case HealthStatus.unknown:
        return Icons.help;
    }
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.degraded:
        return Colors.orange;
      case HealthStatus.unhealthy:
        return Colors.red;
      case HealthStatus.unknown:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showServiceDetails(SystemHealthCheck service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.serviceName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${service.status.value}'),
            Text('Response Time: ${service.responseTime.toStringAsFixed(0)}ms'),
            Text('Last Checked: ${_formatDateTime(service.checkedAt)}'),
            if (service.error != null) ...[
              const SizedBox(height: 8),
              Text('Error: ${service.error}',
                  style: TextStyle(color: Colors.red[700])),
            ],
            const SizedBox(height: 8),
            const Text('Metrics:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...service.metrics.entries
                .map((entry) => Text('${entry.key}: ${entry.value}')),
          ],
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

  void _refreshService(String serviceId) {
    // Implement service refresh logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Refreshing service $serviceId...')),
    );
  }
}

class SystemMaintenanceTab extends ConsumerStatefulWidget {
  const SystemMaintenanceTab({super.key});

  @override
  ConsumerState<SystemMaintenanceTab> createState() =>
      _SystemMaintenanceTabState();
}

class _SystemMaintenanceTabState extends ConsumerState<SystemMaintenanceTab> {
  List<SystemMaintenance> _maintenanceWindows = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceWindows();
  }

  Future<void> _loadMaintenanceWindows() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));

      _maintenanceWindows = [
        SystemMaintenance(
          id: '1',
          title: 'Database Optimization',
          description: 'Scheduled database maintenance to optimize performance',
          status: MaintenanceStatus.scheduled,
          scheduledStart: DateTime.now().add(const Duration(days: 1)),
          scheduledEnd: DateTime.now().add(const Duration(days: 1, hours: 2)),
          message: 'System will be temporarily unavailable during maintenance',
          affectedServices: ['API', 'Database', 'Search'],
          metadata: {'estimated_downtime': '2 hours', 'impact': 'medium'},
          createdBy: 'admin@vidyut.com',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        SystemMaintenance(
          id: '2',
          title: 'Security Updates',
          description: 'Apply critical security patches',
          status: MaintenanceStatus.completed,
          scheduledStart: DateTime.now().subtract(const Duration(days: 1)),
          scheduledEnd:
              DateTime.now().subtract(const Duration(days: 1, hours: 1)),
          actualStart: DateTime.now().subtract(const Duration(days: 1)),
          actualEnd: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1, minutes: 30)),
          message: 'Security updates applied successfully',
          affectedServices: ['API', 'Web'],
          metadata: {'patches_applied': 5, 'impact': 'low'},
          createdBy: 'security@vidyut.com',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
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
              onPressed: _loadMaintenanceWindows,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final adminStore = ref.watch(adminStoreProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Maintenance Windows',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Row(children: [
                const Text('Maintenance Mode'),
                const SizedBox(width: 8),
                Switch(
                  value: adminStore.maintenanceMode,
                  onChanged: (v) => adminStore.setMaintenance(v),
                ),
              ]),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _createMaintenanceWindow,
                icon: const Icon(Icons.add),
                label: const Text('Schedule'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMaintenanceWindows,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _maintenanceWindows.length,
              itemBuilder: (context, index) {
                final maintenance = _maintenanceWindows[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getStatusIcon(maintenance.status),
                      color: _getStatusColor(maintenance.status),
                    ),
                    title: Text(maintenance.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(maintenance.description),
                        const SizedBox(height: 4),
                        Text(
                          'Scheduled: ${_formatDateTime(maintenance.scheduledStart)} - ${_formatDateTime(maintenance.scheduledEnd)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Status: ${maintenance.status.value}',
                          style: TextStyle(
                            color: _getStatusColor(maintenance.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMaintenanceAction(maintenance, value),
                      itemBuilder: (context) => [
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
                        if (maintenance.status ==
                            MaintenanceStatus.scheduled) ...[
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
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel),
                                SizedBox(width: 8),
                                Text('Cancel'),
                              ],
                            ),
                          ),
                        ],
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

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return Icons.schedule;
      case MaintenanceStatus.inProgress:
        return Icons.build;
      case MaintenanceStatus.completed:
        return Icons.check_circle;
      case MaintenanceStatus.cancelled:
        return Icons.cancel;
      case MaintenanceStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return Colors.blue;
      case MaintenanceStatus.inProgress:
        return Colors.orange;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.cancelled:
        return Colors.grey;
      case MaintenanceStatus.failed:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _createMaintenanceWindow() {
    // Implement create maintenance window dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create maintenance window - Coming soon')),
    );
  }

  void _handleMaintenanceAction(SystemMaintenance maintenance, String action) {
    switch (action) {
      case 'view':
        _showMaintenanceDetails(maintenance);
        break;
      case 'edit':
        // Implement edit maintenance window
        break;
      case 'cancel':
        _cancelMaintenance(maintenance);
        break;
    }
  }

  void _showMaintenanceDetails(SystemMaintenance maintenance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(maintenance.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${maintenance.description}'),
              const SizedBox(height: 8),
              Text('Status: ${maintenance.status.value}'),
              const SizedBox(height: 8),
              Text(
                  'Scheduled Start: ${_formatDateTime(maintenance.scheduledStart)}'),
              Text(
                  'Scheduled End: ${_formatDateTime(maintenance.scheduledEnd)}'),
              if (maintenance.actualStart != null)
                Text(
                    'Actual Start: ${_formatDateTime(maintenance.actualStart!)}'),
              if (maintenance.actualEnd != null)
                Text('Actual End: ${_formatDateTime(maintenance.actualEnd!)}'),
              const SizedBox(height: 8),
              Text('Message: ${maintenance.message}'),
              const SizedBox(height: 8),
              Text(
                  'Affected Services: ${maintenance.affectedServices.join(', ')}'),
              const SizedBox(height: 8),
              Text('Created By: ${maintenance.createdBy}'),
              Text('Created At: ${_formatDateTime(maintenance.createdAt)}'),
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

  void _cancelMaintenance(SystemMaintenance maintenance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Maintenance'),
        content:
            Text('Are you sure you want to cancel "${maintenance.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement cancel logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maintenance cancelled')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class SystemBackupsTab extends StatelessWidget {
  const SystemBackupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.backup, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Backup Management'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}

class SystemAuditLogsTab extends ConsumerWidget {
  const SystemAuditLogsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(adminStoreProvider);
    final logs = store.auditLogs;
    final retentionCtrl =
        TextEditingController(text: store.auditRetentionDays.toString());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('Audit Logs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(
            width: 160,
            child: TextField(
              controller: retentionCtrl,
              decoration: const InputDecoration(
                  labelText: 'Retention (days)', border: OutlineInputBorder()),
              onSubmitted: (v) {
                final d = int.tryParse(v);
                if (d != null && d > 0) store.auditRetentionDays = d;
              },
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              final csv = store.exportAuditCsv();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('CSV ready (${csv.length} chars).')),
              );
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export CSV'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => store.addAudit('manual', 'Manual test entry'),
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = logs[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(a.message),
                subtitle: Text('${a.area} • ${a.timestamp.toIso8601String()}'),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
