import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import '../models/firebase_models.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();
  
  FirestoreService._();

  final FirebaseService _firebase = FirebaseService.instance;

  // Product methods
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef = await _firebase.products.add(product.toFirestore());
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'product_created',
        parameters: {'product_id': docRef.id, 'category': product.category},
      );
      
      return docRef.id;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firebase.products.doc(productId).update(updates);
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firebase.products.doc(productId).delete();
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'product_deleted',
        parameters: {'product_id': productId},
      );
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firebase.products.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      return null;
    }
  }

  Stream<List<ProductModel>> getProducts({
    String? category,
    String? sellerId,
    String? status,
    int limit = 20,
  }) {
    Query query = _firebase.products;

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (sellerId != null) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ProductModel>> searchProducts({
    String? query,
    String? category,
    String? city,
    String? state,
    double? minPrice,
    double? maxPrice,
    List<String>? materials,
    int limit = 20,
  }) {
    Query firestoreQuery = _firebase.products;

    if (category != null) {
      firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
    }
    if (city != null) {
      firestoreQuery = firestoreQuery.where('city', isEqualTo: city);
    }
    if (state != null) {
      firestoreQuery = firestoreQuery.where('state', isEqualTo: state);
    }
    if (minPrice != null) {
      firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
    }

    firestoreQuery = firestoreQuery
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    return firestoreQuery.snapshots().map((snapshot) {
      List<ProductModel> products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Client-side filtering for text search and materials
      if (query != null && query.isNotEmpty) {
        products = products.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.brand.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      if (materials != null && materials.isNotEmpty) {
        products = products.where((product) {
          return materials.any((material) => product.materials.contains(material));
        }).toList();
      }

      return products;
    });
  }

  Future<void> incrementProductView(String productId) async {
    try {
      await _firebase.products.doc(productId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
    }
  }

  Future<void> incrementProductContact(String productId) async {
    try {
      await _firebase.products.doc(productId).update({
        'contactCount': FieldValue.increment(1),
      });
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
    }
  }

  // Conversation methods
  Future<String> createConversation(ConversationModel conversation) async {
    try {
      final docRef = await _firebase.conversations.add(conversation.toFirestore());
      return docRef.id;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final doc = await _firebase.conversations.doc(conversationId).get();
      if (doc.exists) {
        return ConversationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      return null;
    }
  }

  Stream<List<ConversationModel>> getUserConversations(String userId) {
    return _firebase.conversations
        .where('buyerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ConversationModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ConversationModel>> getSellerConversations(String sellerId) {
    return _firebase.conversations
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ConversationModel.fromFirestore(doc)).toList();
    });
  }

  // Message methods
  Future<String> sendMessage(MessageModel message) async {
    try {
      final docRef = await _firebase.conversations
          .doc(message.conversationId)
          .collection('messages')
          .add(message.toFirestore());

      // Update conversation with last message
      await _firebase.conversations.doc(message.conversationId).update({
        'lastMessage': message.text,
        'lastMessageAt': Timestamp.fromDate(message.sentAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return docRef.id;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firebase.conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }

  // Lead methods
  Future<String> createLead(LeadModel lead) async {
    try {
      final docRef = await _firebase.leads.add(lead.toFirestore());
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'lead_created',
        parameters: {'lead_id': docRef.id, 'industry': lead.industry},
      );
      
      return docRef.id;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<void> updateLead(String leadId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firebase.leads.doc(leadId).update(updates);
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Stream<List<LeadModel>> getLeads({
    String? industry,
    String? city,
    String? state,
    int limit = 20,
  }) {
    Query query = _firebase.leads;

    if (industry != null) {
      query = query.where('industry', isEqualTo: industry);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LeadModel.fromFirestore(doc)).toList();
    });
  }

  // Category methods
  Future<void> createCategory(String name, String description) async {
    try {
      await _firebase.categories.doc(name).set({
        'name': name,
        'description': description,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getCategories() {
    return _firebase.categories
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    });
  }
}
