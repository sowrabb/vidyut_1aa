import 'package:flutter/foundation.dart';

enum NotificationChannel { inApp, push, email, sms }

enum NotificationType { broadcast, segmented, oneToOne }

@immutable
class AudienceFilter {
  final Set<String> roles; // e.g., seller, buyer, admin
  final Set<String> states; // state names
  final Set<String> userIds; // explicit users
  final bool? isSeller; // optional quick toggle

  const AudienceFilter({
    this.roles = const {},
    this.states = const {},
    this.userIds = const {},
    this.isSeller,
  });

  AudienceFilter copyWith({
    Set<String>? roles,
    Set<String>? states,
    Set<String>? userIds,
    bool? isSeller,
  }) =>
      AudienceFilter(
        roles: roles ?? this.roles,
        states: states ?? this.states,
        userIds: userIds ?? this.userIds,
        isSeller: isSeller ?? this.isSeller,
      );

  Map<String, dynamic> toJson() => {
        'roles': roles.toList(),
        'states': states.toList(),
        'userIds': userIds.toList(),
        'isSeller': isSeller,
      };

  factory AudienceFilter.fromJson(Map<String, dynamic> json) => AudienceFilter(
        roles: {...(json['roles'] as List? ?? const [])}.cast<String>(),
        states: {...(json['states'] as List? ?? const [])}.cast<String>(),
        userIds: {...(json['userIds'] as List? ?? const [])}.cast<String>(),
        isSeller: json['isSeller'] as bool?,
      );
}

@immutable
class NotificationTemplate {
  final String id;
  final String name;
  final NotificationChannel channel;
  final String title; // for push/email/in-app
  final String body; // supports simple variables like {{name}}

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.channel,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'channel': channel.name,
        'title': title,
        'body': body,
      };

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      NotificationTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        channel: NotificationChannel.values
            .firstWhere((e) => e.name == json['channel']),
        title: json['title'] as String,
        body: json['body'] as String,
      );
}

@immutable
class NotificationDraft {
  final String id;
  final NotificationType type;
  final Set<NotificationChannel> channels;
  final AudienceFilter audience;
  final Map<NotificationChannel, NotificationTemplate> templates;
  final DateTime? scheduledAt; // null => send now
  final bool respectQuietHours;

  const NotificationDraft({
    required this.id,
    required this.type,
    required this.channels,
    required this.audience,
    required this.templates,
    this.scheduledAt,
    this.respectQuietHours = true,
  });

  NotificationDraft copyWith({
    NotificationType? type,
    Set<NotificationChannel>? channels,
    AudienceFilter? audience,
    Map<NotificationChannel, NotificationTemplate>? templates,
    DateTime? scheduledAt,
    bool? respectQuietHours,
  }) =>
      NotificationDraft(
        id: id,
        type: type ?? this.type,
        channels: channels ?? this.channels,
        audience: audience ?? this.audience,
        templates: templates ?? this.templates,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        respectQuietHours: respectQuietHours ?? this.respectQuietHours,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'channels': channels.map((c) => c.name).toList(),
        'audience': audience.toJson(),
        'templates': {
          for (final e in templates.entries) e.key.name: e.value.toJson(),
        },
        'scheduledAt': scheduledAt?.toIso8601String(),
        'respectQuietHours': respectQuietHours,
      };

  factory NotificationDraft.fromJson(Map<String, dynamic> json) =>
      NotificationDraft(
        id: json['id'] as String,
        type: NotificationType.values.firstWhere((e) => e.name == json['type']),
        channels: {...(json['channels'] as List? ?? const [])}
            .map((e) =>
                NotificationChannel.values.firstWhere((c) => c.name == e))
            .toSet(),
        audience:
            AudienceFilter.fromJson(json['audience'] as Map<String, dynamic>),
        templates: {
          for (final entry
              in (json['templates'] as Map<String, dynamic>? ?? const {})
                  .entries)
            NotificationChannel.values.firstWhere((c) => c.name == entry.key):
                NotificationTemplate.fromJson(
                    entry.value as Map<String, dynamic>)
        },
        scheduledAt: (json['scheduledAt'] as String?) != null
            ? DateTime.parse(json['scheduledAt'] as String)
            : null,
        respectQuietHours: (json['respectQuietHours'] as bool?) ?? true,
      );
}

/// Notification Send Result
@immutable
class NotificationSendResult {
  final int sentCount;
  final int failedCount;
  final String? jobId;
  final String? error;

  const NotificationSendResult({
    required this.sentCount,
    required this.failedCount,
    this.jobId,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'sent_count': sentCount,
        'failed_count': failedCount,
        if (jobId != null) 'job_id': jobId,
        if (error != null) 'error': error,
      };

  factory NotificationSendResult.fromJson(Map<String, dynamic> json) =>
      NotificationSendResult(
        sentCount: json['sent_count'] as int,
        failedCount: json['failed_count'] as int,
        jobId: json['job_id'] as String?,
        error: json['error'] as String?,
      );
}
