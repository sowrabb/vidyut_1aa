import 'package:flutter/material.dart';
import '../app/tokens.dart';
import '../app/breakpoints.dart';
import '../features/categories/categories_page.dart';

/// Highly responsive category card that adapts to any screen size
class ResponsiveCategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback? onTap;

  const ResponsiveCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final screenWidth = MediaQuery.sizeOf(context).width;
        
        // Adaptive sizing based on card width and screen size
        final isSmallCard = cardWidth < 140;
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
                // Image section
                _buildImageSection(isSmallCard),
                
                // Content section
                Expanded(
                  child: _buildContentSection(cardWidth, isSmallCard, isMobile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isSmallCard) {
    // Adaptive image aspect ratio - categories need more image focus
    final imageAspectRatio = isSmallCard ? 16/10 : 16/11;
    
    return AspectRatio(
      aspectRatio: imageAspectRatio,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.thumbBg,
          image: category.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: category.imageUrl.startsWith('assets/')
                      ? AssetImage(category.imageUrl)
                      : NetworkImage(category.imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Category image error: $exception');
                  },
                )
              : null,
        ),
        child: category.imageUrl.isEmpty
            ? Icon(
                Icons.category,
                size: isSmallCard ? 24 : 32,
                color: AppColors.textSecondary,
              )
            : null,
      ),
    );
  }

  Widget _buildContentSection(double cardWidth, bool isSmallCard, bool isMobile) {
    // Reduced padding to prevent overflow
    final contentPadding = EdgeInsets.all(isSmallCard ? 3.0 : 5.0);
    final spacing = isSmallCard ? 1.5 : 3.0;
    
    // More conservative text sizes
    final titleSize = _getAdaptiveTextSize(cardWidth, base: 12, min: 9, max: 14);
    final countSize = _getAdaptiveTextSize(cardWidth, base: 10, min: 7, max: 11);
    final buttonSize = _getAdaptiveTextSize(cardWidth, base: 10, min: 8, max: 11);

    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category name - priority content
          Text(
            category.name,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
            maxLines: isSmallCard ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: spacing),

          // Product count
          Text(
            '${category.productCount} products',
            style: TextStyle(
              fontSize: countSize,
              color: AppColors.textSecondary,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Industries (only show if there's space and not too small)
          if (!isSmallCard && cardWidth > 140 && category.industries.isNotEmpty) ...[
            SizedBox(height: spacing),
            _buildIndustryChips(cardWidth),
          ],

          const Spacer(),

          // Bottom section - view button
          _buildViewButton(cardWidth, isSmallCard, buttonSize),
        ],
      ),
    );
  }

  Widget _buildIndustryChips(double cardWidth) {
    // Show fewer chips on smaller cards
    final maxChips = cardWidth < 160 ? 1 : (cardWidth < 200 ? 2 : 3);
    final chipSize = _getAdaptiveTextSize(cardWidth, base: 10, min: 8, max: 11);
    
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: category.industries
          .take(maxChips)
          .map(
            (industry) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.xxs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                industry,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: chipSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildViewButton(double cardWidth, bool isSmallCard, double buttonSize) {
    final buttonHeight = cardWidth < 140 ? 32.0 : (cardWidth < 180 ? 36.0 : 40.0);
    final adjustedFontSize = buttonSize + 2; // Increase font size by 2px
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 4),
          minimumSize: Size(0, buttonHeight),
          side: BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          'View',
          style: TextStyle(
            fontSize: adjustedFontSize,
            color: AppColors.primary,
            fontWeight: FontWeight.w600, // Made bolder for better visibility
            height: 1.0,
          ),
        ),
      ),
    );
  }

  // Adaptive sizing helper
  double _getAdaptiveTextSize(double cardWidth, {required double base, required double min, required double max}) {
    if (cardWidth < 120) return min;
    if (cardWidth > 200) return max;
    
    // Linear interpolation between min and max based on card width
    final ratio = (cardWidth - 120) / (200 - 120);
    return min + (max - min) * ratio;
  }
}
