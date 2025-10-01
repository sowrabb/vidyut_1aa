/// Modern users management page using repository-backed providers
/// Replaces enhanced_users_management_page.dart with cleaner architecture.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../../state/session/rbac.dart';
import '../models/admin_user.dart';
import '../../auth/models/user_role_models.dart';

class UsersManagementPageV2 extends ConsumerStatefulWidget {
  const UsersManagementPageV2({super.key});

  @override
  ConsumerState<UsersManagementPageV2> createState() =>
      _UsersManagementPageV2State();
}

class _UsersManagementPageV2State extends ConsumerState<UsersManagementPageV2> {
  String _searchQuery = '';
  UserRole? _roleFilter;
  UserStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(firebaseAllUsersProvider);
    final rbac = ref.watch(rbacProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(firebaseAllUsersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUsersList(users, rbac),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(firebaseAllUsersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<UserRole?>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _roleFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Roles')),
                ...UserRole.values.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.name),
                    )),
              ],
              onChanged: (value) => setState(() => _roleFilter = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<UserStatus?>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _statusFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...UserStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    )),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<AdminUser> users, RbacState rbac) {
    // Apply filters
    var filteredUsers = users.where((user) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.name.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !user.phone.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_roleFilter != null && user.role != _roleFilter) {
        return false;
      }
      if (_statusFilter != null && user.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user, rbac);
      },
    );
  }

  Widget _buildUserCard(AdminUser user, RbacState rbac) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(user.phone),
            Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
                _buildStatusBadge(user.status),
              ],
            ),
          ],
        ),
        trailing: rbac.can('users.write')
            ? PopupMenuButton<String>(
                onSelected: (action) => _handleUserAction(action, user),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (user.status == UserStatus.active)
                    const PopupMenuItem(
                      value: 'suspend',
                      child: ListTile(
                        leading: Icon(Icons.block),
                        title: Text('Suspend'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.check_circle),
                        title: Text('Activate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.admin:
        color = Colors.red;
        break;
      case UserRole.seller:
        color = Colors.blue;
        break;
      case UserRole.buyer:
        color = Colors.green;
        break;
      case UserRole.guest:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    Color color;
    switch (status) {
      case UserStatus.active:
        color = Colors.green;
        break;
      case UserStatus.pending:
        color = Colors.orange;
        break;
      case UserStatus.suspended:
        color = Colors.red;
        break;
      case UserStatus.inactive:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleUserAction(String action, AdminUser user) async {
    final firestore = ref.read(firebaseFirestoreProvider);

    switch (action) {
      case 'edit':
        // TODO: Navigate to edit dialog/page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon')),
        );
        break;

      case 'suspend':
        final confirmed = await _showConfirmDialog(
          'Suspend User',
          'Are you sure you want to suspend ${user.name}?',
        );
        if (confirmed) {
          try {
            await firestore.collection('users').doc(user.id).update({
              'status': UserStatus.suspended.value,
            });
            ref.invalidate(firebaseAllUsersProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User suspended')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
        break;

      case 'activate':
        try {
          await firestore.collection('users').doc(user.id).update({
            'status': UserStatus.active.value,
          });
          ref.invalidate(firebaseAllUsersProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User activated')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          'Delete User',
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
        );
        if (confirmed) {
          try {
            // Soft delete by setting status to inactive
            await firestore.collection('users').doc(user.id).update({
              'status': UserStatus.inactive.value,
            });
            ref.invalidate(firebaseAllUsersProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
        break;
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
