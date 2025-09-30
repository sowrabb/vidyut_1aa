import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/reviews/product_reviews_card.dart';
import 'package:vidyut/features/sell/models.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/services/reviews_repository.dart';
import 'package:vidyut/features/reviews/models.dart';

void main() {
  testWidgets('ProductReviewsCard renders and shows empty state',
      (tester) async {
    final product = Product(
        id: 'p1',
        title: 'T',
        brand: 'B',
        category: 'Cables & Wires',
        price: 10);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          reviewsRepositoryProvider.overrideWith((ref) => ReviewsRepository()),
        ],
        child: MaterialApp(
            home: Scaffold(body: ProductReviewsCard(product: product)))));

    expect(find.text('Reviews'), findsOneWidget);
    expect(find.textContaining('No reviews yet'), findsOneWidget);
  });

  testWidgets('ProductReviewsCard shows a review', (tester) async {
    final product = Product(
        id: 'p1',
        title: 'T',
        brand: 'B',
        category: 'Cables & Wires',
        price: 10);
    final repo = ReviewsRepository();
    await repo.createReview(Review(
        id: 'r1',
        productId: 'p1',
        userId: 'u1',
        authorDisplay: 'U1',
        rating: 5,
        body: 'Nice',
        createdAt: DateTime.now()));

    await tester.pumpWidget(ProviderScope(
        overrides: [
          reviewsRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: MaterialApp(
            home: Scaffold(body: ProductReviewsCard(product: product)))));

    expect(find.textContaining('Nice'), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
  });
}
