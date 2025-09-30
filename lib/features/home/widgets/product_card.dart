import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/tokens.dart';
import '../../../app/breakpoints.dart';

class ProductCard extends StatefulWidget {
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

  const ProductCard({
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
  });

  factory ProductCard.demo({required int index, VoidCallback? onTap}) {
    return ProductCard(
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late PageController _pageController;
  int _currentIndex = 0;

  List<String> get _images {
    if (widget.imageUrl.startsWith('assets/')) {
      // For local assets, return the single image
      return [widget.imageUrl];
    } else {
      // For network images, create multiple demo images
      return [
        widget.imageUrl,
        'https://picsum.photos/seed/${widget.title}_1/800/600',
        'https://picsum.photos/seed/${widget.title}_2/800/600',
        'https://picsum.photos/seed/${widget.title}_3/800/600',
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= AppBreakpoints.desktop;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - Responsive aspect ratio (gives more room to content on phones)
            AspectRatio(
              aspectRatio: isMobile ? (16 / 9) : (4 / 3),
              child: _buildImageSection(isDesktop),
            ),

            // Content Section - uses Flexible to prevent overflow
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                child: _buildContentSection(isDesktop, isMobile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDesktop) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.thumbBg,
                image: _images[index].isNotEmpty
                    ? DecorationImage(
                        image: _images[index].startsWith('assets/')
                            ? AssetImage(_images[index])
                            : NetworkImage(_images[index]) as ImageProvider,
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Product image error: $exception');
                        },
                      )
                    : null,
              ),
              child: _images[index].isEmpty
                  ? const Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.textSecondary,
                    )
                  : null,
            );
          },
        ),

        // Discount badge
        if (widget.discountPercentage != null)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${widget.discountPercentage!.toInt()}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Navigation arrows for desktop
        if (isDesktop && _images.length > 1) ...[
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 16),
                  onPressed: () {
                    final newIndex =
                        (_currentIndex - 1 + _images.length) % _images.length;
                    _pageController.animateToPage(newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 16),
                  onPressed: () {
                    final newIndex = (_currentIndex + 1) % _images.length;
                    _pageController.animateToPage(newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                ),
              ),
            ),
          ),
        ],

        // Page indicators
        if (_images.length > 1)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(bool isDesktop, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Top content section (shrinks first if space is tight)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Text(
                  widget.brand,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isMobile ? 1 : 2),

                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isMobile ? 1 : 2),

                // Subtitle
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isMobile ? 2 : 2),

                // Rating
                if (widget.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star,
                          size: isMobile ? 10 : 12, color: Colors.amber),
                      SizedBox(width: isMobile ? 2 : 3),
                      Text(
                        widget.rating!.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                SizedBox(height: isMobile ? 2 : 2),

                // Price
                Text(
                  widget.price,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom section with action buttons
        Row(
          children: [
            Expanded(
              child: isMobile
                  ? IconButton(
                      onPressed: () => _call(widget.phone),
                      icon: const Icon(Ionicons.call_outline, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(3),
                        minimumSize: const Size(26, 26),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => _call(widget.phone),
                      icon: Icon(Ionicons.call_outline,
                          size: isDesktop ? 14 : 12),
                      label: Text('Call',
                          style: TextStyle(fontSize: isDesktop ? 11 : 10)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        minimumSize: const Size(0, 26),
                      ),
                    ),
            ),
            SizedBox(width: isMobile ? 6 : 4),
            Expanded(
              child: isMobile
                  ? IconButton(
                      onPressed: () => _whatsapp(widget.whatsappNumber),
                      icon: const Icon(Ionicons.logo_whatsapp, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(3),
                        minimumSize: const Size(26, 26),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => _whatsapp(widget.whatsappNumber),
                      icon: Icon(Ionicons.logo_whatsapp,
                          size: isDesktop ? 14 : 12),
                      label: Text('WhatsApp',
                          style: TextStyle(fontSize: isDesktop ? 11 : 10)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        minimumSize: const Size(0, 26),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsapp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
