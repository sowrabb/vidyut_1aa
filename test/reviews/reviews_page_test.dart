import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/reviews/reviews_page.dart';
import 'package:vidyut/services/reviews_repository.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/reviews/models.dart';

void main() {
  testWidgets('ReviewsPage filters and pagination render', (tester) async {
    final repo = ReviewsRepository();
    for (int i = 0; i < 25; i++) {
      await repo.createReview(Review(
        id: 'r$i',
        productId: 'p1',
        userId: 'u$i',
        authorDisplay: 'U$i',
        rating: (i % 5) + 1,
        body: 'Body $i',
        createdAt: DateTime.now().subtract(Duration(minutes: i)),
      ));
    }

    await tester.pumpWidget(ProviderScope(overrides: [
      reviewsRepositoryProvider.overrideWith((ref) => repo),
    ], child: const MaterialApp(home: ReviewsPage(productId: 'p1'))));

    expect(find.textContaining('Average'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Previous'), findsOneWidget);
  });
}
