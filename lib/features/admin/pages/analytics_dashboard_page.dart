import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../models/analytics_models.dart';
import '../../../widgets/simple_charts.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
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
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Reports', icon: Icon(Icons.assessment)),
            Tab(text: 'Metrics', icon: Icon(Icons.analytics)),
            Tab(text: 'Queries', icon: Icon(Icons.query_stats)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AnalyticsOverviewTab(),
          AnalyticsReportsTab(),
          AnalyticsMetricsTab(),
          AnalyticsQueriesTab(),
        ],
      ),
    );
  }
}

class AnalyticsOverviewTab extends ConsumerStatefulWidget {
  const AnalyticsOverviewTab({super.key});

  @override
  ConsumerState<AnalyticsOverviewTab> createState() =>
      _AnalyticsOverviewTabState();
}

class _AnalyticsOverviewTabState extends ConsumerState<AnalyticsOverviewTab> {
  List<AnalyticsDashboard> _dashboards = [];
  bool _isLoading = true;
  String? _error;

  // Simple filters (expand later)
  DateTimeRange? _dateRange;
  String? _stateFilter;
  String? _cityFilter;
  String _userSearch = '';

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      _dashboards = [
        AnalyticsDashboard(
          id: '1',
          name: 'Business Overview',
          description: 'High-level business metrics and KPIs',
          widgets: [
            DashboardWidget(
              id: '1',
              type: 'metric_card',
              title: 'Total Users',
              configuration: {'metric': 'total_users', 'format': 'number'},
              position: WidgetPosition(x: 0, y: 0),
              size: WidgetSize(width: 300, height: 150),
              dataSources: ['users'],
              lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
            DashboardWidget(
              id: '2',
              type: 'line_chart',
              title: 'User Growth',
              configuration: {'metric': 'user_growth', 'period': '30d'},
              position: WidgetPosition(x: 320, y: 0),
              size: WidgetSize(width: 400, height: 200),
              dataSources: ['users', 'analytics'],
              lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
            ),
          ],
          settings: DashboardSettings(
            theme: 'light',
            autoRefresh: true,
            refreshInterval: 300,
            timeFilters: {'period': '30d'},
            allowedUsers: ['admin@vidyut.com'],
            customSettings: {},
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdBy: 'admin@vidyut.com',
          isPublic: true,
        ),
        AnalyticsDashboard(
          id: '2',
          name: 'Technical Metrics',
          description: 'System performance and technical KPIs',
          widgets: [
            DashboardWidget(
              id: '3',
              type: 'gauge',
              title: 'API Response Time',
              configuration: {'metric': 'api_response_time', 'threshold': 200},
              position: WidgetPosition(x: 0, y: 0),
              size: WidgetSize(width: 250, height: 200),
              dataSources: ['monitoring'],
              lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
          settings: DashboardSettings(
            theme: 'dark',
            autoRefresh: true,
            refreshInterval: 60,
            timeFilters: {'period': '1h'},
            allowedUsers: ['admin@vidyut.com', 'engineering@vidyut.com'],
            customSettings: {},
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdBy: 'engineering@vidyut.com',
          isPublic: false,
        ),
      ];

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminStore = ref.watch(enhancedAdminStoreProvider);
    final demo = ref.watch(demoDataServiceProvider);
    final analytics = ref.watch(analyticsServiceProvider);

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
              onPressed: _loadDashboards,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Aggregate basic KPIs from available demo data
    final sellers = adminStore.sellers;
    final users = adminStore.users;
    final products = adminStore.useBackend
        ? adminStore.products
        : adminStore.products.isNotEmpty
            ? adminStore.products
            : demo.allProducts.map((p) => p).toList();

    final Map<String, int> sellersByState = {};
    final Map<String, Map<String, int>> sellersByCity = {};
    for (final u in users) {
      final sp = u.sellerProfile;
      if (sp == null) continue;
      final state = (sp.state.isNotEmpty ? sp.state : u.location).trim();
      final city = (sp.city.isNotEmpty ? sp.city : u.location).trim();
      if (state.isNotEmpty) {
        sellersByState[state] = (sellersByState[state] ?? 0) + 1;
        sellersByCity.putIfAbsent(state, () => <String, int>{});
        if (city.isNotEmpty) {
          sellersByCity[state]![city] = (sellersByCity[state]![city] ?? 0) + 1;
        }
      }
    }

    final List<String> states = sellersByState.keys.toList();
    states.sort();
    final List<String> citiesForState;
    if (_stateFilter != null && sellersByCity.containsKey(_stateFilter)) {
      citiesForState = sellersByCity[_stateFilter!]!.keys.toList();
      citiesForState.sort();
    } else {
      citiesForState = <String>[];
    }

    return SingleChildScrollView(
        child: Column(
      children: [
        // Header with Create Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Analytics Dashboards',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createDashboard,
                icon: const Icon(Icons.add),
                label: const Text('Create Dashboard'),
              ),
            ],
          ),
        ),

        // Filters row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_dateRange == null
                    ? 'Date Range'
                    : '${_dateRange!.start.toString().split(' ').first} → ${_dateRange!.end.toString().split(' ').first}'),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange: _dateRange ??
                        DateTimeRange(
                          start: DateTime(now.year, now.month, 1),
                          end: now,
                        ),
                  );
                  if (picked != null) {
                    setState(() => _dateRange = picked);
                  }
                },
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String?>(
                  value: _stateFilter,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('All States')),
                    ...states.map((s) => DropdownMenuItem<String?>(
                          value: s,
                          child: Text(s),
                        )),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() {
                    _stateFilter = v;
                    _cityFilter = null;
                  }),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String?>(
                  value: _cityFilter,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('All Cities')),
                    ...citiesForState.map((c) => DropdownMenuItem<String?>(
                          value: c,
                          child: Text(c),
                        )),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _cityFilter = v),
                ),
              ),
            ],
          ),
        ),

        // Quick Stats (Business Overview)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Total Sellers',
                  '${sellers.length}',
                  Icons.storefront_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'Total Products',
                  '${products.length}',
                  Icons.inventory_2_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'Total Views',
                  '${analytics.totalViews}',
                  Icons.visibility_outlined,
                  Colors.orange,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Active Users',
                  '${analytics.activeUsersCount}',
                  Icons.people_alt_outlined,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'Total Sessions',
                  '${analytics.totalSessions}',
                  Icons.timelapse_outlined,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'Avg Session (s)',
                  analytics.averageSessionDurationSeconds.toStringAsFixed(0),
                  Icons.speed_outlined,
                  Colors.indigo,
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Views Trend (last days)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.show_chart),
                    const SizedBox(width: 8),
                    Text('Views Trend',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final csv = await analytics.generateReportCsv(
                            name: 'views_per_day', type: 'views_per_day');
                        _exportCsv('views_per_day.csv', csv);
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export CSV'),
                    )
                  ]),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final pts = analytics.viewsPerDay
                        .map((e) => LineSeriesPoint(e.key, e.value.toDouble()))
                        .toList();
                    return SizedBox(height: 200, child: LineChart(points: pts));
                  }),
                ],
              ),
            ),
          ),
        ),

        // Sellers by State (table)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined),
                      const SizedBox(width: 8),
                      Text('Sellers by State',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('Total: ${sellers.length}'),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          final rows = <List<String>>[
                            ['state', 'seller_count'],
                            ...states.map(
                                (s) => [s, (sellersByState[s] ?? 0).toString()])
                          ];
                          final csv = rows
                              .map((r) => r.map(_csvEscape).join(','))
                              .join('\n');
                          _exportCsv('sellers_by_state.csv', csv);
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export CSV'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView(
                      children: [
                        ...states.map((s) => ListTile(
                              dense: true,
                              title: Text(s),
                              trailing: Text('${sellersByState[s]}'),
                              onTap: () => setState(() => _stateFilter = s),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Sellers by City for selected state
        if (_stateFilter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_city_outlined),
                        const SizedBox(width: 8),
                        Text('Sellers in ${_stateFilter!}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        Text('Cities: ${citiesForState.length}'),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            final rows = <List<String>>[
                              ['state', 'city', 'seller_count'],
                              ...citiesForState.map((c) => [
                                    _stateFilter!,
                                    c,
                                    (sellersByCity[_stateFilter!]![c] ?? 0)
                                        .toString()
                                  ])
                            ];
                            final csv = rows
                                .map((r) => r.map(_csvEscape).join(','))
                                .join('\n');
                            _exportCsv(
                                'sellers_by_city_${_stateFilter!}.csv', csv);
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Export CSV'),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView(
                        children: [
                          ...citiesForState.map((c) => ListTile(
                                dense: true,
                                title: Text(c),
                                trailing:
                                    Text('${sellersByCity[_stateFilter!]![c]}'),
                                onTap: () => setState(() => _cityFilter = c),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Views by State
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.visibility_outlined),
                    const SizedBox(width: 8),
                    Text('Views by State',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        final entries = analytics.viewsByState.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        final rows = <List<String>>[
                          ['state', 'views'],
                          ...entries.map((e) => [e.key, e.value.toString()]),
                        ];
                        final csv = rows
                            .map((r) => r.map(_csvEscape).join(','))
                            .join('\\n');
                        _exportCsv('views_by_state.csv', csv);
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export CSV'),
                    )
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: Builder(builder: (context) {
                      final entries = analytics.viewsByState.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return ListView(
                        children: [
                          ...entries.map((e) => ListTile(
                                dense: true,
                                title: Text(e.key),
                                trailing: Text('${e.value}'),
                              )),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Views by City
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.apartment_outlined),
                    const SizedBox(width: 8),
                    Text('Views by City',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        final entries = analytics.viewsByCity.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        final rows = <List<String>>[
                          ['city', 'views'],
                          ...entries.map((e) => [e.key, e.value.toString()]),
                        ];
                        final csv = rows
                            .map((r) => r.map(_csvEscape).join(','))
                            .join('\\n');
                        _exportCsv('views_by_city.csv', csv);
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export CSV'),
                    )
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: Builder(builder: (context) {
                      final entries = analytics.viewsByCity.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return ListView(
                        children: [
                          ...entries.map((e) => ListTile(
                                dense: true,
                                title: Text(e.key),
                                trailing: Text('${e.value}'),
                              )),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Top Users by Time Spent
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.timelapse_outlined),
                    const SizedBox(width: 8),
                    Text('Top Users by Time Spent',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        final body =
                            analytics.timeSpentByUserSeconds.entries.toList();
                        body.sort((a, b) => b.value.compareTo(a.value));
                        final rows = <List<String>>[
                          ['user_id', 'time_spent_seconds'],
                          ...body.map((e) => [e.key, e.value.toString()])
                        ];
                        final csv = rows
                            .map((r) => r.map(_csvEscape).join(','))
                            .join('\n');
                        _exportCsv('top_users_time_spent.csv', csv);
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export CSV'),
                    )
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search user id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (q) =>
                        setState(() => _userSearch = q.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: Builder(builder: (context) {
                      final entries = analytics.timeSpentByUserSeconds.entries
                          .where((e) =>
                              _userSearch.isEmpty ||
                              e.key.toLowerCase().contains(_userSearch))
                          .toList();
                      entries.sort((a, b) => b.value.compareTo(a.value));
                      final top = entries.take(20).toList();
                      return ListView(
                        children: [
                          ...top.map((e) => ListTile(
                                dense: true,
                                title: Text('User ${e.key}'),
                                trailing: Text('${e.value}s'),
                              )),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dashboards List (kept for future custom dashboards)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RefreshIndicator(
            onRefresh: _loadDashboards,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _dashboards.length,
              itemBuilder: (context, index) {
                final dashboard = _dashboards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          dashboard.isPublic ? Colors.green : Colors.blue,
                      child: const Icon(
                        Icons.dashboard,
                        color: Colors.white,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(dashboard.name)),
                        if (dashboard.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PUBLIC',
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
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PRIVATE',
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
                        Text(dashboard.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${dashboard.widgets.length} widgets',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Auto-refresh: ${dashboard.settings.autoRefresh ? 'ON' : 'OFF'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Updated: ${_formatDateTime(dashboard.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleDashboardAction(dashboard, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View Dashboard'),
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
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(width: 8),
                              Text('Duplicate'),
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
    ));
  }

  Widget _buildQuickStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _createDashboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Dashboard'),
        content: const Text('Dashboard creation dialog - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleDashboardAction(AnalyticsDashboard dashboard, String action) {
    switch (action) {
      case 'view':
        _viewDashboard(dashboard);
        break;
      case 'edit':
        _editDashboard(dashboard);
        break;
      case 'share':
        _shareDashboard(dashboard);
        break;
      case 'duplicate':
        _duplicateDashboard(dashboard);
        break;
      case 'delete':
        _deleteDashboard(dashboard);
        break;
    }
  }

  void _exportCsv(String filename, String content) {
    // In a real app, stream download; here we just confirm generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('CSV generated (${content.length} chars): $filename')),
    );
  }

  String _csvEscape(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    var v = value.replaceAll('"', '""');
    if (needsQuotes) v = '"' + v + '"';
    return v;
  }

  void _viewDashboard(AnalyticsDashboard dashboard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DashboardViewPage(dashboard: dashboard),
      ),
    );
  }

  void _editDashboard(AnalyticsDashboard dashboard) {
    // Implement edit dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit "${dashboard.name}" - Coming soon')),
    );
  }

  void _shareDashboard(AnalyticsDashboard dashboard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share "${dashboard.name}" with team members'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Permission',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'view', child: Text('View Only')),
                      DropdownMenuItem(value: 'edit', child: Text('Edit')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard shared successfully')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _duplicateDashboard(AnalyticsDashboard dashboard) {
    setState(() {
      final duplicatedDashboard = AnalyticsDashboard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${dashboard.name} (Copy)',
        description: dashboard.description,
        widgets: dashboard.widgets,
        settings: dashboard.settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'current_user@vidyut.com',
        isPublic: false,
      );
      _dashboards.add(duplicatedDashboard);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dashboard "${dashboard.name}" duplicated')),
    );
  }

  void _deleteDashboard(AnalyticsDashboard dashboard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dashboard'),
        content: Text('Are you sure you want to delete "${dashboard.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _dashboards.removeWhere((d) => d.id == dashboard.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Dashboard "${dashboard.name}" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class DashboardViewPage extends StatelessWidget {
  final AnalyticsDashboard dashboard;

  const DashboardViewPage({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Fullscreen',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle dashboard actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Dashboard'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: dashboard.widgets.length,
          itemBuilder: (context, index) {
            final widget = dashboard.widgets[index];
            return _buildDashboardWidget(widget);
          },
        ),
      ),
    );
  }

  Widget _buildDashboardWidget(DashboardWidget widget) {
    switch (widget.type) {
      case 'metric_card':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  '1,234', // Mock data
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  '+12% from last month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      case 'line_chart':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Center(
                  child: Icon(
                    Icons.show_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  'Chart visualization would go here',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case 'gauge':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Center(
                  child: Icon(
                    Icons.speed,
                    size: 64,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  'Gauge visualization would go here',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      default:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Center(
                  child: Icon(
                    Icons.widgets,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Widget type: ${widget.type}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }
}

class AnalyticsReportsTab extends ConsumerWidget {
  const AnalyticsReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsServiceProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Text('Generate'),
            const SizedBox(width: 12),
            FilledButton(
                onPressed: () async {
                  final csv = await analytics.generateReportCsv(
                      name: 'Views by State', type: 'views_by_state');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Report ready (${csv.length} chars)')));
                },
                child: const Text('Views by State CSV')),
            const SizedBox(width: 8),
            FilledButton(
                onPressed: () async {
                  final csv = await analytics.generateReportCsv(
                      name: 'Views per Day', type: 'views_per_day');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Report ready (${csv.length} chars)')));
                },
                child: const Text('Views per Day CSV')),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Report Jobs'),
            const SizedBox(height: 8),
            for (final j in analytics.reportJobs)
              ListTile(
                dense: true,
                title: Text('${j.name} (${j.type})'),
                subtitle: Text(
                    'Status: ${j.status} • started ${j.startedAt.toIso8601String()}${j.completedAt != null ? ' • completed ${j.completedAt!.toIso8601String()}' : ''}'),
                trailing: j.content != null
                    ? OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Use export to save CSV')));
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export'))
                    : null,
              ),
          ]),
        ),
      ),
    ]);
  }
}

class AnalyticsMetricsTab extends ConsumerWidget {
  const AnalyticsMetricsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsServiceProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.show_chart),
                const SizedBox(width: 8),
                const Text('Views per day'),
                const Spacer(),
                OutlinedButton.icon(
                    onPressed: () async {
                      final csv = await analytics.generateReportCsv(
                          name: 'views_per_day', type: 'views_per_day');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('CSV generated (${csv.length} chars)')));
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Export CSV'))
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: LineChart(
                  points: analytics.viewsPerDay
                      .map((e) => LineSeriesPoint(e.key, e.value.toDouble()))
                      .toList(),
                ),
              )
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.groups_outlined),
                const SizedBox(width: 8),
                const Text('Top users by time spent'),
              ]),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final entries = analytics.timeSpentByUserSeconds.entries
                    .toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                return Column(children: [
                  for (final e in entries.take(10))
                    ListTile(
                        dense: true,
                        title: Text('User ${e.key}'),
                        trailing: Text('${e.value}s'))
                ]);
              })
            ]),
          ),
        ),
      ],
    );
  }
}

