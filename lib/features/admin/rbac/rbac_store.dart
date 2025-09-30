import 'package:flutter/foundation.dart';
import '../store/admin_store.dart';
import 'rbac_service.dart';
import 'rbac_models.dart';

/// Bridges existing AdminStore RBAC and new RbacService features (overrides, templates).
class RbacStore extends ChangeNotifier {
  final AdminStore adminStore; // existing roles/permissions mapping
  final RbacService service; // v2 capabilities

  bool _initialized = false;
  bool get isInitialized => _initialized;

  RbacStore({required this.adminStore, required this.service});

  Future<void> initialize() async {
    await service.hydrate();
    _initialized = true;
    notifyListeners();
  }

  Map<String, Set<String>> get roleToPermissions {
    // Prefer AdminStore's current mapping for backward compatibility
    return adminStore.roleToPermissions;
  }

  Future<void> createRole(String role,
      {Iterable<String> permissions = const []}) async {
    await adminStore.createRole(role, permissions: permissions);
    notifyListeners();
  }

  Future<void> deleteRole(String role) async {
    await adminStore.deleteRole(role);
    notifyListeners();
  }

  Future<void> grantPermissionToRole(String role, String permission) async {
    await adminStore.grantPermissionToRole(role, permission);
    notifyListeners();
  }

  Future<void> revokePermissionFromRole(String role, String permission) async {
    await adminStore.revokePermissionFromRole(role, permission);
    notifyListeners();
  }

  // Overrides
  UserOverride? overrideForUser(String userId) =>
      service.overrideForUser(userId);
  Future<void> upsertOverride(UserOverride override) =>
      service.upsertOverride(override);
  Future<void> removeOverride(String userId) => service.removeOverride(userId);

  // Assignments
  String? getAssignedRole(String userId) => service.getAssignedRole(userId);
  Future<void> assignRoleToUser(String userId, String role) =>
      service.assignRoleToUser(userId, role);

  Future<void> setCredential(String userId, String username, String password) =>
      service.setCredential(userId, username, password);
  String? getCredential(String userId) => service.getCredential(userId);
}
