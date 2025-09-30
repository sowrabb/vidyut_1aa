import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/sell/products_list_page.dart';
import 'package:vidyut/features/sell/product_form_page.dart';
import 'package:vidyut/features/sell/models.dart';
import 'package:vidyut/features/sell/store/seller_store.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';

void main() {
  group('Seller Dashboard Product CRUD Tests', () {
    testWidgets('Products list page renders correctly', (tester) async {
      await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: ProductsListPage())));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(ProductsListPage), findsOneWidget);
    });

    testWidgets('Product form page renders for new product', (tester) async {
      await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: ProductFormPage())));
      expect(find.byType(ProductFormPage), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);
    });

    testWidgets('Product form has category and status fields', (tester) async {
      await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: ProductFormPage())));

      // Check for category dropdown
      expect(find.text('Category *'), findsOneWidget);

      // Check for status dropdown
      expect(find.text('Status'), findsOneWidget);

      // Check for submit for approval button
      expect(find.text('Submit for Approval'), findsOneWidget);
    });

    test('ProductStatus enum has all required values', () {
      expect(ProductStatus.values, contains(ProductStatus.active));
      expect(ProductStatus.values, contains(ProductStatus.inactive));
      expect(ProductStatus.values, contains(ProductStatus.pending));
      expect(ProductStatus.values, contains(ProductStatus.draft));
      expect(ProductStatus.values, contains(ProductStatus.archived));
    });

    test('SellerStore has bulk operations methods', () {
      final demoService = LightweightDemoDataService();
      final store = SellerStore(demoService);

      // Test that bulk operations exist
      expect(store.bulkSetStatus, isA<Function>());
      expect(store.bulkDelete, isA<Function>());
      expect(store.bulkEdit, isA<Function>());
      expect(store.duplicateProduct, isA<Function>());
      expect(store.softDeleteProduct, isA<Function>());
      expect(store.hardDeleteProduct, isA<Function>());
    });

    test('Demo data service supports product operations', () {
      final service = LightweightDemoDataService();

      // Test that new methods exist
      expect(service.duplicateProduct, isA<Function>());
      expect(service.softDeleteProduct, isA<Function>());
      expect(service.hardDeleteProduct, isA<Function>());
      expect(service.bulkUpdateStatus, isA<Function>());
      expect(service.bulkDelete, isA<Function>());
      expect(service.bulkEdit, isA<Function>());
    });
  });
}
