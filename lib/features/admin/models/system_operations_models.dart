/// System Operations & Audit Logs Models
library;

class SystemMaintenance {
  final String id;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String message;
  final List<String> affectedServices;
  final Map<String, dynamic> metadata;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SystemMaintenance({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.message,
    required this.affectedServices,
    required this.metadata,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemMaintenance.fromJson(Map<String, dynamic> json) =>
      SystemMaintenance(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: MaintenanceStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => MaintenanceStatus.scheduled,
        ),
        scheduledStart: DateTime.parse(json['scheduled_start'] as String),
        scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
        actualStart: json['actual_start'] != null
            ? DateTime.parse(json['actual_start'] as String)
            : null,
        actualEnd: json['actual_end'] != null
            ? DateTime.parse(json['actual_end'] as String)
            : null,
        message: json['message'] as String,
        affectedServices: List<String>.from(json['affected_services'] ?? []),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'scheduled_start': scheduledStart.toIso8601String(),
        'scheduled_end': scheduledEnd.toIso8601String(),
        'actual_start': actualStart?.toIso8601String(),
        'actual_end': actualEnd?.toIso8601String(),
        'message': message,
        'affected_services': affectedServices,
        'metadata': metadata,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

enum MaintenanceStatus {
  scheduled('scheduled'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  failed('failed');

  const MaintenanceStatus(this.value);
  final String value;
}

class BackupJob {
  final String id;
  final String backupType;
  final String database;
  final BackupStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? filePath;
  final int fileSizeBytes;
  final String? error;
  final Map<String, dynamic> metadata;
  final String createdBy;

  BackupJob({
    required this.id,
    required this.backupType,
    required this.database,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.filePath,
    required this.fileSizeBytes,
    this.error,
    required this.metadata,
    required this.createdBy,
  });

  factory BackupJob.fromJson(Map<String, dynamic> json) => BackupJob(
        id: json['id'] as String,
        backupType: json['backup_type'] as String,
        database: json['database'] as String,
        status: BackupStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => BackupStatus.pending,
        ),
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        filePath: json['file_path'] as String?,
        fileSizeBytes: json['file_size_bytes'] as int,
        error: json['error'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'backup_type': backupType,
        'database': database,
        'status': status.value,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'file_path': filePath,
        'file_size_bytes': fileSizeBytes,
        'error': error,
        'metadata': metadata,
        'created_by': createdBy,
      };
}

enum BackupStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const BackupStatus(this.value);
  final String value;
}

class RestoreJob {
  final String id;
  final String backupId;
  final String database;
  final RestoreStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic> metadata;
  final String createdBy;

  RestoreJob({
    required this.id,
    required this.backupId,
    required this.database,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.error,
    required this.metadata,
    required this.createdBy,
  });

  factory RestoreJob.fromJson(Map<String, dynamic> json) => RestoreJob(
        id: json['id'] as String,
        backupId: json['backup_id'] as String,
        database: json['database'] as String,
        status: RestoreStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => RestoreStatus.pending,
        ),
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        error: json['error'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'backup_id': backupId,
        'database': database,
        'status': status.value,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'metadata': metadata,
        'created_by': createdBy,
      };
}

enum RestoreStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const RestoreStatus(this.value);
  final String value;
}

class SystemHealthCheck {
  final String id;
  final String serviceName;
  final HealthStatus status;
  final double responseTime;
  final String? error;
  final Map<String, dynamic> metrics;
  final DateTime checkedAt;

  SystemHealthCheck({
    required this.id,
    required this.serviceName,
    required this.status,
    required this.responseTime,
    this.error,
    required this.metrics,
    required this.checkedAt,
  });

  factory SystemHealthCheck.fromJson(Map<String, dynamic> json) =>
      SystemHealthCheck(
        id: json['id'] as String,
        serviceName: json['service_name'] as String,
        status: HealthStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => HealthStatus.healthy,
        ),
        responseTime: (json['response_time'] as num).toDouble(),
        error: json['error'] as String?,
        metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
        checkedAt: DateTime.parse(json['checked_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_name': serviceName,
        'status': status.value,
        'response_time': responseTime,
        'error': error,
        'metrics': metrics,
        'checked_at': checkedAt.toIso8601String(),
      };
}

enum HealthStatus {
  healthy('healthy'),
  degraded('degraded'),
  unhealthy('unhealthy'),
  unknown('unknown');

  const HealthStatus(this.value);
  final String value;
}

class TemplateLifecycle {
  final String id;
  final String templateName;
  final String templateType;
  final TemplateStatus status;
  final String version;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? deprecatedAt;
  final DateTime? deletedAt;
  final String createdBy;
  final String? publishedBy;
  final String? deprecatedBy;
  final String? deletedBy;
  final Map<String, dynamic> metadata;

  TemplateLifecycle({
    required this.id,
    required this.templateName,
    required this.templateType,
    required this.status,
    required this.version,
    required this.createdAt,
    this.publishedAt,
    this.deprecatedAt,
    this.deletedAt,
    required this.createdBy,
    this.publishedBy,
    this.deprecatedBy,
    this.deletedBy,
    required this.metadata,
  });

  factory TemplateLifecycle.fromJson(Map<String, dynamic> json) =>
      TemplateLifecycle(
        id: json['id'] as String,
        templateName: json['template_name'] as String,
        templateType: json['template_type'] as String,
        status: TemplateStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => TemplateStatus.draft,
        ),
        version: json['version'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        publishedAt: json['published_at'] != null
            ? DateTime.parse(json['published_at'] as String)
            : null,
        deprecatedAt: json['deprecated_at'] != null
            ? DateTime.parse(json['deprecated_at'] as String)
            : null,
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
        createdBy: json['created_by'] as String,
        publishedBy: json['published_by'] as String?,
        deprecatedBy: json['deprecated_by'] as String?,
        deletedBy: json['deleted_by'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_name': templateName,
        'template_type': templateType,
        'status': status.value,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'published_at': publishedAt?.toIso8601String(),
        'deprecated_at': deprecatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'created_by': createdBy,
        'published_by': publishedBy,
        'deprecated_by': deprecatedBy,
        'deleted_by': deletedBy,
        'metadata': metadata,
      };
}

enum TemplateStatus {
  draft('draft'),
  published('published'),
  deprecated('deprecated'),
  deleted('deleted');

  const TemplateStatus(this.value);
  final String value;
}

class SystemAuditLog {
  final String id;
  final String actor;
  final String actorType;
  final String action;
  final String resourceType;
  final String resourceId;
  final Map<String, dynamic> changes;
  final String ipAddress;
  final String userAgent;
  final String sessionId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SystemAuditLog({
    required this.id,
    required this.actor,
    required this.actorType,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.changes,
    required this.ipAddress,
    required this.userAgent,
    required this.sessionId,
    required this.timestamp,
    required this.metadata,
  });

  factory SystemAuditLog.fromJson(Map<String, dynamic> json) => SystemAuditLog(
        id: json['id'] as String,
        actor: json['actor'] as String,
        actorType: json['actor_type'] as String,
        action: json['action'] as String,
        resourceType: json['resource_type'] as String,
        resourceId: json['resource_id'] as String,
        changes: Map<String, dynamic>.from(json['changes'] ?? {}),
        ipAddress: json['ip_address'] as String,
        userAgent: json['user_agent'] as String,
        sessionId: json['session_id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actor': actor,
        'actor_type': actorType,
        'action': action,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'changes': changes,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'session_id': sessionId,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

class BulkOperation {
  final String id;
  final String operationType;
  final BulkOperationStatus status;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic> metadata;
  final String createdBy;

  BulkOperation({
    required this.id,
    required this.operationType,
    required this.status,
    required this.totalItems,
    required this.processedItems,
    required this.failedItems,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.error,
    required this.metadata,
    required this.createdBy,
  });

  factory BulkOperation.fromJson(Map<String, dynamic> json) => BulkOperation(
        id: json['id'] as String,
        operationType: json['operation_type'] as String,
        status: BulkOperationStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => BulkOperationStatus.pending,
        ),
        totalItems: json['total_items'] as int,
        processedItems: json['processed_items'] as int,
        failedItems: json['failed_items'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        error: json['error'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation_type': operationType,
        'status': status.value,
        'total_items': totalItems,
        'processed_items': processedItems,
        'failed_items': failedItems,
        'created_at': createdAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'metadata': metadata,
        'created_by': createdBy,
      };
}

enum BulkOperationStatus {
  pending('pending'),
  running('running'),
  paused('paused'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const BulkOperationStatus(this.value);
  final String value;
}

class DataExport {
  final String id;
  final String exportType;
  final String dataScope;
  final DataExportStatus status;
  final String? downloadUrl;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic> metadata;
  final String createdBy;

  DataExport({
    required this.id,
    required this.exportType,
    required this.dataScope,
    required this.status,
    this.downloadUrl,
    this.expiresAt,
    required this.createdAt,
    this.completedAt,
    this.error,
    required this.metadata,
    required this.createdBy,
  });

  factory DataExport.fromJson(Map<String, dynamic> json) => DataExport(
        id: json['id'] as String,
        exportType: json['export_type'] as String,
        dataScope: json['data_scope'] as String,
        status: DataExportStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => DataExportStatus.pending,
        ),
        downloadUrl: json['download_url'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        error: json['error'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'export_type': exportType,
        'data_scope': dataScope,
        'status': status.value,
        'download_url': downloadUrl,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'metadata': metadata,
        'created_by': createdBy,
      };
}

enum DataExportStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  expired('expired');

  const DataExportStatus(this.value);
  final String value;
}

// Request/Response Models

class CreateMaintenanceRequest {
  final String title;
  final String description;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String message;
  final List<String> affectedServices;

  CreateMaintenanceRequest({
    required this.title,
    required this.description,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.message,
    required this.affectedServices,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'scheduled_start': scheduledStart.toIso8601String(),
        'scheduled_end': scheduledEnd.toIso8601String(),
        'message': message,
        'affected_services': affectedServices,
      };
}

class CreateBackupRequest {
  final String backupType;
  final String database;
  final bool incremental;

  CreateBackupRequest({
    required this.backupType,
    required this.database,
    required this.incremental,
  });

  Map<String, dynamic> toJson() => {
        'backup_type': backupType,
        'database': database,
        'incremental': incremental,
      };
}

class CreateRestoreRequest {
  final String backupId;
  final String database;
  final bool force;

  CreateRestoreRequest({
    required this.backupId,
    required this.database,
    required this.force,
  });

  Map<String, dynamic> toJson() => {
        'backup_id': backupId,
        'database': database,
        'force': force,
      };
}

class CreateDataExportRequest {
  final String exportType;
  final String dataScope;
  final List<String> columns;
  final Map<String, dynamic> filters;

  CreateDataExportRequest({
    required this.exportType,
    required this.dataScope,
    required this.columns,
    required this.filters,
  });

  Map<String, dynamic> toJson() => {
        'export_type': exportType,
        'data_scope': dataScope,
        'columns': columns,
        'filters': filters,
      };
}

class SystemMaintenanceListResponse {
  final List<SystemMaintenance> maintenances;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  SystemMaintenanceListResponse({
    required this.maintenances,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory SystemMaintenanceListResponse.fromJson(Map<String, dynamic> json) =>
      SystemMaintenanceListResponse(
        maintenances: (json['maintenances'] as List)
            .map((m) => SystemMaintenance.fromJson(m))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class BackupJobListResponse {
  final List<BackupJob> backups;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  BackupJobListResponse({
    required this.backups,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory BackupJobListResponse.fromJson(Map<String, dynamic> json) =>
      BackupJobListResponse(
        backups: (json['backups'] as List)
            .map((b) => BackupJob.fromJson(b))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class SystemAuditLogListResponse {
  final List<SystemAuditLog> logs;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  SystemAuditLogListResponse({
    required this.logs,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory SystemAuditLogListResponse.fromJson(Map<String, dynamic> json) =>
      SystemAuditLogListResponse(
        logs: (json['logs'] as List)
            .map((l) => SystemAuditLog.fromJson(l))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class BulkOperationListResponse {
  final List<BulkOperation> operations;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  BulkOperationListResponse({
    required this.operations,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory BulkOperationListResponse.fromJson(Map<String, dynamic> json) =>
      BulkOperationListResponse(
        operations: (json['operations'] as List)
            .map((o) => BulkOperation.fromJson(o))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class SystemHealthSummary {
  final Map<String, SystemHealthCheck> services;
  final HealthStatus overallStatus;
  final DateTime lastChecked;
  final Map<String, dynamic> summary;

  SystemHealthSummary({
    required this.services,
    required this.overallStatus,
    required this.lastChecked,
    required this.summary,
  });

  factory SystemHealthSummary.fromJson(Map<String, dynamic> json) =>
      SystemHealthSummary(
        services: Map<String, SystemHealthCheck>.from(json['services']
            .map((k, v) => MapEntry(k, SystemHealthCheck.fromJson(v)))),
        overallStatus: HealthStatus.values.firstWhere(
          (e) => e.value == json['overall_status'],
          orElse: () => HealthStatus.healthy,
        ),
        lastChecked: DateTime.parse(json['last_checked'] as String),
        summary: Map<String, dynamic>.from(json['summary'] ?? {}),
      );
}
