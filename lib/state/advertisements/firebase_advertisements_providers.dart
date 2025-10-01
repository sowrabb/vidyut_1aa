/// Firebase-backed advertisements providers for seller ad campaigns
/// Allows sellers to promote products through paid advertising
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';
import '../../features/sell/models.dart' show AdType, AdCampaign;

part 'firebase_advertisements_providers.g.dart';

/// Model for advertisement campaign with billing
class AdvertisementCampaign {
  final String id;
  final String sellerId;
  final String sellerName;
  final String campaignName;
  final String productId;
  final String productTitle;
  final AdType adType;
  final String term; // search term or category name
  final int slot; // display slot (1-3)
  final AdStatus status;
  final double budget;
  final double budgetSpent;
  final DateTime startDate;
  final DateTime endDate;
  final int impressions;
  final int clicks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  AdvertisementCampaign({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.campaignName,
    required this.productId,
    required this.productTitle,
    required this.adType,
    required this.term,
    required this.slot,
    required this.status,
    required this.budget,
    required this.budgetSpent,
    required this.startDate,
    required this.endDate,
    required this.impressions,
    required this.clicks,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory AdvertisementCampaign.fromJson(Map<String, dynamic> json) {
    return AdvertisementCampaign(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String? ?? '',
      campaignName: json['campaign_name'] as String,
      productId: json['product_id'] as String,
      productTitle: json['product_title'] as String? ?? '',
      adType: AdType.values.firstWhere(
        (e) => e.toString().split('.').last == json['ad_type'],
        orElse: () => AdType.search,
      ),
      term: json['term'] as String? ?? '',
      slot: json['slot'] as int? ?? 1,
      status: AdStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdStatus.pending,
      ),
      budget: (json['budget'] as num).toDouble(),
      budgetSpent: (json['budget_spent'] as num?)?.toDouble() ?? 0.0,
      startDate: (json['start_date'] as Timestamp).toDate(),
      endDate: (json['end_date'] as Timestamp).toDate(),
      impressions: json['impressions'] as int? ?? 0,
      clicks: json['clicks'] as int? ?? 0,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'seller_id': sellerId,
    'seller_name': sellerName,
    'campaign_name': campaignName,
    'product_id': productId,
    'product_title': productTitle,
    'ad_type': adType.toString().split('.').last,
    'term': term,
    'slot': slot,
    'status': status.name,
    'budget': budget,
    'budget_spent': budgetSpent,
    'start_date': Timestamp.fromDate(startDate),
    'end_date': Timestamp.fromDate(endDate),
    'impressions': impressions,
    'clicks': clicks,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
    'metadata': metadata,
  };

  double get clickThroughRate =>
      impressions > 0 ? (clicks / impressions) * 100 : 0.0;

  double get costPerClick =>
      clicks > 0 ? budgetSpent / clicks : 0.0;

  double get budgetRemaining => budget - budgetSpent;

  bool get isActive =>
      status == AdStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate) &&
      budgetRemaining > 0;
}

/// Ad status
enum AdStatus {
  pending,      // Awaiting approval
  active,       // Currently running
  paused,       // Paused by seller
  completed,    // Campaign ended
  rejected,     // Rejected by admin
  budgetExhausted, // Budget fully spent
}

/// Stream active ads for a specific ad type
@riverpod
Stream<List<AdvertisementCampaign>> firebaseActiveAds(
  FirebaseActiveAdsRef ref,
  AdType adType,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final now = DateTime.now();

  return firestore
      .collection('advertisements')
      .where('ad_type', isEqualTo: adType.toString().split('.').last)
      .where('status', isEqualTo: AdStatus.active.name)
      .where('start_date', isLessThanOrEqualTo: Timestamp.fromDate(now))
      .where('end_date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
      .orderBy('start_date')
      .orderBy('budget_spent', descending: false)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdvertisementCampaign.fromJson({...data, 'id': doc.id});
    }).where((ad) => ad.budgetRemaining > 0).toList();
  });
}

