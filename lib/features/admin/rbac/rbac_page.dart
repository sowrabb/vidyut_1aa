import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
// admin_store imported via providers
import '../models/admin_user.dart';
// removed rbac_store import
// rbac_service imported via providers
import 'permission_catalog.dart';
import 'role_templates.dart';
import 'rbac_models.dart';

class RbacTabbedPage extends ConsumerStatefulWidget {
  const RbacTabbedPage({super.key});
  @override
  ConsumerState<RbacTabbedPage> createState() => _RbacTabbedPageState();
}

class _RbacTabbedPageState extends ConsumerState<RbacTabbedPage>
    with TickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Touch providers to ensure they are instantiated
    ref.watch(rbacServiceProvider);
    ref.watch(adminStoreProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Access Control (RBAC)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
        const Divider(height: 1),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Roles'),
            Tab(text: 'Users'),
            Tab(text: 'Overrides'),
            Tab(text: 'Overview'),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              _RolesTab(),
              _UsersTab(),
              _OverridesTab(),
              _OverviewTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _RolesTab extends ConsumerStatefulWidget {
  const _RolesTab();
  @override
  ConsumerState<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends ConsumerState<_RolesTab> {
  String newRole = '';
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    final rbac = ref.watch(rbacServiceProvider);
    final roles = rbac.roleToPermissions.keys.toList()..sort();
    if (selectedRole.isEmpty && roles.isNotEmpty) selectedRole = roles.first;
    final perms = rbac.roleToPermissions[selectedRole] ?? <String>{};

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Roles',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: roles.contains(selectedRole)
                      ? selectedRole
                      : (roles.isEmpty ? null : roles.first),
                  isExpanded: true,
                  items: [
                    for (final r in roles)
                      DropdownMenuItem(value: r, child: Text(r))
                  ],
                  onChanged: (v) =>
                      setState(() => selectedRole = v ?? selectedRole),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'New role', border: OutlineInputBorder()),
                  onChanged: (v) => newRole = v,
                ),
                const SizedBox(height: 8),
                Wrap(children: [
                  OutlinedButton(
                      onPressed: newRole.trim().isEmpty
                          ? null
                          : () async {
                              await rbac.createRole(newRole.trim());
                              setState(() => selectedRole = newRole.trim());
                            },
                      child: const Text('Create Role')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                      onPressed: (selectedRole == 'admin' ||
                              selectedRole == 'seller' ||
                              selectedRole == 'buyer' ||
                              selectedRole.isEmpty)
                          ? null
                          : () async {
                              await rbac.deleteRole(selectedRole);
                              setState(() => selectedRole =
                                  roles.isNotEmpty ? roles.first : '');
                            },
                      child: const Text('Delete Role')),
                ]),
                const SizedBox(height: 16),
                const Text('Role Templates',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final name in RoleTemplates.allTemplateNames())
                    OutlinedButton(
                      onPressed: selectedRole.isEmpty
                          ? null
                          : () async {
                              final list = RoleTemplates.permissionsFor(name);
                              for (final p in list) {
                                await rbac.grantPermissionToRole(
                                    selectedRole, p);
                              }
                              setState(() {});
                            },
                      child: Text(name),
                    ),
                ]),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      for (final cat in PermissionCatalog.categories)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat.title,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                for (final p in cat.permissions)
                                  FilterChip(
                                    label: Text(p),
                                    selected: perms.contains(p),
                                    onSelected: selectedRole.isEmpty
                                        ? null
                                        : (v) async {
                                            if (v) {
                                              await rbac.grantPermissionToRole(
                                                  selectedRole, p);
                                            } else {
                                              await rbac
                                                  .revokePermissionFromRole(
                                                      selectedRole, p);
                                            }
                                            setState(() {});
                                          },
                                  ),
                              ]),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();
  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String? selectedUserId;
  final TextEditingController _q = TextEditingController();
  String roleFilter = 'any';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(adminStoreProvider);
    var users = store.allUsers;
    final rbac = ref.watch(rbacServiceProvider);
    final roles = rbac.roleToPermissions.keys.toList()..sort();
    final roleFilterOptions = ['any', ...roles];

    // Keep selected user consistent
    if (selectedUserId != null && users.every((u) => u.id != selectedUserId)) {
      selectedUserId = null;
    }

    if (selectedUserId == null && users.isNotEmpty) {
      selectedUserId = users.first.id;
    }

    // Apply simple filters
    if (_q.text.trim().isNotEmpty) {
      final q = _q.text.trim().toLowerCase();
      users = users
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.id.toLowerCase().contains(q))
          .toList();
    }
    if (roleFilter != 'any') {
      users = users
          .where(
              (u) => (rbac.getAssignedRole(u.id) ?? u.role.name) == roleFilter)
          .toList();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: user list with role assignment
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Users',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                FilledButton.icon(
                    onPressed: () => _openCreateUserDialog(context),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Create User')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _q,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search name/email/id',
                            border: OutlineInputBorder()),
                        onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: roleFilterOptions.contains(roleFilter)
                        ? roleFilter
                        : 'any',
                    items: [
                      for (final r in roleFilterOptions)
                        DropdownMenuItem(value: r, child: Text(r))
                    ],
                    onChanged: (v) => setState(() => roleFilter = v ?? 'any'),
                    decoration: const InputDecoration(
                        labelText: 'Filter by RBAC role',
                        border: OutlineInputBorder()),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, idx) {
                    final u = users[idx];
                    final assigned = rbac.getAssignedRole(u.id) ?? u.role.name;
                    final isSelected = u.id == selectedUserId;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.primarySurface,
                      title: Text('${u.name} • ${u.email}'),
                      subtitle: Text(
                          'Role: $assigned  •  Plan: ${u.plan}  •  Status: ${u.status.name}'),
                      trailing: SizedBox(
                        width: 200,
                        child: DropdownButton<String>(
                          value: roles.contains(assigned)
                              ? assigned
                              : (roles.isNotEmpty ? roles.first : null),
                          isExpanded: true,
                          items: [
                            for (final r in roles)
                              DropdownMenuItem(value: r, child: Text(r))
                          ],
                          onChanged: (v) async {
                            if (v == null) return;
                            await rbac.assignRoleToUser(u.id, v);
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                      onTap: () => setState(() => selectedUserId = u.id),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: per-user permission overrides editor
        Expanded(
          flex: 3,
          child: selectedUserId == null
              ? const SizedBox.shrink()
              : _UserOverridesEditor(userId: selectedUserId!),
        ),
      ],
    );
  }

  Future<void> _openCreateUserDialog(BuildContext context) async {
    final store = ProviderScope.containerOf(context).read(adminStoreProvider);
    final rbac = ProviderScope.containerOf(context).read(rbacServiceProvider);
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final sortedRoleKeys = rbac.roleToPermissions.keys.toList()..sort();
    String selectedRbacRole =
        sortedRoleKeys.isNotEmpty ? sortedRoleKeys.first : 'admin';
    final Set<String> extraGrants = <String>{};

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, sbSetState) {
            return AlertDialog(
              title: const Text('Create Admin User'),
              content: SizedBox(
                width: 680,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller: usernameCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Username',
                                      border: OutlineInputBorder()))),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: passwordCtrl,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              value: selectedRbacRole,
                              items: [
                                for (final r in sortedRoleKeys)
                                  DropdownMenuItem(value: r, child: Text(r))
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  sbSetState(() {
                                    selectedRbacRole = v;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                  labelText: 'RBAC Role',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Additional permissions (optional)',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        for (final cat in PermissionCatalog.categories) ...[
                          Row(children: [
                            Expanded(
                                child: Text(cat.title,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary))),
                            TextButton(
                                onPressed: () {
                                  sbSetState(() {
                                    extraGrants.addAll(cat.permissions);
                                  });
                                },
                                child: const Text('Select all')),
                            TextButton(
                                onPressed: () {
                                  sbSetState(() {
                                    extraGrants.removeAll(cat.permissions);
                                  });
                                },
                                child: const Text('Clear')),
                          ]),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final p in cat.permissions)
                              FilterChip(
                                label: Text(p),
                                selected: extraGrants.contains(p),
                                onSelected: (v) {
                                  sbSetState(() {
                                    if (v) {
                                      extraGrants.add(p);
                                    } else {
                                      extraGrants.remove(p);
                                    }
                                  });
                                },
                              ),
                          ]),
                          const SizedBox(height: 8),
                        ],
                      ]),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final id = 'U${now.millisecondsSinceEpoch}';
                      final user = AdminUser(
                        id: id,
                        name: nameCtrl.text.trim(),
                        email: '${usernameCtrl.text.trim()}@example.com',
                        phone: 'n/a',
                        role: UserRole.admin,
                        status: UserStatus.active,
                        subscription: SubscriptionPlan.free,
                        joinDate: now,
                        lastActive: now,
                        location: 'Unknown',
                        industry: 'Unknown',
                        createdAt: now,
                        plan: 'free',
                        isSeller: false,
                      );
                      await store.addUser(user);
                      await rbac.setCredential(id, usernameCtrl.text.trim(),
                          passwordCtrl.text.trim());
                      await rbac.assignRoleToUser(id, selectedRbacRole);
                      if (extraGrants.isNotEmpty) {
                        await rbac.upsertOverride(
                            UserOverride(userId: id, grants: extraGrants));
                      }
                      if (mounted) {
                        setState(() {
                          selectedUserId = id;
                        });
                      }
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: const Text('Create')),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserOverridesEditor extends ConsumerStatefulWidget {
  final String userId;
  const _UserOverridesEditor({required this.userId});
  @override
  ConsumerState<_UserOverridesEditor> createState() =>
      _UserOverridesEditorState();
}

