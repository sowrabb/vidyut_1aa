import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../models/admin_user.dart';

class SubscriptionsTab extends ConsumerStatefulWidget {
  const SubscriptionsTab({super.key});

  @override
  ConsumerState<SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends ConsumerState<SubscriptionsTab> {
  String _searchQuery = '';
  String _selectedPlan = 'all';
  final Set<String> _selectedUsers = {};

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final store = ref.watch(adminStoreProvider);
      final users = store.allUsers;
      final stats = store.getSubscriptionStats();

      // Filter users based on search and plan
      var filteredUsers = users.where((user) {
        final matchesSearch = _searchQuery.isEmpty ||
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.id.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesPlan =
            _selectedPlan == 'all' || user.plan == _selectedPlan;

        return matchesSearch && matchesPlan;
      }).toList();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Users',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text('${users.length}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Free Plan',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text('${stats['free'] ?? 0}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Basic Plan',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text('${stats['basic'] ?? 0}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Premium Plan',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text('${stats['premium'] ?? 0}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and filter controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedPlan,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Plans')),
                    DropdownMenuItem(value: 'free', child: Text('Free')),
                    DropdownMenuItem(value: 'basic', child: Text('Basic')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPlan = value ?? 'all';
                    });
                  },
                ),
                const SizedBox(width: 12),
                if (_selectedUsers.isNotEmpty) ...[
                  OutlinedButton(
                    onPressed: () => _showBulkActionDialog(context, store),
                    child: Text('Bulk Actions (${_selectedUsers.length})'),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Users table
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Current Plan')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredUsers.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Checkbox(
                              value: _selectedUsers.contains(user.id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUsers.add(user.id);
                                  } else {
                                    _selectedUsers.remove(user.id);
                                  }
                                });
                              },
                            ),
                          ),
                          DataCell(Text(user.name)),
                          DataCell(Text(user.email)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPlanColor(user.plan),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.plan.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user.status == UserStatus.active
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => _showUserSubscriptionDialog(
                                    context, store, user),
                                child: const Text('Manage'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _showUpgradeDialog(context, store, user),
                                child: const Text('Upgrade'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await store.pauseUserSubscription(user.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Paused ${user.name}')),
                                    );
                                  }
                                },
                                child: const Text('Pause'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final newPlan = user.plan == 'premium'
                                      ? 'basic'
                                      : user.plan == 'basic'
                                          ? 'free'
                                          : 'free';
                                  await store.downgradeUser(user.id, newPlan);
                                },
                                child: const Text('Downgrade'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _showCancelDialog(context, store, user),
                                child: const Text('Cancel'),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getPlanColor(String plan) {
    switch (plan) {
      case 'free':
        return Colors.grey;
      case 'basic':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showBulkActionDialog(BuildContext context, dynamic store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: const Text('Upgrade to Premium'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await store.bulkUpdateUserSubscriptions(
                    _selectedUsers.toList(), 'premium');
                setState(() {
                  _selectedUsers.clear();
                });
                navigator.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down),
              title: const Text('Downgrade to Basic'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await store.bulkUpdateUserSubscriptions(
                    _selectedUsers.toList(), 'basic');
                setState(() {
                  _selectedUsers.clear();
                });
                navigator.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel Subscriptions'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await store.bulkUpdateUserSubscriptions(
                    _selectedUsers.toList(), 'free');
                setState(() {
                  _selectedUsers.clear();
                });
                navigator.pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUserSubscriptionDialog(
      BuildContext context, dynamic store, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Plan: ${user.plan.toUpperCase()}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: user.plan,
              decoration: const InputDecoration(labelText: 'Change Plan'),
              items: const [
                DropdownMenuItem(value: 'free', child: Text('Free')),
                DropdownMenuItem(value: 'basic', child: Text('Basic')),
                DropdownMenuItem(value: 'premium', child: Text('Premium')),
              ],
              onChanged: (newPlan) async {
                if (newPlan != null && newPlan != user.plan) {
                  final navigator = Navigator.of(context);
                  await store.updateUserSubscription(user.id, newPlan);
                  navigator.pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, dynamic store, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade ${user.name}'),
        content: const Text(
            'Are you sure you want to upgrade this user to the next plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final newPlan = user.plan == 'free' ? 'basic' : 'premium';
              await store.upgradeUser(user.id, newPlan);
              navigator.pop();
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, dynamic store, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel ${user.name}\'s Subscription'),
        content: const Text(
            'Are you sure you want to cancel this user\'s subscription? They will be moved to the free plan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await store.cancelUserSubscription(user.id);
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Subscription',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
