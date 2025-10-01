import 'package:flutter/material.dart';
import 'dart:convert';
import '../../widgets/image_upload_widget.dart';
import '../sell/models.dart';
import '../sell/widgets/materials_selector.dart';
import '../sell/widgets/simple_custom_fields.dart';
import '../../widgets/bi_directional_scroller.dart';
import '../../app/tokens.dart';
import '../../app/breakpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import 'models/admin_user.dart';
import '../sell/models.dart' as sell_models;
// duplicates removed
import '../sell/hub_shell.dart';
import '../sell/product_form_page.dart';
// unused import removed
import 'pages/hero_sections_page.dart';
import 'pages/categories_management_page.dart';
import 'pages/notifications_page.dart';
import 'pages/subscription_management_page.dart';
import 'pages/kyc_management_page.dart';
import 'pages/billing_management_page.dart';
import 'pages/seller_management_page.dart';
import 'pages/system_operations_page.dart';
import 'pages/feature_flags_page.dart';
import 'pages/analytics_dashboard_page.dart';
import 'pages/media_storage_page.dart';
import 'pages/enhanced_users_management_page.dart';
import 'pages/enhanced_products_management_page.dart';
import 'pages/users_management_page_v2.dart';
import 'pages/products_management_page_v2.dart';
// rbac service accessed via providers
import 'auth/admin_login_page.dart';
import 'rbac/rbac_page.dart';
import 'store/enhanced_admin_store.dart';
// permission gate used in pages directly
import '../stateinfo/clean_state_info_page.dart';

/// Responsive header component for Admin Console pages
class AdminPageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;

  const AdminPageHeader({
    super.key,
    required this.title,
    required this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineSoft, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Actions row with horizontal scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...actions
                    .expand((action) => [
                          action,
                          const SizedBox(width: 8),
                        ])
                    .take(actions.length * 2 - 1), // Remove last spacing
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacSvc = ref.watch(rbacServiceProvider);
    final auth = ref.watch(adminAuthServiceProvider);
    final roles = rbacSvc.roleToPermissions.keys.toList()..sort();
    final currentUserId = auth.currentUser?.userId;
    final currentAssigned = currentUserId != null
        ? (rbacSvc.getAssignedRole(currentUserId) ?? auth.currentUser?.role)
        : null;
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: roles.contains(currentAssigned) ? currentAssigned : null,
        hint: const Text('Select RBAC role'),
        isExpanded: true,
        items: [
          for (final r in roles)
            DropdownMenuItem(
              value: r,
              child: Text(
                r,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (v) async {
          if (v == null || currentUserId == null) return;
          await rbacSvc.assignRoleToUser(currentUserId, v);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Role set to $v')));
          }
        },
        decoration:
            const InputDecoration(isDense: true, border: OutlineInputBorder()),
      ),
    );
  }
}

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell>
    with TickerProviderStateMixin {
  int selectedCategoryIndex = 0;
  int selectedItemIndex = 0;
  late TabController _tabController;

  // Configurable admin categories - can be modified for feature flags
  List<AdminCategory> get categories => _getAdminCategories();

  List<AdminCategory> _getAdminCategories() {
    return [
      const AdminCategory(
        name: 'Dashboard',
        icon: Icons.dashboard_outlined,
        items: [
          AdminItem(
              label: 'Overview',
              icon: Icons.analytics_outlined,
              page: _AdminDashboard()),
        ],
      ),
      AdminCategory(
        name: 'User Controls',
        icon: Icons.people_outline,
        items: [
          const AdminItem(
              label: 'Users',
              icon: Icons.people_outline,
              page: UsersManagementPageV2()),
          const AdminItem(
              label: 'RBAC',
              icon: Icons.admin_panel_settings_outlined,
              page: RbacTabbedPage()),
          const AdminItem(
              label: 'KYC Reviews',
              icon: Icons.verified_user_outlined,
              page: KycManagementPage()),
          const AdminItem(
              label: 'Billing',
              icon: Icons.receipt_long_outlined,
              page: BillingManagementPage()),
        ],
      ),
      AdminCategory(
        name: 'Seller Controls',
        icon: Icons.storefront_outlined,
        items: [
          const AdminItem(
              label: 'Sellers',
              icon: Icons.storefront_outlined,
              page: SellerManagementPage()),
          const AdminItem(
              label: 'Products',
              icon: Icons.inventory_2_outlined,
              page: ProductsManagementPageV2()),
          const AdminItem(
              label: 'Product Uploads',
              icon: Icons.upload_file_outlined,
              page: _ProductUploadsPage()),
          const AdminItem(
              label: 'Ads & Slots',
              icon: Icons.campaign_outlined,
              page: _AdsPage()),
          const AdminItem(
              label: 'Leads', icon: Icons.work_outline, page: _LeadsPage()),
          const AdminItem(
              label: 'Orders',
              icon: Icons.receipt_long_outlined,
              page: _OrdersPage()),
          const AdminItem(
              label: 'Subscription Management',
              icon: Icons.subscriptions_outlined,
              page: SubscriptionManagementPage()),
        ],
      ),
      const AdminCategory(
        name: 'Content & Communication',
        icon: Icons.chat_bubble_outline,
        items: [
          AdminItem(
              label: 'Hero Sections',
              icon: Icons.slideshow,
              page: _HeroSectionsPage()),
          AdminItem(
              label: 'Categories',
              icon: Icons.category_outlined,
              page: _CategoriesManagementPage()),
          AdminItem(
              label: 'Messaging',
              icon: Icons.chat_bubble_outline,
              page: _MessagingPage()),
          AdminItem(
              label: 'State Info',
              icon: Icons.info_outline,
              page: _AdminStateInfoEntry()),
          AdminItem(
              label: 'Notifications',
              icon: Icons.notifications_none_outlined,
              page: NotificationsPage()),
        ],
      ),
      const AdminCategory(
        name: 'System & Operations',
        icon: Icons.settings_applications_outlined,
        items: [
          AdminItem(
              label: 'Search & Relevance',
              icon: Icons.search,
              page: _SearchPage()),
          AdminItem(
              label: 'Geo & Regions',
              icon: Icons.public_outlined,
              page: _GeoPage()),
          AdminItem(
              label: 'Analytics Dashboard',
              icon: Icons.analytics_outlined,
              page: _AnalyticsDashboardPage()),
          AdminItem(
              label: 'Compliance',
              icon: Icons.policy_outlined,
              page: _CompliancePage()),
          AdminItem(
              label: 'Feature Flags',
              icon: Icons.toggle_on_outlined,
              page: _FeatureFlagsPage()),
          AdminItem(
              label: 'Audit Logs',
              icon: Icons.event_note_outlined,
              page: _AuditLogsPage()),
          AdminItem(
              label: 'System Operations',
              icon: Icons.settings_applications_outlined,
              page: _SystemOperationsPage()),
          AdminItem(
              label: 'Bulk Ops',
              icon: Icons.batch_prediction_outlined,
              page: _BulkOpsPage()),
          AdminItem(
              label: 'Data Export',
              icon: Icons.upload_outlined,
              page: _DataExportPage()),
          AdminItem(
              label: 'Dev Tools',
              icon: Icons.code_outlined,
              page: _DevToolsPage()),
        ],
      ),
      const AdminCategory(
        name: 'Media & Storage',
        icon: Icons.cloud_upload_outlined,
        items: [
          AdminItem(
              label: 'Media Files',
              icon: Icons.folder_outlined,
              page: _MediaStoragePage()),
          AdminItem(
              label: 'CDN Management',
              icon: Icons.cloud_outlined,
              page: _MediaStoragePage()),
          AdminItem(
              label: 'Storage Quotas',
              icon: Icons.storage_outlined,
              page: _MediaStoragePage()),
          AdminItem(
              label: 'File Cleanup',
              icon: Icons.cleaning_services_outlined,
              page: _MediaStoragePage()),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: categories[selectedCategoryIndex].items.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int categoryIndex) {
    setState(() {
      selectedCategoryIndex = categoryIndex;
      selectedItemIndex = 0;
    });
    _tabController.dispose();
    _tabController = TabController(
      length: categories[categoryIndex].items.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(adminAuthServiceProvider);
    final adminStore = ref.watch(adminStoreProvider);
    // Watching RBAC service ensures UI updates when role/permissions change
    ref.watch(rbacServiceProvider);
    if (!auth.isLoggedIn) {
      return const Scaffold(body: Center(child: Text('Not authorized')));
    }

    List<AdminCategory> filteredCategories = categories
        .map((cat) {
          final filteredItems = cat.items.where((item) {
            final key = _permissionForLabel(item.label);
            if (key == null) return true;
            return auth.hasPermission(key);
          }).toList();
          return AdminCategory(
              name: cat.name, icon: cat.icon, items: filteredItems);
        })
        .where((cat) => cat.items.isNotEmpty)
        .toList();

    // Ensure selectedCategoryIndex is within bounds after filtering
    if (selectedCategoryIndex >= filteredCategories.length) {
      selectedCategoryIndex = 0;
      selectedItemIndex = 0;
    }

    if (filteredCategories.isNotEmpty &&
        filteredCategories[selectedCategoryIndex].items.isEmpty) {
      // pick first non-empty category
      final idx = filteredCategories.indexWhere((c) => c.items.isNotEmpty);
      if (idx != -1) {
        selectedCategoryIndex = idx;
        selectedItemIndex = 0;
        _tabController.dispose();
        _tabController = TabController(
            length: filteredCategories[selectedCategoryIndex].items.length,
            vsync: this);
      }
    }

    // Ensure TabController matches filtered item count on mobile
    if (_tabController.length !=
        filteredCategories[selectedCategoryIndex].items.length) {
      _tabController.dispose();
      _tabController = TabController(
          length: filteredCategories[selectedCategoryIndex].items.length,
          vsync: this);
    }
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Admin Console'),
          const SizedBox(width: 12),
          if (adminStore.maintenanceMode)
            Chip(
                label: const Text('Maintenance'),
                backgroundColor: Colors.red.shade400,
                labelStyle: const TextStyle(color: Colors.white)),
        ]),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _RoleSelector(),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(adminAuthServiceProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                  (route) => route.isFirst,
                );
              }
            },
          ),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout(filteredCategories)
          : _buildMobileLayout(filteredCategories),
    );
  }

  Widget _buildDesktopLayout(List<AdminCategory> filteredCategories) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main category navigation
        NavigationRail(
          selectedIndex: selectedCategoryIndex,
          onDestinationSelected: _onCategorySelected,
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.surface,
          destinations: filteredCategories.map((category) {
            return NavigationRailDestination(
              icon: Icon(category.icon),
              selectedIcon: Icon(category.icon),
              label: Text(category.name),
            );
          }).toList(),
        ),
        const VerticalDivider(width: 1, color: AppColors.divider),

        // Sub-category navigation and content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-category sidebar
              Container(
                width: 200,
                color: AppColors.surfaceAlt,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        filteredCategories[selectedCategoryIndex].name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCategories[selectedCategoryIndex]
                            .items
                            .length,
                        itemBuilder: (context, index) {
                          final item = filteredCategories[selectedCategoryIndex]
                              .items[index];
                          final isSelected = selectedItemIndex == index;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AppColors.primarySurface,
                            leading: Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedItemIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, color: AppColors.divider),

              // Content area
              Expanded(
                child: filteredCategories[selectedCategoryIndex]
                    .items[selectedItemIndex]
                    .page,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<AdminCategory> filteredCategories) {
    return Column(
      children: [
        // Category tabs
        Container(
          color: AppColors.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filteredCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isSelected = selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(index),
                    label: Text(category.name),
                    avatar: Icon(category.icon, size: 18),
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),

        // Item tabs
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: filteredCategories[selectedCategoryIndex].items.map((item) {
              return Tab(
                icon: Icon(item.icon, size: 18),
                text: item.label,
              );
            }).toList(),
            onTap: (index) {
              setState(() {
                selectedItemIndex = index;
              });
            },
          ),
        ),
        const Divider(height: 1),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: filteredCategories[selectedCategoryIndex]
                .items
                .map((item) => item.page)
                .toList(),
          ),
        ),
      ],
    );
  }
}

class AdminCategory {
  final String name;
  final IconData icon;
  final List<AdminItem> items;

  const AdminCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}

class AdminItem {
  final String label;
  final IconData icon;
  final Widget page;

  const AdminItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}

String? _permissionForLabel(String label) {
  final l = label.toLowerCase();
  if (l == 'rbac') return 'rbac.manage';
  if (l == 'users') return 'users.read';
  if (l == 'kyc reviews') return 'kyc.review';
  if (l == 'billing') return 'billing.manage';
  if (l == 'sellers') return 'sellers.read';
  if (l == 'products') return 'products.read';
  if (l == 'product uploads') return 'uploads.review';
  if (l == 'ads & slots') return 'ads.manage';
  if (l == 'leads') return 'leads.manage';
  if (l == 'orders') return 'orders.manage';
  if (l == 'subscription management') return 'billing.manage';
  if (l == 'hero sections' ||
      l == 'categories' ||
      l == 'messaging' ||
      l == 'notifications' ||
      l == 'state info') return 'cms.manage';
  if (l == 'search & relevance') return 'search.tune';
  if (l == 'geo & regions') return 'geo.manage';
  if (l == 'analytics dashboard') return 'analytics.view';
  if (l == 'compliance') return 'compliance.manage';
  if (l == 'feature flags') return 'feature.flags';
  if (l == 'audit logs') return 'audit.read';
  if (l == 'system operations') return 'system.ops';
  if (l == 'bulk ops') return 'bulk.ops';
  if (l == 'data export') return 'export.data';
  if (l == 'dev tools') return 'dev.tools';
  if (l == 'media files' ||
      l == 'cdn management' ||
      l == 'storage quotas' ||
      l == 'file cleanup') return 'media.manage';
  return null;
}

// Removed duplicate _NotificationsPage; using NotificationsPage directly

// --- Pages ---
class _AdminStateInfoEntry extends ConsumerWidget {
  const _AdminStateInfoEntry();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(adminAuthServiceProvider);
    if (!auth.hasPermission('cms.manage')) {
      return const Center(child: Text('Not authorized'));
    }
    return const CleanStateInfoPage(showAdminControls: true);
  }
}


class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _statCard('DAU', '2,430'),
          _statCard('Sellers', '1,280'),
          _statCard('Products', '18,430'),
          _statCard('Leads (Open)', '312'),
          _statCard('Ads (Active)', '76'),
        ]),
      ]),
    );
  }
}

class _RbacPage extends StatefulWidget {
  const _RbacPage();
  @override
  State<_RbacPage> createState() => _RbacPageState();
}

