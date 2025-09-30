import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

class NotificationsTray extends ConsumerStatefulWidget {
  const NotificationsTray({super.key});

  @override
  ConsumerState<NotificationsTray> createState() => _NotificationsTrayState();
}

class _NotificationsTrayState extends ConsumerState<NotificationsTray> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(notificationsRepositoryProvider);
    return StreamBuilder(
      stream: repo.getInbox(limit: 20),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <InboxItem>[];
        final unread = items.where((e) => e.readAt == null).length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _openSheet(items, repo),
            ),
            if (unread > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openSheet(List<InboxItem> items, NotificationsRepository repo) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (_, i) {
            final item = items[i];
            return ListTile(
              leading: Icon(item.readAt == null ? Icons.markunread : Icons.drafts),
              title: Text(item.title),
              subtitle: Text(item.body),
              onTap: () async {
                await repo.markRead(item.id);
                if (mounted) Navigator.pop(context);
              },
              onLongPress: () async {
                await repo.markRead(item.id);
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        );
      },
    );
  }
}


