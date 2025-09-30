import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rbac_models.dart';

/// Enhanced RBAC service with backend integration and production features
class EnhancedRbacService extends ChangeNotifier {
  final Map<String, Set<String>> _roleToPermissions = <String, Set<String>>{};
  final Map<String, UserOverride> _userOverrides = <String, UserOverride>{};
  final Map<String, String> _userAssignedRole = <String, String>{};
  final Map<String, String> _userCredentials = <String, String>{};
  final List<RoleTemplate> _roleTemplates = [];
  final List<Permission> _availablePermissions = [];
  final List<AuditLog> _auditLogs = [];

  bool _isInitialized = false;
  bool _useBackend = false;

  EnhancedRbacService({bool useBackend = false}) : _useBackend = useBackend {
    _initialize();
  }

  /// Reload roles, permissions, and templates from the configured source
  Future<void> refresh() async {
    _isInitialized = false;
    notifyListeners();
    await _initialize();
  }

  // ================= Getters =================

  bool get isInitialized => _isInitialized;
  Map<String, Set<String>> get roleToPermissions => {
        for (final e in _roleToPermissions.entries)
          e.key: Set<String>.from(e.value)
      };
  Map<String, UserOverride> get allOverrides =>
      Map.unmodifiable(_userOverrides);
  List<RoleTemplate> get roleTemplates => List.unmodifiable(_roleTemplates);
  List<Permission> get availablePermissions =>
      List.unmodifiable(_availablePermissions);
  List<AuditLog> get auditLogs => List.unmodifiable(_auditLogs.reversed);

  // ================= Initialization =================

  Future<void> _initialize() async {
    try {
      if (_useBackend) {
        await _loadFromBackend();
      } else {
        await _loadFromDemoData();
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('RBAC initialization failed: $e');
    }
  }

  Future<void> _loadFromBackend() async {
    // Pending: Implement backend API calls
    // For now, load from demo data
    await _loadFromDemoData();
  }

  Future<void> _loadFromDemoData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load roles
    final roleLines = prefs.getStringList('rbac_roles_v3') ?? const <String>[];
    _roleToPermissions.clear();
    _roleToPermissions.addAll({
      for (final line in roleLines)
        if (line.contains(':'))
          line.split(':')[0]: line.split(':').length > 1 &&
                  line.split(':')[1].isNotEmpty
              ? line.split(':')[1].split(',').where((e) => e.isNotEmpty).toSet()
              : <String>{}
    });

    // Load overrides
    final overrideLines =
        prefs.getStringList('rbac_overrides_v3') ?? const <String>[];
    _userOverrides.clear();
    _userOverrides.addAll({
      for (final s in overrideLines)
        if (s.split('|').length >= 4)
          s.split('|')[0]: UserOverride(
            userId: s.split('|')[0],
            grants: s.split('|')[1].isEmpty
                ? <String>{}
                : s.split('|')[1].split(',').where((e) => e.isNotEmpty).toSet(),
            revokes: s.split('|')[2].isEmpty
                ? <String>{}
                : s.split('|')[2].split(',').where((e) => e.isNotEmpty).toSet(),
            expiresAt: s.split('|')[3].isEmpty
                ? null
                : DateTime.tryParse(s.split('|')[3]),
          )
    });

    // Load assignments
    final assignLines =
        prefs.getStringList('rbac_assignments_v3') ?? const <String>[];
    _userAssignedRole.clear();
    _userAssignedRole.addAll({
      for (final s in assignLines)
        if (s.contains(':')) s.split(':')[0]: s.split(':')[1]
    });

    // Load credentials
    final credLines =
        prefs.getStringList('rbac_credentials_v2') ?? const <String>[];
    _userCredentials.clear();
    _userCredentials.addAll({
      for (final s in credLines)
        if (s.split('|').length >= 3)
          s.split('|')[0]: '${s.split('|')[1]}|${s.split('|')[2]}'
    });

    // Initialize default permissions
    _initializeDefaultPermissions();

    // Initialize default role templates
    _initializeDefaultRoleTemplates();

    notifyListeners();
  }

