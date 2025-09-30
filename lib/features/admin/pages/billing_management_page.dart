import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/billing_models.dart';
import '../models/subscription_models.dart' as sub;
import '../../../app/provider_registry.dart';
import '../models/admin_action_result.dart';
import '../widgets/admin_async_feedback.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';

class BillingManagementPage extends ConsumerStatefulWidget {
  const BillingManagementPage({super.key});

  @override
  ConsumerState<BillingManagementPage> createState() =>
      _BillingManagementPageState();
}

class _BillingManagementPageState extends ConsumerState<BillingManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Payments filters
  PaymentStatus? _selectedPaymentStatus;
  PaymentMethod? _selectedPaymentMethod;
  DateTime? _paymentStartDate;
  DateTime? _paymentEndDate;

  // Invoices filters
  InvoiceStatus? _selectedInvoiceStatus;
  bool? _showOverdueInvoices;
  DateTime? _invoiceStartDate;
  DateTime? _invoiceEndDate;

  // Common filters
  final String _sortBy = 'createdAt';
  final String _sortOrder = 'desc';
  int _currentPage = 1;
  final int _pageSize = 20;

  Set<String> _selectedPayments = {};
  Set<String> _selectedInvoices = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Delay provider modification until after widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBillingData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBillingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final store = ref.read(enhancedAdminStoreProvider);
      await Future.wait([
        store.loadPayments(
          page: _currentPage,
          limit: _pageSize,
          status: _selectedPaymentStatus,
          method: _selectedPaymentMethod,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          startDate: _paymentStartDate,
          endDate: _paymentEndDate,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        ),
        store.loadInvoices(
          page: _currentPage,
          limit: _pageSize,
          status: _selectedInvoiceStatus,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          startDate: _invoiceStartDate,
          endDate: _invoiceEndDate,
          overdue: _showOverdueInvoices,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        ),
        store.loadBillingStats(),
      ]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged() {
    _currentPage = 1;
    _selectedPayments.clear();
    _selectedInvoices.clear();
    _loadBillingData();
  }

  void _onTabChanged() {
    _selectedPayments.clear();
    _selectedInvoices.clear();
    _loadBillingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('billing_management_scaffold'),
      appBar: AppBar(
        title: const Text('Billing Management'),
        bottom: TabBar(
          key: const ValueKey('billing_tab_bar'),
          controller: _tabController,
          onTap: (_) => _onTabChanged(),
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Payments', icon: Icon(Icons.payment)),
            Tab(text: 'Invoices', icon: Icon(Icons.receipt)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBillingData,
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _handleExportAction(action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_payments',
                child: Text('Export Payments'),
              ),
              const PopupMenuItem(
                value: 'export_invoices',
                child: Text('Export Invoices'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              KeyedSubtree(
                key: const ValueKey('overview_tab'),
                child: _buildOverviewTab(),
              ),
              KeyedSubtree(
                key: const ValueKey('payments_tab'),
                child: _buildPaymentsTab(),
              ),
              KeyedSubtree(
                key: const ValueKey('invoices_tab'),
                child: _buildInvoicesTab(),
              ),
            ],
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer(
      key: const ValueKey('overview_consumer'),
      builder: (context, ref, child) {
        final stats = ref.watch(enhancedAdminStoreProvider).billingStats;
        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics
              _buildStatsCards(stats),

              const SizedBox(height: 24),

              // Revenue Chart
              _buildRevenueChart(stats),

              const SizedBox(height: 24),

              // Subscriptions Snapshot
              _buildSubscriptionsSection(),

              const SizedBox(height: 24),

              // Dunning List
              _buildDunningSection(ref.read(enhancedAdminStoreProvider)),

              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDunningSection(dynamic store) {
    final overdue = store.dunningInvoices;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Dunning (${overdue.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (overdue.isEmpty) const Text('No delinquent invoices.'),
            if (overdue.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: overdue.length,
                itemBuilder: (context, index) {
                  final inv = overdue[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.red),
                    title: Text('#${inv.invoiceNumber} — ${inv.userName}'),
                    subtitle: Text(
                        'Amount: ${inv.currency.symbol}${inv.totalAmount.toStringAsFixed(2)} • Due ${inv.dueDate.day}/${inv.dueDate.month}'),
                    trailing: Wrap(spacing: 8, children: [
                      TextButton(
                        onPressed: () => _openInvoiceDetails(inv),
                        child: const Text('View'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(enhancedAdminStoreProvider)
                              .retryInvoicePayment(inv.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Retry triggered')));
                          }
                        },
                        child: const Text('Retry'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(enhancedAdminStoreProvider)
                              .notifyDunningInvoice(inv.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder sent')));
                          }
                        },
                        child: const Text('Notify'),
                      ),
                    ]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final subs = ref.watch(enhancedAdminStoreProvider).subscriptions;
        int active =
            subs.where((s) => s.state == sub.SubscriptionState.active).length;
        int pastDue =
            subs.where((s) => s.state == sub.SubscriptionState.pastDue).length;
        int canceled =
            subs.where((s) => s.state == sub.SubscriptionState.canceled).length;
        int paused =
            subs.where((s) => s.state == sub.SubscriptionState.paused).length;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subscriptions',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard('Active', '$active', Colors.green,
                        Icons.play_circle_fill),
                    _buildStatCard('Past Due', '$pastDue', Colors.orange,
                        Icons.warning_amber),
                    _buildStatCard(
                        'Canceled', '$canceled', Colors.red, Icons.cancel),
                    _buildStatCard('Paused', '$paused', Colors.grey,
                        Icons.pause_circle_filled),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(BillingStats stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Revenue',
          '₹${stats.totalRevenue.toStringAsFixed(0)}',
          Colors.green,
          Icons.attach_money,
        ),
        _buildStatCard(
          'Monthly Revenue',
          '₹${stats.monthlyRevenue.toStringAsFixed(0)}',
          Colors.blue,
          Icons.trending_up,
        ),
        _buildStatCard(
          'Pending Payments',
          '₹${stats.pendingPayments.toStringAsFixed(0)}',
          Colors.orange,
          Icons.pending,
        ),
        _buildStatCard(
          'Overdue Amount',
          '₹${stats.overdueAmount.toStringAsFixed(0)}',
          Colors.red,
          Icons.warning,
        ),
        _buildStatCard(
          'Total Invoices',
          stats.totalInvoices.toString(),
          Colors.purple,
          Icons.receipt,
        ),
        _buildStatCard(
          'Pending Invoices',
          stats.pendingInvoices.toString(),
          Colors.amber,
          Icons.pending_actions,
        ),
        _buildStatCard(
          'Overdue Invoices',
          stats.overdueInvoices.toString(),
          Colors.red,
          Icons.schedule,
        ),
        _buildStatCard(
          'Success Rate',
          '${((stats.successfulPayments / stats.totalPayments) * 100).toStringAsFixed(1)}%',
          Colors.green,
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(BillingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Revenue chart would be displayed here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.green),
              title: Text('Payment received'),
              subtitle: Text('₹2,500 from John Doe'),
              trailing: Text('2 min ago'),
            ),
            ListTile(
              leading: Icon(Icons.receipt, color: Colors.blue),
              title: Text('Invoice sent'),
              subtitle: Text('Invoice #INV-001 to Jane Smith'),
              trailing: Text('1 hour ago'),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Payment failed'),
              subtitle: Text('₹1,200 from Bob Wilson'),
              trailing: Text('3 hours ago'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return Column(
      children: [
        // Filters
        _buildPaymentFilters(),

        // Bulk Actions
        if (_selectedPayments.isNotEmpty)
          BulkActionsBar(
            selectedCount: _selectedPayments.length,
            totalCount: ref.read(enhancedAdminStoreProvider).payments.length,
            onSelectAll: () {
              setState(() {
                _selectedPayments = Set.from(
                  ref
                      .read(enhancedAdminStoreProvider)
                      .payments
                      .map((p) => p.id),
                );
              });
            },
            onDeselectAll: () {
              setState(() {
                _selectedPayments.clear();
              });
            },
            onBulkAction: (action) => _handleBulkPaymentAction(action),
          ),

        // Payments List
        Expanded(child: _buildPaymentsList()),

        // Pagination
        Consumer(
          key: const ValueKey('payments_pagination_consumer'),
          builder: (context, ref, child) {
            return PaginationBar(
              currentPage: _currentPage,
              totalCount:
                  ref.watch(enhancedAdminStoreProvider).paymentsTotalCount,
              hasMore: ref.watch(enhancedAdminStoreProvider).hasMore,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                _loadBillingData();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by user, transaction ID...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onFilterChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onFilterChanged,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PaymentStatus?>(
                    value: _selectedPaymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...PaymentStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentStatus = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PaymentMethod?>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Methods'),
                      ),
                      ...PaymentMethod.values.map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method.displayName),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(_paymentStartDate != null
                        ? '${_paymentStartDate!.day}/${_paymentStartDate!.month} - ${_paymentEndDate?.day}/${_paymentEndDate?.month}'
                        : 'Select Date Range'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    if (_error != null) {
      return ErrorBanner(
        message: _error!,
        onDismiss: () => setState(() => _error = null),
      );
    }

    return Consumer(
      key: const ValueKey('payments_consumer'),
      builder: (context, ref, child) {
        final payments = ref.watch(enhancedAdminStoreProvider).payments;

        if (payments.isEmpty) {
          return const Center(child: Text('No payments found'));
        }

        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final isSelected = _selectedPayments.contains(payment.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedPayments.add(payment.id);
                      } else {
                        _selectedPayments.remove(payment.id);
                      }
                    });
                  },
                ),
                title: Text(payment.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.userEmail),
                    Text(
                        '${payment.currency.symbol}${payment.amount.toStringAsFixed(2)}'),
                    if (payment.transactionId != null)
                      Text('TXN: ${payment.transactionId}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(payment.status)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        payment.status.displayName,
                        style: TextStyle(
                          color: _getPaymentStatusColor(payment.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.method.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: () => _openPaymentDetails(payment),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInvoicesTab() {
    return Column(
      children: [
        // Filters
        _buildInvoiceFilters(),

        // Bulk Actions
        if (_selectedInvoices.isNotEmpty)
          BulkActionsBar(
            selectedCount: _selectedInvoices.length,
            totalCount: ref.read(enhancedAdminStoreProvider).invoices.length,
            onSelectAll: () {
              setState(() {
                _selectedInvoices = Set.from(
                  ref
                      .read(enhancedAdminStoreProvider)
                      .invoices
                      .map((i) => i.id),
                );
              });
            },
            onDeselectAll: () {
              setState(() {
                _selectedInvoices.clear();
              });
            },
            onBulkAction: (action) => _handleBulkInvoiceAction(action),
          ),

        // Invoices List
        Expanded(child: _buildInvoicesList()),

        // Pagination
        Consumer(
          key: const ValueKey('invoices_pagination_consumer'),
          builder: (context, ref, child) {
            return PaginationBar(
              currentPage: _currentPage,
              totalCount:
                  ref.watch(enhancedAdminStoreProvider).invoicesTotalCount,
              hasMore: ref.watch(enhancedAdminStoreProvider).hasMore,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                _loadBillingData();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInvoiceFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by invoice number, user...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onFilterChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onFilterChanged,
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue only'),
                  selected: _showOverdueInvoices == true,
                  onSelected: (selected) {
                    setState(() {
                      _showOverdueInvoices = selected ? true : null;
                    });
                    _onFilterChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<InvoiceStatus?>(
                    value: _selectedInvoiceStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...InvoiceStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedInvoiceStatus = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    value: _showOverdueInvoices,
                    decoration: const InputDecoration(
                      labelText: 'Overdue',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                          value: true, child: Text('Overdue Only')),
                      DropdownMenuItem(
                          value: false, child: Text('Not Overdue')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _showOverdueInvoices = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectInvoiceDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(_invoiceStartDate != null
                        ? '${_invoiceStartDate!.day}/${_invoiceStartDate!.month} - ${_invoiceEndDate?.day}/${_invoiceEndDate?.month}'
                        : 'Select Date Range'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_error != null) {
      return ErrorBanner(
        message: _error!,
        onDismiss: () => setState(() => _error = null),
      );
    }

    return Consumer(
      key: const ValueKey('invoices_consumer'),
      builder: (context, ref, child) {
        final invoices = ref.watch(enhancedAdminStoreProvider).invoices;

        if (invoices.isEmpty) {
          return const Center(child: Text('No invoices found'));
        }

        return ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            final isSelected = _selectedInvoices.contains(invoice.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedInvoices.add(invoice.id);
                      } else {
                        _selectedInvoices.remove(invoice.id);
                      }
                    });
                  },
                ),
                title: Text(invoice.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.userEmail),
                    Text('Invoice #${invoice.invoiceNumber}'),
                    Text(
                        '${invoice.currency.symbol}${invoice.totalAmount.toStringAsFixed(2)}'),
                    if (invoice.isOverdue)
                      Text(
                        '${invoice.daysOverdue} days overdue',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getInvoiceStatusColor(invoice.status)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        invoice.status.displayName,
                        style: TextStyle(
                          color: _getInvoiceStatusColor(invoice.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${invoice.dueDate.day}/${invoice.dueDate.month}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: () => _openInvoiceDetails(invoice),
              ),
            );
          },
        );
      },
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _paymentStartDate != null && _paymentEndDate != null
          ? DateTimeRange(start: _paymentStartDate!, end: _paymentEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _paymentStartDate = picked.start;
        _paymentEndDate = picked.end;
      });
      _onFilterChanged();
    }
  }

  void _selectInvoiceDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _invoiceStartDate != null && _invoiceEndDate != null
          ? DateTimeRange(start: _invoiceStartDate!, end: _invoiceEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _invoiceStartDate = picked.start;
        _invoiceEndDate = picked.end;
      });
      _onFilterChanged();
    }
  }

  void _handleExportAction(String action) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final store = ref.read(enhancedAdminStoreProvider);

      String resultPath;
      if (action == 'export_payments') {
        resultPath = await store.exportPaymentsCsv(
          status: _selectedPaymentStatus,
          method: _selectedPaymentMethod,
          startDate: _paymentStartDate,
          endDate: _paymentEndDate,
        );
      } else {
        resultPath = await store.exportInvoicesCsv(
          status: _selectedInvoiceStatus,
          startDate: _invoiceStartDate,
          endDate: _invoiceEndDate,
          overdue: _showOverdueInvoices,
        );
      }

      if (mounted) {
        final msg = 'Export generated (${resultPath.length} chars)';
        AdminAsyncFeedback.showSnackBar(
          context,
          AdminActionResult.success(msg),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleBulkPaymentAction(String action) async {
    if (_selectedPayments.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final store = ref.read(enhancedAdminStoreProvider);
      await store.performBulkPaymentAction(
        paymentIds: _selectedPayments.toList(),
        action: action,
      );

      setState(() {
        _selectedPayments.clear();
      });

      _loadBillingData();

      if (mounted) {
        AdminAsyncFeedback.showSnackBar(
          context,
          const AdminActionResult.success('Bulk payment action completed'),
        );
      }
    } catch (e) {
      if (mounted) {
        AdminAsyncFeedback.showSnackBar(
          context,
          AdminActionResult.error('Error: ${e.toString()}'),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleBulkInvoiceAction(String action) async {
    if (_selectedInvoices.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final store = ref.read(enhancedAdminStoreProvider);
      await store.performBulkInvoiceAction(
        invoiceIds: _selectedInvoices.toList(),
        action: action,
      );

      setState(() {
        _selectedInvoices.clear();
      });

      _loadBillingData();

      if (mounted) {
        AdminAsyncFeedback.showSnackBar(
          context,
          const AdminActionResult.success('Bulk invoice action completed'),
        );
      }
    } catch (e) {
      if (mounted) {
        AdminAsyncFeedback.showSnackBar(
          context,
          AdminActionResult.error('Error: ${e.toString()}'),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment ${payment.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('${payment.userName} • ${payment.userEmail}'),
              Text(
                  '${payment.currency.symbol}${payment.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Row(children: [
                Chip(label: Text(payment.status.displayName)),
                const SizedBox(width: 8),
                Chip(label: Text(payment.method.displayName)),
              ]),
              const SizedBox(height: 8),
              if (payment.transactionId != null)
                Text('Txn: ${payment.transactionId}'),
              Text('Created: ${payment.createdAt}'),
              if (payment.processedAt != null)
                Text('Processed: ${payment.processedAt}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () => Navigator.pop(context),
                    label: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  if (payment.status != PaymentStatus.refunded &&
                      payment.status != PaymentStatus.failed)
                    FilledButton.icon(
                      icon: const Icon(Icons.undo),
                      onPressed: () async {
                        final store = ref.read(enhancedAdminStoreProvider);
                        await store.createRefund(CreateRefundRequest(
                          paymentId: payment.id,
                          amount: payment.amount,
                          reason: 'Refund issued',
                        ));
                        if (mounted) Navigator.pop(context);
                        _loadBillingData();
                      },
                      label: const Text('Refund'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Invoice ${invoice.invoiceNumber}'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${invoice.userName} • ${invoice.userEmail}'),
              const SizedBox(height: 8),
              Text(
                  'Total: ${invoice.currency.symbol}${invoice.totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Row(children: [
                Chip(label: Text(invoice.status.displayName)),
                const SizedBox(width: 8),
                Text('Due: ${invoice.dueDate}'),
              ]),
              const Divider(),
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  itemCount: invoice.items.length,
                  itemBuilder: (context, idx) {
                    final it = invoice.items[idx];
                    return ListTile(
                      dense: true,
                      title: Text(it.description),
                      trailing: Text(
                          '${invoice.currency.symbol}${it.totalPrice.toStringAsFixed(2)}'),
                      subtitle: Text(
                          'Qty ${it.quantity} • Unit ${invoice.currency.symbol}${it.unitPrice.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          if (invoice.status == InvoiceStatus.draft ||
              invoice.status == InvoiceStatus.pending)
            FilledButton(
              onPressed: () async {
                final store = ref.read(enhancedAdminStoreProvider);
                await store.sendInvoice(invoice.id);
                if (mounted) Navigator.pop(context);
                _loadBillingData();
              },
              child: const Text('Send'),
            ),
          OutlinedButton(
            onPressed: () async {
              final store = ref.read(enhancedAdminStoreProvider);
              await store.createRefund(CreateRefundRequest(
                paymentId: 'invoice_${invoice.id}',
                amount:
                    (invoice.totalAmount * 0.1).clamp(0, invoice.totalAmount),
                reason: 'Credit note issued',
              ));
              if (mounted) Navigator.pop(context);
              _loadBillingData();
            },
            child: const Text('Add Credit'),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.partiallyRefunded:
        return Colors.amber;
    }
  }

  Color _getInvoiceStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
      case InvoiceStatus.voided:
        return Colors.grey;
    }
  }
}
