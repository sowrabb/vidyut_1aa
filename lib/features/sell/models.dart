enum FieldType { text, number, dropdown, boolean, date }

// Enums
enum ProductStatus { active, draft, archived }
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
  double price;
  int moq;
  double gstRate;
  List<String> materials;
  Map<String, dynamic> customValues;
  ProductStatus status; // NEW
  DateTime createdAt; // NEW
  double rating; // NEW (0..5)

  Product({
    required this.id,
    this.title = '',
    this.brand = '',
    this.subtitle = '',
    this.category = '',
    this.description = '',
    this.images = const [],
    this.price = 0,
    this.moq = 1,
    this.gstRate = 18,
    this.materials = const [],
    this.customValues = const {},
    this.status = ProductStatus.active,
    DateTime? createdAt,
    this.rating = 0,
  }) : createdAt = createdAt ?? DateTime.now();

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
    double? rating,
  }) {
    return Product(
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
      rating: rating ?? this.rating,
    );
  }
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
}

// Ad Campaign model
class AdCampaign {
  final String id;
  final AdType type;
  final String term; // search term, category name, or product id
  final int slot; // 1-3 for display order

  AdCampaign({
    required this.id,
    required this.type,
    required this.term,
    required this.slot,
  });

  AdCampaign copyWith({
    String? id,
    AdType? type,
    String? term,
    int? slot,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      type: type ?? this.type,
      term: term ?? this.term,
      slot: slot ?? this.slot,
    );
  }
}

// Helpers
extension ProductCategorySafe on Product {
  String get categorySafe => category.isNotEmpty
      ? category
      : (kCategories.contains(subtitle) ? subtitle : kCategories.first);
}
