import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../../app/provider_registry.dart';
import '../../widgets/section_header.dart';
import 'widgets/hero_slideshow.dart';
import 'widgets/trusted_brands_strip.dart';
import 'widgets/categories_grid_v2.dart';
import 'widgets/products_grid_v2.dart';
import 'widgets/location_button.dart';
import '../admin/admin_shell.dart';
import '../admin/auth/admin_login_page.dart';
import '../search/search_page_v2.dart';
import '../categories/categories_page.dart';

class HomePageV2 extends ConsumerStatefulWidget {
  const HomePageV2({super.key});

  @override
  ConsumerState<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends ConsumerState<HomePageV2> {
  @override
  Widget build(BuildContext context) {
    // final session = ref.watch(sessionProvider); // Not used in this widget
    final rbac = ref.watch(rbacProvider);
    final locationPrefs = ref.watch(locationProvider);

    return Scaffold(
      appBar: VidyutAppBar(
        title: 'Vidyut',
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocationButton(
                city: locationPrefs.selectedRegion,
                state: locationPrefs.selectedRegion,
                radiusKm: locationPrefs.radiusKm,
                area: null,
                onPicked: (res) {
                  ref.read(locationProvider.notifier).updateRegion(
                    res.city,
                    latitude: res.latitude,
                    longitude: res.longitude,
                  );
                  ref.read(locationProvider.notifier).updateRadius(res.radiusKm);
                },
              ),
              if (context.isDesktop) ...[
                const SizedBox(width: 8),
                if (rbac.can('admin.access'))
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
          // Update search query provider
          ref.read(searchQueryProvider.notifier).state = SearchQuery(
            query: q.trim(),
            categories: [],
            filters: {},
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchPageV2(initialQuery: q.trim()),
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
                          // Update search query provider
                          ref.read(searchQueryProvider.notifier).state = SearchQuery(
                            query: q.trim(),
                            categories: [],
                            filters: {},
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchPageV2(initialQuery: q.trim()),
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

              // Categories Grid (using new provider)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CategoriesGridV2(),
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

              // Products Grid (using new provider)
              ProductsGridV2(radiusKm: locationPrefs.radiusKm),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
