import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../tokens.dart';
import '../../features/home/home_page.dart';
import '../../features/search/search_page.dart';
import '../../features/categories/categories_page.dart';
import '../../features/messaging/messaging_pages.dart';
import '../../features/messaging/messaging_store.dart';
import '../../features/sell/sell_hub_page.dart';
import '../../widgets/notification_badge.dart';
import '../../services/demo_data_service.dart';
import '../../features/stateinfo/state_info_page.dart';
import '../../features/profile/profile_page.dart';
import '../breakpoints.dart';
import '../../widgets/auto_hide_scaffold.dart';

enum AppDest { home, search, messages, categories, sell, stateInfo, profile }

class ResponsiveScaffold extends StatefulWidget {
  final int initialIndex;
  const ResponsiveScaffold({super.key, this.initialIndex = 0});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int index = 0;

  List<Widget> get _pages => [
        const HomePage(),
        const SearchPage(),
        ChangeNotifierProvider(
          create: (context) => MessagingStore(context.read<DemoDataService>()),
          child: const MessagingPage(),
        ),
        const CategoriesPage(),
        const SellHubPage(),
        const StateInfoPage(),
        const ProfilePage(),
      ];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Ionicons.home_outline),
        selectedIcon: Icon(Ionicons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Ionicons.search_outline),
        selectedIcon: Icon(Ionicons.search),
        label: 'Search',
      ),
      if (isDesktop)
        const NavigationDestination(
          icon: Icon(Ionicons.chatbubble_ellipses_outline),
          selectedIcon: Icon(Ionicons.chatbubble_ellipses),
          label: 'Messages',
        ),
      if (isDesktop)
        const NavigationDestination(
          icon: Icon(Ionicons.grid_outline),
          selectedIcon: Icon(Ionicons.grid),
          label: 'Categories',
        ),
      const NavigationDestination(
        icon: Icon(Ionicons.storefront_outline),
        selectedIcon: Icon(Ionicons.storefront),
        label: 'Sell',
      ),
      const NavigationDestination(
        icon: Icon(Ionicons.earth_outline),
        selectedIcon: Icon(Ionicons.earth),
        label: 'State info',
      ),
      const NavigationDestination(
        icon: Icon(Ionicons.person_circle_outline),
        selectedIcon: Icon(Ionicons.person_circle),
        label: 'Profile',
      ),
    ];

    // Map visible destination positions to page indices in _pages
    final List<int> indexMap = isDesktop
        ? [0, 1, 2, 3, 4, 5, 6]
        : [0, 1, 4, 5, 6]; // Home, Search, Sell, State, Profile

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Ionicons.home_outline),
                  selectedIcon: Icon(Ionicons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Ionicons.search_outline),
                  selectedIcon: Icon(Ionicons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Consumer<MessagingStore>(
                    builder: (context, messagingStore, child) {
                      return NotificationBadge(
                        count: messagingStore.unreadCount,
                        child: const Icon(Ionicons.chatbubble_ellipses_outline),
                      );
                    },
                  ),
                  selectedIcon: Consumer<MessagingStore>(
                    builder: (context, messagingStore, child) {
                      return NotificationBadge(
                        count: messagingStore.unreadCount,
                        child: const Icon(Ionicons.chatbubble_ellipses),
                      );
                    },
                  ),
                  label: const Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Ionicons.grid_outline),
                  selectedIcon: const Icon(Ionicons.grid),
                  label: const Text('Categories'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Ionicons.storefront_outline),
                  selectedIcon: const Icon(Ionicons.storefront),
                  label: const Text('Sell'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Ionicons.earth_outline),
                  selectedIcon: const Icon(Ionicons.earth),
                  label: const Text('State info'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Ionicons.person_circle_outline),
                  selectedIcon: const Icon(Ionicons.person_circle),
                  label: const Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(child: _pages[index]),
          ],
        ),
      );
    }

    // Mobile/tablet
    final selectedPos = indexMap.indexOf(index);
    return AutoHideScaffold(
      backgroundColor: AppColors.surface,
      body: _pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPos == -1 ? 0 : selectedPos,
        onDestinationSelected: (i) => setState(() => index = indexMap[i]),
        destinations: destinations,
      ),
    );
  }
}