class _UserOverridesEditorState extends ConsumerState<_UserOverridesEditor> {
  late Set<String> _pendingGrants;
  late Set<String> _pendingRevokes;

  @override
  void initState() {
    super.initState();
    _pendingGrants = <String>{};
    _pendingRevokes = <String>{};
  }

  @override
  Widget build(BuildContext context) {
    final rbac = ref.watch(rbacServiceProvider);
    final adminStore = ref.watch(adminStoreProvider);
    final assignedRole = rbac.getAssignedRole(widget.userId);
    // Fallback to default role from users list
    final defaultRole =
        adminStore.allUsers.firstWhere((u) => u.id == widget.userId).role.name;
    final role = assignedRole ?? defaultRole;
    final base = rbac.roleToPermissions[role] ?? <String>{};
    final current =
        rbac.overrideForUser(widget.userId) ?? const UserOverride(userId: '');
    // Initialize pending sets from current on each build if empty (first load or after clear)
    if (_pendingGrants.isEmpty && _pendingRevokes.isEmpty) {
      _pendingGrants = {...current.grants};
      _pendingRevokes = {...current.revokes};
    }

    Future<void> togglePermission(String permission, bool nextSelected) async {
      final grants = {..._pendingGrants};
      final revokes = {..._pendingRevokes};
      final inBase = base.contains(permission);
      if (nextSelected) {
        // Ensure permission is allowed: remove revoke if base has it; else grant it
        if (inBase) {
          revokes.remove(permission);
        } else {
          grants.add(permission);
        }
      } else {
        // Ensure permission is denied: add revoke if base has it; else remove grant
        if (inBase) {
          revokes.add(permission);
        } else {
          grants.remove(permission);
        }
      }
      setState(() {
        _pendingGrants = grants;
        _pendingRevokes = revokes;
      });
    }

    bool isSelected(String permission) {
      if (_pendingRevokes.contains(permission)) return false;
      if (_pendingGrants.contains(permission)) return true;
      return base.contains(permission);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Overrides for: ${widget.userId}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineSoft),
                borderRadius: BorderRadius.circular(6)),
            child: Text('Base role: $role',
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const Spacer(),
          OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _pendingGrants.clear();
                  _pendingRevokes.clear();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset')),
          const SizedBox(width: 8),
          FilledButton.icon(
              onPressed: () async {
                // Save pending changes
                if (_pendingGrants.isEmpty && _pendingRevokes.isEmpty) {
                  await rbac.removeOverride(widget.userId);
                } else {
                  await rbac.upsertOverride(UserOverride(
                      userId: widget.userId,
                      grants: _pendingGrants,
                      revokes: _pendingRevokes));
                }
                if (mounted) setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Overrides saved')),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save')),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final cat in PermissionCatalog.categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(cat.title,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary))),
                          TextButton(
                              onPressed: () async {
                                for (final p in cat.permissions) {
                                  if (!isSelected(p)) {
                                    await togglePermission(p, true);
                                  }
                                }
                                if (mounted) setState(() {});
                              },
                              child: const Text('Select all')),
                          TextButton(
                              onPressed: () async {
                                for (final p in cat.permissions) {
                                  if (isSelected(p)) {
                                    await togglePermission(p, false);
                                  }
                                }
                                if (mounted) setState(() {});
                              },
                              child: const Text('Clear')),
                        ]),
                        const SizedBox(height: 6),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final p in cat.permissions)
                            FilterChip(
                              label: Text(p),
                              selected: isSelected(p),
                              onSelected: (v) => togglePermission(p, v),
                            ),
                        ]),
                      ]),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _OverridesTab extends ConsumerStatefulWidget {
  const _OverridesTab();
  @override
  ConsumerState<_OverridesTab> createState() => _OverridesTabState();
}