class _RbacPageState extends State<_RbacPage> {
  String newRole = '';
  String newPerm = '';
  String selectedRole = 'admin';
  final List<Map<String, dynamic>> presets = const [
    {
      'name': 'Viewer',
      'perms': ['users.read', 'products.read', 'analytics.view', 'audit.read']
    },
    {
      'name': 'Moderator',
      'perms': ['users.read', 'messaging.moderate', 'kyc.review', 'audit.read']
    },
    {
      'name': 'Ops',
      'perms': [
        'users.write',
        'orders.manage',
        'leads.manage',
        'uploads.review',
        'audit.read'
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final store = ProviderScope.containerOf(context).read(adminStoreProvider);
    final roles = store.roleToPermissions.keys.toList()..sort();
    if (!roles.contains(selectedRole) && roles.isNotEmpty)
      selectedRole = roles.first;
    final perms = store.roleToPermissions[selectedRole] ?? {};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Access Control (RBAC)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const Text('Role:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
              value: selectedRole.isEmpty
                  ? (roles.isEmpty ? null : roles.first)
                  : selectedRole,
              items: [
                for (final r in roles)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) =>
                  setState(() => selectedRole = v ?? selectedRole)),
          const Spacer(),
          SizedBox(
              width: 180,
              child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'New role', border: OutlineInputBorder()),
                  onChanged: (v) => newRole = v)),
          const SizedBox(width: 8),
          OutlinedButton(
              onPressed: newRole.trim().isEmpty
                  ? null
                  : () {
                      store.createRole(newRole.trim());
                      setState(() => selectedRole = newRole.trim());
                    },
              child: const Text('Create Role')),
          const SizedBox(width: 8),
          OutlinedButton(
              onPressed: (selectedRole == 'admin' ||
                      selectedRole == 'seller' ||
                      selectedRole == 'buyer')
                  ? null
                  : () {
                      store.deleteRole(selectedRole);
                      setState(() => selectedRole =
                          roles.isNotEmpty ? roles.first : 'admin');
                    },
              child: const Text('Delete Role')),
          const SizedBox(width: 12),
          SizedBox(
              width: 240,
              child: TextField(
                  decoration: const InputDecoration(
                      labelText: 'New permission',
                      border: OutlineInputBorder()),
                  onChanged: (v) => newPerm = v)),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: newPerm.trim().isEmpty
                  ? null
                  : () {
                      store.grantPermissionToRole(selectedRole, newPerm.trim());
                      setState(() => newPerm = '');
                    },
              child: const Text('Grant')),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Text('Apply preset:'),
          const SizedBox(width: 8),
          for (final p in presets) ...[
            OutlinedButton(
                onPressed: () async {
                  for (final perm in (p['perms'] as List)) {
                    await store.grantPermissionToRole(
                        selectedRole, perm as String);
                  }
                  if (!roles.contains(p['name'])) {
                    // optional: create a role named the preset
                  }
                },
                child: Text(p['name'] as String)),
            const SizedBox(width: 6),
          ]
        ]),
      ),
      const Divider(height: 16),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in perms.toList()..sort())
                Chip(
                  label: Text(p),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    store.revokePermissionFromRole(selectedRole, p);
                    setState(() {});
                  },
                ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();
  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  String channel = 'email';
  final to = TextEditingController();
  final subject = TextEditingController();
  final body = TextEditingController();
  String template = 'None';

  @override
  void dispose() {
    to.dispose();
    subject.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Template:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
                value: template,
                items: [
                  const DropdownMenuItem(value: 'None', child: Text('None')),
                  ...ProviderScope.containerOf(context)
                      .read(adminStoreProvider)
                      .templates
                      .map((t) => DropdownMenuItem(value: t, child: Text(t))),
                ],
                onChanged: (v) {
                  setState(() {
                    template = v ?? 'None';
                    if (template != 'None') {
                      subject.text = template;
                      body.text = 'Hello, ...';
                    }
                  });
                }),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            DropdownButton<String>(
                value: channel,
                items: const [
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'sms', child: Text('SMS')),
                  DropdownMenuItem(value: 'inapp', child: Text('In-App')),
                ],
                onChanged: (v) => setState(() => channel = v ?? 'email')),
            const SizedBox(width: 12),
            SizedBox(
                width: 280,
                child: TextField(
                    controller: to,
                    decoration: const InputDecoration(
                        labelText: 'To (email/phone/userId)',
                        border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          if (channel != 'sms')
            SizedBox(
                width: 420,
                child: TextField(
                    controller: subject,
                    decoration: const InputDecoration(
                        labelText: 'Subject', border: OutlineInputBorder()))),
          const SizedBox(height: 12),
          TextField(
              controller: body,
              maxLines: 5,
              decoration: const InputDecoration(
                  labelText: 'Message', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send),
                label: const Text('Send')),
            const SizedBox(width: 8),
            OutlinedButton.icon(
                onPressed: _queue,
                icon: const Icon(Icons.schedule),
                label: const Text('Queue')),
          ]),
        ]),
      ),
    ]);
  }

  void _send() {
    _processNotification(channel, to.text.trim(), body.text.trim(), false);
  }

  void _queue() {
    _processNotification(channel, to.text.trim(), body.text.trim(), true);
  }

  void _processNotification(
      String channel, String recipient, String messageText, bool queued) {
    // Simulate notification processing
    // In a real app, you would:
    // 1. Send to notification service
    // 2. Store in database
    // 3. Track delivery status
    // 4. Handle failures and retries

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${queued ? 'Queued' : 'Sent'} ${channel.toUpperCase()} to $recipient'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _BulkOpsPage extends StatefulWidget {
  const _BulkOpsPage();
  @override
  State<_BulkOpsPage> createState() => _BulkOpsPageState();
}

class _BulkOpsPageState extends State<_BulkOpsPage> {
  String target = 'users';
  String mode = 'edit';
  String sample = 'id,name,email\nU1001,John,john@example.com';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Bulk Operations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            DropdownButton<String>(
                value: target,
                items: const [
                  DropdownMenuItem(value: 'users', child: Text('Users')),
                  DropdownMenuItem(value: 'products', child: Text('Products')),
                  DropdownMenuItem(value: 'leads', child: Text('Leads')),
                ],
                onChanged: (v) => setState(() => target = v ?? 'users')),
            const SizedBox(width: 12),
            DropdownButton<String>(
                value: mode,
                items: const [
                  DropdownMenuItem(value: 'edit', child: Text('Bulk Edit')),
                  DropdownMenuItem(value: 'import', child: Text('CSV Import')),
                  DropdownMenuItem(value: 'export', child: Text('CSV Export')),
                ],
                onChanged: (v) => setState(() => mode = v ?? 'edit')),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: 680,
            child: TextField(
              controller: TextEditingController(text: sample),
              maxLines: 8,
              onChanged: (v) {
                sample = v;
              },
              decoration: const InputDecoration(
                  labelText: 'CSV (paste or edit)',
                  border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            OutlinedButton.icon(
                onPressed: _downloadTemplate,
                icon: const Icon(Icons.download),
                label: const Text('Download Template')),
            const SizedBox(width: 8),
            FilledButton.icon(
                onPressed: _process,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Process')),
          ]),
        ]),
      ),
    ]);
  }

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template for $target ready (demo)')));
  }

  void _process() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${mode.toUpperCase()} for $target processed (demo)')));
  }
}

class _DataExportPage extends StatefulWidget {
  const _DataExportPage();
  @override
  State<_DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<_DataExportPage> {
  String module = 'users';
  String format = 'csv';
  String scope = 'all';
  final idsCtrl = TextEditingController();
  final filterCtrl = TextEditingController();

  @override
  void dispose() {
    idsCtrl.dispose();
    filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Data Export',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            DropdownButton<String>(
                value: module,
                items: const [
                  DropdownMenuItem(value: 'users', child: Text('Users')),
                  DropdownMenuItem(value: 'products', child: Text('Products')),
                  DropdownMenuItem(value: 'leads', child: Text('Leads')),
                  DropdownMenuItem(value: 'orders', child: Text('Orders')),
                  DropdownMenuItem(value: 'messages', child: Text('Messages')),
                ],
                onChanged: (v) => setState(() => module = v ?? 'users')),
            const SizedBox(width: 8),
            DropdownButton<String>(
                value: format,
                items: const [
                  DropdownMenuItem(value: 'csv', child: Text('CSV')),
                  DropdownMenuItem(value: 'json', child: Text('JSON')),
                ],
                onChanged: (v) => setState(() => format = v ?? 'csv')),
            const SizedBox(width: 8),
            DropdownButton<String>(
                value: scope,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'filtered', child: Text('Filtered')),
                  DropdownMenuItem(value: 'ids', child: Text('IDs')),
                ],
                onChanged: (v) => setState(() => scope = v ?? 'all')),
            const SizedBox(width: 12),
            FilledButton.icon(
                onPressed: _export,
                icon: const Icon(Icons.download),
                label: const Text('Export')),
          ]),
          const SizedBox(height: 12),
          if (scope == 'ids')
            SizedBox(
                width: 520,
                child: TextField(
                    controller: idsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'IDs (comma-separated)',
                        border: OutlineInputBorder()))),
          if (scope == 'filtered')
            SizedBox(
                width: 520,
                child: TextField(
                    controller: filterCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Filter (query or status)',
                        border: OutlineInputBorder()))),
        ]),
      ),
    ]);
  }

  void _export() {
    final ids = idsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final filter = filterCtrl.text.trim();
    String content;
    if (format == 'json') {
      content = '{"module":"$module","scope":"$scope","count":3}';
    } else {
      switch (module) {
        case 'users':
          content = 'id,name,email,role\nU1001,John,j@example.com,admin';
          break;
        case 'products':
          content = 'id,title,price,status\nP1001,Cable,300,Active';
          break;
        case 'leads':
          content = 'id,title,industry,qty\nL1001,Bulk Cable,EPC,500';
          break;
        case 'orders':
          content =
              'id,buyer,seller,total,status\n#501,Acme,Finolex,12000,Processing';
          break;
        case 'messages':
          content =
              'id,buyer,seller,messages,last\n#1001,Acme,Finolex,7,2025-09-12';
          break;
        default:
          content = 'id\n1';
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Export ready (${content.length} chars) scope=$scope ids=${ids.length} filter="${filter.isEmpty ? '-' : filter}"')));
  }
}

Widget _statCard(String label, String value) {
  return SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}

class _UsersPage extends ConsumerStatefulWidget {
  const _UsersPage();
  @override
  ConsumerState<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<_UsersPage> {
  String q = '';
  String role = 'any';
  String status = 'any';
  String sort = 'created_desc';
  final Set<String> selected = {};
  String usersCsv = '';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(adminStoreProvider);
    final users = store.allUsers.where((u) {
      final okQ = q.isEmpty ||
          u.name.toLowerCase().contains(q.toLowerCase()) ||
          u.email.toLowerCase().contains(q.toLowerCase()) ||
          u.id.toLowerCase().contains(q.toLowerCase());
      final okR = role == 'any' || u.role == role;
      final okS = status == 'any' || u.status == status;
      return okQ && okR && okS;
    }).toList()
      ..sort((a, b) {
        switch (sort) {
          case 'created_asc':
            return a.createdAt.compareTo(b.createdAt);
          case 'name_asc':
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case 'name_desc':
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          case 'created_desc':
          default:
            return b.createdAt.compareTo(a.createdAt);
        }
      });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Users',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search id, name, email',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: role,
            items: const [
              DropdownMenuItem(value: 'any', child: Text('Any Role')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'seller', child: Text('Seller')),
              DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
            ],
            onChanged: (v) => setState(() => role = v ?? 'any'),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'any', child: Text('Any Status')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'any'),
          ),
          DropdownButton<String>(
            value: sort,
            items: const [
              DropdownMenuItem(value: 'created_desc', child: Text('Newest')),
              DropdownMenuItem(value: 'created_asc', child: Text('Oldest')),
              DropdownMenuItem(value: 'name_asc', child: Text('Name A-Z')),
              DropdownMenuItem(value: 'name_desc', child: Text('Name Z-A')),
            ],
            onChanged: (v) => setState(() => sort = v ?? 'created_desc'),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border(
            bottom: BorderSide(color: AppColors.outlineSoft, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Text('${selected.length} selected'),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => store.bulkUpdateUsersStatus(selected, 'active'),
              child: const Text('Mark Active'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => store.bulkUpdateUsersStatus(selected, 'suspended'),
              child: const Text('Suspend'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      for (final id in selected) {
                        await store.promoteToSeller(id, plan: 'pro');
                      }
                    },
              child: const Text('Promote to Seller'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      for (final id in selected) {
                        await store.demoteToBuyer(id);
                      }
                    },
              child: const Text('Demote to Buyer'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () {
                store.exportUsersCsv((csv) {
                  _saveCsv(context, 'users.csv', csv);
                });
              },
              child: const Text('Export CSV'),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
                onPressed: () => _openCreate(context),
                icon: const Icon(Icons.add),
                label: const Text('Add User')),
            const SizedBox(width: 6),
            FilledButton.icon(
                onPressed: () => _openCreateSeller(context),
                icon: const Icon(Icons.store_mall_directory_outlined),
                label: const Text('Create Seller')),
            const SizedBox(width: 6),
            OutlinedButton.icon(
                onPressed: () => _importUsersCsv(context),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Import CSV')),
          ]),
        ),
      ),
      const Divider(height: 16),
      Expanded(
        child: BiDirectionalScroller(
          child: DataTable(columns: const [
            DataColumn(label: Text('')),
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ], rows: [
            for (final u in users)
              DataRow(cells: [
                DataCell(Checkbox(
                    value: selected.contains(u.id),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selected.add(u.id);
                        } else {
                          selected.remove(u.id);
                        }
                      });
                    })),
                DataCell(Text(u.id)),
                DataCell(Text(u.name)),
                DataCell(Text(u.email)),
                DataCell(Text(u.role.name)),
                DataCell(Text(u.status.name)),
                DataCell(Text(u.createdAt.toIso8601String().substring(0, 10))),
                DataCell(Row(children: [
                  TextButton(
                      onPressed: () => _openEdit(context, u),
                      child: const Text('Quick Edit')),
                  TextButton(
                      onPressed: () => _openProfileEditor(context, u),
                      child: const Text('Open Profile Editor')),
                  TextButton(
                      onPressed: () async {
                        await store.promoteToSeller(u.id, plan: 'pro');
                      },
                      child: const Text('Promote')),
                  TextButton(
                      onPressed: () async {
                        await store.demoteToBuyer(u.id);
                      },
                      child: const Text('Demote')),
                  TextButton(
                      onPressed: () => _impersonate(context, u),
                      child: const Text('Impersonate')),
                  TextButton(
                      onPressed: () => _confirmDelete(context, u),
                      child: const Text('Delete')),
                  TextButton(
                      onPressed: () => _resetPw(context, u),
                      child: const Text('Reset PW')),
                ])),
              ])
          ]),
        ),
      ),
    ]);
  }

  void _impersonate(BuildContext context, AdminUser u) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            SellHubShell(adminOverride: true, overrideSellerName: u.name)));
  }

  void _saveCsv(BuildContext context, String filename, String csv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'CSV ready: $filename (${csv.length} chars). File saved to downloads.')),
    );
  }

  void _openCreate(BuildContext context) {
    final id = TextEditingController(
        text: 'U${DateTime.now().millisecondsSinceEpoch % 100000}');
    final name = TextEditingController();
    final email = TextEditingController();
    String role = 'buyer';
    String status = 'pending';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Add User'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: id,
                        decoration: const InputDecoration(
                            labelText: 'ID', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: email,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<String>(
                              value: role,
                              items: const [
                                DropdownMenuItem(
                                    value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(
                                    value: 'seller', child: Text('Seller')),
                                DropdownMenuItem(
                                    value: 'buyer', child: Text('Buyer')),
                              ],
                              onChanged: (v) {
                                role = v ?? 'buyer';
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Role'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DropdownButtonFormField<String>(
                              value: status,
                              items: const [
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(
                                    value: 'suspended',
                                    child: Text('Suspended')),
                              ],
                              onChanged: (v) {
                                status = v ?? 'pending';
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Status'))),
                    ]),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      final store = ProviderScope.containerOf(context)
                          .read(adminStoreProvider);
                      store.addUser(AdminUser(
                        id: id.text.trim(),
                        name: name.text.trim(),
                        email: email.text.trim(),
                        phone: '+91 00000 00000',
                        role: _parseUserRole(role),
                        status: _parseUserStatus(status),
                        subscription: SubscriptionPlan.free,
                        joinDate: DateTime.now(),
                        lastActive: DateTime.now(),
                        location: 'Unknown',
                        industry: 'Unknown',
                        createdAt: DateTime.now(),
                        plan: 'free',
                        isSeller: false,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('Create')),
              ],
            ));
  }

  void _openCreateSeller(BuildContext context) {
    final id = TextEditingController(
        text: 'S${DateTime.now().millisecondsSinceEpoch % 100000}');
    final name = TextEditingController();
    final email = TextEditingController();
    String plan = 'pro';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Create Seller'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: id,
                        decoration: const InputDecoration(
                            labelText: 'ID', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: email,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                        value: plan,
                        items: const [
                          DropdownMenuItem(value: 'free', child: Text('Free')),
                          DropdownMenuItem(value: 'plus', child: Text('Plus')),
                          DropdownMenuItem(value: 'pro', child: Text('Pro')),
                        ],
                        onChanged: (v) {
                          plan = v ?? 'pro';
                        },
                        decoration: const InputDecoration(labelText: 'Plan')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      await ProviderScope.containerOf(context)
                          .read(adminStoreProvider)
                          .createSeller(
                              id: id.text.trim(),
                              name: name.text.trim(),
                              email: email.text.trim(),
                              plan: plan);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seller created')));
                    },
                    child: const Text('Create')),
              ],
            ));
  }

  void _openEdit(BuildContext context, AdminUser u) {
    final name = TextEditingController(text: u.name);
    final email = TextEditingController(text: u.email);
    String role = u.role.name;
    String status = u.status.name;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Edit ${u.id}'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: email,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<String>(
                              value: role,
                              items: const [
                                DropdownMenuItem(
                                    value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(
                                    value: 'seller', child: Text('Seller')),
                                DropdownMenuItem(
                                    value: 'buyer', child: Text('Buyer')),
                              ],
                              onChanged: (v) {
                                role = v ?? u.role.name;
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Role'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DropdownButtonFormField<String>(
                              value: status,
                              items: const [
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(
                                    value: 'suspended',
                                    child: Text('Suspended')),
                              ],
                              onChanged: (v) {
                                status = v ?? u.status.name;
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Status'))),
                    ]),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      final store = ProviderScope.containerOf(context)
                          .read(adminStoreProvider);
                      store.updateUser(u.copyWith(
                          name: name.text.trim(),
                          email: email.text.trim(),
                          role: _parseUserRole(role),
                          status: _parseUserStatus(status)));
                      Navigator.pop(context);
                    },
                    child: const Text('Save')),
              ],
            ));
  }

  void _confirmDelete(BuildContext context, AdminUser u) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Delete ${u.id}?'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      ProviderScope.containerOf(context)
                          .read(adminStoreProvider)
                          .deleteUser(u.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  void _resetPw(BuildContext context, AdminUser u) {
    ProviderScope.containerOf(context)
        .read(adminStoreProvider)
        .resetPassword(u.id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset for ${u.id} (demo)')));
  }

  void _openProfileEditor(BuildContext context, AdminUser u) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _AdminUserProfileEditor(userId: u.id)));
  }

  void _importUsersCsv(BuildContext context) {
    usersCsv =
        'id,name,email,role,status\nU9001,Aarti,aarti@example.com,seller,active\nU9002,Rahul,rahul@example.com,buyer,pending';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Import Users CSV'),
              content: SizedBox(
                  width: 560,
                  child: TextField(
                      controller: TextEditingController(text: usersCsv),
                      maxLines: 8,
                      onChanged: (v) {
                        usersCsv = v;
                      },
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      _parseAndAddUsers(usersCsv);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Users imported (demo)')));
                    },
                    child: const Text('Import')),
              ],
            ));
  }

  void _parseAndAddUsers(String text) {
    final store = ProviderScope.containerOf(context).read(adminStoreProvider);
    final lines = text.trim().split('\n');
    if (lines.length <= 1) return;
    final data = lines
        .skip(1)
        .map((l) => l.split(','))
        .where((cols) => cols.length >= 5);
    for (final cols in data) {
      store.addUser(AdminUser(
        id: cols[0].trim(),
        name: cols[1].trim(),
        email: cols[2].trim(),
        phone: '+91 00000 00000',
        role: cols[3].trim() == 'seller' ? UserRole.seller : UserRole.buyer,
        status:
            cols[4].trim() == 'active' ? UserStatus.active : UserStatus.pending,
        subscription: SubscriptionPlan.free,
        joinDate: DateTime.now(),
        lastActive: DateTime.now(),
        location: 'Unknown',
        industry: 'Unknown',
        createdAt: DateTime.now(),
        plan: 'free',
        isSeller: cols[3].trim() == 'seller',
      ));
    }
  }

  UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
        return UserRole.seller;
      case 'buyer':
        return UserRole.buyer;
      default:
        return UserRole.buyer;
    }
  }

  UserStatus _parseUserStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.pending;
    }
  }
}

