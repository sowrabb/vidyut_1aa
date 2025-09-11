import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/tokens.dart';

/// Landscape product card for mobile view - similar to Amazon's mobile layout
class LandscapeProductCard extends StatelessWidget {
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

  const LandscapeProductCard({
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

  factory LandscapeProductCard.demo({required int index, VoidCallback? onTap}) {
    return LandscapeProductCard(
      productId: 'P${index + 1}',
      title: 'Copper Cable ${index + 1} - High Quality Electrical Wire',
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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineSoft, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 170, // Optimized height to prevent overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image (left side)
              _buildImageSection(),
              
              // Content Section (right side)
              Expanded(
                child: _buildContentSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: 130, // Reduced width to give more space to content
      height: 170,
      child: Stack(
        children: [
          // Main image
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
                ? const Icon(
                    Icons.image,
                    size: 32,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),

          // Discount badge
          if (discountPercentage != null)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${discountPercentage!.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand name
          Text(
            brand,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Product title - flexible space
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle/specifications
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Rating row
          if (rating != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Price - prominent but sized to fit
          Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Action buttons - icon only for mobile
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      height: 40, // Reduced height to prevent overflow
      child: Row(
        children: [
          // Call button - filled, icon only
          Expanded(
            child: FilledButton(
              onPressed: () => _call(phone),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(
                Ionicons.call,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // WhatsApp button - filled, icon only
          Expanded(
            child: FilledButton(
              onPressed: () => _whatsapp(whatsappNumber),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(
                Ionicons.logo_whatsapp,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
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
