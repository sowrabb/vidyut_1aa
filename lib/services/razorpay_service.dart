/// Razorpay payment service for subscription payments
/// Supports web, Android, and iOS platforms
/// 
/// Based on: https://razorpay.com/docs/#home-payments

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_role_models.dart';
import 'dart:js' as js;
import 'dart:html' as html;

/// Razorpay configuration
class RazorpayConfig {
  // Test credentials - Replace with production keys for live deployment
  static const String keyId = 'rzp_test_RO6ONctE3DuCuk';
  static const String keySecret = 'xShbFR8r4LfvFVYM13mbRJW6';
  
  // Company details
  static const String companyName = 'Vidyut';
  static const String companyLogo = 'https://your-logo-url.com/logo.png'; // TODO: Add your logo URL
  static const String supportEmail = 'support@vidyut.com';
  static const String supportPhone = '+91-9876543210';
}

/// Payment result
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? error;
  final Map<String, dynamic>? data;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.error,
    this.data,
  });

  PaymentResult copyWith({
    bool? success,
    String? paymentId,
    String? orderId,
    String? signature,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return PaymentResult(
      success: success ?? this.success,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      signature: signature ?? this.signature,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

/// Razorpay payment service
class RazorpayService {
  final FirebaseFirestore _firestore;
  Razorpay? _razorpay;
  
  // Callbacks
  Function(PaymentResult)? _onPaymentSuccess;
  Function(PaymentResult)? _onPaymentFailure;

  RazorpayService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialize Razorpay
  void initialize() {
    if (kIsWeb) {
      // Web doesn't need Razorpay instance initialization
      // Uses Razorpay Checkout script
      return;
    }
    
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Dispose Razorpay
  void dispose() {
    _razorpay?.clear();
  }

  /// Get subscription plan pricing from Firestore (admin-configurable)
  Future<Map<String, dynamic>> getPlanPricing(SubscriptionPlan plan) async {
    try {
      final doc = await _firestore
          .collection('subscription_plans')
          .doc(plan.value)
          .get();

      if (doc.exists) {
        return doc.data() ?? _getDefaultPricing(plan);
      }
      return _getDefaultPricing(plan);
    } catch (e) {
      debugPrint('Error fetching plan pricing: $e');
      return _getDefaultPricing(plan);
    }
  }

  /// Default pricing (fallback)
  Map<String, dynamic> _getDefaultPricing(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return {
          'name': 'Free',
          'price': 0,
          'currency': 'INR',
          'duration': 'forever',
          'features': ['Basic listings', 'Limited support'],
        };
      case SubscriptionPlan.plus:
        return {
          'name': 'Plus',
          'price': 100000, // ₹1,000 in paise (Razorpay uses smallest currency unit)
          'currency': 'INR',
          'duration': 'year',
          'features': [
            'Unlimited listings',
            'Priority support',
            'Analytics dashboard',
            'Featured products',
          ],
        };
      case SubscriptionPlan.pro:
        return {
          'name': 'Pro',
          'price': 500000, // ₹5,000 in paise
          'currency': 'INR',
          'duration': 'year',
          'features': [
            'Everything in Plus',
            'Premium placement',
            'Custom branding',
            'Dedicated account manager',
            'API access',
          ],
        };
      case SubscriptionPlan.enterprise:
        return {
          'name': 'Enterprise',
          'price': 0, // Contact sales
          'currency': 'INR',
          'duration': 'custom',
          'features': [
            'Everything in Pro',
            'Custom integration',
            'White-label solution',
            'SLA guarantees',
          ],
        };
    }
  }

  /// Create Razorpay order for subscription
  Future<Map<String, dynamic>> createSubscriptionOrder({
    required String userId,
    required String userName,
    required String userEmail,
    required SubscriptionPlan plan,
  }) async {
    final pricing = await getPlanPricing(plan);
    final amount = pricing['price'] as int;

    if (amount == 0) {
      throw Exception('Free plans do not require payment');
    }

    // Create order in Firestore (will be synced with Razorpay backend)
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    
    final orderData = {
      'order_id': orderId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'plan': plan.value,
      'amount': amount,
      'currency': pricing['currency'],
      'status': 'created',
      'created_at': FieldValue.serverTimestamp(),
      'metadata': {
        'duration': pricing['duration'],
        'plan_name': pricing['name'],
      },
    };

    await _firestore.collection('payment_orders').doc(orderId).set(orderData);

    return {
      'order_id': orderId,
      'amount': amount,
      'currency': pricing['currency'],
      'plan': pricing,
    };
  }

  /// Open Razorpay checkout
  Future<PaymentResult> openCheckout({
    required String orderId,
    required int amount,
    required String currency,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String planName,
    Function(PaymentResult)? onSuccess,
    Function(PaymentResult)? onFailure,
  }) async {
    _onPaymentSuccess = onSuccess;
    _onPaymentFailure = onFailure;

    final options = {
      'key': RazorpayConfig.keyId,
      'amount': amount,
      'currency': currency,
      'name': RazorpayConfig.companyName,
      'description': '$planName Subscription',
      'order_id': orderId,
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'theme': {
        'color': '#3399cc',
      },
      'modal': {
        'ondismiss': () {
          _onPaymentFailure?.call(PaymentResult(
            success: false,
            error: 'Payment cancelled by user',
          ));
        }
      },
    };

    if (kIsWeb) {
      // For web, use Razorpay Checkout via JavaScript
      try {
        debugPrint('🔵 Opening Razorpay Checkout on Web');
        debugPrint('🔵 Amount: $amount, Currency: $currency');
        debugPrint('🔵 Order ID: $orderId');
        
        // Create Razorpay options object with JS interop
        final razorpayOptionsMap = {
          'key': RazorpayConfig.keyId,
          'amount': amount,
          'currency': currency,
          'name': RazorpayConfig.companyName,
          'description': '$planName Subscription',
          // Note: order_id removed for test mode - Razorpay test keys work without order creation
          // For production, uncomment this and implement server-side order creation:
          // 'order_id': orderId,
          'prefill': {
            'name': userName,
            'email': userEmail,
            'contact': userPhone,
          },
          'theme': {
            'color': '#3399cc',
          },
        };
        
        // Add handlers after creating the map
        razorpayOptionsMap['handler'] = js.allowInterop((response) {
          debugPrint('✅ Payment Success: ${response.toString()}');
          final paymentId = response['razorpay_payment_id'] as String?;
          final responseOrderId = response['razorpay_order_id'] as String?;
          final signature = response['razorpay_signature'] as String?;
          
          final result = PaymentResult(
            success: true,
            paymentId: paymentId,
            orderId: responseOrderId ?? orderId,
            signature: signature,
            data: {
              'payment_id': paymentId,
              'order_id': responseOrderId ?? orderId,
              'signature': signature,
            },
          );
          
          // Update Firestore with our local order ID
          _firestore.collection('payment_orders').doc(orderId).update({
            'status': 'success',
            'payment_id': paymentId,
            'razorpay_order_id': responseOrderId,
            'signature': signature,
            'completed_at': FieldValue.serverTimestamp(),
          });
          
          _onPaymentSuccess?.call(result);
        });
        
        razorpayOptionsMap['modal'] = {
          'ondismiss': js.allowInterop(() {
            debugPrint('❌ Payment dismissed by user');
            _onPaymentFailure?.call(PaymentResult(
              success: false,
              error: 'Payment cancelled by user',
            ));
          })
        };
        
        final razorpayOptions = js.JsObject.jsify(razorpayOptionsMap);
        
        // Check if Razorpay is loaded
        if (js.context['Razorpay'] == null) {
          debugPrint('❌ Razorpay script not loaded!');
          return PaymentResult(success: false, error: 'Razorpay script not loaded. Please refresh the page.');
        }
        
        // Create and open Razorpay instance
        final razorpayInstance = js.JsObject(js.context['Razorpay'], [razorpayOptions]);
        razorpayInstance.callMethod('open');
        
        debugPrint('🔵 Razorpay modal opened successfully');
        return PaymentResult(success: false, error: 'Payment in progress');
      } catch (e) {
        debugPrint('❌ Error opening Razorpay: $e');
        return PaymentResult(success: false, error: e.toString());
      }
    } else {
      // For mobile (Android/iOS)
      try {
        debugPrint('🔵 Opening Razorpay Checkout on Mobile');
        _razorpay?.open(options);
        // Return pending result, actual result will come via callbacks
        return PaymentResult(success: false, error: 'Payment in progress');
      } catch (e) {
        debugPrint('❌ Error opening Razorpay: $e');
        return PaymentResult(success: false, error: e.toString());
      }
    }
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final result = PaymentResult(
      success: true,
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
      data: {
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
      },
    );

    // Update order status in Firestore
    if (response.orderId != null) {
      await _firestore.collection('payment_orders').doc(response.orderId).update({
        'status': 'success',
        'payment_id': response.paymentId,
        'signature': response.signature,
        'completed_at': FieldValue.serverTimestamp(),
      });
    }

    _onPaymentSuccess?.call(result);
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) async {
    final result = PaymentResult(
      success: false,
      error: '${response.code}: ${response.message}',
      data: {
        'code': response.code,
        'message': response.message,
      },
    );

    // Update order status in Firestore
    if (response.error != null && response.error!['metadata'] != null) {
      final orderId = response.error!['metadata']['order_id'];
      if (orderId != null) {
        await _firestore.collection('payment_orders').doc(orderId).update({
          'status': 'failed',
          'error': response.message,
          'failed_at': FieldValue.serverTimestamp(),
        });
      }
    }

    _onPaymentFailure?.call(result);
  }

  /// Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
    // Handle external wallet payment
  }

  /// Activate subscription after successful payment
  Future<void> activateSubscription({
    required String userId,
    required String orderId,
    required SubscriptionPlan plan,
  }) async {
    final now = DateTime.now();
    final expiresAt = DateTime(now.year + 1, now.month, now.day); // 1 year subscription

    await _firestore.collection('users').doc(userId).update({
      'subscription_plan': plan.value,
      'current_plan_code': orderId,
      'subscription_activated_at': Timestamp.fromDate(now),
      'subscription_expires_at': Timestamp.fromDate(expiresAt),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Log subscription activation
    await _firestore.collection('subscription_history').add({
      'user_id': userId,
      'plan': plan.value,
      'order_id': orderId,
      'activated_at': FieldValue.serverTimestamp(),
      'expires_at': Timestamp.fromDate(expiresAt),
      'type': 'activation',
    });
  }

  /// Upgrade subscription
  Future<void> upgradeSubscription({
    required String userId,
    required String orderId,
    required SubscriptionPlan fromPlan,
    required SubscriptionPlan toPlan,
  }) async {
    final now = DateTime.now();
    final expiresAt = DateTime(now.year + 1, now.month, now.day);

    await _firestore.collection('users').doc(userId).update({
      'subscription_plan': toPlan.value,
      'current_plan_code': orderId,
      'subscription_activated_at': Timestamp.fromDate(now),
      'subscription_expires_at': Timestamp.fromDate(expiresAt),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Log subscription upgrade
    await _firestore.collection('subscription_history').add({
      'user_id': userId,
      'from_plan': fromPlan.value,
      'to_plan': toPlan.value,
      'order_id': orderId,
      'upgraded_at': FieldValue.serverTimestamp(),
      'expires_at': Timestamp.fromDate(expiresAt),
      'type': 'upgrade',
    });
  }

  /// Get user's active subscription
  Future<Map<String, dynamic>?> getActiveSubscription(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
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
    } catch (e) {
      debugPrint('Error fetching subscription: $e');
      return null;
    }
  }
}

