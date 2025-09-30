/// Compliance & Data Governance Models
library;

class DataRetentionPolicy {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> rules;
  final RetentionAction action;
  final int retentionPeriodDays;
  final List<String> dataTypes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  DataRetentionPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    required this.action,
    required this.retentionPeriodDays,
    required this.dataTypes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) =>
      DataRetentionPolicy(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        rules: Map<String, dynamic>.from(json['rules'] ?? {}),
        action: RetentionAction.values.firstWhere(
          (e) => e.value == json['action'],
          orElse: () => RetentionAction.delete,
        ),
        retentionPeriodDays: json['retention_period_days'] as int,
        dataTypes: List<String>.from(json['data_types'] ?? []),
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rules': rules,
        'action': action.value,
        'retention_period_days': retentionPeriodDays,
        'data_types': dataTypes,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
      };
}

enum RetentionAction {
  delete('delete'),
  archive('archive'),
  anonymize('anonymize'),
  redact('redact');

  const RetentionAction(this.value);
  final String value;
}

class PIIField {
  final String id;
  final String name;
  final String description;
  final PIIFieldType type;
  final String tableName;
  final String columnName;
  final PIILevel sensitivityLevel;
  final bool isRequired;
  final Map<String, dynamic> maskingRules;
  final DateTime createdAt;
  final DateTime updatedAt;

