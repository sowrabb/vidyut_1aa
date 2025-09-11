import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import 'package:ionicons/ionicons.dart';
import '../messaging/messaging_pages.dart';
import '../messaging/messaging_store.dart';
import '../../app/tokens.dart';
import '../../widgets/notification_badge.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Your Profile'),
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Saved'),
            Tab(text: 'RFQs'),
            Tab(text: 'Settings'),
          ]),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            _OverviewTab(),
            _SavedTab(),
            _RfqsTab(),
            _SettingsTab(),
          ]),
        ),
        floatingActionButton: Consumer<MessagingStore>(
          builder: (context, messagingStore, child) {
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
        child: Consumer<MessagingStore>(
          builder: (context, messagingStore, child) {
            return Row(
              children: [
                NotificationBadge(
                  count: messagingStore.unreadCount,
                  child: const Icon(Ionicons.chatbubble_ellipses_outline, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Messages',
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

class _SavedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentClamp(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('TODO: Saved products & sellers'),
        ],
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
          Text('TODO: Buyer RFQs & statuses'),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentClamp(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('TODO: Password, notifications, preferences'),
        ],
      ),
    );
  }
}