class _OverridesTabState extends ConsumerState<_OverridesTab> {
  final userIdCtrl = TextEditingController();
  final grantsCtrl = TextEditingController();
  final revokesCtrl = TextEditingController();
  DateTime? expiresAt;

  @override
  void dispose() {
    userIdCtrl.dispose();
    grantsCtrl.dispose();
    revokesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rbac = ref.watch(rbacServiceProvider);
    final overrides = rbac.allOverrides.values.toList();
    overrides.sort((a, b) => a.userId.compareTo(b.userId));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Permission Overrides',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          SizedBox(
              width: 220,
              child: TextField(
                  controller: userIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'User ID', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          SizedBox(
              width: 280,
              child: TextField(
                  controller: grantsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Grants (comma separated)',
                      border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          SizedBox(
              width: 280,
              child: TextField(
                  controller: revokesCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Revokes (comma separated)',
                      border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          OutlinedButton(
              onPressed: () async {
                final override = UserOverride(
                  userId: userIdCtrl.text.trim(),
                  grants: grantsCtrl.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toSet(),
                  revokes: revokesCtrl.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toSet(),
                  expiresAt: expiresAt,
                );
                await rbac.upsertOverride(override);
                if (mounted) setState(() {});
              },
              child: const Text('Save Override')),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        const Text('Existing Overrides',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: overrides.length,
            itemBuilder: (context, i) {
              final o = overrides[i];
              return ListTile(
                title: Text(o.userId),
                subtitle: Text(
                    'Grants: ${o.grants.join(', ')} • Revokes: ${o.revokes.join(', ')}${o.expiresAt != null ? ' • Expires: ${o.expiresAt}' : ''}'),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await rbac.removeOverride(o.userId);
                      if (mounted) setState(() {});
                    }),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(adminStoreProvider);
    final roleCounts = <String, int>{};
    for (final u in store.allUsers) {
      roleCounts[u.role.name] = (roleCounts[u.role.name] ?? 0) + 1;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('System Overview',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _statCard('Roles', store.roleToPermissions.length.toString()),
          _statCard('Permissions Catalog',
              PermissionCatalog.allPermissions().length.toString()),
          _statCard('Users', store.allUsers.length.toString()),
          _statCard('Role: admin perms',
              (store.roleToPermissions['admin']?.length ?? 0).toString()),
        ]),
      ]),
    );
  }

  Widget _statCard(String label, String value) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
