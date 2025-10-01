/// Firebase providers for payment order tracking and subscription sync
/// Enables real-time payment status monitoring across all devices

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_payment_providers.g.dart';

/// Payment order model
class PaymentOrder {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final String plan;
  final int amount;
  final String currency;
  final String status; // created, success, failed
  final String? paymentId;
  final String? signature;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? error;
  final Map<String, dynamic>? metadata;

  PaymentOrder({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.plan,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentId,
    this.signature,
    required this.createdAt,
    this.completedAt,
    this.failedAt,
    this.error,
    this.metadata,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      plan: json['plan'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentId: json['payment_id'] as String?,
      signature: json['signature'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] as Timestamp).toDate()
          : null,
      failedAt: json['failed_at'] != null
          ? (json['failed_at'] as Timestamp).toDate()
          : null,
      error: json['error'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'plan': plan,
        'amount': amount,
        'currency': currency,
        'status': status,
        if (paymentId != null) 'payment_id': paymentId,
        if (signature != null) 'signature': signature,
        'created_at': Timestamp.fromDate(createdAt),
        if (completedAt != null) 'completed_at': Timestamp.fromDate(completedAt!),
        if (failedAt != null) 'failed_at': Timestamp.fromDate(failedAt!),
        if (error != null) 'error': error,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Stream all payment orders for a user (for history/audit)
@riverpod
Stream<List<PaymentOrder>> firebaseUserPaymentOrders(
  FirebaseUserPaymentOrdersRef ref,
  String userId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PaymentOrder.fromJson(doc.data()))
          .toList());
}

/// Stream current user's payment orders
@riverpod
Stream<List<PaymentOrder>> firebaseCurrentUserPaymentOrders(
  FirebaseCurrentUserPaymentOrdersRef ref,
) {
  final userId = ref.watch(sessionControllerProvider).userId;
  if (userId == null) return Stream.value([]);
  
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PaymentOrder.fromJson(doc.data()))
          .toList());
}

/// Stream a specific payment order (for real-time status tracking)
@riverpod
Stream<PaymentOrder?> firebasePaymentOrder(
  FirebasePaymentOrderRef ref,
  String orderId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .doc(orderId)
      .snapshots()
      .map((doc) => doc.exists ? PaymentOrder.fromJson(doc.data()!) : null);
}

/// Stream all successful payment orders (for admin analytics)
@riverpod
Stream<List<PaymentOrder>> firebaseSuccessfulPayments(
  FirebaseSuccessfulPaymentsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .where('status', isEqualTo: 'success')
      .orderBy('completed_at', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PaymentOrder.fromJson(doc.data()))
          .toList());
}

/// Stream failed payment orders (for admin monitoring)
@riverpod
Stream<List<PaymentOrder>> firebaseFailedPayments(
  FirebaseFailedPaymentsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  return firestore
      .collection('payment_orders')
      .where('status', isEqualTo: 'failed')
      .orderBy('failed_at', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PaymentOrder.fromJson(doc.data()))
          .toList());
}

/// Stream payment statistics (for admin dashboard)
@riverpod
Stream<Map<String, dynamic>> firebasePaymentStats(
  FirebasePaymentStatsRef ref,
) async* {
  final firestore = ref.watch(firebaseFirestoreProvider);
  
  final allOrdersSnapshot = await firestore.collection('payment_orders').get();
  final successSnapshot = await firestore
      .collection('payment_orders')
      .where('status', isEqualTo: 'success')
      .get();
  final failedSnapshot = await firestore
      .collection('payment_orders')
      .where('status', isEqualTo: 'failed')
      .get();
  
  int totalRevenue = 0;
  for (final doc in successSnapshot.docs) {
    totalRevenue += doc.data()['amount'] as int? ?? 0;
  }
  
  yield {
    'total_orders': allOrdersSnapshot.docs.length,
    'successful_orders': successSnapshot.docs.length,
    'failed_orders': failedSnapshot.docs.length,
    'total_revenue': totalRevenue,
    'total_revenue_inr': totalRevenue / 100, // Convert paise to rupees
    'success_rate': successSnapshot.docs.isNotEmpty
        ? (successSnapshot.docs.length / allOrdersSnapshot.docs.length * 100)
        : 0.0,
  };
}

