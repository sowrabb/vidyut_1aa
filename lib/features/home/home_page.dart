import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/app_state.dart';
import 'widgets/hero_slideshow.dart';
import 'widgets/trusted_brands_strip.dart';
import 'widgets/categories_grid.dart';
import 'widgets/products_grid.dart';
import 'widgets/location_button.dart';
import '../admin/admin_shell.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
                city: appState.city,
                state: appState.state,
                radiusKm: appState.radiusKm,
                area: appState.area,
                onPicked: (res) => appState.setLocation(
                  city: res.city,
                  area: res.area,
                  state: res.state,
                  radiusKm: res.radiusKm,
                  mode: res.isAuto ? LocationMode.auto : LocationMode.manual,
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
                if (appState.isAdmin)
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
                      _promptAdmin(context, appState);
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CategoriesGrid(),
                ),
              ),
              ProductsGrid(radiusKm: appState.radiusKm),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void _promptAdmin(BuildContext context, AppState appState) {
    final code = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Admin Login'),
      content: SizedBox(width: 360, child: TextField(controller: code, obscureText: true, decoration: const InputDecoration(labelText: 'Access Code', border: OutlineInputBorder()))),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: (){
          if (code.text.trim() == 'admin123') {
            appState.setAdmin(true);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin mode enabled')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code')));
          }
        }, child: const Text('Unlock')),
      ],
    ));
  }
}
