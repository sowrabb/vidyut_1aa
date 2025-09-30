import 'permission_catalog.dart';

class RoleTemplates {
  static const Map<String, List<String>> templates = {
    'Marketing Expert': [
      'analytics.view',
      'cms.manage',
      'notifications.send',
      'leads.manage',
    ],
    'Sales Manager': [
      'sellers.read',
      'products.manage',
      'orders.manage',
      'leads.manage',
    ],
    'Support Agent': [
      'users.read',
      'messaging.moderate',
      'audit.read',
    ],
    'Content Manager': [
      'cms.manage',
      'hero.sections',
      'categories.manage',
    ],
    'System Admin': [
      // In practice, this would be all permissions.
      // Keep explicit for demo clarity.
    ],
  };

  static List<String> allTemplateNames() => templates.keys.toList();

  static List<String> permissionsFor(String templateName) {
    if (templateName == 'System Admin') {
      return PermissionCatalog.allPermissions().toList();
    }
    return List<String>.from(templates[templateName] ?? const <String>[]);
  }
}
