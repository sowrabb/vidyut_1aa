import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../../widgets/responsive_product_grid.dart';
import '../sell/product_detail_page.dart';

class ProductsGridV2 extends ConsumerWidget {
  final double radiusKm;
  
  const ProductsGridV2({super.key, required this.radiusKm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use productsProvider with filters for home page
    final productsAsync = ref.watch(productsProvider({
      'page': 0,
      'limit': 8,
      'featured': true, // Show featured products on home
    }));
    
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (productPage) {
        if (productPage.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('No products available.')),
          );
        }

        // Convert to ProductCardData
        final productCards = productPage.products.map((product) {
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
              // TODO: Implement call functionality
            },
            onWhatsAppPressed: () {
              // TODO: Implement WhatsApp functionality
            },
          );
        }).toList();

        return ResponsiveProductGrid(
          products: productCards,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}