class _AdminUserProfileEditor extends StatefulWidget {
  final String userId;
  const _AdminUserProfileEditor({required this.userId});
  @override
  State<_AdminUserProfileEditor> createState() =>
      _AdminUserProfileEditorState();
}

class _AdminUserProfileEditorState extends State<_AdminUserProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late AdminUser user;
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController legalName;
  late TextEditingController gstin;
  late TextEditingController phone;
  late TextEditingController address;
  late TextEditingController bannerUrl;
  List<String> materials = const [];
  List<MapEntry<String, String>> custom = const [];
  String role = 'buyer';
  String status = 'active';
  String plan = 'free';
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    final store = ProviderScope.containerOf(context).read(adminStoreProvider);
    user = store.allUsers.firstWhere((u) => u.id == widget.userId);
    name = TextEditingController(text: user.name);
    email = TextEditingController(text: user.email);
    role = user.role.name;
    status = user.status.name;
    plan = user.plan;
    isSeller = user.isSeller || user.role == UserRole.seller;
    final sp = user.sellerProfile ??
        sell_models.SellerProfile(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
    legalName = TextEditingController(text: sp.companyName);
    gstin = TextEditingController(text: sp.gstNumber);
    phone = TextEditingController(text: sp.phone);
    address = TextEditingController(text: sp.address);
    bannerUrl = TextEditingController(text: sp.logoUrl);
    materials = List.of(sp.materials);
    custom = <MapEntry<String, String>>[];
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    legalName.dispose();
    gstin.dispose();
    phone.dispose();
    address.dispose();
    bannerUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${user.id}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Account',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: TextFormField(
                                    controller: name,
                                    decoration: const InputDecoration(
                                        labelText: 'Name'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: email,
                                    decoration: const InputDecoration(
                                        labelText: 'Email'))),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: DropdownButtonFormField<String>(
                                    value: role,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'admin', child: Text('Admin')),
                                      DropdownMenuItem(
                                          value: 'seller',
                                          child: Text('Seller')),
                                      DropdownMenuItem(
                                          value: 'buyer', child: Text('Buyer'))
                                    ],
                                    onChanged: (v) {
                                      setState(() => role = v ?? role);
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Role'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: DropdownButtonFormField<String>(
                                    value: status,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'active',
                                          child: Text('Active')),
                                      DropdownMenuItem(
                                          value: 'pending',
                                          child: Text('Pending')),
                                      DropdownMenuItem(
                                          value: 'suspended',
                                          child: Text('Suspended'))
                                    ],
                                    onChanged: (v) {
                                      setState(() => status = v ?? status);
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Status'))),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: DropdownButtonFormField<String>(
                                    value: plan,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'free', child: Text('Free')),
                                      DropdownMenuItem(
                                          value: 'plus', child: Text('Plus')),
                                      DropdownMenuItem(
                                          value: 'pro', child: Text('Pro'))
                                    ],
                                    onChanged: (v) {
                                      setState(() => plan = v ?? plan);
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Plan'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: SwitchListTile(
                                    value: isSeller,
                                    onChanged: (v) {
                                      setState(() => isSeller = v);
                                    },
                                    title: const Text('Seller enabled'))),
                          ]),
                        ]))),
            const SizedBox(height: 12),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seller Profile',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: TextFormField(
                                    controller: legalName,
                                    decoration: const InputDecoration(
                                        labelText: 'Legal Name'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: gstin,
                                    decoration: const InputDecoration(
                                        labelText: 'GSTIN'))),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: TextFormField(
                                    controller: phone,
                                    decoration: const InputDecoration(
                                        labelText: 'Phone'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: address,
                                    decoration: const InputDecoration(
                                        labelText: 'Address'))),
                          ]),
                          const SizedBox(height: 8),
                          // Seller Banner Image
                          ImageUploadWidget(
                            currentImagePath:
                                bannerUrl.text.isEmpty ? null : bannerUrl.text,
                            onImageSelected: (result) {
                              setState(() {
                                bannerUrl.text = result.path;
                              });
                            },
                            onImageRemoved: (_) {
                              setState(() {
                                bannerUrl.clear();
                              });
                            },
                            width: double.infinity,
                            height: 180,
                            label: 'Seller Banner Image',
                            hint:
                                'Upload a banner image (JPG/PNG/WebP, max 5MB) or leave empty',
                            showPreview: true,
                            allowMultipleSources: true,
                          ),
                          const SizedBox(height: 12),
                          MaterialsSelector(
                              value: materials,
                              onChanged: (v) => setState(() => materials = v),
                              label: 'Materials'),
                          const SizedBox(height: 12),
                          SimpleCustomFields(
                              entries: custom,
                              onChanged: (v) => setState(() => custom = v),
                              title: 'Custom Fields'),
                        ]))),
            const SizedBox(height: 16),
            Row(children: [
              FilledButton(onPressed: _save, child: const Text('Save Changes')),
              const SizedBox(width: 8),
              OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
            ]),
          ],
        ),
      ),
    );
  }

  void _save() {
    final store = ProviderScope.containerOf(context).read(adminStoreProvider);
    final profile = sell_models.SellerProfile(
      companyName: legalName.text.trim(),
      gstNumber: gstin.text.trim(),
      phone: phone.text.trim(),
      address: address.text.trim(),
      logoUrl: bannerUrl.text.trim(),
      materials: materials,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final updated = user.copyWith(
      name: name.text.trim(),
      email: email.text.trim(),
      role: _parseUserRole(role),
      status: _parseUserStatus(status),
      plan: plan,
      isSeller: isSeller,
      sellerProfile: isSeller ? profile : null,
    );
    store.updateUser(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
        return UserRole.seller;
      case 'buyer':
        return UserRole.buyer;
      default:
        return UserRole.buyer;
    }
  }

  UserStatus _parseUserStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.pending;
    }
  }
}

class _SellersPage extends StatefulWidget {
  const _SellersPage();
  @override
  State<_SellersPage> createState() => _SellersPageState();
}

class _SellersPageState extends State<_SellersPage> {
  String q = '';
  String status = 'All';
  String material = 'Any';
  final Set<String> selected = <String>{};
  final List<Map<String, String>> sellers = [
    {
      'id': 'S1001',
      'name': 'Finolex',
      'status': 'Approved',
      'materials': 'Copper,PVC',
      'city': 'Pune'
    },
    {
      'id': 'S1002',
      'name': 'Polycab',
      'status': 'Pending',
      'materials': 'Aluminium,XLPE',
      'city': 'Mumbai'
    },
    {
      'id': 'S1003',
      'name': 'Havells',
      'status': 'Approved',
      'materials': 'Copper,PVC',
      'city': 'Delhi'
    },
    {
      'id': 'S1004',
      'name': 'Anchor',
      'status': 'Suspended',
      'materials': 'Plastic,Metal',
      'city': 'Bengaluru'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = sellers.where((s) {
      final okQ =
          q.isEmpty || s['name']!.toLowerCase().contains(q.toLowerCase());
      final okS = status == 'All' || s['status'] == status;
      final okM = material == 'Any' ||
          (s['materials']!
              .toLowerCase()
              .split(',')
              .contains(material.toLowerCase()));
      return okQ && okS && okM;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Sellers',
        actions: [
          SizedBox(
            width: 280,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search sellers',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Status')),
              DropdownMenuItem(value: 'Approved', child: Text('Approved')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'All'),
          ),
          DropdownButton<String>(
            value: material,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Material')),
              DropdownMenuItem(value: 'Copper', child: Text('Copper')),
              DropdownMenuItem(value: 'PVC', child: Text('PVC')),
              DropdownMenuItem(value: 'Aluminium', child: Text('Aluminium')),
              DropdownMenuItem(value: 'XLPE', child: Text('XLPE')),
            ],
            onChanged: (v) => setState(() => material = v ?? 'Any'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
        child: Column(
          children: [
            // Bulk actions bar
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primarySurface,
                child: Row(
                  children: [
                    Text('${selected.length} selected'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _bulkApprove(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Selected'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkSuspend(),
                      icon: const Icon(Icons.pause_circle),
                      label: const Text('Suspend Selected'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkMove(),
                      icon: const Icon(Icons.move_to_inbox),
                      label: const Text('Move Selected'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => selected.clear()),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Selection'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BiDirectionalScroller(
                child: DataTable(columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('Seller')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Materials')),
                  DataColumn(label: Text('City')),
                  DataColumn(label: Text('Actions')),
                ], rows: [
                  for (final s in filtered)
                    DataRow(cells: [
                      DataCell(Checkbox(
                        value: selected.contains(s['id']),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              selected.add(s['id']!);
                            } else {
                              selected.remove(s['id']!);
                            }
                          });
                        },
                      )),
                      DataCell(Text(s['name']!)),
                      DataCell(_statusChip(s['status']!)),
                      DataCell(Text(s['materials']!)),
                      DataCell(Text(s['city']!)),
                      DataCell(Row(children: [
                        TextButton(
                            onPressed: () => _openEdit(context, s['name']!),
                            child: const Text('Edit')),
                        TextButton(
                            onPressed: () => _moveSeller(context, s['name']!),
                            child: const Text('Move')),
                        TextButton(
                            onPressed: () =>
                                _approveSeller(context, s['name']!),
                            child: const Text('Approve')),
                      ])),
                    ])
                ]),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _statusChip(String st) {
    Color c = AppColors.textSecondary;
    if (st == 'Approved') c = AppColors.success;
    if (st == 'Pending') c = AppColors.warning;
    if (st == 'Suspended') c = AppColors.error;
    return Chip(label: Text(st), labelStyle: TextStyle(color: c));
  }

  void _openEdit(BuildContext context, String seller) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Edit $seller'),
              content: const SizedBox(
                  width: 420,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        decoration: InputDecoration(labelText: 'Owner Name')),
                    SizedBox(height: 8),
                    TextField(
                        decoration: InputDecoration(labelText: 'Company Name')),
                    SizedBox(height: 8),
                    TextField(decoration: InputDecoration(labelText: 'City')),
                    SizedBox(height: 8),
                    TextField(
                        decoration: InputDecoration(
                            labelText: 'Materials (comma separated)')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Save'))
              ],
            ));
  }

  void _moveSeller(BuildContext context, String seller) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Move $seller'),
              content: DropdownButtonFormField<String>(
                  items: const [
                    DropdownMenuItem(
                        value: 'Category A', child: Text('Category A')),
                    DropdownMenuItem(
                        value: 'Category B', child: Text('Category B')),
                    DropdownMenuItem(
                        value: 'Category C', child: Text('Category C')),
                  ],
                  onChanged: (_) {},
                  decoration: const InputDecoration(labelText: 'Target Group')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Move'))
              ],
            ));
  }

  void _approveSeller(BuildContext context, String seller) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Approve $seller?'),
              content:
                  const Text('This will approve the seller and notify them.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processSellerApproval(seller, true);
                    },
                    child: const Text('Approve'))
              ],
            ));
  }

  void _processSellerApproval(String seller, bool approved) {
    // Update seller status in the data
    setState(() {
      final sellerIndex = sellers.indexWhere((s) => s['name'] == seller);
      if (sellerIndex != -1) {
        sellers[sellerIndex]['status'] = approved ? 'Approved' : 'Rejected';
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${approved ? 'Approved' : 'Rejected'} $seller successfully'),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );

    // In a real app, you would:
    // 1. Send API request to backend
    // 2. Send notification to seller
    // 3. Update database
    // 4. Log the action
  }

  void _bulkApprove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Approve ${selected.length} sellers?'),
        content: const Text(
            'This will approve all selected sellers and notify them.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _processBulkSellerApproval(true);
            },
            child: const Text('Approve All'),
          ),
        ],
      ),
    );
  }

  void _processBulkSellerApproval(bool approved) {
    final selectedSellers =
        sellers.where((s) => selected.contains(s['id'])).toList();

    setState(() {
      for (final seller in selectedSellers) {
        seller['status'] = approved ? 'Approved' : 'Rejected';
      }
      selected.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${approved ? 'Approved' : 'Rejected'} ${selectedSellers.length} sellers successfully'),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _bulkSuspend() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Suspend ${selected.length} sellers?'),
        content: const Text('This will suspend all selected sellers.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _processBulkSellerSuspend();
            },
            child: const Text('Suspend All'),
          ),
        ],
      ),
    );
  }

  void _processBulkSellerSuspend() {
    final selectedSellers =
        sellers.where((s) => selected.contains(s['id'])).toList();

    setState(() {
      for (final seller in selectedSellers) {
        seller['status'] = 'Suspended';
      }
      selected.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Suspended ${selectedSellers.length} sellers successfully'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _bulkMove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Move ${selected.length} sellers?'),
        content: DropdownButtonFormField<String>(
          items: const [
            DropdownMenuItem(value: 'Category A', child: Text('Category A')),
            DropdownMenuItem(value: 'Category B', child: Text('Category B')),
            DropdownMenuItem(value: 'Category C', child: Text('Category C')),
          ],
          onChanged: (_) {},
          decoration: const InputDecoration(labelText: 'Target Category'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Moved ${selected.length} sellers')),
              );
            },
            child: const Text('Move All'),
          ),
        ],
      ),
    );
  }
}

