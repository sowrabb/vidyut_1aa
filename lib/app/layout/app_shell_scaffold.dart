import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../tokens.dart';
import '../breakpoints.dart';
import 'responsive_scaffold.dart';
import '../../widgets/auto_hide_scaffold.dart';
import '../../features/about/about_page.dart';

class AppShellScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int selectedIndex;
  const AppShellScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.selectedIndex = 0,
  });

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

    // Map visible destination positions to page indices in ResponsiveScaffold
    final List<int> indexMap = isDesktop
        ? [0, 1, 2, 3, 4, 5, 6]
        : [0, 1, 4, 5, 6]; // Home, Search, Sell, State, Profile

    void goToRoot(int i) {
      final actualIndex = indexMap[i];
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => ResponsiveScaffold(initialIndex: actualIndex)),
        (route) => false,
      );
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: goToRoot,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              destinations: const [
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
                  icon: Icon(Ionicons.chatbubble_ellipses_outline),
                  selectedIcon: Icon(Ionicons.chatbubble_ellipses),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Ionicons.grid_outline),
                  selectedIcon: Icon(Ionicons.grid),
                  label: Text('Categories'),
                ),
                NavigationRailDestination(
                  icon: Icon(Ionicons.storefront_outline),
                  selectedIcon: Icon(Ionicons.storefront),
                  label: Text('Sell'),
                ),
                NavigationRailDestination(
                  icon: Icon(Ionicons.earth_outline),
                  selectedIcon: Icon(Ionicons.earth),
                  label: Text('State info'),
                ),
                NavigationRailDestination(
                  icon: Icon(Ionicons.person_circle_outline),
                  selectedIcon: Icon(Ionicons.person_circle),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(child: body),
          ],
        ),
      );
    }

    // For mobile, map the selectedIndex to the correct position in the filtered destinations
    final mobileSelectedIndex =
        isDesktop ? selectedIndex : indexMap.indexOf(selectedIndex);

    return AutoHideScaffold(
      backgroundColor: AppColors.surface,
      appBar: appBar,
      body: body,
      enableAutoHide: false, // Disable auto-hide animation for sticky nav bar
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: mobileSelectedIndex == -1 ? 0 : mobileSelectedIndex,
            onDestinationSelected: goToRoot,
            destinations: destinations,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primary.withOpacity(0.4),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}

class VidyutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final ValueChanged<String>? onSearch;
  const VidyutAppBar(
      {super.key, required this.title, this.trailing, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 6);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width >= AppBreakpoints.desktop;
    const double logoSize = 48; // 2x from previous 24
    final double toolbarHeight =
        (logoSize + 24).clamp(kToolbarHeight, double.infinity);

    Widget buildLogoTitle() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.png',
            width: logoSize,
            height: logoSize,
            errorBuilder: (_, __, ___) =>
                const SizedBox(width: logoSize, height: logoSize),
          ),
          const SizedBox(width: 10),
          const Text('VidyutNidhi'),
        ],
      );
    }

    final searchField = TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Search products...',
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        prefixIcon: const Icon(Ionicons.search_outline),
      ),
    );

    return AppBar(
      titleSpacing: 5,
      toolbarHeight: toolbarHeight,
      centerTitle: false,
      title: isDesktop
          ? Row(
              children: [
                buildLogoTitle(),
                const SizedBox(width: 12),
                Flexible(
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: searchField,
                    ),
                  ),
                ),
              ],
            )
          : buildLogoTitle(),
      actions: [
        if (isDesktop)
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
            child: const Text('About Us'),
          ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: trailing!,
          ),
      ],
    );
  }
}