class AnalyticsQueriesTab extends ConsumerStatefulWidget {
  const AnalyticsQueriesTab({super.key});

  @override
  ConsumerState<AnalyticsQueriesTab> createState() =>
      _AnalyticsQueriesTabState();
}

class _AnalyticsQueriesTabState extends ConsumerState<AnalyticsQueriesTab> {
  int _stateOffset = 0;
  int _cityOffset = 0;
  int _productOffset = 0;
  static const int _pageSize = 20;
  String _stateSearch = '';
  String _citySearch = '';
  String _productSearch = '';

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsServiceProvider);
    final demo = ref.watch(demoDataServiceProvider);
    final topStates = analytics
        .topStatesByViews(limit: 200)
        .where((e) =>
            _stateSearch.isEmpty || e.key.toLowerCase().contains(_stateSearch))
        .toList();
    final topCities = analytics
        .topCitiesByViews(limit: 200)
        .where((e) =>
            _citySearch.isEmpty || e.key.toLowerCase().contains(_citySearch))
        .toList();
    String productName(String id) {
      final p = demo.allProducts.where((e) => e.id == id).cast().toList();
      if (p.isNotEmpty) return p.first.title;
      return 'Product $id';
    }

    final topProducts = analytics
        .topProductsByViews(limit: 200)
        .where((e) =>
            _productSearch.isEmpty ||
            productName(e.key).toLowerCase().contains(_productSearch) ||
            e.key.toLowerCase().contains(_productSearch))
        .toList();

    List<Widget> buildPager(
        int offset, int total, void Function(int) setOffset) {
      final canPrev = offset > 0;
      final canNext = offset + _pageSize < total;
      return [
        OutlinedButton(
          onPressed: canPrev
              ? () => setOffset((offset - _pageSize).clamp(0, total))
              : null,
          child: const Text('Prev'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: canNext
              ? () => setOffset((offset + _pageSize).clamp(0, total))
              : null,
          child: const Text('Next'),
        ),
        const SizedBox(width: 8),
        Text(
            'Showing ${offset + 1}-${(offset + _pageSize).clamp(0, total)} of $total'),
      ];
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      // States
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.query_stats),
              const SizedBox(width: 8),
              const Text('Top States by Views'),
              const Spacer(),
              ...buildPager(_stateOffset, topStates.length,
                  (v) => setState(() => _stateOffset = v)),
              const Spacer(),
              OutlinedButton.icon(
                  onPressed: () async {
                    final csv = await analytics.generateReportCsv(
                        name: 'views_by_state', type: 'views_by_state');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('CSV ready (${csv.length} chars)')));
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export CSV'))
            ]),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search state',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) => setState(() {
                _stateSearch = q.trim().toLowerCase();
                _stateOffset = 0;
              }),
            ),
            const SizedBox(height: 8),
            for (final e in topStates.skip(_stateOffset).take(_pageSize))
              ListTile(
                  dense: true,
                  title: Text(e.key),
                  trailing: Text('${e.value}')),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      // Cities
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_city_outlined),
              const SizedBox(width: 8),
              const Text('Top Cities by Views'),
              const Spacer(),
              ...buildPager(_cityOffset, topCities.length,
                  (v) => setState(() => _cityOffset = v)),
              const Spacer(),
              OutlinedButton.icon(
                  onPressed: () async {
                    final csv = await analytics.generateReportCsv(
                        name: 'views_by_city', type: 'views_by_city');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('CSV ready (${csv.length} chars)')));
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export CSV'))
            ]),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search city',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) => setState(() {
                _citySearch = q.trim().toLowerCase();
                _cityOffset = 0;
              }),
            ),
            const SizedBox(height: 8),
            for (final e in topCities.skip(_cityOffset).take(_pageSize))
              ListTile(
                  dense: true,
                  title: Text(e.key),
                  trailing: Text('${e.value}')),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      // Products
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.inventory_2_outlined),
              const SizedBox(width: 8),
              const Text('Top Products by Views'),
              const Spacer(),
              ...buildPager(_productOffset, topProducts.length,
                  (v) => setState(() => _productOffset = v)),
              const Spacer(),
              OutlinedButton.icon(
                  onPressed: () async {
                    final csv = await analytics.generateReportCsv(
                        name: 'top_products', type: 'top_products');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('CSV ready (${csv.length} chars)')));
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export CSV'))
            ]),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search product',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) => setState(() {
                _productSearch = q.trim().toLowerCase();
                _productOffset = 0;
              }),
            ),
            const SizedBox(height: 8),
            for (final e in topProducts.skip(_productOffset).take(_pageSize))
              ListTile(
                  dense: true,
                  title: Text(productName(e.key)),
                  subtitle: Text('ID: ${e.key}'),
                  trailing: Text('${e.value}')),
          ]),
        ),
      ),
    ]);
  }
}