class _KycPage extends StatefulWidget {
  const _KycPage();
  @override
  State<_KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<_KycPage> {
  String status = 'Pending';
  String q = '';
  String docType = 'Any';
  final Set<String> selected = <String>{};
  final List<Map<String, dynamic>> kycs = List.generate(
      12,
      (i) => {
            'id': '#${1020 + i}',
            'seller': i % 2 == 0 ? 'Finolex' : 'Polycab',
            'contactEmail': 'kyc$i@example.com',
            'contactPhone': '+91-98${i}00${i}00',
            'submitted': '2025-09-0${(i % 7) + 1}',
            'status': (i % 4 == 0)
                ? 'Rejected'
                : (i % 3 == 0)
                    ? 'Approved'
                    : 'Pending',
            'pan': 'ABCDE${1000 + i}F',
            'aadhaar': 'XXXX-XXXX-${1234 + i}',
            'gstin': '27ABCDE${200 + i}1Z5',
            'businessType': i % 2 == 0 ? 'Manufacturer' : 'Distributor',
            'address': 'Plot ${i + 10}, Industrial Area, City',
            'docs': [
              {
                'type': 'PAN',
                'url': 'https://picsum.photos/seed/pan$i/600/400'
              },
              {
                'type': 'Aadhaar',
                'url': 'https://picsum.photos/seed/aadhaar$i/600/400'
              },
              {
                'type': 'GST',
                'url': 'https://picsum.photos/seed/gst$i/600/400'
              },
            ],
            'notes': i % 5 == 0 ? 'Mismatch in address' : '',
          });

  @override
  Widget build(BuildContext context) {
    final filtered = kycs.where((k) {
      final okS = status == 'All' || k['status'] == status;
      final okQ = q.isEmpty ||
          k['seller'].toString().toLowerCase().contains(q.toLowerCase()) ||
          k['id'].toString().contains(q);
      final okD = docType == 'Any' ||
          (k['docs'] as List).any((d) => d['type'] == docType);
      return okS && okQ && okD;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'KYC Reviews',
        actions: [
          SizedBox(
            width: 240,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search # or seller',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Approved', child: Text('Approved')),
              DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'All', child: Text('All')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'Pending'),
          ),
          DropdownButton<String>(
            value: docType,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Doc')),
              DropdownMenuItem(value: 'PAN', child: Text('PAN')),
              DropdownMenuItem(value: 'Aadhaar', child: Text('Aadhaar')),
              DropdownMenuItem(value: 'GST', child: Text('GST')),
            ],
            onChanged: (v) => setState(() => docType = v ?? 'Any'),
          ),
          OutlinedButton.icon(
            onPressed: () => _exportCsv(filtered),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
        child: Column(
          children: [
            // Bulk actions bar
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primarySurface,
                child: Row(
                  children: [
                    Text('${selected.length} selected'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _bulkApproveKyc(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Selected'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkRejectKyc(),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject Selected'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkRequestResubmit(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Request Re-submit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => selected.clear()),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Selection'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BiDirectionalScroller(
                child: DataTable(columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Seller')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Submitted')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ], rows: [
                  for (final k in filtered)
                    DataRow(cells: [
                      DataCell(Checkbox(
                        value: selected.contains(k['id']),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              selected.add(k['id']);
                            } else {
                              selected.remove(k['id']);
                            }
                          });
                        },
                      )),
                      DataCell(Text(k['id'].toString())),
                      DataCell(Text(k['seller'].toString())),
                      DataCell(Text(k['contactEmail'].toString())),
                      DataCell(Text(k['contactPhone'].toString())),
                      DataCell(Text(k['submitted'].toString())),
                      DataCell(Text(k['status'].toString())),
                      DataCell(Row(children: [
                        TextButton(
                            onPressed: () => _previewDocs(k),
                            child: const Text('Open Review')),
                        TextButton(
                            onPressed: () => _decision(k, true),
                            child: const Text('Approve')),
                        TextButton(
                            onPressed: () => _decision(k, false),
                            child: const Text('Reject')),
                        TextButton(
                            onPressed: () => _requestResubmit(k),
                            child: const Text('Request Re-submit')),
                      ])),
                    ])
                ]),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _previewDocs(Map<String, dynamic> k) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('KYC ${k['id']} — ${k['seller']}'),
              content: SizedBox(
                  width: 680,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            'Contact: ${k['contactEmail']} • ${k['contactPhone']}'),
                        Text('Business Type: ${k['businessType']}'),
                        Text('GSTIN: ${k['gstin']}'),
                        Text('PAN: ${k['pan']}'),
                        Text('Aadhaar: ${k['aadhaar']}'),
                        Text('Address: ${k['address']}'),
                        if ((k['notes'] as String).isNotEmpty)
                          Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Notes: ${k['notes']}',
                                  style: const TextStyle(
                                      color: AppColors.warning))),
                        const SizedBox(height: 12),
                        const Text('Documents',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final d in (k['docs'] as List))
                            SizedBox(
                                width: 200,
                                child: Column(children: [
                                  Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                          color: AppColors.surfaceAlt,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      alignment: Alignment.center,
                                      child: Text(d['type'])),
                                  const SizedBox(height: 6),
                                  Text(d['url'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                ]))
                        ]),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
                TextButton(
                    onPressed: () => _decision(k, false),
                    child: const Text('Reject')),
                FilledButton(
                    onPressed: () => _decision(k, true),
                    child: const Text('Approve')),
              ],
            ));
  }

  void _decision(Map<String, dynamic> k, bool approve) {
    final notesController = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('${approve ? 'Approve' : 'Reject'} ${k['id']}'),
              content: TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Notes (optional)',
                      border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processKycDecision(
                          k, approve, notesController.text.trim());
                    },
                    child: const Text('Confirm'))
              ],
            ));
  }

  void _processKycDecision(
      Map<String, dynamic> kyc, bool approve, String notes) {
    setState(() {
      kyc['status'] = approve ? 'Approved' : 'Rejected';
      if (notes.isNotEmpty) {
        kyc['adminNotes'] = notes;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${approve ? 'Approved' : 'Rejected'} KYC ${kyc['id']} successfully'),
        backgroundColor: approve ? AppColors.success : AppColors.error,
      ),
    );

    // In a real app, you would:
    // 1. Send API request to backend
    // 2. Send notification to seller
    // 3. Update database
    // 4. Log the action
  }

  void _requestResubmit(Map<String, dynamic> k) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Request re-submit ${k['id']}'),
              content: const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText: 'Missing/mismatched details to fix',
                      border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Send'))
              ],
            ));
  }

  void _exportCsv(List<Map<String, dynamic>> list) {
    const header = 'id,seller,email,phone,submitted,status';
    final rows = list
        .map((k) => [
              k['id'],
              k['seller'],
              k['contactEmail'],
              k['contactPhone'],
              k['submitted'],
              k['status']
            ].join(','))
        .join('\n');
    final csv = '$header\n$rows';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV ready (${csv.length} chars). Implement save.')));
  }

  void _bulkApproveKyc() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Approve ${selected.length} KYC applications?'),
        content: const Text('This will approve all selected KYC applications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Approved ${selected.length} KYC applications')),
              );
            },
            child: const Text('Approve All'),
          ),
        ],
      ),
    );
  }

  void _bulkRejectKyc() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reject ${selected.length} KYC applications?'),
        content: const Text('This will reject all selected KYC applications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Rejected ${selected.length} KYC applications')),
              );
            },
            child: const Text('Reject All'),
          ),
        ],
      ),
    );
  }

  void _bulkRequestResubmit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text('Request re-submit for ${selected.length} KYC applications?'),
        content: const Text(
            'This will request re-submission for all selected KYC applications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Requested re-submit for ${selected.length} KYC applications')),
              );
            },
            child: const Text('Request All'),
          ),
        ],
      ),
    );
  }
}

class _ProductsPage extends StatefulWidget {
  const _ProductsPage();
  @override
  State<_ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<_ProductsPage> {
  String q = '';
  String category = 'All';
  String material = 'Any';
  String status = 'Any';
  String stock = 'Any';
  final Set<int> selected = {};

  final List<Map<String, dynamic>> products = List.generate(
      20,
      (i) => {
            'title': 'Product ${i + 1}',
            'seller': i % 2 == 0 ? 'Finolex' : 'Polycab',
            'category': i % 3 == 0 ? 'Cables & Wires' : 'Switchgear',
            'material': i % 2 == 0 ? 'Copper' : 'Aluminium',
            'price': 300 + i * 15,
            'status': i % 5 == 0 ? 'Draft' : 'Active',
            'stock': i % 4 == 0 ? 0 : 100 + i,
          });

  List<Map<String, dynamic>> get filtered => products.where((p) {
        final okQ = q.isEmpty ||
            p['title'].toString().toLowerCase().contains(q.toLowerCase());
        final okC = category == 'All' || p['category'] == category;
        final okM = material == 'Any' || p['material'] == material;
        final okS = status == 'Any' || p['status'] == status;
        final okStock = stock == 'Any' ||
            (stock == 'OOS' ? p['stock'] == 0 : p['stock'] > 0);
        return okQ && okC && okM && okS && okStock;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Products',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: category,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Categories')),
              DropdownMenuItem(
                  value: 'Cables & Wires', child: Text('Cables & Wires')),
              DropdownMenuItem(value: 'Switchgear', child: Text('Switchgear')),
            ],
            onChanged: (v) => setState(() => category = v ?? 'All'),
          ),
          DropdownButton<String>(
            value: material,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Material')),
              DropdownMenuItem(value: 'Copper', child: Text('Copper')),
              DropdownMenuItem(value: 'Aluminium', child: Text('Aluminium')),
            ],
            onChanged: (v) => setState(() => material = v ?? 'Any'),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Status')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'Any'),
          ),
          DropdownButton<String>(
            value: stock,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Stock')),
              DropdownMenuItem(value: 'OOS', child: Text('Out of Stock')),
              DropdownMenuItem(value: 'In', child: Text('In Stock')),
            ],
            onChanged: (v) => setState(() => stock = v ?? 'Any'),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border(
            bottom: BorderSide(color: AppColors.outlineSoft, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Text('${selected.length} selected'),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: selected.isEmpty ? null : () => _bulkStatus('Active'),
              child: const Text('Mark Active'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: selected.isEmpty ? null : () => _bulkStatus('Draft'),
              child: const Text('Mark Draft'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: selected.isEmpty ? null : () => _bulkDelete(),
              child: const Text('Delete'),
            ),
          ]),
        ),
      ),
      const Divider(height: 16),
      Expanded(
        child: BiDirectionalScroller(
          child: DataTable(columns: const [
            DataColumn(label: Text('')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Seller')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Material')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Actions')),
          ], rows: [
            for (int i = 0; i < filtered.length; i++)
              DataRow(cells: [
                DataCell(Checkbox(
                    value: selected.contains(i),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selected.add(i);
                        } else {
                          selected.remove(i);
                        }
                      });
                    })),
                DataCell(Text(filtered[i]['title'].toString())),
                DataCell(Text(filtered[i]['seller'].toString())),
                DataCell(Text(filtered[i]['category'].toString())),
                DataCell(Text(filtered[i]['material'].toString())),
                DataCell(Text('₹${filtered[i]['price']}')),
                DataCell(Text(filtered[i]['status'].toString())),
                DataCell(Text(filtered[i]['stock'] == 0
                    ? 'OOS'
                    : '${filtered[i]['stock']}')),
                DataCell(Row(children: [
                  TextButton(
                      onPressed: () => _openProductEdit(context, filtered[i]),
                      child: const Text('Edit')),
                  TextButton(
                      onPressed: () => _impersonateSeller(
                          context, filtered[i]['seller'].toString()),
                      child: const Text('View as Seller')),
                ])),
              ])
          ]),
        ),
      ),
    ]);
  }

  void _bulkStatus(String st) {
    final selectedProducts = selected.toList();
    setState(() {
      for (final i in selectedProducts) {
        if (i < filtered.length) {
          filtered[i]['status'] = st;
        }
      }
      selected.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${selectedProducts.length} products to $st'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _bulkDelete() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Delete ${selected.length} products?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processBulkDelete();
                    },
                    child: const Text('Delete'))
              ],
            ));
  }

  void _processBulkDelete() {
    final selectedProducts = selected.toList();
    setState(() {
      // Remove products from the main list
      for (final i in selectedProducts) {
        if (i < filtered.length) {
          final product = filtered[i];
          products.removeWhere((p) => p['title'] == product['title']);
        }
      }
      selected.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Deleted ${selectedProducts.length} products successfully'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _openProductEdit(BuildContext context, Map<String, dynamic> p) {
    final product = Product(
      id: 'admin-${p['title']}',
      title: p['title'].toString(),
      brand: p['seller'].toString(),
      subtitle: p['category'].toString(),
      description: 'Admin edit session',
      images: const ['https://picsum.photos/seed/admin-edit/800/600'],
      price: (p['price'] is num)
          ? (p['price'] as num).toDouble()
          : double.tryParse(p['price'].toString()) ?? 0,
      moq: 1,
      gstRate: 18.0,
      materials: [p['material'].toString()],
      customValues: const {},
    );
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _AdminProductEditor(
            product: product, sellerName: p['seller'].toString())));
  }

  void _impersonateSeller(BuildContext context, String seller) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            SellHubShell(adminOverride: true, overrideSellerName: seller)));
  }
}

class _AdminProductEditor extends StatelessWidget {
  final Product product;
  final String sellerName;
  const _AdminProductEditor({required this.product, required this.sellerName});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final sellerStore = ref.read(sellerStoreProvider);
      sellerStore.addProduct(product);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade900,
          title: Text('Admin override — $sellerName'),
        ),
        body: ProductFormPage(product: product),
      );
    });
  }
}

class _ProductUploadsPage extends ConsumerStatefulWidget {
  const _ProductUploadsPage();
  @override
  ConsumerState<_ProductUploadsPage> createState() =>
      _ProductUploadsPageState();
}

class _ProductUploadsPageState extends ConsumerState<_ProductUploadsPage> {
  String _histQuery = '';
  String _histStatus = 'All';
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with rbacProvider.can() and firebase* providers
    final store = ref.watch(enhancedAdminStoreProvider);
    final queue = _applyQueueFilters(store.productUploadQueue);
    final history = _applyFilters(store.productUploadHistory);
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        AdminPageHeader(
          title: 'Product Uploads Moderation',
          actions: [
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search title/seller',
                ),
                onChanged: (v) => setState(() => _histQuery = v),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _histStatus,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
              ],
              onChanged: (v) => setState(() => _histStatus = v ?? 'All'),
            ),
            const SizedBox(width: 8),
            const Text('Filters apply to active tab',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                final buffer = StringBuffer();
                buffer.writeln(
                    'id,seller,category,title,status,submitted_at,reviewed_at,note');
                for (final i in history) {
                  buffer.writeln([
                    i.id,
                    i.sellerName,
                    i.proposed['category'] ?? '',
                    i.proposed['title'] ?? '',
                    i.status.name,
                    i.submittedAt.toIso8601String(),
                    i.reviewedAt?.toIso8601String() ?? '',
                    i.reviewerNote ?? '',
                  ].join(','));
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('History CSV ready (${buffer.length} chars)')));
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export History'),
            ),
          ],
        ),
        const TabBar(tabs: [Tab(text: 'Pending'), Tab(text: 'History')]),
        Expanded(
            child: TabBarView(children: [
          _UploadsList(queue: queue),
          _UploadsHistoryList(history: history),
        ])),
      ]),
    );
  }

  List<ProductUploadItem> _applyFilters(List<ProductUploadItem> items) {
    Iterable<ProductUploadItem> res = items;
    if (_histQuery.trim().isNotEmpty) {
      final q = _histQuery.trim().toLowerCase();
      res = res.where((i) =>
          (i.proposed['title']?.toString().toLowerCase().contains(q) ??
              false) ||
          i.sellerName.toLowerCase().contains(q));
    }
    if (_histStatus != 'All') {
      res = res.where((i) => _histStatus == 'Approved'
          ? i.status == UploadStatus.approved
          : i.status == UploadStatus.rejected);
    }
    return res.toList();
  }

  List<ProductUploadItem> _applyQueueFilters(List<ProductUploadItem> items) {
    if (_histQuery.trim().isEmpty) return items;
    final q = _histQuery.trim().toLowerCase();
    return items
        .where((i) =>
            (i.proposed['title']?.toString().toLowerCase().contains(q) ??
                false) ||
            i.sellerName.toLowerCase().contains(q))
        .toList();
  }
}

