import 'package:flutter/foundation.dart';
import '../features/reviews/models.dart';

/// Simple in-memory reviews repository for demo/testing.
/// Can be swapped with a backend implementation later.
class ReviewsRepository extends ChangeNotifier {
  final Map<String, List<Review>> _reviewsByProduct = {};

  // Config
  final int maxImagesPerReview;

  ReviewsRepository({this.maxImagesPerReview = 6});

  ReviewSummary getSummary(String productId) {
    final list = List<Review>.from(_reviewsByProduct[productId] ?? const []);
    if (list.isEmpty) {
      return ReviewSummary(
        productId: productId,
        average: 0,
        totalCount: 0,
        countsByStar: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    var sum = 0;
    for (final r in list) {
      counts[r.rating] = (counts[r.rating] ?? 0) + 1;
      sum += r.rating;
    }

    return ReviewSummary(
      productId: productId,
      average: sum / list.length,
      totalCount: list.length,
      countsByStar: counts,
    );
  }

  List<Review> listReviews(
    String productId, {
    required ReviewListQuery query,
  }) {
    List<Review> list = List.of(_reviewsByProduct[productId] ?? const []);

    if (query.starFilters.isNotEmpty) {
      list = list.where((r) => query.starFilters.contains(r.rating)).toList();
    }
    if (query.withPhotosOnly) {
      list = list.where((r) => r.images.isNotEmpty).toList();
    }

    switch (query.sort) {
      case ReviewSort.mostRecent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSort.mostHelpful:
        list.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
      case ReviewSort.highestRating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSort.lowestRating:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    final start = (query.page - 1) * query.pageSize;
    if (start >= list.length) return const [];
    final end = (start + query.pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  Review? getUserReview(String productId, String userId) {
    final list = _reviewsByProduct[productId];
    if (list == null) return null;
    for (final r in list) {
      if (r.userId == userId) return r;
    }
    return null;
  }

  Future<Review> createReview(Review review) async {
    final images = review.images;
    if (images.length > maxImagesPerReview) {
      throw ArgumentError('Too many images. Max: $maxImagesPerReview');
    }

    final list = _reviewsByProduct.putIfAbsent(review.productId, () => []);
    if (list.any((r) => r.userId == review.userId)) {
      throw StateError('Duplicate review for this user and product');
    }
    list.add(review);
    notifyListeners();
    return review;
  }

  Future<Review> updateReview(Review updated) async {
    final list = _reviewsByProduct[updated.productId];
    if (list == null) throw StateError('Product has no reviews');
    final idx = list.indexWhere((r) => r.id == updated.id);
    if (idx == -1) throw StateError('Review not found');
    list[idx] = updated.copyWith(updatedAt: DateTime.now());
    notifyListeners();
    return list[idx];
  }

  Future<void> voteReviewHelpful({
    required String productId,
    required String reviewId,
    required String userId,
    required bool helpful,
  }) async {
    final list = _reviewsByProduct[productId];
    if (list == null) return;
    final idx = list.indexWhere((r) => r.id == reviewId);
    if (idx == -1) return;
    final r = list[idx];
    final votes = Map<String, bool>.from(r.helpfulVotesByUser);
    votes[userId] = helpful;
    list[idx] = r.copyWith(helpfulVotesByUser: votes);
    notifyListeners();
  }

  Future<void> reportReview({
    required String productId,
    required String reviewId,
  }) async {
    final list = _reviewsByProduct[productId];
    if (list == null) return;
    final idx = list.indexWhere((r) => r.id == reviewId);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(reported: true);
    notifyListeners();
  }
}
