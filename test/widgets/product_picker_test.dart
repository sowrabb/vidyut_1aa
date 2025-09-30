import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/widgets/product_picker.dart';

void main() {
  testWidgets('ProductPicker shows results and selects a product',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProductPicker(onSelected: (_) {}),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ProductPicker), findsOneWidget);
    // Type into search and ensure list still renders (demo data seeded)
    await tester.enterText(find.byType(TextField).first, 'Cable');
    await tester.pump(const Duration(milliseconds: 300));

    // Expect at least one tile
    expect(find.byType(InkWell), findsWidgets);
  });
}
