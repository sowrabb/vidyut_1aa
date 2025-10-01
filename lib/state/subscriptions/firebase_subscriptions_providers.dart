/// Firebase-backed subscriptions and billing providers
/// Manages user subscription plans, payments, and billing
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/user_role_models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_subscriptions_providers.g.dart';

/// Model for subscription plan
class SubscriptionPlanData {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final String currency;
  final String interval; // month, year
  final Map<String, dynamic> limits;
  final List<String> features;
  final bool isActive;

  SubscriptionPlanData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.currency,
    required this.interval,
    required this.limits,
    required this.features,
    required this.isActive,
  });

  factory SubscriptionPlanData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanData(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      interval: json['interval'] as String? ?? 'month',
      limits: Map<String, dynamic>.from(json['limits'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Model for user subscription
class UserSubscriptionData {
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // active, canceled, expired, pending
  final String? paymentMethod;
  final bool autoRenew;

  UserSubscriptionData({
    required this.userId,
    required this.planId,
    required this.startDate,
    this.endDate,
    required this.status,
    this.paymentMethod,
    required this.autoRenew,
  });

  factory UserSubscriptionData.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionData(
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      startDate: (json['start_date'] as Timestamp).toDate(),
      endDate: json['end_date'] != null
          ? (json['end_date'] as Timestamp).toDate()
          : null,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      autoRenew: json['auto_renew'] as bool? ?? false,
    );
  }
}

/// Stream all active subscription plans
@riverpod
Stream<List<SubscriptionPlanData>> firebaseSubscriptionPlans(
  FirebaseSubscriptionPlansRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('subscription_plans')
      .where('is_active', isEqualTo: true)
      .orderBy('price', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SubscriptionPlanData.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get current user's subscription
@riverpod
Stream<UserSubscriptionData?> firebaseUserSubscription(
  FirebaseUserSubscriptionRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('user_subscriptions')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserSubscriptionData.fromJson(data);
  });
}

/// Service for subscription operations
@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Subscription service class
class SubscriptionService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  SubscriptionService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Create a subscription plan (admin only)
  Future<String> createPlan({
    required String name,
    required String displayName,
    required double price,
    String currency = 'INR',
    String interval = 'month',
    required Map<String, dynamic> limits,
    required List<String> features,
  }) async {
    final planData = {
      'name': name,
      'display_name': displayName,
      'price': price,
      'currency': currency,
      'interval': interval,
      'limits': limits,
      'features': features,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore.collection('subscription_plans').add(planData);
    return docRef.id;
  }

  /// Subscribe user to a plan
  Future<void> subscribeToPlan(String planId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final subscriptionData = {
      'user_id': userId,
      'plan_id': planId,
      'start_date': FieldValue.serverTimestamp(),
      'status': 'pending', // Will be 'active' after payment
      'auto_renew': true,
      'created_at': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('user_subscriptions')
        .doc(userId)
        .set(subscriptionData);

    // TODO: Integrate with payment gateway (Razorpay/Stripe)
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await firestore.collection('user_subscriptions').doc(userId).update({
      'status': 'canceled',
      'auto_renew': false,
      'canceled_at': FieldValue.serverTimestamp(),
    });
  }

  /// Reactivate subscription
  Future<void> reactivateSubscription() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await firestore.collection('user_subscriptions').doc(userId).update({
      'status': 'active',
      'auto_renew': true,
      'reactivated_at': FieldValue.serverTimestamp(),
    });
  }
}




