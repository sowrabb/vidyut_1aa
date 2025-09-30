// Notification Service with StateNotifierProvider for reactive notifications
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'success', 'warning', 'error', 'system'
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? userId; // null for global notifications

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'createdAt': Timestamp.fromDate(createdAt),
        'isRead': isRead,
        'userId': userId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        type: json['type'],
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : null,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        isRead: json['isRead'] ?? false,
        userId: json['userId'],
      );

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? userId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }
}

/// Notification state
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notification Service with StateNotifierProvider
class NotificationService extends StateNotifier<NotificationState> {
  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const NotificationState()) {
    _initializeNotifications();
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  /// Initialize notifications stream
  void _initializeNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _notificationsSubscription = _getNotificationsStream(userId).listen(
      (notifications) {
        state = state.copyWith(
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  /// Get notifications stream for user
  Stream<List<AppNotification>> _getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final unreadNotifications = state.notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        final docRef =
            _firestore.collection('notifications').doc(notification.id);
        batch.update(docRef, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final notifications = state.notifications;

      for (final notification in notifications) {
        final docRef =
            _firestore.collection('notifications').doc(notification.id);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear all notifications: $e');
    }
  }

  /// Send local notification (for immediate feedback)
  void showLocalNotification({
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      data: data,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final updatedNotifications = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: updatedNotifications.where((n) => !n.isRead).length,
    );
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<AppNotification> get unreadNotifications {
    return state.notifications.where((n) => !n.isRead).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<AppNotification> get recentNotifications {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    return state.notifications
        .where((n) => n.createdAt.isAfter(yesterday))
        .toList();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    state = state.copyWith(isLoading: true);
    _initializeNotifications();
  }
}
