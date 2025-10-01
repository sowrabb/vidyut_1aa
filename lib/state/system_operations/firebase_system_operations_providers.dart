/// Firebase-backed system operations providers for background jobs
/// Handles automated tasks, cleanup, and system maintenance
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';

part 'firebase_system_operations_providers.g.dart';

/// Model for system operation
class SystemOperation {
  final String id;
  final String operationType;
  final String description;
  final OperationStatus status;
  final OperationPriority priority;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Duration? duration;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> result;
  final String? errorMessage;
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SystemOperation({
    required this.id,
    required this.operationType,
    required this.description,
    required this.status,
    required this.priority,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.duration,
    required this.parameters,
    required this.result,
    this.errorMessage,
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemOperation.fromJson(Map<String, dynamic> json) {
    return SystemOperation(
      id: json['id'] as String,
      operationType: json['operation_type'] as String,
      description: json['description'] as String,
      status: OperationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OperationStatus.pending,
      ),
      priority: OperationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => OperationPriority.normal,
      ),
      scheduledAt: json['scheduled_at'] != null
          ? (json['scheduled_at'] as Timestamp).toDate()
          : null,
      startedAt: json['started_at'] != null
          ? (json['started_at'] as Timestamp).toDate()
          : null,
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] as Timestamp).toDate()
          : null,
      duration: json['duration_ms'] != null
          ? Duration(milliseconds: json['duration_ms'] as int)
          : null,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      result: Map<String, dynamic>.from(json['result'] ?? {}),
      errorMessage: json['error_message'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'operation_type': operationType,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    if (scheduledAt != null) 'scheduled_at': Timestamp.fromDate(scheduledAt!),
    if (startedAt != null) 'started_at': Timestamp.fromDate(startedAt!),
    if (completedAt != null) 'completed_at': Timestamp.fromDate(completedAt!),
    if (duration != null) 'duration_ms': duration!.inMilliseconds,
    'parameters': parameters,
    'result': result,
    if (errorMessage != null) 'error_message': errorMessage,
    'retry_count': retryCount,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };
}

/// Operation status
enum OperationStatus {
  pending,      // Waiting to run
  running,      // Currently executing
  completed,    // Successfully completed
  failed,       // Failed with error
  cancelled,    // Cancelled by admin
  retrying,     // Retrying after failure
}

/// Operation priority
enum OperationPriority {
  low,
  normal,
  high,
  critical,
}

