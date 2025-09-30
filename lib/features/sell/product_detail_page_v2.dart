import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../../app/geo.dart';
import '../sell/models.dart';
import '../home/widgets/product_card.dart';
import '../../widgets/product_image_gallery.dart';
import '../reviews/product_reviews_card.dart';
import 'seller_page.dart';
import 'package:ionicons/ionicons.dart';
import '../search/search_page_v2.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPageV2 extends ConsumerWidget {
  final String productId;
  
  const ProductDetailPageV2({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final session = ref.watch(sessionControllerProvider);
    final rbac = ref.watch(rbacProvider);
    
    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (product) {
        final t = Theme.of(context).textTheme;
        
        return AppShellScaffold(
          selectedIndex: 1, // default: Search tab for product discovery context
          appBar: const VidyutAppBar(title: 'Vidyut'),
          body: SafeArea(
            child: ContentClamp(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Gallery + Meta  (2-col desktop / 1-col mobile)
                  ResponsiveRow(desktop: 2, tablet: 2, phone: 1, children: [
                    // Gallery
                    ProductImageGallery(
                        imageUrls: product.images,
                        heroPrefix: 'product_${product.id}'),
                    // Meta
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleBlock(product: product),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                // TODO: Implement contact functionality
                              },
                              icon: const Icon(Icons.call),
                              label: const Text('Contact Supplier'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                // TODO: Implement WhatsApp functionality
                              },
                              icon: const Icon(Ionicons.logo_whatsapp),
                              label: const Text('WhatsApp'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.whatsapp,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _SellerMiniCard(product: product),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Description
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outlineSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(product.description.isEmpty
                          ? 'No description provided.'
                          : product.description),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Specifications
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outlineSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Specifications', style: t.titleMedium),
                          const SizedBox(height: 12),
                          _SpecRow('Brand', product.brand),
                          _SpecRow('Category', product.category),
                          _SpecRow('MOQ', '${product.moq} units'),
                          _SpecRow('GST Rate', '${product.gstRate}%'),
                          if (product.materials.isNotEmpty)
                            _SpecRow('Materials', product.materials.join(', ')),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reviews Section
                  Consumer(
                    builder: (context, ref, child) {
                      final reviewsAsync = ref.watch(reviewsProvider(productId));
                      
                      return reviewsAsync.when(
                        loading: () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (error, stack) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Error loading reviews: $error'),
                          ),
                        ),
                        data: (reviewsList) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.outlineSoft),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Reviews', style: t.titleMedium),
                                      Text('${reviewsList.totalCount} reviews'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '${reviewsList.averageRating.toStringAsFixed(1)}',
                                        style: t.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < reviewsList.averageRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (reviewsList.reviews.isNotEmpty)
                                    ...reviewsList.reviews.take(3).map((review) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  review.authorDisplay,
                                                  style: t.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Row(
                                                  children: List.generate(5, (index) {
                                                    return Icon(
                                                      index < review.rating
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      size: 14,
                                                      color: Colors.amber,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              review.body,
                                              style: t.bodySmall,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  if (session.isAuthenticated && rbac.can('reviews.write'))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          ref.read(reviewComposerProvider.notifier)
                                              .startComposing(productId);
                                          // TODO: Show review composer dialog
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Write Review'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final Product product;
  
  const _TitleBlock({required this.product});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title.isEmpty ? 'Untitled Product' : product.title,
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (product.subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            product.subtitle,
            style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '₹${product.price.toStringAsFixed(0)}',
          style: t.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < product.rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${product.rating.toStringAsFixed(1)} (${product.rating.toInt()} reviews)',
              style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _SellerMiniCard extends StatelessWidget {
  final Product product;
  
  const _SellerMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SellerPage(sellerName: 'Demo Seller'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.thumbBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Seller',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Verified Supplier',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
