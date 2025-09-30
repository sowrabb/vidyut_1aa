import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:photo_view/photo_view.dart';
import '../../app/tokens.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../../app/provider_registry.dart';
import 'messaging_store.dart';
import 'models.dart';
import 'attachments.dart';
import 'messaging_attachment_service.dart';
import 'messaging_backend_service.dart';

class MessagingPage extends ConsumerWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    return Scaffold(
      appBar: const VidyutAppBar(title: 'Messages'),
      body: isWide ? const _WideLayout() : const _NarrowLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: false,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (sheetContext) => const _NewMessageSheet(),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messaging service not available')),
            );
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Ionicons.create_outline),
      ),
      backgroundColor: AppColors.surface,
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
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

class _TwoPane extends ConsumerStatefulWidget {
  const _TwoPane();
  @override
  ConsumerState<_TwoPane> createState() => _TwoPaneState();
}

class _TwoPaneState extends ConsumerState<_TwoPane> {
  bool showList = true;
  var _store;

  void _onStoreChanged() {
    if (!mounted) return;
    if (_store?.activeConversationId != null &&
        _store!.activeConversationId!.isNotEmpty) {
      setState(() => showList = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final s = ref.read(messagingStoreProvider);
      if (!identical(s, _store)) {
        _store?.removeListener(_onStoreChanged);
        _store = s;
        _store?.addListener(_onStoreChanged);
        // Check if there's already an active conversation
        if (_store?.activeConversationId != null &&
            _store!.activeConversationId!.isNotEmpty) {
          setState(() => showList = false);
        }
      }
    } catch (e) {
      // Provider not available yet, will retry on next build
      _store = null;
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
      transitionBuilder: (child, animation) {
        // Use a more efficient transition that doesn't rebuild the entire widget tree
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: showList
          ? _ConversationList(onOpen: () => setState(() => showList = false))
          : _ConversationView(onBack: () => setState(() => showList = true)),
    );
  }
}

class _NewMessageSheet extends ConsumerStatefulWidget {
  const _NewMessageSheet();
  @override
  ConsumerState<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends ConsumerState<_NewMessageSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<({String id, String title, String subtitle})> _allSellers(
      BuildContext context) {
    // Static demo list; can be wired to SellerStore later
    return [
      (
        id: 'seller_acme',
        title: 'Acme Traders',
        subtitle: 'Distributor • Hyderabad'
      ),
      (
        id: 'seller_crompton',
        title: 'Crompton Distributors',
        subtitle: 'Manufacturer • Pune'
      ),
      (
        id: 'seller_generic',
        title: 'Generic Electricals',
        subtitle: 'Retailer • Mumbai'
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.read(messagingStoreProvider);
    final candidates = _allSellers(context)
        .where((s) =>
            _query.text.isEmpty ||
            s.title.toLowerCase().contains(_query.text.toLowerCase()))
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
                    child: Text('New Message',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        child:
                            Icon(Ionicons.headset_outline, color: Colors.white),
                      ),
                      title: const Text('Contact Support'),
                      subtitle: const Text('Vidyut Support'),
                      onTap: () {
                        store.ensureConversation(
                            id: 'support',
                            title: 'Vidyut Support',
                            isSupport: true);
                        Navigator.of(context).pop();
                      },
                    );
                  }
                  final s = candidates[i - 1];
                  return ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Ionicons.storefront_outline)),
                    title: Text(s.title),
                    subtitle: Text(s.subtitle),
                    onTap: () {
                      store.ensureConversation(
                          id: s.id,
                          title: s.title,
                          subtitle: s.subtitle,
                          isSupport: false);
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
      store.ensureConversation(
          id: 'support', title: 'Vidyut Support', isSupport: true);
      Navigator.of(context).pop();
      return;
    }
    final match = _allSellers(context).firstWhere(
      (s) => s.title.toLowerCase().contains(input.toLowerCase()),
      orElse: () => (id: '', title: '', subtitle: ''),
    );
    if (match.id.isNotEmpty) {
      store.ensureConversation(
          id: match.id, title: match.title, subtitle: match.subtitle);
      Navigator.of(context).pop();
    }
  }
}

class _ConversationList extends ConsumerWidget {
  final VoidCallback? onOpen;
  const _ConversationList({this.onOpen});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final store = ref.watch(messagingStoreProvider);
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
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
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
    } catch (e) {
      return const Center(
        child: Text('Messaging service not available'),
      );
    }
  }
}

