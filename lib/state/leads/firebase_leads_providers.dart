/// Firebase-backed leads providers for B2B marketplace
/// Matches buyers with sellers based on materials and location
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sell/models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_leads_providers.g.dart';

/// Stream all leads for the current seller (matched leads)
@riverpod
Stream<List<Lead>> firebaseSellerLeads(FirebaseSellerLeadsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('leads')
      .where('matched_sellers', arrayContains: userId)
      .where('status', whereIn: ['new', 'contacted', 'quoted'])
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Lead.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream leads created by current user (buyer)
@riverpod
Stream<List<Lead>> firebaseBuyerLeads(FirebaseBuyerLeadsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('leads')
      .where('created_by', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Lead.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream leads by status
@riverpod
Stream<List<Lead>> firebaseLeadsByStatus(
  FirebaseLeadsByStatusRef ref,
  String status,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('leads')
      .where('matched_sellers', arrayContains: userId)
      .where('status', isEqualTo: status)
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Lead.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single lead by ID
@riverpod
Stream<Lead?> firebaseLead(FirebaseLeadRef ref, String leadId) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('leads')
      .doc(leadId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Lead.fromJson({...data, 'id': doc.id});
  });
}

/// Service for lead operations
@riverpod
LeadService leadService(LeadServiceRef ref) {
  return LeadService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Lead service class
class LeadService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  LeadService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a new lead (buyer posts requirement)
  Future<String> createLead({
    required String title,
    required String industry,
    required List<String> materials,
    required String city,
    required String state,
    required int qty,
    required double turnoverCr,
    required DateTime needBy,
    required String about,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Create lead
    final leadData = {
      'title': title,
      'industry': industry,
      'materials': materials,
      'city': city,
      'state': state,
      'qty': qty,
      'turnover_cr': turnoverCr,
      'need_by': Timestamp.fromDate(needBy),
      'status': 'new',
      'about': about,
      'created_by': userId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'matched_sellers': <String>[], // Will be populated by matching algorithm
      'contact_count': 0,
      'quote_count': 0,
    };

    final docRef = await firestore.collection('leads').add(leadData);

    // Run matching algorithm asynchronously
    await _matchSellersToLead(docRef.id, materials, city, state);

    return docRef.id;
  }

  /// Update an existing lead
  Future<void> updateLead({
    required String leadId,
    String? title,
    String? industry,
    List<String>? materials,
    String? city,
    String? state,
    int? qty,
    double? turnoverCr,
    DateTime? needBy,
    String? about,
    String? status,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final leadRef = firestore.collection('leads').doc(leadId);
    final doc = await leadRef.get();

    if (!doc.exists) throw Exception('Lead not found');

    // Verify ownership
    final createdBy = doc.data()?['created_by'] as String?;
    if (createdBy != userId) {
      throw Exception('Not authorized to update this lead');
    }

    final updateData = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (title != null) updateData['title'] = title;
    if (industry != null) updateData['industry'] = industry;
    if (materials != null) updateData['materials'] = materials;
    if (city != null) updateData['city'] = city;
    if (state != null) updateData['state'] = state;
    if (qty != null) updateData['qty'] = qty;
    if (turnoverCr != null) updateData['turnover_cr'] = turnoverCr;
    if (needBy != null) updateData['need_by'] = Timestamp.fromDate(needBy);
    if (about != null) updateData['about'] = about;
    if (status != null) updateData['status'] = status;

    await leadRef.update(updateData);

    // Re-run matching if materials/location changed
    if (materials != null || city != null || state != null) {
      final currentMaterials = materials ?? List<String>.from(doc.data()?['materials'] ?? []);
      final currentCity = city ?? doc.data()?['city'] as String;
      final currentState = state ?? doc.data()?['state'] as String;
      await _matchSellersToLead(leadId, currentMaterials, currentCity, currentState);
    }
  }

  /// Delete a lead
  Future<void> deleteLead(String leadId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final leadRef = firestore.collection('leads').doc(leadId);
    final doc = await leadRef.get();

    if (!doc.exists) throw Exception('Lead not found');

    // Verify ownership
    final createdBy = doc.data()?['created_by'] as String?;
    if (createdBy != userId) {
      throw Exception('Not authorized to delete this lead');
    }

    await leadRef.delete();
  }

  /// Update lead status (seller action)
  Future<void> updateLeadStatus(String leadId, String status) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final leadRef = firestore.collection('leads').doc(leadId);
    final doc = await leadRef.get();

    if (!doc.exists) throw Exception('Lead not found');

    // Verify seller is matched to this lead
    final matchedSellers = List<String>.from(doc.data()?['matched_sellers'] ?? []);
    if (!matchedSellers.contains(userId)) {
      throw Exception('Not authorized to update this lead');
    }

    await leadRef.update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Record seller contact (seller views/contacts lead)
  Future<void> recordContact(String leadId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final leadRef = firestore.collection('leads').doc(leadId);
    
    await leadRef.update({
      'contact_count': FieldValue.increment(1),
      'last_contacted_at': FieldValue.serverTimestamp(),
    });

    // Track which sellers contacted
    await leadRef.update({
      'contacted_by.$userId': FieldValue.serverTimestamp(),
    });
  }

  /// Submit quote for lead
  Future<void> submitQuote({
    required String leadId,
    required double quoteAmount,
    String? notes,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final leadRef = firestore.collection('leads').doc(leadId);
    final doc = await leadRef.get();

    if (!doc.exists) throw Exception('Lead not found');

    // Verify seller is matched to this lead
    final matchedSellers = List<String>.from(doc.data()?['matched_sellers'] ?? []);
    if (!matchedSellers.contains(userId)) {
      throw Exception('Not authorized to quote on this lead');
    }

    // Create quote document
    await firestore.collection('quotes').add({
      'lead_id': leadId,
      'seller_id': userId,
      'amount': quoteAmount,
      'notes': notes,
      'status': 'submitted',
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update lead quote count
    await leadRef.update({
      'quote_count': FieldValue.increment(1),
      'status': 'quoted',
    });
  }

  /// Matching algorithm: Find sellers that match lead requirements
  Future<void> _matchSellersToLead(
    String leadId,
    List<String> materials,
    String city,
    String state,
  ) async {
    // Find sellers who have matching materials
    final sellersQuery = await firestore
        .collection('seller_profiles')
        .where('is_verified', isEqualTo: true)
        .where('materials', arrayContainsAny: materials.take(10).toList())
        .get();

    final matchedSellerIds = <String>[];

    for (final sellerDoc in sellersQuery.docs) {
      final sellerData = sellerDoc.data();
      final sellerState = sellerData['state'] as String?;
      final sellerCity = sellerData['city'] as String?;

      // Priority matching:
      // 1. Same city and has materials = HIGH priority
      // 2. Same state and has materials = MEDIUM priority
      // 3. Has materials = LOW priority

      if (sellerCity == city && sellerState == state) {
        // High priority match
        matchedSellerIds.insert(0, sellerDoc.id);
      } else if (sellerState == state) {
        // Medium priority match
        matchedSellerIds.add(sellerDoc.id);
      } else {
        // Low priority match (nationwide)
        matchedSellerIds.add(sellerDoc.id);
      }
    }

    // Update lead with matched sellers
    if (matchedSellerIds.isNotEmpty) {
      await firestore.collection('leads').doc(leadId).update({
        'matched_sellers': matchedSellerIds,
        'match_count': matchedSellerIds.length,
      });

      // TODO: Send notifications to matched sellers
      // Can be done via Cloud Functions or notification service
    }
  }

  /// Get lead statistics for seller
  Future<Map<String, int>> getSellerLeadStats() async {
    final userId = getCurrentUserId();
    if (userId == null) return {};

    final leadsSnapshot = await firestore
        .collection('leads')
        .where('matched_sellers', arrayContains: userId)
        .get();

    final stats = <String, int>{
      'total': leadsSnapshot.docs.length,
      'new': 0,
      'contacted': 0,
      'quoted': 0,
      'closed': 0,
      'lost': 0,
    };

    for (final doc in leadsSnapshot.docs) {
      final status = doc.data()['status'] as String? ?? 'new';
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  /// Search leads by filters (admin/analytics)
  Future<List<Lead>> searchLeads({
    String? industry,
    String? state,
    List<String>? materials,
    String? status,
  }) async {
    Query query = firestore.collection('leads');

    if (industry != null) {
      query = query.where('industry', isEqualTo: industry);
    }

    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }

    if (materials != null && materials.isNotEmpty) {
      query = query.where('materials', arrayContainsAny: materials);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('created_at', descending: true).limit(50);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Lead.fromJson({...data, 'id': doc.id});
    }).toList();
  }
}




