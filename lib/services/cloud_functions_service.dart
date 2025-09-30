// Cloud Functions Service for production-ready server-side operations
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for calling Firebase Cloud Functions
class CloudFunctionsService {
  CloudFunctionsService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  // =============================================================================
  // PRODUCT ANALYTICS FUNCTIONS
  // =============================================================================

  /// Update product analytics (views, inquiries, favorites)
  Future<Map<String, dynamic>> updateProductAnalytics({
    required String productId,
    required String action, // 'view', 'inquiry', 'favorite'
  }) async {
    try {
      final callable = _functions.httpsCallable('updateProductAnalytics');
      final result = await callable.call({
        'productId': productId,
        'action': action,
        'userId': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product analytics: $e');
      }
      throw Exception('Failed to update product analytics: $e');
    }
  }

  /// Get product analytics data
  Future<Map<String, dynamic>> getProductAnalytics(String productId) async {
    try {
      final callable = _functions.httpsCallable('getProductAnalytics');
      final result = await callable.call({
        'productId': productId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product analytics: $e');
      }
      throw Exception('Failed to get product analytics: $e');
    }
  }

  // =============================================================================
  // LEAD MANAGEMENT FUNCTIONS
  // =============================================================================

  /// Create a new lead
  Future<Map<String, dynamic>> createLead({
    required String productId,
    required String inquiry,
    required Map<String, dynamic> contactInfo,
  }) async {
    try {
      final callable = _functions.httpsCallable('createLead');
      final result = await callable.call({
        'productId': productId,
        'inquiry': inquiry,
        'contactInfo': contactInfo,
        'userId': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating lead: $e');
      }
      throw Exception('Failed to create lead: $e');
    }
  }

  /// Update lead status
  Future<Map<String, dynamic>> updateLeadStatus({
    required String leadId,
    required String status,
    String? notes,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateLeadStatus');
      final result = await callable.call({
        'leadId': leadId,
        'status': status,
        'notes': notes,
        'updatedBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating lead status: $e');
      }
      throw Exception('Failed to update lead status: $e');
    }
  }

  // =============================================================================
  // SEARCH FUNCTIONS
  // =============================================================================

  /// Advanced product search
  Future<Map<String, dynamic>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? materials,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final callable = _functions.httpsCallable('searchProducts');
      final result = await callable.call({
        'query': query,
        'category': category,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'location': location,
        'materials': materials,
        'limit': limit,
        'offset': offset,
        'userId': currentUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error searching products: $e');
      }
      throw Exception('Failed to search products: $e');
    }
  }

  // =============================================================================
  // USER MANAGEMENT FUNCTIONS
  // =============================================================================

  /// Update user role (admin only)
  Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required String newRole,
    bool? isSeller,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateUserRole');
      final result = await callable.call({
        'userId': userId,
        'newRole': newRole,
        'isSeller': isSeller,
        'updatedBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user role: $e');
      }
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Get user analytics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final callable = _functions.httpsCallable('getUserAnalytics');
      final result = await callable.call({
        'userId': userId,
        'requestedBy': currentUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user analytics: $e');
      }
      throw Exception('Failed to get user analytics: $e');
    }
  }

  // =============================================================================
  // ANALYTICS FUNCTIONS
  // =============================================================================

  /// Get analytics data for admin dashboard
  Future<Map<String, dynamic>> getAnalyticsData({
    String period = '30d',
  }) async {
    try {
      final callable = _functions.httpsCallable('getAnalyticsData');
      final result = await callable.call({
        'period': period,
        'requestedBy': currentUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting analytics data: $e');
      }
      throw Exception('Failed to get analytics data: $e');
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final callable = _functions.httpsCallable('getDashboardStats');
      final result = await callable.call({
        'requestedBy': currentUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting dashboard stats: $e');
      }
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // =============================================================================
  // NOTIFICATION FUNCTIONS
  // =============================================================================

  /// Send notification to user
  Future<Map<String, dynamic>> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendNotification');
      final result = await callable.call({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'sentBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notification: $e');
      }
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Send bulk notification
  Future<Map<String, dynamic>> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendBulkNotification');
      final result = await callable.call({
        'userIds': userIds,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'sentBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending bulk notification: $e');
      }
      throw Exception('Failed to send bulk notification: $e');
    }
  }

  // =============================================================================
  // CONTENT MODERATION FUNCTIONS
  // =============================================================================

  /// Moderate content (reviews, messages, etc.)
  Future<Map<String, dynamic>> moderateContent({
    required String content,
    required String contentType, // 'review', 'message', 'product'
    String? contentId,
  }) async {
    try {
      final callable = _functions.httpsCallable('moderateContent');
      final result = await callable.call({
        'content': content,
        'contentType': contentType,
        'contentId': contentId,
        'moderatedBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error moderating content: $e');
      }
      throw Exception('Failed to moderate content: $e');
    }
  }

  // =============================================================================
  // SYSTEM FUNCTIONS
  // =============================================================================

  /// Run daily cleanup tasks
  Future<Map<String, dynamic>> runDailyCleanup() async {
    try {
      final callable = _functions.httpsCallable('runDailyCleanup');
      final result = await callable.call({
        'requestedBy': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error running daily cleanup: $e');
      }
      throw Exception('Failed to run daily cleanup: $e');
    }
  }

  /// Get system health status
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final callable = _functions.httpsCallable('getSystemHealth');
      final result = await callable.call({
        'requestedBy': currentUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting system health: $e');
      }
      throw Exception('Failed to get system health: $e');
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
}
