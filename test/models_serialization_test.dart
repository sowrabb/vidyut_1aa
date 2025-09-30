import 'package:flutter_test/flutter_test.dart';

import 'package:vidyut/features/sell/models.dart' as sell;
import 'package:vidyut/features/profile/models/user_models.dart';
import 'package:vidyut/features/reviews/models.dart' as reviews;
import 'package:vidyut/models/product_status.dart';

void main() {
  group('ProductStatus enum', () {
    test('fromString parses known values', () {
      expect(ProductStatus.fromString('active'), ProductStatus.active);
      expect(ProductStatus.fromString('draft'), ProductStatus.draft);
      expect(ProductStatus.fromString('archived'), ProductStatus.archived);
    });

    test('fromString falls back to draft on unknown', () {
      expect(ProductStatus.fromString('unknown'), ProductStatus.draft);
    });
  });

  group('sell.Product serialization', () {
    test('toJson/fromJson roundtrip (minimal)', () {
      final product = sell.Product(id: 'p1');
      final json = product.toJson();
      final parsed = sell.Product.fromJson({
        'id': json['id'],
        'title': json['title'],
        'brand': json['brand'],
        'subtitle': json['subtitle'],
        'category': json['category'],
        'description': json['description'],
        'images': json['images'],
        'documents': json['documents'],
        'price': json['price'],
        'moq': json['moq'],
        'gst_rate': json['gst_rate'],
        'materials': json['materials'],
        'custom_values': json['custom_values'],
        'status': json['status'],
        'created_at': json['created_at'],
        'rating': json['rating'],
        'location': json['location'],
      });
      expect(parsed.id, product.id);
      expect(parsed.status, ProductStatus.active);
    });
  });

  group('UserProfile serialization', () {
    test('toJson/fromJson roundtrip', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'u1',
        name: 'Alice',
        email: 'a@x.com',
        phone: '123',
        createdAt: now,
        updatedAt: now,
      );
      final json = profile.toJson();
      final parsed = UserProfile.fromJson(json);
      expect(parsed.id, profile.id);
      expect(parsed.name, profile.name);
      expect(parsed.email, profile.email);
    });
  });

  group('reviews.Review serialization', () {
    test('toJson/fromJson roundtrip (simple)', () {
      final now = DateTime.now();
      final review = reviews.Review(
        id: 'r1',
        productId: 'p1',
        userId: 'u1',
        authorDisplay: 'A***',
        rating: 5,
        body: 'Great product',
        createdAt: now,
      );
      final json = review.toJson();
      final parsed = reviews.Review.fromJson(json);
      expect(parsed.id, review.id);
      expect(parsed.rating, 5);
      expect(parsed.body, 'Great product');
    });
  });
}


