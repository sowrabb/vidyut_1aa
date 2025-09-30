/// Feature Flags Management Models
library;

class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final String key;
  final bool isEnabled;
  final FeatureFlagType type;
  final Map<String, dynamic> defaultValue;
  final List<FeatureFlagEnvironment> environments;
  final List<TargetingRule> targetingRules;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.key,
    required this.isEnabled,
    required this.type,
    required this.defaultValue,
    required this.environments,
    required this.targetingRules,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) => FeatureFlag(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        key: json['key'] as String,
        isEnabled: json['is_enabled'] as bool,
        type: FeatureFlagType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => FeatureFlagType.boolean,
        ),
        defaultValue: Map<String, dynamic>.from(json['default_value'] ?? {}),
        environments: (json['environments'] as List)
            .map((e) => FeatureFlagEnvironment.fromJson(e))
            .toList(),
        targetingRules: (json['targeting_rules'] as List)
            .map((r) => TargetingRule.fromJson(r))
            .toList(),
        tags: List<String>.from(json['tags'] ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'key': key,
        'is_enabled': isEnabled,
        'type': type.value,
        'default_value': defaultValue,
        'environments': environments.map((e) => e.toJson()).toList(),
        'targeting_rules': targetingRules.map((r) => r.toJson()).toList(),
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_active': isActive,
      };
}

enum FeatureFlagType {
  boolean('boolean'),
  string('string'),
  number('number'),
  json('json');

  const FeatureFlagType(this.value);
  final String value;
}

class FeatureFlagEnvironment {
  final String id;
  final String name;
  final String environment;
  final bool isEnabled;
  final Map<String, dynamic> value;
  final List<TargetingRule> targetingRules;
  final DateTime lastUpdated;

  FeatureFlagEnvironment({
    required this.id,
    required this.name,
    required this.environment,
    required this.isEnabled,
    required this.value,
    required this.targetingRules,
    required this.lastUpdated,
  });

