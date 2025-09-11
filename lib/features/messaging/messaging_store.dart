import 'package:flutter/material.dart';
import 'models.dart';
import '../../services/demo_data_service.dart';

class MessagingStore extends ChangeNotifier {
  final DemoDataService _demoDataService;
  String? _activeConversationId;
  ReplyDraft _replyDraft = const ReplyDraft();

  MessagingStore(this._demoDataService) {
    // Listen to demo data changes
    _demoDataService.addListener(_onDemoDataChanged);
  }

  @override
  void dispose() {
    _demoDataService.removeListener(_onDemoDataChanged);
    super.dispose();
  }

  void _onDemoDataChanged() {
    notifyListeners();
  }

  List<Conversation> get conversations {
    final list = [..._demoDataService.allConversations];
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
  Conversation? get activeConversation {
    if (_activeConversationId == null || _activeConversationId!.isEmpty) {
      return null;
    }
    return _demoDataService.getConversation(_activeConversationId!);
  }

  ReplyDraft get replyDraft => _replyDraft;

  // Unread count tracking
  int get unreadCount {
    int total = 0;
    for (final conv in _demoDataService.allConversations) {
      if (conv.id != _activeConversationId) {
        // Count unread messages (messages not sent by me)
        total += conv.messages.where((m) => m.senderType != MessageSenderType.me).length;
      }
    }
    return total;
  }

  // Mark conversation as read (for future use)
  void markConversationAsRead(String conversationId) {
    // In a real app, this would update read status in the backend
    // For now, we'll just notify listeners to refresh the UI
    notifyListeners();
  }

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
    if (_activeConversationId == null || _activeConversationId!.isEmpty) return;
    final conv = _demoDataService.getConversation(_activeConversationId!);
    if (conv == null) return;
    
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conv.id,
      senderType: MessageSenderType.me,
      senderName: 'Me',
      text: text,
      sentAt: DateTime.now(),
      attachments: attachments,
      replyToMessageId: _replyDraft.messageId,
      isSending: true,
    );
    final updated = conv.copyWith(messages: [...conv.messages, msg]);
    _demoDataService.updateConversation(updated);
    _replyDraft = const ReplyDraft();
    
    // Simulate message sending delay and mark as sent
    Future.delayed(const Duration(milliseconds: 500), () {
      final updatedConv = _demoDataService.getConversation(_activeConversationId!);
      if (updatedConv != null) {
        final msgIndex = updatedConv.messages.indexWhere((m) => m.id == msg.id);
        if (msgIndex != -1) {
          final sentMsg = Message(
            id: msg.id,
            conversationId: msg.conversationId,
            senderType: msg.senderType,
            senderName: msg.senderName,
            text: msg.text,
            sentAt: msg.sentAt,
            attachments: msg.attachments,
            replyToMessageId: msg.replyToMessageId,
            isSending: false,
          );
          final updatedMessages = List<Message>.from(updatedConv.messages);
          updatedMessages[msgIndex] = sentMsg;
          final finalConv = updatedConv.copyWith(messages: updatedMessages);
          _demoDataService.updateConversation(finalConv);
        }
      }
    });
  }

  /// Create or select a conversation by id. If missing, it will be created.
  void ensureConversation({
    required String id,
    required String title,
    String subtitle = '',
    bool isSupport = false,
  }) {
    final existing = _demoDataService.getConversation(id);
    if (existing == null) {
      final newConversation = Conversation(
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
      );
      _demoDataService.addConversation(newConversation);
    }
    _activeConversationId = id;
    _replyDraft = const ReplyDraft();
    notifyListeners();
  }

}
