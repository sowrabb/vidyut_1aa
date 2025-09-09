import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/admin_store.dart';
import '../models/notification.dart' as notif;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          FilledButton.icon(
            onPressed: _openCreateWizard,
            icon: const Icon(Icons.add),
            label: const Text('Create Notification'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<AdminStore>(
        builder: (context, store, _) {
          final drafts = store.notificationDrafts;
          final templates = store.notificationTemplates;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Drafts', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (drafts.isEmpty)
                  const Text('No drafts yet'),
                if (drafts.isNotEmpty)
                  ...drafts.map((d) => Card(
                        child: ListTile(
                          title: Text('Draft ${d.id} • ${d.type.name}'),
                          subtitle: Text('${d.channels.map((e)=>e.name).join(', ')} • audience ~${store.estimateAudienceSize(d.audience)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                tooltip: 'Send now',
                                onPressed: () => store.sendNotification(d),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => store.deleteNotificationDraft(d.id),
                              ),
                            ],
                          ),
                          onTap: () => _openCreateWizard(existing: d),
                        ),
                      )),
                const SizedBox(height: 24),
                Text('Templates', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (templates.isEmpty)
                  const Text('No templates'),
                if (templates.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: templates
                        .map((t) => Chip(
                              label: Text('${t.name} • ${t.channel.name}'),
                            ))
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCreateWizard({notif.NotificationDraft? existing}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NotificationWizard(existing: existing),
    );
  }
}

class _NotificationWizard extends StatefulWidget {
  final notif.NotificationDraft? existing;
  const _NotificationWizard({this.existing});

  @override
  State<_NotificationWizard> createState() => _NotificationWizardState();
}

class _NotificationWizardState extends State<_NotificationWizard> {
  int step = 0;
  late notif.NotificationType type;
  Set<notif.NotificationChannel> channels = {notif.NotificationChannel.inApp};
  notif.AudienceFilter audience = const notif.AudienceFilter();
  final Map<notif.NotificationChannel, notif.NotificationTemplate> templates = {};
  DateTime? scheduledAt;
  bool respectQuiet = true;

  final TextEditingController _userIdsCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final d = widget.existing!;
      type = d.type;
      channels = {...d.channels};
      audience = d.audience;
      templates.addAll(d.templates);
      scheduledAt = d.scheduledAt;
      respectQuiet = d.respectQuietHours;
    } else {
      type = notif.NotificationType.segmented;
    }
  }

  @override
  void dispose() {
    _userIdsCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            AppBar(
              title: const Text('Create Notification'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            Expanded(
              child: Stepper(
                currentStep: step,
                onStepContinue: _next,
                onStepCancel: _back,
                steps: [
                  Step(
                    title: const Text('Audience'),
                    isActive: step >= 0,
                    content: _buildAudience(),
                  ),
                  Step(
                    title: const Text('Content'),
                    isActive: step >= 1,
                    content: _buildContent(),
                  ),
                  Step(
                    title: const Text('Schedule'),
                    isActive: step >= 2,
                    content: _buildSchedule(),
                  ),
                  Step(
                    title: const Text('Review'),
                    isActive: step >= 3,
                    content: _buildReview(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudience() {
    final store = Provider.of<AdminStore>(context, listen: false);
    final roles = const ['admin','seller','buyer'];
    final states = store.geo.keys.toList();
    final userIdsStr = audience.userIds.join(',');
    _userIdsCtrl.text = userIdsStr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: roles.map((r) {
            final selected = audience.roles.contains(r);
            return FilterChip(
              selected: selected,
              label: Text(r),
              onSelected: (v) {
                setState(() {
                  final s = {...audience.roles};
                  v ? s.add(r) : s.remove(r);
                  audience = audience.copyWith(roles: s);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: null,
          items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              final s = {...audience.states};
              if (s.contains(val)) s.remove(val); else s.add(val);
              audience = audience.copyWith(states: s);
            });
          },
          decoration: const InputDecoration(labelText: 'Add/Remove State'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Only Sellers'),
            Switch(
              value: audience.isSeller ?? false,
              onChanged: (v) => setState(() => audience = audience.copyWith(isSeller: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userIdsCtrl,
          decoration: const InputDecoration(
            labelText: 'Specific User IDs (comma-separated)',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            final ids = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
            setState(() => audience = audience.copyWith(userIds: ids));
          },
        ),
        const SizedBox(height: 12),
        Text('Estimated recipients: ${store.estimateAudienceSize(audience)}'),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: notif.NotificationChannel.values.map((c) => FilterChip(
                label: Text(c.name),
                selected: channels.contains(c),
                onSelected: (v) => setState(() {
                  v ? channels.add(c) : channels.remove(c);
                }),
              )).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Respect quiet hours'),
            Switch(value: respectQuiet, onChanged: (v) => setState(() => respectQuiet = v)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => scheduledAt = null),
              icon: const Icon(Icons.flash_on),
              label: const Text('Send Now'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  initialDate: now,
                );
                if (picked != null) {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time != null) {
                    setState(() {
                      scheduledAt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                    });
                  }
                }
              },
              icon: const Icon(Icons.schedule),
              label: Text(scheduledAt == null ? 'Schedule' : 'Scheduled: $scheduledAt'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildReview() {
    final store = Provider.of<AdminStore>(context, listen: false);
    final draft = _buildDraft();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: ${draft.type.name}'),
        Text('Channels: ${draft.channels.map((e)=>e.name).join(', ')}'),
        Text('Audience: ~${store.estimateAudienceSize(draft.audience)} users'),
        Text('Schedule: ${draft.scheduledAt?.toIso8601String() ?? 'Now'}'),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                await store.saveNotificationDraft(draft);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Draft'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () async {
                await store.saveNotificationDraft(draft);
                await store.sendNotification(draft);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification queued')));
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Publish'),
            ),
          ],
        ),
      ],
    );
  }

  void _next() {
    if (step < 3) setState(() => step++);
  }

  void _back() {
    if (step > 0) setState(() => step--);
  }

  notif.NotificationDraft _buildDraft() {
    final id = widget.existing?.id ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
    final selectedChannels = channels.isEmpty ? {notif.NotificationChannel.inApp} : channels;
    final Map<notif.NotificationChannel, notif.NotificationTemplate> tmpl = {
      for (final c in selectedChannels)
        c: notif.NotificationTemplate(
          id: 'inline_${c.name}_$id',
          name: 'Inline ${c.name}',
          channel: c,
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        )
    };
    return notif.NotificationDraft(
      id: id,
      type: type,
      channels: selectedChannels,
      audience: audience,
      templates: tmpl,
      scheduledAt: scheduledAt,
      respectQuietHours: respectQuiet,
    );
  }
}


