import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/admin/models/admin_user.dart';
import '../features/admin/models/hero_section.dart';
import '../features/admin/models/notification.dart';
import '../features/admin/models/product_models.dart' as prod;
import '../features/admin/models/billing_models.dart' as bill;
import '../features/admin/models/kyc_models.dart';
import '../features/admin/models/subscription_models.dart' as sub;

/// Environment configuration for API service
class ApiEnvironment {
  final String baseUrl;
  final Duration timeout;
  final bool enableRetries;
  final int maxRetries;
  final Duration retryDelay;

  const ApiEnvironment({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.enableRetries = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  static const ApiEnvironment production = ApiEnvironment(
    baseUrl: 'https://api.vidyut.com/admin',
    timeout: Duration(seconds: 30),
  );

  static const ApiEnvironment staging = ApiEnvironment(
    baseUrl: 'https://staging-api.vidyut.com/admin',
    timeout: Duration(seconds: 45),
  );

  static const ApiEnvironment development = ApiEnvironment(
    baseUrl: 'http://localhost:3000/admin',
    timeout: Duration(seconds: 60),
  );

  static ApiEnvironment fromEnvironment() {
    const env = String.fromEnvironment('API_ENV', defaultValue: 'production');
    switch (env) {
      case 'staging':
        return staging;
      case 'development':
        return development;
      default:
        return production;
    }
  }
}

/// Enhanced API service for admin panel backend integration
class EnhancedAdminApiService {
  final ApiEnvironment _environment;
  final http.Client _httpClient;
  Map<String, String> _defaultHeaders;

  EnhancedAdminApiService({
    ApiEnvironment? environment,
    http.Client? httpClient,
    String? authToken,
  })  : _environment = environment ?? ApiEnvironment.fromEnvironment(),
        _httpClient = httpClient ?? http.Client(),
        _defaultHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        } {
    // Initialize token synchronously
    if (authToken != null) {
      _defaultHeaders['Authorization'] = 'Bearer $authToken';
    }

    // Load token from storage asynchronously
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_auth_token');
      if (token != null) {
        _defaultHeaders['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Ignore persistence errors
    }
  }

  /// Update auth token
  void updateAuthToken(String? token) {
    if (token != null) {
      _defaultHeaders['Authorization'] = 'Bearer $token';
      // Persist token to storage
      _persistToken(token).catchError((e) {
        debugPrint('Failed to persist auth token: $e');
      });
    } else {
      _defaultHeaders.remove('Authorization');
      // Clear token from storage
      _clearToken().catchError((e) {
        debugPrint('Failed to clear auth token: $e');
      });
    }
  }

  Future<void> _persistToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_auth_token', token);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_auth_token');
    } catch (e) {
      // Ignore persistence errors
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }

  /// Make HTTP request with retry logic and proper error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? _environment.timeout;
    int attempts = 0;

