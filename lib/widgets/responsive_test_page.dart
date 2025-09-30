import 'package:flutter/material.dart';
import 'responsive_grid.dart';
import 'responsive_product_grid.dart';
import 'landscape_product_card.dart';
import 'responsive_category_card.dart';
import '../features/categories/categories_page.dart';

/// Test page to verify responsive behavior across different screen sizes
class ResponsiveTestPage extends StatelessWidget {
  const ResponsiveTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final testCategories = [
      const CategoryData(
        name: 'Test Category 1',
        imageUrl: 'https://picsum.photos/seed/cat1/400/300',
        productCount: 25,
        industries: ['Industrial', 'Commercial'],
        materials: ['Steel', 'Plastic'],
      ),
      const CategoryData(
        name: 'Test Category 2',
        imageUrl: 'https://picsum.photos/seed/cat2/400/300',
        productCount: 42,
        industries: ['Construction', 'Residential'],
        materials: ['Aluminum', 'Rubber'],
      ),
      const CategoryData(
        name: 'Test Category 3',
        imageUrl: 'https://picsum.photos/seed/cat3/400/300',
        productCount: 18,
        industries: ['Automotive'],
        materials: ['Carbon'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Design Test'),
        actions: [
          IconButton(
            onPressed: () => _showScreenInfo(context),
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen size info
            _buildScreenInfo(context),
            const SizedBox(height: 24),

            // Category cards test
            Text(
              'Category Cards',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ResponsiveGrid(
              gridType: ResponsiveGridType.category,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: testCategories.map((category) {
                return ResponsiveCategoryCard(
                  category: category,
                  onTap: () => _showDialog(context, 'Tapped: ${category.name}'),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Product cards test
            Text(
              'Product Cards (Auto-responsive)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ResponsiveProductGrid(
              products: List.generate(8, (index) {
                return ProductCardData.demo(
                  index: index,
                  onTap: () =>
                      _showDialog(context, 'Tapped Product ${index + 1}'),
                );
              }),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),

            const SizedBox(height: 32),

            // Landscape cards test
            Text(
              'Landscape Cards (Mobile Style)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(3, (index) {
                return LandscapeProductCard.demo(
                  index: index,
                  onTap: () =>
                      _showDialog(context, 'Tapped Landscape ${index + 1}'),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Width test sections
            Text(
              'Width Adaptation Test',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildWidthTestSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenInfo(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final productCols = ResponsiveGridConfig.getProductColumns(size.width);
    final categoryCols = ResponsiveGridConfig.getCategoryColumns(size.width);
    final spacing = ResponsiveGridConfig.getSpacing(size.width);
    final productAspect =
        ResponsiveGridConfig.getProductAspectRatio(size.width);
    final categoryAspect =
        ResponsiveGridConfig.getCategoryAspectRatio(size.width);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Screen: ${size.width.toInt()} x ${size.height.toInt()}'),
            Text('Product Columns: $productCols'),
            Text('Category Columns: $categoryCols'),
            Text('Spacing: ${spacing.toInt()}px'),
            Text('Product Aspect: ${productAspect.toStringAsFixed(2)}'),
            Text('Category Aspect: ${categoryAspect.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildWidthTestSection(BuildContext context) {
    final testWidths = [300.0, 600.0, 900.0, 1200.0];

    return Column(
      children: testWidths.map((width) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Container Width: ${width.toInt()}px'),
            const SizedBox(height: 8),
            Container(
              width: width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ResponsiveProductGrid(
                  products: List.generate(4, (index) {
                    return ProductCardData.demo(index: index);
                  }),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  void _showScreenInfo(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screen Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Width: ${size.width.toInt()}px'),
            Text('Height: ${size.height.toInt()}px'),
            Text(
                'Device Pixel Ratio: ${MediaQuery.of(context).devicePixelRatio}'),
            Text(
              'Text Scale Factor: ${MediaQuery.textScalerOf(context).scale(1).toStringAsFixed(2)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
