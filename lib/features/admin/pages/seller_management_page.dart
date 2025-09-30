import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../store/enhanced_admin_store.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/error_banner.dart';
import '../admin_shell.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../models/admin_user.dart';
import '../models/product_models.dart' as admin_prod;
import '../../sell/hub_shell.dart';

class SellerManagementPage extends ConsumerStatefulWidget {
  const SellerManagementPage({super.key});

  @override
  ConsumerState<SellerManagementPage> createState() =>
      _SellerManagementPageState();
}

class _SellerManagementPageState extends ConsumerState<SellerManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _uploadHistQuery = '';
  String _uploadHistStatus = 'All';
  final Set<String> _selectedSellers = {};
  String? _error;
  final bool _isLoading = false;

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
      backgroundColor: AppColors.surfaceAlt,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Seller Controls',
            actions: [
              OutlinedButton.icon(
                onPressed: _exportSellers,
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _showSellerOnboardingDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Invite Seller'),
              ),
            ],
          ),

          if (_error != null)
            ErrorBanner(
              message: _error!,
              onDismiss: () => setState(() => _error = null),
            ),

          // Tabs
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Sellers'),
                Tab(text: 'Products'),
                Tab(text: 'Uploads'),
                Tab(text: 'Leads'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSellersTab(),
                _buildProductsTab(),
                _buildUploadsTab(),
                _buildLeadsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellersTab() {
    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final sellers = store.sellers.where((seller) {
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            if (!seller.name.toLowerCase().contains(query) &&
                !seller.email.toLowerCase().contains(query)) {
              return false;
            }
          }
          if (_statusFilter != 'all' && seller.status.name != _statusFilter) {
            return false;
          }
          return true;
        }).toList();

        return Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search sellers...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'suspended', child: Text('Suspended')),
                    ],
                    onChanged: (value) =>
                        setState(() => _statusFilter = value!),
                  ),
                ],
              ),
            ),

            // Bulk Actions
            if (_selectedSellers.isNotEmpty)
              BulkActionsBar(
                selectedCount: _selectedSellers.length,
                totalCount: sellers.length,
                onSelectAll: () => setState(
                    () => _selectedSellers.addAll(sellers.map((s) => s.id))),
                onDeselectAll: () => setState(() => _selectedSellers.clear()),
                onBulkAction: _onBulkSellerAction,
              ),

            // Sellers List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: sellers.length,
                      itemBuilder: (context, index) {
                        final seller = sellers[index];
                        return _buildSellerCard(seller);
                      },
                    ),
            ),

            // Pagination
            PaginationBar(
              currentPage: 1,
              totalCount: sellers.length,
              hasMore: false,
              onPageChanged: (page) {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildSellerCard(AdminUser seller) {
    final isSelected = _selectedSellers.contains(seller.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedSellers.add(seller.id);
              } else {
                _selectedSellers.remove(seller.id);
              }
            });
          },
        ),
        title: Text(seller.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(seller.email),
            if (seller.sellerProfile != null) ...[
              Text('Business: ${seller.sellerProfile!.companyName}'),
              Text('GST: ${seller.sellerProfile!.gstNumber}'),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(seller.status),
            PopupMenuButton<String>(
              onSelected: (action) => _handleSellerAction(action, seller),
              itemBuilder: (context) => [
                if (seller.status == UserStatus.pending)
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                if (seller.status != UserStatus.suspended)
                  const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                if (seller.status == UserStatus.suspended)
                  const PopupMenuItem(
                      value: 'activate', child: Text('Activate')),
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(
                    value: 'impersonate', child: Text('Impersonate')),
                const PopupMenuItem(
                    value: 'message', child: Text('Send Message')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    final rawStatus =
        status is Enum ? status.name : (status?.toString() ?? 'unknown');
    final statusKey =
        rawStatus.contains('.') ? rawStatus.split('.').last : rawStatus;

    Color color;
    switch (statusKey) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      case 'pending_review':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(statusKey.toUpperCase()),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  Widget _buildProductsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final products = store.products;

        return Column(
          children: [
            // Product Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'pending_review',
                          child: Text('Pending Review')),
                      DropdownMenuItem(
                          value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(admin_prod.Product product) {
    final sellerName =
        product.customValues['sellerName'] as String? ?? 'Unknown seller';
    final statusName = product.status.name;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(product.title.isEmpty ? 'Untitled product' : product.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seller: $sellerName'),
            Text(
                'Category: ${product.category.isEmpty ? 'Uncategorised' : product.category}'),
            Text('Price: ₹${product.price.toStringAsFixed(2)}'),
            Text('MOQ: ${product.moq}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(statusName),
            PopupMenuButton<String>(
              onSelected: (action) => _handleProductAction(action, product),
              itemBuilder: (context) => [
                if (statusName == 'pending_review')
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                if (statusName == 'pending_review')
                  const PopupMenuItem(value: 'reject', child: Text('Reject')),
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final queue = store.productUploadQueue;
        final history = store.productUploadHistory;
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: AppColors.surface,
                child: Column(children: [
                  TabBar(tabs: [
                    Tab(text: 'Pending (${queue.length})'),
                    Tab(text: 'History (${history.length})'),
                  ]),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      SizedBox(
                        width: 260,
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search title/seller',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) =>
                              setState(() => _uploadHistQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _uploadHistStatus,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(
                              value: 'Approved', child: Text('Approved')),
                          DropdownMenuItem(
                              value: 'Rejected', child: Text('Rejected')),
                        ],
                        onChanged: (v) =>
                            setState(() => _uploadHistStatus = v ?? 'All'),
                      ),
                      const SizedBox(width: 12),
                      const Text('Filters apply to active tab',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _exportUploadHistory(context),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export History'),
                      ),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                child: TabBarView(children: [
                  _uploadList(_filterPending(queue), store),
                  _uploadHistoryList(_filterHistory(history)),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ProductUploadItem> _filterPending(List<ProductUploadItem> items) {
    if (_uploadHistQuery.trim().isEmpty) return items;
    final q = _uploadHistQuery.trim().toLowerCase();
    return items
        .where((i) =>
            (i.proposed['title']?.toString().toLowerCase().contains(q) ??
                false) ||
            i.sellerName.toLowerCase().contains(q))
        .toList();
  }

  List<ProductUploadItem> _filterHistory(List<ProductUploadItem> items) {
    Iterable<ProductUploadItem> res = items;
    if (_uploadHistQuery.trim().isNotEmpty) {
      final q = _uploadHistQuery.trim().toLowerCase();
      res = res.where((i) =>
          (i.proposed['title']?.toString().toLowerCase().contains(q) ??
              false) ||
          i.sellerName.toLowerCase().contains(q));
    }
    if (_uploadHistStatus != 'All') {
      res = res.where((i) => _uploadHistStatus == 'Approved'
          ? i.status == UploadStatus.approved
          : i.status == UploadStatus.rejected);
    }
    return res.toList();
  }

  Widget _uploadList(List<ProductUploadItem> items, EnhancedAdminStore store) {
    if (items.isEmpty) {
      return const Center(child: Text('No pending uploads'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: item.assets.isNotEmpty
                ? CircleAvatar(backgroundImage: AssetImage(item.assets.first))
                : const CircleAvatar(child: Icon(Icons.image_not_supported)),
            title: Text(item.proposed['title']?.toString() ?? 'Untitled'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seller: ${item.sellerName}'),
                Text('Category: ${item.proposed['category'] ?? '-'}'),
                Text('Submitted: ${_timeAgo(item.submittedAt)}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) =>
                  _handleUploadAction(store, item.id, action),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text('View Diff')),
                PopupMenuItem(value: 'approve', child: Text('Approve')),
                PopupMenuItem(value: 'reject', child: Text('Reject')),
              ],
            ),
            onTap: () => _showUploadDiff(context, item),
          ),
        );
      },
    );
  }

  Widget _uploadHistoryList(List<ProductUploadItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No history yet'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
              item.status == UploadStatus.approved
                  ? Icons.check_circle
                  : Icons.cancel,
              color: item.status == UploadStatus.approved
                  ? Colors.green
                  : Colors.red,
            ),
            title: Text(item.proposed['title']?.toString() ?? 'Untitled'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seller: ${item.sellerName}'),
                Text('Reviewed: ${item.reviewedAt ?? '-'}'),
                if (item.reviewerNote != null && item.reviewerNote!.isNotEmpty)
                  Text('Note: ${item.reviewerNote}'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _handleUploadAction(
      EnhancedAdminStore store, String id, String action) async {
    switch (action) {
      case 'view':
        final item = store.productUploadQueue.firstWhere((e) => e.id == id);
        _showUploadDiff(context, item);
        break;
      case 'approve':
        await store.approveProductUpload(id, comments: 'Looks good');
        _showMessage('Upload approved');
        break;
      case 'reject':
        await store.rejectProductUpload(id, reason: 'Incomplete specs');
        _showMessage('Upload rejected');
        break;
    }
  }

  void _showUploadDiff(BuildContext context, ProductUploadItem item) {
    final proposed = item.proposed;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Diff (Demo)'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: SelectableText(
              _prettyJson(proposed),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Approve in dialog')),
        ],
      ),
    );
  }

  String _prettyJson(Map<String, dynamic> json) {
    try {
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (_) {
      return json.toString();
    }
  }

  void _exportUploadHistory(BuildContext context) {
    final store =
        ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
    final history = store.productUploadHistory;
    final buffer = StringBuffer();
    buffer.writeln(
        'id,seller,category,title,status,submitted_at,reviewed_at,note');
    for (final i in history) {
      final status = i.status.name;
      final category = (i.proposed['category'] ?? '').toString();
      final title = (i.proposed['title'] ?? '').toString();
      buffer.writeln([
        i.id,
        i.sellerName,
        category,
        title,
        status,
        i.submittedAt.toIso8601String(),
        i.reviewedAt?.toIso8601String() ?? '',
        i.reviewerNote ?? '',
      ].map((v) => '"${v.toString().replaceAll('"', '""')}"').join(','));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    _showMessage('Uploads history CSV copied to clipboard');
  }

  Widget _buildLeadsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final leads = store.leads;

        return Column(
          children: [
            // Lead Stats
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  _buildStatCard('Total', leads.length.toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _buildStatCard(
                      'Hot',
                      leads
                          .where((l) => l['priority'] == 'high')
                          .length
                          .toString(),
                      Colors.red),
                  const SizedBox(width: 16),
                  _buildStatCard(
                      'Qualified',
                      leads
                          .where((l) => l['status'] == 'qualified')
                          .length
                          .toString(),
                      Colors.green),
                ],
              ),
            ),

            // Leads List
            Expanded(
              child: ListView.builder(
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return _buildLeadCard(lead);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(lead['customerName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lead['customerEmail']),
            Text('Category: ${lead['productCategory']}'),
            Text(
                'Value: ₹${lead['estimatedValue']?.toStringAsFixed(0) ?? 'N/A'}'),
            Text('Priority: ${lead['priority']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(lead['status']),
            PopupMenuButton<String>(
              onSelected: (action) => _handleLeadAction(action, lead),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'assign', child: Text('Assign')),
                const PopupMenuItem(value: 'contact', child: Text('Contact')),
                const PopupMenuItem(value: 'qualify', child: Text('Qualify')),
                const PopupMenuItem(value: 'view', child: Text('View Details')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _handleSellerAction(String action, AdminUser seller) async {
    try {
      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);

      switch (action) {
        case 'approve':
          await store.approveSeller(seller.id, comments: 'Approved by admin');
          _showMessage('Seller approved successfully');
          break;
        case 'suspend':
          await store.suspendSeller(seller.id, reason: 'Suspended by admin');
          _showMessage('Seller suspended successfully');
          break;
        case 'impersonate':
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SellHubShell(
                    adminOverride: true,
                    overrideSellerName: seller.name,
                  )));
          break;
        case 'view':
          _showSellerDetails(seller);
          break;
        case 'message':
          _showMessageDialog(seller);
          break;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _handleProductAction(String action, admin_prod.Product product) {
    // Implement product actions
    _showMessage('Product action: $action for ${product.title}');
  }

  void _handleLeadAction(String action, Map<String, dynamic> lead) {
    // Implement lead actions
    _showMessage('Lead action: $action for ${lead['customerName']}');
  }

  void _handleOrderAction(String action, Map<String, dynamic> order) {
    // Implement order actions
    _showMessage('Order action: $action for ${order['orderNumber']}');
  }

  void _onBulkSellerAction(String action) async {
    if (_selectedSellers.isEmpty) return;

    try {
      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      final ids = List<String>.from(_selectedSellers);
      switch (action) {
        case 'approve':
          for (final id in ids) {
            await store.approveSeller(id, comments: 'Bulk approve');
          }
          _showMessage('Approved ${ids.length} sellers');
          break;
        case 'suspend':
          for (final id in ids) {
            await store.suspendSeller(id, reason: 'Bulk suspend');
          }
          _showMessage('Suspended ${ids.length} sellers');
          break;
        default:
          _showMessage('Unknown bulk action: $action');
      }
      setState(() => _selectedSellers.clear());
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _exportSellers() {
    final store =
        ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
    final sellers = store.sellers.where((seller) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!seller.name.toLowerCase().contains(query) &&
            !seller.email.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_statusFilter != 'all' && seller.status.name != _statusFilter) {
        return false;
      }
      return true;
    }).toList();

    final buffer = StringBuffer();
    buffer.writeln('id,name,email,status,company,gst,city,state');
    for (final s in sellers) {
      final sp = s.sellerProfile;
      buffer.writeln([
        s.id,
        s.name,
        s.email,
        s.status.name,
        sp?.companyName ?? '',
        sp?.gstNumber ?? '',
        sp?.city ?? '',
        sp?.state ?? '',
      ].map((v) => '"${v.toString().replaceAll('"', '""')}"').join(','));
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    _showMessage('Sellers CSV copied to clipboard');
  }

  void _showSellerOnboardingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Seller'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMessage('Invitation sent successfully');
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  void _showSellerDetails(AdminUser seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(seller.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${seller.email}'),
              Text('Status: ${seller.status}'),
              if (seller.sellerProfile != null) ...[
                const SizedBox(height: 16),
                const Text('Business Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Company: ${seller.sellerProfile!.companyName}'),
                Text('GST: ${seller.sellerProfile!.gstNumber}'),
                Text('Address: ${seller.sellerProfile!.address}'),
              ],
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

  void _showMessageDialog(AdminUser seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message ${seller.name}'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMessage('Message sent successfully');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
