import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_shell.dart';
import '../models/admin_user.dart';
import '../../../app/provider_registry.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  String? _selectedUserId;
  final TextEditingController _password = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoDataServiceProvider);
    final users = demo.allUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sign in as Admin',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    items: [
                      const DropdownMenuItem(
                          value: '__any__', child: Text('Skip (any admin)')),
                      const DropdownMenuItem(
                          value: '__marketing__', child: Text('Marketing')),
                      ...users.where((u) => u.role == UserRole.admin).map((u) =>
                          DropdownMenuItem(
                              value: u.id,
                              child: Text('${u.name} (${u.role.name})')))
                    ],
                    onChanged: (v) => setState(() => _selectedUserId = v),
                    decoration: const InputDecoration(
                        labelText: 'Admin User', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password (demo: any)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            // final messenger = ScaffoldMessenger.of(context);
                            // Optional: allow proceeding without selecting details

                            setState(() => _submitting = true);
                            final auth = ref.read(adminAuthServiceProvider);
                            final navigator = Navigator.of(context);

                            try {
                              AdminUser user;
                              if (_selectedUserId == '__marketing__') {
                                // Pick first admin, then assign RBAC role 'marketing'
                                user = users.firstWhere(
                                    (u) => u.role == UserRole.admin);
                                await ref
                                    .read(rbacServiceProvider)
                                    .assignRoleToUser(user.id, 'marketing');
                                await auth.login(user);
                              } else {
                                user = (_selectedUserId == '__any__' ||
                                        _selectedUserId == null)
                                    ? users.firstWhere(
                                        (u) => u.role == UserRole.admin)
                                    : users.firstWhere(
                                        (u) => u.id == _selectedUserId);
                                await auth.login(user);
                              }

                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const AdminShell()),
                                (route) => route.isFirst,
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _submitting = false);
                              }
                            }
                          },
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
