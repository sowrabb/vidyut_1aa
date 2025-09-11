import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/breakpoints.dart';
import '../../app/tokens.dart';
import 'store/seller_store.dart';
import '../../services/demo_data_service.dart';
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

class _SellHubShellState extends State<SellHubShell> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _navigationItems = [
    const _NavigationItem(
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      page: DashboardPage(),
      iconColor: Color(0xFF667EEA),
    ),
    const _NavigationItem(
      icon: Icons.analytics_outlined,
      label: 'Analytics',
      page: AnalyticsPage(),
      iconColor: Color(0xFF11998E),
    ),
    const _NavigationItem(
      icon: Icons.inventory_2_outlined,
      label: 'Products',
      page: ProductsListPage(),
      iconColor: Color(0xFFFF6B6B),
    ),
    const _NavigationItem(
      icon: Icons.people_outline,
      label: 'B2B Leads',
      page: LeadsPage(),
      iconColor: Color(0xFF4ECDC4),
    ),
    const _NavigationItem(
      icon: Icons.person_outline,
      label: 'Profile',
      page: ProfileSettingsPage(),
      iconColor: Color(0xFF88D8A3),
    ),
    const _NavigationItem(
      icon: Icons.card_membership_outlined,
      label: 'Subscription',
      page: SubscriptionPage(),
      iconColor: Color(0xFFFFB347),
    ),
    const _NavigationItem(
      icon: Icons.campaign_outlined,
      label: 'Ads',
      page: AdsPage(),
      iconColor: Color(0xFFE056FD),
    ),
    const _NavigationItem(
      icon: Icons.how_to_reg_outlined,
      label: 'Signup',
      page: SellerSignupPage(),
      iconColor: Color(0xFF74B9FF),
    ),
  ];


  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= AppBreakpoints.desktop;

    final shell = ChangeNotifierProvider(
      create: (context) => SellerStore(context.read<DemoDataService>()),
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
        title: const Text('Seller Hub'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Seller Hub',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                'Manage your business efficiently',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6, // Reduced height by ~35%
                    crossAxisSpacing: AppSpace.md,
                    mainAxisSpacing: AppSpace.md,
                  ),
                  itemCount: _navigationItems.length,
                  itemBuilder: (context, index) {
                    final item = _navigationItems[index];
                    return _SellerHubCard(
                      icon: item.icon,
                      label: item.label,
                      iconColor: item.iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => item.page,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;
  final Color iconColor;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
    required this.iconColor,
  });
}

class _SellerHubCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _SellerHubCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_SellerHubCard> createState() => _SellerHubCardState();
}

class _SellerHubCardState extends State<_SellerHubCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.textSecondary,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 36,
                          color: widget.iconColor,
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
