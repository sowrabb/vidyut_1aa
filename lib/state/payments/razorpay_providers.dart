/// Riverpod providers for Razorpay payment integration
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/razorpay_service.dart';
import '../../features/auth/models/user_role_models.dart';
import '../core/firebase_providers.dart';

part 'razorpay_providers.g.dart';

/// Razorpay service provider
@riverpod
RazorpayService razorpayService(RazorpayServiceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final service = RazorpayService(firestore: firestore);
  service.initialize();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
}

/// Get subscription plan pricing (admin-configurable)
@riverpod
Future<Map<String, dynamic>> subscriptionPlanPricing(
  SubscriptionPlanPricingRef ref,
  SubscriptionPlan plan,
) async {
  final razorpay = ref.watch(razorpayServiceProvider);
  return razorpay.getPlanPricing(plan);
}

/// Get all subscription plans with pricing
@riverpod
Future<Map<SubscriptionPlan, Map<String, dynamic>>> allSubscriptionPlans(
  AllSubscriptionPlansRef ref,
) async {
  final razorpay = ref.watch(razorpayServiceProvider);
  
  final plans = <SubscriptionPlan, Map<String, dynamic>>{};
  
  for (final plan in SubscriptionPlan.values) {
    plans[plan] = await razorpay.getPlanPricing(plan);
  }
  
  return plans;
}

/// Get user's active subscription
@riverpod
Stream<Map<String, dynamic>?> userActiveSubscription(
  UserActiveSubscriptionRef ref,
  String userId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore.collection('users').doc(userId).snapshots().map((doc) {
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    final expiresAt = data['subscription_expires_at'] as Timestamp?;
    
    if (expiresAt == null) return null;
    
    final expiryDate = expiresAt.toDate();
    final isActive = expiryDate.isAfter(DateTime.now());
    
    return {
      'plan': data['subscription_plan'],
      'plan_code': data['current_plan_code'],
      'activated_at': data['subscription_activated_at'],
      'expires_at': expiresAt,
      'is_active': isActive,
      'days_remaining': expiryDate.difference(DateTime.now()).inDays,
    };
  });
}

/// Stream payment orders for a user
@riverpod
Stream<List<Map<String, dynamic>>> userPaymentOrders(
  UserPaymentOrdersRef ref,
  String userId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {...data, 'id': doc.id};
    }).toList();
  });
}

/// Payment state notifier for managing payment flow
@riverpod
class PaymentState extends _$PaymentState {
  @override
  Map<String, dynamic> build() {
    return {
      'isProcessing': false,
      'currentStep': 'plan_selection', // plan_selection, payment, business_details
      'selectedPlan': null,
      'orderId': null,
      'paymentResult': null,
      'error': null,
    };
  }

  void selectPlan(SubscriptionPlan plan) {
    state = {...state, 'selectedPlan': plan};
  }

  void setProcessing(bool processing) {
    state = {...state, 'isProcessing': processing};
  }

  void setStep(String step) {
    state = {...state, 'currentStep': step};
  }

  void setOrderId(String orderId) {
    state = {...state, 'orderId': orderId};
  }

  void setPaymentResult(PaymentResult result) {
    state = {...state, 'paymentResult': result};
  }

  void setError(String? error) {
    state = {...state, 'error': error};
  }

  void reset() {
    state = {
      'isProcessing': false,
      'currentStep': 'plan_selection',
      'selectedPlan': null,
      'orderId': null,
      'paymentResult': null,
      'error': null,
    };
  }
}