    while (
        attempts < (_environment.enableRetries ? _environment.maxRetries : 1)) {
      try {
        final response = await request().timeout(effectiveTimeout);

        // Handle successful responses
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // Handle client errors (4xx) - don't retry
        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw AdminApiException(
            'Client error: ${response.statusCode}',
            response.statusCode,
            response.body,
          );
        }

        // Handle server errors (5xx) - retry if enabled
        if (response.statusCode >= 500) {
          attempts++;
          if (attempts < _environment.maxRetries &&
              _environment.enableRetries) {
            await Future.delayed(_environment.retryDelay * attempts);
            continue;
          }
          throw AdminApiException(
            'Server error: ${response.statusCode}',
            response.statusCode,
            response.body,
          );
        }

        return response;
      } catch (e) {
        if (e is AdminApiException) rethrow;

        attempts++;
        if (attempts < _environment.maxRetries && _environment.enableRetries) {
          await Future.delayed(_environment.retryDelay * attempts);
          continue;
        }

        if (e is TimeoutException) {
          throw AdminApiException(
            'Request timeout after ${effectiveTimeout.inSeconds}s',
            408,
            'Request timed out',
          );
        }

        throw AdminApiException(
          'Network error: $e',
          0,
          e.toString(),
        );
      }
    }

    throw AdminApiException('Max retries exceeded', 0, 'Request failed');
  }

  /// Build URI with proper encoding
  Uri _buildUri(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('${_environment.baseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      // Don't pre-encode values - let uri.replace handle encoding
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  // ================= User Management API =================

  /// Get users with pagination, filtering, and sorting
  Future<UserListResponse> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? status,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final uri = _buildUri('/users', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return UserListResponse.fromJson(data);
  }

  /// Get single user by ID
  Future<AdminUser> getUser(String userId) async {
    final uri = _buildUri('/users/$userId');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return AdminUser.fromJson(data['user']);
  }

  /// Create new user
  Future<AdminUser> createUser(CreateUserRequest request) async {
    final uri = _buildUri('/users');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return AdminUser.fromJson(data['user']);
  }

  /// Update user
  Future<AdminUser> updateUser(String userId, UpdateUserRequest request) async {
    final uri = _buildUri('/users/$userId');
    final response = await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return AdminUser.fromJson(data['user']);
  }

  /// Delete user - handles multiple response codes
  Future<void> deleteUser(String userId) async {
    final uri = _buildUri('/users/$userId');
    final response = await _makeRequest(
        () => _httpClient.delete(uri, headers: _defaultHeaders));

    // Accept multiple success codes for deletion
    if (![200, 202, 204].contains(response.statusCode)) {
      throw AdminApiException(
          'Failed to delete user: ${response.statusCode}', response.statusCode);
    }
  }

  /// Bulk update user status
  Future<BulkOperationResult> bulkUpdateUserStatus(
      List<String> userIds, String status) async {
    final uri = _buildUri('/users/bulk-status');
    final request = BulkStatusUpdateRequest(userIds: userIds, status: status);
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return BulkOperationResult.fromJson(data);
  }

  /// Export users CSV
  Future<String> exportUsersCsv({
    String? search,
    String? role,
    String? status,
  }) async {
    final queryParams = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final uri = _buildUri('/users/export', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    return response.body;
  }

  /// Import users CSV using multipart upload
  Future<BulkOperationResult> importUsersCsv(String csvContent,
      {bool dryRun = false}) async {
    final uri = _buildUri('/users/import');

    // Use multipart request for CSV upload
    final multipartRequest = http.MultipartRequest('POST', uri);

    // Don't include Content-Type header - let multipart request set it
    multipartRequest.headers.addAll({
      'Accept': 'application/json',
      if (_defaultHeaders.containsKey('Authorization'))
        'Authorization': _defaultHeaders['Authorization']!,
    });

    // Add CSV content as file field
    multipartRequest.files.add(http.MultipartFile.fromString(
      'csv_file',
      csvContent,
      filename: 'users.csv',
    ));

    // Add dry run parameter
    multipartRequest.fields['dry_run'] = dryRun.toString();

    final streamedResponse = await _makeRequest(() async {
      final response = await multipartRequest.send();
      return http.Response.fromStream(response);
    });

    final data = jsonDecode(streamedResponse.body);
    return BulkOperationResult.fromJson(data);
  }

  /// Reset user password
  Future<void> resetUserPassword(String userId) async {
    final uri = _buildUri('/users/$userId/reset-password');
    await _makeRequest(() => _httpClient.post(uri, headers: _defaultHeaders));
  }

  /// Set a new password directly for a user (admin action)
  Future<void> setUserPassword(String userId, String newPassword) async {
    final uri = _buildUri('/users/$userId/set-password');
    final body = {'new_password': newPassword};
    await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        ));
  }

  // ================= Hero Sections API =================

  /// Get hero sections
  Future<List<HeroSection>> getHeroSections() async {
    final uri = _buildUri('/hero-sections');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return (data['hero_sections'] as List)
        .map((json) => HeroSection.fromJson(json))
        .toList();
  }

  /// Create hero section
  Future<HeroSection> createHeroSection(
      CreateHeroSectionRequest request) async {
    final uri = _buildUri('/hero-sections');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return HeroSection.fromJson(data['hero_section']);
  }

  /// Update hero section
  Future<HeroSection> updateHeroSection(
      String id, UpdateHeroSectionRequest request) async {
    final uri = _buildUri('/hero-sections/$id');
    final response = await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return HeroSection.fromJson(data['hero_section']);
  }

  /// Delete hero section
  Future<void> deleteHeroSection(String id) async {
    final uri = _buildUri('/hero-sections/$id');
    final response = await _makeRequest(
        () => _httpClient.delete(uri, headers: _defaultHeaders));

    // Accept multiple success codes for deletion
    if (![200, 202, 204].contains(response.statusCode)) {
      throw AdminApiException(
          'Failed to delete hero section: ${response.statusCode}',
          response.statusCode);
    }
  }

  /// Reorder hero sections
  Future<void> reorderHeroSections(List<String> orderedIds) async {
    final uri = _buildUri('/hero-sections/reorder');
    final request = ReorderRequest(orderedIds: orderedIds);
    await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));
  }

  /// Save slide duration settings
  Future<void> saveSlideDurations({
    required int firstSlideSeconds,
    required int otherSlidesSeconds,
  }) async {
    final uri = _buildUri('/hero-sections/slide-settings');
    final body = {
      'first_slide_seconds': firstSlideSeconds,
      'other_slides_seconds': otherSlidesSeconds,
    };
    await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        ));
  }

  // ================= File Upload API =================

  /// Upload image file - web compatible
  Future<String> uploadImage(dynamic imageFile) async {
    final uri = _buildUri('/upload/image');
    final multipartRequest = http.MultipartRequest('POST', uri);
    multipartRequest.headers.addAll(_defaultHeaders);

    if (kIsWeb) {
      // Web platform - imageFile should be a web file
      multipartRequest.files.add(http.MultipartFile.fromBytes(
        'image',
        imageFile,
        filename: 'image.jpg',
      ));
    } else {
      // Mobile platform - handle different file types
      try {
        // Try to get path from the file object
        final path = imageFile.toString();
        if (path.startsWith('File:')) {
          final filePath = path.substring(5); // Remove 'File:' prefix
          multipartRequest.files
              .add(await http.MultipartFile.fromPath('image', filePath));
        } else {
          throw ArgumentError('Invalid image file type for mobile platform');
        }
      } catch (e) {
        throw ArgumentError('Failed to process image file: $e');
      }
    }

    final streamedResponse = await _makeRequest(() async {
      final response = await multipartRequest.send();
      return http.Response.fromStream(response);
    });

    final data = jsonDecode(streamedResponse.body);
    return data['url'] as String;
  }

  // ================= Categories API =================

  /// Get categories
  Future<List<prod.Category>> getCategories() async {
    final uri = _buildUri('/categories');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return (data['categories'] as List)
        .map((json) => prod.Category.fromJson(json))
        .toList();
  }

  // ================= Notifications API =================

  /// Get notification templates
  Future<List<NotificationTemplate>> getNotificationTemplates() async {
    final uri = _buildUri('/notifications/templates');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return (data['templates'] as List)
        .map((json) => NotificationTemplate.fromJson(json))
        .toList();
  }

  /// Estimate audience size via Firebase Function proxy (or backend endpoint)
  Future<int> estimateAudienceSize(AudienceFilter audience) async {
    // Prefer function endpoint if configured
    final uri = _buildUri('/notifications/estimate');
    final payload = { 'audience': audience.toJson() };
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(payload),
        ));
    final data = jsonDecode(response.body);
    return (data['count'] as num).toInt();
  }

  /// Send notification - creates a job and returns minimal result or jobId
  Future<NotificationSendResult> sendNotification(
      NotificationDraft draft) async {
    final uri = _buildUri('/notifications/send');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode({'draft': draft.toJson()}),
        ));

    final data = jsonDecode(response.body);
    // If backend returns jobId only, normalize to result
    if (data is Map && data['jobId'] != null) {
      return NotificationSendResult(
        sentCount: 0,
        failedCount: 0,
        jobId: data['jobId'] as String,
      );
    }
    return NotificationSendResult.fromJson(data);
  }

  // ================= Plans API =================

  /// Get subscription plans
  Future<List<sub.Plan>> getPlans() async {
    final uri = _buildUri('/plans');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return (data['plans'] as List)
        .map((json) => sub.Plan.fromJson(json))
        .toList();
  }

  /// Update user subscription
  Future<void> updateUserSubscription(String userId, String planId) async {
    final uri = _buildUri('/users/$userId/subscription');
    final request = {'plan_id': planId};
    await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request),
        ));
  }

  // ================= KYC API =================

  /// Get KYC reviews
  Future<KycReviewListResponse> getKycReviews({
    int page = 1,
    int limit = 20,
    String? status,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final uri = _buildUri('/kyc/reviews', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return KycReviewListResponse.fromJson(data);
  }

  /// Get KYC queue stats
  Future<KycQueueStats> getKycQueueStats() async {
    final uri = _buildUri('/kyc/queue-stats');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return KycQueueStats.fromJson(data);
  }

  /// Get single KYC review
  Future<KycReview> getKycReview(String reviewId) async {
    final uri = _buildUri('/kyc/reviews/$reviewId');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return KycReview.fromJson(data['review']);
  }

  /// Update KYC review
  Future<KycReview> updateKycReview(
      String reviewId, UpdateKycReviewRequest request) async {
    final uri = _buildUri('/kyc/reviews/$reviewId');
    final response = await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return KycReview.fromJson(data['review']);
  }

  /// Bulk KYC action
  Future<BulkKycActionResult> bulkKycAction(
      BulkKycActionRequest request) async {
    final uri = _buildUri('/kyc/bulk-action');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return BulkKycActionResult.fromJson(data);
  }

  /// Get KYC audit logs
  Future<KycAuditLogListResponse> getKycAuditLogs({
    int page = 1,
    int limit = 20,
    String? reviewId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (reviewId != null) 'review_id': reviewId,
      if (action != null) 'action': action,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/kyc/audit-logs', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return KycAuditLogListResponse.fromJson(data);
  }

  /// Export KYC audit logs
  Future<String> exportKycAuditLogs({
    String? reviewId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      if (reviewId != null) 'review_id': reviewId,
      if (action != null) 'action': action,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/kyc/audit-logs/export', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    return response.body;
  }

  // ================= Billing API =================

  /// Get payments
  Future<bill.PaymentListResponse> getPayments({
    int page = 1,
    int limit = 20,
    String? status,
    String? method,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (method != null) 'method': method,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/billing/payments', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return bill.PaymentListResponse.fromJson(data);
  }

  /// Get invoices
  Future<bill.InvoiceListResponse> getInvoices({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/billing/invoices', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return bill.InvoiceListResponse.fromJson(data);
  }

  /// Get billing statistics
  Future<bill.BillingStats> getBillingStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/billing/stats', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    final data = jsonDecode(response.body);
    return bill.BillingStats.fromJson(data);
  }

  /// Create invoice
  Future<bill.Invoice> createInvoice(bill.CreateInvoiceRequest request) async {
    final uri = _buildUri('/billing/invoices');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return bill.Invoice.fromJson(data['invoice']);
  }

  /// Send invoice
  Future<void> sendInvoice(String invoiceId) async {
    final uri = _buildUri('/billing/invoices/$invoiceId/send');
    await _makeRequest(() => _httpClient.post(uri, headers: _defaultHeaders));
  }

  /// Create refund
  Future<bill.Refund> createRefund(bill.CreateRefundRequest request) async {
    final uri = _buildUri('/billing/refunds');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    final data = jsonDecode(response.body);
    return bill.Refund.fromJson(data['refund']);
  }

  /// Export payments CSV
  Future<String> exportPaymentsCsv({
    String? status,
    String? method,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      if (status != null) 'status': status,
      if (method != null) 'method': method,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/billing/payments/export', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    return response.body;
  }

  /// Export invoices CSV
  Future<String> exportInvoicesCsv({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      if (status != null) 'status': status,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final uri = _buildUri('/billing/invoices/export', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));

    return response.body;
  }

  /// Bulk payment actions
  Future<BulkOperationResult> bulkPaymentAction({
    required List<String> paymentIds,
    required String action,
  }) async {
    final uri = _buildUri('/billing/payments/bulk-action');
    final body = {
      'payment_ids': paymentIds,
      'action': action,
    };
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        ));
    final data = jsonDecode(response.body);
    return BulkOperationResult.fromJson(data);
  }

  /// Bulk invoice actions
  Future<BulkOperationResult> bulkInvoiceAction({
    required List<String> invoiceIds,
    required String action,
  }) async {
    final uri = _buildUri('/billing/invoices/bulk-action');
    final body = {
      'invoice_ids': invoiceIds,
      'action': action,
    };
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        ));
    final data = jsonDecode(response.body);
    return BulkOperationResult.fromJson(data);
  }

  /// Retry invoice payment (dunning)
  Future<void> retryInvoicePayment(String invoiceId) async {
    final uri = _buildUri('/billing/invoices/$invoiceId/retry');
    await _makeRequest(() => _httpClient.post(uri, headers: _defaultHeaders));
  }

  /// Notify dunning for an invoice
  Future<void> notifyInvoiceDunning(String invoiceId) async {
    final uri = _buildUri('/billing/invoices/$invoiceId/notify');
    await _makeRequest(() => _httpClient.post(uri, headers: _defaultHeaders));
  }

  // ================= Products API =================

  /// Get products
  Future<prod.ProductListResponse> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    String? search,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (category != null && category.isNotEmpty) 'category': category,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = _buildUri('/products', queryParams: queryParams);
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));
    final data = jsonDecode(response.body);
    return prod.ProductListResponse.fromJson(data);
  }

  /// Create product
  Future<prod.Product> createProduct(prod.CreateProductRequest request) async {
    final uri = _buildUri('/products');
    final response = await _makeRequest(() => _httpClient.post(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));
    final data = jsonDecode(response.body);
    return prod.Product.fromJson(data['product']);
  }

  /// Update product
  Future<prod.Product> updateProduct(
      String productId, prod.UpdateProductRequest request) async {
    final uri = _buildUri('/products/$productId');
    final response = await _makeRequest(() => _httpClient.put(
          uri,
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));
    final data = jsonDecode(response.body);
    return prod.Product.fromJson(data['product']);
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    final uri = _buildUri('/products/$productId');
    final response = await _makeRequest(
        () => _httpClient.delete(uri, headers: _defaultHeaders));
    if (![200, 202, 204].contains(response.statusCode)) {
      throw AdminApiException(
          'Failed to delete product: ${response.statusCode}',
          response.statusCode);
    }
  }

  /// Export products CSV
  Future<String> exportProductsCsv() async {
    final uri = _buildUri('/products/export');
    final response = await _makeRequest(
        () => _httpClient.get(uri, headers: _defaultHeaders));
    return response.body;
  }

  /// Import products CSV
  Future<BulkOperationResult> importProductsCsv(String csvContent,
      {bool dryRun = false}) async {
    final uri = _buildUri('/products/import');
    // Use multipart request for CSV upload
    final multipartRequest = http.MultipartRequest('POST', uri);
    // Don't include Content-Type header - let multipart request set it
    multipartRequest.headers.addAll({
      'Accept': 'application/json',
      if (_defaultHeaders.containsKey('Authorization'))
        'Authorization': _defaultHeaders['Authorization']!,
    });
    // Add CSV content as file field
    multipartRequest.files.add(http.MultipartFile.fromString(
      'csv_file',
      csvContent,
      filename: 'products.csv',
    ));
    // Add dry run parameter
    multipartRequest.fields['dry_run'] = dryRun.toString();
    final streamedResponse = await _makeRequest(() async {
      final response = await multipartRequest.send();
      return http.Response.fromStream(response);
    });
    final data = jsonDecode(streamedResponse.body);
    return BulkOperationResult.fromJson(data);
  }
}

