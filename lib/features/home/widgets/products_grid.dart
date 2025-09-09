import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_card.dart';
import '../../sell/product_detail_page.dart';
import '../../sell/store/seller_store.dart';

class ProductsGrid extends StatelessWidget {
  final double radiusKm;
  const ProductsGrid({super.key, required this.radiusKm});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerStore>(
      builder: (context, sellerStore, child) {
        final products = sellerStore.products.take(12).toList();
        
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.crossAxisExtent;
              final crossAxisCount = _getCrossAxisCount(availableWidth);
              final spacing = _getSpacing(availableWidth);

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 0.75, // Slightly taller for better content fit
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= products.length) return null;
                    final product = products[index];
                    return ProductCard(
                      productId: product.id,
                      title: product.title,
                      brand: product.brand,
                      price: '₹${product.price.toStringAsFixed(0)}',
                      subtitle: product.subtitle,
                      imageUrl: product.images.isNotEmpty ? product.images.first : 'assets/logo.png',
                      phone: '+91 98765 43210', // Default phone
                      whatsappNumber: '+91 98765 43210', // Default WhatsApp
                      rating: product.rating,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              );
            },
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(double availableWidth) {
    if (availableWidth >= 1200) return 4; // Desktop
    if (availableWidth >= 900) return 3; // Large tablet
    if (availableWidth >= 600) return 2; // Tablet
    return 1; // Mobile
  }

  double _getSpacing(double availableWidth) {
    if (availableWidth >= 1200) return 16;
    if (availableWidth >= 900) return 12;
    if (availableWidth >= 600) return 10;
    return 8;
  }
}
