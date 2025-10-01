import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_page_v2.dart';
import '../features/search/search_page_v2.dart';
import '../features/messaging/messaging_page_v2.dart';
import '../features/profile/user_profile_page.dart';
import '../features/admin/admin_dashboard_v2.dart';
import '../../../app/provider_registry.dart';

class MainAppV2 extends ConsumerWidget {
  const MainAppV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveScaffoldV2(
        initialIndex: 0,
      ),
    );
  }
}

class ResponsiveScaffoldV2 extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const ResponsiveScaffoldV2({super.key, required this.initialIndex});

  @override
  ConsumerState<ResponsiveScaffoldV2> createState() => _ResponsiveScaffoldV2State();
}

class _ResponsiveScaffoldV2State extends ConsumerState<ResponsiveScaffoldV2> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;
        
        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Navigation Rail
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: _getNavigationDestinations().map((dest) => NavigationRailDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
          )).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Main Content
        Expanded(
          child: _getPage(_currentIndex),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: _getNavigationDestinations(),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.1),
          elevation: 8,
          indicatorColor: Colors.blue.withOpacity(0.2),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations() {
    final session = ref.watch(sessionControllerProvider);
    final rbac = ref.watch(rbacProvider);
    
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: 'Search',
      ),
    ];
    
    if (session.isAuthenticated) {
      destinations.addAll([
        const NavigationDestination(
          icon: Icon(Icons.message_outlined),
          selectedIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ]);
    }
    
    if (rbac.can('admin.access')) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    
    return destinations;
  }

  Widget _getPage(int index) {
    final session = ref.watch(sessionControllerProvider);
    final rbac = ref.watch(rbacProvider);
    
    // Adjust index based on available pages
    int adjustedIndex = index;
    
    if (!session.isAuthenticated && index >= 2) {
      adjustedIndex = 0; // Default to Home if not logged in
    }
    
    final destinations = _getNavigationDestinations();
    if (!rbac.can('admin.access') && index == destinations.length - 1) {
      adjustedIndex = 0; // Default to Home if no admin access
    }
    
    switch (adjustedIndex) {
      case 0:
        return const HomePageV2();
      case 1:
        return const SearchPageV2();
      case 2:
        if (session.isAuthenticated) {
          return const MessagingPageV2();
        }
        return const HomePageV2();
      case 3:
        if (session.isAuthenticated) {
          return const UserProfilePage();
        }
        return const HomePageV2();
      case 4:
        if (rbac.can('admin.access')) {
          return const AdminDashboardV2();
        }
        return const HomePageV2();
      default:
        return const HomePageV2();
    }
  }
}
