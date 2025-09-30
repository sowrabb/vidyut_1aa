import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/widgets/product_image_gallery.dart';

void main() {
  testWidgets('thumbnails navigate to selected image', (tester) async {
    final images = List<String>.generate(3, (i) => 'assets/logo.png');
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: ProductImageGallery(imageUrls: images),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Product image 1 of 3'), findsOneWidget);

    // Tap second thumbnail via semantics label
    await tester.tap(find.bySemanticsLabel('Thumbnail 2 of 3'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Product image 2 of 3'), findsOneWidget);
  }, skip: true);

  testWidgets('arrow buttons are present when multiple images', (tester) async {
    final images = List<String>.generate(2, (i) => 'assets/logo.png');
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: ProductImageGallery(imageUrls: images),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  }, skip: true);
}