class _UploadsList extends ConsumerWidget {
  final List<ProductUploadItem> queue;
  const _UploadsList({required this.queue});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with rbacProvider.can() and firebase* providers
    final store = ref.read(enhancedAdminStoreProvider);
    if (queue.isEmpty) return const Center(child: Text('No pending uploads'));
    return ListView.builder(
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final item = queue[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: item.assets.isNotEmpty
                ? CircleAvatar(backgroundImage: AssetImage(item.assets.first))
                : const CircleAvatar(child: Icon(Icons.image_not_supported)),
            title: Text(item.proposed['title']?.toString() ?? 'Untitled'),
            subtitle: Text('Seller: ${item.sellerName}'),
            trailing: Wrap(spacing: 6, children: [
              TextButton(
                  onPressed: () => _showDiff(context, item),
                  child: const Text('Diff')),
              TextButton(
                  onPressed: () =>
                      store.approveProductUpload(item.id, comments: 'ok'),
                  child: const Text('Approve')),
              TextButton(
                  onPressed: () =>
                      store.rejectProductUpload(item.id, reason: 'no'),
                  child: const Text('Reject')),
            ]),
            onTap: () => _showDiff(context, item),
          ),
        );
      },
    );
  }

  void _showDiff(BuildContext context, ProductUploadItem item) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Diff'),
                content: Text(item.proposed.toString()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))
                ]));
  }
}

class _UploadsHistoryList extends StatelessWidget {
  final List<ProductUploadItem> history;
  const _UploadsHistoryList({required this.history});
  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const Center(child: Text('No history yet'));
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
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
            subtitle: Text('Seller: ${item.sellerName}'),
          ),
        );
      },
    );
  }
}

class _AdsPage extends ConsumerStatefulWidget {
  const _AdsPage();
  @override
  ConsumerState<_AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends ConsumerState<_AdsPage> {
  String q = '';
  String type = 'Any';
  String status = 'Active';
  String dateRange = 'Any';
  late TextEditingController _phoneController;
  final List<Map<String, dynamic>> ads = List.generate(
      10,
      (i) => {
            'id': 'ad${i + 1}',
            'type': i % 2 == 0 ? 'search' : 'category',
            'term': i % 2 == 0 ? 'copper' : 'Cables & Wires',
            'slot': (i % 5) + 1,
            'seller': i % 2 == 0 ? 'Finolex' : 'Polycab',
            'priority': (i % 3) + 1,
            'budget': 5000 + i * 500,
            'status': i % 4 == 0 ? 'Paused' : 'Active',
            'schedule': '09:00-18:00',
          });

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(adminStoreProvider);
    _phoneController.text = store.adsPriorityPhone;
    final filtered = ads.where((a) {
      final okQ = q.isEmpty ||
          a['term'].toString().toLowerCase().contains(q.toLowerCase()) ||
          a['seller'].toString().toLowerCase().contains(q.toLowerCase());
      final okT = type == 'Any' || a['type'] == type.toLowerCase();
      final okS = status == 'Any' || a['status'] == status;
      return okQ && okT && okS;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Ads & Slots',
        actions: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Priority Phone',
                prefixIcon: Icon(Icons.call),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              ProviderScope.containerOf(context)
                  .read(adminStoreProvider)
                  .setAdsPriorityPhone(_phoneController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Priority phone updated')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search term/seller',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: type,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Type')),
              DropdownMenuItem(value: 'search', child: Text('Search')),
              DropdownMenuItem(value: 'category', child: Text('Category')),
            ],
            onChanged: (v) => setState(() => type = v ?? 'Any'),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Status')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Paused', child: Text('Paused')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'Active'),
          ),
          DropdownButton<String>(
            value: dateRange,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Date')),
              DropdownMenuItem(value: 'This Week', child: Text('This Week')),
              DropdownMenuItem(value: 'This Month', child: Text('This Month')),
            ],
            onChanged: (v) => setState(() => dateRange = v ?? 'Any'),
          ),
          OutlinedButton.icon(
            onPressed: () => _exportCsv(filtered),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
          FilledButton.icon(
            onPressed: () => _assign(context),
            icon: const Icon(Icons.add),
            label: const Text('Assign to Slot'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
          child: BiDirectionalScroller(
        child: DataTable(columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Term/Category')),
          DataColumn(label: Text('Slot')),
          DataColumn(label: Text('Seller')),
          DataColumn(label: Text('Priority')),
          DataColumn(label: Text('Budget')),
          DataColumn(label: Text('Schedule')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ], rows: [
          for (final a in filtered)
            DataRow(cells: [
              DataCell(Text(a['id'])),
              DataCell(Text(a['type'])),
              DataCell(Text(a['term'])),
              DataCell(Text('#${a['slot']}')),
              DataCell(Text(a['seller'])),
              DataCell(Text('${a['priority']}')),
              DataCell(Text('₹${a['budget']}')),
              DataCell(Text(a['schedule'])),
              DataCell(Text(a['status'])),
              DataCell(Row(children: [
                TextButton(
                    onPressed: () => _edit(context, a),
                    child: const Text('Edit')),
                TextButton(
                    onPressed: () => _pauseResume(a),
                    child: Text(a['status'] == 'Active' ? 'Pause' : 'Resume')),
                TextButton(
                    onPressed: () => _boost(a), child: const Text('Boost')),
              ])),
            ])
        ]),
      )),
    ]);
  }

  void _assign(BuildContext context) {
    String type = 'search';
    final term = TextEditingController();
    final seller = TextEditingController();
    int slot = 1;
    int priority = 1;
    String schedule = '09:00-18:00';
    DateTimeRange? range;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Assign to Slot'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButtonFormField<String>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                              value: 'search', child: Text('Search')),
                          DropdownMenuItem(
                              value: 'category', child: Text('Category')),
                        ],
                        onChanged: (v) {
                          type = v ?? 'search';
                        },
                        decoration: const InputDecoration(labelText: 'Type')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: term,
                        decoration: const InputDecoration(
                            labelText: 'Term / Category',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: seller,
                        decoration: const InputDecoration(
                            labelText: 'Seller', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<int>(
                              value: slot,
                              items: [
                                for (int i = 1; i <= 5; i++)
                                  DropdownMenuItem(
                                      value: i, child: Text('Slot #$i'))
                              ],
                              onChanged: (v) {
                                slot = v ?? 1;
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Slot'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DropdownButtonFormField<int>(
                              value: priority,
                              items: const [
                                DropdownMenuItem(
                                    value: 1, child: Text('Normal')),
                                DropdownMenuItem(value: 2, child: Text('High')),
                                DropdownMenuItem(value: 3, child: Text('Top')),
                              ],
                              onChanged: (v) {
                                priority = v ?? 1;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Priority'))),
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                        controller: TextEditingController(text: schedule),
                        onChanged: (v) {
                          schedule = v;
                        },
                        decoration: const InputDecoration(
                            labelText: 'Schedule (HH:MM-HH:MM)',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                              context: context,
                              firstDate:
                                  now.subtract(const Duration(days: 365)),
                              lastDate: now.add(const Duration(days: 365)),
                              initialDateRange: DateTimeRange(
                                  start: now,
                                  end: now.add(const Duration(days: 7))));
                          if (picked != null) range = picked;
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text('Pick Date Range'),
                      ),
                    ),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Assigned (demo) ${range != null ? 'from ${range!.start.toIso8601String().substring(0, 10)} to ${range!.end.toIso8601String().substring(0, 10)}' : ''}')));
                    },
                    child: const Text('Assign'))
              ],
            ));
  }

  void _edit(BuildContext context, Map<String, dynamic> a) {
    final seller = TextEditingController(text: a['seller']);
    int slot = a['slot'];
    int priority = a['priority'];
    String schedule = a['schedule'];
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Edit ${a['id']}'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: seller,
                        decoration: const InputDecoration(
                            labelText: 'Seller', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<int>(
                              value: slot,
                              items: [
                                for (int i = 1; i <= 5; i++)
                                  DropdownMenuItem(
                                      value: i, child: Text('Slot #$i'))
                              ],
                              onChanged: (v) {
                                slot = v ?? slot;
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Slot'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DropdownButtonFormField<int>(
                              value: priority,
                              items: const [
                                DropdownMenuItem(
                                    value: 1, child: Text('Normal')),
                                DropdownMenuItem(value: 2, child: Text('High')),
                                DropdownMenuItem(value: 3, child: Text('Top')),
                              ],
                              onChanged: (v) {
                                priority = v ?? priority;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Priority'))),
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                        controller: TextEditingController(text: schedule),
                        onChanged: (v) {
                          schedule = v;
                        },
                        decoration: const InputDecoration(
                            labelText: 'Schedule (HH:MM-HH:MM)',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved (demo)')));
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  void _pauseResume(Map<String, dynamic> a) {
    setState(() => a['status'] = a['status'] == 'Active' ? 'Paused' : 'Active');
  }

  void _boost(Map<String, dynamic> a) {
    setState(() => a['priority'] =
        (a['priority'] as int) + 1 > 3 ? 3 : (a['priority'] as int) + 1);
  }

  void _exportCsv(List<Map<String, dynamic>> list) {
    const header = 'id,type,term,slot,seller,priority,budget,schedule,status';
    final rows = list
        .map((r) => [
              r['id'],
              r['type'],
              r['term'],
              r['slot'],
              r['seller'],
              r['priority'],
              r['budget'],
              r['schedule'],
              r['status']
            ].join(','))
        .join('\n');
    final csv = '$header\n$rows';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV ready (${csv.length} chars). Implement save.')));
  }
}

class _LeadsPage extends StatefulWidget {
  const _LeadsPage();
  @override
  State<_LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<_LeadsPage> {
  String q = '';
  String status = 'Any';
  String industry = 'Any';
  String csv = '';
  final List<Map<String, dynamic>> leads = List.generate(
      10,
      (i) => {
            'id': 'L${i + 1}',
            'title': i % 2 == 0 ? 'Bulk Cable Order' : 'Factory Wiring',
            'industry':
                i % 3 == 0 ? 'Construction' : (i % 3 == 1 ? 'EPC' : 'MEP'),
            'materials': i % 2 == 0 ? ['Copper', 'PVC'] : ['Aluminium', 'XLPE'],
            'city': i % 2 == 0 ? 'Mumbai' : 'Pune',
            'state': 'Maharashtra',
            'qty': 1000 + i * 100,
            'status': i % 4 == 0 ? 'Won' : (i % 3 == 0 ? 'Quoted' : 'New'),
            'assignee': i % 2 == 0 ? 'Finolex' : 'Polycab',
            'notes': '',
          });

  @override
  Widget build(BuildContext context) {
    final filtered = leads.where((l) {
      final okQ = q.isEmpty ||
          l['title'].toString().toLowerCase().contains(q.toLowerCase()) ||
          l['id'].toString().toLowerCase().contains(q.toLowerCase()) ||
          l['assignee'].toString().toLowerCase().contains(q.toLowerCase());
      final okS = status == 'Any' || l['status'] == status;
      final okI = industry == 'Any' || l['industry'] == industry;
      return okQ && okS && okI;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Leads',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search title/id/assignee',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: industry,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Industry')),
              DropdownMenuItem(
                  value: 'Construction', child: Text('Construction')),
              DropdownMenuItem(value: 'EPC', child: Text('EPC')),
              DropdownMenuItem(value: 'MEP', child: Text('MEP')),
            ],
            onChanged: (v) => setState(() => industry = v ?? 'Any'),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Status')),
              DropdownMenuItem(value: 'New', child: Text('New')),
              DropdownMenuItem(
                  value: 'In Progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'Quoted', child: Text('Quoted')),
              DropdownMenuItem(value: 'Won', child: Text('Won')),
              DropdownMenuItem(value: 'Lost', child: Text('Lost')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'Any'),
          ),
          OutlinedButton.icon(
            onPressed: () => _exportCsv(filtered),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
          FilledButton.icon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: const Text('New Lead'),
          ),
          OutlinedButton.icon(
            onPressed: () => _importCsv(context),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Import CSV'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
          child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final l = filtered[i];
          return Card(
              child: ListTile(
            title: Text('${l['title']} — ${l['industry']}'),
            subtitle: Text(
                '${l['state']} • ${l['city']} • ${l['materials'].join(', ')} • Qty ${l['qty']}'),
            trailing: Wrap(spacing: 6, children: [
              Text(l['status']),
              TextButton(
                  onPressed: () => _edit(context, l),
                  child: const Text('Edit')),
              TextButton(
                  onPressed: () => _assign(context, l),
                  child: const Text('Assign')),
              TextButton(
                  onPressed: () => _note(context, l),
                  child: const Text('Note')),
            ]),
          ));
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: filtered.length,
      )),
    ]);
  }

  void _create(BuildContext context) {
    // Rich form similar to Seller Profile
    final formKey = GlobalKey<FormState>();
    final ctrlTitle = TextEditingController();
    final ctrlCompany = TextEditingController();
    final ctrlContact = TextEditingController();
    final ctrlEmail = TextEditingController();
    final ctrlPhone = TextEditingController();
    final ctrlCity = TextEditingController();
    final ctrlState = TextEditingController(text: 'Telangana');
    final ctrlQty = TextEditingController(text: '100');
    final ctrlTurnCr = TextEditingController(text: '10');
    final ctrlNeedBy = TextEditingController(
        text: DateTime.now()
            .add(const Duration(days: 14))
            .toString()
            .split(' ')
            .first);
    final ctrlAbout = TextEditingController();
    final gstCtrl = TextEditingController();
    List<MapEntry<String, String>> customFields = const [];
    String industry = 'Construction';
    final Set<String> selectedMaterials = {};

    showDialog(
        context: context,
        builder: (_) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 920, maxHeight: 680),
                child: Scaffold(
                  appBar: AppBar(title: const Text('New Lead')),
                  body: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                                controller: ctrlTitle,
                                decoration: const InputDecoration(
                                    labelText: 'Lead Title *',
                                    border: OutlineInputBorder()),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlCompany,
                                      decoration: const InputDecoration(
                                          labelText: 'Company Name',
                                          border: OutlineInputBorder()))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlContact,
                                      decoration: const InputDecoration(
                                          labelText: 'Contact Person',
                                          border: OutlineInputBorder()))),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlEmail,
                                      decoration: const InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder()))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlPhone,
                                      decoration: const InputDecoration(
                                          labelText: 'Phone',
                                          border: OutlineInputBorder()))),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: DropdownButtonFormField<String>(
                                      value: industry,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Construction',
                                            child: Text('Construction')),
                                        DropdownMenuItem(
                                            value: 'EPC', child: Text('EPC')),
                                        DropdownMenuItem(
                                            value: 'MEP', child: Text('MEP')),
                                        DropdownMenuItem(
                                            value: 'Solar',
                                            child: Text('Solar')),
                                      ],
                                      onChanged: (v) {
                                        industry = v ?? industry;
                                      },
                                      decoration: const InputDecoration(
                                          labelText: 'Industry'))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: MaterialsSelector(
                                value: selectedMaterials.toList(),
                                onChanged: (v) {
                                  selectedMaterials
                                    ..clear()
                                    ..addAll(v);
                                },
                                label: 'Materials Used',
                              )),
                            ]),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: gstCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'GSTIN',
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlCity,
                                      decoration: const InputDecoration(
                                          labelText: 'City',
                                          border: OutlineInputBorder()))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlState,
                                      decoration: const InputDecoration(
                                          labelText: 'State',
                                          border: OutlineInputBorder()))),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlQty,
                                      decoration: const InputDecoration(
                                          labelText: 'Quantity',
                                          border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlTurnCr,
                                      decoration: const InputDecoration(
                                          labelText: 'Buyer Turnover (₹ Cr)',
                                          border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextFormField(
                                      controller: ctrlNeedBy,
                                      decoration: const InputDecoration(
                                          labelText: 'Need By (YYYY-MM-DD)',
                                          border: OutlineInputBorder()))),
                            ]),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: ctrlAbout,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                    labelText: 'Additional Details',
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 16),
                            SimpleCustomFields(
                                entries: customFields,
                                onChanged: (v) {
                                  customFields = v;
                                },
                                title: 'Additional Info (Custom Fields)'),
                            const SizedBox(height: 12),
                          ]),
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const Spacer(),
                      FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(context);
                            _processLeadCreation(
                              ctrlTitle.text.trim(),
                              industry,
                              selectedMaterials.join(','),
                              ctrlCity.text.trim(),
                              ctrlState.text.trim(),
                              qty: int.tryParse(ctrlQty.text.trim()) ?? 0,
                              turnoverCr:
                                  double.tryParse(ctrlTurnCr.text.trim()) ?? 0,
                              needByIso: ctrlNeedBy.text.trim(),
                              about: ctrlAbout.text.trim(),
                              company: ctrlCompany.text.trim(),
                              contact: ctrlContact.text.trim(),
                              email: ctrlEmail.text.trim(),
                              phone: ctrlPhone.text.trim(),
                              gstin: gstCtrl.text.trim(),
                              customFields: customFields,
                            );
                          },
                          child: const Text('Create')),
                    ]),
                  ),
                ),
              ),
            ));
  }

  void _processLeadCreation(String title, String industry, String materials,
      String city, String state,
      {int qty = 0,
      double turnoverCr = 0,
      String? needByIso,
      String? about,
      String? company,
      String? contact,
      String? email,
      String? phone,
      String? gstin,
      List<MapEntry<String, String>>? customFields}) {
    final lead = {
      'id': 'L${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'company': company ?? 'Company Name',
      'contact': contact ?? 'Contact Person',
      'email': email ?? 'contact@example.com',
      'phone': phone ?? '+91-0000000000',
      'requirements': materials,
      'gstin': gstin ?? '',
      'customFields': (customFields ?? const <MapEntry<String, String>>[])
          .map((e) => {'k': e.key, 'v': e.value})
          .toList(),
      'industry': industry,
      'city': city,
      'state': state,
      'qty': qty,
      'turnoverCr': turnoverCr,
      'needBy': needByIso ?? DateTime.now().toIso8601String().substring(0, 10),
      'about': about ?? '',
      'status': 'New',
      'created': DateTime.now().toIso8601String().substring(0, 10),
      'assigned': 'Unassigned',
    };

    setState(() {
      leads.add(lead);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lead created successfully'),
        backgroundColor: AppColors.success,
      ),
    );

    // In a real app, you would:
    // 1. Send API request to backend
    // 2. Store in database
    // 3. Send notification to sales team
    // 4. Log the action
  }

  void _edit(BuildContext context, Map<String, dynamic> l) {
    final title = TextEditingController(text: l['title']);
    String status = l['status'];
    String assignee = l['assignee'];
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Edit ${l['id']}'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: title,
                        decoration: const InputDecoration(
                            labelText: 'Title', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                        value: status,
                        items: const [
                          DropdownMenuItem(value: 'New', child: Text('New')),
                          DropdownMenuItem(
                              value: 'In Progress', child: Text('In Progress')),
                          DropdownMenuItem(
                              value: 'Quoted', child: Text('Quoted')),
                          DropdownMenuItem(value: 'Won', child: Text('Won')),
                          DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                        ],
                        onChanged: (v) {
                          status = v ?? status;
                        },
                        decoration: const InputDecoration(labelText: 'Status')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: TextEditingController(text: assignee),
                        onChanged: (v) {
                          assignee = v;
                        },
                        decoration: const InputDecoration(
                            labelText: 'Assignee (seller)',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lead saved (demo)')));
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  void _assign(BuildContext context, Map<String, dynamic> l) {
    String assignee = l['assignee'];
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Assign ${l['id']}'),
              content: TextField(
                  controller: TextEditingController(text: assignee),
                  onChanged: (v) {
                    assignee = v;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Seller', border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assigned (demo)')));
                    },
                    child: const Text('Assign'))
              ],
            ));
  }

  void _note(BuildContext context, Map<String, dynamic> l) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Add Note to ${l['id']}'),
              content: const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: 'Note', border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note added (demo)')));
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  void _exportCsv(List<Map<String, dynamic>> list) {
    const header = 'id,title,industry,materials,city,state,qty,status,assignee';
    final rows = list
        .map((r) => [
              r['id'],
              r['title'],
              r['industry'],
              (r['materials'] as List).join('|'),
              r['city'],
              r['state'],
              r['qty'],
              r['status'],
              r['assignee']
            ].join(','))
        .join('\n');
    final csv = '$header\n$rows';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV ready (${csv.length} chars). Implement save.')));
  }

  void _importCsv(BuildContext context) {
    csv =
        'title,industry,materials,city,state,qty\nNew Plant,EPC,Aluminium|XLPE,Pune,Maharashtra,500';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Import Leads CSV'),
              content: SizedBox(
                  width: 560,
                  child: TextField(
                      controller: TextEditingController(text: csv),
                      maxLines: 8,
                      onChanged: (v) {
                        csv = v;
                      },
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      _parseAndAddLeads(csv);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Imported (demo)')));
                    },
                    child: const Text('Import')),
              ],
            ));
  }

  void _parseAndAddLeads(String text) {
    final lines = text.trim().split('\n');
    if (lines.length <= 1) return;
    final data = lines
        .skip(1)
        .map((l) => l.split(','))
        .where((cols) => cols.length >= 6);
    setState(() {
      for (final cols in data) {
        leads.insert(0, {
          'id': 'L${DateTime.now().millisecondsSinceEpoch % 100000}',
          'title': cols[0],
          'industry': cols[1],
          'materials': cols[2].split('|'),
          'city': cols[3],
          'state': cols[4],
          'qty': int.tryParse(cols[5]) ?? 0,
          'status': 'New',
          'assignee': '',
          'notes': '',
        });
      }
    });
  }
}

