// Firestore Repository Service for production-ready data operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/sell/models.dart';
import '../features/profile/models/user_models.dart';
import '../features/admin/models/admin_user.dart';
import '../features/reviews/models.dart';
import '../features/messaging/models.dart';
import '../features/stateinfo/models/state_info_models.dart';

/// Generic Firestore Repository Service
class FirestoreRepositoryService {
  FirestoreRepositoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // =============================================================================
  // USER OPERATIONS
  // =============================================================================

  /// Get user document by ID
  Future<UserProfile?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Stream user document
  Stream<UserProfile?> streamUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromJson(doc.data()!) : null);
  }

  /// Create or update user
  Future<void> saveUser(UserProfile user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  // =============================================================================
  // PRODUCT OPERATIONS
  // =============================================================================

  /// Get products with filters
  Future<List<Product>> getProducts({
    String? category,
    String? sellerId,
    ProductStatus? status,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore.collection('products');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  /// Stream products with filters
  Stream<List<Product>> streamProducts({
    String? category,
    String? sellerId,
    ProductStatus? status,
    int limit = 20,
  }) {
    Query query = _firestore.collection('products');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (sellerId != null) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Get single product
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Stream single product
  Stream<Product?> streamProduct(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists ? Product.fromJson(doc.data()!) : null);
  }

  /// Save product
  Future<String> saveProduct(Product product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  /// Update product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('products').doc(productId).update(updates);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // =============================================================================
  // REVIEW OPERATIONS
  // =============================================================================

  /// Get reviews for a product
  Future<List<Review>> getProductReviews(String productId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  /// Stream reviews for a product
  Stream<List<Review>> streamProductReviews(String productId,
      {int limit = 20}) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList());
  }

  /// Save review
  Future<String> saveReview(Review review) async {
    try {
      final docRef =
          await _firestore.collection('reviews').add(review.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  // =============================================================================
  // LEAD OPERATIONS
  // =============================================================================

  /// Get leads for user
  Future<List<Lead>> getUserLeads(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('leads')
          .where('buyerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Lead.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get leads: $e');
    }
  }

  /// Stream leads for user
  Stream<List<Lead>> streamUserLeads(String userId, {int limit = 20}) {
    return _firestore
        .collection('leads')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Lead.fromJson(doc.data())).toList());
  }

  /// Save lead
  Future<String> saveLead(Lead lead) async {
    try {
      final docRef = await _firestore.collection('leads').add(lead.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save lead: $e');
    }
  }

  // =============================================================================
  // MESSAGING OPERATIONS
  // =============================================================================

  /// Get conversations for user
  Future<List<Conversation>> getUserConversations(String userId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  /// Stream conversations for user
  Stream<List<Conversation>> streamUserConversations(String userId,
      {int limit = 20}) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromJson(doc.data()))
            .toList());
  }

  /// Get messages for conversation
  Stream<List<Message>> streamConversationMessages(String conversationId,
      {int limit = 50}) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  /// Save message
  Future<String> saveMessage(String conversationId, Message message) async {
    try {
      final docRef = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  // =============================================================================
  // STATE INFO OPERATIONS
  // =============================================================================

  /// Get power generators
  Future<List<PowerGenerator>> getPowerGenerators({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('power_generators')
          .orderBy('name')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PowerGenerator.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get power generators: $e');
    }
  }

  /// Stream power generators
  Stream<List<PowerGenerator>> streamPowerGenerators({int limit = 20}) {
    return _firestore
        .collection('power_generators')
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PowerGenerator.fromJson(doc.data()))
            .toList());
  }

  // =============================================================================
  // ADMIN OPERATIONS
  // =============================================================================

  /// Get all users (admin only)
  Future<List<AdminUser>> getAllUsers({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AdminUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Stream all users (admin only)
  Stream<List<AdminUser>> streamAllUsers({int limit = 50}) {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminUser.fromJson(doc.data()))
            .toList());
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if user has permission
  Future<bool> hasPermission(String userId, String permission) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final role = userData['role'] as String? ?? 'user';

      // Simple role-based permission check
      switch (permission) {
        case 'admin':
          return role == 'admin';
        case 'seller':
          return role == 'seller' || role == 'admin';
        case 'user':
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
