import 'package:flutter/foundation.dart';
import 'package:vidyut/models/product_status.dart';

/// Product Status
/// Uses shared ProductStatus

/// Product Model for Admin
@immutable
class Product {
  final String id;
  final String title;
  final String brand;
  final String subtitle;
  final String category;
  final String description;
  final List<String> images;
  final double price;
  final int moq;
  final double gstRate;
  final List<String> materials;
  final Map<String, dynamic> customValues;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double rating;
  final int viewCount;
  final int orderCount;

  const Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.images,
    required this.price,
    required this.moq,
    required this.gstRate,
    required this.materials,
    required this.customValues,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.rating,
    required this.viewCount,
    required this.orderCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'brand': brand,
        'subtitle': subtitle,
        'category': category,
        'description': description,
        'images': images,
        'price': price,
        'moq': moq,
        'gst_rate': gstRate,
        'materials': materials,
        'custom_values': customValues,
        'status': status.value,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        'rating': rating,
        'view_count': viewCount,
        'order_count': orderCount,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        title: json['title'] as String,
        brand: json['brand'] as String,
        subtitle: json['subtitle'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        images: List<String>.from(json['images'] ?? []),
        price: (json['price'] as num).toDouble(),
        moq: json['moq'] as int,
        gstRate: (json['gst_rate'] as num).toDouble(),
        materials: List<String>.from(json['materials'] ?? []),
        customValues: Map<String, dynamic>.from(json['custom_values'] ?? {}),
        status: ProductStatus.fromString(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        rating: (json['rating'] as num).toDouble(),
        viewCount: json['view_count'] as int,
        orderCount: json['order_count'] as int,
      );

  Product copyWith({
    String? id,
    String? title,
    String? brand,
    String? subtitle,
    String? category,
    String? description,
    List<String>? images,
    double? price,
    int? moq,
    double? gstRate,
    List<String>? materials,
    Map<String, dynamic>? customValues,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? viewCount,
    int? orderCount,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        brand: brand ?? this.brand,
        subtitle: subtitle ?? this.subtitle,
        category: category ?? this.category,
        description: description ?? this.description,
        images: images ?? this.images,
        price: price ?? this.price,
        moq: moq ?? this.moq,
        gstRate: gstRate ?? this.gstRate,
        materials: materials ?? this.materials,
        customValues: customValues ?? this.customValues,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        rating: rating ?? this.rating,
        viewCount: viewCount ?? this.viewCount,
        orderCount: orderCount ?? this.orderCount,
      );
}

/// Create Product Request
@immutable
class CreateProductRequest {
  final String title;
  final String brand;
  final String subtitle;
  final String category;
  final String description;
  final List<String> images;
  final double price;
  final int moq;
  final double gstRate;
  final List<String> materials;
  final Map<String, dynamic> customValues;
  final ProductStatus status;

  const CreateProductRequest({
    required this.title,
    required this.brand,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.images,
    required this.price,
    required this.moq,
    required this.gstRate,
    required this.materials,
    required this.customValues,
    this.status = ProductStatus.active,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'brand': brand,
        'subtitle': subtitle,
        'category': category,
        'description': description,
        'images': images,
        'price': price,
        'moq': moq,
        'gst_rate': gstRate,
        'materials': materials,
        'custom_values': customValues,
        'status': status.value,
      };
}

/// Update Product Request
@immutable
class UpdateProductRequest {
  final String? title;
  final String? brand;
  final String? subtitle;
  final String? category;
  final String? description;
  final List<String>? images;
  final double? price;
  final int? moq;
  final double? gstRate;
  final List<String>? materials;
  final Map<String, dynamic>? customValues;
  final ProductStatus? status;

  const UpdateProductRequest({
    this.title,
    this.brand,
    this.subtitle,
    this.category,
    this.description,
    this.images,
    this.price,
    this.moq,
    this.gstRate,
    this.materials,
    this.customValues,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (brand != null) 'brand': brand,
        if (subtitle != null) 'subtitle': subtitle,
        if (category != null) 'category': category,
        if (description != null) 'description': description,
        if (images != null) 'images': images,
        if (price != null) 'price': price,
        if (moq != null) 'moq': moq,
        if (gstRate != null) 'gst_rate': gstRate,
        if (materials != null) 'materials': materials,
        if (customValues != null) 'custom_values': customValues,
        if (status != null) 'status': status!.value,
      };
}

/// Product List Response
@immutable
class ProductListResponse {
  final List<Product> products;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  const ProductListResponse({
    required this.products,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        products:
            (json['products'] as List).map((p) => Product.fromJson(p)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

/// Category Model
@immutable
class Category {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (parentId != null) 'parent_id': parentId,
        'sort_order': sortOrder,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        parentId: json['parent_id'] as String?,
        sortOrder: json['sort_order'] as int,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
