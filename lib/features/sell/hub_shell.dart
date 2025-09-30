import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/breakpoints.dart';
import '../../app/tokens.dart';
// providers accessed via app/provider_registry.dart where needed
import 'ads_page.dart';
import 'signup_page.dart';
import 'products_list_page.dart';
import 'leads_page.dart';
import 'profile_settings_page.dart';
import 'subscription_page.dart';
import 'dashboard_page.dart';
import 'analytics_page.dart';

class SellHubShell extends ConsumerStatefulWidget {
  final bool adminOverride;
  final String? overrideSellerName;
  const SellHubShell(
      {super.key, this.adminOverride = false, this.overrideSellerName});

  @override
  ConsumerState<SellHubShell> createState() => _SellHubShellState();
}

class _SellHubShellState extends ConsumerState<SellHubShell> {
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

    final shell = Scaffold(
      appBar: widget.adminOverride
          ? AppBar(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade900,
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Admin override — ${widget.overrideSellerName ?? 'Seller'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _MetaChip(
                      label: 'Role: Seller', color: Color(0xFF1565C0)),
                  const SizedBox(width: 4),
                  const _MetaChip(label: 'Plan: Pro', color: Color(0xFF6A1B9A)),
                  const SizedBox(width: 4),
                  const _MetaChip(
                      label: 'Status: Active', color: Color(0xFF2E7D32)),
                ],
              ),
            )
          : null,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
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

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
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
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          size: 32, // Reduced size to prevent overflow
                          color: widget.iconColor,
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Flexible(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14, // Reduced font size
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
