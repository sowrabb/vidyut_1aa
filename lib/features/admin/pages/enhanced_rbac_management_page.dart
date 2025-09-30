import 'package:flutter/material.dart';
import '../rbac/enhanced_rbac_service.dart';
import '../rbac/rbac_models.dart';
import '../widgets/permission_grid.dart';
import '../widgets/role_card.dart';

/// Enhanced RBAC management page with comprehensive role and permission management
class EnhancedRbacManagementPage extends StatefulWidget {
  final EnhancedRbacService rbacService;

  const EnhancedRbacManagementPage({
    super.key,
    required this.rbacService,
  });

  @override
  State<EnhancedRbacManagementPage> createState() =>
      _EnhancedRbacManagementPageState();
}

class _EnhancedRbacManagementPageState extends State<EnhancedRbacManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedModule = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    widget.rbacService.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.rbacService.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RBAC Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'Roles'),
            Tab(icon: Icon(Icons.security), text: 'Permissions'),
            Tab(icon: Icon(Icons.person_add), text: 'User Overrides'),
            Tab(icon: Icon(Icons.view_module), text: 'Templates'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.rbacService.refresh(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRolesTab(),
          _buildPermissionsTab(),
          _buildUserOverridesTab(),
          _buildTemplatesTab(),
        ],
      ),
    );
  }

  Widget _buildRolesTab() {
    return Column(
      children: [
        // Role management header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search roles...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showCreateRoleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Role'),
              ),
            ],
          ),
        ),

        // Roles list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.rbacService.roleToPermissions.length,
            itemBuilder: (context, index) {
              final role =
                  widget.rbacService.roleToPermissions.keys.elementAt(index);
              final permissions = widget.rbacService.roleToPermissions[role]!;

              if (_searchQuery.isNotEmpty &&
                  !role.toLowerCase().contains(_searchQuery.toLowerCase())) {
                return const SizedBox.shrink();
              }

              return RoleCard(
                roleName: role,
                permissions: permissions,
                onEdit: () => _showEditRoleDialog(role),
                onDelete: () => _showDeleteRoleDialog(role),
                onManagePermissions: () => _showManagePermissionsDialog(role),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab() {
    return Column(
      children: [
        // Module filter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedModule.isEmpty ? null : _selectedModule,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Module',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: '', child: Text('All Modules')),
                    ...widget.rbacService.getModules().map(
                          (module) => DropdownMenuItem(
                              value: module, child: Text(module)),
                        ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedModule = value ?? ''),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showCreatePermissionDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Permission'),
              ),
            ],
          ),
        ),

        // Permissions grid
        Expanded(
          child: PermissionGrid(
            permissions: _selectedModule.isEmpty
                ? widget.rbacService.availablePermissions
                : widget.rbacService.getPermissionsByModule(_selectedModule),
            onPermissionTap: (permission) => _showPermissionDetails(permission),
          ),
        ),
      ],
    );
  }

  Widget _buildUserOverridesTab() {
    return Column(
      children: [
        // User overrides header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'User-specific permission overrides allow temporary or permanent modifications to user permissions.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showCreateOverrideDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Override'),
              ),
            ],
          ),
        ),

        // User overrides list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.rbacService.allOverrides.length,
            itemBuilder: (context, index) {
              final entry =
                  widget.rbacService.allOverrides.entries.elementAt(index);
              final userId = entry.key;
              final override = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        override.isExpired ? Colors.red : Colors.green,
                    child: Text(userId.substring(0, 1).toUpperCase()),
                  ),
                  title: Text('User $userId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (override.grants.isNotEmpty)
                        Text('Grants: ${override.grants.join(', ')}'),
                      if (override.revokes.isNotEmpty)
                        Text('Revokes: ${override.revokes.join(', ')}'),
                      if (override.expiresAt != null)
                        Text('Expires: ${override.expiresAt!.toString()}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleOverrideAction(action, userId),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        // Templates header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Role templates provide predefined permission sets for common roles.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showCreateTemplateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Template'),
              ),
            ],
          ),
        ),

        // Templates list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.rbacService.roleTemplates.length,
            itemBuilder: (context, index) {
              final template = widget.rbacService.roleTemplates[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        template.isSystem ? Colors.blue : Colors.green,
                    child: Icon(template.isSystem ? Icons.build : Icons.person),
                  ),
                  title: Text(template.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.description),
                      const SizedBox(height: 4),
                      Text(
                        '${template.permissions.length} permissions • Version ${template.version}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleTemplateAction(action, template),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'use',
                        child: ListTile(
                          leading: Icon(Icons.add),
                          title: Text('Create Role'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!template.isSystem) ...[
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= Dialog Methods =================

  void _showCreateRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateRoleDialog(
        rbacService: widget.rbacService,
        onRoleCreated: () => setState(() {}),
      ),
    );
  }

  void _showEditRoleDialog(String roleName) {
    showDialog(
      context: context,
      builder: (context) => EditRoleDialog(
        rbacService: widget.rbacService,
        roleName: roleName,
        onRoleUpdated: () => setState(() {}),
      ),
    );
  }

  void _showDeleteRoleDialog(String roleName) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text(
            'Are you sure you want to delete the role "$roleName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              try {
                await widget.rbacService.deleteRole(roleName);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Role "$roleName" deleted successfully'),
                  ),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete role: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showManagePermissionsDialog(String roleName) {
    showDialog(
      context: context,
      builder: (context) => ManagePermissionsDialog(
        rbacService: widget.rbacService,
        roleName: roleName,
        onPermissionsUpdated: () => setState(() {}),
      ),
    );
  }

  void _showCreatePermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePermissionDialog(
        rbacService: widget.rbacService,
        onPermissionCreated: () => setState(() {}),
      ),
    );
  }

  void _showPermissionDetails(Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(permission.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${permission.id}'),
            const SizedBox(height: 8),
            Text(permission.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateOverrideDialog() {
    showDialog(
      context: context,
      builder: (context) => UserOverrideDialog(
        rbacService: widget.rbacService,
        onOverrideCreated: () => setState(() {}),
      ),
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => RoleTemplateDialog(
        rbacService: widget.rbacService,
        onTemplateCreated: () => setState(() {}),
      ),
    );
  }

  void _handleOverrideAction(String action, String userId) {
    switch (action) {
      case 'edit':
        // Pending: Implement edit override
        break;
      case 'delete':
        _showDeleteOverrideDialog(userId);
        break;
    }
  }

  void _showDeleteOverrideDialog(String userId) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Override'),
        content: Text(
            'Are you sure you want to delete the override for user $userId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              try {
                await widget.rbacService.removeOverride(userId);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Override deleted successfully'),
                  ),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete override: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleTemplateAction(String action, RoleTemplate template) {
    switch (action) {
      case 'use':
        _showCreateRoleFromTemplateDialog(template);
        break;
      case 'edit':
        // Pending: Implement edit template
        break;
      case 'delete':
        _showDeleteTemplateDialog(template);
        break;
    }
  }

  void _showCreateRoleFromTemplateDialog(RoleTemplate template) {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Role from Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Creating role from template: ${template.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Role Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              try {
                await widget.rbacService
                    .createRoleFromTemplate(controller.text, template.id);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content:
                        Text('Role "${controller.text}" created successfully'),
                  ),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to create role: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTemplateDialog(RoleTemplate template) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
            'Are you sure you want to delete the template "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              try {
                await widget.rbacService.deleteRoleTemplate(template.id);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Template deleted successfully')),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete template: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ================= Dialog Widgets =================

class CreateRoleDialog extends StatefulWidget {
  final EnhancedRbacService rbacService;
  final VoidCallback onRoleCreated;

  const CreateRoleDialog({
    super.key,
    required this.rbacService,
    required this.onRoleCreated,
  });

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<String> _selectedPermissions = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Role'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Role name is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Select Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.rbacService.availablePermissions.length,
                  itemBuilder: (context, index) {
                    final permission =
                        widget.rbacService.availablePermissions[index];
                    return CheckboxListTile(
                      title: Text(permission.name),
                      subtitle: Text(permission.id),
                      value: _selectedPermissions.contains(permission.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedPermissions.add(permission.id);
                          } else {
                            _selectedPermissions.remove(permission.id);
                          }
                        });
                      },
                    );
                  },
                ),
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
          onPressed: _createRole,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createRole() {
    if (_formKey.currentState!.validate()) {
      widget.rbacService
          .createRole(_nameController.text, permissions: _selectedPermissions);
      widget.onRoleCreated();
      Navigator.of(context).pop();
    }
  }
}

class EditRoleDialog extends StatefulWidget {
  final EnhancedRbacService rbacService;
  final String roleName;
  final VoidCallback onRoleUpdated;

  const EditRoleDialog({
    super.key,
    required this.rbacService,
    required this.roleName,
    required this.onRoleUpdated,
  });

  @override
  State<EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<EditRoleDialog> {
  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    _selectedPermissions
        .addAll(widget.rbacService.roleToPermissions[widget.roleName] ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Role: ${widget.roleName}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            const Text('Select Permissions:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.rbacService.availablePermissions.length,
                itemBuilder: (context, index) {
                  final permission =
                      widget.rbacService.availablePermissions[index];
                  return CheckboxListTile(
                    title: Text(permission.name),
                    subtitle: Text(permission.id),
                    value: _selectedPermissions.contains(permission.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPermissions.add(permission.id);
                        } else {
                          _selectedPermissions.remove(permission.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateRole,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateRole() {
    widget.rbacService
        .updateRole(widget.roleName, permissions: _selectedPermissions);
    widget.onRoleUpdated();
    Navigator.of(context).pop();
  }
}

class ManagePermissionsDialog extends StatelessWidget {
  final EnhancedRbacService rbacService;
  final String roleName;
  final VoidCallback onPermissionsUpdated;

  const ManagePermissionsDialog({
    super.key,
    required this.rbacService,
    required this.roleName,
    required this.onPermissionsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Permissions: $roleName'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: PermissionGrid(
          permissions: rbacService.availablePermissions,
          selectedPermissions: rbacService.roleToPermissions[roleName] ?? {},
          onPermissionToggle: (permissionId, isSelected) async {
            if (isSelected) {
              await rbacService.grantPermissionToRole(roleName, permissionId);
            } else {
              await rbacService.revokePermissionFromRole(
                  roleName, permissionId);
            }
            onPermissionsUpdated();
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class CreatePermissionDialog extends StatefulWidget {
  final EnhancedRbacService rbacService;
  final VoidCallback onPermissionCreated;

  const CreatePermissionDialog({
    super.key,
    required this.rbacService,
    required this.onPermissionCreated,
  });

  @override
  State<CreatePermissionDialog> createState() => _CreatePermissionDialogState();
}

class _CreatePermissionDialogState extends State<CreatePermissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Permission'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Permission ID (e.g., users.read)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Permission ID is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Permission Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Permission name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'Description is required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createPermission,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createPermission() {
    if (_formKey.currentState!.validate()) {
      final permission = Permission(
        _idController.text,
        _nameController.text,
        _descriptionController.text,
      );

      widget.rbacService.addPermission(permission);
      widget.onPermissionCreated();
      Navigator.of(context).pop();
    }
  }
}

class UserOverrideDialog extends StatefulWidget {
  final EnhancedRbacService rbacService;
  final VoidCallback onOverrideCreated;

  const UserOverrideDialog({
    super.key,
    required this.rbacService,
    required this.onOverrideCreated,
  });

  @override
  State<UserOverrideDialog> createState() => _UserOverrideDialogState();
}

class _UserOverrideDialogState extends State<UserOverrideDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final Set<String> _grantPermissions = {};
  final Set<String> _revokePermissions = {};
  DateTime? _expiryDate;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User Override'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'User ID is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Grant Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.rbacService.availablePermissions.length,
                  itemBuilder: (context, index) {
                    final permission =
                        widget.rbacService.availablePermissions[index];
                    return CheckboxListTile(
                      title: Text(permission.name),
                      subtitle: Text(permission.id),
                      value: _grantPermissions.contains(permission.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _grantPermissions.add(permission.id);
                            _revokePermissions.remove(permission.id);
                          } else {
                            _grantPermissions.remove(permission.id);
                          }
                        });
                      },
                    );
                  },
                ),
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
          onPressed: _createOverride,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createOverride() {
    if (_formKey.currentState!.validate()) {
      final override = UserOverride(
        userId: _userIdController.text,
        grants: _grantPermissions,
        revokes: _revokePermissions,
        expiresAt: _expiryDate,
      );

      widget.rbacService.upsertOverride(override);
      widget.onOverrideCreated();
      Navigator.of(context).pop();
    }
  }
}

class RoleTemplateDialog extends StatefulWidget {
  final EnhancedRbacService rbacService;
  final VoidCallback onTemplateCreated;

  const RoleTemplateDialog({
    super.key,
    required this.rbacService,
    required this.onTemplateCreated,
  });

  @override
  State<RoleTemplateDialog> createState() => _RoleTemplateDialogState();
}

class _RoleTemplateDialogState extends State<RoleTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedPermissions = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Role Template'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Template name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Select Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.rbacService.availablePermissions.length,
                  itemBuilder: (context, index) {
                    final permission =
                        widget.rbacService.availablePermissions[index];
                    return CheckboxListTile(
                      title: Text(permission.name),
                      subtitle: Text(permission.id),
                      value: _selectedPermissions.contains(permission.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedPermissions.add(permission.id);
                          } else {
                            _selectedPermissions.remove(permission.id);
                          }
                        });
                      },
                    );
                  },
                ),
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
          onPressed: _createTemplate,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createTemplate() {
    if (_formKey.currentState!.validate()) {
      widget.rbacService.createCustomTemplate(
        _nameController.text,
        _descriptionController.text,
        _selectedPermissions,
      );
      widget.onTemplateCreated();
      Navigator.of(context).pop();
    }
  }
}
