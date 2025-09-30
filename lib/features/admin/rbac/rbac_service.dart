import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rbac_models.dart';

/// In-memory RBAC service with persistence to SharedPreferences (demo).
class RbacService extends ChangeNotifier {
  final Map<String, Set<String>> _roleToPermissions = <String, Set<String>>{};
  final Map<String, UserOverride> _userOverrides = <String, UserOverride>{};
  final Map<String, String> _userAssignedRole = <String, String>{};
  final Map<String, String> _userCredentials =
      <String, String>{}; // userId => username|password (demo only)

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    // Roles
    final roleLines = prefs.getStringList('rbac_roles_v2') ?? const <String>[];
    _roleToPermissions
      ..clear()
      ..addAll({
        for (final line in roleLines)
          if (line.contains(':'))
            line.split(':')[0]:
                line.split(':').length > 1 && line.split(':')[1].isNotEmpty
                    ? line
                        .split(':')[1]
                        .split(',')
                        .where((e) => e.isNotEmpty)
                        .toSet()
                    : <String>{}
      });
    // Overrides
    final overrideLines =
        prefs.getStringList('rbac_overrides_v2') ?? const <String>[];
    _userOverrides
      ..clear()
      ..addAll({
        for (final s in overrideLines)
          if (s.split('|').length >= 4)
            s.split('|')[0]: UserOverride(
              userId: s.split('|')[0],
              grants: s.split('|')[1].isEmpty
                  ? <String>{}
                  : s
                      .split('|')[1]
                      .split(',')
                      .where((e) => e.isNotEmpty)
                      .toSet(),
              revokes: s.split('|')[2].isEmpty
                  ? <String>{}
                  : s
                      .split('|')[2]
                      .split(',')
                      .where((e) => e.isNotEmpty)
                      .toSet(),
              expiresAt: s.split('|')[3].isEmpty
                  ? null
                  : DateTime.tryParse(s.split('|')[3]),
            )
      });
    notifyListeners();

    // Assignments
    final assignLines =
        prefs.getStringList('rbac_assignments_v2') ?? const <String>[];
    _userAssignedRole
      ..clear()
      ..addAll({
        for (final s in assignLines)
          if (s.contains(':')) s.split(':')[0]: s.split(':')[1]
      });
    notifyListeners();

    // Credentials (demo)
    final credLines =
        prefs.getStringList('rbac_credentials_v1') ?? const <String>[];
    _userCredentials
      ..clear()
      ..addAll({
        for (final s in credLines)
          if (s.split('|').length >= 3)
            s.split('|')[0]: '${s.split('|')[1]}|${s.split('|')[2]}'
      });
    notifyListeners();
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rbac_roles_v2',
      _roleToPermissions.entries
          .map((e) => '${e.key}:${e.value.join(',')}')
          .toList(growable: false),
    );
    await prefs.setStringList(
      'rbac_overrides_v2',
      _userOverrides.values
          .map((o) =>
              '${o.userId}|${o.grants.join(',')}|${o.revokes.join(',')}|${o.expiresAt?.toIso8601String() ?? ''}')
          .toList(growable: false),
    );
    await prefs.setStringList(
      'rbac_assignments_v2',
      _userAssignedRole.entries
          .map((e) => '${e.key}:${e.value}')
          .toList(growable: false),
    );
    await prefs.setStringList(
      'rbac_credentials_v1',
      _userCredentials.entries
          .map((e) => '${e.key}|${e.value}')
          .toList(growable: false),
    );
  }

  Map<String, Set<String>> get roleToPermissions => {
        for (final e in _roleToPermissions.entries)
          e.key: Set<String>.from(e.value)
      };

  Set<String> effectivePermissionsForRole(String role,
      {List<String> inherited = const <String>[]}) {
    final own = _roleToPermissions[role] ?? <String>{};
    final inheritedPerms = inherited.fold<Set<String>>(<String>{}, (acc, r) {
      acc.addAll(_roleToPermissions[r] ?? <String>{});
      return acc;
    });
    return {...own, ...inheritedPerms};
  }

  Future<void> createRole(String role,
      {Iterable<String> permissions = const []}) async {
    if (_roleToPermissions.containsKey(role)) return;
    _roleToPermissions[role] = {...permissions};
    notifyListeners();
    await persist();
  }

  Future<void> deleteRole(String role) async {
    _roleToPermissions.remove(role);
    notifyListeners();
    await persist();
  }

  Future<void> grantPermissionToRole(String role, String permission) async {
    final set = _roleToPermissions.putIfAbsent(role, () => <String>{});
    if (!set.contains(permission)) {
      set.add(permission);
      notifyListeners();
      await persist();
    }
  }

  Future<void> revokePermissionFromRole(String role, String permission) async {
    final set = _roleToPermissions[role];
    if (set != null && set.remove(permission)) {
      notifyListeners();
      await persist();
    }
  }

  UserOverride? overrideForUser(String userId) => _userOverrides[userId];
  Map<String, UserOverride> get allOverrides =>
      Map.unmodifiable(_userOverrides);

  Future<void> upsertOverride(UserOverride override) async {
    _userOverrides[override.userId] = override;
    notifyListeners();
    await persist();
  }

  Future<void> removeOverride(String userId) async {
    _userOverrides.remove(userId);
    notifyListeners();
    await persist();
  }

  // Role assignments
  String? getAssignedRole(String userId) => _userAssignedRole[userId];
  Future<void> assignRoleToUser(String userId, String role) async {
    _userAssignedRole[userId] = role;
    notifyListeners();
    await persist();
  }

  // Credentials (demo)
  Future<void> setCredential(
      String userId, String username, String password) async {
    _userCredentials[userId] = '$username|$password';
    notifyListeners();
    await persist();
  }

  String? getCredential(String userId) => _userCredentials[userId];

  bool userHas(String role, String permission, {UserOverride? override}) {
    final base = _roleToPermissions[role] ?? <String>{};
    final add = override?.isExpired == true
        ? <String>{}
        : (override?.grants ?? <String>{});
    final sub = override?.isExpired == true
        ? <String>{}
        : (override?.revokes ?? <String>{});
    final eff = {...base, ...add}..removeWhere(sub.contains);
    if (eff.contains(permission)) return true;
    final module = permission.split('.').first;
    return eff.contains('$module.*');
  }
}
