import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../../app/tokens.dart';
import '../../app/layout/app_shell_scaffold.dart';
import 'messaging_store.dart';
import 'models.dart';

class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    return ChangeNotifierProvider(
      create: (_) => MessagingStore(),
      child: Scaffold(
        appBar: const VidyutAppBar(title: 'Messages'),
        body: isWide ? const _WideLayout() : const _NarrowLayout(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final store = context.read<MessagingStore>();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: false,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (sheetContext) => ChangeNotifierProvider.value(
                value: store,
                child: const _NewMessageSheet(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Ionicons.create_outline),
        ),
        backgroundColor: AppColors.surface,
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(width: 320, child: _ConversationList()),
        VerticalDivider(width: 1, color: AppColors.divider),
        Expanded(child: _ConversationView()),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();
  @override
  Widget build(BuildContext context) {
    return const _TwoPane();
  }
}

class _TwoPane extends StatefulWidget {
  const _TwoPane();
  @override
  State<_TwoPane> createState() => _TwoPaneState();
}

class _TwoPaneState extends State<_TwoPane> {
  bool showList = true;
  MessagingStore? _store;

  void _onStoreChanged() {
    if (!mounted) return;
    if (_store?.activeConversationId != null) {
      setState(() => showList = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = context.read<MessagingStore>();
    if (!identical(s, _store)) {
      _store?.removeListener(_onStoreChanged);
      _store = s;
      _store?.addListener(_onStoreChanged);
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: showList
          ? _ConversationList(onOpen: () => setState(() => showList = false))
          : _ConversationView(onBack: () => setState(() => showList = true)),
    );
  }
}

class _NewMessageSheet extends StatefulWidget {
  const _NewMessageSheet();
  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<({String id, String title, String subtitle})> _allSellers(BuildContext context) {
    // Static demo list; can be wired to SellerStore later
    return [
      (id: 'seller_acme', title: 'Acme Traders', subtitle: 'Distributor • Hyderabad'),
      (id: 'seller_crompton', title: 'Crompton Distributors', subtitle: 'Manufacturer • Pune'),
      (id: 'seller_generic', title: 'Generic Electricals', subtitle: 'Retailer • Mumbai'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<MessagingStore>();
    final candidates = _allSellers(context)
        .where((s) => _query.text.isEmpty || s.title.toLowerCase().contains(_query.text.toLowerCase()))
        .toList();
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    return DraggableScrollableSheet(
      initialChildSize: isDesktop ? 0.6 : 0.9,
      minChildSize: isDesktop ? 0.4 : 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(Ionicons.create_outline),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('New Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Ionicons.close_outline),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: 'Search seller or type "support"',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Ionicons.search_outline),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) => _startChat(store, v.trim()),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: candidates.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Ionicons.headset_outline, color: Colors.white),
                      ),
                      title: const Text('Contact Support'),
                      subtitle: const Text('Vidyut Support'),
                      onTap: () {
                        store.ensureConversation(id: 'support', title: 'Vidyut Support', isSupport: true);
                        Navigator.of(context).pop();
                      },
                    );
                  }
                  final s = candidates[i - 1];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Ionicons.storefront_outline)),
                    title: Text(s.title),
                    subtitle: Text(s.subtitle),
                    onTap: () {
                      store.ensureConversation(id: s.id, title: s.title, subtitle: s.subtitle, isSupport: false);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _startChat(MessagingStore store, String input) {
    if (input.toLowerCase() == 'support') {
      store.ensureConversation(id: 'support', title: 'Vidyut Support', isSupport: true);
      Navigator.of(context).pop();
      return;
    }
    final match = _allSellers(context).firstWhere(
      (s) => s.title.toLowerCase().contains(input.toLowerCase()),
      orElse: () => (id: '', title: '', subtitle: ''),
    );
    if (match.id.isNotEmpty) {
      store.ensureConversation(id: match.id, title: match.title, subtitle: match.subtitle);
      Navigator.of(context).pop();
    }
  }
}

class _ConversationList extends StatelessWidget {
  final VoidCallback? onOpen;
  const _ConversationList({this.onOpen});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<MessagingStore>();
    final items = store.conversations;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final c = items[index];
        final last = c.messages.isNotEmpty ? c.messages.last : null;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                c.isSupport ? AppColors.primary : AppColors.primarySurface,
            child: Icon(
              c.isSupport
                  ? Ionicons.headset_outline
                  : Ionicons.chatbubble_ellipses_outline,
              color: c.isSupport ? Colors.white : AppColors.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                  child: Text(c.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (c.isPinned)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Ionicons.pin_outline,
                      size: 16, color: AppColors.textSecondary),
                ),
            ],
          ),
          subtitle: Text(last?.text ?? c.subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(
            last != null ? _formatTime(last.sentAt) : '',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          onTap: () {
            store.selectConversation(c.id);
            onOpen?.call();
          },
        );
      },
    );
  }
}

class _ConversationView extends StatelessWidget {
  final VoidCallback? onBack;
  const _ConversationView({this.onBack});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MessagingStore>();
    final conv = store.activeConversation;
    if (conv == null || conv.id.isEmpty) {
      return const Center(child: Text('No conversation'));
    }
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: ListTile(
            leading: onBack != null
                ? IconButton(
                    icon: const Icon(Ionicons.arrow_back), onPressed: onBack)
                : CircleAvatar(
                    backgroundColor: conv.isSupport
                        ? AppColors.primary
                        : AppColors.primarySurface,
                    child: Icon(
                      conv.isSupport
                          ? Ionicons.headset_outline
                          : Ionicons.chatbubble_ellipses_outline,
                      color: conv.isSupport ? Colors.white : AppColors.primary,
                    ),
                  ),
            title: Text(conv.title),
            subtitle: Text(conv.isSupport ? 'Support' : 'Chat'),
            trailing: const SizedBox.shrink(),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: conv.messages.length,
            itemBuilder: (context, index) {
              final m = conv.messages[index];
              final isMe = m.senderType == MessageSenderType.me;
              final replyTo = m.replyToMessageId != null
                  ? conv.messages.firstWhere((e) => e.id == m.replyToMessageId,
                      orElse: () => Message(
                          id: '',
                          conversationId: conv.id,
                          senderType: m.senderType,
                          senderName: '',
                          text: '',
                          sentAt: m.sentAt))
                  : null;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onLongPress: () =>
                      context.read<MessagingStore>().setReplyTo(m),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyTo != null && replyTo.id.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border(
                                  left: BorderSide(
                                      color: AppColors.primary.withOpacity(0.6),
                                      width: 3)),
                            ),
                            child: Text(replyTo.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          ),
                        if (m.text.isNotEmpty) Text(m.text),
                        if (m.attachments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: m.attachments
                                .map((a) => _AttachmentChip(attachment: a))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(_formatTime(m.sentAt),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        const _Composer(),
      ],
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final Attachment attachment;
  const _AttachmentChip({required this.attachment});
  @override
  Widget build(BuildContext context) {
    final icon = attachment.type == 'image'
        ? Ionicons.image_outline
        : attachment.type == 'pdf'
            ? Ionicons.document_outline
            : Ionicons.attach_outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(attachment.name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer();
  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final TextEditingController _controller = TextEditingController();
  final List<Attachment> _staged = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && _staged.isEmpty) return;
    context
        .read<MessagingStore>()
        .sendMessage(text, attachments: List.of(_staged));
    _controller.clear();
    setState(() => _staged.clear());
  }

  void _addAttachment() {
    // Placeholder: add a dummy attachment. File pickers can be wired later.
    setState(() {
      _staged.add(Attachment(
          id: UniqueKey().toString(), name: 'attachment.pdf', type: 'pdf'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final reply = context.watch<MessagingStore>().replyDraft;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reply.isActive)
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Ionicons.return_down_forward_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(reply.previewText ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Ionicons.close_outline),
                    onPressed: () =>
                        context.read<MessagingStore>().clearReply(),
                  ),
                ],
              ),
            ),
          if (_staged.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _staged
                    .map(
                      (a) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _AttachmentChip(attachment: a),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: InkWell(
                              onTap: () => setState(() => _staged.remove(a)),
                              child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Ionicons.close,
                                      size: 12, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _addAttachment,
                  icon: const Icon(Ionicons.attach_outline),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Ionicons.send_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  if (day == today) {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
  return '${time.day}/${time.month}/${time.year}';
}
