import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/app_state.dart';
import '../sell/models.dart';
import '../sell/store/seller_store.dart';
import 'search_store.dart';
import '../home/widgets/product_card.dart';
import '../sell/product_detail_page.dart';
import '../../app/tokens.dart';
import '../sell/seller_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final SearchMode? initialMode;
  const SearchPage({super.key, this.initialQuery, this.initialMode});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // SearchStore will be created in build method and synced there
  }

  @override
  Widget build(BuildContext context) {
    // Allow navigation from Home with initial query via RouteSettings.arguments
    final argQuery = ModalRoute.of(context)?.settings.arguments as String?;

    return ChangeNotifierProvider(
      create: (_) {
        final sellerStore = context.read<SellerStore>();
        final store = SearchStore(sellerStore.products);
        // Sync location from AppState
        final appState = context.read<AppState>();
        store.setGeo(
          city: appState.city,
          state: appState.state,
          radiusKm: appState.radiusKm,
        );
        if (widget.initialMode != null) {
          store.setMode(widget.initialMode!);
        }
        final initQ = widget.initialQuery ?? argQuery;
        if ((initQ ?? '').isNotEmpty) {
          store.setQuery(initQ!);
        }
        return store;
      },
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: ContentClamp(
              child: LayoutBuilder(
                builder: (context, bc) {
                  final isDesktop = bc.maxWidth >= AppBreaks.desktop;
                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: _SearchBar()),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      if (isDesktop)
                        const SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 280,
                                child: _FiltersPanel(sticky: true),
                              ),
                              SizedBox(width: 16),
                              Expanded(child: _ResultsGrid()),
                            ],
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () => _openFiltersSheet(context),
                                  icon: const Icon(Icons.tune),
                                  label: const Text('Filters'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _ResultsGrid(),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: _FiltersPanel(),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final store = context.read<SearchStore>();
    return ResponsiveRow(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by brand, spec, materials...',
          ),
          onChanged: store.setQuery,
          onSubmitted: store.setQuery,
        ),
        Selector<SearchStore, SearchMode>(
          selector: (_, s) => s.mode,
          builder: (_, mode, __) => SegmentedButton<SearchMode>(
            segments: const [
              ButtonSegment(
                  value: SearchMode.products, label: Text('Products')),
              ButtonSegment(
                  value: SearchMode.profiles,
                  label: Text('Profiles using material')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => store.setMode(s.first),
          ),
        ),
        DropdownButtonFormField<SortBy>(
          value: context.watch<SearchStore>().sortBy,
          items: const [
            DropdownMenuItem(value: SortBy.relevance, child: Text('Relevance')),
            DropdownMenuItem(
                value: SortBy.priceAsc, child: Text('Price: Low to High')),
            DropdownMenuItem(
                value: SortBy.priceDesc, child: Text('Price: High to Low')),
            DropdownMenuItem(value: SortBy.distance, child: Text('Distance')),
          ],
          onChanged: (v) => store.setSort(v ?? SortBy.relevance),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
          isExpanded: true, // Make dropdown expand to fill available space
        ),
      ],
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final bool sticky;
  const _FiltersPanel({this.sticky = false});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SearchStore>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Category
        Text('Category', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in kCategories)
              FilterChip(
                label: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: store.selectedCategories.contains(c),
                onSelected: (_) => store.toggleCategory(c),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Materials
        Text('Materials Used', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in kMaterials)
              FilterChip(
                label: Text(m, maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: store.selectedMaterials.contains(m),
                onSelected: (_) => store.toggleMaterial(m),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Price
        Text('Price (₹)', style: Theme.of(context).textTheme.titleSmall),
        RangeSlider(
          values: RangeValues(store.priceStart, store.priceEnd),
          min: 0,
          max: 50000,
          divisions: 50,
          labels: RangeLabels('₹${store.priceStart.toStringAsFixed(0)}',
              '₹${store.priceEnd.toStringAsFixed(0)}'),
          onChanged: (v) => store.setPriceRange(v.start, v.end),
        ),
        const SizedBox(height: 16),

        // Location context (read-only summary; change via AppBar button in Home)
        Row(
          children: [
            const Icon(Icons.public, size: 18),
            const SizedBox(width: 6),
            Expanded(
                child: Text(
                    '${store.city}, ${store.state} • within ${store.radiusKm.toStringAsFixed(0)} km',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).maybePop(), // just close when in sheet
          icon: const Icon(Icons.check),
          label: const Text('Apply'),
        ),
      ],
    );

    if (!sticky) return content;
    return SingleChildScrollView(child: content);
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SearchStore>();
    if (store.mode == SearchMode.profiles) {
      final profiles = store.profilesResults;
      if (profiles.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No matching profiles.')),
        );
      }
      return ResponsiveRow(
        desktop: 2,
        tablet: 2,
        phone: 1,
        children: [
          for (final p in profiles)
            _B2BProfileCard(
              name: p.name,
              materials: p.materials,
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SellerPage(sellerName: p.name),
                  ),
                );
              },
            ),
        ],
      );
    }

    final list = store.results;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('No results. Try adjusting filters.')),
      );
    }

    return LayoutBuilder(
      builder: (_, bc) {
        // Use same visual density as home products grid
        final w = bc.maxWidth;
        final isDesktop = w >= AppBreaks.desktop;
        final isTablet = w >= AppBreaks.tablet && w < AppBreaks.desktop;
        final crossAxisExtent =
            isDesktop ? AppLayout.productCardMax : (isTablet ? 300.0 : 280.0);
        final childAspect = isDesktop ? 0.80 : 0.74;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: crossAxisExtent,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspect,
          ),
          itemBuilder: (_, i) {
            return ProductCard.demo(
              index: i,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: list[i]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _B2BProfileCard extends StatelessWidget {
  final String name;
  final List<String> materials;
  final VoidCallback onOpen;
  const _B2BProfileCard(
      {required this.name, required this.materials, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.thumbBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.business,
                      color: AppColors.textSecondary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name,
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 12),
              if (materials.isNotEmpty) ...[
                Text('Materials Used',
                    style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: materials
                      .take(4)
                      .map((m) => Chip(
                            label: Text(m),
                            backgroundColor: AppColors.primarySurface,
                            labelStyle: const TextStyle(
                                color: AppColors.primary, fontSize: 12),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Profile'))),
                const SizedBox(width: 8),
                Expanded(
                    child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Quote'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
