/// Firebase-backed reviews and ratings providers
/// Replaces in-memory review system with Firestore real-time sync
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/reviews/models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_reviews_providers.g.dart';

/// Stream all reviews for a product
@riverpod
Stream<List<Review>> firebaseProductReviews(
  FirebaseProductReviewsRef ref,
  String productId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('reviews')
      .where('product_id', isEqualTo: productId)
      .where('status', isEqualTo: 'published')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Review.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream reviews by user
@riverpod
Stream<List<Review>> firebaseUserReviews(FirebaseUserReviewsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('reviews')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Review.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get review summary for a product
@riverpod
Stream<ReviewSummary> firebaseReviewSummary(
  FirebaseReviewSummaryRef ref,
  String productId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('products')
      .doc(productId)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) {
      return ReviewSummary(
        productId: productId,
        average: 0.0,
        totalCount: 0,
        countsByStar: {},
      );
    }

    // Get all reviews for this product
    final reviewsSnapshot = await firestore
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .where('status', isEqualTo: 'published')
        .get();

    final reviews = reviewsSnapshot.docs.map((d) {
      final data = d.data();
      return Review.fromJson({...data, 'id': d.id});
    }).toList();

    if (reviews.isEmpty) {
      return ReviewSummary(
        productId: productId,
        average: 0.0,
        totalCount: 0,
        countsByStar: {},
      );
    }

    // Calculate summary
    final countsByStar = <int, int>{};
    for (int star = 1; star <= 5; star++) {
      countsByStar[star] = reviews.where((r) => r.rating == star).length;
    }

    final totalRating = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    final average = totalRating / reviews.length;

    return ReviewSummary(
      productId: productId,
      average: average,
      totalCount: reviews.length,
      countsByStar: countsByStar,
    );
  });
}

