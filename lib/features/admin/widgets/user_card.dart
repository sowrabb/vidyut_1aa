import 'package:flutter/material.dart';
import '../models/admin_user.dart';
import '../../auth/models/user_role_models.dart';

/// User card widget with selection, actions, and status management
class UserCard extends StatelessWidget {
  final AdminUser user;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(bool)? onSelect;
  final Function(String)? onStatusChange;
  final Function(String)? onPlanChange;
  final VoidCallback? onImpersonate;
  final Future<void> Function()? onResetPassword; // legacy reset link/email
  final Future<void> Function(String)? onSetPassword; // direct set password

  const UserCard({
    super.key,
    required this.user,
    required this.isSelected,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSelect,
    this.onStatusChange,
    this.onPlanChange,
    this.onImpersonate,
    this.onResetPassword,
    this.onSetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox
              if (onSelect != null)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelect!(value ?? false),
                ),

              // User avatar
              CircleAvatar(
                backgroundColor: _getRoleColor(user.role),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildStatusChip(user.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRoleChip(user.role),
                        const SizedBox(width: 8),
                        _buildPlanChip(user.plan),
                        if (user.isSeller) ...[
                          const SizedBox(width: 8),
                          const Chip(
                            label: Text('Seller'),
                            backgroundColor: Colors.green,
                            labelStyle:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    if (user.sellerProfile != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.sellerProfile!.companyName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              PopupMenuButton<String>(
                onSelected: (action) => _handleAction(context, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (user.role == UserRole.seller)
                    const PopupMenuItem(
                      value: 'impersonate',
                      child: ListTile(
                        leading: Icon(Icons.person_search),
                        title: Text('Impersonate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'status',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Change Status'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'plan',
                    child: ListTile(
                      leading: Icon(Icons.upgrade),
                      title: Text('Change Plan'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset_password',
                    child: ListTile(
                      leading: Icon(Icons.lock_reset),
                      title: Text('Reset Password'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(UserStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String label;

    switch (status) {
      case UserStatus.active:
        backgroundColor = Colors.green;
        label = 'Active';
        break;
      case UserStatus.inactive:
        backgroundColor = Colors.grey;
        label = 'Inactive';
        break;
      case UserStatus.suspended:
        backgroundColor = Colors.red;
        label = 'Suspended';
        break;
      case UserStatus.pending:
        backgroundColor = Colors.orange;
        label = 'Pending';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildRoleChip(UserRole role) {
    Color backgroundColor;
    String label;

    switch (role) {
      case UserRole.admin:
        backgroundColor = Colors.purple;
        label = 'Admin';
        break;
      case UserRole.seller:
        backgroundColor = Colors.blue;
        label = 'Seller';
        break;
      case UserRole.buyer:
        backgroundColor = Colors.teal;
        label = 'Buyer';
        break;
      case UserRole.guest:
        backgroundColor = Colors.grey;
        label = 'Guest';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildPlanChip(String plan) {
    Color backgroundColor;
    String label;

    switch (plan.toLowerCase()) {
      case 'free':
        backgroundColor = Colors.grey;
        label = 'Free';
        break;
      case 'plus':
        backgroundColor = Colors.blue;
        label = 'Plus';
        break;
      case 'pro':
        backgroundColor = Colors.purple;
        label = 'Pro';
        break;
      default:
        backgroundColor = Colors.grey;
        label = plan;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.seller:
        return Colors.blue;
      case UserRole.buyer:
        return Colors.teal;
      case UserRole.guest:
        return Colors.grey;
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'impersonate':
        onImpersonate?.call();
        break;
      case 'status':
        _showStatusDialog(context);
        break;
      case 'plan':
        _showPlanDialog(context);
        break;
      case 'reset_password':
        _showResetPasswordDialog(context);
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(context, 'active', 'Active', Colors.green),
            _buildStatusOption(context, 'inactive', 'Inactive', Colors.grey),
            _buildStatusOption(context, 'suspended', 'Suspended', Colors.red),
            _buildStatusOption(context, 'pending', 'Pending', Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
      BuildContext context, String value, String label, Color color) {
    return ListTile(
      leading: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        onStatusChange?.call(value);
      },
    );
  }

  void _showPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlanOption(context, 'free', 'Free', Colors.grey),
            _buildPlanOption(context, 'plus', 'Plus', Colors.blue),
            _buildPlanOption(context, 'pro', 'Pro', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
      BuildContext context, String value, String label, Color color) {
    return ListTile(
      leading: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        onPlanChange?.call(value);
      },
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set New Password'),
        content: SizedBox(
          width: 380,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPwController,
                  decoration: const InputDecoration(labelText: 'New password'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Minimum 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPwController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  validator: (v) {
                    if (v != newPwController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(context).pop();
              if (onSetPassword != null) {
                try {
                  await onSetPassword!(newPwController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              } else if (onResetPassword != null) {
                try {
                  // Overload: if provided, treat as set-password handler externally
                  await onResetPassword!();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset initiated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
