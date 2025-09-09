import 'package:flutter/material.dart';
import 'models.dart';

class MessagingStore extends ChangeNotifier {
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  ReplyDraft _replyDraft = const ReplyDraft();

  MessagingStore() {
    _seed();
  }

  List<Conversation> get conversations {
    final list = [..._conversations];
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      final aTime = a.messages.isNotEmpty
          ? a.messages.last.sentAt
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.messages.isNotEmpty
          ? b.messages.last.sentAt
          : DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  String? get activeConversationId => _activeConversationId;
  Conversation? get activeConversation =>
      _conversations.firstWhere((c) => c.id == _activeConversationId,
          orElse: () => _conversations.isNotEmpty
              ? _conversations.first
              : const Conversation(
                  id: '',
                  title: '',
                  subtitle: '',
                  isPinned: false,
                  isSupport: false,
                  messages: []));

  ReplyDraft get replyDraft => _replyDraft;

  void selectConversation(String conversationId) {
    _activeConversationId = conversationId;
    _replyDraft = const ReplyDraft();
    notifyListeners();
  }

  void setReplyTo(Message message) {
    _replyDraft = ReplyDraft(messageId: message.id, previewText: message.text);
    notifyListeners();
  }

  void clearReply() {
    _replyDraft = const ReplyDraft();
    notifyListeners();
  }

  void sendMessage(String text, {List<Attachment> attachments = const []}) {
    if (_activeConversationId == null) return;
    final idx = _conversations.indexWhere((c) => c.id == _activeConversationId);
    if (idx == -1) return;
    final conv = _conversations[idx];
    final msg = Message(
      id: UniqueKey().toString(),
      conversationId: conv.id,
      senderType: MessageSenderType.me,
      senderName: 'Me',
      text: text,
      sentAt: DateTime.now(),
      attachments: attachments,
      replyToMessageId: _replyDraft.messageId,
    );
    final updated = conv.copyWith(messages: [...conv.messages, msg]);
    _conversations[idx] = updated;
    _replyDraft = const ReplyDraft();
    notifyListeners();
  }

  /// Create or select a conversation by id. If missing, it will be created.
  void ensureConversation({
    required String id,
    required String title,
    String subtitle = '',
    bool isSupport = false,
  }) {
    final existingIndex = _conversations.indexWhere((c) => c.id == id);
    if (existingIndex == -1) {
      _conversations.add(Conversation(
        id: id,
        title: title,
        subtitle: subtitle,
        isPinned: isSupport,
        isSupport: isSupport,
        messages: [
          if (isSupport)
            Message(
              id: UniqueKey().toString(),
              conversationId: id,
              senderType: MessageSenderType.support,
              senderName: 'Support',
              text: 'Hi! How can we help?',
              sentAt: DateTime.now(),
            ),
        ],
      ));
    }
    _activeConversationId = id;
    _replyDraft = const ReplyDraft();
    notifyListeners();
  }

  void _seed() {
    final support = Conversation(
      id: 'support',
      title: 'Vidyut Support',
      subtitle: 'We are here to help',
      isPinned: true,
      isSupport: true,
      messages: [
        Message(
          id: 'm1',
          conversationId: 'support',
          senderType: MessageSenderType.support,
          senderName: 'Support',
          text: 'Hello! How can we assist you today?',
          sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    );

    final chat1 = Conversation(
      id: 'c1',
      title: 'Acme Traders',
      subtitle: 'B2B Partner',
      isPinned: false,
      isSupport: false,
      messages: [
        Message(
          id: 'm2',
          conversationId: 'c1',
          senderType: MessageSenderType.other,
          senderName: 'Anita',
          text: 'Can you share the latest price list?',
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          id: 'm3',
          conversationId: 'c1',
          senderType: MessageSenderType.me,
          senderName: 'Me',
          text: 'Sure, attaching here.',
          sentAt:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          attachments: const [
            Attachment(id: 'a1', name: 'price-list.pdf', type: 'pdf')
          ],
        ),
      ],
    );

    _conversations.addAll([support, chat1]);
    _activeConversationId = support.id;
  }
}
