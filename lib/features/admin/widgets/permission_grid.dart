import 'package:flutter/material.dart';
import '../rbac/enhanced_rbac_service.dart';

/// Permission grid widget for displaying and managing permissions
class PermissionGrid extends StatelessWidget {
  final List<Permission> permissions;
  final Set<String> selectedPermissions;
  final Function(String, bool)? onPermissionToggle;
  final Function(Permission)? onPermissionTap;

  const PermissionGrid({
    super.key,
    required this.permissions,
    this.selectedPermissions = const {},
    this.onPermissionToggle,
    this.onPermissionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: permissions.length,
      itemBuilder: (context, index) {
        final permission = permissions[index];
        final isSelected = selectedPermissions.contains(permission.id);

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          child: InkWell(
            onTap: () {
              if (onPermissionTap != null) {
                onPermissionTap!(permission);
              } else if (onPermissionToggle != null) {
                onPermissionToggle!(permission.id, !isSelected);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          permission.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ),
                      if (onPermissionToggle != null)
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) => onPermissionToggle!(
                              permission.id, value ?? false),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permission.id,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      permission.description,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
