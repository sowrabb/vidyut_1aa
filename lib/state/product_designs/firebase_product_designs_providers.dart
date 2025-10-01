/// Firebase-backed product designs (templates) providers
/// Helps sellers quickly create products using pre-made templates
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_product_designs_providers.g.dart';

/// Model for product design template
class ProductDesign {
  final String id;
  final String name;
  final String description;
  final String category;
  final Map<String, TemplateField> fields;
  final String? thumbnailUrl;
  final bool isActive;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  ProductDesign({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fields,
    this.thumbnailUrl,
    required this.isActive,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory ProductDesign.fromJson(Map<String, dynamic> json) {
    final fieldsMap = json['fields'] as Map<String, dynamic>? ?? {};
    final fields = fieldsMap.map((key, value) {
      return MapEntry(
        key,
        TemplateField.fromJson(value as Map<String, dynamic>),
      );
    });

    return ProductDesign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      fields: fields,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      createdBy: json['created_by'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category,
    'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
    'thumbnail_url': thumbnailUrl,
    'is_active': isActive,
    'usage_count': usageCount,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
    'created_by': createdBy,
  };
}

/// Model for template field
class TemplateField {
  final String label;
  final String fieldType; // text, number, dropdown, textarea
  final dynamic defaultValue;
  final bool required;
  final List<String>? options; // For dropdown fields
  final String? unit; // For number fields (e.g., "meters", "kg")

  TemplateField({
    required this.label,
    required this.fieldType,
    this.defaultValue,
    required this.required,
    this.options,
    this.unit,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      label: json['label'] as String,
      fieldType: json['field_type'] as String,
      defaultValue: json['default_value'],
      required: json['required'] as bool? ?? false,
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'field_type': fieldType,
    'default_value': defaultValue,
    'required': required,
    if (options != null) 'options': options,
    if (unit != null) 'unit': unit,
  };
}

/// Stream all active product designs
@riverpod
Stream<List<ProductDesign>> firebaseActiveProductDesigns(
  FirebaseActiveProductDesignsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('product_designs')
      .where('is_active', isEqualTo: true)
      .orderBy('usage_count', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductDesign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream product designs by category
@riverpod
Stream<List<ProductDesign>> firebaseProductDesignsByCategory(
  FirebaseProductDesignsByCategoryRef ref,
  String category,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('product_designs')
      .where('category', isEqualTo: category)
      .where('is_active', isEqualTo: true)
      .orderBy('usage_count', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductDesign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream all product designs (admin view)
@riverpod
Stream<List<ProductDesign>> firebaseAllProductDesigns(
  FirebaseAllProductDesignsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('product_designs')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductDesign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single product design
@riverpod
Stream<ProductDesign?> firebaseProductDesign(
  FirebaseProductDesignRef ref,
  String designId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('product_designs')
      .doc(designId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return ProductDesign.fromJson({...data, 'id': doc.id});
  });
}

/// Service for product design operations
@riverpod
ProductDesignService productDesignService(ProductDesignServiceRef ref) {
  return ProductDesignService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Product design service class
class ProductDesignService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  ProductDesignService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a new product design template (admin only)
  Future<String> createDesign({
    required String name,
    required String description,
    required String category,
    required Map<String, TemplateField> fields,
    String? thumbnailUrl,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final designData = {
      'name': name,
      'description': description,
      'category': category,
      'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
      'thumbnail_url': thumbnailUrl,
      'is_active': true,
      'usage_count': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'created_by': userId,
    };

    final docRef = await firestore.collection('product_designs').add(designData);
    return docRef.id;
  }

  /// Update a product design (admin only)
  Future<void> updateDesign({
    required String designId,
    String? name,
    String? description,
    String? category,
    Map<String, TemplateField>? fields,
    String? thumbnailUrl,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (category != null) updateData['category'] = category;
    if (fields != null) {
      updateData['fields'] = fields.map((key, value) => MapEntry(key, value.toJson()));
    }
    if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
    if (isActive != null) updateData['is_active'] = isActive;

    await firestore
        .collection('product_designs')
        .doc(designId)
        .update(updateData);
  }

  /// Delete a product design (admin only)
  Future<void> deleteDesign(String designId) async {
    await firestore.collection('product_designs').doc(designId).delete();
  }

  /// Toggle active status
  Future<void> toggleActive(String designId) async {
    final doc = await firestore
        .collection('product_designs')
        .doc(designId)
        .get();

    if (doc.exists) {
      final currentActive = doc.data()?['is_active'] as bool? ?? false;
      await firestore.collection('product_designs').doc(designId).update({
        'is_active': !currentActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Increment usage count when template is used
  Future<void> trackUsage(String designId) async {
    await firestore.collection('product_designs').doc(designId).update({
      'usage_count': FieldValue.increment(1),
      'last_used_at': FieldValue.serverTimestamp(),
    });
  }

  /// Duplicate a product design
  Future<String> duplicateDesign(String designId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final doc = await firestore
        .collection('product_designs')
        .doc(designId)
        .get();

    if (!doc.exists) throw Exception('Design not found');

    final data = doc.data()!;
    
    // Create copy with "(Copy)" suffix
    final newDesignData = {
      ...data,
      'name': '${data['name']} (Copy)',
      'usage_count': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'created_by': userId,
    };

    final docRef = await firestore
        .collection('product_designs')
        .add(newDesignData);

    return docRef.id;
  }

  /// Get designs by category (for dropdown)
  Future<List<ProductDesign>> getDesignsByCategory(String category) async {
    final snapshot = await firestore
        .collection('product_designs')
        .where('category', isEqualTo: category)
        .where('is_active', isEqualTo: true)
        .orderBy('usage_count', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductDesign.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Get most popular designs
  Future<List<ProductDesign>> getPopularDesigns({int limit = 10}) async {
    final snapshot = await firestore
        .collection('product_designs')
        .where('is_active', isEqualTo: true)
        .orderBy('usage_count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductDesign.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Initialize default templates (one-time setup)
  Future<void> initializeDefaultTemplates() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('Admin not authenticated');

    final defaultTemplates = [
      {
        'name': 'Electrical Wire Template',
        'description': 'Standard template for electrical wires and cables',
        'category': 'Wires & Cables',
        'fields': {
          'wire_type': {
            'label': 'Wire Type',
            'field_type': 'dropdown',
            'default_value': 'Copper',
            'required': true,
            'options': ['Copper', 'Aluminum', 'Copper-clad Aluminum'],
          },
          'gauge': {
            'label': 'Gauge/Size',
            'field_type': 'text',
            'default_value': '14 AWG',
            'required': true,
          },
          'length': {
            'label': 'Length',
            'field_type': 'number',
            'default_value': 100,
            'required': true,
            'unit': 'meters',
          },
          'insulation': {
            'label': 'Insulation Material',
            'field_type': 'dropdown',
            'default_value': 'PVC',
            'required': true,
            'options': ['PVC', 'XLPE', 'Rubber', 'Teflon'],
          },
          'voltage_rating': {
            'label': 'Voltage Rating',
            'field_type': 'text',
            'default_value': '600V',
            'required': true,
          },
        },
      },
      {
        'name': 'Circuit Breaker Template',
        'description': 'Template for circuit breakers and MCBs',
        'category': 'Circuit Breakers',
        'fields': {
          'breaker_type': {
            'label': 'Breaker Type',
            'field_type': 'dropdown',
            'default_value': 'MCB',
            'required': true,
            'options': ['MCB', 'MCCB', 'RCCB', 'RCBO'],
          },
          'poles': {
            'label': 'Number of Poles',
            'field_type': 'dropdown',
            'default_value': '2',
            'required': true,
            'options': ['1', '2', '3', '4'],
          },
          'current_rating': {
            'label': 'Current Rating',
            'field_type': 'number',
            'default_value': 16,
            'required': true,
            'unit': 'Amperes',
          },
          'trip_curve': {
            'label': 'Trip Curve',
            'field_type': 'dropdown',
            'default_value': 'C',
            'required': true,
            'options': ['B', 'C', 'D', 'K'],
          },
          'breaking_capacity': {
            'label': 'Breaking Capacity',
            'field_type': 'text',
            'default_value': '6kA',
            'required': true,
          },
        },
      },
      {
        'name': 'LED Light Template',
        'description': 'Template for LED lights and fixtures',
        'category': 'Lights',
        'fields': {
          'light_type': {
            'label': 'Light Type',
            'field_type': 'dropdown',
            'default_value': 'Bulb',
            'required': true,
            'options': ['Bulb', 'Tube', 'Panel', 'Strip', 'Flood'],
          },
          'wattage': {
            'label': 'Wattage',
            'field_type': 'number',
            'default_value': 9,
            'required': true,
            'unit': 'Watts',
          },
          'color_temperature': {
            'label': 'Color Temperature',
            'field_type': 'dropdown',
            'default_value': 'Warm White',
            'required': true,
            'options': ['Warm White (3000K)', 'Cool White (6000K)', 'Daylight (6500K)'],
          },
          'lumens': {
            'label': 'Lumens',
            'field_type': 'number',
            'default_value': 900,
            'required': true,
            'unit': 'lm',
          },
          'base_type': {
            'label': 'Base Type',
            'field_type': 'dropdown',
            'default_value': 'B22',
            'required': true,
            'options': ['B22', 'E27', 'E14', 'GU10'],
          },
        },
      },
    ];

    final batch = firestore.batch();
    for (final template in defaultTemplates) {
      final docRef = firestore.collection('product_designs').doc();
      batch.set(docRef, {
        ...template,
        'is_active': true,
        'usage_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'created_by': userId,
      });
    }

    await batch.commit();
  }

  /// Create product from template
  Future<Map<String, dynamic>> createProductFromTemplate(String designId) async {
    final doc = await firestore
        .collection('product_designs')
        .doc(designId)
        .get();

    if (!doc.exists) throw Exception('Template not found');

    final design = ProductDesign.fromJson({...doc.data()!, 'id': doc.id});

    // Track usage
    await trackUsage(designId);

    // Generate product data from template
    final productData = <String, dynamic>{
      'title': design.name,
      'category': design.category,
      'description': design.description,
    };

    // Add default values from template fields
    for (final entry in design.fields.entries) {
      if (entry.value.defaultValue != null) {
        productData[entry.key] = entry.value.defaultValue;
      }
    }

    return productData;
  }
}




