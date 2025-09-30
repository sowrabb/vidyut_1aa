import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../app/breakpoints.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/responsive_category_card.dart';
import '../../widgets/multi_select_dropdown.dart';
import 'categories_notifier.dart';
import 'category_detail_page.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(categoriesNotifierProvider.notifier);
    final state = ref.watch(categoriesNotifierProvider);
    return ResponsiveRow(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search categories...',
          ),
          onChanged: notifier.setQuery,
        ),
        DropdownButtonFormField<CategorySortBy>(
          value: state.sortBy,
          items: const [
            DropdownMenuItem(
                value: CategorySortBy.name, child: Text('Name A-Z')),
            DropdownMenuItem(
                value: CategorySortBy.nameDesc, child: Text('Name Z-A')),
            DropdownMenuItem(
                value: CategorySortBy.popularity, child: Text('Most Popular')),
          ],
          onChanged: (v) => notifier.setSort(v ?? CategorySortBy.name),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
          isExpanded: true,
        ),
      ],
    );
  }
}

class _FiltersPanel extends ConsumerWidget {
  final bool sticky;
  const _FiltersPanel({this.sticky = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesNotifierProvider);
    final notifier = ref.read(categoriesNotifierProvider.notifier);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Industry (multi-select dropdown)
        Text('Industry', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        MultiSelectDropdown<String>(
          options: kIndustries,
          value: state.selectedIndustries.toList(),
          onChanged: (list) {
            for (final i in kIndustries) {
              final selected = list.contains(i);
              final has = state.selectedIndustries.contains(i);
              if (selected && !has) notifier.toggleIndustry(i);
              if (!selected && has) notifier.toggleIndustry(i);
            }
          },
          itemLabel: (s) => s,
          hintText: 'Select industries',
          showChipsInField: false,
        ),
        const SizedBox(height: 16),

        // Materials (multi-select dropdown)
        Text('Materials Used', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        MultiSelectDropdown<String>(
          options: kMaterials,
          value: state.selectedMaterials.toList(),
          onChanged: (list) {
            for (final m in kMaterials) {
              final selected = list.contains(m);
              final has = state.selectedMaterials.contains(m);
              if (selected && !has) notifier.toggleMaterial(m);
              if (!selected && has) notifier.toggleMaterial(m);
            }
          },
          itemLabel: (s) => s,
          hintText: 'Select materials',
          showChipsInField: false,
        ),
        const SizedBox(height: 16),

        // Clear filters button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: notifier.clearFilters,
            child: const Text('Clear All Filters'),
          ),
        ),
      ],
    );

    return sticky ? content : content;
  }
}

class _CategoriesGrid extends ConsumerWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ResponsiveGrid(
        gridType: ResponsiveGridType.category,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: state.filteredCategories.map((category) {
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
