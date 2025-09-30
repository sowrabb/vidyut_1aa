import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../../widgets/responsive_grid.dart';
import 'category_detail_page.dart';

class CategoriesPageV2 extends ConsumerWidget {
  const CategoriesPageV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
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
    return ResponsiveRow(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search categories...',
          ),
          onChanged: (query) {
            // TODO: Implement category search
          },
        ),
        DropdownButtonFormField<String>(
          value: 'name',
          items: const [
            DropdownMenuItem(value: 'name', child: Text('Name')),
            DropdownMenuItem(value: 'popularity', child: Text('Popularity')),
          ],
          onChanged: (value) {
            // TODO: Implement sorting
          },
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        
        // Industry filter
        Text('Industry', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Construction', 'Manufacturing', 'EPC'].map((industry) {
            return FilterChip(
              label: Text(industry),
              selected: false,
              onSelected: (selected) {
                // TODO: Implement industry filter
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Materials filter
        Text('Materials', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Copper', 'PVC', 'Aluminium'].map((material) {
            return FilterChip(
              label: Text(material),
              selected: false,
              onSelected: (selected) {
                // TODO: Implement materials filter
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.check),
          label: const Text('Apply'),
        ),
      ],
    );

    if (!sticky) return content;
    return SingleChildScrollView(child: content);
  }
}

class _CategoriesGrid extends ConsumerWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (categoryTree) {
        final categories = categoryTree.getRootCategories();
        
        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('No categories available.')),
          );
        }

        return ResponsiveRow(
          desktop: 3,
          tablet: 2,
          phone: 1,
          children: categories.map((category) => _CategoryCard(
            category: category,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryDetailPage(category: category),
                ),
              );
            },
          )).toList(),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.thumbBg,
                  image: DecorationImage(
                    image: NetworkImage(category.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image load error
                    },
                  ),
                ),
                child: category.imageUrl.isEmpty
                    ? const Icon(Icons.category, color: AppColors.textSecondary, size: 48)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.productCount} products',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (category.industries.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: category.industries.take(3).map((industry) {
                    return Chip(
                      label: Text(industry),
                      backgroundColor: AppColors.primarySurface,
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

