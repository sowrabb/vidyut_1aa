import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../app/breakpoints.dart';
import '../../app/app_state.dart';
import '../../services/demo_data_service.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/responsive_category_card.dart';
import 'categories_store.dart';
import 'category_detail_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoriesStore(context.read<AppState>(), context.read<DemoDataService>()),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: ContentClamp(
              child: LayoutBuilder(
                builder: (context, bc) {
                  final isDesktop = bc.maxWidth >= AppBreakpoints.desktop;
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
                              Expanded(child: _CategoriesGrid()),
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
                              const _CategoriesGrid(),
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
    final store = context.read<CategoriesStore>();
    return ResponsiveRow(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search categories...',
          ),
          onChanged: store.setQuery,
        ),
        DropdownButtonFormField<CategorySortBy>(
          value: context.watch<CategoriesStore>().sortBy,
          items: const [
            DropdownMenuItem(
                value: CategorySortBy.name, child: Text('Name A-Z')),
            DropdownMenuItem(
                value: CategorySortBy.nameDesc, child: Text('Name Z-A')),
            DropdownMenuItem(
                value: CategorySortBy.popularity, child: Text('Most Popular')),
          ],
          onChanged: (v) => store.setSort(v ?? CategorySortBy.name),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
          isExpanded: true,
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
    final store = context.watch<CategoriesStore>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Industry
        Text('Industry', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final industry in kIndustries)
              FilterChip(
                label: Text(industry,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: store.selectedIndustries.contains(industry),
                onSelected: (_) => store.toggleIndustry(industry),
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
            for (final material in kMaterials)
              FilterChip(
                label: Text(material,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: store.selectedMaterials.contains(material),
                onSelected: (_) => store.toggleMaterial(material),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Clear filters button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: store.clearFilters,
            child: const Text('Clear All Filters'),
          ),
        ),
      ],
    );

    return sticky ? content : content;
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CategoriesStore>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ResponsiveGrid(
        gridType: ResponsiveGridType.category,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: store.filteredCategories.map((category) {
          return ResponsiveCategoryCard(
            category: category,
            onTap: () => _navigateToCategory(context, category),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, CategoryData category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(category: category),
      ),
    );
  }
}

// Category data model
class CategoryData {
  final String name;
  final String imageUrl;
  final int productCount;
  final List<String> industries;
  final List<String> materials;

  const CategoryData({
    required this.name,
    required this.imageUrl,
    required this.productCount,
    required this.industries,
    required this.materials,
  });
}

// Sort options for categories
enum CategorySortBy { name, nameDesc, popularity }

// Demo industries
const kIndustries = [
  'Construction',
  'EPC',
  'MEP',
  'Solar',
  'Industrial',
  'Commercial',
  'Residential',
  'Infrastructure',
];

// Demo materials (reusing from existing)
const kMaterials = [
  'Copper',
  'Aluminium',
  'PVC',
  'XLPE',
  'Steel',
  'Iron',
  'Plastic',
  'Rubber',
  'Glass',
  'Ceramic',
];
