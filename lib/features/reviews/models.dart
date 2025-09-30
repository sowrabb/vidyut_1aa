import 'dart:convert';

class ReviewSummary {
  final String productId;
  final double average;
  final int totalCount;
  final Map<int, int> countsByStar; // 1..5

  const ReviewSummary({
    required this.productId,
    required this.average,
    required this.totalCount,
    required this.countsByStar,
  });
}

class HelpfulVote {
  final String reviewId;
  final String userId;
  final bool helpful; // true = helpful, false = not helpful (optional usage)

  const HelpfulVote({
    required this.reviewId,
    required this.userId,
    this.helpful = true,
  });

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'userId': userId,
        'helpful': helpful,
      };

  factory HelpfulVote.fromJson(Map<String, dynamic> json) => HelpfulVote(
        reviewId: json['reviewId'] as String,
        userId: json['userId'] as String,
        helpful: (json['helpful'] as bool?) ?? true,
      );
}

class ReviewImage {
  final String url; // absolute URL or storage path
  final int? width;
  final int? height;

  const ReviewImage({required this.url, this.width, this.height});

  Map<String, dynamic> toJson() => {
        'url': url,
        'width': width,
        'height': height,
      };

  factory ReviewImage.fromJson(Map<String, dynamic> json) => ReviewImage(
        url: json['url'] as String,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}

class Review {
  final String id;
  final String productId;
  final String userId;
  final String authorDisplay; // masked if needed
  final int rating; // 1..5
  final String? title;
  final String body;
  final List<ReviewImage> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, bool> helpfulVotesByUser; // userId -> helpful?
  final bool reported; // simple flag for demo
  final Map<String, String>? attributes; // e.g., size/fit/color/variant

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.authorDisplay,
    required this.rating,
    this.title,
    required this.body,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    this.helpfulVotesByUser = const {},
    this.reported = false,
    this.attributes,
  });

  int get helpfulCount => helpfulVotesByUser.values.where((v) => v).length;

  Review copyWith({
    String? id,
    String? productId,
    String? userId,
    String? authorDisplay,
    int? rating,
    String? title,
    String? body,
    List<ReviewImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? helpfulVotesByUser,
    bool? reported,
    Map<String, String>? attributes,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      authorDisplay: authorDisplay ?? this.authorDisplay,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      body: body ?? this.body,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      helpfulVotesByUser: helpfulVotesByUser ?? this.helpfulVotesByUser,
      reported: reported ?? this.reported,
      attributes: attributes ?? this.attributes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'authorDisplay': authorDisplay,
        'rating': rating,
        'title': title,
        'body': body,
        'images': images.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'helpfulVotesByUser': helpfulVotesByUser,
        'reported': reported,
        'attributes': attributes,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        productId: json['productId'] as String,
        userId: json['userId'] as String,
        authorDisplay: json['authorDisplay'] as String,
        rating: json['rating'] as int,
        title: json['title'] as String?,
        body: json['body'] as String,
        images: (json['images'] as List<dynamic>? ?? [])
            .map((e) => ReviewImage.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        helpfulVotesByUser:
            Map<String, bool>.from(json['helpfulVotesByUser'] ?? {}),
        reported: (json['reported'] as bool?) ?? false,
        attributes: (json['attributes'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())),
      );

  @override
  String toString() => jsonEncode(toJson());
}

enum ReviewSort {
  mostRecent,
  mostHelpful,
  highestRating,
  lowestRating,
}

class ReviewListQuery {
  final int page;
  final int pageSize;
  final Set<int> starFilters; // empty means all
  final bool withPhotosOnly;
  final ReviewSort sort;

  const ReviewListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.starFilters = const {},
    this.withPhotosOnly = false,
    this.sort = ReviewSort.mostRecent,
  });
}
