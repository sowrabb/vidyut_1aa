import 'package:flutter/material.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/responsive_category_card.dart';
import '../../categories/category_detail_page.dart';
import '../../categories/categories_page.dart';

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
        final isMobile = constraints.maxWidth < 768; // AppBreakpoints.tablet

        if (isMobile) {
          // Mobile: Single row horizontal scroll
          return SizedBox(
            height: 180, // Fixed height for horizontal scroll
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 140, // Fixed width for each category card
                  margin: EdgeInsets.only(
                    right: index < _categories.length - 1 ? 12 : 0,
                  ),
                  child: ResponsiveCategoryCard(
                    category: _categories[index],
                    onTap: () =>
                        _navigateToCategory(context, _categories[index]),
                  ),
                );
              },
            ),
          );
        } else {
          // Desktop/Tablet: Regular grid
          return ResponsiveGrid(
            gridType: ResponsiveGridType.category,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _categories.map((category) {
              return ResponsiveCategoryCard(
                category: category,
                onTap: () => _navigateToCategory(context, category),
              );
            }).toList(),
          );
        }
      },
    );
  }

  void _navigateToCategory(BuildContext context, CategoryData category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(category: category),
      ),
    );
  }
}
