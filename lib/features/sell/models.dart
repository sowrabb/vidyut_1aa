import 'package:vidyut/models/product_status.dart';
export 'package:vidyut/models/product_status.dart';

enum FieldType { text, number, dropdown, boolean, date }

enum AdType { search, category, product }

// Categories & Materials (already present; ensure exported)
const kCategories = <String>[
  'Cables & Wires',
  'Switchgear',
  'Transformers',
  'Meters',
  'Solar & Storage',
  'Lighting',
  'Motors & Drives',
  'Tools & Safety',
  'Services'
];

const kMaterials = <String>['Copper', 'PVC', 'Aluminium', 'FR', 'FRLS', 'XLPE'];

// Product Location model
class ProductLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String? area;
  final String? pincode;

  const ProductLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    this.area,
    this.pincode,
  });

  ProductLocation copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? area,
    String? pincode,
  }) {
    return ProductLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      area: area ?? this.area,
      pincode: pincode ?? this.pincode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'area': area,
      'pincode': pincode,
    };
  }

  factory ProductLocation.fromJson(Map<String, dynamic> json) {
    return ProductLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      state: json['state'] as String,
      area: json['area'] as String?,
      pincode: json['pincode'] as String?,
    );
  }
}

// Seller Profile model
class SellerProfile {
  final String id;
  final String companyName;
  final String gstNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String email;
  final String website;
  final String description;
  final List<String> categories;
  final List<String> materials;
  final String logoUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerProfile({
    this.id = '',
    this.companyName = '',
    this.gstNumber = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.description = '',
    this.categories = const [],
    this.materials = const [],
    this.logoUrl = '',
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SellerProfile copyWith({
    String? id,
    String? companyName,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    String? email,
    String? website,
    String? description,
    List<String>? categories,
    List<String>? materials,
    String? logoUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
      logoUrl: logoUrl ?? this.logoUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
        'gst_number': gstNumber,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phone': phone,
        'email': email,
        'website': website,
        'description': description,
        'categories': categories,
        'materials': materials,
        'logo_url': logoUrl,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory SellerProfile.fromJson(Map<String, dynamic> json) => SellerProfile(
        id: json['id'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
        gstNumber: json['gst_number'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        pincode: json['pincode'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        website: json['website'] as String? ?? '',
        description: json['description'] as String? ?? '',
        categories: List<String>.from(json['categories'] ?? []),
        materials: List<String>.from(json['materials'] ?? []),
        logoUrl: json['logo_url'] as String? ?? '',
        isVerified: json['is_verified'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class CustomFieldDef {
  final String id;
  final String label;
  final FieldType type;
  final List<String> options; // for dropdown type

  const CustomFieldDef({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
  });

  CustomFieldDef copyWith({
    String? id,
    String? label,
    FieldType? type,
    List<String>? options,
  }) {
    return CustomFieldDef(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}

// Product model: add category, status, createdAt, rating (UI only)
class Product {
  final String id;
  String title;
  String brand;
  String subtitle; // brief spec / secondary label
  String category; // NEW (fallback handled below)
  String description;
  List<String> images;
  List<String> documents; // NEW: PDF documents and specifications
  double price;
  int moq;
  double gstRate;
  List<String> materials;
  Map<String, dynamic> customValues;
  ProductStatus status; // NEW
  DateTime createdAt; // NEW
  double rating; // NEW (0..5)
  ProductLocation? location; // NEW

  Product({
    required this.id,
    this.title = '',
    this.brand = '',
    this.subtitle = '',
    this.category = '',
    this.description = '',
    this.images = const [],
    this.documents = const [],
    this.price = 0,
    this.moq = 1,
    this.gstRate = 18,
    this.materials = const [],
    this.customValues = const {},
    this.status = ProductStatus.active,
    DateTime? createdAt,
    this.rating = 0,
    this.location,
  }) : createdAt = createdAt ?? DateTime.now();

  Product copyWith({
    String? id,
    String? title,
    String? brand,
    String? subtitle,
    String? category,
    String? description,
    List<String>? images,
    List<String>? documents,
    double? price,
    int? moq,
    double? gstRate,
    List<String>? materials,
    Map<String, dynamic>? customValues,
    ProductStatus? status,
    DateTime? createdAt,
    double? rating,
    ProductLocation? location,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      description: description ?? this.description,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      price: price ?? this.price,
      moq: moq ?? this.moq,
      gstRate: gstRate ?? this.gstRate,
      materials: materials ?? this.materials,
      customValues: customValues ?? this.customValues,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      location: location ?? this.location,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      moq: json['moq'] as int? ?? json['stock'] as int? ?? 1,
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 18.0,
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      customValues:
          Map<String, dynamic>.from(json['custom_values'] as Map? ?? {}),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ProductStatus.active,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] != null
          ? ProductLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'subtitle': subtitle,
      'category': category,
      'description': description,
      'images': images,
      'documents': documents,
      'price': price,
      'moq': moq,
      'gst_rate': gstRate,
      'materials': materials,
      'custom_values': customValues,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'location': location?.toJson(),
    };
  }
}

// Backward-compat convenience getters for admin pages expecting legacy names
extension ProductCompat on Product {
  String get name => title;
  int get stock => moq;
  String get unit => '';
  String get material => materials.isNotEmpty ? materials.first : '';
}

// Leads: admin-seeded, richer attributes
class Lead {
  final String id;
  final String title;
  final String industry; // e.g., Construction, EPC, MEP
  final List<String> materials;
  final String city;
  final String state;
  final int qty;
  final double turnoverCr; // turnover in Crores (UI)
  final DateTime needBy;
  final String status; // New, Quoted, Won/Lost (UI only)
  final String about; // longer description / notes

  Lead({
    required this.id,
    required this.title,
    required this.industry,
    required this.materials,
    required this.city,
    required this.state,
    required this.qty,
    required this.turnoverCr,
    required this.needBy,
    required this.status,
    this.about = '',
  });

  Lead copyWith({
    String? id,
    String? title,
    String? industry,
    List<String>? materials,
    String? city,
    String? state,
    int? qty,
    double? turnoverCr,
    DateTime? needBy,
    String? status,
    String? about,
  }) {
    return Lead(
      id: id ?? this.id,
      title: title ?? this.title,
      industry: industry ?? this.industry,
      materials: materials ?? this.materials,
      city: city ?? this.city,
      state: state ?? this.state,
      qty: qty ?? this.qty,
      turnoverCr: turnoverCr ?? this.turnoverCr,
      needBy: needBy ?? this.needBy,
      status: status ?? this.status,
      about: about ?? this.about,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'industry': industry,
        'materials': materials,
        'city': city,
        'state': state,
        'qty': qty,
        'turnoverCr': turnoverCr,
        'needBy': needBy.toIso8601String(),
        'status': status,
        'about': about,
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        industry: json['industry'] as String? ?? '',
        materials: List<String>.from(json['materials'] ?? []),
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        qty: json['qty'] as int? ?? 0,
        turnoverCr: (json['turnoverCr'] as num?)?.toDouble() ?? 0.0,
        needBy: DateTime.parse(json['needBy'] as String),
        status: json['status'] as String? ?? 'New',
        about: json['about'] as String? ?? '',
      );
}

// Ad Campaign model
class AdCampaign {
  final String id;
  final AdType type;
  final String term; // search term, category name, or product id
  final int slot; // 1-3 for display order
  final String? productId; // explicit selected product for campaign (optional)
  final String? productTitle; // denormalized for quick display (optional)
  final String? productThumbnail; // denormalized for quick display (optional)

  AdCampaign({
    required this.id,
    required this.type,
    required this.term,
    required this.slot,
    this.productId,
    this.productTitle,
    this.productThumbnail,
  });

  AdCampaign copyWith({
    String? id,
    AdType? type,
    String? term,
    int? slot,
    String? productId,
    String? productTitle,
    String? productThumbnail,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      type: type ?? this.type,
      term: term ?? this.term,
      slot: slot ?? this.slot,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productThumbnail: productThumbnail ?? this.productThumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'term': term,
      'slot': slot,
      'product_id': productId,
      'product_title': productTitle,
      'product_thumbnail': productThumbnail,
    };
  }

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'search');
    final adType = AdType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => AdType.search,
    );
    return AdCampaign(
      id: json['id'] as String,
      type: adType,
      term: json['term'] as String? ?? '',
      slot: (json['slot'] as num?)?.toInt() ?? 1,
      productId: json['product_id'] as String?,
      productTitle: json['product_title'] as String?,
      productThumbnail: json['product_thumbnail'] as String?,
    );
  }
}

// Helpers
extension ProductCategorySafe on Product {
  String get categorySafe => category.isNotEmpty
      ? category
      : (kCategories.contains(subtitle) ? subtitle : kCategories.first);
}