class _OrdersPage extends StatefulWidget {
  const _OrdersPage();
  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<_OrdersPage> {
  String q = '';
  String status = 'All';
  String stock = 'Any';
  final List<Map<String, dynamic>> orders = List.generate(
      18,
      (i) => {
            'id': '#${500 + i}',
            'buyer': i % 2 == 0 ? 'Acme Builders' : 'Metro EPC',
            'seller': i % 3 == 0 ? 'Finolex' : 'Polycab',
            'items': 3 + (i % 4),
            'total': 12000 + i * 500,
            'status': (i % 5 == 0)
                ? 'Refunded'
                : (i % 4 == 0)
                    ? 'Cancelled'
                    : (i % 3 == 0)
                        ? 'Shipped'
                        : (i % 2 == 0)
                            ? 'Processing'
                            : 'Pending',
            'hasOOS': i % 6 == 0, // contains out-of-stock items
          });

  @override
  Widget build(BuildContext context) {
    final filtered = orders.where((o) {
      final okQ = q.isEmpty ||
          o['id'].toString().contains(q) ||
          o['buyer'].toString().toLowerCase().contains(q.toLowerCase()) ||
          o['seller'].toString().toLowerCase().contains(q.toLowerCase());
      final okS = status == 'All' || o['status'] == status;
      final okStock = stock == 'Any' ||
          (stock == 'OOS' ? o['hasOOS'] == true : o['hasOOS'] == false);
      return okQ && okS && okStock;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Orders',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search #, buyer, seller',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Status')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Processing', child: Text('Processing')),
              DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              DropdownMenuItem(value: 'Refunded', child: Text('Refunded')),
            ],
            onChanged: (v) => setState(() => status = v ?? 'All'),
          ),
          DropdownButton<String>(
            value: stock,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Inventory')),
              DropdownMenuItem(value: 'OOS', child: Text('Contains OOS items')),
              DropdownMenuItem(value: 'In', child: Text('No OOS items')),
            ],
            onChanged: (v) => setState(() => stock = v ?? 'Any'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
        child: BiDirectionalScroller(
          child: DataTable(columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Buyer')),
            DataColumn(label: Text('Seller')),
            DataColumn(label: Text('Items')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Flags')),
            DataColumn(label: Text('Actions')),
          ], rows: [
            for (final o in filtered)
              DataRow(cells: [
                DataCell(Text(o['id'].toString())),
                DataCell(Text(o['buyer'].toString())),
                DataCell(Text(o['seller'].toString())),
                DataCell(Text('${o['items']}')),
                DataCell(Text('₹${o['total']}')),
                DataCell(Text(o['status'].toString())),
                DataCell(Row(children: [
                  if (o['hasOOS'] == true)
                    const Chip(
                        label: Text('OOS'), backgroundColor: Color(0xFFFFF7E0))
                ])),
                DataCell(Row(children: [
                  TextButton(
                      onPressed: () => _viewOrder(o),
                      child: const Text('View')),
                  TextButton(
                      onPressed: () => _advanceStatus(o),
                      child: const Text('Advance')),
                  TextButton(
                      onPressed: () => _cancelOrder(o),
                      child: const Text('Cancel')),
                ])),
              ])
          ]),
        ),
      ),
    ]);
  }

  void _viewOrder(Map<String, dynamic> o) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Order ${o['id']}'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buyer: ${o['buyer']}'),
                    Text('Seller: ${o['seller']}'),
                    Text('Items: ${o['items']}'),
                    Text('Total: ₹${o['total']}'),
                    Text('Status: ${o['status']}'),
                    if (o['hasOOS'] == true) const SizedBox(height: 8),
                    if (o['hasOOS'] == true)
                      const Text('Contains out-of-stock items',
                          style: TextStyle(color: AppColors.warning)),
                  ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  void _advanceStatus(Map<String, dynamic> o) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Advanced ${o['id']} (demo)')));
  }

  void _cancelOrder(Map<String, dynamic> o) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Cancelled ${o['id']} (demo)')));
  }
}

class _MessagingPage extends StatefulWidget {
  const _MessagingPage();
  @override
  State<_MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<_MessagingPage> {
  String q = '';
  String flag = 'Any';
  String dateRange = 'Any';
  final List<Map<String, dynamic>> threads = List.generate(
      16,
      (i) => {
            'id': '#${1000 + i}',
            'buyer': i % 2 == 0 ? 'Acme Builders' : 'Metro EPC',
            'seller': i % 3 == 0 ? 'Finolex' : 'Polycab',
            'messages': 4 + (i % 7),
            'flagged': i % 5 == 0,
            'last': '2025-09-${10 + (i % 10)} 1$i:00',
          });

  @override
  Widget build(BuildContext context) {
    final filtered = threads.where((t) {
      final okQ = q.isEmpty ||
          t['id'].toString().contains(q) ||
          t['buyer'].toString().toLowerCase().contains(q.toLowerCase()) ||
          t['seller'].toString().toLowerCase().contains(q.toLowerCase());
      final okF = flag == 'Any' ||
          (flag == 'Flagged' ? t['flagged'] == true : t['flagged'] == false);
      final okD = dateRange == 'Any' ||
          (dateRange == 'Last 7d'
              ? t['last'].toString().compareTo('2025-09-12') >= 0
              : true);
      return okQ && okF && okD;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Messaging Moderation',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search #, buyer, seller',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: flag,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any')),
              DropdownMenuItem(value: 'Flagged', child: Text('Flagged')),
              DropdownMenuItem(value: 'Clean', child: Text('Not Flagged')),
            ],
            onChanged: (v) => setState(() => flag = v ?? 'Any'),
          ),
          DropdownButton<String>(
            value: dateRange,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Date')),
              DropdownMenuItem(value: 'Last 7d', child: Text('Last 7 days')),
            ],
            onChanged: (v) => setState(() => dateRange = v ?? 'Any'),
          ),
          OutlinedButton.icon(
            onPressed: () => _exportCsv(filtered),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
        child: BiDirectionalScroller(
          child: DataTable(columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Buyer')),
            DataColumn(label: Text('Seller')),
            DataColumn(label: Text('Messages')),
            DataColumn(label: Text('Flags')),
            DataColumn(label: Text('Last')),
            DataColumn(label: Text('Actions')),
          ], rows: [
            for (final t in filtered)
              DataRow(cells: [
                DataCell(Text(t['id'].toString())),
                DataCell(Text(t['buyer'].toString())),
                DataCell(Text(t['seller'].toString())),
                DataCell(Text('${t['messages']}')),
                DataCell(Row(children: [
                  if (t['flagged'] == true) const Chip(label: Text('Flagged'))
                ])),
                DataCell(Text(t['last'].toString())),
                DataCell(Row(children: [
                  TextButton(
                      onPressed: () => _openThread(t),
                      child: const Text('Open')),
                  if (t['flagged'] == true)
                    TextButton(
                        onPressed: () => _resolveFlag(t),
                        child: const Text('Resolve')),
                  TextButton(
                      onPressed: () => _blockUser(t),
                      child: const Text('Block')),
                  TextButton(
                      onPressed: () => _exportThread(t),
                      child: const Text('Export Thread')),
                ])),
              ])
          ]),
        ),
      ),
    ]);
  }

  void _openThread(Map<String, dynamic> t) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Thread ${t['id']}'),
              content: const SizedBox(
                  width: 560,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(title: Text('Buyer: Hello, need 500m cable.')),
                    ListTile(title: Text('Seller: Price shared.')),
                    ListTile(title: Text('Buyer: Sending PO.')),
                    ListTile(
                        title: Text(
                            'System: Flagged for keyword "urgent" (demo)')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  void _resolveFlag(Map<String, dynamic> t) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resolved flag on ${t['id']} (demo)')));
  }

  void _blockUser(Map<String, dynamic> t) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blocked user in ${t['id']} (demo)')));
  }

  void _exportCsv(List<Map<String, dynamic>> list) {
    const header = 'id,buyer,seller,messages,flagged,last';
    final rows = list
        .map((r) => [
              r['id'],
              r['buyer'],
              r['seller'],
              r['messages'],
              r['flagged'],
              r['last']
            ].join(','))
        .join('\n');
    final csv = '$header\n$rows';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV ready (${csv.length} chars). Implement save.')));
  }

  void _exportThread(Map<String, dynamic> t) {
    final transcript = 'Thread ${t['id']}\nBuyer: Hello...\nSeller: Price...';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Transcript ready (${transcript.length} chars). Implement save.')));
  }
}

class _StateCmsPage extends StatefulWidget {
  const _StateCmsPage();
  @override
  State<_StateCmsPage> createState() => _StateCmsPageState();
}

