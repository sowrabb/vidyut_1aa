import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/reviews/models.dart';
import 'package:vidyut/services/reviews_repository.dart';

void main() {
  test('create and list reviews with filters', () async {
    final repo = ReviewsRepository(maxImagesPerReview: 6);
    final pid = 'p1';

    expect(repo.getSummary(pid).totalCount, 0);

    final r1 = Review(
      id: 'r1',
      productId: pid,
      userId: 'u1',
      authorDisplay: 'User 1',
      rating: 5,
      body: 'Great product',
      createdAt: DateTime.now(),
    );
    await repo.createReview(r1);

    final r2 = Review(
      id: 'r2',
      productId: pid,
      userId: 'u2',
      authorDisplay: 'User 2',
      rating: 3,
      body: 'Average',
      images: const [ReviewImage(url: 'https://example.com/img.jpg')],
      createdAt: DateTime.now(),
    );
    await repo.createReview(r2);

    final sum = repo.getSummary(pid);
    expect(sum.totalCount, 2);
    expect(sum.countsByStar[5], 1);
    expect(sum.countsByStar[3], 1);

    final withPhotos = repo.listReviews(pid,
        query: const ReviewListQuery(withPhotosOnly: true));
    expect(withPhotos.length, 1);
    expect(withPhotos.first.id, 'r2');

    await repo.voteReviewHelpful(
        productId: pid, reviewId: 'r1', userId: 'u2', helpful: true);
    final r1listed = repo
        .listReviews(pid, query: const ReviewListQuery())
        .firstWhere((e) => e.id == 'r1');
    expect(r1listed.helpfulCount, 1);
  });
}
