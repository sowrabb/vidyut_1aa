import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/enhanced_admin_api_service.dart';
import '../../../services/lightweight_demo_data_service.dart';
import '../models/hero_section.dart';
import '../models/notification.dart' as notif;
import '../models/subscription_models.dart' as sub;
import '../models/admin_user.dart';
import '../../auth/models/user_role_models.dart';
import '../models/kyc_models.dart';
import '../models/billing_models.dart';
import '../models/product_models.dart' as admin_prod;
import '../../sell/models.dart' as sell;
import '../../../models/product_status.dart';
import 'admin_store.dart';

/// Enhanced AdminStore with backend integration and production-ready features
class EnhancedAdminStore extends ChangeNotifier {
  final EnhancedAdminApiService _apiService;
  final LightweightDemoDataService _demoDataService;
  bool _useBackend;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;

  // Filtering and sorting state
  String _searchQuery = '';
  String _selectedRole = '';
  String _selectedStatus = '';
  String _selectedMaterial = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  // Data caches
  List<AdminUser> _users = [];
  List<HeroSection> _heroSections = [];
  List<AdminCategoryData> _categories = [];
  List<notif.NotificationTemplate> _notificationTemplates = [];
  List<sub.Plan> _plans = [];
  List<sub.Subscription> _subscriptions = [];
  List<KycReview> _kycReviews = [];
  KycQueueStats? _kycQueueStats;
  List<Payment> _payments = [];
  List<Invoice> _invoices = [];
  BillingStats? _billingStats;
  // Notification job tracking
  String? _currentNotificationJobId;
  Map<String, dynamic>? _currentNotificationJob;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _notificationJobSubscription;

  // Bulk operations state
  final Set<String> _selectedUserIds = {};
  final Set<String> _selectedProductIds = {};
  bool _isBulkOperationInProgress = false;
  String? _bulkOperationStatus;

  // Products data
  List<admin_prod.Product> _products = [];
  // Product upload moderation (demo)
  final List<ProductUploadItem> _productUploadQueue = [];
  final List<ProductUploadItem> _productUploadHistory = [];
  List<ProductUploadItem> get productUploadQueue =>
      List.unmodifiable(_productUploadQueue);
  List<ProductUploadItem> get productUploadHistory =>
      List.unmodifiable(_productUploadHistory);
  // Seller audit logs (demo)
  final List<Map<String, dynamic>> _sellerAuditLogs = [];
  List<Map<String, dynamic>> get sellerAuditLogs =>
      List.unmodifiable(_sellerAuditLogs);

  // RBAC compatibility - configurable permissions
  Map<String, Set<String>> _roleToPermissions = {
    'admin': {
      'users.*',
      'content.*',
      'system.*',
      'analytics.*',
      'billing.*',
      'kyc.*',
      'rbac.manage'
    },
    'seller': {'products.*', 'orders.*', 'profile.*'},
    'buyer': {'orders.*', 'profile.*'},
    'manager': {'users.read', 'content.*', 'analytics.read'},
  };

  /// Update RBAC permissions (for remote configuration)
  void updateRbacPermissions(Map<String, Set<String>> permissions) {
    _roleToPermissions = Map.from(permissions);
    notifyListeners();
  }

