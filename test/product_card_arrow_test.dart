import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/home/widgets/product_card.dart';

void main() {
  group('ProductCard Arrow Navigation Tests', () {
    testWidgets('ProductCard arrows should work correctly on desktop',
        (WidgetTester tester) async {
      // Create a ProductCard with multiple images (network URL will generate multiple demo images)
      final productCard = ProductCard(
        productId: 'test-product',
        title: 'Test Product',
        brand: 'Test Brand',
        price: '₹100',
        subtitle: 'Test subtitle',
        imageUrl:
            'https://example.com/test-image.jpg', // Network URL to trigger multiple images
        phone: '1234567890',
        whatsappNumber: '1234567890',
      );

      // Build the widget in a desktop-sized context
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 400,
                  child: productCard,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the product card is displayed
      expect(find.byType(ProductCard), findsOneWidget);

      // Look for the arrow buttons - they should be present for network URLs on desktop
      final leftArrow = find.byIcon(Icons.chevron_left);
      final rightArrow = find.byIcon(Icons.chevron_right);

      // The arrows should be present since network URLs generate multiple images and we're in desktop mode
      expect(leftArrow, findsOneWidget);
      expect(rightArrow, findsOneWidget);

      // Test left arrow navigation
      await tester.tap(leftArrow);
      await tester.pumpAndSettle();

      // Test right arrow navigation
      await tester.tap(rightArrow);
      await tester.pumpAndSettle();

      // Test right arrow navigation again
      await tester.tap(rightArrow);
      await tester.pumpAndSettle();

      // The page indicators should also be present
      final pageIndicators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      // Should have page indicators for multiple images
      expect(pageIndicators, findsWidgets);
    });

    testWidgets('ProductCard should not show arrows on mobile',
        (WidgetTester tester) async {
      // Create a ProductCard with multiple images
      final productCard = ProductCard(
        productId: 'test-product',
        title: 'Test Product',
        brand: 'Test Brand',
        price: '₹100',
        subtitle: 'Test subtitle',
        imageUrl: 'https://example.com/test-image.jpg',
        phone: '1234567890',
        whatsappNumber: '1234567890',
      );

      // Build the widget in a mobile-sized context
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 300,
                  child: productCard,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the product card is displayed
      expect(find.byType(ProductCard), findsOneWidget);

      // Look for the arrow buttons - they should NOT be visible on mobile
      final leftArrow = find.byIcon(Icons.chevron_left);
      final rightArrow = find.byIcon(Icons.chevron_right);

      // The arrows should not be present on mobile
      expect(leftArrow, findsNothing);
      expect(rightArrow, findsNothing);
    });

    testWidgets('ProductCard with single asset image should not show arrows',
        (WidgetTester tester) async {
      // Create a ProductCard with a single asset image
      final productCard = ProductCard(
        productId: 'test-product',
        title: 'Test Product',
        brand: 'Test Brand',
        price: '₹100',
        subtitle: 'Test subtitle',
        imageUrl: 'assets/logo.png', // Single asset image
        phone: '1234567890',
        whatsappNumber: '1234567890',
      );

      // Build the widget in a desktop-sized context
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 400,
                  child: productCard,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the product card is displayed
      expect(find.byType(ProductCard), findsOneWidget);

      // Look for the arrow buttons - they should NOT be visible for single images
      final leftArrow = find.byIcon(Icons.chevron_left);
      final rightArrow = find.byIcon(Icons.chevron_right);

      // The arrows should not be present for single images
      expect(leftArrow, findsNothing);
      expect(rightArrow, findsNothing);
    });
  });
}
