import 'package:flutter/material.dart';
import '../../../app/breakpoints.dart';
import '../../../app/tokens.dart';
import '../../categories/categories_page.dart';
import '../../categories/category_detail_page.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  static const _categories = [
    CategoryData(
      name: 'Cables & Wires',
      imageUrl: 'assets/demo-images/wires-cables/wire01.jpeg',
      productCount: 5,
      industries: ['Construction', 'EPC', 'MEP', 'Industrial'],
      materials: ['Copper', 'Aluminium', 'PVC', 'XLPE'],
    ),
    CategoryData(
      name: 'Switchgear',
      imageUrl: 'assets/demo-images/circuit-breakers/breaker01.jpeg',
      productCount: 5,
      industries: ['Industrial', 'Commercial', 'Infrastructure'],
      materials: ['Steel', 'Iron', 'Plastic'],
    ),
    CategoryData(
      name: 'Lighting',
      imageUrl: 'assets/demo-images/lights/light01.jpeg',
      productCount: 5,
      industries: ['Commercial', 'Residential', 'Infrastructure'],
      materials: ['Plastic', 'Aluminium', 'Glass'],
    ),
    CategoryData(
      name: 'Motors & Drives',
      imageUrl: 'assets/demo-images/motors/motor01.jpeg',
      productCount: 5,
      industries: ['Industrial', 'Commercial'],
      materials: ['Steel', 'Iron', 'Copper'],
    ),
    CategoryData(
      name: 'Tools & Safety',
      imageUrl: 'assets/demo-images/tools/tool01.jpeg',
      productCount: 5,
      industries: ['Construction', 'Industrial', 'Commercial'],
      materials: ['Steel', 'Rubber', 'Plastic'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = _getCrossAxisCount(availableWidth);
        final spacing = _getSpacing(availableWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 0.85, // Slightly taller for better content fit
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => _navigateToCategory(context, category),
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= AppBreakpoints.desktop) return 6;
    if (width >= AppBreakpoints.tablet) return 4;
    return 3;
  }

  double _getSpacing(double width) {
    if (width >= AppBreakpoints.desktop) return 16;
    if (width >= AppBreakpoints.tablet) return 12;
    return 8;
  }

  void _navigateToCategory(BuildContext context, CategoryData category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(category: category),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - fixed height
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.thumbBg,
                  image: DecorationImage(
                    image: AssetImage(category.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Category image error: $exception');
                    },
                  ),
                ),
                child: category.imageUrl.isEmpty
                    ? const Icon(
                        Icons.category,
                        size: 32,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
            ),

            // Content section - flexible height
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category name
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Product count
                    Text(
                      '${category.productCount} products',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),

                    const SizedBox(height: 6),

                    // View button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 28),
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