/// Stream paginated reviews with filters
/// Note: This uses the existing ReviewListQuery model from features/reviews/models.dart
@riverpod
Stream<List<Review>> firebaseFilteredReviews(
  FirebaseFilteredReviewsRef ref,
  ReviewListQuery query,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  // Note: ReviewListQuery doesn't have productId, so we'll need to get it from context
  // For now, returning all reviews with filters
  Query reviewsQuery = firestore
      .collection('reviews')
      .where('status', isEqualTo: 'published');

  // Filter by star rating if specified
  if (query.starFilters.isNotEmpty) {
    reviewsQuery = reviewsQuery.where('rating', whereIn: query.starFilters.toList());
  }

  // Filter by photos if specified
  if (query.withPhotosOnly) {
    reviewsQuery = reviewsQuery.where('has_images', isEqualTo: true);
  }

  // Sort
  switch (query.sort) {
    case ReviewSort.mostRecent:
      reviewsQuery = reviewsQuery.orderBy('created_at', descending: true);
      break;
    case ReviewSort.mostHelpful:
      reviewsQuery = reviewsQuery.orderBy('helpful_count', descending: true);
      break;
    case ReviewSort.highestRating:
      reviewsQuery = reviewsQuery.orderBy('rating', descending: true);
      break;
    case ReviewSort.lowestRating:
      reviewsQuery = reviewsQuery.orderBy('rating', descending: false);
      break;
  }

  // Limit results
  reviewsQuery = reviewsQuery.limit(query.pageSize);

  return reviewsQuery.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Review.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Service for review operations
@riverpod
ReviewService reviewService(ReviewServiceRef ref) {
  return ReviewService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Review service class
class ReviewService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  ReviewService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Submit a new review
  Future<String> submitReview({
    required String productId,
    required int rating,
    String? title,
    required String body,
    List<String> imageUrls = const [],
    Map<String, String>? attributes,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Check if user already reviewed this product
    final existingReview = await firestore
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('You have already reviewed this product');
    }

    // Create review
    final reviewData = {
      'product_id': productId,
      'user_id': userId,
      'author_display': 'Anonymous User', // TODO: Get from user profile
      'rating': rating,
      'title': title,
      'body': body,
      'images': imageUrls.map((url) => {
        'url': url,
        'width': 400,
        'height': 400,
      }).toList(),
      'has_images': imageUrls.isNotEmpty,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'helpful_votes': <String, bool>{},
      'helpful_count': 0,
      'reported': false,
      'status': 'published', // Auto-approve for now, can add moderation later
      'attributes': attributes ?? {},
    };

    final docRef = await firestore.collection('reviews').add(reviewData);

    // Update product rating
    await _updateProductRating(productId);

    return docRef.id;
  }

  /// Update an existing review
  Future<void> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? body,
    List<String>? imageUrls,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final doc = await reviewRef.get();

    if (!doc.exists) throw Exception('Review not found');

    // Verify ownership
    final reviewUserId = doc.data()?['user_id'] as String?;
    if (reviewUserId != userId) {
      throw Exception('Not authorized to update this review');
    }

    final updateData = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (rating != null) updateData['rating'] = rating;
    if (title != null) updateData['title'] = title;
    if (body != null) updateData['body'] = body;
    if (imageUrls != null) {
      updateData['images'] = imageUrls.map((url) => {
        'url': url,
        'width': 400,
        'height': 400,
      }).toList();
      updateData['has_images'] = imageUrls.isNotEmpty;
    }

    await reviewRef.update(updateData);

    // Update product rating if rating changed
    if (rating != null) {
      final productId = doc.data()?['product_id'] as String?;
      if (productId != null) {
        await _updateProductRating(productId);
      }
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final doc = await reviewRef.get();

    if (!doc.exists) throw Exception('Review not found');

    // Verify ownership
    final reviewUserId = doc.data()?['user_id'] as String?;
    if (reviewUserId != userId) {
      throw Exception('Not authorized to delete this review');
    }

    final productId = doc.data()?['product_id'] as String?;

    await reviewRef.delete();

    // Update product rating
    if (productId != null) {
      await _updateProductRating(productId);
    }
  }

  /// Vote a review as helpful
  Future<void> voteHelpful(String reviewId, bool isHelpful) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = firestore.collection('reviews').doc(reviewId);
    
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(reviewRef);
      if (!doc.exists) throw Exception('Review not found');

      final helpfulVotes = Map<String, bool>.from(doc.data()?['helpful_votes'] ?? {});
      final currentVote = helpfulVotes[userId];

      // Update vote
      helpfulVotes[userId] = isHelpful;

      // Calculate new helpful count
      final helpfulCount = helpfulVotes.values.where((v) => v).length;

      transaction.update(reviewRef, {
        'helpful_votes.$userId': isHelpful,
        'helpful_count': helpfulCount,
      });
    });
  }

  /// Report a review (admin moderation)
  Future<void> reportReview(String reviewId, String reason) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = firestore.collection('reviews').doc(reviewId);
    
    await reviewRef.update({
      'reported': true,
      'report_reason': reason,
      'reported_by': userId,
      'reported_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: Approve a review
  Future<void> approveReview(String reviewId) async {
    await firestore.collection('reviews').doc(reviewId).update({
      'status': 'published',
      'moderated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: Hide a review
  Future<void> hideReview(String reviewId) async {
    await firestore.collection('reviews').doc(reviewId).update({
      'status': 'hidden',
      'moderated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: Remove a review
  Future<void> removeReview(String reviewId) async {
    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final doc = await reviewRef.get();
    
    if (doc.exists) {
      final productId = doc.data()?['product_id'] as String?;
      
      await reviewRef.update({
        'status': 'removed',
        'moderated_at': FieldValue.serverTimestamp(),
      });

      // Update product rating
      if (productId != null) {
        await _updateProductRating(productId);
      }
    }
  }

  /// Update product's average rating
  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot = await firestore
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .where('status', isEqualTo: 'published')
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      // No reviews, set rating to 0
      await firestore.collection('products').doc(productId).update({
        'rating': 0.0,
        'review_count': 0,
      });
      return;
    }

    final reviews = reviewsSnapshot.docs;
    final totalRating = reviews.fold<int>(
      0,
      (sum, doc) => sum + (doc.data()['rating'] as int? ?? 0),
    );
    final average = totalRating / reviews.length;

    await firestore.collection('products').doc(productId).update({
      'rating': average,
      'review_count': reviews.length,
    });
  }

  /// Get reviews for a seller (all their products)
  Future<List<Review>> getSellerReviews(String sellerId) async {
    // Get seller's products
    final productsSnapshot = await firestore
        .collection('products')
        .where('seller_id', isEqualTo: sellerId)
        .get();

    final productIds = productsSnapshot.docs.map((doc) => doc.id).toList();

    if (productIds.isEmpty) return [];

    // Get reviews for these products (Firestore limit: 10 items in whereIn)
    final reviewsSnapshot = await firestore
        .collection('reviews')
        .where('product_id', whereIn: productIds.take(10).toList())
        .where('status', isEqualTo: 'published')
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    return reviewsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Review.fromJson({...data, 'id': doc.id});
    }).toList();
  }
}

