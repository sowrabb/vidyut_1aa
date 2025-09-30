import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../app/tokens.dart';

class AdminDashboardV2 extends ConsumerWidget {
  const AdminDashboardV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final rbac = ref.watch(rbacProvider);
    final analyticsAsync = ref.watch(analyticsProvider);
    final kycAsync = ref.watch(kycSubmissionsProvider);
    
    // Check admin permissions
    if (!rbac.can('admin.access')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${session.displayName ?? 'Admin'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${rbac.role}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Analytics Section
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            analyticsAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading analytics: $error'),
                ),
              ),
              data: (analytics) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Users',
                        value: '${analytics.metrics['total_users'] ?? 0}',
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Active Users',
                        value: '${analytics.metrics['active_users'] ?? 0}',
                        icon: Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Products',
                        value: '${analytics.metrics['total_products'] ?? 0}',
                        icon: Icons.inventory,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // KYC Section
            if (rbac.can('kyc.review')) ...[
              Text(
                'KYC Submissions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              
              kycAsync.when(
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading KYC: $error'),
                  ),
                ),
                data: (kycData) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Reviews',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text('${kycData.totalCount} total'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (kycData.items.isEmpty)
                            const Text('No pending KYC submissions.')
                          else
                            ...kycData.items.take(3).map((submission) {
                              return ListTile(
                                title: Text(submission.userName),
                                subtitle: Text('Status: ${submission.status}'),
                                trailing: submission.status == 'pending'
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              ref.read(kycSubmissionsProvider.notifier)
                                                  .approveSubmission(submission.id);
                                            },
                                            child: const Text('Approve'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              ref.read(kycSubmissionsProvider.notifier)
                                                  .rejectSubmission(submission.id, 'Rejected');
                                            },
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      )
                                    : null,
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (rbac.can('users.read'))
                  _ActionCard(
                    title: 'Manage Users',
                    icon: Icons.people,
                    onTap: () {
                      // TODO: Navigate to users page
                    },
                  ),
                if (rbac.can('products.write'))
                  _ActionCard(
                    title: 'Manage Products',
                    icon: Icons.inventory,
                    onTap: () {
                      // TODO: Navigate to products page
                    },
                  ),
                if (rbac.can('notifications.send'))
                  _ActionCard(
                    title: 'Send Notifications',
                    icon: Icons.notifications,
                    onTap: () {
                      // TODO: Navigate to notifications page
                    },
                  ),
                if (rbac.can('billing.manage'))
                  _ActionCard(
                    title: 'Billing',
                    icon: Icons.payment,
                    onTap: () {
                      // TODO: Navigate to billing page
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 24, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
