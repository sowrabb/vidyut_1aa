import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../app/breakpoints.dart';
import '../../app/app_state.dart';
import '../search/search_store.dart';
import '../sell/models.dart';
import '../sell/store/seller_store.dart';
import '../sell/product_detail_page.dart';
import '../../widgets/responsive_product_grid.dart';
import 'categories_page.dart' hide kMaterials;

class CategoryDetailPage extends StatelessWidget {
  final CategoryData category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        // Use real products from SellerStore
        final sellerStore = context.read<SellerStore>();
        final appState = context.read<AppState>();
        final store = SearchStore(sellerStore.products, appState);

        // Pre-select this category
        store.selectedCategories.add(category.name);
        
        return store;
      },
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(category.name),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          body: SafeArea(
            child: ContentClamp(
              child: LayoutBuilder(
                builder: (context, bc) {
                  final isDesktop = bc.maxWidth >= AppBreakpoints.desktop;
                  return CustomScrollView(
                    slivers: [
                      // Category header
                      SliverToBoxAdapter(
                        child: _CategoryHeader(category: category),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Search bar
                      const SliverToBoxAdapter(child: _SearchBar()),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),

                      if (isDesktop)
                        SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 280,
                                child: _FiltersPanel(sticky: true),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _ResultsGrid(category: category)),
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
                              _ResultsGrid(category: category),
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

  List<Product> _generateDemoProductsForCategory(CategoryData category) {
    final products = <Product>[];
    final random = Random(42);

    for (int i = 0; i < 20; i++) {
      products.add(Product(
        id: '${category.name}_${i + 1}',
        title: '${category.name} Product ${i + 1}',
        brand: i.isEven ? 'Philips' : 'Schneider',
        category: category.name,
        subtitle: 'Spec ${i + 1}',
        price: 300 + i * 120.0,
        moq: 10,
        gstRate: 18,
        materials: category.materials.isNotEmpty
            ? [category.materials[i % category.materials.length]]
            : ['General'],
        status: i % 5 == 0 ? ProductStatus.draft : ProductStatus.active,
        rating: (random.nextDouble() * 2) + 3, // 3..5
      ));
    }

    return products;
  }
}

class _CategoryHeader extends StatelessWidget {
  final CategoryData category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Category image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(category.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: category.imageUrl.isEmpty
                  ? const Icon(
                      Icons.category,
                      size: 40,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.productCount} products available',
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Industries
                  if (category.industries.isNotEmpty) ...[
                    Text(
                      'Industries:',
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: category.industries
                          .take(3)
                          .map(
                            (industry) => Chip(
                              label: Text(industry),
                              backgroundColor: AppColors.primarySurface,
                              labelStyle: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
            hintText: 'Search products in this category...',
          ),
          onChanged: store.setQuery,
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
    final store = context.watch<SearchStore>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

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

class _ResultsGrid extends StatelessWidget {
  final CategoryData category;
  
  const _ResultsGrid({required this.category});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SearchStore>();

    // Convert to ProductCardData
    final productCards = store.results.map((product) {
      return ProductCardData(
        productId: product.id,
        title: product.title,
        brand: product.brand,
        price: '₹${product.price.toStringAsFixed(0)}',
        subtitle: product.subtitle,
        imageUrl: 'https://picsum.photos/seed/${product.id}/800/600',
        phone: '9000000000',
        whatsappNumber: '9000000000',
        rating: product.rating,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        onCallPressed: () {
          context.read<SellerStore>().recordProductContactCall(product.id);
        },
        onWhatsAppPressed: () {
          context.read<SellerStore>().recordProductContactWhatsapp(product.id);
        },
      );
    }).toList();

    // Get ads for this category
    final sellerStore = context.read<SellerStore>();
    final relevantAds = sellerStore.ads.where((ad) {
      if (ad.type == AdType.category) {
        return ad.term.toLowerCase() == category.name.toLowerCase();
      }
      return false;
    }).toList();

    return Column(
      children: [
        // Show relevant ads at the top
        if (relevantAds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Sponsored Results',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...relevantAds.map((ad) => _AdResultCard(ad: ad)),
          const SizedBox(height: 16),
          Text(
            'Regular Results',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ResponsiveProductGrid(
          products: productCards,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}

class _AdResultCard extends StatelessWidget {
  final AdCampaign ad;
  
  const _AdResultCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'AD',
                style: t.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sponsored: ${ad.term}',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Position #${ad.slot} • Category Campaign',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
