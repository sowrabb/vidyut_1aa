/// Analytics & Reporting Models
library;

// Simple analytics snapshot models for admin providers
class AnalyticsSnapshot {
  final int totalUsers;
  final int activeSellers;
  final int totalProducts;
  final int totalOrders;
  final Map<String, dynamic> metrics;
  final List<ActivityEvent> events;
  final DateTime lastUpdated;

  AnalyticsSnapshot({
    required this.totalUsers,
    required this.activeSellers,
    required this.totalProducts,
    required this.totalOrders,
    required this.metrics,
    required this.events,
    required this.lastUpdated,
  });

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) => AnalyticsSnapshot(
    totalUsers: json['total_users'] as int? ?? 0,
    activeSellers: json['active_sellers'] as int? ?? 0,
    totalProducts: json['total_products'] as int? ?? 0,
    totalOrders: json['total_orders'] as int? ?? 0,
    metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
    events: (json['events'] as List? ?? [])
        .map((e) => ActivityEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastUpdated: json['last_updated'] != null
        ? DateTime.parse(json['last_updated'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'total_users': totalUsers,
    'active_sellers': activeSellers,
    'total_products': totalProducts,
    'total_orders': totalOrders,
    'metrics': metrics,
    'events': events.map((e) => e.toJson()).toList(),
    'last_updated': lastUpdated.toIso8601String(),
  };
}

class ProductAnalytics {
  final int totalProducts;
  final int activeProducts;
  final List<Map<String, dynamic>> topProducts;
  final Map<String, int> productViews;

  ProductAnalytics({
    required this.totalProducts,
    required this.activeProducts,
    required this.topProducts,
    required this.productViews,
  });

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) => ProductAnalytics(
    totalProducts: json['total_products'] as int? ?? 0,
    activeProducts: json['active_products'] as int? ?? 0,
    topProducts: List<Map<String, dynamic>>.from(json['top_products'] ?? []),
    productViews: Map<String, int>.from(json['product_views'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'total_products': totalProducts,
    'active_products': activeProducts,
    'top_products': topProducts,
    'product_views': productViews,
  };
}

class UserAnalytics {
  final int totalUsers;
  final int activeUsers;
  final Map<String, int> userGrowth;
  final Map<String, int> activeUserSessions;

  UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.userGrowth,
    required this.activeUserSessions,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) => UserAnalytics(
    totalUsers: json['total_users'] as int? ?? 0,
    activeUsers: json['active_users'] as int? ?? 0,
    userGrowth: Map<String, int>.from(json['user_growth'] ?? {}),
    activeUserSessions: Map<String, int>.from(json['active_user_sessions'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'total_users': totalUsers,
    'active_users': activeUsers,
    'user_growth': userGrowth,
    'active_user_sessions': activeUserSessions,
  };
}

class ActivityEvent {
  final String id;
  final String userId;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ActivityEvent({
    required this.id,
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    required this.metadata,
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) => ActivityEvent(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    action: json['action'] as String? ?? '',
    resourceType: json['resource_type'] as String? ?? '',
    resourceId: json['resource_id'] as String? ?? '',
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now(),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'action': action,
    'resource_type': resourceType,
    'resource_id': resourceId,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

class AnalyticsDashboard {
  final String id;
  final String name;
  final String description;
  final List<DashboardWidget> widgets;
  final DashboardSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isPublic;

  AnalyticsDashboard({
    required this.id,
    required this.name,
    required this.description,
    required this.widgets,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isPublic,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      AnalyticsDashboard(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        widgets: (json['widgets'] as List)
            .map((w) => DashboardWidget.fromJson(w))
            .toList(),
        settings: DashboardSettings.fromJson(json['settings']),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isPublic: json['is_public'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'widgets': widgets.map((w) => w.toJson()).toList(),
        'settings': settings.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_public': isPublic,
      };
}

class DashboardWidget {
  final String id;
  final String type;
  final String title;
  final Map<String, dynamic> configuration;
  final WidgetPosition position;
  final WidgetSize size;
  final List<String> dataSources;
  final DateTime lastUpdated;

  DashboardWidget({
    required this.id,
    required this.type,
    required this.title,
    required this.configuration,
    required this.position,
    required this.size,
    required this.dataSources,
    required this.lastUpdated,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) =>
      DashboardWidget(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
        position: WidgetPosition.fromJson(json['position']),
        size: WidgetSize.fromJson(json['size']),
        dataSources: List<String>.from(json['data_sources'] ?? []),
        lastUpdated: DateTime.parse(json['last_updated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'configuration': configuration,
        'position': position.toJson(),
        'size': size.toJson(),
        'data_sources': dataSources,
        'last_updated': lastUpdated.toIso8601String(),
      };
}

class WidgetPosition {
  final int x;
  final int y;

  WidgetPosition({
    required this.x,
    required this.y,
  });

  factory WidgetPosition.fromJson(Map<String, dynamic> json) => WidgetPosition(
        x: json['x'] as int,
        y: json['y'] as int,
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}

class WidgetSize {
  final int width;
  final int height;

  WidgetSize({
    required this.width,
    required this.height,
  });

  factory WidgetSize.fromJson(Map<String, dynamic> json) => WidgetSize(
        width: json['width'] as int,
        height: json['height'] as int,
      );

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };
}

class DashboardSettings {
  final String theme;
  final bool autoRefresh;
  final int refreshInterval;
  final Map<String, dynamic> timeFilters;
  final List<String> allowedUsers;
  final Map<String, dynamic> customSettings;

  DashboardSettings({
    required this.theme,
    required this.autoRefresh,
    required this.refreshInterval,
    required this.timeFilters,
    required this.allowedUsers,
    required this.customSettings,
  });

  factory DashboardSettings.fromJson(Map<String, dynamic> json) =>
      DashboardSettings(
        theme: json['theme'] as String,
        autoRefresh: json['auto_refresh'] as bool,
        refreshInterval: json['refresh_interval'] as int,
        timeFilters: Map<String, dynamic>.from(json['time_filters'] ?? {}),
        allowedUsers: List<String>.from(json['allowed_users'] ?? []),
        customSettings:
            Map<String, dynamic>.from(json['custom_settings'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'auto_refresh': autoRefresh,
        'refresh_interval': refreshInterval,
        'time_filters': timeFilters,
        'allowed_users': allowedUsers,
        'custom_settings': customSettings,
      };
}

class AnalyticsReport {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final Map<String, dynamic> parameters;
  final ReportStatus status;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  AnalyticsReport({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.parameters,
    required this.status,
    this.fileUrl,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    required this.metadata,
  });

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) =>
      AnalyticsReport(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: ReportType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => ReportType.csv,
        ),
        parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
        status: ReportStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => ReportStatus.pending,
        ),
        fileUrl: json['file_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        createdBy: json['created_by'] as String,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.value,
        'parameters': parameters,
        'status': status.value,
        'file_url': fileUrl,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'created_by': createdBy,
        'metadata': metadata,
      };
}

enum ReportType {
  csv('csv'),
  pdf('pdf'),
  excel('excel'),
  json('json');

  const ReportType(this.value);
  final String value;
}

enum ReportStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const ReportStatus(this.value);
  final String value;
}

class AnalyticsThreshold {
  final String id;
  final String name;
  final String metric;
  final ThresholdCondition condition;
  final double value;
  final String notificationChannel;
  final List<String> recipients;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  AnalyticsThreshold({
    required this.id,
    required this.name,
    required this.metric,
    required this.condition,
    required this.value,
    required this.notificationChannel,
    required this.recipients,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory AnalyticsThreshold.fromJson(Map<String, dynamic> json) =>
      AnalyticsThreshold(
        id: json['id'] as String,
        name: json['name'] as String,
        metric: json['metric'] as String,
        condition: ThresholdCondition.values.firstWhere(
          (e) => e.value == json['condition'],
          orElse: () => ThresholdCondition.greaterThan,
        ),
        value: (json['value'] as num).toDouble(),
        notificationChannel: json['notification_channel'] as String,
        recipients: List<String>.from(json['recipients'] ?? []),
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'metric': metric,
        'condition': condition.value,
        'value': value,
        'notification_channel': notificationChannel,
        'recipients': recipients,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
      };
}

enum ThresholdCondition {
  greaterThan('greater_than'),
  lessThan('less_than'),
  equalTo('equal_to'),
  notEqualTo('not_equal_to'),
  greaterThanOrEqual('greater_than_or_equal'),
  lessThanOrEqual('less_than_or_equal');

  const ThresholdCondition(this.value);
  final String value;
}

class AnalyticsMetric {
  final String id;
  final String name;
  final String description;
  final MetricType type;
  final String dataSource;
  final Map<String, dynamic> configuration;
  final DateTime lastCalculated;
  final double currentValue;
  final Map<String, dynamic> historicalData;

  AnalyticsMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.dataSource,
    required this.configuration,
    required this.lastCalculated,
    required this.currentValue,
    required this.historicalData,
  });

  factory AnalyticsMetric.fromJson(Map<String, dynamic> json) =>
      AnalyticsMetric(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: MetricType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => MetricType.count,
        ),
        dataSource: json['data_source'] as String,
        configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
        lastCalculated: DateTime.parse(json['last_calculated'] as String),
        currentValue: (json['current_value'] as num).toDouble(),
        historicalData:
            Map<String, dynamic>.from(json['historical_data'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.value,
        'data_source': dataSource,
        'configuration': configuration,
        'last_calculated': lastCalculated.toIso8601String(),
        'current_value': currentValue,
        'historical_data': historicalData,
      };
}

enum MetricType {
  count('count'),
  sum('sum'),
  average('average'),
  percentage('percentage'),
  ratio('ratio'),
  trend('trend');

  const MetricType(this.value);
  final String value;
}

class AnalyticsQuery {
  final String id;
  final String name;
  final String description;
  final String sql;
  final List<String> parameters;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  AnalyticsQuery({
    required this.id,
    required this.name,
    required this.description,
    required this.sql,
    required this.parameters,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory AnalyticsQuery.fromJson(Map<String, dynamic> json) => AnalyticsQuery(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        sql: json['sql'] as String,
        parameters: List<String>.from(json['parameters'] ?? []),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sql': sql,
        'parameters': parameters,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_active': isActive,
      };
}

// Request/Response Models

class CreateDashboardRequest {
  final String name;
  final String description;
  final List<DashboardWidget> widgets;
  final DashboardSettings settings;
  final bool isPublic;

  CreateDashboardRequest({
    required this.name,
    required this.description,
    required this.widgets,
    required this.settings,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'widgets': widgets.map((w) => w.toJson()).toList(),
        'settings': settings.toJson(),
        'is_public': isPublic,
      };
}

class UpdateDashboardRequest {
  final String? name;
  final String? description;
  final List<DashboardWidget>? widgets;
  final DashboardSettings? settings;
  final bool? isPublic;

  UpdateDashboardRequest({
    this.name,
    this.description,
    this.widgets,
    this.settings,
    this.isPublic,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (widgets != null)
          'widgets': widgets!.map((w) => w.toJson()).toList(),
        if (settings != null) 'settings': settings!.toJson(),
        if (isPublic != null) 'is_public': isPublic,
      };
}

class CreateReportRequest {
  final String name;
  final String description;
  final ReportType type;
  final Map<String, dynamic> parameters;

  CreateReportRequest({
    required this.name,
    required this.description,
    required this.type,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type.value,
        'parameters': parameters,
      };
}

class CreateThresholdRequest {
  final String name;
  final String metric;
  final ThresholdCondition condition;
  final double value;
  final String notificationChannel;
  final List<String> recipients;

  CreateThresholdRequest({
    required this.name,
    required this.metric,
    required this.condition,
    required this.value,
    required this.notificationChannel,
    required this.recipients,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'metric': metric,
        'condition': condition.value,
        'value': value,
        'notification_channel': notificationChannel,
        'recipients': recipients,
      };
}

class ExecuteQueryRequest {
  final String queryId;
  final Map<String, dynamic> parameters;
  final int limit;

  ExecuteQueryRequest({
    required this.queryId,
    required this.parameters,
    required this.limit,
  });

  Map<String, dynamic> toJson() => {
        'query_id': queryId,
        'parameters': parameters,
        'limit': limit,
      };
}

class DashboardListResponse {
  final List<AnalyticsDashboard> dashboards;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  DashboardListResponse({
    required this.dashboards,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory DashboardListResponse.fromJson(Map<String, dynamic> json) =>
      DashboardListResponse(
        dashboards: (json['dashboards'] as List)
            .map((d) => AnalyticsDashboard.fromJson(d))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class ReportListResponse {
  final List<AnalyticsReport> reports;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  ReportListResponse({
    required this.reports,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) =>
      ReportListResponse(
        reports: (json['reports'] as List)
            .map((r) => AnalyticsReport.fromJson(r))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class ThresholdListResponse {
  final List<AnalyticsThreshold> thresholds;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  ThresholdListResponse({
    required this.thresholds,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory ThresholdListResponse.fromJson(Map<String, dynamic> json) =>
      ThresholdListResponse(
        thresholds: (json['thresholds'] as List)
            .map((t) => AnalyticsThreshold.fromJson(t))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class QueryResult {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final int totalRows;
  final Map<String, dynamic> metadata;

  QueryResult({
    required this.data,
    required this.columns,
    required this.totalRows,
    required this.metadata,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) => QueryResult(
        data: List<Map<String, dynamic>>.from(json['data'] ?? []),
        columns: List<String>.from(json['columns'] ?? []),
        totalRows: json['total_rows'] as int,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}
