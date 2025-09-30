import 'package:flutter/material.dart';

enum MessageSenderType { me, other, support }

class Attachment {
  final String id;
  final String name;
  final String type; // e.g. 'image', 'pdf'
  final int? sizeBytes;
  final String? storagePath;
  final String? downloadUrl;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final DateTime? createdAt;

  const Attachment({
    required this.id,
    required this.name,
    required this.type,
    this.sizeBytes,
    this.storagePath,
    this.downloadUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.createdAt,
  });

  Attachment copyWith({
    String? id,
    String? name,
    String? type,
    int? sizeBytes,
    String? storagePath,
    String? downloadUrl,
    String? thumbnailUrl,
    int? width,
    int? height,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
      if (storagePath != null) 'storagePath': storagePath,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'file',
      sizeBytes: json['sizeBytes'] is int
          ? json['sizeBytes'] as int
          : (json['sizeBytes'] is num
              ? (json['sizeBytes'] as num).toInt()
              : null),
      storagePath: json['storagePath'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: json['width'] is int
          ? json['width'] as int
          : (json['width'] is num ? (json['width'] as num).toInt() : null),
      height: json['height'] is int
          ? json['height'] as int
          : (json['height'] is num ? (json['height'] as num).toInt() : null),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
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
  final bool isSending;
  final bool isRead;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.attachments = const [],
    this.replyToMessageId,
    this.isSending = false,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderType': senderType.name,
        'senderName': senderName,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'replyToMessageId': replyToMessageId,
        'isSending': isSending,
        'isRead': isRead,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String? ?? '',
        conversationId: json['conversationId'] as String? ?? '',
        senderType: MessageSenderType.values.firstWhere(
          (e) => e.name == json['senderType'],
          orElse: () => MessageSenderType.me,
        ),
        senderName: json['senderName'] as String? ?? '',
        text: json['text'] as String? ?? '',
        sentAt: DateTime.parse(json['sentAt'] as String),
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        replyToMessageId: json['replyToMessageId'] as String?,
        isSending: json['isSending'] as bool? ?? false,
        isRead: json['isRead'] as bool? ?? false,
      );
}

class Conversation {
  final String id;
  final String title;
  final String subtitle;
  final bool isPinned;
  final bool isSupport;
  final List<Message> messages;
  final List<String> participants;
  final DateTime updatedAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isPinned,
    required this.isSupport,
    required this.messages,
    required this.participants,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isPinned,
    bool? isSupport,
    List<Message>? messages,
    List<String>? participants,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isPinned: isPinned ?? this.isPinned,
      isSupport: isSupport ?? this.isSupport,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isPinned': isPinned,
        'isSupport': isSupport,
        'messages': messages.map((m) => m.toJson()).toList(),
        'participants': participants,
        'updatedAt': updatedAt.toIso8601String(),
        'unreadCount': unreadCount,
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        isPinned: json['isPinned'] as bool? ?? false,
        isSupport: json['isSupport'] as bool? ?? false,
        messages: (json['messages'] as List<dynamic>?)
                ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        participants: List<String>.from(json['participants'] ?? []),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        unreadCount: json['unreadCount'] as int? ?? 0,
      );
}

@immutable
class ReplyDraft {
  final String? messageId;
  final String? previewText;

  const ReplyDraft({this.messageId, this.previewText});

  bool get isActive => messageId != null;
}