// ================= Request/Response Models =================

class UserListResponse {
  final List<AdminUser> users;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  UserListResponse({
    required this.users,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) =>
      UserListResponse(
        users:
            (json['users'] as List).map((u) => AdminUser.fromJson(u)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class CreateUserRequest {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? companyName;
  final String? gstNumber;
  final String? address;
  final List<String> materials;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.companyName,
    this.gstNumber,
    this.address,
    this.materials = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        if (companyName != null) 'company_name': companyName,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (address != null) 'address': address,
        'materials': materials,
      };
}

class UpdateUserRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? status;
  final String? plan;
  final String? companyName;
  final String? gstNumber;
  final String? address;
  final List<String>? materials;

  UpdateUserRequest({
    this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.plan,
    this.companyName,
    this.gstNumber,
    this.address,
    this.materials,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (plan != null) 'plan': plan,
        if (companyName != null) 'company_name': companyName,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (address != null) 'address': address,
        if (materials != null) 'materials': materials,
      };
}

class BulkStatusUpdateRequest {
  final List<String> userIds;
  final String status;

  BulkStatusUpdateRequest({
    required this.userIds,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'user_ids': userIds,
        'status': status,
      };
}

class BulkOperationResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final String? jobId;

  BulkOperationResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    this.jobId,
  });

  factory BulkOperationResult.fromJson(Map<String, dynamic> json) =>
      BulkOperationResult(
        successCount: json['success_count'] as int,
        failureCount: json['failure_count'] as int,
        errors: List<String>.from(json['errors'] ?? []),
        jobId: json['job_id'] as String?,
      );
}

class CreateHeroSectionRequest {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final int priority;
  final bool isActive;

