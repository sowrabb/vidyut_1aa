/// Firebase-backed product providers for sellers
/// Replaces in-memory product management with Firestore writes
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sell/models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_products_providers.g.dart';

/// Stream all products for the current seller
@riverpod
Stream<List<Product>> firebaseSellerProducts(FirebaseSellerProductsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('products')
      .where('seller_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream all active products (for buyers/users)
@riverpod
Stream<List<Product>> firebaseActiveProducts(FirebaseActiveProductsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('products')
      .where('status', isEqualTo: 'active')
      .orderBy('created_at', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream products by category
@riverpod
Stream<List<Product>> firebaseProductsByCategory(
  FirebaseProductsByCategoryRef ref,
  String category,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('products')
      .where('category', isEqualTo: category)
      .where('status', isEqualTo: 'active')
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single product by ID
@riverpod
Stream<Product?> firebaseProduct(FirebaseProductRef ref, String productId) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('products')
      .doc(productId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Product.fromJson({...data, 'id': doc.id});
  });
}

/// Service for product CRUD operations
@riverpod
ProductService productService(ProductServiceRef ref) {
  return ProductService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Product service class
class ProductService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  ProductService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a new product
  Future<String> createProduct(Product product) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final productData = {
      'title': product.title,
      'brand': product.brand ?? '',
      'subtitle': product.subtitle ?? '',
      'category': product.category,
      'description': product.description ?? '',
      'images': product.images,
      'documents': product.documents,
      'price': product.price,
      'moq': product.moq,
      'gst_rate': product.gstRate,
      'materials': product.materials,
      'custom_values': product.customValues ?? {},
      'status': product.status.name,
      'seller_id': userId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'rating': product.rating ?? 0.0,
      'view_count': 0,
      'order_count': 0,
      if (product.location != null) ...{
        'location': {
          'latitude': product.location!.latitude,
          'longitude': product.location!.longitude,
          'city': product.location!.city,
          'state': product.location!.state,
          'area': product.location!.area,
          'pincode': product.location!.pincode,
        },
      },
    };

    final docRef = await firestore.collection('products').add(productData);
    return docRef.id;
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final productRef = firestore.collection('products').doc(product.id);
    final doc = await productRef.get();

    // Verify ownership
    if (doc.exists) {
      final sellerId = doc.data()?['seller_id'] as String?;
      if (sellerId != userId) {
        throw Exception('Not authorized to update this product');
      }
    }

    final productData = {
      'title': product.title,
      'brand': product.brand ?? '',
      'subtitle': product.subtitle ?? '',
      'category': product.category,
      'description': product.description ?? '',
      'images': product.images,
      'documents': product.documents,
      'price': product.price,
      'moq': product.moq,
      'gst_rate': product.gstRate,
      'materials': product.materials,
      'custom_values': product.customValues ?? {},
      'status': product.status.name,
      'updated_at': FieldValue.serverTimestamp(),
      'rating': product.rating ?? 0.0,
      if (product.location != null) ...{
        'location': {
          'latitude': product.location!.latitude,
          'longitude': product.location!.longitude,
          'city': product.location!.city,
          'state': product.location!.state,
          'area': product.location!.area,
          'pincode': product.location!.pincode,
        },
      },
    };

    await productRef.update(productData);
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final productRef = firestore.collection('products').doc(productId);
    final doc = await productRef.get();

    // Verify ownership
    if (doc.exists) {
      final sellerId = doc.data()?['seller_id'] as String?;
      if (sellerId != userId) {
        throw Exception('Not authorized to delete this product');
      }
    }

    await productRef.delete();
  }

  /// Duplicate a product
  Future<String> duplicateProduct(String productId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final productRef = firestore.collection('products').doc(productId);
    final doc = await productRef.get();

    if (!doc.exists) throw Exception('Product not found');

    // Verify ownership
    final sellerId = doc.data()?['seller_id'] as String?;
    if (sellerId != userId) {
      throw Exception('Not authorized to duplicate this product');
    }

    final data = doc.data()!;
    final duplicatedData = {
      ...data,
      'title': '${data['title']} (Copy)',
      'status': 'draft',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'view_count': 0,
      'order_count': 0,
    };

    final newDocRef = await firestore.collection('products').add(duplicatedData);
    return newDocRef.id;
  }

  /// Update product status (e.g., activate, deactivate, archive)
  Future<void> updateProductStatus(String productId, ProductStatus status) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final productRef = firestore.collection('products').doc(productId);
    final doc = await productRef.get();

    // Verify ownership
    if (doc.exists) {
      final sellerId = doc.data()?['seller_id'] as String?;
      if (sellerId != userId) {
        throw Exception('Not authorized to update this product');
      }
    }

    await productRef.update({
      'status': status.name,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Increment product view count
  Future<void> incrementViewCount(String productId) async {
    final productRef = firestore.collection('products').doc(productId);
    await productRef.update({
      'view_count': FieldValue.increment(1),
      'last_viewed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Increment product order count
  Future<void> incrementOrderCount(String productId) async {
    final productRef = firestore.collection('products').doc(productId);
    await productRef.update({
      'order_count': FieldValue.increment(1),
    });
  }

  /// Update product rating
  Future<void> updateProductRating(String productId, double newRating) async {
    final productRef = firestore.collection('products').doc(productId);
    await productRef.update({
      'rating': newRating,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Search products by text
  Future<List<Product>> searchProducts(String query) async {
    // Note: For production, use Algolia or similar for better search
    // This is a simple implementation using category/title matching
    
    final snapshot = await firestore
        .collection('products')
        .where('status', isEqualTo: 'active')
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Get products by seller ID
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    final snapshot = await firestore
        .collection('products')
        .where('seller_id', isEqualTo: sellerId)
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromJson({...data, 'id': doc.id});
    }).toList();
  }
}




