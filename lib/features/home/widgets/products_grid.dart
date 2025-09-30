import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/responsive_product_grid.dart';
import '../../sell/product_detail_page.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';

class ProductsGrid extends ConsumerWidget {
  final double radiusKm;
  const ProductsGrid({super.key, required this.radiusKm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final sellerStore = ref.watch(sellerStoreProvider);
        final products = sellerStore.products.take(12).toList();

        // Convert to ProductCardData
        final productCards = products.map((product) {
          return ProductCardData(
            productId: product.id,
            title: product.title,
            brand: product.brand,
            price: '₹${product.price.toStringAsFixed(0)}',
            subtitle: product.subtitle,
            imageUrl: product.images.isNotEmpty
                ? product.images.first
                : 'assets/logo.png',
            phone: '+91 98765 43210', // Default phone
            whatsappNumber: '+91 98765 43210', // Default WhatsApp
            rating: product.rating,
            onTap: () {
              // Record product view
              sellerStore.recordProductView(product.id);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
            onCallPressed: () {
              // Record call interaction
              sellerStore.recordProductContactCall(product.id);
            },
            onWhatsAppPressed: () {
              // Record WhatsApp interaction
              sellerStore.recordProductContactWhatsapp(product.id);
            },
          );
        }).toList();

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpace.xs, 0, AppSpace.xs),
            child: ResponsiveProductGrid(
              products: productCards,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        );
      },
    );
  }
}
