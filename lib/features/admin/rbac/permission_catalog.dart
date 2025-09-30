import 'package:flutter/foundation.dart';

@immutable
class PermissionCategory {
  final String key;
  final String title;
  final List<String> permissions;

  const PermissionCategory({
    required this.key,
    required this.title,
    required this.permissions,
  });
}

class PermissionCatalog {
  static const List<PermissionCategory> categories = [
    PermissionCategory(
      key: 'analytics',
      title: 'Dashboard & Analytics',
      permissions: [
        'analytics.view',
        'analytics.export',
        'dashboard.overview',
      ],
    ),
    PermissionCategory(
      key: 'users',
      title: 'User Management',
      permissions: [
        'users.read',
        'users.write',
        'users.create',
        'users.delete',
      ],
    ),
    PermissionCategory(
      key: 'cms',
      title: 'Content Management',
      permissions: [
        'cms.manage',
        'hero.sections',
        'categories.manage',
        'notifications.send',
      ],
    ),
    PermissionCategory(
      key: 'seller_ops',
      title: 'Seller Operations',
      permissions: [
        'sellers.read',
        'sellers.write',
        'products.manage',
        'leads.manage',
        'orders.manage',
      ],
    ),
    PermissionCategory(
      key: 'system',
      title: 'System Operations',
      permissions: [
        'system.ops',
        'feature.flags',
        'audit.read',
        'bulk.ops',
        'export.data',
      ],
    ),
    PermissionCategory(
      key: 'rbac',
      title: 'RBAC Management',
      permissions: [
        'rbac.manage',
        'roles.create',
        'roles.assign',
        'permissions.override',
      ],
    ),
  ];

  static Set<String> allPermissions() {
    return categories.fold<Set<String>>(<String>{}, (acc, c) {
      acc.addAll(c.permissions);
      return acc;
    });
  }
}