class _StateCmsPageState extends State<_StateCmsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  String q = '';
  final List<Map<String, dynamic>> _posts = [];
  @override
  void initState() {
    super.initState();
    // Seed demo posts with categories and version history
    for (int i = 0; i < 12; i++) {
      _posts.add({
        'id': 'POST${100 + i}',
        'title': 'Post ${i + 1}',
        'state': i % 2 == 0 ? 'Maharashtra' : 'Karnataka',
        'author': 'Admin',
        'time': '${2 + (i % 5)}d',
        'category': (i % 3 == 0)
            ? 'design'
            : (i % 3 == 1)
                ? 'images'
                : 'profiles',
        'pinned': i % 5 == 0,
        'content': 'Sample content ${i + 1}',
        'versions': [
          {'v': 1, 'time': '7d', 'summary': 'Initial'},
        ],
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('State Info CMS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(
              width: 300,
              child: TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search), hintText: 'Search posts'),
                  onChanged: (v) => setState(() => q = v))),
          const SizedBox(width: 8),
          FilledButton.icon(
              onPressed: () => _composePost(context),
              icon: const Icon(Icons.add),
              label: const Text('New Post')),
        ]),
      ),
      TabBar(controller: _tabs, isScrollable: true, tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Designs'),
        Tab(text: 'Product Images'),
        Tab(text: 'Profiles'),
      ]),
      const Divider(height: 1),
      Expanded(
          child: TabBarView(controller: _tabs, children: [
        _cmsList(q: q, kind: 'all'),
        _cmsList(q: q, kind: 'design'),
        _cmsList(q: q, kind: 'images'),
        _cmsList(q: q, kind: 'profiles'),
      ])),
    ]);
  }

  Widget _cmsList({required String q, required String kind}) {
    final posts = _posts.where((p) {
      final okKind = kind == 'all' || p['category'] == kind;
      final okQ = q.isEmpty ||
          p['title'].toString().toLowerCase().contains(q.toLowerCase()) ||
          p['state'].toString().toLowerCase().contains(q.toLowerCase());
      return okKind && okQ;
    }).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Card(
        child: ListTile(
          title: Row(children: [
            if (posts[i]['pinned'] == true)
              const Icon(Icons.push_pin, size: 16),
            if (posts[i]['pinned'] == true) const SizedBox(width: 6),
            Expanded(child: Text(posts[i]['title']!)),
          ]),
          subtitle: Text(
              '${posts[i]['state']} • ${posts[i]['author']} • ${posts[i]['time']} • v${(posts[i]['versions'] as List).length}'),
          trailing: Wrap(spacing: 6, children: [
            TextButton(
                onPressed: () => _editPost(posts[i]),
                child: const Text('Edit')),
            TextButton(
                onPressed: () => _versions(posts[i]),
                child: const Text('Versions')),
            TextButton(
                onPressed: () => _deletePost(posts[i]),
                child: const Text('Delete')),
            TextButton(
                onPressed: () => _togglePin(posts[i]),
                child: Text(posts[i]['pinned'] == true ? 'Unpin' : 'Pin')),
          ]),
        ),
      ),
    );
  }

  void _composePost(BuildContext context) {
    String category = 'design';
    final title = TextEditingController();
    final state = TextEditingController();
    final content = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('New Post'),
              content: SizedBox(
                  width: 560,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: title,
                        decoration: const InputDecoration(
                            labelText: 'Title', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: state,
                        decoration: const InputDecoration(
                            labelText: 'State/Discom',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                        value: category,
                        items: const [
                          DropdownMenuItem(
                              value: 'design', child: Text('Designs')),
                          DropdownMenuItem(
                              value: 'images', child: Text('Product Images')),
                          DropdownMenuItem(
                              value: 'profiles', child: Text('Profiles')),
                        ],
                        onChanged: (v) {
                          category = v ?? 'design';
                        },
                        decoration:
                            const InputDecoration(labelText: 'Category')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: content,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        _posts.insert(0, {
                          'id': 'POST${DateTime.now().millisecondsSinceEpoch}',
                          'title': title.text.trim(),
                          'state': state.text.trim(),
                          'author': 'Admin',
                          'time': 'now',
                          'category': category,
                          'pinned': false,
                          'content': content.text.trim(),
                          'versions': [
                            {'v': 1, 'time': 'now', 'summary': 'Initial'}
                          ],
                        });
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Publish'))
              ],
            ));
  }

  void _editPost(Map<String, dynamic> p) {
    final title = TextEditingController(text: p['title']);
    final state = TextEditingController(text: p['state']);
    final content = TextEditingController(text: p['content']);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Edit ${p['id']}'),
              content: SizedBox(
                  width: 560,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: title,
                        decoration: const InputDecoration(
                            labelText: 'Title', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: state,
                        decoration: const InputDecoration(
                            labelText: 'State/Discom',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: content,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        p['title'] = title.text.trim();
                        p['state'] = state.text.trim();
                        p['content'] = content.text.trim();
                        final versions = (p['versions'] as List);
                        versions.add({
                          'v': versions.length + 1,
                          'time': 'now',
                          'summary': 'Edited'
                        });
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  void _deletePost(Map<String, dynamic> p) {
    setState(() => _posts.removeWhere((e) => e['id'] == p['id']));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deleted "${p['title']}"')));
  }

  void _togglePin(Map<String, dynamic> p) {
    setState(() => p['pinned'] = !(p['pinned'] as bool));
  }

  void _versions(Map<String, dynamic> p) {
    final versions = (p['versions'] as List).reversed.toList();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Versions — ${p['title']}'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final v in versions)
                      ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('v${v['v']} • ${v['time']}'),
                          subtitle: Text(v['summary'] ?? '')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }
}

class _SearchPage extends ConsumerStatefulWidget {
  const _SearchPage();
  @override
  ConsumerState<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<_SearchPage> {
  final keyCtrl = TextEditingController();
  final valCtrl = TextEditingController();
  final bannedCtrl = TextEditingController();
  String boostKey = '';
  String boostVal = '1.0';
  String category = '';
  String catTerm = '';
  String catFactor = '1.0';

  @override
  void dispose() {
    keyCtrl.dispose();
    valCtrl.dispose();
    bannedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(adminStoreProvider);
    final synonyms = store.synonyms.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final banned = store.bannedTerms.toList()..sort();
    final boosts = store.boosts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Search & Relevance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () {
                final payload = {
                  'synonyms': store.synonyms,
                  'banned': store.bannedTerms.toList(),
                  'boosts': store.boosts,
                  'categoryBoosts': store.categoryBoosts,
                };
                final json =
                    const JsonEncoder.withIndent('  ').convert(payload);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Exported JSON (${json.length} chars)')),
                );
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export JSON'),
            ),
          ]),
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Synonyms'),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final e in synonyms)
                            Chip(
                                label: Text('${e.key} → ${e.value}'),
                                onDeleted: () => store.removeSynonym(e.key)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: keyCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Term',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller: valCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Synonym',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          FilledButton(
                              onPressed: () {
                                final a = keyCtrl.text.trim(),
                                    b = valCtrl.text.trim();
                                if (a.isNotEmpty && b.isNotEmpty) {
                                  store.addSynonym(a, b);
                                  keyCtrl.clear();
                                  valCtrl.clear();
                                }
                              },
                              child: const Text('Add')),
                        ]),
                      ]))),
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Banned Terms'),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final t in banned)
                            Chip(
                                label: Text(t),
                                onDeleted: () => store.removeBanned(t)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: bannedCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Add term',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          FilledButton(
                              onPressed: () {
                                final t = bannedCtrl.text.trim();
                                if (t.isNotEmpty) {
                                  store.addBanned(t);
                                  bannedCtrl.clear();
                                }
                              },
                              child: const Text('Ban')),
                        ]),
                      ]))),
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Boosts'),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final e in boosts)
                            Chip(
                                label: Text(
                                    '${e.key} × ${e.value.toStringAsFixed(2)}')),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller:
                                      TextEditingController(text: boostKey),
                                  onChanged: (v) => boostKey = v,
                                  decoration: const InputDecoration(
                                      labelText: 'Term',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 120,
                              child: TextField(
                                  controller:
                                      TextEditingController(text: boostVal),
                                  onChanged: (v) => boostVal = v,
                                  decoration: const InputDecoration(
                                      labelText: 'Factor'),
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          FilledButton(
                              onPressed: () {
                                final k = boostKey.trim();
                                final f = double.tryParse(boostVal) ?? 1.0;
                                if (k.isNotEmpty) store.setBoost(k, f);
                              },
                              child: const Text('Set')),
                        ]),
                      ]))),
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category Boosts'),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final e in store.categoryBoosts.entries)
                            for (final kv in e.value.entries)
                              Chip(
                                  label: Text(
                                      '[${e.key}] ${kv.key} × ${kv.value.toStringAsFixed(2)}')),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller:
                                      TextEditingController(text: category),
                                  onChanged: (v) => category = v,
                                  decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller:
                                      TextEditingController(text: catTerm),
                                  onChanged: (v) => catTerm = v,
                                  decoration: const InputDecoration(
                                      labelText: 'Term',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 120,
                              child: TextField(
                                  controller:
                                      TextEditingController(text: catFactor),
                                  onChanged: (v) => catFactor = v,
                                  decoration: const InputDecoration(
                                      labelText: 'Factor'),
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          FilledButton(
                              onPressed: () {
                                final c = category.trim(),
                                    t = catTerm.trim(),
                                    f = double.tryParse(catFactor) ?? 1.0;
                                if (c.isNotEmpty && t.isNotEmpty)
                                  store.setCategoryBoost(c, t, f);
                              },
                              child: const Text('Set')),
                        ]),
                      ]))),
        ]),
      ),
    );
  }
}

class _GeoPage extends ConsumerStatefulWidget {
  const _GeoPage();
  @override
  ConsumerState<_GeoPage> createState() => _GeoPageState();
}

class _GeoPageState extends ConsumerState<_GeoPage> {
  String? selectedState;
  String? selectedCity;
  final areaCtrl = TextEditingController();
  double? radius;

  @override
  void dispose() {
    areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(adminStoreProvider);
    final geo = store.geo;
    final states = geo.keys.toList()..sort();
    selectedState ??= states.isNotEmpty ? states.first : null;
    final cities = selectedState == null
        ? <String>[]
        : (geo[selectedState!]!.keys.toList()..sort());
    selectedCity ??= cities.isNotEmpty ? cities.first : null;
    final areas = (selectedState != null && selectedCity != null)
        ? (geo[selectedState!]![selectedCity!] ?? [])
        : <String>[];
    radius ??= store.defaultServiceRadiusKm;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Geo & Regions',
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final payload = {
                'geo': store.geo,
                'radiusOverrides': store.cityRadiusOverridesKm,
                'defaultRadiusKm': store.defaultServiceRadiusKm,
              };
              final json = const JsonEncoder.withIndent('  ').convert(payload);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Exported Geo JSON (${json.length} chars)')),
              );
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export JSON'),
          ),
          DropdownButton<String>(
            value: selectedState,
            hint: const Text('Select state'),
            items: [
              for (final s in states)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) {
              setState(() {
                selectedState = v;
                selectedCity = null;
              });
            },
          ),
          if (selectedState != null)
            DropdownButton<String>(
              value: selectedCity,
              hint: const Text('Select city'),
              items: [
                for (final c in cities)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) {
                setState(() => selectedCity = v);
              },
            ),
          OutlinedButton.icon(
            onPressed: () => _addState(context),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add State'),
          ),
          if (selectedState != null)
            OutlinedButton.icon(
              onPressed: () => _addCity(context, selectedState!),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Add City'),
            ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const Text('Default service radius:'),
          const SizedBox(width: 8),
          SizedBox(
              width: 120,
              child: TextField(
                  controller:
                      TextEditingController(text: radius!.toStringAsFixed(0)),
                  onChanged: (v) {
                    radius = double.tryParse(v) ?? radius;
                  },
                  decoration: const InputDecoration(suffixText: 'km'))),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: () {
                if (radius != null) store.setDefaultRadius(radius!);
              },
              child: const Text('Save')),
        ]),
      ),
      const Divider(height: 16),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Areas'),
                        const SizedBox(height: 8),
                        if (selectedState == null || selectedCity == null)
                          const Text('Select a state and city'),
                        if (selectedState != null && selectedCity != null) ...[
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final a in areas)
                              Chip(
                                  label: Text(a),
                                  onDeleted: () => store.removeArea(
                                      selectedState!, selectedCity!, a)),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: TextField(
                                    controller: areaCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Add area',
                                        border: OutlineInputBorder()))),
                            const SizedBox(width: 8),
                            FilledButton(
                                onPressed: () {
                                  final v = areaCtrl.text.trim();
                                  if (v.isNotEmpty) {
                                    store.addArea(
                                        selectedState!, selectedCity!, v);
                                    areaCtrl.clear();
                                  }
                                },
                                child: const Text('Add')),
                          ]),
                        ],
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (selectedState != null && selectedCity != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City Radius Override'),
                          const SizedBox(height: 8),
                          Row(children: [
                            SizedBox(
                              width: 160,
                              child: TextField(
                                controller: TextEditingController(
                                    text: (store.cityRadiusOverridesKm[
                                                '${selectedState!}|${selectedCity!}'] ??
                                            store.defaultServiceRadiusKm)
                                        .toStringAsFixed(0)),
                                onChanged: (v) {},
                                decoration: const InputDecoration(
                                    labelText: 'Radius (km)',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                                onPressed: () {
                                  final ctrlVal = (store.cityRadiusOverridesKm[
                                              '${selectedState!}|${selectedCity!}'] ??
                                          store.defaultServiceRadiusKm)
                                      .toStringAsFixed(0);
                                  final parsed = double.tryParse(ctrlVal);
                                  if (parsed != null)
                                    store.setCityRadius(
                                        selectedState!, selectedCity!, parsed);
                                },
                                child: const Text('Save')),
                            const SizedBox(width: 8),
                            OutlinedButton(
                                onPressed: () {
                                  store.clearCityRadius(
                                      selectedState!, selectedCity!);
                                },
                                child: const Text('Clear')),
                          ]),
                        ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }

  void _addState(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Add State'),
              content: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                      labelText: 'State', border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      ProviderScope.containerOf(context)
                          .read(adminStoreProvider)
                          .addState(ctrl.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  void _addCity(BuildContext context, String state) {
    final ctrl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Add City in $state'),
              content: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                      labelText: 'City', border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      ProviderScope.containerOf(context)
                          .read(adminStoreProvider)
                          .addCity(state, ctrl.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }
}

class _AnalyticsPage extends StatefulWidget {
  const _AnalyticsPage();
  @override
  State<_AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<_AnalyticsPage> {
  String range = '7d';
  DateTimeRange? customRange;
  String segmentDevice = 'All';
  String segmentChannel = 'All';
  String segmentState = 'All';
  bool comparePrev = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AdminPageHeader(
            title: 'Analytics',
            actions: [
              DropdownButton<String>(
                value: range,
                items: const [
                  DropdownMenuItem(value: '7d', child: Text('Last 7d')),
                  DropdownMenuItem(value: '30d', child: Text('Last 30d')),
                  DropdownMenuItem(value: '90d', child: Text('Last 90d')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (v) async {
                  if (v == 'custom') {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now,
                      initialDateRange: DateTimeRange(
                        start: now.subtract(const Duration(days: 7)),
                        end: now,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        range = 'custom';
                        customRange = picked;
                      });
                    }
                  } else {
                    setState(() => range = v ?? '7d');
                  }
                },
              ),
              DropdownButton<String>(
                value: segmentDevice,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Devices')),
                  DropdownMenuItem(value: 'Web', child: Text('Web')),
                  DropdownMenuItem(value: 'Android', child: Text('Android')),
                  DropdownMenuItem(value: 'iOS', child: Text('iOS')),
                ],
                onChanged: (v) => setState(() => segmentDevice = v ?? 'All'),
              ),
              DropdownButton<String>(
                value: segmentChannel,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Channels')),
                  DropdownMenuItem(value: 'Organic', child: Text('Organic')),
                  DropdownMenuItem(value: 'Ads', child: Text('Ads')),
                  DropdownMenuItem(value: 'Referral', child: Text('Referral')),
                ],
                onChanged: (v) => setState(() => segmentChannel = v ?? 'All'),
              ),
              DropdownButton<String>(
                value: segmentState,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All States')),
                  DropdownMenuItem(value: 'MH', child: Text('Maharashtra')),
                  DropdownMenuItem(value: 'KA', child: Text('Karnataka')),
                  DropdownMenuItem(value: 'TG', child: Text('Telangana')),
                ],
                onChanged: (v) => setState(() => segmentState = v ?? 'All'),
              ),
              Row(
                children: [
                  const Text('Compare'),
                  Switch(
                    value: comparePrev,
                    onChanged: (v) => setState(() => comparePrev = v),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _exportAll,
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _kpiRow(),
          const SizedBox(height: 12),
          _chartCard('Funnel: Visit → Lead → Quote → Order',
              action: TextButton(
                  onPressed: _exportFunnels, child: const Text('Export CSV'))),
          const SizedBox(height: 12),
          _cohortCard(),
          const SizedBox(height: 12),
          _seriesCard('Time Series: DAU / Orders / GMV'),
          const SizedBox(height: 12),
          _chartCard('Conversions by channel',
              action: TextButton(
                  onPressed: _exportChannels, child: const Text('Export CSV'))),
          const SizedBox(height: 12),
          _geoHeatmapCard(),
          const SizedBox(height: 12),
          _tableCard('Top Products', [
            'Product',
            'Views',
            'Leads',
            'Orders',
            'GMV'
          ], [
            ['Cable A', '12k', '320', '45', '₹4.5L'],
            ['Switch B', '9k', '210', '28', '₹2.3L'],
          ]),
          const SizedBox(height: 12),
          _tableCard('Top Sellers', [
            'Seller',
            'Views',
            'Leads',
            'Orders',
            'GMV'
          ], [
            ['Finolex', '18k', '540', '72', '₹7.8L'],
            ['Polycab', '16k', '480', '66', '₹7.1L'],
          ]),
          const SizedBox(height: 12),
          _tableCard('Search Analytics', [
            'Query',
            'Count',
            'No Result',
            'Conv%'
          ], [
            ['copper wire', '2,430', '12', '3.4%'],
            ['xlpe cable', '1,980', '7', '2.9%'],
            ['rare term', '120', '120', '0.0%'],
          ]),
        ]),
      ),
    );
  }

  Widget _kpiRow() {
    Widget k(String label, String value, {Color? color}) => Expanded(
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(value,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ]))));
    return Row(children: [
      k('DAU', '12,430'),
      const SizedBox(width: 8),
      k('Orders', '1,240'),
      const SizedBox(width: 8),
      k('GMV', '₹92.4L'),
      const SizedBox(width: 8),
      k('Conv%', '3.9%'),
    ]);
  }

  Widget _chartCard(String title, {Widget? action}) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              if (action != null) action
            ]),
            const SizedBox(height: 8),
            Container(
              height: 220,
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenue Trend (Last 30 Days)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildRevenueChart(),
                  ),
                ],
              ),
            ),
          ])));

  Widget _seriesCard(String title) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
                height: 200,
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('Lines: DAU, Orders, GMV')),
          ])));

  Widget _cohortCard() => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Cohorts: Signup month retention',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                  onPressed: _exportCohorts, child: const Text('Export CSV'))
            ]),
            const SizedBox(height: 8),
            Container(
                height: 220,
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('Cohort heatmap placeholder')),
          ])));

  Widget _geoHeatmapCard() => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Geo Heatmap (orders by state/city)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: _exportGeo, child: const Text('Export CSV'))
            ]),
            const SizedBox(height: 8),
            Container(
                height: 220,
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('Geo heatmap placeholder')),
          ])));

  Widget _tableCard(
          String title, List<String> headers, List<List<String>> rows) =>
      Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                          onPressed: () => _exportTable(title, headers, rows),
                          child: const Text('Export CSV'))
                    ]),
                    const SizedBox(height: 8),
                    BiDirectionalScroller(
                        child: DataTable(columns: [
                      for (final h in headers) DataColumn(label: Text(h))
                    ], rows: [
                      for (final r in rows)
                        DataRow(cells: [for (final c in r) DataCell(Text(c))]),
                    ])),
                  ])));

  void _exportAll() {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported analytics bundle (demo)')));
  }

  void _exportFunnels() {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funnels CSV ready (demo)')));
  }

  void _exportCohorts() {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cohorts CSV ready (demo)')));
  }

  void _exportChannels() {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channels CSV ready (demo)')));
  }

  void _exportGeo() {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Geo CSV ready (demo)')));
  }

  void _exportTable(
      String title, List<String> headers, List<List<String>> rows) {
    if (!ProviderScope.containerOf(context)
        .read(adminAuthServiceProvider)
        .hasPermission('export.data')) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title CSV ready (demo)')));
  }

  Widget _buildRevenueChart() {
    // Generate sample revenue data for the last 30 days
    final now = DateTime.now();
    final revenueData = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final baseRevenue = 50000 + (index * 1000) + (index % 7 == 0 ? 5000 : 0);
      return {
        'date': date,
        'revenue': baseRevenue + (index % 3 == 0 ? 2000 : 0),
      };
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: RevenueChartPainter(revenueData),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  RevenueChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final minRevenue =
        data.map((d) => d['revenue'] as int).reduce((a, b) => a < b ? a : b);
    final maxRevenue =
        data.map((d) => d['revenue'] as int).reduce((a, b) => a > b ? a : b);
    final revenueRange = maxRevenue - minRevenue;

    if (revenueRange == 0) return;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final revenue = data[i]['revenue'] as int;
      final y =
          size.height - ((revenue - minRevenue) / revenueRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i += 3) {
      // Show every 3rd point
      final x = (i / (data.length - 1)) * size.width;
      final revenue = data[i]['revenue'] as int;
      final y =
          size.height - ((revenue - minRevenue) / revenueRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CompliancePage extends StatefulWidget {
  const _CompliancePage();
  @override
  State<_CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<_CompliancePage> {
  String tab = 'Reports';
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('Compliance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const Spacer(),
          DropdownButton<String>(
              value: tab,
              items: const [
                DropdownMenuItem(value: 'Reports', child: Text('Reports')),
                DropdownMenuItem(value: 'Takedowns', child: Text('Takedowns')),
                DropdownMenuItem(
                    value: 'Legal Holds', child: Text('Legal Holds')),
                DropdownMenuItem(
                    value: 'PII Redaction', child: Text('PII Redaction')),
              ],
              onChanged: (v) => setState(() => tab = v ?? 'Reports')),
        ]),
      ),
      const Divider(height: 1),
      Expanded(child: _content()),
    ]);
  }

  Widget _content() {
    switch (tab) {
      case 'Takedowns':
        return _simpleList('Takedown Requests',
            ['#TK100 • product spam', '#TK101 • abusive messaging']);
      case 'Legal Holds':
        return _simpleList('Legal Holds', ['User U1001 • until 2026-01-01']);
      case 'PII Redaction':
        return _redaction();
      case 'Reports':
      default:
        return _simpleList(
            'Reports', ['Monthly compliance report', 'KYC summary']);
    }
  }

  Widget _simpleList(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.all(16),
          child:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(
          child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => Card(
                  child: ListTile(
                      title: Text(items[i]),
                      trailing: TextButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Opened (demo)'))),
                          child: const Text('Open')))),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: items.length)),
    ]);
  }

  Widget _redaction() {
    final userCtrl = TextEditingController();
    final fieldCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PII Redaction'),
        const SizedBox(height: 8),
        Row(children: [
          SizedBox(
              width: 220,
              child: TextField(
                  controller: userCtrl,
                  decoration: const InputDecoration(
                      labelText: 'User ID', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          SizedBox(
              width: 220,
              child: TextField(
                  controller: fieldCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Field (e.g., phone)',
                      border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redaction queued (demo)')));
              },
              child: const Text('Redact')),
        ]),
      ]),
    );
  }
}

