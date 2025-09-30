import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../app/layout/adaptive.dart';
import 'package:ionicons/ionicons.dart';
import '../messaging/messaging_pages.dart';
import '../../app/tokens.dart';
import '../../widgets/notification_badge.dart';
import 'widgets/profile_settings_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Your Profile'),
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'RFQs'),
            Tab(text: 'Settings'),
          ]),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            _OverviewTab(),
            _RfqsTab(),
            _SettingsTab(),
          ]),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final messagingStore = ref.watch(messagingStoreProvider);
            return NotificationBadge(
              count: messagingStore.unreadCount,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MessagingPage()),
                  );
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Ionicons.chatbubble_ellipses_outline),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentClamp(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 12),
          const _QuickStats(),
          const SizedBox(height: 12),
          _MessagesShortcutCard(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineSoft)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Buyer Name',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text('buyer@example.com',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
          OutlinedButton(onPressed: () {}, child: const Text('Edit Profile')),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final authService = ref.watch(otpAuthServiceProvider);
              return TextButton(
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
                child: Text(authService.isGuest ? 'Sign Up' : 'Logout'),
              );
            },
          ),
        ]),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats();
  @override
  Widget build(BuildContext context) {
    return const ResponsiveRow(desktop: 3, tablet: 3, phone: 1, children: [
      _StatCard(label: 'Saved', value: '18'),
      _StatCard(label: 'RFQs', value: '5'),
      _StatCard(label: 'Orders', value: '2'),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineSoft)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ]),
      ),
    );
  }
}

class _MessagesShortcutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MessagingPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final messagingStore = ref.watch(messagingStoreProvider);
            return Row(
              children: [
                NotificationBadge(
                  count: messagingStore.unreadCount,
                  child: const Icon(Ionicons.chatbubble_ellipses_outline,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Messages',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Ionicons.arrow_forward, color: Colors.white),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RfqsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentClamp(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Coming soon: Buyer RFQs & statuses'),
        ],
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStore = ref.watch(userStoreProvider);

    return ContentClamp(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          ProfileSection(profile: userStore.profile),
          const SizedBox(height: 24),

          // Security Section
          SecuritySection(userStore: userStore),
          const SizedBox(height: 24),

          // Notifications Section
          NotificationsSection(settings: userStore.notificationSettings),
          const SizedBox(height: 24),

          // Preferences Section
          PreferencesSection(preferences: userStore.preferences),
          const SizedBox(height: 24),

          // Account Actions Section
          AccountActionsSection(userStore: userStore),
        ],
      ),
    );
  }
}