  void _initializeDefaultPermissions() {
    _availablePermissions.clear();
    _availablePermissions.addAll([
      // User management permissions
      const Permission(
          'users.read', 'Read Users', 'View user information and lists'),
      const Permission(
          'users.write', 'Write Users', 'Create, update, and delete users'),
      const Permission('users.bulk', 'Bulk User Operations',
          'Perform bulk operations on users'),

      // Seller management permissions
      const Permission(
          'sellers.read', 'Read Sellers', 'View seller information'),
      const Permission(
          'sellers.write', 'Write Sellers', 'Manage seller accounts'),
      const Permission(
          'sellers.verify', 'Verify Sellers', 'Approve seller verification'),

      // Product management permissions
      const Permission(
          'products.read', 'Read Products', 'View product information'),
      const Permission(
          'products.write', 'Write Products', 'Create and edit products'),
      const Permission('products.moderate', 'Moderate Products',
          'Review and approve products'),

      // Orders removed (permissions deprecated)

      // Content management permissions
      const Permission('cms.read', 'Read CMS', 'View content management'),
      const Permission('cms.write', 'Write CMS', 'Manage content and pages'),
      const Permission(
          'cms.publish', 'Publish Content', 'Publish and unpublish content'),

      // Analytics permissions
      const Permission(
          'analytics.read', 'Read Analytics', 'View analytics and reports'),
      const Permission(
          'analytics.export', 'Export Analytics', 'Export analytics data'),

      // System permissions
      const Permission('system.read', 'Read System', 'View system information'),
      const Permission(
          'system.write', 'Write System', 'Modify system settings'),
      const Permission(
          'system.admin', 'System Admin', 'Full system administration'),

      // RBAC permissions
      const Permission('rbac.read', 'Read RBAC', 'View roles and permissions'),
      const Permission(
          'rbac.write', 'Write RBAC', 'Manage roles and permissions'),
      const Permission('rbac.assign', 'Assign Roles', 'Assign roles to users'),

      // Audit permissions
      const Permission('audit.read', 'Read Audit Logs', 'View audit logs'),
      const Permission(
          'audit.export', 'Export Audit Logs', 'Export audit logs'),
    ]);
  }

  void _initializeDefaultRoleTemplates() {
    _roleTemplates.clear();
    _roleTemplates.addAll([
      RoleTemplate(
        id: 'template_admin',
        name: 'Administrator',
        description: 'Full system access',
        permissions: _availablePermissions.map((p) => p.id).toSet(),
        isSystem: true,
        version: 1,
      ),
      const RoleTemplate(
        id: 'template_seller',
        name: 'Seller',
        description: 'Seller account management',
        permissions: {
          'products.read',
          'products.write',
          'analytics.read',
        },
        isSystem: true,
        version: 1,
      ),
      const RoleTemplate(
        id: 'template_support',
        name: 'Support Agent',
        description: 'Customer support operations',
        permissions: {
          'users.read',
          'audit.read',
        },
        isSystem: true,
        version: 1,
      ),
      const RoleTemplate(
        id: 'template_moderator',
        name: 'Content Moderator',
        description: 'Content moderation and review',
        permissions: {
          'products.read',
          'products.moderate',
          'cms.read',
          'cms.write',
          'audit.read',
        },
        isSystem: true,
        version: 1,
      ),
    ]);
  }

  // ================= Role Management =================

  Future<void> createRole(String role,
      {Iterable<String> permissions = const []}) async {
    if (_roleToPermissions.containsKey(role)) {
      throw Exception('Role already exists');
    }

    _roleToPermissions[role] = {...permissions};
    await _addAuditLog(
        'rbac', 'Created role "$role" with ${permissions.length} permissions');
    notifyListeners();
    await _persistRoles();
  }

  Future<void> updateRole(String role, {Iterable<String>? permissions}) async {
    if (!_roleToPermissions.containsKey(role)) {
      throw Exception('Role does not exist');
    }

    if (permissions != null) {
      _roleToPermissions[role] = {...permissions};
    }

    await _addAuditLog('rbac', 'Updated role "$role"');
    notifyListeners();
    await _persistRoles();
  }

  Future<void> deleteRole(String role) async {
    if (!_roleToPermissions.containsKey(role)) {
      throw Exception('Role does not exist');
    }

    // Check if role is in use
    final usersWithRole = _userAssignedRole.entries
        .where((entry) => entry.value == role)
        .map((entry) => entry.key)
        .toList();

    if (usersWithRole.isNotEmpty) {
      throw Exception(
          'Cannot delete role: ${usersWithRole.length} users still assigned');
    }

    _roleToPermissions.remove(role);
    await _addAuditLog('rbac', 'Deleted role "$role"');
    notifyListeners();
    await _persistRoles();
  }

