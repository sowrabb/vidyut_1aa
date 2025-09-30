/// Search and Relevance Management Models
library;

class SearchConfiguration {
  final String id;
  final String name;
  final List<SearchSynonym> synonyms;
  final List<SearchBoost> boosts;
  final List<String> bannedTerms;
  final Map<String, dynamic> tuningRules;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  SearchConfiguration({
    required this.id,
    required this.name,
    required this.synonyms,
    required this.boosts,
    required this.bannedTerms,
    required this.tuningRules,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory SearchConfiguration.fromJson(Map<String, dynamic> json) =>
      SearchConfiguration(
        id: json['id'] as String,
        name: json['name'] as String,
        synonyms: (json['synonyms'] as List)
            .map((s) => SearchSynonym.fromJson(s))
            .toList(),
        boosts: (json['boosts'] as List)
            .map((b) => SearchBoost.fromJson(b))
            .toList(),
        bannedTerms: List<String>.from(json['banned_terms'] ?? []),
        tuningRules: Map<String, dynamic>.from(json['tuning_rules'] ?? {}),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'synonyms': synonyms.map((s) => s.toJson()).toList(),
        'boosts': boosts.map((b) => b.toJson()).toList(),
        'banned_terms': bannedTerms,
        'tuning_rules': tuningRules,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_active': isActive,
      };
}

class SearchSynonym {
  final String id;
  final String primary;
  final List<String> alternatives;
  final double weight;
  final String category;
  final bool isActive;

  SearchSynonym({
    required this.id,
    required this.primary,
    required this.alternatives,
    required this.weight,
    required this.category,
    required this.isActive,
  });

  factory SearchSynonym.fromJson(Map<String, dynamic> json) => SearchSynonym(
        id: json['id'] as String,
        primary: json['primary'] as String,
        alternatives: List<String>.from(json['alternatives'] ?? []),
        weight: (json['weight'] as num).toDouble(),
        category: json['category'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'primary': primary,
        'alternatives': alternatives,
        'weight': weight,
        'category': category,
        'is_active': isActive,
      };
}

class SearchBoost {
  final String id;
  final String term;
  final double boostValue;
  final String category;
  final List<String> conditions;
  final bool isActive;

  SearchBoost({
    required this.id,
    required this.term,
    required this.boostValue,
    required this.category,
    required this.conditions,
    required this.isActive,
  });

  factory SearchBoost.fromJson(Map<String, dynamic> json) => SearchBoost(
        id: json['id'] as String,
        term: json['term'] as String,
        boostValue: (json['boost_value'] as num).toDouble(),
        category: json['category'] as String,
        conditions: List<String>.from(json['conditions'] ?? []),
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term,
        'boost_value': boostValue,
        'category': category,
        'conditions': conditions,
        'is_active': isActive,
      };
}

class SearchPerformance {
  final String id;
  final DateTime timestamp;
  final String query;
  final double responseTime;
  final int resultCount;
  final double relevanceScore;
  final List<String> clickedResults;
  final String userId;
  final String sessionId;

  SearchPerformance({
    required this.id,
    required this.timestamp,
    required this.query,
    required this.responseTime,
    required this.resultCount,
    required this.relevanceScore,
    required this.clickedResults,
    required this.userId,
    required this.sessionId,
  });

  factory SearchPerformance.fromJson(Map<String, dynamic> json) =>
      SearchPerformance(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        query: json['query'] as String,
        responseTime: (json['response_time'] as num).toDouble(),
        resultCount: json['result_count'] as int,
        relevanceScore: (json['relevance_score'] as num).toDouble(),
        clickedResults: List<String>.from(json['clicked_results'] ?? []),
        userId: json['user_id'] as String,
        sessionId: json['session_id'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'query': query,
        'response_time': responseTime,
        'result_count': resultCount,
        'relevance_score': relevanceScore,
        'clicked_results': clickedResults,
        'user_id': userId,
        'session_id': sessionId,
      };
}

class SearchExperiment {
  final String id;
  final String name;
  final String description;
  final SearchConfiguration configurationA;
  final SearchConfiguration configurationB;
  final double trafficSplit;
  final DateTime startDate;
  final DateTime? endDate;
  final ExperimentStatus status;
  final Map<String, dynamic> metrics;
  final String createdBy;

  SearchExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.configurationA,
    required this.configurationB,
    required this.trafficSplit,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.metrics,
    required this.createdBy,
  });

  factory SearchExperiment.fromJson(Map<String, dynamic> json) =>
      SearchExperiment(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        configurationA: SearchConfiguration.fromJson(json['configuration_a']),
        configurationB: SearchConfiguration.fromJson(json['configuration_b']),
        trafficSplit: (json['traffic_split'] as num).toDouble(),
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        status: ExperimentStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => ExperimentStatus.draft,
        ),
        metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'configuration_a': configurationA.toJson(),
        'configuration_b': configurationB.toJson(),
        'traffic_split': trafficSplit,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'status': status.value,
        'metrics': metrics,
        'created_by': createdBy,
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

class ReindexJob {
  final String id;
  final String entityType;
  final List<String> entityIds;
  final ReindexStatus status;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? error;
  final String createdBy;

  ReindexJob({
    required this.id,
    required this.entityType,
    required this.entityIds,
    required this.status,
    required this.totalItems,
    required this.processedItems,
    required this.failedItems,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.error,
    required this.createdBy,
  });

  factory ReindexJob.fromJson(Map<String, dynamic> json) => ReindexJob(
        id: json['id'] as String,
        entityType: json['entity_type'] as String,
        entityIds: List<String>.from(json['entity_ids'] ?? []),
        status: ReindexStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => ReindexStatus.pending,
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
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_type': entityType,
        'entity_ids': entityIds,
        'status': status.value,
        'total_items': totalItems,
        'processed_items': processedItems,
        'failed_items': failedItems,
        'created_at': createdAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error': error,
        'created_by': createdBy,
      };
}

enum ReindexStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const ReindexStatus(this.value);
  final String value;
}

// Request/Response Models

class CreateSearchConfigurationRequest {
  final String name;
  final List<SearchSynonym> synonyms;
  final List<SearchBoost> boosts;
  final List<String> bannedTerms;
  final Map<String, dynamic> tuningRules;

  CreateSearchConfigurationRequest({
    required this.name,
    required this.synonyms,
    required this.boosts,
    required this.bannedTerms,
    required this.tuningRules,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'synonyms': synonyms.map((s) => s.toJson()).toList(),
        'boosts': boosts.map((b) => b.toJson()).toList(),
        'banned_terms': bannedTerms,
        'tuning_rules': tuningRules,
      };
}

class UpdateSearchConfigurationRequest {
  final String? name;
  final List<SearchSynonym>? synonyms;
  final List<SearchBoost>? boosts;
  final List<String>? bannedTerms;
  final Map<String, dynamic>? tuningRules;
  final bool? isActive;

  UpdateSearchConfigurationRequest({
    this.name,
    this.synonyms,
    this.boosts,
    this.bannedTerms,
    this.tuningRules,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (synonyms != null)
          'synonyms': synonyms!.map((s) => s.toJson()).toList(),
        if (boosts != null) 'boosts': boosts!.map((b) => b.toJson()).toList(),
        if (bannedTerms != null) 'banned_terms': bannedTerms,
        if (tuningRules != null) 'tuning_rules': tuningRules,
        if (isActive != null) 'is_active': isActive,
      };
}

class CreateSearchExperimentRequest {
  final String name;
  final String description;
  final String configurationAId;
  final String configurationBId;
  final double trafficSplit;
  final DateTime startDate;
  final DateTime? endDate;

  CreateSearchExperimentRequest({
    required this.name,
    required this.description,
    required this.configurationAId,
    required this.configurationBId,
    required this.trafficSplit,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'configuration_a_id': configurationAId,
        'configuration_b_id': configurationBId,
        'traffic_split': trafficSplit,
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
      };
}

class CreateReindexJobRequest {
  final String entityType;
  final List<String> entityIds;
  final bool forceReindex;

  CreateReindexJobRequest({
    required this.entityType,
    required this.entityIds,
    required this.forceReindex,
  });

  Map<String, dynamic> toJson() => {
        'entity_type': entityType,
        'entity_ids': entityIds,
        'force_reindex': forceReindex,
      };
}

class SearchPerformanceListResponse {
  final List<SearchPerformance> performances;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;
  final Map<String, dynamic> summary;

  SearchPerformanceListResponse({
    required this.performances,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.summary,
  });

  factory SearchPerformanceListResponse.fromJson(Map<String, dynamic> json) =>
      SearchPerformanceListResponse(
        performances: (json['performances'] as List)
            .map((p) => SearchPerformance.fromJson(p))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
        summary: Map<String, dynamic>.from(json['summary'] ?? {}),
      );
}

class SearchConfigurationListResponse {
  final List<SearchConfiguration> configurations;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  SearchConfigurationListResponse({
    required this.configurations,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory SearchConfigurationListResponse.fromJson(Map<String, dynamic> json) =>
      SearchConfigurationListResponse(
        configurations: (json['configurations'] as List)
            .map((c) => SearchConfiguration.fromJson(c))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class ReindexJobListResponse {
  final List<ReindexJob> jobs;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  ReindexJobListResponse({
    required this.jobs,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory ReindexJobListResponse.fromJson(Map<String, dynamic> json) =>
      ReindexJobListResponse(
        jobs:
            (json['jobs'] as List).map((j) => ReindexJob.fromJson(j)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}
