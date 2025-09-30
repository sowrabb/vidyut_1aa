import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../../widgets/responsive_product_grid.dart';
import '../sell/product_detail_page.dart';

class SearchPageV2 extends ConsumerWidget {
  final String? initialQuery;
  const SearchPageV2({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Search (V2)'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by brand, spec, materials...',
              ),
              controller: TextEditingController(text: initialQuery ?? searchQuery.query),
              onSubmitted: (text) {
                ref.read(searchQueryProvider.notifier).state = searchQuery.copyWith(query: text);
                ref.read(searchHistoryProvider.notifier).addEntry(
                  SearchEntry(query: text, timestamp: DateTime.now(), filters: searchQuery.filters),
                );
              },
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (data) {
                if (data.products.isEmpty) {
                  return const Center(child: Text('No results. Try adjusting filters.'));
                }
                final cards = data.products.map((p) => ProductCardData(
                      productId: p.id,
                      title: p.title,
                      brand: p.brand,
                      price: '₹${p.price.toStringAsFixed(0)}',
                      subtitle: p.subtitle,
                      imageUrl: 'https://picsum.photos/seed/${p.id}/800/600',
                      phone: '9000000000',
                      whatsappNumber: '9000000000',
                      rating: p.rating,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
                      ),
                      onCallPressed: () {},
                      onWhatsAppPressed: () {},
                    ))
                    .toList();
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ResponsiveProductGrid(
                        products: cards,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



