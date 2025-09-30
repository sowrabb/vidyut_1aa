import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../admin/store/enhanced_admin_store.dart';
import '../rbac/rbac_service.dart';
import '../../../services/lightweight_demo_data_service.dart';
import '../models/admin_user.dart';

class AdminIdentity {
  final String userId;
  final String name;
  final String email;
  final String role;

  const AdminIdentity({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AdminAuthService extends ChangeNotifier {
  final EnhancedAdminStore _adminStore;
  final LightweightDemoDataService _demoDataService;
  final RbacService _rbacService;

  AdminIdentity? _current;
  bool _initialized = false;

  AdminAuthService(this._adminStore, this._demoDataService, this._rbacService) {
    _hydrate();
    // Listen to RBAC service changes to notify when permissions change
    _rbacService.addListener(_onRbacChanged);
    // Don't await RBAC hydration to avoid blocking initialization
    _rbacService.hydrate().then((_) {
      _initializeDefaultRoles();
    }).catchError((e) {
      debugPrint('RBAC hydration failed: $e');
      _initializeDefaultRoles();
    });
  }

  void _onRbacChanged() {
    // When RBAC changes, notify listeners so permission checks are re-evaluated
    notifyListeners();
  }

  @override
  void dispose() {
    _rbacService.removeListener(_onRbacChanged);
    super.dispose();
  }

  bool get isInitialized => _initialized;
  AdminIdentity? get currentUser => _current;
  bool get isLoggedIn => _current != null;

  Future<void> _hydrate() async {
    try {
      // Check if we're in a test environment or web
      if (kIsWeb || _isTestEnvironment()) {
        // Web or test - use in-memory storage
        _initializeWithDemoUser();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('admin_auth_user');
      if (uid != null) {
        final user = _demoDataService.allUsers.firstWhere(
          (u) => u.id == uid,
          orElse: () => _getDefaultAdminUser(),
        );
        _current = AdminIdentity(
            userId: user.id,
            name: user.name,
            email: user.email,
            role: user.role.name);
      } else {
        _initializeWithDemoUser();
      }
    } catch (e) {
      debugPrint('Auth hydration failed: $e');
      _initializeWithDemoUser();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  void _initializeWithDemoUser() {
    if (_demoDataService.allUsers.isNotEmpty) {
      final user = _demoDataService.allUsers.first;
      _current = AdminIdentity(
          userId: user.id,
          name: user.name,
          email: user.email,
          role: user.role.name);
    } else {
      _current = AdminIdentity(
        userId: 'demo_admin',
        name: 'Demo Admin',
        email: 'admin@vidyut.com',
        role: 'admin',
      );
    }
  }

  AdminUser _getDefaultAdminUser() {
    return AdminUser(
      id: 'U1',
      name: 'Admin',
      email: 'admin@example.com',
      phone: '+91 00000 00000',
      role: UserRole.admin,
      status: UserStatus.active,
      subscription: SubscriptionPlan.free,
      joinDate: DateTime.now().subtract(const Duration(days: 7)),
      lastActive: DateTime.now(),
      location: 'Unknown',
      industry: 'Unknown',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      plan: 'free',
      isSeller: false,
    );
  }

  Future<void> login(AdminUser user) async {
    _current = AdminIdentity(
        userId: user.id,
        name: user.name,
        email: user.email,
        role: user.role.name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_auth_user', user.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _current = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_auth_user');
    notifyListeners();
  }

  bool hasPermission(String permission) {
    final role = _current?.role;
    if (role == null) return false;

    // Prefer explicit user assignment if present
    final assigned = _rbacService.getAssignedRole(_current!.userId) ?? role;
    final override = _rbacService.overrideForUser(_current!.userId);

    // Check RBAC service first
    if (_rbacService.userHas(assigned, permission, override: override))
      return true;

    // Fallback to AdminStore mapping for compatibility
    final map = _adminStore.roleToPermissions;
    final set = map[assigned];
    if (set == null) return false;

    // Check exact permission
    if (set.contains(permission)) return true;

    // Check wildcard permissions (e.g., 'users.*' matches 'users.create')
    final module = permission.split('.').first;
    if (set.contains('$module.*')) return true;

    // Check for more granular permissions
    final parts = permission.split('.');
    if (parts.length > 1) {
      final subModule = parts.take(2).join('.');
      if (set.contains('$subModule.*')) return true;
    }

    return false;
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  /// Get user's effective permissions
  Set<String> getEffectivePermissions() {
    final role = _current?.role;
    if (role == null) return <String>{};

    final assigned = _rbacService.getAssignedRole(_current!.userId) ?? role;
    final map = _adminStore.roleToPermissions;
    return map[assigned] ?? <String>{};
  }

  bool _isTestEnvironment() {
    // Check if we're running in a test environment
    try {
      // This will throw in test environment
      SharedPreferences.getInstance();
      return false;
    } catch (e) {
      return true;
    }
  }

  void _initializeDefaultRoles() {
    // Initialize default roles if RBAC service is empty
    final currentRoles = _rbacService.roleToPermissions;
    if (currentRoles.isEmpty) {
      final defaultRoles = _demoDataService.rolePermissions;
      for (final entry in defaultRoles.entries) {
        _rbacService.createRole(entry.key, permissions: entry.value);
      }
    }
  }
}
