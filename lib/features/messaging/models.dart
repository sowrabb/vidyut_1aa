import 'package:flutter/material.dart';

enum MessageSenderType { me, other, support }

class Attachment {
  final String id;
  final String name;
  final String type; // e.g. 'image', 'pdf', 'file'

  const Attachment({required this.id, required this.name, required this.type});
}

class Message {
  final String id;
  final String conversationId;
  final MessageSenderType senderType;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final List<Attachment> attachments;
  final String? replyToMessageId;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.attachments = const [],
    this.replyToMessageId,
  });
}

class Conversation {
  final String id;
  final String title;
  final String subtitle;
  final bool isPinned;
  final bool isSupport;
  final List<Message> messages;

  const Conversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isPinned,
    required this.isSupport,
    required this.messages,
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isPinned,
    bool? isSupport,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isPinned: isPinned ?? this.isPinned,
      isSupport: isSupport ?? this.isSupport,
      messages: messages ?? this.messages,
    );
  }
}

@immutable
class ReplyDraft {
  final String? messageId;
  final String? previewText;

  const ReplyDraft({this.messageId, this.previewText});

  bool get isActive => messageId != null;
}