  factory FeatureFlagEnvironment.fromJson(Map<String, dynamic> json) =>
      FeatureFlagEnvironment(
        id: json['id'] as String,
        name: json['name'] as String,
        environment: json['environment'] as String,
        isEnabled: json['is_enabled'] as bool,
        value: Map<String, dynamic>.from(json['value'] ?? {}),
        targetingRules: (json['targeting_rules'] as List)
            .map((r) => TargetingRule.fromJson(r))
            .toList(),
        lastUpdated: DateTime.parse(json['last_updated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'environment': environment,
        'is_enabled': isEnabled,
        'value': value,
        'targeting_rules': targetingRules.map((r) => r.toJson()).toList(),
        'last_updated': lastUpdated.toIso8601String(),
      };
}

class TargetingRule {
  final String id;
  final String name;
  final TargetingRuleType type;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> value;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TargetingRule({
    required this.id,
    required this.name,
    required this.type,
    required this.conditions,
    required this.value,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TargetingRule.fromJson(Map<String, dynamic> json) => TargetingRule(
        id: json['id'] as String,
        name: json['name'] as String,
        type: TargetingRuleType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => TargetingRuleType.user,
        ),
        conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
        value: Map<String, dynamic>.from(json['value'] ?? {}),
        priority: json['priority'] as int,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.value,
        'conditions': conditions,
        'value': value,
        'priority': priority,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

enum TargetingRuleType {
  user('user'),
  segment('segment'),
  percentage('percentage'),
  geo('geo'),
  time('time');

  const TargetingRuleType(this.value);
  final String value;
}

class KillSwitch {
  final String id;
  final String name;
  final String description;
  final String featureKey;
  final bool isActive;
  final KillSwitchScope scope;
  final Map<String, dynamic> conditions;
  final String reason;
  final DateTime activatedAt;
  final DateTime? deactivatedAt;
  final String activatedBy;
  final String? deactivatedBy;

  KillSwitch({
    required this.id,
    required this.name,
    required this.description,
    required this.featureKey,
    required this.isActive,
    required this.scope,
    required this.conditions,
    required this.reason,
    required this.activatedAt,
    this.deactivatedAt,
    required this.activatedBy,
    this.deactivatedBy,
  });

  factory KillSwitch.fromJson(Map<String, dynamic> json) => KillSwitch(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        featureKey: json['feature_key'] as String,
        isActive: json['is_active'] as bool,
        scope: KillSwitchScope.values.firstWhere(
          (e) => e.value == json['scope'],
          orElse: () => KillSwitchScope.global,
        ),
        conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
        reason: json['reason'] as String,
        activatedAt: DateTime.parse(json['activated_at'] as String),
        deactivatedAt: json['deactivated_at'] != null
            ? DateTime.parse(json['deactivated_at'] as String)
            : null,
        activatedBy: json['activated_by'] as String,
        deactivatedBy: json['deactivated_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'feature_key': featureKey,
        'is_active': isActive,
        'scope': scope.value,
        'conditions': conditions,
        'reason': reason,
        'activated_at': activatedAt.toIso8601String(),
        'deactivated_at': deactivatedAt?.toIso8601String(),
        'activated_by': activatedBy,
        'deactivated_by': deactivatedBy,
      };
}

enum KillSwitchScope {
  global('global'),
  environment('environment'),
  user('user'),
  segment('segment');

  const KillSwitchScope(this.value);
  final String value;
}

class FeatureFlagExperiment {
  final String id;
  final String name;
  final String description;
  final String featureKey;
  final List<ExperimentVariant> variants;
  final double trafficSplit;
  final ExperimentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> metrics;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeatureFlagExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.featureKey,
    required this.variants,
    required this.trafficSplit,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.metrics,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeatureFlagExperiment.fromJson(Map<String, dynamic> json) =>
      FeatureFlagExperiment(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        featureKey: json['feature_key'] as String,
        variants: (json['variants'] as List)
            .map((v) => ExperimentVariant.fromJson(v))
            .toList(),
        trafficSplit: (json['traffic_split'] as num).toDouble(),
        status: ExperimentStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => ExperimentStatus.draft,
        ),
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'feature_key': featureKey,
        'variants': variants.map((v) => v.toJson()).toList(),
        'traffic_split': trafficSplit,
        'status': status.value,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'metrics': metrics,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ExperimentVariant {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> value;
  final double trafficPercentage;
  final bool isControl;

  ExperimentVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.trafficPercentage,
    required this.isControl,
  });

  factory ExperimentVariant.fromJson(Map<String, dynamic> json) =>
      ExperimentVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        value: Map<String, dynamic>.from(json['value'] ?? {}),
        trafficPercentage: (json['traffic_percentage'] as num).toDouble(),
        isControl: json['is_control'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'value': value,
        'traffic_percentage': trafficPercentage,
        'is_control': isControl,
      };
}

enum ExperimentStatus {
  draft('draft'),
  running('running'),
  completed('completed'),
  cancelled('cancelled');

  const ExperimentStatus(this.value);
  final String value;
}

class FeatureFlagGuardrail {
  final String id;
  final String name;
  final String description;
  final String featureKey;
  final GuardrailType type;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> actions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  FeatureFlagGuardrail({
    required this.id,
    required this.name,
    required this.description,
    required this.featureKey,
    required this.type,
    required this.conditions,
    required this.actions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory FeatureFlagGuardrail.fromJson(Map<String, dynamic> json) =>
      FeatureFlagGuardrail(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        featureKey: json['feature_key'] as String,
        type: GuardrailType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => GuardrailType.performance,
        ),
        conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
        actions: Map<String, dynamic>.from(json['actions'] ?? {}),
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'feature_key': featureKey,
        'type': type.value,
        'conditions': conditions,
        'actions': actions,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
      };
}

enum GuardrailType {
  performance('performance'),
  error('error'),
  usage('usage'),
  cost('cost');

  const GuardrailType(this.value);
  final String value;
}

class FeatureFlagApproval {
  final String id;
  final String featureFlagId;
  final String environment;
  final ApprovalStatus status;
  final String requestedBy;
  final DateTime requestedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final String? reason;
  final Map<String, dynamic> changes;

  FeatureFlagApproval({
    required this.id,
    required this.featureFlagId,
    required this.environment,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.reason,
    required this.changes,
  });

  factory FeatureFlagApproval.fromJson(Map<String, dynamic> json) =>
      FeatureFlagApproval(
        id: json['id'] as String,
        featureFlagId: json['feature_flag_id'] as String,
        environment: json['environment'] as String,
        status: ApprovalStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => ApprovalStatus.pending,
        ),
        requestedBy: json['requested_by'] as String,
        requestedAt: DateTime.parse(json['requested_at'] as String),
        approvedBy: json['approved_by'] as String?,
        approvedAt: json['approved_at'] != null
            ? DateTime.parse(json['approved_at'] as String)
            : null,
        rejectedBy: json['rejected_by'] as String?,
        rejectedAt: json['rejected_at'] != null
            ? DateTime.parse(json['rejected_at'] as String)
            : null,
        reason: json['reason'] as String?,
        changes: Map<String, dynamic>.from(json['changes'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'feature_flag_id': featureFlagId,
        'environment': environment,
        'status': status.value,
        'requested_by': requestedBy,
        'requested_at': requestedAt.toIso8601String(),
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'rejected_by': rejectedBy,
        'rejected_at': rejectedAt?.toIso8601String(),
        'reason': reason,
        'changes': changes,
      };
}

enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ApprovalStatus(this.value);
  final String value;
}

// Request/Response Models

class CreateFeatureFlagRequest {
  final String name;
  final String description;
  final String key;
  final FeatureFlagType type;
  final Map<String, dynamic> defaultValue;
  final List<String> tags;

  CreateFeatureFlagRequest({
    required this.name,
    required this.description,
    required this.key,
    required this.type,
    required this.defaultValue,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'key': key,
        'type': type.value,
        'default_value': defaultValue,
        'tags': tags,
      };
}

class UpdateFeatureFlagRequest {
  final String? name;
  final String? description;
  final bool? isEnabled;
  final Map<String, dynamic>? defaultValue;
  final List<TargetingRule>? targetingRules;
  final List<String>? tags;
  final bool? isActive;

  UpdateFeatureFlagRequest({
    this.name,
    this.description,
    this.isEnabled,
    this.defaultValue,
    this.targetingRules,
    this.tags,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isEnabled != null) 'is_enabled': isEnabled,
        if (defaultValue != null) 'default_value': defaultValue,
        if (targetingRules != null)
          'targeting_rules': targetingRules!.map((r) => r.toJson()).toList(),
        if (tags != null) 'tags': tags,
        if (isActive != null) 'is_active': isActive,
      };
}

class CreateKillSwitchRequest {
  final String name;
  final String description;
  final String featureKey;
  final KillSwitchScope scope;
  final Map<String, dynamic> conditions;
  final String reason;

  CreateKillSwitchRequest({
    required this.name,
    required this.description,
    required this.featureKey,
    required this.scope,
    required this.conditions,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'feature_key': featureKey,
        'scope': scope.value,
        'conditions': conditions,
        'reason': reason,
      };
}

class FeatureFlagListResponse {
  final List<FeatureFlag> flags;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  FeatureFlagListResponse({
    required this.flags,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory FeatureFlagListResponse.fromJson(Map<String, dynamic> json) =>
      FeatureFlagListResponse(
        flags: (json['flags'] as List)
            .map((f) => FeatureFlag.fromJson(f))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class KillSwitchListResponse {
  final List<KillSwitch> killSwitches;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  KillSwitchListResponse({
    required this.killSwitches,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory KillSwitchListResponse.fromJson(Map<String, dynamic> json) =>
      KillSwitchListResponse(
        killSwitches: (json['kill_switches'] as List)
            .map((k) => KillSwitch.fromJson(k))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class FeatureFlagEvaluation {
  final String flagKey;
  final Map<String, dynamic> value;
  final bool isEnabled;
  final String? variant;
  final String? reason;
  final Map<String, dynamic> metadata;

  FeatureFlagEvaluation({
    required this.flagKey,
    required this.value,
    required this.isEnabled,
    this.variant,
    this.reason,
    required this.metadata,
  });

  factory FeatureFlagEvaluation.fromJson(Map<String, dynamic> json) =>
      FeatureFlagEvaluation(
        flagKey: json['flag_key'] as String,
        value: Map<String, dynamic>.from(json['value'] ?? {}),
        isEnabled: json['is_enabled'] as bool,
        variant: json['variant'] as String?,
        reason: json['reason'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'flag_key': flagKey,
        'value': value,
        'is_enabled': isEnabled,
        'variant': variant,
        'reason': reason,
        'metadata': metadata,
      };
}
