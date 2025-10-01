import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../store/enhanced_admin_store.dart';
import '../models/admin_user.dart';
import '../../../services/enhanced_admin_api_service.dart';
import '../widgets/user_card.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/filter_bar.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';
import '../../sell/hub_shell.dart';

/// Enhanced users management page with full CRUD, pagination, filtering, and bulk operations
class EnhancedUsersManagementPage extends StatefulWidget {
  final EnhancedAdminStore adminStore;

  const EnhancedUsersManagementPage({
    super.key,
    required this.adminStore,
  });

  @override
  State<EnhancedUsersManagementPage> createState() =>
      _EnhancedUsersManagementPageState();
}

class _EnhancedUsersManagementPageState
    extends State<EnhancedUsersManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedRole = '';
  String _selectedStatus = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.adminStore.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    widget.adminStore.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.adminStore.loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.adminStore.refreshUsers(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          FilterBar(
            searchController: _searchController,
            selectedRole: _selectedRole,
            selectedStatus: _selectedStatus,
            sortBy: _sortBy,
            sortOrder: _sortOrder,
            onSearchChanged: (query) => widget.adminStore.setSearchQuery(query),
            onRoleChanged: (role) {
              setState(() => _selectedRole = role);
              widget.adminStore.setRoleFilter(role);
            },
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              widget.adminStore.setStatusFilter(status);
            },
            onSortChanged: (sortBy, sortOrder) {
              setState(() {
                _sortBy = sortBy;
                _sortOrder = sortOrder;
              });
              widget.adminStore.setSorting(sortBy, sortOrder);
            },
          ),

          // Error Banner
          if (widget.adminStore.error != null)
            ErrorBanner(
              message: widget.adminStore.error!,
              onDismiss: () => widget.adminStore.clearError(),
            ),

          // Bulk Actions Bar
          if (widget.adminStore.selectedUserIds.isNotEmpty)
            BulkActionsBar(
              selectedCount: widget.adminStore.selectedUserIds.length,
              totalCount: widget.adminStore.totalCount,
              onSelectAll: () => widget.adminStore.selectAllUsers(),
              onDeselectAll: () => widget.adminStore.deselectAllUsers(),
              onBulkAction: _handleBulkAction,
            ),

          // Users List
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => widget.adminStore.refreshUsers(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.adminStore.users.length +
                        (widget.adminStore.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= widget.adminStore.users.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final user = widget.adminStore.users[index];
                      final isSelected =
                          widget.adminStore.selectedUserIds.contains(user.id);

                      return UserCard(
                        user: user,
                        isSelected: isSelected,
                        onTap: () => _showUserDetails(user),
                        onEdit: () => _showEditUserDialog(user),
                        onDelete: () => _showDeleteUserDialog(user),
                        onImpersonate: user.role.toString().contains('seller')
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SellHubShell(
                                      adminOverride: true,
                                      overrideSellerName: user.name,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        onResetPassword: () =>
                            widget.adminStore.resetUserPassword(user.id),
                        onSetPassword: (newPassword) => widget.adminStore
                            .setUserPassword(user.id, newPassword),
                        onSelect: (selected) {
                          if (selected) {
                            widget.adminStore.selectUser(user.id);
                          } else {
                            widget.adminStore.deselectUser(user.id);
                          }
                        },
                        onStatusChange: (status) =>
                            _updateUserStatus(user, status),
                        onPlanChange: (plan) => _updateUserPlan(user, plan),
                      );
                    },
                  ),
                ),

                // Loading Overlay
                if (widget.adminStore.isLoading) const LoadingOverlay(),
              ],
            ),
          ),

          // Pagination Bar
          PaginationBar(
            currentPage: widget.adminStore.currentPage,
            totalCount: widget.adminStore.totalCount,
            hasMore: widget.adminStore.hasMore,
            onPageChanged: (page) {
              // Handle page change if needed
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportUsers();
        break;
      case 'import':
        _importUsers();
        break;
    }
  }

  void _handleBulkAction(String action) {
    switch (action) {
      case 'activate':
        _bulkUpdateStatus('active');
        break;
      case 'suspend':
        _bulkUpdateStatus('suspended');
        break;
      case 'delete':
        _showBulkDeleteDialog();
        break;
    }
  }

  Future<void> _exportUsers() async {
    try {
      final csv = await widget.adminStore.exportUsersCsv();
      await Clipboard.setData(ClipboardData(text: csv));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Users exported to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importUsers() async {
    try {
      final source = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload CSV'),
                onTap: () => Navigator.pop(context, 'upload'),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Use Sample CSV'),
                subtitle: const Text('Loads the seeded template from assets'),
                onTap: () => Navigator.pop(context, 'sample'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      String? content;
      if (source == 'sample') {
        content =
            await rootBundle.loadString('assets/demo-csv/users_sample.csv');
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['csv'],
          withData: true,
        );
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.first.bytes != null) {
          content = String.fromCharCodes(result.files.first.bytes!);
        }
      }

      if (content == null || content.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No CSV content selected')),
          );
        }
        return;
      }

      final proceed = await _showImportPreviewDialog(content);
      if (proceed != null && proceed) {
        final importResult = await widget.adminStore.importUsersCsv(content);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Import completed: ${importResult.successCount} successful, ${importResult.failureCount} failed'),
              action: importResult.errors.isNotEmpty
                  ? SnackBarAction(
                      label: 'View Errors',
                      onPressed: () =>
                          _showImportErrorsDialog(importResult.errors),
                    )
                  : null,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<bool?> _showImportPreviewDialog(String csvContent) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will import users from the CSV file. Continue?'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Show dry run first
                final dryRunResult = await widget.adminStore
                    .importUsersCsv(csvContent, dryRun: true);

                if (mounted) {
                  Navigator.of(context).pop();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Dry Run Results'),
                      content: Text(
                        'Found ${dryRunResult.successCount} valid users, ${dryRunResult.failureCount} errors.\n\n'
                        'Proceed with import?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
              child: const Text('Preview & Import'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImportErrorsDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Errors'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: errors.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(errors[index]),
              dense: true,
            ),
          ),
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

  Future<void> _bulkUpdateStatus(String status) async {
    try {
      final result = await widget.adminStore.bulkUpdateUserStatus(status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Bulk update completed: ${result.successCount} successful, ${result.failureCount} failed'),
            action: result.errors.isNotEmpty
                ? SnackBarAction(
                    label: 'View Errors',
                    onPressed: () => _showImportErrorsDialog(result.errors),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk update failed: $e')),
        );
      }
    }
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Users'),
        content: Text(
          'Are you sure you want to delete ${widget.adminStore.selectedUserIds.length} users? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Implement bulk delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bulk delete not implemented yet')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Phone', user.phone),
              _buildDetailRow('Role', user.role.toString().split('.').last),
              _buildDetailRow('Status', user.status.toString().split('.').last),
              _buildDetailRow('Plan', user.plan),
              _buildDetailRow('Created', user.createdAt.toString()),
              if (user.sellerProfile != null) ...[
                const Divider(),
                const Text('Seller Profile',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDetailRow(
                    'Company',
                    user.sellerProfile!.companyName.isEmpty
                        ? 'N/A'
                        : user.sellerProfile!.companyName),
                _buildDetailRow(
                    'GST',
                    user.sellerProfile!.gstNumber.isEmpty
                        ? 'N/A'
                        : user.sellerProfile!.gstNumber),
                _buildDetailRow(
                    'Address',
                    user.sellerProfile!.address.isEmpty
                        ? 'N/A'
                        : user.sellerProfile!.address),
                _buildDetailRow(
                    'Materials', user.sellerProfile!.materials.join(', ')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditUserDialog(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        onSave: (request) async {
          try {
            await widget.adminStore.createUser(request);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User created successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create user: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditUserDialog(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onSave: (request) async {
          try {
            await widget.adminStore.updateUser(user.id, request);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update user: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteUserDialog(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await widget.adminStore.deleteUser(user.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete user: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserStatus(AdminUser user, String status) async {
    try {
      await widget.adminStore
          .updateUser(user.id, UpdateUserRequest(status: status));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _updateUserPlan(AdminUser user, String plan) async {
    try {
      await widget.adminStore
          .updateUser(user.id, UpdateUserRequest(plan: plan));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User plan updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update plan: $e')),
        );
      }
    }
  }
}

// ================= Dialog Widgets =================

class CreateUserDialog extends StatefulWidget {
  final Function(CreateUserRequest) onSave;

  const CreateUserDialog({super.key, required this.onSave});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedRole = 'buyer';
  final List<String> _selectedMaterials = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                    DropdownMenuItem(value: 'seller', child: Text('Seller')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                if (_selectedRole == 'seller') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration:
                        const InputDecoration(labelText: 'Company Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final request = CreateUserRequest(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
        companyName: _selectedRole == 'seller' ? _companyController.text : null,
        gstNumber: _selectedRole == 'seller' ? _gstController.text : null,
        address: _selectedRole == 'seller' ? _addressController.text : null,
        materials: _selectedMaterials,
      );

      widget.onSave(request);
    }
  }
}

class EditUserDialog extends StatefulWidget {
  final AdminUser user;
  final Function(UpdateUserRequest) onSave;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _gstController;
  late TextEditingController _addressController;

  late String _selectedRole;
  late String _selectedStatus;
  late String _selectedPlan;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _companyController = TextEditingController(
        text: widget.user.sellerProfile?.companyName ?? '');
    _gstController =
        TextEditingController(text: widget.user.sellerProfile?.gstNumber ?? '');
    _addressController =
        TextEditingController(text: widget.user.sellerProfile?.address ?? '');

    _selectedRole = widget.user.role.toString().split('.').last;
    _selectedStatus = widget.user.status.toString().split('.').last;
    _selectedPlan = widget.user.plan;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.user.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                    DropdownMenuItem(value: 'seller', child: Text('Seller')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(
                        value: 'suspended', child: Text('Suspended')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPlan,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: const [
                    DropdownMenuItem(value: 'free', child: Text('Free')),
                    DropdownMenuItem(value: 'plus', child: Text('Plus')),
                    DropdownMenuItem(value: 'pro', child: Text('Pro')),
                  ],
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                ),
                if (_selectedRole == 'seller') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration:
                        const InputDecoration(labelText: 'Company Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final request = UpdateUserRequest(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
        status: _selectedStatus,
        plan: _selectedPlan,
        companyName: _selectedRole == 'seller' ? _companyController.text : null,
        gstNumber: _selectedRole == 'seller' ? _gstController.text : null,
        address: _selectedRole == 'seller' ? _addressController.text : null,
      );

      widget.onSave(request);
    }
  }
}