  PIIField({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tableName,
    required this.columnName,
    required this.sensitivityLevel,
    required this.isRequired,
    required this.maskingRules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PIIField.fromJson(Map<String, dynamic> json) => PIIField(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: PIIFieldType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => PIIFieldType.email,
        ),
        tableName: json['table_name'] as String,
        columnName: json['column_name'] as String,
        sensitivityLevel: PIILevel.values.firstWhere(
          (e) => e.value == json['sensitivity_level'],
          orElse: () => PIILevel.public,
        ),
        isRequired: json['is_required'] as bool,
        maskingRules: Map<String, dynamic>.from(json['masking_rules'] ?? {}),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.value,
        'table_name': tableName,
        'column_name': columnName,
        'sensitivity_level': sensitivityLevel.value,
        'is_required': isRequired,
        'masking_rules': maskingRules,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

enum PIIFieldType {
  email('email'),
  phone('phone'),
  ssn('ssn'),
  creditCard('credit_card'),
  address('address'),
  name('name'),
  dateOfBirth('date_of_birth'),
  other('other');

  const PIIFieldType(this.value);
  final String value;
}

enum PIILevel {
  public('public'),
  internal('internal'),
  confidential('confidential'),
  restricted('restricted');

  const PIILevel(this.value);
  final String value;
}

class DataExportRequest {
  final String id;
  final String userId;
  final String requestType;
  final DataExportStatus status;
  final Map<String, dynamic> dataScope;
  final List<String> dataTypes;
  final String? downloadUrl;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic> metadata;

  DataExportRequest({
    required this.id,
    required this.userId,
    required this.requestType,
    required this.status,
    required this.dataScope,
    required this.dataTypes,
    this.downloadUrl,
    this.expiresAt,
    required this.createdAt,
    this.completedAt,
    this.error,
    required this.metadata,
  });

  factory DataExportRequest.fromJson(Map<String, dynamic> json) =>
      DataExportRequest(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        requestType: json['request_type'] as String,
        status: DataExportStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => DataExportStatus.pending,
        ),
        dataScope: Map<String, dynamic>.from(json['data_scope'] ?? {}),
        dataTypes: List<String>.from(json['data_types'] ?? []),
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
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'request_type': requestType,
        'status': status.value,
        'data_scope': dataScope,
        'data_types': dataTypes,
        'download_url': downloadUrl,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'metadata': metadata,
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

class DataDeletionRequest {
  final String id;
  final String userId;
  final String requestType;
  final DataDeletionStatus status;
  final Map<String, dynamic> dataScope;
  final List<String> dataTypes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic> metadata;

  DataDeletionRequest({
    required this.id,
    required this.userId,
    required this.requestType,
    required this.status,
    required this.dataScope,
    required this.dataTypes,
    required this.createdAt,
    this.completedAt,
    this.error,
    required this.metadata,
  });

  factory DataDeletionRequest.fromJson(Map<String, dynamic> json) =>
      DataDeletionRequest(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        requestType: json['request_type'] as String,
        status: DataDeletionStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => DataDeletionStatus.pending,
        ),
        dataScope: Map<String, dynamic>.from(json['data_scope'] ?? {}),
        dataTypes: List<String>.from(json['data_types'] ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        error: json['error'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'request_type': requestType,
        'status': status.value,
        'data_scope': dataScope,
        'data_types': dataTypes,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'metadata': metadata,
      };
}

enum DataDeletionStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const DataDeletionStatus(this.value);
  final String value;
}

class ConsentRecord {
  final String id;
  final String userId;
  final String consentType;
  final bool hasConsented;
  final DateTime consentGivenAt;
  final DateTime? consentWithdrawnAt;
  final String consentMethod;
  final Map<String, dynamic> consentData;
  final String? withdrawalReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsentRecord({
    required this.id,
    required this.userId,
    required this.consentType,
    required this.hasConsented,
    required this.consentGivenAt,
    this.consentWithdrawnAt,
    required this.consentMethod,
    required this.consentData,
    this.withdrawalReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        consentType: json['consent_type'] as String,
        hasConsented: json['has_consented'] as bool,
        consentGivenAt: DateTime.parse(json['consent_given_at'] as String),
        consentWithdrawnAt: json['consent_withdrawn_at'] != null
            ? DateTime.parse(json['consent_withdrawn_at'] as String)
            : null,
        consentMethod: json['consent_method'] as String,
        consentData: Map<String, dynamic>.from(json['consent_data'] ?? {}),
        withdrawalReason: json['withdrawal_reason'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'consent_type': consentType,
        'has_consented': hasConsented,
        'consent_given_at': consentGivenAt.toIso8601String(),
        'consent_withdrawn_at': consentWithdrawnAt?.toIso8601String(),
        'consent_method': consentMethod,
        'consent_data': consentData,
        'withdrawal_reason': withdrawalReason,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class AuditLogEntry {
  final String id;
  final String userId;
  final String action;
  final String resourceType;
  final String resourceId;
  final Map<String, dynamic> changes;
  final String ipAddress;
  final String userAgent;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.changes,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
    required this.metadata,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        action: json['action'] as String,
        resourceType: json['resource_type'] as String,
        resourceId: json['resource_id'] as String,
        changes: Map<String, dynamic>.from(json['changes'] ?? {}),
        ipAddress: json['ip_address'] as String,
        userAgent: json['user_agent'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'action': action,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'changes': changes,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

// Request/Response Models

class CreateDataRetentionPolicyRequest {
  final String name;
  final String description;
  final Map<String, dynamic> rules;
  final RetentionAction action;
  final int retentionPeriodDays;
  final List<String> dataTypes;

  CreateDataRetentionPolicyRequest({
    required this.name,
    required this.description,
    required this.rules,
    required this.action,
    required this.retentionPeriodDays,
    required this.dataTypes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'rules': rules,
        'action': action.value,
        'retention_period_days': retentionPeriodDays,
        'data_types': dataTypes,
      };
}

class CreateDataExportRequestRequest {
  final String userId;
  final String requestType;
  final Map<String, dynamic> dataScope;
  final List<String> dataTypes;

  CreateDataExportRequestRequest({
    required this.userId,
    required this.requestType,
    required this.dataScope,
    required this.dataTypes,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'request_type': requestType,
        'data_scope': dataScope,
        'data_types': dataTypes,
      };
}

class CreateDataDeletionRequestRequest {
  final String userId;
  final String requestType;
  final Map<String, dynamic> dataScope;
  final List<String> dataTypes;

  CreateDataDeletionRequestRequest({
    required this.userId,
    required this.requestType,
    required this.dataScope,
    required this.dataTypes,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'request_type': requestType,
        'data_scope': dataScope,
        'data_types': dataTypes,
      };
}

class DataRetentionPolicyListResponse {
  final List<DataRetentionPolicy> policies;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  DataRetentionPolicyListResponse({
    required this.policies,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory DataRetentionPolicyListResponse.fromJson(Map<String, dynamic> json) =>
      DataRetentionPolicyListResponse(
        policies: (json['policies'] as List)
            .map((p) => DataRetentionPolicy.fromJson(p))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class PIIFieldListResponse {
  final List<PIIField> fields;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  PIIFieldListResponse({
    required this.fields,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PIIFieldListResponse.fromJson(Map<String, dynamic> json) =>
      PIIFieldListResponse(
        fields:
            (json['fields'] as List).map((f) => PIIField.fromJson(f)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class DataExportRequestListResponse {
  final List<DataExportRequest> requests;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  DataExportRequestListResponse({
    required this.requests,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory DataExportRequestListResponse.fromJson(Map<String, dynamic> json) =>
      DataExportRequestListResponse(
        requests: (json['requests'] as List)
            .map((r) => DataExportRequest.fromJson(r))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class AuditLogListResponse {
  final List<AuditLogEntry> logs;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  AuditLogListResponse({
    required this.logs,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory AuditLogListResponse.fromJson(Map<String, dynamic> json) =>
      AuditLogListResponse(
        logs: (json['logs'] as List)
            .map((l) => AuditLogEntry.fromJson(l))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}