/// Stream seller's ads
@riverpod
Stream<List<AdvertisementCampaign>> firebaseSellerAds(FirebaseSellerAdsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('advertisements')
      .where('seller_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdvertisementCampaign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream ads by status (admin)
@riverpod
Stream<List<AdvertisementCampaign>> firebaseAdsByStatus(
  FirebaseAdsByStatusRef ref,
  AdStatus status,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('advertisements')
      .where('status', isEqualTo: status.name)
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdvertisementCampaign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream all ads (admin)
@riverpod
Stream<List<AdvertisementCampaign>> firebaseAllAds(FirebaseAllAdsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('advertisements')
      .orderBy('created_at', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdvertisementCampaign.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single ad
@riverpod
Stream<AdvertisementCampaign?> firebaseAdvertisement(
  FirebaseAdvertisementRef ref,
  String adId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('advertisements')
      .doc(adId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return AdvertisementCampaign.fromJson({...data, 'id': doc.id});
  });
}

/// Service for advertisement operations
@riverpod
AdvertisementService advertisementService(AdvertisementServiceRef ref) {
  return AdvertisementService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Advertisement service class
class AdvertisementService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  AdvertisementService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a new ad campaign
  Future<String> createCampaign({
    required String campaignName,
    required String productId,
    required String productTitle,
    required AdType adType,
    required String term, // search term or category name
    required int slot, // display slot 1-3
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Validate dates
    if (endDate.isBefore(startDate)) {
      throw Exception('End date must be after start date');
    }

    if (budget <= 0) {
      throw Exception('Budget must be greater than 0');
    }

    final adData = {
      'seller_id': userId,
      'seller_name': 'Seller', // TODO: Get from seller profile
      'campaign_name': campaignName,
      'product_id': productId,
      'product_title': productTitle,
      'ad_type': adType.toString().split('.').last,
      'term': term,
      'slot': slot,
      'status': AdStatus.pending.name, // Requires admin approval
      'budget': budget,
      'budget_spent': 0.0,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'impressions': 0,
      'clicks': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'metadata': {},
    };

    final docRef = await firestore.collection('advertisements').add(adData);
    return docRef.id;
  }

  /// Update ad campaign
  Future<void> updateCampaign({
    required String adId,
    String? campaignName,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    String? term,
    int? slot,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final adRef = firestore.collection('advertisements').doc(adId);
    final doc = await adRef.get();

    if (!doc.exists) throw Exception('Ad not found');

    // Verify ownership
    final sellerId = doc.data()?['seller_id'] as String?;
    if (sellerId != userId) {
      throw Exception('Not authorized to update this ad');
    }

    final updateData = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (campaignName != null) updateData['campaign_name'] = campaignName;
    if (budget != null) updateData['budget'] = budget;
    if (startDate != null) updateData['start_date'] = Timestamp.fromDate(startDate);
    if (endDate != null) updateData['end_date'] = Timestamp.fromDate(endDate);
    if (term != null) updateData['term'] = term;
    if (slot != null) updateData['slot'] = slot;

    await adRef.update(updateData);
  }

  /// Pause ad campaign
  Future<void> pauseCampaign(String adId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final adRef = firestore.collection('advertisements').doc(adId);
    final doc = await adRef.get();

    if (!doc.exists) throw Exception('Ad not found');

    // Verify ownership
    final sellerId = doc.data()?['seller_id'] as String?;
    if (sellerId != userId) {
      throw Exception('Not authorized to pause this ad');
    }

    await adRef.update({
      'status': AdStatus.paused.name,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Resume ad campaign
  Future<void> resumeCampaign(String adId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final adRef = firestore.collection('advertisements').doc(adId);
    final doc = await adRef.get();

    if (!doc.exists) throw Exception('Ad not found');

    // Verify ownership
    final sellerId = doc.data()?['seller_id'] as String?;
    if (sellerId != userId) {
      throw Exception('Not authorized to resume this ad');
    }

    await adRef.update({
      'status': AdStatus.active.name,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Delete ad campaign
  Future<void> deleteCampaign(String adId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final adRef = firestore.collection('advertisements').doc(adId);
    final doc = await adRef.get();

    if (!doc.exists) throw Exception('Ad not found');

    // Verify ownership
    final sellerId = doc.data()?['seller_id'] as String?;
    if (sellerId != userId) {
      throw Exception('Not authorized to delete this ad');
    }

    await adRef.delete();
  }

  /// Track impression (ad shown)
  Future<void> trackImpression(String adId) async {
    final adRef = firestore.collection('advertisements').doc(adId);
    
    await adRef.update({
      'impressions': FieldValue.increment(1),
      'last_impression_at': FieldValue.serverTimestamp(),
    });

    // Update cost (simplified - $0.10 per impression)
    await _updateCost(adId, 0.10);
  }

  /// Track click (ad clicked)
  Future<void> trackClick(String adId) async {
    final adRef = firestore.collection('advertisements').doc(adId);
    
    await adRef.update({
      'clicks': FieldValue.increment(1),
      'last_click_at': FieldValue.serverTimestamp(),
    });

    // Update cost (simplified - $1.00 per click)
    await _updateCost(adId, 1.00);
  }

  /// Update ad cost
  Future<void> _updateCost(String adId, double amount) async {
    final adRef = firestore.collection('advertisements').doc(adId);
    
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(adRef);
      if (!doc.exists) return;

      final budgetSpent = (doc.data()?['budget_spent'] as num?)?.toDouble() ?? 0.0;
      final budget = (doc.data()?['budget'] as num?)?.toDouble() ?? 0.0;
      final newBudgetSpent = budgetSpent + amount;

      final updateData = <String, dynamic>{
        'budget_spent': newBudgetSpent,
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Check if budget exhausted
      if (newBudgetSpent >= budget) {
        updateData['status'] = AdStatus.budgetExhausted.name;
      }

      transaction.update(adRef, updateData);
    });
  }

  /// Admin: Approve ad
  Future<void> approveAd(String adId) async {
    await firestore.collection('advertisements').doc(adId).update({
      'status': AdStatus.active.name,
      'approved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: Reject ad
  Future<void> rejectAd(String adId, String reason) async {
    await firestore.collection('advertisements').doc(adId).update({
      'status': AdStatus.rejected.name,
      'rejection_reason': reason,
      'rejected_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get ad performance metrics
  Future<Map<String, dynamic>> getAdMetrics(String adId) async {
    final doc = await firestore.collection('advertisements').doc(adId).get();
    
    if (!doc.exists) throw Exception('Ad not found');

    final ad = AdvertisementCampaign.fromJson({...doc.data()!, 'id': doc.id});

    return {
      'impressions': ad.impressions,
      'clicks': ad.clicks,
      'click_through_rate': ad.clickThroughRate,
      'budget': ad.budget,
      'budget_spent': ad.budgetSpent,
      'budget_remaining': ad.budgetRemaining,
      'cost_per_click': ad.costPerClick,
      'is_active': ad.isActive,
    };
  }

  /// Get seller's total ad spend
  Future<double> getSellerAdSpend() async {
    final userId = getCurrentUserId();
    if (userId == null) return 0.0;

    final snapshot = await firestore
        .collection('advertisements')
        .where('seller_id', isEqualTo: userId)
        .get();

    double totalSpend = 0.0;
    for (final doc in snapshot.docs) {
      final budgetSpent = (doc.data()['budget_spent'] as num?)?.toDouble() ?? 0.0;
      totalSpend += budgetSpent;
    }

    return totalSpend;
  }

  /// Get seller's ad statistics
  Future<Map<String, dynamic>> getSellerAdStats() async {
    final userId = getCurrentUserId();
    if (userId == null) return {};

    final snapshot = await firestore
        .collection('advertisements')
        .where('seller_id', isEqualTo: userId)
        .get();

    int totalCampaigns = snapshot.docs.length;
    int activeCampaigns = 0;
    int totalImpressions = 0;
    int totalClicks = 0;
    double totalSpend = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      
      if (status == AdStatus.active.name) activeCampaigns++;
      
      totalImpressions += (data['impressions'] as int? ?? 0);
      totalClicks += (data['clicks'] as int? ?? 0);
      totalSpend += (data['budget_spent'] as num?)?.toDouble() ?? 0.0;
    }

    final avgCTR = totalImpressions > 0
        ? (totalClicks / totalImpressions) * 100
        : 0.0;

    return {
      'total_campaigns': totalCampaigns,
      'active_campaigns': activeCampaigns,
      'total_impressions': totalImpressions,
      'total_clicks': totalClicks,
      'total_spend': totalSpend,
      'average_ctr': avgCTR,
    };
  }

  /// Admin: Get platform ad revenue
  Future<Map<String, dynamic>> getPlatformAdRevenue({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = firestore.collection('advertisements');

    if (startDate != null) {
      query = query.where('created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('created_at',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    double totalRevenue = 0.0;
    int totalAds = snapshot.docs.length;
    int totalImpressions = 0;
    int totalClicks = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRevenue += (data['budget_spent'] as num?)?.toDouble() ?? 0.0;
      totalImpressions += (data['impressions'] as int? ?? 0);
      totalClicks += (data['clicks'] as int? ?? 0);
    }

    return {
      'total_revenue': totalRevenue,
      'total_ads': totalAds,
      'total_impressions': totalImpressions,
      'total_clicks': totalClicks,
      'average_revenue_per_ad': totalAds > 0 ? totalRevenue / totalAds : 0.0,
    };
  }
}