class _BillingPage extends StatefulWidget {
  const _BillingPage();
  @override
  State<_BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<_BillingPage> {
  String q = '';
  String plan = 'Any';
  final Set<String> selected = <String>{};
  final List<Map<String, dynamic>> subs = List.generate(
      10,
      (i) => {
            'id': 'U${1000 + i}',
            'name': i % 2 == 0 ? 'Aarti' : 'Rahul',
            'email': 'user$i@example.com',
            'plan': i % 3 == 0 ? 'pro' : (i % 2 == 0 ? 'plus' : 'free'),
            'status': 'active',
            'renewal': '2025-12-0${(i % 9) + 1}',
          });

  @override
  Widget build(BuildContext context) {
    final filtered = subs.where((s) {
      final okQ = q.isEmpty ||
          s['id'].toString().contains(q) ||
          s['name'].toString().toLowerCase().contains(q.toLowerCase()) ||
          s['email'].toString().toLowerCase().contains(q.toLowerCase());
      final okP = plan == 'Any' || s['plan'] == plan;
      return okQ && okP;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminPageHeader(
        title: 'Billing & Subscriptions',
        actions: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search user id/name/email',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          DropdownButton<String>(
            value: plan,
            items: const [
              DropdownMenuItem(value: 'Any', child: Text('Any Plan')),
              DropdownMenuItem(value: 'free', child: Text('Free')),
              DropdownMenuItem(value: 'plus', child: Text('Plus')),
              DropdownMenuItem(value: 'pro', child: Text('Pro')),
            ],
            onChanged: (v) => setState(() => plan = v ?? 'Any'),
          ),
          FilledButton.icon(
            onPressed: () => _grantPlan(context),
            icon: const Icon(Icons.card_membership),
            label: const Text('Grant Plan'),
          ),
          OutlinedButton.icon(
            onPressed: () => _coupon(context),
            icon: const Icon(Icons.percent),
            label: const Text('Issue Coupon'),
          ),
        ],
      ),
      const Divider(height: 1),
      Expanded(
        child: Column(
          children: [
            // Bulk actions bar
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primarySurface,
                child: Row(
                  children: [
                    Text('${selected.length} selected'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _bulkChangePlan(),
                      icon: const Icon(Icons.card_membership),
                      label: const Text('Change Plan'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkRefund(),
                      icon: const Icon(Icons.money_off),
                      label: const Text('Refund'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _bulkIssueCoupon(),
                      icon: const Icon(Icons.percent),
                      label: const Text('Issue Coupon'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => selected.clear()),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Selection'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BiDirectionalScroller(
                child: DataTable(columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Plan')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Renews')),
                  DataColumn(label: Text('Actions')),
                ], rows: [
                  for (final s in filtered)
                    DataRow(cells: [
                      DataCell(Checkbox(
                        value: selected.contains(s['id']),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              selected.add(s['id']);
                            } else {
                              selected.remove(s['id']);
                            }
                          });
                        },
                      )),
                      DataCell(Text(s['id'])),
                      DataCell(Text(s['email'])),
                      DataCell(Text(s['plan'])),
                      DataCell(Text(s['status'])),
                      DataCell(Text(s['renewal'])),
                      DataCell(Row(children: [
                        TextButton(
                            onPressed: () => _changePlan(context, s),
                            child: const Text('Change Plan')),
                        TextButton(
                            onPressed: () => _refund(context, s),
                            child: const Text('Refund')),
                      ])),
                    ])
                ]),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _grantPlan(BuildContext context) {
    final userId = TextEditingController();
    String plan = 'pro';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Grant Plan'),
              content: SizedBox(
                  width: 420,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: userId,
                        decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                        value: plan,
                        items: const [
                          DropdownMenuItem(value: 'plus', child: Text('Plus')),
                          DropdownMenuItem(value: 'pro', child: Text('Pro')),
                        ],
                        onChanged: (v) {
                          plan = v ?? 'pro';
                        },
                        decoration: const InputDecoration(labelText: 'Plan')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      ProviderScope.containerOf(context)
                          .read(adminStoreProvider)
                          .grantPlan(userId.text.trim(), plan);
                      Navigator.pop(context);
                    },
                    child: const Text('Grant'))
              ],
            ));
  }

  void _coupon(BuildContext context) {
    final userId = TextEditingController();
    final code = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Issue Coupon'),
              content: SizedBox(
                  width: 420,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: userId,
                        decoration: const InputDecoration(
                            labelText: 'User ID (optional)',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(
                        controller: code,
                        decoration: const InputDecoration(
                            labelText: 'Coupon Code',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Coupon issued (demo)')));
                    },
                    child: const Text('Issue'))
              ],
            ));
  }

  void _changePlan(BuildContext context, Map<String, dynamic> s) {
    String plan = s['plan'];
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Change Plan ${s['id']}'),
              content: DropdownButtonFormField<String>(
                  value: plan,
                  items: const [
                    DropdownMenuItem(value: 'free', child: Text('Free')),
                    DropdownMenuItem(value: 'plus', child: Text('Plus')),
                    DropdownMenuItem(value: 'pro', child: Text('Pro')),
                  ],
                  onChanged: (v) {
                    plan = v ?? plan;
                  },
                  decoration: const InputDecoration(labelText: 'Plan')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processPlanChange(s, plan);
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  void _processPlanChange(Map<String, dynamic> subscription, String newPlan) {
    setState(() {
      subscription['plan'] = newPlan;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changed plan for ${subscription['id']} to $newPlan'),
        backgroundColor: AppColors.success,
      ),
    );

    // In a real app, you would:
    // 1. Send API request to backend
    // 2. Update billing system
    // 3. Send notification to user
    // 4. Log the action
  }

  void _refund(BuildContext context, Map<String, dynamic> s) {
    final amount = TextEditingController(text: '100.00');
    final reason = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Refund ${s['id']}'),
              content: SizedBox(
                  width: 420,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: amount,
                        decoration: const InputDecoration(
                            labelText: 'Amount', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    TextField(
                        controller: reason,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Reason (optional)',
                            border: OutlineInputBorder())),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      final a = double.tryParse(amount.text.trim()) ?? 0;
                      Navigator.pop(context);
                      _processRefund(s, a, reason.text.trim());
                    },
                    child: const Text('Refund'))
              ],
            ));
  }

  void _processRefund(
      Map<String, dynamic> subscription, double amount, String reason) {
    // Update subscription data
    setState(() {
      subscription['lastRefund'] = {
        'amount': amount,
        'reason': reason,
        'date': DateTime.now().toIso8601String(),
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Refund of ₹${amount.toStringAsFixed(2)} processed for ${subscription['id']}'),
        backgroundColor: AppColors.success,
      ),
    );

    // In a real app, you would:
    // 1. Send API request to payment processor
    // 2. Update billing records
    // 3. Send notification to user
    // 4. Log the action
  }

  void _bulkChangePlan() {
    String plan = 'pro';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Change plan for ${selected.length} users?'),
        content: DropdownButtonFormField<String>(
          value: plan,
          items: const [
            DropdownMenuItem(value: 'free', child: Text('Free')),
            DropdownMenuItem(value: 'plus', child: Text('Plus')),
            DropdownMenuItem(value: 'pro', child: Text('Pro')),
          ],
          onChanged: (v) => plan = v ?? 'pro',
          decoration: const InputDecoration(labelText: 'New Plan'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Changed plan to $plan for ${selected.length} users')),
              );
            },
            child: const Text('Change All'),
          ),
        ],
      ),
    );
  }

  void _bulkRefund() {
    final amount = TextEditingController(text: '100.00');
    final reason = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Refund ${selected.length} users?'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount,
                decoration: const InputDecoration(
                    labelText: 'Amount per user', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reason,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Refunded ${selected.length} users')),
              );
            },
            child: const Text('Refund All'),
          ),
        ],
      ),
    );
  }

  void _bulkIssueCoupon() {
    final code = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Issue coupon to ${selected.length} users?'),
        content: TextField(
          controller: code,
          decoration: const InputDecoration(
              labelText: 'Coupon Code', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selected.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Issued coupon to ${selected.length} users')),
              );
            },
            child: const Text('Issue All'),
          ),
        ],
      ),
    );
  }
}

class _SystemOperationsPage extends StatelessWidget {
  const _SystemOperationsPage();
  @override
  Widget build(BuildContext context) {
    return const SystemOperationsPage();
  }
}

class _DevToolsPage extends ConsumerWidget {
  const _DevToolsPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(adminStoreProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Dev Tools',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(spacing: 8, children: [
          FilledButton.icon(
              onPressed: store.seedDemoData,
              icon: const Icon(Icons.dataset),
              label: const Text('Seed demo data')),
          OutlinedButton.icon(
              onPressed: store.reindexSearch,
              icon: const Icon(Icons.manage_search_outlined),
              label: const Text('Reindex search')),
        ]),
      ),
    ]);
  }
}

// (legacy helper removed)

class _FeatureFlagsPage extends StatelessWidget {
  const _FeatureFlagsPage();
  @override
  Widget build(BuildContext context) {
    return const FeatureFlagsPage();
  }
}

class _AuditLogsPage extends ConsumerWidget {
  const _AuditLogsPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(adminStoreProvider);
    final logs = store.auditLogs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('Audit Logs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(
            width: 140,
            child: TextField(
              controller: TextEditingController(
                  text: store.auditRetentionDays.toString()),
              onChanged: (v) {
                final d = int.tryParse(v);
                if (d != null && d > 0) store.auditRetentionDays = d;
              },
              decoration: const InputDecoration(
                  labelText: 'Retention (days)', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
              onPressed: () {
                final csv = store.exportAuditCsv();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'CSV ready (${csv.length} chars). Implement save.')));
              },
              icon: const Icon(Icons.download),
              label: const Text('Export CSV')),
          const SizedBox(width: 8),
          FilledButton.icon(
              onPressed: () {
                store.addAudit('manual', 'Manual test entry');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add entry')),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
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
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: logs.length,
        ),
      ),
    ]);
  }
}

class _CategoriesManagementPage extends StatelessWidget {
  const _CategoriesManagementPage();

  @override
  Widget build(BuildContext context) {
    return const CategoriesManagementPage();
  }
}

class _HeroSectionsPage extends StatelessWidget {
  const _HeroSectionsPage();

  @override
  Widget build(BuildContext context) {
    return const HeroSectionsPage();
  }
}

class _AnalyticsDashboardPage extends StatelessWidget {
  const _AnalyticsDashboardPage();

  @override
  Widget build(BuildContext context) {
    return const AnalyticsDashboardPage();
  }
}

class _MediaStoragePage extends StatelessWidget {
  const _MediaStoragePage();

  @override
  Widget build(BuildContext context) {
    return const MediaStoragePage();
  }
}
