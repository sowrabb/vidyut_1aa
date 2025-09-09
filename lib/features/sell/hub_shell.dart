import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/breakpoints.dart';
import 'store/seller_store.dart';
import 'ads_page.dart';
import 'signup_page.dart';
import 'products_list_page.dart';
import 'leads_page.dart';
import 'profile_settings_page.dart';
import 'subscription_page.dart';
import 'dashboard_page.dart';
import 'analytics_page.dart';

class SellHubShell extends StatefulWidget {
  final bool adminOverride;
  final String? overrideSellerName;
  const SellHubShell({super.key, this.adminOverride = false, this.overrideSellerName});

  @override
  State<SellHubShell> createState() => _SellHubShellState();
}

class _SellHubShellState extends State<SellHubShell>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  final List<_NavigationItem> _navigationItems = [
    const _NavigationItem(
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      page: DashboardPage(),
    ),
    const _NavigationItem(
      icon: Icons.analytics_outlined,
      label: 'Analytics',
      page: AnalyticsPage(),
    ),
    const _NavigationItem(
      icon: Icons.inventory_2_outlined,
      label: 'Products',
      page: ProductsListPage(),
    ),
    const _NavigationItem(
      icon: Icons.people_outline,
      label: 'B2B Leads',
      page: LeadsPage(),
    ),
    const _NavigationItem(
      icon: Icons.person_outline,
      label: 'Profile',
      page: ProfileSettingsPage(),
    ),
    const _NavigationItem(
      icon: Icons.card_membership_outlined,
      label: 'Subscription',
      page: SubscriptionPage(),
    ),
    const _NavigationItem(
      icon: Icons.campaign_outlined,
      label: 'Ads',
      page: AdsPage(),
    ),
    const _NavigationItem(
      icon: Icons.how_to_reg_outlined,
      label: 'Signup',
      page: SellerSignupPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _navigationItems.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= AppBreakpoints.desktop;

    final shell = ChangeNotifierProvider(
      create: (context) => SellerStore(),
      child: Scaffold(
        appBar: widget.adminOverride ? AppBar(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade900,
          title: Text('Admin override — ${widget.overrideSellerName ?? 'Seller'}'),
        ) : null,
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
    return shell;
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: _navigationItems.map((item) {
            return NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.icon),
              label: Text(item.label),
            );
          }).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: _navigationItems[_selectedIndex].page,
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _navigationItems
              .map((item) => Tab(icon: Icon(item.icon), text: item.label))
              .toList(),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _navigationItems.map((n) => n.page).toList(),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}