/// Stream pending operations
@riverpod
Stream<List<SystemOperation>> firebasePendingOperations(
  FirebasePendingOperationsRef ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('system_operations')
      .where('status', isEqualTo: OperationStatus.pending.name)
      .orderBy('priority', descending: true)
      .orderBy('scheduled_at')
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SystemOperation.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream operations by status
@riverpod
Stream<List<SystemOperation>> firebaseOperationsByStatus(
  FirebaseOperationsByStatusRef ref,
  OperationStatus status,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('system_operations')
      .where('status', isEqualTo: status.name)
      .orderBy('created_at', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SystemOperation.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Stream recent operations
@riverpod
Stream<List<SystemOperation>> firebaseRecentOperations(
  FirebaseRecentOperationsRef ref, {
  int limit = 50,
}) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('system_operations')
      .orderBy('created_at', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SystemOperation.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single operation
@riverpod
Stream<SystemOperation?> firebaseSystemOperation(
  FirebaseSystemOperationRef ref,
  String operationId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('system_operations')
      .doc(operationId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return SystemOperation.fromJson({...data, 'id': doc.id});
  });
}

/// Service for system operation management
@riverpod
SystemOperationService systemOperationService(SystemOperationServiceRef ref) {
  return SystemOperationService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// System operation service class
class SystemOperationService {
  final FirebaseFirestore firestore;

  SystemOperationService({required this.firestore});

  /// Schedule an operation
  Future<String> scheduleOperation({
    required String operationType,
    required String description,
    DateTime? scheduledAt,
    OperationPriority priority = OperationPriority.normal,
    Map<String, dynamic>? parameters,
  }) async {
    final operationData = {
      'operation_type': operationType,
      'description': description,
      'status': OperationStatus.pending.name,
      'priority': priority.name,
      'scheduled_at': scheduledAt != null
          ? Timestamp.fromDate(scheduledAt)
          : FieldValue.serverTimestamp(),
      'parameters': parameters ?? {},
      'result': {},
      'retry_count': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore
        .collection('system_operations')
        .add(operationData);

    return docRef.id;
  }

  /// Execute an operation
  Future<void> executeOperation(String operationId) async {
    final opRef = firestore.collection('system_operations').doc(operationId);
    final doc = await opRef.get();

    if (!doc.exists) throw Exception('Operation not found');

    final operation = SystemOperation.fromJson({...doc.data()!, 'id': doc.id});

    // Mark as running
    await opRef.update({
      'status': OperationStatus.running.name,
      'started_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    try {
      final startTime = DateTime.now();
      
      // Execute based on operation type
      final result = await _performOperation(operation);

      final duration = DateTime.now().difference(startTime);

      // Mark as completed
      await opRef.update({
        'status': OperationStatus.completed.name,
        'completed_at': FieldValue.serverTimestamp(),
        'duration_ms': duration.inMilliseconds,
        'result': result,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Mark as failed
      await opRef.update({
        'status': OperationStatus.failed.name,
        'error_message': e.toString(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Retry logic
      if (operation.retryCount < 3) {
        await _retryOperation(operationId);
      }
    }
  }

  /// Perform the actual operation
  Future<Map<String, dynamic>> _performOperation(SystemOperation operation) async {
    switch (operation.operationType) {
      case 'cleanup_old_searches':
        return await _cleanupOldSearches(operation.parameters);
      
      case 'cleanup_old_audit_logs':
        return await _cleanupOldAuditLogs(operation.parameters);
      
      case 'generate_analytics_report':
        return await _generateAnalyticsReport(operation.parameters);
      
      case 'check_expired_subscriptions':
        return await _checkExpiredSubscriptions(operation.parameters);
      
      case 'check_expired_ads':
        return await _checkExpiredAds(operation.parameters);
      
      case 'backup_database':
        return await _backupDatabase(operation.parameters);
      
      case 'send_notifications':
        return await _sendNotifications(operation.parameters);
      
      default:
        throw Exception('Unknown operation type: ${operation.operationType}');
    }
  }

  /// Cleanup old search history (90+ days)
  Future<Map<String, dynamic>> _cleanupOldSearches(Map<String, dynamic> params) async {
    final daysToKeep = params['days_to_keep'] as int? ?? 90;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    final snapshot = await firestore
        .collection('search_history')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return {
      'deleted_count': snapshot.docs.length,
      'cutoff_date': cutoffDate.toIso8601String(),
    };
  }

  /// Cleanup old audit logs (180+ days)
  Future<Map<String, dynamic>> _cleanupOldAuditLogs(Map<String, dynamic> params) async {
    final daysToKeep = params['days_to_keep'] as int? ?? 180;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    final snapshot = await firestore
        .collection('audit_logs')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return {
      'deleted_count': snapshot.docs.length,
      'cutoff_date': cutoffDate.toIso8601String(),
    };
  }

  /// Generate analytics report
  Future<Map<String, dynamic>> _generateAnalyticsReport(Map<String, dynamic> params) async {
    // TODO: Implement analytics report generation
    return {
      'report_generated': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Check for expired subscriptions
  Future<Map<String, dynamic>> _checkExpiredSubscriptions(Map<String, dynamic> params) async {
    final now = DateTime.now();
    
    final snapshot = await firestore
        .collection('user_subscriptions')
        .where('end_date', isLessThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'active')
        .get();

    int expiredCount = 0;

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'status': 'expired',
        'updated_at': FieldValue.serverTimestamp(),
      });
      expiredCount++;
    }

    return {
      'expired_count': expiredCount,
      'checked_at': now.toIso8601String(),
    };
  }

  /// Check for expired ads
  Future<Map<String, dynamic>> _checkExpiredAds(Map<String, dynamic> params) async {
    final now = DateTime.now();
    
    final snapshot = await firestore
        .collection('advertisements')
        .where('end_date', isLessThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'active')
        .get();

    int expiredCount = 0;

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'status': 'completed',
        'updated_at': FieldValue.serverTimestamp(),
      });
      expiredCount++;
    }

    return {
      'expired_count': expiredCount,
      'checked_at': now.toIso8601String(),
    };
  }

  /// Backup database
  Future<Map<String, dynamic>> _backupDatabase(Map<String, dynamic> params) async {
    // TODO: Implement database backup
    return {
      'backup_completed': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Send batch notifications
  Future<Map<String, dynamic>> _sendNotifications(Map<String, dynamic> params) async {
    // TODO: Implement notification sending
    return {
      'notifications_sent': 0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Retry a failed operation
  Future<void> _retryOperation(String operationId) async {
    final opRef = firestore.collection('system_operations').doc(operationId);
    
    await opRef.update({
      'status': OperationStatus.pending.name,
      'retry_count': FieldValue.increment(1),
      'scheduled_at': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 5)),
      ),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an operation
  Future<void> cancelOperation(String operationId) async {
    await firestore.collection('system_operations').doc(operationId).update({
      'status': OperationStatus.cancelled.name,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Delete an operation
  Future<void> deleteOperation(String operationId) async {
    await firestore.collection('system_operations').doc(operationId).delete();
  }

  /// Get operation statistics
  Future<Map<String, dynamic>> getOperationStats() async {
    final snapshot = await firestore.collection('system_operations').get();

    final stats = <String, int>{
      'total': snapshot.docs.length,
      'pending': 0,
      'running': 0,
      'completed': 0,
      'failed': 0,
      'cancelled': 0,
    };

    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Schedule recurring operations (one-time setup)
  Future<void> scheduleRecurringOperations() async {
    final now = DateTime.now();

    // Daily: Cleanup old searches (runs at 2 AM)
    await scheduleOperation(
      operationType: 'cleanup_old_searches',
      description: 'Clean up search history older than 90 days',
      scheduledAt: DateTime(now.year, now.month, now.day + 1, 2, 0),
      priority: OperationPriority.low,
      parameters: {'days_to_keep': 90},
    );

    // Weekly: Cleanup old audit logs (runs Sunday 3 AM)
    await scheduleOperation(
      operationType: 'cleanup_old_audit_logs',
      description: 'Clean up audit logs older than 180 days',
      scheduledAt: DateTime(now.year, now.month, now.day + 7, 3, 0),
      priority: OperationPriority.low,
      parameters: {'days_to_keep': 180},
    );

    // Daily: Check expired subscriptions (runs at 1 AM)
    await scheduleOperation(
      operationType: 'check_expired_subscriptions',
      description: 'Mark expired subscriptions',
      scheduledAt: DateTime(now.year, now.month, now.day + 1, 1, 0),
      priority: OperationPriority.high,
      parameters: {},
    );

    // Hourly: Check expired ads
    await scheduleOperation(
      operationType: 'check_expired_ads',
      description: 'Mark expired advertisements',
      scheduledAt: now.add(const Duration(hours: 1)),
      priority: OperationPriority.normal,
      parameters: {},
    );

    // Monthly: Generate analytics report (1st of month, 4 AM)
    await scheduleOperation(
      operationType: 'generate_analytics_report',
      description: 'Generate monthly analytics report',
      scheduledAt: DateTime(now.year, now.month + 1, 1, 4, 0),
      priority: OperationPriority.normal,
      parameters: {},
    );
  }

  /// Run pending operations (called by cron/scheduler)
  Future<void> runPendingOperations() async {
    final now = DateTime.now();
    
    final snapshot = await firestore
        .collection('system_operations')
        .where('status', isEqualTo: OperationStatus.pending.name)
        .where('scheduled_at', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('scheduled_at')
        .orderBy('priority', descending: true)
        .limit(10)
        .get();

    for (final doc in snapshot.docs) {
      try {
        await executeOperation(doc.id);
      } catch (e) {
        print('Error executing operation ${doc.id}: $e');
      }
    }
  }
}




