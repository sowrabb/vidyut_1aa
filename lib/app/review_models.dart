/// Simple Review model for unified providers
/// This is a temporary model until we can properly integrate with the existing review system

class Review {
  final String id;
  final String productId;
  final String userId;
  final String authorDisplay;
  final int rating; // 1-5
  final String? title;
  final String body;
  final List<ReviewImage> images;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.authorDisplay,
    required this.rating,
    this.title,
    required this.body,
    required this.images,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'authorDisplay': authorDisplay,
        'rating': rating,
        'title': title,
        'body': body,
        'images': images.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String? ?? '',
        productId: json['productId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        authorDisplay: json['authorDisplay'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        title: json['title'] as String?,
        body: json['body'] as String? ?? '',
        images: (json['images'] as List<dynamic>?)
                ?.map((i) => ReviewImage.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}

class ReviewImage {
  final String url;
  final int? width;
  final int? height;

  const ReviewImage({
    required this.url,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'width': width,
        'height': height,
      };

  factory ReviewImage.fromJson(Map<String, dynamic> json) => ReviewImage(
        url: json['url'] as String? ?? '',
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}
