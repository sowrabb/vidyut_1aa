/// Firebase-backed seller profile providers
/// Replaces in-memory seller profile management with Firestore
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sell/models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_seller_providers.g.dart';

/// Stream the current user's seller profile
@riverpod
Stream<SellerProfile?> firebaseSellerProfile(FirebaseSellerProfileRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('seller_profiles')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return SellerProfile(
      id: doc.id,
      companyName: data['company_name'] as String? ?? '',
      gstNumber: data['gst_number'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      website: data['website'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      logoUrl: data['logo_url'] as String? ?? '',
      isVerified: data['is_verified'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  });
}

/// Get a seller profile by seller ID (for viewing other sellers)
@riverpod
Stream<SellerProfile?> firebaseSellerProfileById(
  FirebaseSellerProfileByIdRef ref,
  String sellerId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('seller_profiles')
      .doc(sellerId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return SellerProfile(
      id: doc.id,
      companyName: data['company_name'] as String? ?? '',
      gstNumber: data['gst_number'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      website: data['website'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      logoUrl: data['logo_url'] as String? ?? '',
      isVerified: data['is_verified'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  });
}

/// Stream all verified sellers
@riverpod
Stream<List<SellerProfile>> firebaseVerifiedSellers(FirebaseVerifiedSellersRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('seller_profiles')
      .where('is_verified', isEqualTo: true)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SellerProfile(
        id: doc.id,
        companyName: data['company_name'] as String? ?? '',
        gstNumber: data['gst_number'] as String? ?? '',
        address: data['address'] as String? ?? '',
        city: data['city'] as String? ?? '',
        state: data['state'] as String? ?? '',
        pincode: data['pincode'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        email: data['email'] as String? ?? '',
        website: data['website'] as String? ?? '',
        description: data['description'] as String? ?? '',
        categories: List<String>.from(data['categories'] ?? []),
        materials: List<String>.from(data['materials'] ?? []),
        logoUrl: data['logo_url'] as String? ?? '',
        isVerified: data['is_verified'] as bool? ?? false,
        createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  });
}

/// Service for seller profile operations
@riverpod
SellerProfileService sellerProfileService(SellerProfileServiceRef ref) {
  return SellerProfileService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Seller profile service class
class SellerProfileService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  SellerProfileService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a new seller profile
  Future<void> createSellerProfile(SellerProfile profile) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final profileData = {
      'company_name': profile.companyName,
      'gst_number': profile.gstNumber,
      'address': profile.address,
      'city': profile.city,
      'state': profile.state,
      'pincode': profile.pincode,
      'phone': profile.phone,
      'email': profile.email,
      'website': profile.website,
      'description': profile.description,
      'categories': profile.categories,
      'materials': profile.materials,
      'logo_url': profile.logoUrl,
      'is_verified': false, // Needs admin approval
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    await firestore.collection('seller_profiles').doc(userId).set(profileData);

    // Update user document to mark as seller
    await firestore.collection('users').doc(userId).update({
      'is_seller': true,
      'seller_profile_id': userId,
      'seller_activated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update seller profile
  Future<void> updateSellerProfile(SellerProfile profile) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Verify ownership (can only update own profile)
    if (profile.id != userId) {
      throw Exception('Not authorized to update this profile');
    }

    final profileData = {
      'company_name': profile.companyName,
      'gst_number': profile.gstNumber,
      'address': profile.address,
      'city': profile.city,
      'state': profile.state,
      'pincode': profile.pincode,
      'phone': profile.phone,
      'email': profile.email,
      'website': profile.website,
      'description': profile.description,
      'categories': profile.categories,
      'materials': profile.materials,
      'logo_url': profile.logoUrl,
      'updated_at': FieldValue.serverTimestamp(),
      // Note: is_verified can only be changed by admin
    };

    await firestore.collection('seller_profiles').doc(userId).update(profileData);
  }

  /// Update seller logo
  Future<void> updateSellerLogo(String logoUrl) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await firestore.collection('seller_profiles').doc(userId).update({
      'logo_url': logoUrl,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update seller materials
  Future<void> updateSellerMaterials(List<String> materials) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await firestore.collection('seller_profiles').doc(userId).update({
      'materials': materials,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update seller categories
  Future<void> updateSellerCategories(List<String> categories) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await firestore.collection('seller_profiles').doc(userId).update({
      'categories': categories,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: Verify a seller profile
  Future<void> verifySeller(String sellerId) async {
    await firestore.collection('seller_profiles').doc(sellerId).update({
      'is_verified': true,
      'verified_at': FieldValue.serverTimestamp(),
    });

    // Update user document
    await firestore.collection('users').doc(sellerId).update({
      'status': 'active',
    });
  }

  /// Admin: Unverify a seller profile
  Future<void> unverifySeller(String sellerId) async {
    await firestore.collection('seller_profiles').doc(sellerId).update({
      'is_verified': false,
      'unverified_at': FieldValue.serverTimestamp(),
    });
  }

  /// Check if user has a seller profile
  Future<bool> hasSellerProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return false;

    final doc = await firestore.collection('seller_profiles').doc(userId).get();
    return doc.exists;
  }

  /// Get seller profile by ID (for admin/viewing)
  Future<SellerProfile?> getSellerProfileById(String sellerId) async {
    final doc = await firestore.collection('seller_profiles').doc(sellerId).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return SellerProfile(
      id: doc.id,
      companyName: data['company_name'] as String? ?? '',
      gstNumber: data['gst_number'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      website: data['website'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      logoUrl: data['logo_url'] as String? ?? '',
      isVerified: data['is_verified'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Search sellers by city/state
  Future<List<SellerProfile>> searchSellers({
    String? city,
    String? state,
    List<String>? materials,
  }) async {
    Query query = firestore
        .collection('seller_profiles')
        .where('is_verified', isEqualTo: true);

    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    
    if (state != null) {
      query = query.where('state', isEqualTo: state);
    }

    if (materials != null && materials.isNotEmpty) {
      query = query.where('materials', arrayContainsAny: materials);
    }

    final snapshot = await query.limit(50).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SellerProfile(
        id: doc.id,
        companyName: data['company_name'] as String? ?? '',
        gstNumber: data['gst_number'] as String? ?? '',
        address: data['address'] as String? ?? '',
        city: data['city'] as String? ?? '',
        state: data['state'] as String? ?? '',
        pincode: data['pincode'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        email: data['email'] as String? ?? '',
        website: data['website'] as String? ?? '',
        description: data['description'] as String? ?? '',
        categories: List<String>.from(data['categories'] ?? []),
        materials: List<String>.from(data['materials'] ?? []),
        logoUrl: data['logo_url'] as String? ?? '',
        isVerified: data['is_verified'] as bool? ?? false,
        createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}




