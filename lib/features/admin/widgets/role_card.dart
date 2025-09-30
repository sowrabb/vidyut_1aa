import 'package:flutter/material.dart';

/// Role card widget for displaying role information and actions
class RoleCard extends StatelessWidget {
  final String roleName;
  final Set<String> permissions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onManagePermissions;

  const RoleCard({
    super.key,
    required this.roleName,
    required this.permissions,
    this.onEdit,
    this.onDelete,
    this.onManagePermissions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(roleName),
                  child: Text(
                    roleName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${permissions.length} permissions',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleAction(context, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'permissions',
                      child: ListTile(
                        leading: Icon(Icons.security),
                        title: Text('Manage Permissions'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Role'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Role',
                            style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: permissions.take(5).map((permission) {
                return Chip(
                  label: Text(
                    permission,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.grey[200],
                );
              }).toList()
                ..addAll(permissions.length > 5
                    ? [
                        Chip(
                          label: Text(
                            '+${permissions.length - 5} more',
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                      ]
                    : []),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'seller':
        return Colors.blue;
      case 'buyer':
        return Colors.teal;
      case 'support':
        return Colors.orange;
      case 'moderator':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'permissions':
        onManagePermissions?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