class _ConversationView extends ConsumerWidget {
  final VoidCallback? onBack;
  const _ConversationView({this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final store = ref.watch(messagingStoreProvider);
      final conv = store.activeConversation;
      if (conv == null || conv.id.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Ionicons.chatbubble_ellipses_outline,
                  size: 64, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text('Select a conversation to start messaging',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
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
                        color:
                            conv.isSupport ? Colors.white : AppColors.primary,
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
                    ? conv.messages.firstWhere(
                        (e) => e.id == m.replyToMessageId,
                        orElse: () => Message(
                            id: '',
                            conversationId: conv.id,
                            senderType: m.senderType,
                            senderName: '',
                            text: '',
                            sentAt: m.sentAt))
                    : null;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () =>
                        ref.read(messagingStoreProvider).setReplyTo(m),
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
                                        color:
                                            AppColors.primary.withOpacity(0.6),
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
                            _MessageAttachments(attachments: m.attachments),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_formatTime(m.sentAt),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                              if (m.isSending) ...[
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textSecondary.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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
    } catch (e) {
      return const Center(
        child: Text('Messaging service not available'),
      );
    }
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

class _Composer extends ConsumerStatefulWidget {
  const _Composer();
  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final TextEditingController _controller = TextEditingController();
  final MessagingAttachmentService _attachmentService =
      MessagingAttachmentService();
  final MessagingBackendService _backend = MessagingBackendService();
  final List<StagedAttachment> _staged = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _staged.isEmpty) return;

    final store = ref.read(messagingStoreProvider);
    if (store.activeConversationId == null ||
        store.activeConversationId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a conversation first')),
      );
      return;
    }

    final conversationId = store.activeConversationId!;
    final messageId = await _backend.allocateMessageId(conversationId);

    // Show staged as uploading
    setState(() {
      for (int i = 0; i < _staged.length; i++) {
        _staged[i] = _staged[i].copyWith(state: UploadState.uploading, progress: 0.0, errorMessage: null);
      }
    });

    try {
      final uploaded = await _backend.uploadAll(
        conversationId,
        messageId,
        _staged,
        onProgress: (index, p) {
          if (!mounted) return;
          setState(() => _staged[index] = _staged[index].copyWith(progress: p));
        },
        onError: (index, e) {
          if (!mounted) return;
          setState(() => _staged[index] = _staged[index].copyWith(state: UploadState.failed, errorMessage: e));
        },
      );

      // If any failed, surface error and do not write message
      final anyFailed = _staged.any((s) => s.state == UploadState.failed);
      if (anyFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attachment upload failed. Please retry.')),
        );
        return;
      }

      await _backend.writeMessage(
        conversationId,
        messageId,
        text,
        uploaded,
        replyTo: store.replyDraft.messageId,
      );

      // Update local demo store for UI immediacy
      store.sendMessage(text, attachments: uploaded);
      _controller.clear();
      setState(() => _staged.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _pickImages() async {
    final picked = await _attachmentService.pickImages();
    if (!mounted) return;
    setState(() => _staged.addAll(picked));
  }

  Future<void> _pickPdfs() async {
    final picked = await _attachmentService.pickPdfs();
    if (!mounted) return;
    setState(() => _staged.addAll(picked));
  }

  @override
  Widget build(BuildContext context) {
    final reply = ref.watch(messagingStoreProvider).replyDraft;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 72),
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
                        ref.read(messagingStoreProvider).clearReply(),
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
                    .asMap()
                    .entries
                    .map(
                      (entry) => _StagedPreview(
                        item: entry.value,
                        onRemove: () => setState(() => _staged.removeAt(entry.key)),
                        onMoveLeft: entry.key > 0
                            ? () => setState(() {
                                  final i = entry.key;
                                  final tmp = _staged[i - 1];
                                  _staged[i - 1] = _staged[i];
                                  _staged[i] = tmp;
                                })
                            : null,
                        onMoveRight: entry.key < _staged.length - 1
                            ? () => setState(() {
                                  final i = entry.key;
                                  final tmp = _staged[i + 1];
                                  _staged[i + 1] = _staged[i];
                                  _staged[i] = tmp;
                                })
                            : null,
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
                  onPressed: _pickImages,
                  icon: const Icon(Ionicons.image_outline),
                ),
                IconButton(
                  onPressed: _pickPdfs,
                  icon: const Icon(Ionicons.document_outline),
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
                Consumer(
                  builder: (context, ref, child) {
                    final hasActiveConversation = ref
                                .watch(messagingStoreProvider)
                                .activeConversationId !=
                            null &&
                        ref
                            .watch(messagingStoreProvider)
                            .activeConversationId!
                            .isNotEmpty;
                    return IconButton(
                      onPressed: hasActiveConversation ? _send : null,
                      icon: const Icon(Ionicons.send_outline),
                      color: hasActiveConversation
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StagedPreview extends StatelessWidget {
  final StagedAttachment item;
  final VoidCallback onRemove;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;
  const _StagedPreview({
    required this.item,
    required this.onRemove,
    this.onMoveLeft,
    this.onMoveRight,
  });
  @override
  Widget build(BuildContext context) {
    final isImage = item.isImage;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.previewThumbnailBytes != null
              ? Image.memory(
                  item.previewThumbnailBytes!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Icon(
                    isImage ? Ionicons.image_outline : Ionicons.document_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        if (item.state == UploadState.uploading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                value: item.progress > 0 && item.progress < 1
                    ? item.progress
                    : null,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                color: AppColors.primary,
              ),
            ),
          ),
        if (item.state == UploadState.failed)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: Icon(Ionicons.alert_circle_outline,
                    color: Colors.white),
              ),
            ),
          ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black54,
              child: Icon(Ionicons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
        if (onMoveLeft != null)
          Positioned(
            bottom: -10,
            left: 0,
            child: IconButton(
              icon: const Icon(Ionicons.arrow_back_circle_outline, size: 18),
              color: AppColors.textSecondary,
              onPressed: onMoveLeft,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (onMoveRight != null)
          Positioned(
            bottom: -10,
            right: 0,
            child: IconButton(
              icon: const Icon(Ionicons.arrow_forward_circle_outline, size: 18),
              color: AppColors.textSecondary,
              onPressed: onMoveRight,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }
}

class _MessageAttachments extends StatelessWidget {
  final List<Attachment> attachments;
  const _MessageAttachments({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.type == 'image').toList();
    final pdfs = attachments.where((a) => a.type == 'pdf').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          _ImageGrid(
            images: images,
            onTapImage: (index) => _openImageViewer(context, images, index),
          ),
        if (pdfs.isNotEmpty) ...[
          if (images.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pdfs
                .map((a) => GestureDetector(
                      onTap: () => _openPdf(context, a),
                      child: _PdfChip(attachment: a),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  void _openImageViewer(
      BuildContext context, List<Attachment> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImageViewer(images: images, initialIndex: index),
      ),
    );
  }

  void _openPdf(BuildContext context, Attachment a) async {
    // For now, use url_launcher to open; in-app viewer can be added
    if (a.downloadUrl == null || a.downloadUrl!.isEmpty) return;
    // ignore: deprecated_member_use
    launchUrlString(a.downloadUrl!);
  }
}

class _ImageGrid extends StatelessWidget {
  final List<Attachment> images;
  final void Function(int index) onTapImage;
  const _ImageGrid({required this.images, required this.onTapImage});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      final img = images.first;
      return _ImageTile(image: img, onTap: () => onTapImage(0));
    }
    final toShow = images.take(4).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(toShow.length, (i) {
        return _ImageTile(
          image: toShow[i],
          size: 120,
          onTap: () => onTapImage(i),
        );
      }),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Attachment image;
  final double size;
  final VoidCallback onTap;
  const _ImageTile({required this.image, this.size = 200, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final url = image.thumbnailUrl?.isNotEmpty == true
        ? image.thumbnailUrl!
        : (image.downloadUrl ?? '');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover)
            : const Center(child: Icon(Ionicons.image_outline)),
      ),
    );
  }
}

class _PdfChip extends StatelessWidget {
  final Attachment attachment;
  const _PdfChip({required this.attachment});
  @override
  Widget build(BuildContext context) {
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
          const Icon(Ionicons.document_outline,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(attachment.name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  final List<Attachment> images;
  final int initialIndex;
  const _ImageViewer({required this.images, this.initialIndex = 0});
  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (ctx, i) {
          final a = widget.images[i];
          final url = a.downloadUrl ?? a.thumbnailUrl ?? '';
          return Center(
            child: PhotoView(
              imageProvider: NetworkImage(url),
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
            ),
          );
        },
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
