import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/tokens.dart';
import '../app/breakpoints.dart';

/// Highly responsive product card that adapts to any screen size
class ResponsiveProductCard extends StatelessWidget {
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

  const ResponsiveProductCard({
    super.key,
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

  factory ResponsiveProductCard.demo({required int index, VoidCallback? onTap}) {
    return ResponsiveProductCard(
      productId: 'P${index + 1}',
      title: 'Copper Cable ${index + 1}',
      brand: 'Philips',
      price: '₹${(499 + index * 20)}',
      subtitle: 'PVC | 1.5 sqmm | 1100V',
      imageUrl: 'https://picsum.photos/seed/vidyut_$index/800/600',
      phone: '9000000000',
      whatsappNumber: '9000000000',
      rating: 4.2 + (index % 3) * 0.2,
      discountPercentage: index % 4 == 0 ? 15.0 : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final screenWidth = MediaQuery.sizeOf(context).width;
        
        // Adaptive sizing based on card width and screen size
        final isSmallCard = cardWidth < 160;
        final isDesktop = screenWidth >= AppBreakpoints.desktop;
        final isMobile = screenWidth < AppBreakpoints.tablet;
        
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          margin: EdgeInsets.zero, // Remove margin for consistent grid spacing
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.outlineSoft),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with adaptive aspect ratio
                _buildImageSection(isSmallCard, isDesktop),
                
                // Content section that adapts to available space
                Expanded(
                  child: _buildContentSection(cardWidth, isSmallCard, isMobile, isDesktop),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isSmallCard, bool isDesktop) {
    // Adaptive image height based on card size
    final imageAspectRatio = isSmallCard ? 16/10 : 16/12; // Slightly taller for larger cards
    
    return AspectRatio(
      aspectRatio: imageAspectRatio,
      child: Stack(
        children: [
          // Main image container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.thumbBg,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: imageUrl.startsWith('assets/')
                          ? AssetImage(imageUrl)
                          : NetworkImage(imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        debugPrint('Product image error: $exception');
                      },
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.image,
                    size: isSmallCard ? 24 : 48,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),

          // Discount badge
          if (discountPercentage != null)
            Positioned(
              top: AppSpace.xxs,
              left: AppSpace.xxs,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallCard ? 4 : 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${discountPercentage!.toInt()}% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallCard ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(double cardWidth, bool isSmallCard, bool isMobile, bool isDesktop) {
    // Adaptive padding and spacing
    final contentPadding = EdgeInsets.all(isSmallCard ? 4.0 : 6.0);
    final spacing = isSmallCard ? 2.0 : 4.0;
    
    // Adaptive text sizes
    final brandSize = _getAdaptiveTextSize(cardWidth, base: 10, min: 8, max: 11);
    final titleSize = _getAdaptiveTextSize(cardWidth, base: 13, min: 10, max: 14);
    final subtitleSize = _getAdaptiveTextSize(cardWidth, base: 10, min: 8, max: 10);
    final priceSize = _getAdaptiveTextSize(cardWidth, base: 14, min: 12, max: 16);

    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top content - flexible space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand
                Text(
                  brand,
                  style: TextStyle(
                    fontSize: brandSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (!isSmallCard) SizedBox(height: spacing),

                // Title - adaptive line count
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: isSmallCard ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (!isSmallCard) SizedBox(height: spacing),

                // Subtitle - only on larger cards
                if (!isSmallCard)
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppColors.textSecondary,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Rating - only show if space allows and not small
                if (!isSmallCard && rating != null && cardWidth > 160) ...[
                  SizedBox(height: spacing),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star, 
                          size: subtitleSize + 1, 
                          color: Colors.amber,
                        ),
                        SizedBox(width: 2),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom section - price and buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price
              Text(
                price,
                style: TextStyle(
                  fontSize: priceSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: spacing),

              // Action buttons - adaptive layout
              _buildActionButtons(cardWidth, isSmallCard),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double cardWidth, bool isSmallCard) {
    final buttonHeight = _getButtonHeight(cardWidth);
    
    // For very small cards, show compact icon buttons
    if (isSmallCard || cardWidth < 150) {
      return SizedBox(
        height: buttonHeight,
        child: Row(
          children: [
            Expanded(
              child: _buildCompactButton(
                icon: Ionicons.call_outline,
                color: AppColors.primary,
                onPressed: () => _call(phone),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildCompactButton(
                icon: Ionicons.logo_whatsapp,
                color: AppColors.whatsapp,
                onPressed: () => _whatsapp(whatsappNumber),
              ),
            ),
          ],
        ),
      );
    }

    // For medium cards, show compact text buttons
    if (cardWidth < 180) {
      return SizedBox(
        height: buttonHeight,
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => _call(phone),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  minimumSize: Size(0, buttonHeight),
                ),
                child: Text(
                  'Call',
                  style: TextStyle(fontSize: _getButtonTextSize(cardWidth)),
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: FilledButton(
                onPressed: () => _whatsapp(whatsappNumber),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.whatsapp,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  minimumSize: Size(0, buttonHeight),
                ),
                child: Text(
                  'WhatsApp',
                  style: TextStyle(fontSize: _getButtonTextSize(cardWidth)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For larger cards, show buttons with icons and text
    return SizedBox(
      height: buttonHeight,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _call(phone),
              icon: Icon(Ionicons.call_outline, size: _getIconSize(cardWidth)),
              label: Text(
                'Call',
                style: TextStyle(fontSize: _getButtonTextSize(cardWidth)),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 2),
                minimumSize: Size(0, buttonHeight),
              ),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _whatsapp(whatsappNumber),
              icon: Icon(Ionicons.logo_whatsapp, size: _getIconSize(cardWidth)),
              label: Text(
                'WhatsApp',
                style: TextStyle(fontSize: _getButtonTextSize(cardWidth)),
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2),
                minimumSize: Size(0, buttonHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 24,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 12),
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(2),
          minimumSize: const Size(20, 20),
          maximumSize: const Size(40, 24),
        ),
      ),
    );
  }

  // Adaptive sizing helpers
  double _getAdaptiveTextSize(double cardWidth, {required double base, required double min, required double max}) {
    if (cardWidth < 120) return min;
    if (cardWidth > 200) return max;
    
    // Linear interpolation between min and max based on card width
    final ratio = (cardWidth - 120) / (200 - 120);
    return min + (max - min) * ratio;
  }

  double _getIconSize(double cardWidth) {
    return cardWidth < 140 ? 10 : (cardWidth < 180 ? 12 : 14);
  }

  double _getButtonTextSize(double cardWidth) {
    return cardWidth < 140 ? 8 : (cardWidth < 180 ? 9 : 10);
  }

  double _getButtonHeight(double cardWidth) {
    return cardWidth < 140 ? 20 : (cardWidth < 180 ? 24 : 28);
  }

  Future<void> _call(String number) async {
    // Record call interaction
    onCallPressed?.call();
    
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch phone call: $e');
    }
  }

  Future<void> _whatsapp(String number) async {
    // Record WhatsApp interaction
    onWhatsAppPressed?.call();
    
    final uri = Uri.parse('https://wa.me/$number');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch WhatsApp: $e');
    }
  }
}