  CreateHeroSectionRequest({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.ctaText,
    this.ctaUrl,
    required this.priority,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'image_url': imageUrl,
        if (ctaText != null) 'cta_text': ctaText,
        if (ctaUrl != null) 'cta_url': ctaUrl,
        'priority': priority,
        'is_active': isActive,
      };
}

class UpdateHeroSectionRequest {
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final int? priority;
  final bool? isActive;

  UpdateHeroSectionRequest({
    this.title,
    this.subtitle,
    this.imageUrl,
    this.ctaText,
    this.ctaUrl,
    this.priority,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (imageUrl != null) 'image_url': imageUrl,
        if (ctaText != null) 'cta_text': ctaText,
        if (ctaUrl != null) 'cta_url': ctaUrl,
        if (priority != null) 'priority': priority,
        if (isActive != null) 'is_active': isActive,
      };
}

class ReorderRequest {
  final List<String> orderedIds;

  ReorderRequest({required this.orderedIds});

  Map<String, dynamic> toJson() => {
        'ordered_ids': orderedIds,
      };
}

class AdminApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  AdminApiException(this.message, this.statusCode, [this.responseBody]);

  @override
  String toString() =>
      'AdminApiException: $message (Status: $statusCode)${responseBody != null ? '\nResponse: $responseBody' : ''}';
}
