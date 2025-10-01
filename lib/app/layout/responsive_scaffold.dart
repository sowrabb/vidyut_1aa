import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tokens.dart';
import '../../features/home/home_page.dart';
import '../../features/search/search_page.dart';
import '../../features/categories/categories_page.dart';
import '../../features/messaging/messaging_pages.dart';
import '../../../app/provider_registry.dart';
import '../../features/sell/sell_hub_page.dart';
import '../../widgets/notification_badge.dart';
import '../../features/stateinfo/state_info_page.dart';
import '../../features/profile/profile_page.dart';
import '../breakpoints.dart';
import '../../widgets/auto_hide_scaffold.dart';

enum AppDest { home, search, messages, categories, sell, stateInfo, profile }

// Route names for deep linking
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String messages = '/messages';
  static const String categories = '/categories';
  static const String sell = '/sell';
  static const String stateInfo = '/state-info';
  static const String profile = '/profile';

  static const Map<String, int> routeToIndex = {
    home: 0,
    search: 1,
    messages: 2,
    categories: 3,
    sell: 4,
    stateInfo: 5,
    profile: 6,
  };

  static String getRouteFromIndex(int index) {
    return routeToIndex.entries.firstWhere((e) => e.value == index).key;
  }
}

class ResponsiveScaffold extends ConsumerStatefulWidget {
  final int initialIndex;
  const ResponsiveScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  int index = 0;
  final Map<String, Widget> _pageCache = {};

  Widget _getPage(int pageIndex) {
    final cacheKey = 'page_$pageIndex';
    if (_pageCache.containsKey(cacheKey)) {
      return _pageCache[cacheKey]!;
    }

    Widget page;
    switch (pageIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const SearchPage();
        break;
      case 2:
        page = const MessagingPage();
        break;
      case 3:
        page = const CategoriesPage();
        break;
      case 4:
        page = const SellHubPage();
        break;
      case 5:
        page = const StateInfoPage();
        break;
      case 6:
        page = const ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    _pageCache[cacheKey] = page;
    return page;
  }

  @override
  void dispose() {
    // Clear page cache to prevent memory leaks
    _pageCache.clear();
    super.dispose();
  }

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

    // Preserve current index when switching between desktop and mobile
    if (!isDesktop && index > 1 && index < 4) {
      // If on Messages (2) or Categories (3) and switching to mobile, go to Sell (4)
      index = 4;
    }

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
                const NavigationRailDestination(
                  icon: Icon(Ionicons.home_outline),
                  selectedIcon: Icon(Ionicons.home),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Ionicons.search_outline),
                  selectedIcon: Icon(Ionicons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Consumer(
                    builder: (context, ref, child) {
                      final count =
                          ref.watch(messagingStoreProvider).unreadCount;
                      return NotificationBadge(
                        count: count,
                        child: const Icon(Ionicons.chatbubble_ellipses_outline),
                      );
                    },
                  ),
                  selectedIcon: Consumer(
                    builder: (context, ref, child) {
                      final count =
                          ref.watch(messagingStoreProvider).unreadCount;
                      return NotificationBadge(
                        count: count,
                        child: const Icon(Ionicons.chatbubble_ellipses),
                      );
                    },
                  ),
                  label: const Text('Messages'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Ionicons.grid_outline),
                  selectedIcon: Icon(Ionicons.grid),
                  label: Text('Categories'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Ionicons.storefront_outline),
                  selectedIcon: Icon(Ionicons.storefront),
                  label: Text('Sell'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Ionicons.earth_outline),
                  selectedIcon: Icon(Ionicons.earth),
                  label: Text('State info'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Ionicons.person_circle_outline),
                  selectedIcon: Icon(Ionicons.person_circle),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(child: _getPage(index)),
          ],
        ),
      );
    }

    // Mobile/tablet
    final selectedPos = indexMap.indexOf(index);
    return AutoHideScaffold(
      backgroundColor: AppColors.surface,
      body: _getPage(index),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: selectedPos == -1 ? 0 : selectedPos,
          onDestinationSelected: (i) => setState(() => index = indexMap[i]),
          destinations: destinations,
        ),
      ),
    );
  }
}
