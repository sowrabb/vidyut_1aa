import 'package:flutter/material.dart';
import 'responsive_grid.dart';
import 'responsive_product_card.dart';
import 'landscape_product_card.dart';
import '../app/breakpoints.dart';

/// Enhanced responsive product grid that automatically switches between 
/// grid and landscape layouts based on screen size
class ResponsiveProductGrid extends StatelessWidget {
  final List<ProductCardData> products;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveProductGrid({
    super.key,
    required this.products,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;
        
        if (isMobile) {
          // Mobile: Use landscape cards in a list
          return ListView.builder(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return LandscapeProductCard(
                productId: product.productId,
                title: product.title,
                brand: product.brand,
                price: product.price,
                subtitle: product.subtitle,
                imageUrl: product.imageUrl,
                phone: product.phone,
                whatsappNumber: product.whatsappNumber,
                rating: product.rating,
                discountPercentage: product.discountPercentage,
                isAvailable: product.isAvailable,
                onTap: product.onTap,
                onCallPressed: product.onCallPressed,
                onWhatsAppPressed: product.onWhatsAppPressed,
              );
            },
          );
        } else {
          // Desktop/Tablet: Use regular grid cards
          return ResponsiveGrid(
            gridType: ResponsiveGridType.product,
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            children: products.map((product) {
              return ResponsiveProductCard(
                productId: product.productId,
                title: product.title,
                brand: product.brand,
                price: product.price,
                subtitle: product.subtitle,
                imageUrl: product.imageUrl,
                phone: product.phone,
                whatsappNumber: product.whatsappNumber,
                rating: product.rating,
                discountPercentage: product.discountPercentage,
                isAvailable: product.isAvailable,
                onTap: product.onTap,
                onCallPressed: product.onCallPressed,
                onWhatsAppPressed: product.onWhatsAppPressed,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

/// Data class to hold product information for both card types
class ProductCardData {
  final String productId;
  final String title;
  final String brand;
  final String price;
  final String subtitle;
  final String imageUrl;
  final String phone;
  final String whatsappNumber;
  final double? rating;
  final double? discountPercentage;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback? onCallPressed;
  final VoidCallback? onWhatsAppPressed;

  const ProductCardData({
    required this.productId,
    required this.title,
    required this.brand,
    required this.price,
    required this.subtitle,
    required this.imageUrl,
    required this.phone,
    required this.whatsappNumber,
    this.rating,
    this.discountPercentage,
    this.isAvailable = true,
    this.onTap,
    this.onCallPressed,
    this.onWhatsAppPressed,
  });

  factory ProductCardData.demo({required int index, VoidCallback? onTap}) {
    return ProductCardData(
      productId: 'P${index + 1}',
      title: 'Copper Cable ${index + 1} - Premium Quality',
      brand: 'Philips',
      price: '₹${(499 + index * 20)}',
      subtitle: 'PVC Insulated | 1.5 sqmm | 1100V Rating',
      imageUrl: 'https://picsum.photos/seed/vidyut_$index/400/300',
      phone: '9000000000',
      whatsappNumber: '9000000000',
      rating: 4.2 + (index % 3) * 0.2,
      discountPercentage: index % 4 == 0 ? 15.0 : null,
      onTap: onTap,
    );
  }
}