  Future<void> grantPermissionToRole(String role, String permission) async {
    if (!_roleToPermissions.containsKey(role)) {
      throw Exception('Role does not exist');
    }

    if (!_availablePermissions.any((p) => p.id == permission)) {
      throw Exception('Permission does not exist');
    }

    final set = _roleToPermissions[role]!;
    if (!set.contains(permission)) {
      set.add(permission);
      await _addAuditLog('rbac', 'Granted "$permission" to role "$role"');
      notifyListeners();
      await _persistRoles();
    }
  }

  Future<void> revokePermissionFromRole(String role, String permission) async {
    if (!_roleToPermissions.containsKey(role)) {
      throw Exception('Role does not exist');
    }

    final set = _roleToPermissions[role]!;
    if (set.remove(permission)) {
      await _addAuditLog('rbac', 'Revoked "$permission" from role "$role"');
      notifyListeners();
      await _persistRoles();
    }
  }

  // ================= User Override Management =================

  UserOverride? overrideForUser(String userId) => _userOverrides[userId];

  Future<void> upsertOverride(UserOverride override) async {
    _userOverrides[override.userId] = override;
    await _addAuditLog('rbac', 'Updated override for user ${override.userId}');
    notifyListeners();
    await _persistOverrides();
  }

  Future<void> removeOverride(String userId) async {
    if (_userOverrides.remove(userId) != null) {
      await _addAuditLog('rbac', 'Removed override for user $userId');
      notifyListeners();
      await _persistOverrides();
    }
  }

  // ================= Role Assignment =================

  String? getAssignedRole(String userId) => _userAssignedRole[userId];

  Future<void> assignRoleToUser(String userId, String role) async {
    if (!_roleToPermissions.containsKey(role)) {
      throw Exception('Role does not exist');
    }

    _userAssignedRole[userId] = role;
    await _addAuditLog('rbac', 'Assigned role "$role" to user $userId');
    notifyListeners();
    await _persistAssignments();
  }

  Future<void> removeRoleFromUser(String userId) async {
    if (_userAssignedRole.remove(userId) != null) {
      await _addAuditLog('rbac', 'Removed role from user $userId');
      notifyListeners();
      await _persistAssignments();
    }
  }

  // ================= Permission Checking =================

  bool userHas(String userId, String permission) {
    final role = _userAssignedRole[userId];
    if (role == null) return false;

    final override = _userOverrides[userId];
    return roleHas(role, permission, override: override);
  }

  bool roleHas(String role, String permission, {UserOverride? override}) {
    final base = _roleToPermissions[role] ?? <String>{};
    final add = override?.isExpired == true
        ? <String>{}
        : (override?.grants ?? <String>{});
    final sub = override?.isExpired == true
        ? <String>{}
        : (override?.revokes ?? <String>{});
    final eff = {...base, ...add}..removeWhere(sub.contains);

    if (eff.contains(permission)) return true;

    // Check for wildcard permissions
    final module = permission.split('.').first;
    return eff.contains('$module.*');
  }

  Set<String> effectivePermissionsForUser(String userId) {
    final role = _userAssignedRole[userId];
    if (role == null) return <String>{};

    final override = _userOverrides[userId];
    return effectivePermissionsForRole(role, override: override);
  }

  Set<String> effectivePermissionsForRole(String role,
      {UserOverride? override}) {
    final base = _roleToPermissions[role] ?? <String>{};
    final add = override?.isExpired == true
        ? <String>{}
        : (override?.grants ?? <String>{});
    final sub = override?.isExpired == true
        ? <String>{}
        : (override?.revokes ?? <String>{});
    return {...base, ...add}..removeWhere(sub.contains);
  }

  // ================= Role Templates =================

  Future<void> createRoleFromTemplate(
      String roleName, String templateId) async {
    final template = _roleTemplates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw Exception('Template not found'),
    );