  /// Check if user has specific permission
  bool hasPermission(String role, String permission) {
    final rolePermissions = _roleToPermissions[role];
    if (rolePermissions == null) return false;

    // Check exact match or wildcard match
    if (rolePermissions.contains(permission)) return true;

    // Check wildcard permissions (e.g., 'users.*' matches 'users.create')
    for (final perm in rolePermissions) {
      if (perm.endsWith('.*')) {
        final prefix = perm.substring(0, perm.length - 2);
        if (permission.startsWith(prefix)) return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _demoDataService.removeListener(_handleDemoDataChanged);
    _notificationJobSubscription?.cancel();
    super.dispose();
  }

  EnhancedAdminStore({
    required EnhancedAdminApiService apiService,
    required LightweightDemoDataService demoDataService,
    bool useBackend = true, // Default to backend for production
  })  : _apiService = apiService,
        _demoDataService = demoDataService,
        _useBackend = useBackend {
    _demoDataService.addListener(_handleDemoDataChanged);
    _initialize();
  }

  // ================= Getters =================

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Pagination
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get useBackend => _useBackend;

  // Filters
  String get searchQuery => _searchQuery;
  String get selectedRole => _selectedRole;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  // Data
  List<AdminUser> get users => List.unmodifiable(_users);
  List<HeroSection> get heroSections => List.unmodifiable(_heroSections);

  // Slide duration settings
  int get firstSlideDurationSeconds => 5; // Default 5 seconds
  int get otherSlidesDurationSeconds => 3; // Default 3 seconds
  List<AdminCategoryData> get categories => List.unmodifiable(_categories);
  List<notif.NotificationTemplate> get notificationTemplates =>
      List.unmodifiable(_notificationTemplates);
  List<sub.Plan> get plans => List.unmodifiable(_plans);
  List<sub.Subscription> get subscriptions => List.unmodifiable(_subscriptions);
  List<KycReview> get kycReviews => List.unmodifiable(_kycReviews);
  KycQueueStats? get kycQueueStats => _kycQueueStats;
  int get kycReviewsTotalCount => _kycReviews.length;
  List<Payment> get payments => List.unmodifiable(_payments);
  List<Invoice> get invoices => List.unmodifiable(_invoices);
  BillingStats? get billingStats => _billingStats;
  List<admin_prod.Product> get products => List.unmodifiable(_products);
  String? get currentNotificationJobId => _currentNotificationJobId;
  Map<String, dynamic>? get currentNotificationJob => _currentNotificationJob;
  int get paymentsTotalCount => _payments.length;
  int get invoicesTotalCount => _invoices.length;
  List<Invoice> get dunningInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.overdue).toList();

  // Bulk operations
  Set<String> get selectedUserIds => Set.unmodifiable(_selectedUserIds);
  Set<String> get selectedProductIds => Set.unmodifiable(_selectedProductIds);
  bool get isBulkOperationInProgress => _isBulkOperationInProgress;
  String? get bulkOperationStatus => _bulkOperationStatus;

  // RBAC compatibility
  Map<String, Set<String>> get roleToPermissions => {
        for (final e in _roleToPermissions.entries)
          e.key: Set<String>.from(e.value)
      };

  // ================= Initialization =================

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      if (_useBackend) {
        try {
          await _loadFromBackend();
        } catch (e) {
          // Fallback to demo data if backend fails
          debugPrint('Backend failed, falling back to demo data: $e');
          _useBackend = false;
          await _loadFromDemoData();
        }
      } else {
        await _loadFromDemoData();
      }
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      // Load all data in parallel
      await Future.wait([
        _loadUsers(),
        loadHeroSections(),
        _loadCategories(),
        _loadNotificationTemplates(),
        _loadPlans(),
        _loadKycReviews(),
        _loadKycQueueStats(),
      ]);
    } catch (e) {
      throw Exception('Backend initialization failed: $e');
    }
  }

  Future<void> _loadFromDemoData() async {
    // Use existing demo data service and hydrate all data
    _users = _demoDataService.allUsers;
    _heroSections = _demoDataService.heroSections;

    // Load categories from demo data
    _categories = _demoDataService.allCategories
        .map((cat) => AdminCategoryData(
              id: cat.name.toLowerCase().replaceAll(' ', '-'),
              name: cat.name,
              description: 'Demo category for ${cat.name}',
              imageUrl: cat.imageUrl,
              productCount: cat.productCount,
              industries: cat.industries,
              materials: cat.materials,
              isActive: true,
              priority: 1,
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              updatedAt: DateTime.now().subtract(const Duration(days: 30)),
            ))
        .toList();

    // Load notification templates
    _notificationTemplates = _demoDataService.notificationTemplates;

    // Load plans
    _plans = [
      const sub.Plan(
        id: 'plan_free',
        name: 'Free',
        code: 'free',
        description: 'Basic access',
        status: sub.PlanStatus.published,
        defaultPointsPerCycle: 50,
        visiblePublicly: true,
        version: 1,
      ),
      const sub.Plan(
        id: 'plan_plus',
        name: 'Plus',
        code: 'plus',
        description: 'For growing sellers',
        status: sub.PlanStatus.published,
        defaultPointsPerCycle: 200,
        visiblePublicly: true,
        version: 1,
      ),
    ];

    _refreshUsersFromDemo(notify: false);

    _payments = _demoDataService.allPayments;
    _invoices = _demoDataService.allInvoices;
    _billingStats = _demoDataService.billingSnapshot;
    // Seed subscriptions (demo)
    final now = DateTime.now();
    _subscriptions = [
      sub.Subscription(
        id: 'sub_1',
        sellerId: '2',
        planId: 'plan_free',
        priceId: 'price_1',
        state: sub.SubscriptionState.active,
        currentPeriodStart: DateTime(now.year, now.month, 1),
        currentPeriodEnd: DateTime(now.year, now.month + 1, 1),
        accumulatedPoints: 150,
        consumedPoints: 20,
      ),
      sub.Subscription(
        id: 'sub_2',
        sellerId: '3',
        planId: 'plan_plus',
        priceId: 'price_2',
        state: sub.SubscriptionState.pastDue,
        currentPeriodStart: DateTime(now.year, now.month - 1, 1),
        currentPeriodEnd: DateTime(now.year, now.month, 1),
        accumulatedPoints: 80,
        consumedPoints: 60,
      ),
    ];

    // Disable upload moderation queue (auto-publish)
    _productUploadQueue.clear();

    notifyListeners();
  }

  // Removed upload queue seeding to disable moderation

  Future<void> approveProductUpload(String uploadId, {String? comments}) async {
    final idx = _productUploadQueue.indexWhere((e) => e.id == uploadId);
    if (idx == -1) return;
    final item = _productUploadQueue.removeAt(idx);

    // Create real product in demo layer
    final req = admin_prod.CreateProductRequest(
      title: (item.proposed['title'] ?? '') as String,
      brand: (item.proposed['brand'] ?? '') as String,
      subtitle: (item.proposed['subtitle'] ?? '') as String,
      category: _toSlug((item.proposed['category'] ?? '') as String),
      description: (item.proposed['description'] ?? '') as String,
      images: item.assets,
      price: (item.proposed['price'] as num?)?.toDouble() ?? 0,
      moq: (item.proposed['moq'] as num?)?.toInt() ?? 1,
      gstRate: 18.0,
      materials: List<String>.from(item.proposed['materials'] ?? const []),
      customValues: const {},
      status: ProductStatus.active,
    );
    await createProduct(req);

    // Move to history
    _productUploadHistory.add(item.copyWith(
      status: UploadStatus.approved,
      reviewedAt: DateTime.now(),
      reviewerNote: comments,
    ));
    notifyListeners();
  }

  Future<void> rejectProductUpload(String uploadId, {String? reason}) async {
    final idx = _productUploadQueue.indexWhere((e) => e.id == uploadId);
    if (idx == -1) return;
    final item = _productUploadQueue.removeAt(idx);
    _productUploadHistory.add(item.copyWith(
      status: UploadStatus.rejected,
      reviewedAt: DateTime.now(),
      reviewerNote: reason,
    ));
    notifyListeners();
  }

  // ================= User Management =================

  Future<void> _loadUsers({bool refresh = false, int? page}) async {
    if (_useBackend) {
      try {
        final targetPage = page ?? (refresh ? 1 : _currentPage);
        final response = await _apiService.getUsers(
          page: targetPage,
          search: _searchQuery.isEmpty ? null : _searchQuery,
          role: _selectedRole.isEmpty ? null : _selectedRole,
          status: _selectedStatus.isEmpty ? null : _selectedStatus,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        );

        if (refresh) {
          _users.clear();
          _users.addAll(response.users);
          _currentPage = 1;
        } else {
          _users.addAll(response.users);
        }

        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _currentPage = response.page;

        notifyListeners();
      } catch (e) {
        _setError('Failed to load users: $e');
      }
    } else {
      _refreshUsersFromDemo();
    }
  }

  Future<void> refreshUsers() async {
    _setLoading(true);
    _error = null; // Clear previous errors
    try {
      await _loadUsers(refresh: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreUsers() async {
    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    try {
      final nextPage = _currentPage + 1;
      await _loadUsers(page: nextPage);
      // Only increment if the load was successful
      _currentPage = nextPage;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSearchQuery(String query) async {
    if (_searchQuery != query) {
      _searchQuery = query;
      await refreshUsers();
    }
  }

  Future<void> setRoleFilter(String role) async {
    if (_selectedRole != role) {
      _selectedRole = role;
      await refreshUsers();
    }
  }

  Future<void> setStatusFilter(String status) async {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      await refreshUsers();
    }
  }

  Future<void> setSorting(String sortBy, String sortOrder) async {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      await refreshUsers();
    }
  }

  void _refreshUsersFromDemo({bool notify = true}) {
    final filtered =
        _applyUserFilters(List<AdminUser>.from(_demoDataService.allUsers));
    _users = filtered;
    _totalCount = filtered.length;
    _currentPage = 1;
    _hasMore = false;
    _selectedUserIds.removeWhere((id) => !_users.any((user) => user.id == id));
    if (notify) {
      notifyListeners();
    }
  }

  List<AdminUser> _applyUserFilters(List<AdminUser> users) {
    Iterable<AdminUser> filtered = users;

    if (_selectedRole.isNotEmpty) {
      filtered = filtered.where(
          (user) => user.role.toString().split('.').last == _selectedRole);
    }

    if (_selectedStatus.isNotEmpty) {
      filtered = filtered.where(
          (user) => user.status.toString().split('.').last == _selectedStatus);
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((user) {
        bool contains(String value) => value.toLowerCase().contains(query);
        return contains(user.name) ||
            contains(user.email) ||
            contains(user.phone) ||
            contains(user.location) ||
            contains(user.industry) ||
            contains(user.plan) ||
            contains(user.id) ||
            user.materials
                .any((material) => material.toLowerCase().contains(query));
      });
    }

    final result = filtered.toList();

    int compare(AdminUser a, AdminUser b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'email':
          comparison = a.email.toLowerCase().compareTo(b.email.toLowerCase());
          break;
        case 'lastActive':
          comparison = a.lastActive.compareTo(b.lastActive);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortOrder == 'desc' ? -comparison : comparison;
    }

    result.sort(compare);
    return result;
  }

  void _handleDemoDataChanged() {
    if (!_useBackend) {
      _refreshUsersFromDemo();
    }
  }

  Future<AdminUser> createUser(CreateUserRequest request) async {
    _setLoading(true);
    try {
      AdminUser user;
      if (_useBackend) {
        user = await _apiService.createUser(request);
      } else {
        // Create user in demo data
        user = AdminUser(
          id: 'U${DateTime.now().millisecondsSinceEpoch}',
          name: request.name,
          email: request.email,
          phone: request.phone,
          role: UserRole.values
              .firstWhere((r) => r.toString().split('.').last == request.role),
          status: UserStatus.active,
          subscription: SubscriptionPlan.free,
          joinDate: DateTime.now(),
          lastActive: DateTime.now(),
          location: 'Unknown',
          industry: 'Unknown',
          createdAt: DateTime.now(),
          isSeller: request.role == 'seller',
          plan: 'free',
          sellerProfile: request.role == 'seller'
              ? sell.SellerProfile(
                  companyName: request.companyName ?? '',
                  gstNumber: request.gstNumber ?? '',
                  address: request.address ?? '',
                  materials: request.materials,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
              : null,
        );
        _demoDataService.addUser(user);
      }

      await refreshUsers();
      return user;
    } catch (e) {
      _setError('Failed to create user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AdminUser> updateUser(String userId, UpdateUserRequest request) async {
    _setLoading(true);
    try {
      AdminUser user;
      if (_useBackend) {
        user = await _apiService.updateUser(userId, request);
      } else {
        final existingUser = _demoDataService.getUser(userId);
        if (existingUser == null) throw Exception('User not found');

        user = existingUser.copyWith(
          name: request.name ?? existingUser.name,
          email: request.email ?? existingUser.email,
          phone: request.phone ?? existingUser.phone,
          role: request.role != null
              ? UserRole.values.firstWhere(
                  (r) => r.toString().split('.').last == request.role)
              : existingUser.role,
          status: request.status != null
              ? UserStatus.values.firstWhere(
                  (s) => s.toString().split('.').last == request.status)
              : existingUser.status,
          plan: request.plan ?? existingUser.plan,
          sellerProfile: existingUser.sellerProfile?.copyWith(
            companyName:
                request.companyName ?? existingUser.sellerProfile?.companyName,
            gstNumber:
                request.gstNumber ?? existingUser.sellerProfile?.gstNumber,
            address: request.address ?? existingUser.sellerProfile?.address,
            materials:
                request.materials ?? existingUser.sellerProfile?.materials,
            updatedAt: DateTime.now(),
          ),
        );
        _demoDataService.updateUser(user);
      }

      await refreshUsers();
      return user;
    } catch (e) {
      _setError('Failed to update user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.deleteUser(userId);
      } else {
        _demoDataService.removeUser(userId);
      }

      await refreshUsers();
    } catch (e) {
      _setError('Failed to delete user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetUserPassword(String userId) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.resetUserPassword(userId);
      } else {
        // Demo: just log the action
        print('Password reset for user: $userId');
      }
    } catch (e) {
      _setError('Failed to reset password: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setUserPassword(String userId, String newPassword) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.setUserPassword(userId, newPassword);
      } else {
        // Demo: no-op besides logging
        print('Set new password for user: $userId (demo)');
      }
    } catch (e) {
      _setError('Failed to set password: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= Bulk Operations =================

  void selectUser(String userId) {
    _selectedUserIds.add(userId);
    notifyListeners();
  }

  void deselectUser(String userId) {
    _selectedUserIds.remove(userId);
    notifyListeners();
  }

  void selectAllUsers() {
    _selectedUserIds.clear();
    _selectedUserIds.addAll(_users.map((u) => u.id));
    notifyListeners();
  }

  void deselectAllUsers() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  Future<BulkOperationResult> bulkUpdateUserStatus(String status) async {
    if (_selectedUserIds.isEmpty) {
      throw Exception('No users selected');
    }

    _isBulkOperationInProgress = true;
    _bulkOperationStatus = 'Updating user status...';
    notifyListeners();

    try {
      BulkOperationResult result;
      if (_useBackend) {
        result = await _apiService.bulkUpdateUserStatus(
            _selectedUserIds.toList(), status);
      } else {
        // Demo bulk operation
        int successCount = 0;
        int failureCount = 0;
        final errors = <String>[];

        for (final userId in _selectedUserIds) {
          try {
            final user = _demoDataService.getUser(userId);
            if (user != null) {
              final updatedUser = user.copyWith(
                status: UserStatus.values
                    .firstWhere((s) => s.toString().split('.').last == status),
              );
              _demoDataService.updateUser(updatedUser);
              successCount++;
            } else {
              failureCount++;
              errors.add('User $userId not found');
            }
          } catch (e) {
            failureCount++;
            errors.add('Failed to update user $userId: $e');
          }
        }

        result = BulkOperationResult(
          successCount: successCount,
          failureCount: failureCount,
          errors: errors,
        );
      }

      _bulkOperationStatus =
          'Completed: ${result.successCount} successful, ${result.failureCount} failed';
      await refreshUsers();
      _selectedUserIds.clear();

      return result;
    } catch (e) {
      _bulkOperationStatus = 'Failed: $e';
      rethrow;
    } finally {
      _isBulkOperationInProgress = false;
      notifyListeners();
    }
  }

  Future<String> exportUsersCsv() async {
    _setLoading(true);
    try {
      if (_useBackend) {
        return await _apiService.exportUsersCsv(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          role: _selectedRole.isEmpty ? null : _selectedRole,
          status: _selectedStatus.isEmpty ? null : _selectedStatus,
        );
      } else {
        // Demo CSV export
        const header =
            'id,name,email,role,status,createdAt,plan,isSeller,legalName,gstin,address,materials';
        final rows = _users.map((user) {
          final sellerProfile = user.sellerProfile;
          return [
            user.id,
            user.name,
            user.email,
            user.role.toString().split('.').last,
            user.status.toString().split('.').last,
            user.createdAt.toIso8601String(),
            user.plan,
            user.isSeller.toString(),
            sellerProfile?.companyName ?? '',
            sellerProfile?.gstNumber ?? '',
            sellerProfile?.address ?? '',
            sellerProfile?.materials.join(';') ?? '',
          ]
              .map((field) => '"${field.toString().replaceAll('"', '""')}"')
              .join(',');
        }).toList();

        return [header, ...rows].join('\n');
      }
    } catch (e) {
      _setError('Failed to export users: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<BulkOperationResult> importUsersCsv(String csvContent,
      {bool dryRun = false}) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        return await _apiService.importUsersCsv(csvContent, dryRun: dryRun);
      } else {
        // Demo CSV import
        final lines = csvContent.split('\n');
        if (lines.isEmpty) throw Exception('Empty CSV file');

        final header = lines[0].split(',');
        final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);

        int successCount = 0;
        int failureCount = 0;
        final errors = <String>[];

        for (final line in dataLines) {
          try {
            final values = _parseCsvLine(line);
            if (values.length >= header.length) {
              // Create user from CSV data
              final user = AdminUser(
                id: 'U${DateTime.now().millisecondsSinceEpoch}_$successCount',
                name: values[1],
                email: values[2],
                phone: '+91 00000 00000',
                role: UserRole.values.firstWhere(
                    (r) => r.toString().split('.').last == values[3]),
                status: UserStatus.values.firstWhere(
                    (s) => s.toString().split('.').last == values[4]),
                subscription: SubscriptionPlan.free,
                joinDate: DateTime.tryParse(values[5]) ?? DateTime.now(),
                lastActive: DateTime.now(),
                location: 'Unknown',
                industry: 'Unknown',
                createdAt: DateTime.now(),
                isSeller: values[7] == 'true',
                plan: values[6],
                sellerProfile: values[7] == 'true'
                    ? sell.SellerProfile(
                        companyName: values[8],
                        gstNumber: values[9],
                        address: values[10],
                        materials: values[11]
                            .split(';')
                            .where((m) => m.isNotEmpty)
                            .toList(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      )
                    : null,
              );

              if (!dryRun) {
                _demoDataService.addUser(user);
              }
              successCount++;
            } else {
              failureCount++;
              errors.add('Invalid CSV line: $line');
            }
          } catch (e) {
            failureCount++;
            errors.add('Failed to process line: $line - $e');
          }
        }

        if (!dryRun) {
          await refreshUsers();
        }

        return BulkOperationResult(
          successCount: successCount,
          failureCount: failureCount,
          errors: errors,
        );
      }
    } catch (e) {
      _setError('Failed to import users: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    String current = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current.trim());

    return result;
  }

  // ================= Hero Sections =================

  Future<void> loadHeroSections() async {
    if (_useBackend) {
      try {
        _heroSections = await _apiService.getHeroSections();
        notifyListeners();
      } catch (e) {
        _setError('Failed to load hero sections: $e');
      }
    } else {
      _heroSections = _demoDataService.heroSections;
      notifyListeners();
    }
  }

  Future<HeroSection> createHeroSection(
      CreateHeroSectionRequest request) async {
    _setLoading(true);
    try {
      HeroSection heroSection;
      if (_useBackend) {
        heroSection = await _apiService.createHeroSection(request);
      } else {
        heroSection = HeroSection(
          id: 'hero_${DateTime.now().millisecondsSinceEpoch}',
          title: request.title,
          subtitle: request.subtitle,
          imageUrl: request.imageUrl,
          ctaText: request.ctaText,
          ctaUrl: request.ctaUrl,
          priority: request.priority,
          isActive: request.isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _demoDataService.addHeroSection(heroSection);
      }

      await loadHeroSections();
      return heroSection;
    } catch (e) {
      _setError('Failed to create hero section: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<HeroSection> updateHeroSection(
      String id, UpdateHeroSectionRequest request) async {
    _setLoading(true);
    try {
      HeroSection heroSection;
      if (_useBackend) {
        heroSection = await _apiService.updateHeroSection(id, request);
      } else {
        // Demo update: merge with existing
        final existing = _heroSections.firstWhere((h) => h.id == id);
        heroSection = existing.copyWith(
          title: request.title ?? existing.title,
          subtitle: request.subtitle ?? existing.subtitle,
          imageUrl: request.imageUrl ?? existing.imageUrl,
          ctaText: request.ctaText ?? existing.ctaText,
          ctaUrl: request.ctaUrl ?? existing.ctaUrl,
          priority: request.priority ?? existing.priority,
          isActive: request.isActive ?? existing.isActive,
          updatedAt: DateTime.now(),
        );
        _demoDataService.updateHeroSection(heroSection);
      }

      await loadHeroSections();
      return heroSection;
    } catch (e) {
      _setError('Failed to update hero section: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHeroSection(String id) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.deleteHeroSection(id);
      } else {
        // Demo delete
        _demoDataService.removeHeroSection(id);
      }

      await loadHeroSections();
    } catch (e) {
      _setError('Failed to delete hero section: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reorderHeroSections(List<String> orderedIds) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.reorderHeroSections(orderedIds);
      } else {
        // Demo reorder - update priorities based on order
        for (int i = 0; i < orderedIds.length; i++) {
          final id = orderedIds[i];
          final hero = _heroSections.firstWhere((h) => h.id == id);
          _demoDataService.updateHeroSection(
              hero.copyWith(priority: i + 1, updatedAt: DateTime.now()));
        }
      }

      await loadHeroSections();
    } catch (e) {
      _setError('Failed to reorder hero sections: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSlideDurations({
    required int firstSlideDuration,
    required int otherSlidesDuration,
  }) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.saveSlideDurations(
          firstSlideSeconds: firstSlideDuration,
          otherSlidesSeconds: otherSlidesDuration,
        );
      } else {
        // Demo: simulate delay
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // In a real app, we would update cached settings; for now, just notify
      notifyListeners();
    } catch (e) {
      _setError('Failed to update slide durations: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= Categories =================

  Future<void> _loadCategories() async {
    if (_useBackend) {
      try {
        final apiCategories = await _apiService.getCategories();
        _categories = apiCategories
            .map((cat) => AdminCategoryData(
                  id: cat.id,
                  name: cat.name,
                  description: cat.description ?? '',
                  imageUrl: '',
                  productCount: 0,
                  industries: [],
                  materials: [],
                  isActive: cat.isActive,
                  priority: cat.sortOrder,
                  createdAt: cat.createdAt,
                  updatedAt: cat.createdAt,
                ))
            .toList();
        notifyListeners();
      } catch (e) {
        _setError('Failed to load categories: $e');
      }
    } else {
      // Load from demo data or create default categories
      _categories = [
        AdminCategoryData(
          id: 'cat_1',
          name: 'Cables & Wires',
          description: 'Electrical cables and wires for various applications',
          imageUrl: 'https://picsum.photos/seed/cables/400/300',
          productCount: 1250,
          industries: ['Construction', 'EPC', 'MEP', 'Industrial'],
          materials: ['Copper', 'Aluminium', 'PVC', 'XLPE'],
          isActive: true,
          priority: 1,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      notifyListeners();
    }
  }

  // ================= Notifications =================

  Future<void> _loadNotificationTemplates() async {
    if (_useBackend) {
      try {
        _notificationTemplates = await _apiService.getNotificationTemplates();
        notifyListeners();
      } catch (e) {
        _setError('Failed to load notification templates: $e');
      }
    } else {
      _notificationTemplates = _demoDataService.notificationTemplates;
      notifyListeners();
    }
  }

  Future<notif.NotificationSendResult> sendNotification(
      notif.NotificationDraft draft) async {
    _setLoading(true);
    try {
      notif.NotificationSendResult result;
      if (_useBackend) {
        // Validate channels: must include inApp; push optional behind feature flag
        final hasInApp = draft.channels
            .contains(notif.NotificationChannel.inApp);
        if (!hasInApp) {
          throw Exception('Notification must include in-app channel');
        }
        result = await _apiService.sendNotification(draft);
        if (result.jobId != null) {
          _subscribeToNotificationJob(result.jobId!);
        }
      } else {
        // Demo notification sending
        result = notif.NotificationSendResult(
          sentCount: 100, // Mock count
          failedCount: 0,
          jobId: 'demo_job_${DateTime.now().millisecondsSinceEpoch}',
        );
        _currentNotificationJobId = result.jobId;
        _currentNotificationJob = {
          'status': 'succeeded',
          'counts': {
            'estimated': 100,
            'targeted': 100,
            'succeeded': 100,
            'failed': 0,
          }
        };
        notifyListeners();
      }

      return result;
    } catch (e) {
      _setError('Failed to send notification: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Estimate audience size via backend when enabled
  Future<int> estimateAudienceSize(notif.AudienceFilter audience) async {
    if (_useBackend) {
      try {
        return await _apiService.estimateAudienceSize(audience);
      } catch (e) {
        _setError('Failed to estimate audience: $e');
        return 0;
      }
    }
    // Fallback to demo estimation
    return 0;
  }

  void _subscribeToNotificationJob(String jobId) {
    _notificationJobSubscription?.cancel();
    _currentNotificationJobId = jobId;
    final docRef =
        FirebaseFirestore.instance.collection('notification_jobs').doc(jobId);
    _notificationJobSubscription = docRef
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        _currentNotificationJob = snapshot.data();
        notifyListeners();
      }
    });
  }

  // ================= Plans =================

  Future<void> _loadPlans() async {
    if (_useBackend) {
      try {
        _plans = await _apiService.getPlans();
        notifyListeners();
      } catch (e) {
        _setError('Failed to load plans: $e');
      }
    } else {
      _plans = [
        const sub.Plan(
          id: 'plan_free',
          name: 'Free',
          code: 'free',
          description: 'Basic access',
          status: sub.PlanStatus.published,
          defaultPointsPerCycle: 50,
          visiblePublicly: true,
          version: 1,
        ),
        const sub.Plan(
          id: 'plan_plus',
          name: 'Plus',
          code: 'plus',
          description: 'For growing sellers',
          status: sub.PlanStatus.published,
          defaultPointsPerCycle: 200,
          visiblePublicly: true,
          version: 1,
        ),
      ];
      notifyListeners();
    }
  }

  Future<void> updateUserSubscription(String userId, String planId) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.updateUserSubscription(userId, planId);
      } else {
        final user = _demoDataService.getUser(userId);
        if (user != null) {
          final updatedUser = user.copyWith(plan: planId);
          _demoDataService.updateUser(updatedUser);
        }
      }

      await refreshUsers();
    } catch (e) {
      _setError('Failed to update subscription: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= File Upload =================

  Future<String> uploadImage(dynamic imageFile) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        return await _apiService.uploadImage(imageFile);
      } else {
        // Demo: return a placeholder URL
        return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300';
      }
    } catch (e) {
      _setError('Failed to upload image: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= Helper Methods =================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ================= KYC Management =================

  Future<void> _loadKycReviews({
    int page = 1,
    int limit = 20,
    KycReviewStatus? status,
    String? search,
    bool? overdue,
    bool? highPriority,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    if (_useBackend) {
      try {
        final response = await _apiService.getKycReviews(
          page: page,
          limit: limit,
          status: status?.value,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        if (page == 1) {
          _kycReviews = response.reviews;
        } else {
          _kycReviews.addAll(response.reviews);
        }

        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _currentPage = response.page;

        notifyListeners();
      } catch (e) {
        _setError('Failed to load KYC reviews: $e');
      }
    } else {
      // Demo KYC reviews
      _kycReviews = _generateDemoKycReviews();
      notifyListeners();
    }
  }

  Future<void> loadKycReviews({
    int page = 1,
    int limit = 20,
    KycReviewStatus? status,
    String? search,
    bool? overdue,
    bool? highPriority,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    _setLoading(true);
    try {
      await _loadKycReviews(
        page: page,
        limit: limit,
        status: status,
        search: search,
        overdue: overdue,
        highPriority: highPriority,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadKycQueueStats() async {
    if (_useBackend) {
      try {
        _kycQueueStats = await _apiService.getKycQueueStats();
        notifyListeners();
      } catch (e) {
        _setError('Failed to load KYC queue stats: $e');
      }
    } else {
      // Demo queue stats
      _kycQueueStats = KycQueueStats(
        totalPending: 15,
        totalInProgress: 8,
        totalApproved: 245,
        totalRejected: 12,
        overdueReviews: 3,
        highPriorityReviews: 5,
        averageProcessingTime: 2.5,
        slaCompliance: 0.94,
      );
      notifyListeners();
    }
  }

  Future<KycReview> getKycReview(String reviewId) async {
    if (_useBackend) {
      try {
        return await _apiService.getKycReview(reviewId);
      } catch (e) {
        _setError('Failed to get KYC review: $e');
        rethrow;
      }
    } else {
      // Return demo review
      final review = _kycReviews.firstWhere(
        (r) => r.id == reviewId,
        orElse: () => throw Exception('Review not found'),
      );
      return review;
    }
  }

  Future<KycReview> updateKycReview(
      String reviewId, UpdateKycReviewRequest request) async {
    _setLoading(true);
    try {
      KycReview updatedReview;
      if (_useBackend) {
        updatedReview = await _apiService.updateKycReview(reviewId, request);
      } else {
        // Demo update
        final existingReview = _kycReviews.firstWhere((r) => r.id == reviewId);
        updatedReview = existingReview.copyWith(
          status: request.status ?? existingReview.status,
          reviewComments:
              request.reviewComments ?? existingReview.reviewComments,
          rejectionReason:
              request.rejectionReason ?? existingReview.rejectionReason,
          nextSteps: request.nextSteps ?? existingReview.nextSteps,
          reviewedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final index = _kycReviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _kycReviews[index] = updatedReview;
        }
      }

      notifyListeners();
      return updatedReview;
    } catch (e) {
      _setError('Failed to update KYC review: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<BulkOperationResult> performBulkKycAction({
    required List<String> reviewIds,
    required String action,
    String? reason,
    String? comments,
  }) async {
    _setLoading(true);
    try {
      BulkOperationResult result;
      if (_useBackend) {
        final request = BulkKycActionRequest(
          reviewIds: reviewIds,
          action: action,
          reason: reason,
        );
        final bulkResult = await _apiService.bulkKycAction(request);
        result = BulkOperationResult(
          successCount: bulkResult.successCount,
          failureCount: bulkResult.failureCount,
          errors: bulkResult.errors,
          jobId: bulkResult.jobId,
        );
      } else {
        // Demo bulk action
        int successCount = 0;
        int failureCount = 0;
        final errors = <String>[];

        for (final reviewId in reviewIds) {
          try {
            final reviewIndex = _kycReviews.indexWhere((r) => r.id == reviewId);
            if (reviewIndex != -1) {
              final review = _kycReviews[reviewIndex];
              KycReviewStatus newStatus;

              switch (action) {
                case 'approve':
                  newStatus = KycReviewStatus.approved;
                  break;
                case 'reject':
                  newStatus = KycReviewStatus.rejected;
                  break;
                case 'request_info':
                  newStatus = KycReviewStatus.requiresAdditionalInfo;
                  break;
                default:
                  newStatus = review.status;
              }

              _kycReviews[reviewIndex] = review.copyWith(
                status: newStatus,
                reviewComments: comments ?? review.reviewComments,
                rejectionReason:
                    action == 'reject' ? reason : review.rejectionReason,
                reviewedAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              successCount++;
            } else {
              failureCount++;
              errors.add('Review $reviewId not found');
            }
          } catch (e) {
            failureCount++;
            errors.add('Failed to update review $reviewId: $e');
          }
        }

        result = BulkOperationResult(
          successCount: successCount,
          failureCount: failureCount,
          errors: errors,
        );
      }

      notifyListeners();
      return result;
    } catch (e) {
      _setError('Failed to perform bulk KYC action: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<KycAuditLog>> getKycAuditLogs({
    String? reviewId,
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    if (_useBackend) {
      try {
        final response = await _apiService.getKycAuditLogs(
          reviewId: reviewId,
          action: action,
          fromDate: startDate,
          toDate: endDate,
          page: page,
          limit: limit,
        );
        return response.logs;
      } catch (e) {
        _setError('Failed to get KYC audit logs: $e');
        rethrow;
      }
    } else {
      // Return demo audit logs
      return _generateDemoKycAuditLogs();
    }
  }

  Future<void> exportKycAuditLogs({
    String? reviewId,
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useBackend) {
      try {
        await _apiService.exportKycAuditLogs(
          reviewId: reviewId,
          action: action,
          fromDate: startDate,
          toDate: endDate,
        );
      } catch (e) {
        _setError('Failed to export KYC audit logs: $e');
        rethrow;
      }
    } else {
      // Demo export
      print('Exporting KYC audit logs...');
    }
  }

  List<KycReview> _generateDemoKycReviews() {
    return [
      KycReview(
        id: 'kyc_1',
        userId: 'user_1',
        userName: 'John Doe',
        userEmail: 'john.doe@example.com',
        status: KycReviewStatus.pending,
        documents: [
          KycDocument(
            id: 'doc_1',
            userId: 'user_1',
            type: KycDocumentType.panCard,
            fileName: 'pan_card.jpg',
            fileUrl: 'https://example.com/pan_card.jpg',
            status: KycDocumentStatus.pending,
            uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
            fileSize: 245760,
            mimeType: 'image/jpeg',
          ),
          KycDocument(
            id: 'doc_2',
            userId: 'user_1',
            type: KycDocumentType.aadharCard,
            fileName: 'aadhar_card.jpg',
            fileUrl: 'https://example.com/aadhar_card.jpg',
            status: KycDocumentStatus.approved,
            uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
            fileSize: 312000,
            mimeType: 'image/jpeg',
          ),
        ],
        requiredDocuments: ['pan_card', 'aadhar_card', 'bank_statement'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        slaDeadline: DateTime.now().add(const Duration(days: 1)),
        priority: 8,
        riskFlags: {'high_risk': true, 'multiple_addresses': true},
      ),
      KycReview(
        id: 'kyc_2',
        userId: 'user_2',
        userName: 'Jane Smith',
        userEmail: 'jane.smith@example.com',
        status: KycReviewStatus.inProgress,
        documents: [
          KycDocument(
            id: 'doc_3',
            userId: 'user_2',
            type: KycDocumentType.passport,
            fileName: 'passport.pdf',
            fileUrl: 'https://example.com/passport.pdf',
            status: KycDocumentStatus.underReview,
            uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
            fileSize: 512000,
            mimeType: 'application/pdf',
          ),
        ],
        requiredDocuments: ['passport', 'utility_bill'],
        reviewerId: 'admin_1',
        reviewerName: 'Admin User',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        slaDeadline: DateTime.now().add(const Duration(hours: 6)),
        priority: 6,
      ),
    ];
  }

  List<KycAuditLog> _generateDemoKycAuditLogs() {
    return [
      KycAuditLog(
        id: 'audit_1',
        reviewId: 'kyc_1',
        userId: 'user_1',
        action: 'review_started',
        actorId: 'admin_1',
        actorName: 'Admin User',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0...',
      ),
      KycAuditLog(
        id: 'audit_2',
        reviewId: 'kyc_1',
        userId: 'user_1',
        action: 'document_approved',
        oldValue: 'pending',
        newValue: 'approved',
        actorId: 'admin_1',
        actorName: 'Admin User',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0...',
      ),
    ];
  }

  // ================= Billing Management =================

  Future<void> loadPayments({
    int page = 1,
    int limit = 20,
    PaymentStatus? status,
    PaymentMethod? method,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    if (_useBackend) {
      try {
        final response = await _apiService.getPayments(
          page: page,
          limit: limit,
          status: status?.value,
          method: method?.value,
          fromDate: startDate,
          toDate: endDate,
        );

        if (page == 1) {
          _payments = response.payments;
        } else {
          _payments.addAll(response.payments);
        }

        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _currentPage = response.page;

        notifyListeners();
      } catch (e) {
        _setError('Failed to load payments: $e');
      }
    } else {
      // Demo payments with simple local filtering
      Iterable<Payment> payments = _demoDataService.allPayments;

      if (status != null) {
        payments = payments.where((payment) => payment.status == status);
      }
      if (method != null) {
        payments = payments.where((payment) => payment.method == method);
      }
      if (startDate != null) {
        payments =
            payments.where((payment) => !payment.createdAt.isBefore(startDate));
      }
      if (endDate != null) {
        payments =
            payments.where((payment) => !payment.createdAt.isAfter(endDate));
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        payments = payments.where((payment) =>
            payment.userName.toLowerCase().contains(query) ||
            payment.userEmail.toLowerCase().contains(query) ||
            (payment.transactionId ?? '').toLowerCase().contains(query));
      }

      final sorted = payments.toList()
        ..sort((a, b) => sortOrder == 'asc'
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));

      _payments = sorted;
      _totalCount = _payments.length;
      _hasMore = false;
      _currentPage = 1;
      notifyListeners();
    }
  }

  Future<void> loadInvoices({
    int page = 1,
    int limit = 20,
    InvoiceStatus? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    bool? overdue,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    if (_useBackend) {
      try {
        final response = await _apiService.getInvoices(
          page: page,
          limit: limit,
          status: status?.value,
          fromDate: startDate,
          toDate: endDate,
        );

        if (page == 1) {
          _invoices = response.invoices;
        } else {
          _invoices.addAll(response.invoices);
        }

        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _currentPage = response.page;

        notifyListeners();
      } catch (e) {
        _setError('Failed to load invoices: $e');
      }
    } else {
      Iterable<Invoice> invoices = _demoDataService.allInvoices;

      if (status != null) {
        invoices = invoices.where((invoice) => invoice.status == status);
      }
      if (overdue != null) {
        invoices = invoices.where((invoice) => invoice.isOverdue == overdue);
      }
      if (startDate != null) {
        invoices =
            invoices.where((invoice) => !invoice.issueDate.isBefore(startDate));
      }
      if (endDate != null) {
        invoices =
            invoices.where((invoice) => !invoice.issueDate.isAfter(endDate));
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        invoices = invoices.where((invoice) =>
            invoice.userName.toLowerCase().contains(query) ||
            invoice.userEmail.toLowerCase().contains(query) ||
            invoice.invoiceNumber.toLowerCase().contains(query));
      }

      final sorted = invoices.toList()
        ..sort((a, b) => sortOrder == 'asc'
            ? a.issueDate.compareTo(b.issueDate)
            : b.issueDate.compareTo(a.issueDate));

      _invoices = sorted;
      _totalCount = _invoices.length;
      _hasMore = false;
      _currentPage = 1;
      notifyListeners();
    }
  }

  Future<void> loadBillingStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useBackend) {
      try {
        _billingStats = await _apiService.getBillingStats(
          fromDate: startDate,
          toDate: endDate,
        );
        notifyListeners();
      } catch (e) {
        _setError('Failed to load billing stats: $e');
      }
    } else {
      // Recompute snapshot from current demo data for deterministic analytics
      final completed =
          _payments.where((p) => p.status == PaymentStatus.completed).toList();
      final pendingPays =
          _payments.where((p) => p.status == PaymentStatus.pending).toList();
      final failedPays =
          _payments.where((p) => p.status == PaymentStatus.failed).toList();

      final overdueInvs =
          _invoices.where((i) => i.status == InvoiceStatus.overdue).toList();
      final pendingInvs =
          _invoices.where((i) => i.status == InvoiceStatus.pending).toList();

      final totalRevenue =
          completed.fold<double>(0, (sum, p) => sum + p.amount);
      final pendingPayments =
          pendingPays.fold<double>(0, (sum, p) => sum + p.amount);
      final overdueAmount =
          overdueInvs.fold<double>(0, (sum, i) => sum + i.totalAmount);

      _billingStats = BillingStats(
        totalRevenue: totalRevenue,
        monthlyRevenue: totalRevenue, // simple demo calc
        pendingPayments: pendingPayments,
        overdueAmount: overdueAmount,
        totalInvoices: _invoices.length,
        pendingInvoices: pendingInvs.length,
        overdueInvoices: overdueInvs.length,
        totalPayments: _payments.length,
        successfulPayments: completed.length,
        failedPayments: failedPays.length,
        averagePaymentValue:
            _payments.isEmpty ? 0 : totalRevenue / _payments.length,
        refundRate: 0.02,
      );
      notifyListeners();
    }
  }

  // ===== Dunning/actions =====
  Future<void> retryInvoicePayment(String invoiceId) async {
    if (_useBackend) {
      await _apiService.retryInvoicePayment(invoiceId);
      await loadBillingStats();
      notifyListeners();
      return;
    }
    final idx = _invoices.indexWhere((i) => i.id == invoiceId);
    if (idx == -1) return;
    final inv = _invoices[idx];
    // Create a demo payment attempt and move invoice to 'sent'
    final pay = Payment(
      id: 'pay_retry_${DateTime.now().millisecondsSinceEpoch}',
      userId: inv.userId,
      userName: inv.userName,
      userEmail: inv.userEmail,
      amount: inv.totalAmount,
      currency: inv.currency,
      status: PaymentStatus.processing,
      method: PaymentMethod.card,
      transactionId: 'TXN-RETRY-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _payments.insert(0, pay);
    _invoices[idx] = inv.copyWith(status: InvoiceStatus.sent);
    await loadBillingStats();
    notifyListeners();
  }

  Future<void> notifyDunningInvoice(String invoiceId) async {
    if (_useBackend) {
      await _apiService.notifyInvoiceDunning(invoiceId);
      await loadBillingStats();
      return;
    }
    // Demo: no-op besides analytics refresh
    await loadBillingStats();
  }

  Future<Invoice> createInvoice(CreateInvoiceRequest request) async {
    _setLoading(true);
    try {
      Invoice invoice;
      if (_useBackend) {
        invoice = await _apiService.createInvoice(request);
      } else {
        // Demo invoice creation
        invoice = Invoice(
          id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
          userId: request.userId,
          userName: 'Demo User',
          userEmail: 'demo@example.com',
          invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
          issueDate: DateTime.now(),
          dueDate: request.dueDate,
          subtotal:
              request.items.fold(0.0, (sum, item) => sum + item.totalPrice),
          taxAmount:
              request.items.fold(0.0, (sum, item) => sum + item.totalPrice) *
                  0.18,
          totalAmount:
              request.items.fold(0.0, (sum, item) => sum + item.totalPrice) *
                  1.18,
          currency: Currency.inr,
          status: InvoiceStatus.draft,
          items: request.items,
          taxes: [
            InvoiceTax(
              type: TaxType.gst,
              name: 'GST',
              rate: 18.0,
              amount: request.items
                      .fold(0.0, (sum, item) => sum + item.totalPrice) *
                  0.18,
            ),
          ],
          notes: request.notes,
        );
      }

      await loadInvoices();
      return invoice;
    } catch (e) {
      _setError('Failed to create invoice: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendInvoice(String invoiceId) async {
    _setLoading(true);
    try {
      if (_useBackend) {
        await _apiService.sendInvoice(invoiceId);
      } else {
        // Demo send invoice
        final index = _invoices.indexWhere((i) => i.id == invoiceId);
        if (index != -1) {
          _invoices[index] =
              _invoices[index].copyWith(status: InvoiceStatus.sent);
        }
      }

      await loadInvoices();
    } catch (e) {
      _setError('Failed to send invoice: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Refund> createRefund(CreateRefundRequest request) async {
    _setLoading(true);
    try {
      Refund refund;
      if (_useBackend) {
        refund = await _apiService.createRefund(request);
      } else {
        // Demo refund creation
        refund = Refund(
          id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
          paymentId: request.paymentId,
          userId: 'user_1',
          userName: 'Demo User',
          userEmail: 'demo@example.com',
          amount: request.amount,
          currency: Currency.inr,
          status: PaymentStatus.pending,
          reason: request.reason,
          createdAt: DateTime.now(),
          notes: request.notes,
        );
      }

      await loadPayments();
      return refund;
    } catch (e) {
      _setError('Failed to create refund: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> exportPaymentsCsv({
    PaymentStatus? status,
    PaymentMethod? method,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useBackend) {
      try {
        return await _apiService.exportPaymentsCsv(
          status: status?.value,
          method: method?.value,
          fromDate: startDate,
          toDate: endDate,
        );
      } catch (e) {
        _setError('Failed to export payments: $e');
        rethrow;
      }
    } else {
      // Demo CSV export
      const header =
          'id,user_name,user_email,amount,currency,status,method,created_at';
      final rows = _payments.map((payment) => [
            payment.id,
            payment.userName,
            payment.userEmail,
            payment.amount.toStringAsFixed(2),
            payment.currency.code,
            payment.status.value,
            payment.method.value,
            payment.createdAt.toIso8601String(),
          ]
              .map((field) => '"${field.toString().replaceAll('"', '""')}"')
              .join(','));

      final content = [header, ...rows].join('\n');
      return content; // Web-safe: return CSV content string
    }
  }

  Future<String> exportInvoicesCsv({
    InvoiceStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? overdue,
  }) async {
    if (_useBackend) {
      try {
        return await _apiService.exportInvoicesCsv(
          status: status?.value,
          fromDate: startDate,
          toDate: endDate,
        );
      } catch (e) {
        _setError('Failed to export invoices: $e');
        rethrow;
      }
    } else {
      // Demo CSV export
      const header =
          'id,invoice_number,user_name,user_email,total_amount,currency,status,issue_date,due_date';
      final rows = _invoices.map((invoice) => [
            invoice.id,
            invoice.invoiceNumber,
            invoice.userName,
            invoice.userEmail,
            invoice.totalAmount.toStringAsFixed(2),
            invoice.currency.code,
            invoice.status.value,
            invoice.issueDate.toIso8601String(),
            invoice.dueDate.toIso8601String(),
          ]
              .map((field) => '"${field.toString().replaceAll('"', '""')}"')
              .join(','));

      final content = [header, ...rows].join('\n');
      return content; // Web-safe: return CSV content string
    }
  }

  Future<BulkOperationResult> performBulkPaymentAction({
    required List<String> paymentIds,
    required String action,
  }) async {
    _setLoading(true);
    try {
      BulkOperationResult result;
      if (_useBackend) {
        result = await _apiService.bulkPaymentAction(
          paymentIds: paymentIds,
          action: action,
        );
      } else {
        // Demo bulk action
        result = BulkOperationResult(
          successCount: paymentIds.length,
          failureCount: 0,
          errors: [],
        );
      }

      await loadPayments();
      return result;
    } catch (e) {
      _setError('Failed to perform bulk payment action: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<BulkOperationResult> performBulkInvoiceAction({
    required List<String> invoiceIds,
    required String action,
  }) async {
    _setLoading(true);
    try {
      BulkOperationResult result;
      if (_useBackend) {
        result = await _apiService.bulkInvoiceAction(
          invoiceIds: invoiceIds,
          action: action,
        );
      } else {
        // Demo bulk action
        result = BulkOperationResult(
          successCount: invoiceIds.length,
          failureCount: 0,
          errors: [],
        );
      }

      await loadInvoices();
      return result;
    } catch (e) {
      _setError('Failed to perform bulk invoice action: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= Toggle Backend Mode =================

  Future<void> toggleBackendMode(bool useBackend) async {
    if (_useBackend != useBackend) {
      _useBackend = useBackend;
      _isInitialized = false;
      await _initialize();
    }
  }

  // ================= Seller Management =================

  List<AdminUser> get sellers =>
      _users.where((user) => user.role == UserRole.seller).toList();

  Future<void> approveSeller(String sellerId, {String? comments}) async {
    if (_useBackend) {
      try {
        await _apiService.updateUser(
          sellerId,
          UpdateUserRequest(
              status: 'active',
              /* optionally include */ companyName: null,
              gstNumber: null,
              address: null,
              materials: null),
        );
        await refreshUsers();
      } catch (e) {
        throw Exception('Failed to approve seller: $e');
      }
    } else {
      final index = _users.indexWhere((user) => user.id == sellerId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = user.copyWith(status: UserStatus.active);
        _sellerAuditLogs.add({
          'sellerId': sellerId,
          'action': 'approve',
          'comments': comments,
          'timestamp': DateTime.now(),
        });
        notifyListeners();
      }
    }
  }

  Future<void> suspendSeller(String sellerId, {required String reason}) async {
    if (_useBackend) {
      try {
        await _apiService.updateUser(
          sellerId,
          UpdateUserRequest(status: 'suspended'),
        );
        await refreshUsers();
      } catch (e) {
        throw Exception('Failed to suspend seller: $e');
      }
    } else {
      final index = _users.indexWhere((user) => user.id == sellerId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = user.copyWith(status: UserStatus.suspended);
        _sellerAuditLogs.add({
          'sellerId': sellerId,
          'action': 'suspend',
          'reason': reason,
          'timestamp': DateTime.now(),
        });
        notifyListeners();
      }
    }
  }

  // ================= Product Management =================

  // Demo product data for seller controls
  List<Map<String, dynamic>> get sellerDemoProducts =>
      _generateSellerDemoProducts();

  List<Map<String, dynamic>> _generateSellerDemoProducts() {
    return [
      {
        'id': 'prod_001',
        'sellerId': 'seller_001',
        'sellerName': 'TechMart Electronics',
        'name': 'Smart LED TV 55 inch',
        'description': 'Ultra HD 4K Smart LED TV with Android OS',
        'category': 'Electronics',
        'price': 45999.0,
        'stock': 25,
        'status': 'active',
        'rating': 4.3,
        'reviews': 127,
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      },
      {
        'id': 'prod_002',
        'sellerId': 'seller_002',
        'sellerName': 'HomeDecor Plus',
        'name': 'Wooden Dining Table Set',
        'description': '6-seater solid wood dining table with chairs',
        'category': 'Furniture',
        'price': 28500.0,
        'stock': 8,
        'status': 'pending_review',
        'rating': 4.6,
        'reviews': 89,
        'createdAt': DateTime.now().subtract(const Duration(days: 8)),
      },
      {
        'id': 'prod_003',
        'sellerId': 'seller_003',
        'sellerName': 'Fashion Hub',
        'name': 'Cotton Casual Shirt',
        'description': 'Premium cotton casual shirt for men',
        'category': 'Clothing',
        'price': 1299.0,
        'stock': 150,
        'status': 'active',
        'rating': 4.1,
        'reviews': 203,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }

  // ================= Leads Management =================

  List<Map<String, dynamic>> get leads => _generateDemoLeads();

  List<Map<String, dynamic>> _generateDemoLeads() {
    return [
      {
        'id': 'lead_001',
        'customerName': 'Rahul Sharma',
        'customerEmail': 'rahul.sharma@email.com',
        'customerPhone': '+91 9876543210',
        'productCategory': 'Electronics',
        'status': 'new',
        'priority': 'high',
        'estimatedValue': 75000.0,
        'assignedTo': 'sales_001',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'slaDeadline': DateTime.now().add(const Duration(hours: 22)),
      },
      {
        'id': 'lead_002',
        'customerName': 'Priya Patel',
        'customerEmail': 'priya.patel@email.com',
        'customerPhone': '+91 9876543211',
        'productCategory': 'Home & Garden',
        'status': 'contacted',
        'priority': 'medium',
        'estimatedValue': 35000.0,
        'assignedTo': 'sales_002',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'slaDeadline': DateTime.now().add(const Duration(hours: 16)),
      },
      {
        'id': 'lead_003',
        'customerName': 'Amit Singh',
        'customerEmail': 'amit.singh@email.com',
        'customerPhone': '+91 9876543212',
        'productCategory': 'Tools',
        'status': 'qualified',
        'priority': 'low',
        'estimatedValue': 15000.0,
        'assignedTo': 'sales_001',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'slaDeadline': DateTime.now().add(const Duration(hours: 8)),
      },
    ];
  }

  // Orders removed from Admin: demo data and getter deleted

  // ================= Products Management =================

  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (refresh) {
        _currentPage = 1;
        _products.clear();
        _hasMore = true;
      }

      if (_useBackend) {
        final response = await _apiService.getProducts(
          page: _currentPage,
          limit: 20,
          search: _searchQuery,
          category: _selectedRole, // Reusing role filter for category
          status: _selectedStatus,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        );

        if (refresh) {
          _products = response.products;
        } else {
          _products.addAll(response.products);
        }

        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _currentPage++;
      } else {
        // Demo data from LightweightDemoDataService with client-side filters
        List<admin_prod.Product> mapped =
            _demoDataService.allProducts.map(_mapSellToAdminProduct).toList();

        // Category filter (supports slug or display name)
        if (_selectedRole.isNotEmpty) {
          mapped = mapped.where((p) {
            final slug = _toSlug(p.category);
            return slug == _selectedRole || p.category == _selectedRole;
          }).toList();
        }

        // Material filter
        if (_selectedMaterial.isNotEmpty) {
          final q = _selectedMaterial.toLowerCase();
          mapped = mapped
              .where((p) => p.materials.any((m) => m.toLowerCase().contains(q)))
              .toList();
        }

        // Status filter
        if (_selectedStatus.isNotEmpty) {
          mapped =
              mapped.where((p) => p.status.value == _selectedStatus).toList();
        }

        // Search filter
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.trim().toLowerCase();
          mapped = mapped.where((p) {
            bool contains(String s) => s.toLowerCase().contains(q);
            return contains(p.title) ||
                contains(p.brand) ||
                contains(p.subtitle) ||
                contains(p.description) ||
                contains(p.category) ||
                p.materials.any((m) => m.toLowerCase().contains(q));
          }).toList();
        }

        // Sorting
        int cmp(admin_prod.Product a, admin_prod.Product b) {
          int c;
          switch (_sortBy) {
            case 'name':
              c = a.title.toLowerCase().compareTo(b.title.toLowerCase());
              break;
            case 'price':
              c = a.price.compareTo(b.price);
              break;
            case 'views':
              c = a.viewCount.compareTo(b.viewCount);
              break;
            case 'createdAt':
            default:
              c = a.createdAt.compareTo(b.createdAt);
          }
          return _sortOrder == 'desc' ? -c : c;
        }

        mapped.sort(cmp);

        if (refresh) {
          _products = mapped;
        } else {
          _products.addAll(mapped);
        }
        _totalCount = mapped.length;
        _hasMore = false;
      }
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  Future<void> loadMoreProducts() async {
    if (_hasMore && !_isLoading) {
      await loadProducts();
    }
  }

  void setProductSearchQuery(String query) {
    _searchQuery = query;
    loadProducts(refresh: true);
  }

  void setProductCategoryFilter(String category) {
    _selectedRole = category;
    loadProducts(refresh: true);
  }

  void setProductMaterialFilter(String material) {
    _selectedMaterial = material;
    loadProducts(refresh: true);
  }

  void setProductStatusFilter(String status) {
    _selectedStatus = status;
    loadProducts(refresh: true);
  }

  void setProductStockFilter(String stock) {
    // You might want to add a separate stock filter state
    loadProducts(refresh: true);
  }

  void setProductSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    loadProducts(refresh: true);
  }

  // Product selection methods
  void selectProduct(String productId) {
    _selectedProductIds.add(productId);
    notifyListeners();
  }

  void deselectProduct(String productId) {
    _selectedProductIds.remove(productId);
    notifyListeners();
  }

  void selectAllProducts() {
    _selectedProductIds.addAll(_products.map((p) => p.id));
    notifyListeners();
  }

  void deselectAllProducts() {
    _selectedProductIds.clear();
    notifyListeners();
  }

  // Product CRUD operations
  Future<admin_prod.Product> createProduct(
      admin_prod.CreateProductRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      admin_prod.Product product;
      if (_useBackend) {
        product = await _apiService.createProduct(request);
      } else {
        // Demo implementation
        product = admin_prod.Product(
          id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
          title: request.title,
          brand: request.brand,
          subtitle: request.subtitle,
          category: request.category,
          description: request.description,
          images: request.images,
          price: request.price,
          moq: request.moq,
          gstRate: request.gstRate,
          materials: request.materials,
          customValues: request.customValues,
          status: request.status,
          createdAt: DateTime.now(),
          rating: 0,
          viewCount: 0,
          orderCount: 0,
        );
        // Sync into demo data layer
        _demoDataService.addProduct(sell.Product(
          id: product.id,
          title: product.title,
          brand: product.brand,
          subtitle: product.subtitle,
          category: _fromSlugIfNeeded(product.category),
          description: product.description,
          images: product.images,
          price: product.price,
          moq: product.moq,
          gstRate: product.gstRate,
          materials: product.materials,
          customValues: product.customValues,
          status: _toSellStatus(product.status),
          createdAt: product.createdAt,
          rating: product.rating,
        ));
      }

      _products.insert(0, product);
      _totalCount++;
      return product;
    } catch (e) {
      _error = 'Failed to create product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<admin_prod.Product> updateProduct(
      String productId, admin_prod.UpdateProductRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      admin_prod.Product updatedProduct;
      if (_useBackend) {
        updatedProduct = await _apiService.updateProduct(productId, request);
      } else {
        // Demo implementation
        final index = _products.indexWhere((p) => p.id == productId);
        if (index == -1) throw Exception('Product not found');

        final existingProduct = _products[index];
        updatedProduct = existingProduct.copyWith(
          title: request.title,
          brand: request.brand,
          subtitle: request.subtitle,
          category: request.category,
          description: request.description,
          images: request.images,
          price: request.price,
          moq: request.moq,
          gstRate: request.gstRate,
          materials: request.materials,
          customValues: request.customValues,
          status: request.status,
          updatedAt: DateTime.now(),
        );
        // Sync demo data layer
        _demoDataService.updateProduct(sell.Product(
          id: updatedProduct.id,
          title: updatedProduct.title,
          brand: updatedProduct.brand,
          subtitle: updatedProduct.subtitle,
          category: _fromSlugIfNeeded(updatedProduct.category),
          description: updatedProduct.description,
          images: updatedProduct.images,
          price: updatedProduct.price,
          moq: updatedProduct.moq,
          gstRate: updatedProduct.gstRate,
          materials: updatedProduct.materials,
          customValues: updatedProduct.customValues,
          status: _toSellStatus(updatedProduct.status),
          createdAt: updatedProduct.createdAt,
          rating: updatedProduct.rating,
        ));
      }

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      return updatedProduct;
    } catch (e) {
      _error = 'Failed to update product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useBackend) {
        await _apiService.deleteProduct(productId);
      }

      _products.removeWhere((p) => p.id == productId);
      _selectedProductIds.remove(productId);
      _totalCount--;
      if (!_useBackend) {
        _demoDataService.removeProduct(productId);
      }
    } catch (e) {
      _error = 'Failed to delete product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bulk operations
  Future<BulkOperationResult> bulkUpdateProductStatus(String status) async {
    _isBulkOperationInProgress = true;
    _bulkOperationStatus = 'Updating product status...';
    notifyListeners();

    try {
      int successCount = 0;
      int failureCount = 0;
      final List<String> errors = [];

      for (final productId in _selectedProductIds) {
        try {
          await updateProduct(
              productId,
              admin_prod.UpdateProductRequest(
                  status: ProductStatus.fromString(status)));
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Product $productId: $e');
        }
      }

      _selectedProductIds.clear();
      return BulkOperationResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
    } finally {
      _isBulkOperationInProgress = false;
      _bulkOperationStatus = null;
      notifyListeners();
    }
  }

  // CSV operations
  Future<String> exportProductsCsv() async {
    if (_useBackend) {
      return await _apiService.exportProductsCsv();
    } else {
      // Demo CSV generation
      final csv = StringBuffer();
      csv.writeln(
          'ID,Name,Description,Category,Material,Price,Stock,Unit,Status,Created At');

      for (final product in _products) {
        csv.writeln([
          product.id,
          product.title,
          product.description,
          product.category,
          product.materials.isNotEmpty ? product.materials.first : '',
          product.price,
          product.moq,
          '',
          product.status.toString().split('.').last,
          product.createdAt.toIso8601String(),
        ].join(','));
      }

      return csv.toString();
    }
  }

  Future<BulkOperationResult> importProductsCsv(String csvContent,
      {bool dryRun = false}) async {
    if (_useBackend) {
      return await _apiService.importProductsCsv(csvContent, dryRun: dryRun);
    } else {
      // Demo implementation
      final lines = csvContent.split('\n');
      int successCount = 0;
      int failureCount = 0;
      final List<String> errors = [];

      for (int i = 1; i < lines.length; i++) {
        // Skip header
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final parts = line.split(',');
          if (parts.length < 10) {
            failureCount++;
            errors.add('Line ${i + 1}: Invalid CSV format');
            continue;
          }

          if (!dryRun) {
            final request = admin_prod.CreateProductRequest(
              title: parts[1],
              brand: parts[2],
              subtitle: '',
              category: parts[3],
              description: parts[4],
              images: [],
              price: double.parse(parts[5]),
              moq: int.parse(parts[6]),
              gstRate: 18.0,
              materials: [parts[7]],
              customValues: {},
              status: ProductStatus.fromString(parts[8]),
            );

            await createProduct(request);
          }

          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Line ${i + 1}: $e');
        }
      }

      return BulkOperationResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
    }
  }

  // Removed unused demo products generator

  // ===== Helpers for demo mapping =====
  admin_prod.Product _mapSellToAdminProduct(sell.Product p) {
    return admin_prod.Product(
      id: p.id,
      title: p.title,
      brand: p.brand,
      subtitle: p.subtitle,
      category: _toSlug(p.category.isNotEmpty ? p.category : p.categorySafe),
      description: p.description,
      images: p.images,
      price: p.price,
      moq: p.moq,
      gstRate: p.gstRate,
      materials: p.materials,
      customValues: p.customValues,
      status: _fromSellStatus(p.status),
      createdAt: p.createdAt,
      updatedAt: null,
      rating: p.rating,
      viewCount: 0,
      orderCount: 0,
    );
  }

  ProductStatus _fromSellStatus(sell.ProductStatus s) {
    switch (s) {
      case sell.ProductStatus.active:
        return ProductStatus.active;
      case sell.ProductStatus.inactive:
        return ProductStatus.inactive;
      case sell.ProductStatus.pending:
        return ProductStatus.pending;
      case sell.ProductStatus.draft:
        return ProductStatus.draft;
      case sell.ProductStatus.archived:
        return ProductStatus.archived;
    }
  }

  sell.ProductStatus _toSellStatus(ProductStatus s) {
    switch (s) {
      case ProductStatus.active:
        return sell.ProductStatus.active;
      case ProductStatus.inactive:
        return sell.ProductStatus.inactive;
      case ProductStatus.pending:
        return sell.ProductStatus.pending;
      case ProductStatus.draft:
        return sell.ProductStatus.draft;
      case ProductStatus.archived:
        return sell.ProductStatus.archived;
    }
  }

  String _toSlug(String name) => name
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _fromSlugIfNeeded(String value) {
    if (value.contains(' ')) return value;
    switch (value) {
      case 'wires-cables':
        return 'Cables & Wires';
      case 'circuit-breakers':
        return 'Circuit Breakers';
      case 'lights':
        return 'Lights';
      case 'motors':
        return 'Motors';
      case 'tools':
        return 'Tools';
      default:
        return value.replaceAll('-', ' ');
    }
  }
}

// ================= Supporting Classes =================
enum UploadStatus { pending, approved, rejected }

class ProductUploadItem {
  final String id;
  final String sellerId;
  final String sellerName;
  final List<String> assets;
  final Map<String, dynamic> proposed;
  final DateTime submittedAt;
  final UploadStatus status;
  final DateTime? reviewedAt;
  final String? reviewerNote;

  ProductUploadItem({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.assets,
    required this.proposed,
    required this.submittedAt,
    required this.status,
    this.reviewedAt,
    this.reviewerNote,
  });

  ProductUploadItem copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    List<String>? assets,
    Map<String, dynamic>? proposed,
    DateTime? submittedAt,
    UploadStatus? status,
    DateTime? reviewedAt,
    String? reviewerNote,
  }) {
    return ProductUploadItem(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      assets: assets ?? this.assets,
      proposed: proposed ?? this.proposed,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNote: reviewerNote ?? this.reviewerNote,
    );
  }
}
