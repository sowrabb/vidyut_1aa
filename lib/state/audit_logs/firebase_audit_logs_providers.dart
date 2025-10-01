/// Firebase-backed audit logs providers for compliance and monitoring
/// Tracks all admin and critical user actions for security and debugging
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_audit_logs_providers.g.dart';

/// Model for audit log entry
class AuditLogEntry {
  final String id;
  final String action;
  final String entityType;
  final String? entityId;
  final String userId;
  final String? userName;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.userId,
    this.userName,
    required this.details,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
    );
  }
}

/// Stream recent audit logs (admin only)
@riverpod
Stream<List<AuditLogEntry>> firebaseRecentAuditLogs(
  FirebaseRecentAuditLogsRef ref, {
  int limit = 50,
}) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('audit_logs')
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AuditLogEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream audit logs by entity (e.g., all logs for a specific product)
@riverpod
Stream<List<AuditLogEntry>> firebaseEntityAuditLogs(
  FirebaseEntityAuditLogsRef ref,
  String entityType,
  String entityId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('audit_logs')
      .where('entity_type', isEqualTo: entityType)
      .where('entity_id', isEqualTo: entityId)
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AuditLogEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream audit logs by user (track what a specific user did)
@riverpod
Stream<List<AuditLogEntry>> firebaseUserAuditLogs(
  FirebaseUserAuditLogsRef ref,
  String userId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('audit_logs')
      .where('user_id', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AuditLogEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Service for audit log operations
@riverpod
AuditLogService auditLogService(AuditLogServiceRef ref) {
  return AuditLogService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
    getCurrentUserName: () => ref.read(sessionControllerProvider).displayName ?? 'Unknown',
  );
}

/// Audit log service class
class AuditLogService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;
  final String? Function() getCurrentUserName;

  AuditLogService({
    required this.firestore,
    required this.getCurrentUserId,
    required this.getCurrentUserName,
  });

  /// Log an action
  Future<void> log({
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return; // Don't log anonymous actions

    final logData = {
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'user_id': userId,
      'user_name': getCurrentUserName(),
      'details': details ?? {},
      'timestamp': FieldValue.serverTimestamp(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };

    await firestore.collection('audit_logs').add(logData);
  }

  /// Convenience methods for common actions
  Future<void> logCreate(String entityType, String entityId, Map<String, dynamic>? details) {
    return log(
      action: 'create',
      entityType: entityType,
      entityId: entityId,
      details: details,
    );
  }

  Future<void> logUpdate(String entityType, String entityId, Map<String, dynamic>? details) {
    return log(
      action: 'update',
      entityType: entityType,
      entityId: entityId,
      details: details,
    );
  }

  Future<void> logDelete(String entityType, String entityId) {
    return log(
      action: 'delete',
      entityType: entityType,
      entityId: entityId,
    );
  }

  Future<void> logView(String entityType, String entityId) {
    return log(
      action: 'view',
      entityType: entityType,
      entityId: entityId,
    );
  }

  Future<void> logLogin() {
    return log(
      action: 'login',
      entityType: 'auth',
    );
  }

  Future<void> logLogout() {
    return log(
      action: 'logout',
      entityType: 'auth',
    );
  }

  /// Search audit logs by action
  Future<List<AuditLogEntry>> searchByAction(String action, {int limit = 50}) async {
    final snapshot = await firestore
        .collection('audit_logs')
        .where('action', isEqualTo: action)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AuditLogEntry.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Get audit log statistics
  Future<Map<String, int>> getStatistics() async {
    // Get last 24 hours of logs
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    
    final snapshot = await firestore
        .collection('audit_logs')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(yesterday))
        .get();

    final stats = <String, int>{
      'total': snapshot.docs.length,
      'creates': 0,
      'updates': 0,
      'deletes': 0,
      'views': 0,
      'logins': 0,
    };

    for (final doc in snapshot.docs) {
      final action = doc.data()['action'] as String?;
      if (action != null) {
        final key = '${action}s'; // create -> creates
        stats[key] = (stats[key] ?? 0) + 1;
      }
    }

    return stats;
  }
}