    await createRole(roleName, permissions: template.permissions);
    await _addAuditLog(
        'rbac', 'Created role "$roleName" from template "$templateId"');
  }

  Future<void> createCustomTemplate(
      String name, String description, Set<String> permissions) async {
    final template = RoleTemplate(
      id: 'template_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      permissions: permissions,
      isSystem: false,
      version: 1,
    );

    _roleTemplates.add(template);
    await _addAuditLog('rbac', 'Created custom template "$name"');
    notifyListeners();
    await _persistTemplates();
  }

  Future<void> deleteRoleTemplate(String templateId) async {
    final before = _roleTemplates.length;
    _roleTemplates.removeWhere((t) => t.id == templateId);
    if (_roleTemplates.length != before) {
      await _addAuditLog('rbac', 'Deleted role template "$templateId"');
      notifyListeners();
      await _persistTemplates();
    }
  }

  // ================= Permission Discovery =================

  List<Permission> getPermissionsByModule(String module) {
    return _availablePermissions
        .where((p) => p.id.startsWith('$module.'))
        .toList();
  }

  List<String> getModules() {
    return _availablePermissions
        .map((p) => p.id.split('.').first)
        .toSet()
        .toList()
      ..sort();
  }

  void addPermission(Permission permission) {
    if (_availablePermissions.any((p) => p.id == permission.id)) {
      return;
    }
    _availablePermissions.add(permission);
    notifyListeners();
  }

  // ================= Audit Logging =================

  Future<void> _addAuditLog(String area, String message) async {
    _auditLogs.add(AuditLog(
      timestamp: DateTime.now(),
      area: area,
      message: message,
    ));

    // Keep only last 1000 logs
    if (_auditLogs.length > 1000) {
      _auditLogs.removeRange(0, _auditLogs.length - 1000);
    }

    await _persistAuditLogs();
  }

  // ================= Persistence =================

  Future<void> _persistRoles() async {
    if (_useBackend) {
      // Pending: Implement backend persistence
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_roles_v3',
      _roleToPermissions.entries
          .map((e) => '${e.key}:${e.value.join(',')}')
          .toList(growable: false),
    );
  }

  Future<void> _persistOverrides() async {
    if (_useBackend) {
      // Pending: Implement backend persistence
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_overrides_v3',
      _userOverrides.values
          .map((o) =>
              '${o.userId}|${o.grants.join(',')}|${o.revokes.join(',')}|${o.expiresAt?.toIso8601String() ?? ''}')
          .toList(growable: false),
    );
  }

  Future<void> _persistAssignments() async {
    if (_useBackend) {
      // Pending: Implement backend persistence
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_assignments_v3',
      _userAssignedRole.entries
          .map((e) => '${e.key}:${e.value}')
          .toList(growable: false),
    );
  }

  Future<void> _persistTemplates() async {
    if (_useBackend) {
      // Pending: Implement backend persistence
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_templates_v1',
      _roleTemplates.map((t) => t.toJsonString()).toList(growable: false),
    );
  }

  Future<void> _persistAuditLogs() async {
    if (_useBackend) {
      // Pending: Implement backend persistence
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_audit_logs_v1',
      _auditLogs
          .map((a) => '${a.timestamp.toIso8601String()}|${a.area}|${a.message}')
          .toList(growable: false),
    );
  }

  // ================= Backend Toggle =================

  Future<void> toggleBackendMode(bool useBackend) async {
    if (_useBackend != useBackend) {
      _useBackend = useBackend;
      _isInitialized = false;
      await _initialize();
    }
  }
}

// ================= Additional Models =================

class Permission {
  final String id;
  final String name;
  final String description;

  const Permission(this.id, this.name, this.description);
}

class RoleTemplate {
  final String id;
  final String name;
  final String description;
  final Set<String> permissions;
  final bool isSystem;
  final int version;

  const RoleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isSystem,
    required this.version,
  });

  String toJsonString() {
    return '$id|$name|$description|${permissions.join(',')}|$isSystem|$version';
  }

  factory RoleTemplate.fromJsonString(String json) {
    final parts = json.split('|');
    return RoleTemplate(
      id: parts[0],
      name: parts[1],
      description: parts[2],
      permissions: parts[3].isEmpty ? <String>{} : parts[3].split(',').toSet(),
      isSystem: parts[4] == 'true',
      version: int.parse(parts[5]),
    );
  }
}

class AuditLog {
  final DateTime timestamp;
  final String area;
  final String message;

  const AuditLog({
    required this.timestamp,
    required this.area,
    required this.message,
  });
}
