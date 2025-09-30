import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/user_role_models.dart';
import 'session_controller.dart';
import 'session_state.dart';

class RbacState {
  RbacState({required this.role, required Set<String> permissions})
      : _permissions = permissions;

  final UserRole role;
  final Set<String> _permissions;

  bool can(String permission) {
    if (_permissions.contains(permission)) {
      return true;
    }
    // Wildcard support e.g. permissions with *. suffix.
    for (final entry in _permissions) {
      if (entry.endsWith('.*')) {
        final prefix = entry.substring(0, entry.length - 1);
        if (permission.startsWith(prefix)) {
          return true;
        }
      }
    }
    return false;
  }

  Set<String> get permissions => _permissions;
}

final rbacProvider = Provider<RbacState>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final permissions = _rolePermissionMatrix[session.role] ?? const <String>{};
  return RbacState(role: session.role, permissions: permissions);
});

const Map<UserRole, Set<String>> _rolePermissionMatrix = {
  UserRole.admin: {
    'users.read',
    'users.write',
    'sellers.read',
    'sellers.write',
    'admin.access',
    'kyc.review',
    'products.read',
    'products.write',
    'uploads.review',
    'ads.manage',
    'leads.manage',
    'messaging.moderate',
    'cms.manage',
    'billing.manage',
    'search.tune',
    'geo.manage',
    'analytics.view',
    'compliance.manage',
    'system.ops',
    'feature.flags',
    'rbac.manage',
    'audit.read',
    'bulk.ops',
    'notifications.send',
    'export.data',
    'media.manage',
  },
  UserRole.seller: {
    'products.read',
    'products.write',
    'orders.manage',
    'leads.manage',
    'messaging.use',
    'analytics.view',
  },
  UserRole.buyer: {
    'products.read',
    'messaging.use',
    'leads.create',
    'reviews.create',
  },
  UserRole.guest: {
    'products.read',
  },
};
