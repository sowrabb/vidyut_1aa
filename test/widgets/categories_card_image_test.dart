import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/widgets/responsive_category_card.dart';
import 'package:vidyut/features/categories/categories_page.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders asset image path', (tester) async {
    const cat = CategoryData(
      name: 'Test',
      imageUrl: 'assets/logo.png',
      productCount: 1,
      industries: [],
      materials: [],
    );

    await tester.pumpWidget(_wrap(const SizedBox(
        width: 200, child: ResponsiveCategoryCard(category: cat))));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renders network image placeholder and then error',
      (tester) async {
    const cat = CategoryData(
      name: 'Test',
      imageUrl: 'https://invalid.example.com/missing.jpg',
      productCount: 1,
      industries: [],
      materials: [],
    );

    await tester.pumpWidget(_wrap(const SizedBox(
        width: 200, child: ResponsiveCategoryCard(category: cat))));

    // First frame shows placeholder
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let network fail
    await tester.pump(const Duration(seconds: 1));

    // Fallback icon
    expect(find.byIcon(Icons.category), findsOneWidget);
  });

  testWidgets('empty URL shows fallback icon immediately', (tester) async {
    const cat = CategoryData(
      name: 'Test',
      imageUrl: '',
      productCount: 1,
      industries: [],
      materials: [],
    );

    await tester.pumpWidget(_wrap(const SizedBox(
        width: 200, child: ResponsiveCategoryCard(category: cat))));
    await tester.pump();

    expect(find.byIcon(Icons.category), findsOneWidget);
  });
}
