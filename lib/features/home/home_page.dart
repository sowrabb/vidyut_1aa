import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../../app/provider_registry.dart';
import '../../widgets/section_header.dart';
import 'widgets/hero_slideshow.dart';
import 'widgets/trusted_brands_strip.dart';
import 'widgets/categories_grid.dart';
import 'widgets/products_grid.dart';
import 'widgets/location_button.dart';
import '../admin/admin_shell.dart';
import '../admin/auth/admin_login_page.dart';
import '../search/search_page.dart';
import '../categories/categories_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationControllerProvider);

    // IMPORTANT: HomePage is hosted inside ResponsiveScaffold which already
    // provides the global navigation rail/bottom bar. So HomePage should use
    // a plain Scaffold here to avoid duplicating the nav. We still reuse the
    // rounded search header via VidyutAppBar.
    return Scaffold(
      appBar: VidyutAppBar(
        title: 'Vidyut',
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocationButton(
                city: location.city,
                state: location.stateName,
                radiusKm: location.radiusKm,
                area: location.area,
                onPicked: (res) => ref
                    .read(locationControllerProvider.notifier)
                    .setLocation(
                      city: res.city,
                      area: res.area,
                      stateName: res.state,
                      radiusKm: res.radiusKm,
                      mode: res.isAuto
                          ? LocationMode.auto
                          : LocationMode.manual,
                      latitude: res.latitude,
                      longitude: res.longitude,
                    ),
              ),
              if (context.isDesktop) ...[
                const SizedBox(width: 8),
                // OutlinedButton.icon(
                //   onPressed: () {
                //     Navigator.of(context).pushNamed('/auth-test');
                //   },
                //   icon: const Icon(Icons.bug_report),
                //   label: const Text('Firebase Test'),
                // ),
                // const SizedBox(width: 8),
                if (ref.watch(adminAuthServiceProvider).isLoggedIn)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminShell()),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Admin'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AdminLoginPage()),
                      );
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Admin Login'),
                  ),
              ]
            ],
          ),
        ),
        onSearch: (q) {
          if (q.trim().isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchPage(initialQuery: q.trim()),
            ),
          );
        },
      ),
      body: SafeArea(
        child: ContentClamp(
          child: CustomScrollView(
            slivers: [
              // Mobile: add full-width search below location
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    if (!context.isPhone) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search products...',
                        ),
                        onSubmitted: (q) {
                          if (q.trim().isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchPage(initialQuery: q.trim()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: HeroSlideshow()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TrustedBrandsStrip(),
                ),
              ),

              // Categories Section Header
              SliverToBoxAdapter(
                child: SectionHeader(
                  icon: Ionicons.grid_outline,
                  title: 'Categories',
                  actionText: 'View All Categories',
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                ),
              ),

              // Categories Grid
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CategoriesGrid(),
                ),
              ),

              // Products Section Header
              SliverToBoxAdapter(
                child: SectionHeader(
                  icon: Ionicons.cube_outline,
                  title: 'Frequently Bought Products',
                  actionText: 'Explore Products',
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                ),
              ),

              // Products Grid
              ProductsGrid(radiusKm: location.radiusKm),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // legacy prompt removed
}
