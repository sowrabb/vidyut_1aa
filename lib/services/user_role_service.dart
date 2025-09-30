// Service for managing user role transitions and seller activation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/models/user_role_models.dart';
import '../features/sell/models.dart';

class UserRoleService extends ChangeNotifier {
  UserRoleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isSeller => _currentUser?.isActiveSeller ?? false;
  bool get canBecomeSeller => _currentUser?.canBecomeSeller ?? false;

  /// Initialize user from Firebase Auth
  Future<void> initializeUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        _currentUser = AppUser.fromJson(userDoc.data()!);
      } else {
        // Create new user document if it doesn't exist
        _currentUser = await _createNewUser(userId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new user document
  Future<AppUser> _createNewUser(String userId) async {
    final now = DateTime.now();
    final newUser = AppUser(
      id: userId,
      name: 'New User', // Will be updated from auth
      email: '', // Will be updated from auth
      role: UserRole.buyer,
      status: UserStatus.active,
      subscriptionPlan: SubscriptionPlan.free,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(userId).set(newUser.toJson());
    return newUser;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? location,
    String? industry,
    List<String>? materials,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        location: location,
        industry: industry,
        materials: materials,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toJson());
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Request to become a seller
  Future<bool> requestSellerRole({
    required String planCode,
    String? reason,
  }) async {
    if (_currentUser == null || !_currentUser!.canBecomeSeller) {
      _setError('User cannot become a seller');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final requestId = _firestore.collection('role_transitions').doc().id;
      final request = RoleTransitionRequest(
        id: requestId,
        userId: _currentUser!.id,
        fromRole: _currentUser!.role,
        toRole: UserRole.seller,
        planCode: planCode,
        reason: reason,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('role_transitions')
          .doc(requestId)
          .set(request.toJson());

      // Update user status to pending
      await _updateUserStatus(UserStatus.pending);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to request seller role: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Activate seller role (admin function)
  Future<bool> activateSellerRole({
    required String userId,
    required String planCode,
    String? adminNotes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Update user role and status
      await _firestore.collection('users').doc(userId).update({
        'role': UserRole.seller.value,
        'status': UserStatus.active.value,
        'is_seller': true,
        'current_plan_code': planCode,
        'subscription_plan': _getSubscriptionPlanFromCode(planCode).value,
        'seller_activated_at': Timestamp.fromDate(DateTime.now()),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });

      // Create seller profile
      await _createSellerProfile(userId);

      // Update role transition request
      await _updateRoleTransitionRequest(userId, 'approved', adminNotes);

      // Refresh current user if it's the same user
      if (_currentUser?.id == userId) {
        await initializeUser(userId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to activate seller role: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create seller profile
  Future<void> _createSellerProfile(String userId) async {
    final user = await _firestore.collection('users').doc(userId).get();
    final userData = AppUser.fromJson(user.data()!);

    final sellerProfile = SellerProfile(
      id: userId,
      companyName: userData.name,
      email: userData.email,
      phone: userData.phone ?? '',
      address: userData.location ?? '',
      city: userData.location?.split(',').first ?? '',
      state: userData.location?.split(',').last ?? '',
      pincode: '',
      website: '',
      description: '',
      categories: [],
      materials: userData.materials,
      logoUrl: userData.profileImageUrl ?? '',
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('seller_profiles')
        .doc(userId)
        .set(sellerProfile.toJson());
  }

  /// Update user status
  Future<void> _updateUserStatus(UserStatus status) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(_currentUser!.id)
        .update(updatedUser.toJson());
    _currentUser = updatedUser;
  }

  /// Update role transition request
  Future<void> _updateRoleTransitionRequest(
      String userId, String status, String? adminNotes) async {
    final query = await _firestore
        .collection('role_transitions')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'status': status,
        'admin_notes': adminNotes,
        'processed_at': Timestamp.fromDate(DateTime.now()),
        'processed_by': _currentUser?.id,
      });
    }
  }

  /// Get subscription plan from code
  SubscriptionPlan _getSubscriptionPlanFromCode(String planCode) {
    switch (planCode.toLowerCase()) {
      case 'plus':
        return SubscriptionPlan.plus;
      case 'pro':
        return SubscriptionPlan.pro;
      case 'enterprise':
        return SubscriptionPlan.enterprise;
      default:
        return SubscriptionPlan.free;
    }
  }

  /// Check if user can access seller features
  bool canAccessSellerFeatures() {
    return _currentUser?.isActiveSeller ?? false;
  }

  /// Get current subscription plan
  String getCurrentPlanCode() {
    return _currentUser?.currentPlanCode ?? 'free';
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
