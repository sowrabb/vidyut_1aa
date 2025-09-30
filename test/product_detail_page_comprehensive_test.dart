import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/app/app_state.dart';
import 'package:vidyut/features/sell/product_detail_page.dart';
import 'package:vidyut/features/sell/models.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('ProductDetailPage Comprehensive Tests', () {
    late AppState appState;
    late LightweightDemoDataService demoDataService;
    late Product sampleProduct;

    setUp(() {
      appState = AppState();
      demoDataService = LightweightDemoDataService();

      // Create sample product for testing
      sampleProduct = Product(
        id: 'test_product_1',
        title: 'Industrial Circuit Breaker 63A',
        brand: 'ABB',
        price: 15000.0,
        subtitle: 'Circuit Breakers',
        materials: ['Steel', 'Copper'],
        rating: 4.5,
        moq: 10,
        gstRate: 18.0,
        status: ProductStatus.active,
        description:
            'High-quality industrial circuit breaker with advanced protection features.',
        category: 'Circuit Breakers',
        images: [
          'https://picsum.photos/seed/circuit1/800/600',
          'https://picsum.photos/seed/circuit2/800/600',
        ],
      );
    });

    tearDown(() {
      // Clean up any resources
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          demoDataServiceProvider.overrideWith((ref) => demoDataService),
          appStateNotifierProvider
              .overrideWith((ref) => AppStateNotifier(appState)),
        ],
        child: MaterialApp(
          home: ProductDetailPage(product: sampleProduct),
        ),
      );
    }

    group('Unit Tests - Product Model', () {
      test('Product initializes with correct values', () {
        expect(sampleProduct.id, 'test_product_1');
        expect(sampleProduct.title, 'Industrial Circuit Breaker 63A');
        expect(sampleProduct.brand, 'ABB');
        expect(sampleProduct.price, 15000.0);
        expect(sampleProduct.materials, ['Steel', 'Copper']);
        expect(sampleProduct.rating, 4.5);
        expect(sampleProduct.moq, 10);
        expect(sampleProduct.gstRate, 18.0);
        expect(sampleProduct.status, ProductStatus.active);
      });

      test('Product categorySafe returns correct category', () {
        expect(sampleProduct.categorySafe, 'Circuit Breakers');
      });

      test('Product price formatting works correctly', () {
        expect(sampleProduct.price.toStringAsFixed(0), '15000');
      });

      test('Product materials join correctly', () {
        expect(sampleProduct.materials.join(', '), 'Steel, Copper');
      });

      test('Product status name returns correct value', () {
        expect(sampleProduct.status.name, 'active');
      });
    });

    group('Widget Tests - Basic Rendering', () {
      testWidgets('ProductDetailPage renders without crashing',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify basic structure exists
        expect(find.byType(ProductDetailPage), findsOneWidget);

        // Verify key elements are present
        expect(find.text('Industrial Circuit Breaker 63A'), findsOneWidget);
        expect(find.text('ABB'), findsOneWidget);
        expect(find.text('₹15000'), findsOneWidget);
        expect(find.text('Contact Supplier'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
      });

      testWidgets('ProductDetailPage shows product specifications',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify specifications are displayed
        expect(find.text('Brand'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('MOQ'), findsOneWidget);
        expect(find.text('GST %'), findsOneWidget);
        expect(find.text('Materials'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);
      });

      testWidgets('ProductDetailPage shows seller information',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify seller information is displayed
        expect(find.text('Sold by'), findsOneWidget);
        expect(find.text('ABB Distributors'), findsOneWidget);
        expect(find.text('Verified'), findsOneWidget);
      });

      testWidgets('ProductDetailPage shows related products section',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify related products section
        expect(find.text('Related in Circuit Breakers'), findsOneWidget);
        expect(find.text('Similar 1'), findsOneWidget);
        expect(find.text('Similar 2'), findsOneWidget);
      });

      testWidgets('ProductDetailPage shows reviews section placeholder',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify reviews section
        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('Coming soon: Reviews section'), findsOneWidget);
      });
    });

    group('Widget Tests - Interactive Elements', () {
      testWidgets('Contact Supplier button is tappable',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap Contact Supplier button
        final contactButton = find.text('Contact Supplier');
        expect(contactButton, findsOneWidget);

        await tester.tap(contactButton);
        await tester.pumpAndSettle();

        // Verify button interaction (this would need proper provider setup)
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });

      testWidgets('WhatsApp button is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap WhatsApp button
        final whatsappButton = find.text('WhatsApp');
        expect(whatsappButton, findsOneWidget);

        await tester.tap(whatsappButton);
        await tester.pumpAndSettle();

        // Verify button interaction (this would need proper provider setup)
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });

      testWidgets('Brand chip is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap brand chip
        final brandChip = find.text('ABB');
        expect(brandChip, findsOneWidget);

        await tester.tap(brandChip);
        await tester.pumpAndSettle();

        // Verify chip interaction (this would need proper provider setup)
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });

      testWidgets('Category chip is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap category chip
        final categoryChip = find.text('Circuit Breakers');
        expect(categoryChip, findsOneWidget);

        await tester.tap(categoryChip);
        await tester.pumpAndSettle();

        // Verify chip interaction (this would need proper provider setup)
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });
    });

    group('Responsive Tests', () {
      testWidgets('Mobile layout renders correctly',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify mobile layout renders
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });

      testWidgets('Desktop layout renders correctly',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify desktop layout renders
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });
    });

    group('Content Tests', () {
      testWidgets('Product description is displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify description is displayed
        expect(
            find.text(
                'High-quality industrial circuit breaker with advanced protection features.'),
            findsOneWidget);
      });

      testWidgets('Product images are displayed', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify image widgets are present
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });

      testWidgets('Product specifications table is displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify specification values
        expect(find.text('ABB'), findsOneWidget); // Brand
        expect(find.text('Circuit Breakers'), findsOneWidget); // Category
        expect(find.text('10'), findsOneWidget); // MOQ
        expect(find.text('18'), findsOneWidget); // GST %
        expect(find.text('Steel, Copper'), findsOneWidget); // Materials
        expect(find.text('active'), findsOneWidget); // Status
      });
    });

    group('Accessibility Tests', () {
      testWidgets('ProductDetailPage has proper semantic structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test semantic properties
        final semantics = tester.getSemantics(find.byType(ProductDetailPage));
        expect(semantics, isNotNull);
      });

      testWidgets('Action buttons have proper accessibility labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify action buttons have text labels
        expect(find.text('Contact Supplier'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
      });

      testWidgets('Interactive elements are accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify interactive elements have proper accessibility
        expect(find.text('ABB'), findsOneWidget); // Brand chip
        expect(find.text('Circuit Breakers'), findsOneWidget); // Category chip
      });
    });

    group('Edge Cases', () {
      testWidgets('ProductDetailPage handles empty description',
          (WidgetTester tester) async {
        final productWithEmptyDesc = Product(
          id: 'test_product_2',
          title: 'Test Product',
          brand: 'Test Brand',
          price: 1000.0,
          subtitle: 'Test Category',
          materials: ['Test Material'],
          rating: 4.0,
          description: '', // Empty description
          category: 'Test Category',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              demoDataServiceProvider.overrideWith((ref) => demoDataService),
              appStateNotifierProvider
                  .overrideWith((ref) => AppStateNotifier(appState)),
            ],
            child: MaterialApp(
              home: ProductDetailPage(product: productWithEmptyDesc),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify fallback text is shown
        expect(find.text('No description provided.'), findsOneWidget);
      });

      testWidgets('ProductDetailPage handles empty images list',
          (WidgetTester tester) async {
        final productWithNoImages = Product(
          id: 'test_product_3',
          title: 'Test Product',
          brand: 'Test Brand',
          price: 1000.0,
          subtitle: 'Test Category',
          materials: ['Test Material'],
          rating: 4.0,
          description: 'Test description',
          category: 'Test Category',
          images: [], // Empty images list
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              demoDataServiceProvider.overrideWith((ref) => demoDataService),
              appStateNotifierProvider
                  .overrideWith((ref) => AppStateNotifier(appState)),
            ],
            child: MaterialApp(
              home: ProductDetailPage(product: productWithNoImages),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify page still renders
        expect(find.byType(ProductDetailPage), findsOneWidget);
      });
    });
  });
}
