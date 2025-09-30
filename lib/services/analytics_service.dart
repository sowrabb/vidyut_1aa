import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  final String id;
  final String type; // e.g., view.product, view.profile, interaction.click
  final String? entityType;
  final String? entityId;
  final String? userId;
  final String? state;
  final String? city;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.id,
    required this.type,
    this.entityType,
    this.entityId,
    this.userId,
    this.state,
    this.city,
    required this.timestamp,
  });
}

class AnalyticsSession {
  final String sessionId;
  final String? userId;
  final DateTime startedAt;
  DateTime lastHeartbeatAt;

  AnalyticsSession({
    required this.sessionId,
    required this.userId,
    required this.startedAt,
    required this.lastHeartbeatAt,
  });

  int get durationSeconds => lastHeartbeatAt.difference(startedAt).inSeconds;
}

class AnalyticsService extends ChangeNotifier {
  final List<AnalyticsEvent> _events = [];
  final Map<String, AnalyticsSession> _sessions = {};
  final List<_ReportJob> _reportJobs = [];

  List<AnalyticsEvent> get events => List.unmodifiable(_events);
  List<AnalyticsSession> get sessions => List.unmodifiable(_sessions.values);

  // Generic event logger for non-view interactions
  void logEvent({
    required String type,
    String? entityType,
    String? entityId,
    String? userId,
    String? state,
    String? city,
    DateTime? at,
  }) {
    _events.add(AnalyticsEvent(
      id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      entityType: entityType,
      entityId: entityId,
      userId: userId,
      state: state,
      city: city,
      timestamp: at ?? DateTime.now(),
    ));
    notifyListeners();
  }

  void logView({
    required String type,
    String? entityType,
    String? entityId,
    String? userId,
    String? state,
    String? city,
    DateTime? at,
  }) {
    _events.add(AnalyticsEvent(
      id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      entityType: entityType,
      entityId: entityId,
      userId: userId,
      state: state,
      city: city,
      timestamp: at ?? DateTime.now(),
    ));
    notifyListeners();
  }

  void startSession({required String sessionId, String? userId, DateTime? at}) {
    final now = at ?? DateTime.now();
    _sessions[sessionId] = AnalyticsSession(
      sessionId: sessionId,
      userId: userId,
      startedAt: now,
      lastHeartbeatAt: now,
    );
    notifyListeners();
  }

  void heartbeat({required String sessionId, DateTime? at}) {
    final s = _sessions[sessionId];
    if (s == null) return;
    s.lastHeartbeatAt = at ?? DateTime.now();
    notifyListeners();
  }

  void endSession({required String sessionId, DateTime? at}) {
    heartbeat(sessionId: sessionId, at: at);
  }

  // Aggregations
  int get totalViews => _events.where((e) => e.type.startsWith('view.')).length;

  Map<String, int> get viewsByState {
    final map = <String, int>{};
    for (final e in _events.where((e) => e.type.startsWith('view.'))) {
      final key = (e.state ?? '').trim();
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get viewsByCity {
    final map = <String, int>{};
    for (final e in _events.where((e) => e.type.startsWith('view.'))) {
      final key = (e.city ?? '').trim();
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get timeSpentByUserSeconds {
    final map = <String, int>{};
    for (final s in _sessions.values) {
      final uid = s.userId ?? 'anonymous';
      map[uid] = (map[uid] ?? 0) + s.durationSeconds;
    }
    return map;
  }

  int get activeUsersCount {
    final set = <String>{};
    for (final s in _sessions.values) {
      if ((s.userId ?? '').isNotEmpty) set.add(s.userId!);
    }
    return set.length;
  }

  int get totalSessions => _sessions.length;

  double get averageSessionDurationSeconds {
    if (_sessions.isEmpty) return 0;
    final total =
        _sessions.values.fold<int>(0, (a, b) => a + b.durationSeconds);
    return total / _sessions.length;
  }

  // Time series aggregations (views per day)
  List<MapEntry<DateTime, int>> get viewsPerDay {
    final byDay = <DateTime, int>{};
    for (final e in _events.where((e) => e.type.startsWith('view.'))) {
      final day =
          DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      byDay[day] = (byDay[day] ?? 0) + 1;
    }
    final entries = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  // Preset queries
  List<MapEntry<String, int>> topStatesByViews({int limit = 20}) {
    final entries = viewsByState.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  List<MapEntry<String, int>> topCitiesByViews({int limit = 20}) {
    final entries = viewsByCity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  List<MapEntry<String, int>> topProductsByViews({int limit = 20}) {
    final byProd = <String, int>{};
    for (final e in _events.where((e) => e.type == 'view.product')) {
      final id = e.entityId ?? '';
      if (id.isEmpty) continue;
      byProd[id] = (byProd[id] ?? 0) + 1;
    }
    final entries = byProd.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  // Reports (CSV generation async)
  Future<String> generateReportCsv(
      {required String name, required String type}) async {
    final job = _ReportJob(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        status: 'processing',
        startedAt: DateTime.now());
    _reportJobs.add(job);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    String csv;
    switch (type) {
      case 'views_by_state':
        final entries = viewsByState.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        csv = [
          ['state', 'views'],
          ...entries.map((e) => [e.key, e.value.toString()])
        ].map((r) => r.join(',')).join('\n');
        break;
      case 'views_by_city':
        final cityEntries = viewsByCity.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        csv = [
          ['city', 'views'],
          ...cityEntries.map((e) => [e.key, e.value.toString()])
        ].map((r) => r.join(',')).join('\n');
        break;
      case 'top_products':
        final prodEntries = topProductsByViews(limit: 100);
        csv = [
          ['product_id', 'views'],
          ...prodEntries.map((e) => [e.key, e.value.toString()])
        ].map((r) => r.join(',')).join('\n');
        break;
      case 'views_per_day':
        final entries = viewsPerDay;
        csv = [
          ['day', 'views'],
          ...entries.map((e) => [e.key.toIso8601String(), e.value.toString()])
        ].map((r) => r.join(',')).join('\n');
        break;
      default:
        csv = 'name,value\nplaceholder,0';
    }
    job.status = 'completed';
    job.completedAt = DateTime.now();
    job.content = csv;
    notifyListeners();
    return csv;
  }

  List<_ReportJob> get reportJobs => List.unmodifiable(_reportJobs);

  // Demo seed
  void seedDemoDataIfEmpty() {
    if (_events.isNotEmpty || _sessions.isNotEmpty) return;
    final now = DateTime.now();

    // Seed multiple user sessions over past days
    for (int u = 1; u <= 12; u++) {
      final sid = 'sess_demo_$u';
      final start = now.subtract(Duration(minutes: 5 * u + 10));
      startSession(sessionId: sid, userId: '$u', at: start);
      heartbeat(sessionId: sid, at: start.add(Duration(minutes: 3 + (u % 5))));
      endSession(sessionId: sid, at: start.add(Duration(minutes: 4 + (u % 7))));
    }

    // States and cities for geo diversity
    const geo = [
      {'state': 'Maharashtra', 'city': 'Mumbai'},
      {'state': 'Karnataka', 'city': 'Bengaluru'},
      {'state': 'Delhi', 'city': 'New Delhi'},
      {'state': 'Tamil Nadu', 'city': 'Chennai'},
      {'state': 'Gujarat', 'city': 'Ahmedabad'},
      {'state': 'West Bengal', 'city': 'Kolkata'},
      {'state': 'Telangana', 'city': 'Hyderabad'},
      {'state': 'Rajasthan', 'city': 'Jaipur'},
    ];

    // Seed 30 days of views across products and profiles
    for (int d = 0; d < 30; d++) {
      final day = now.subtract(Duration(days: d));
      for (int i = 0; i < 40 - d; i++) {
        final g = geo[(i + d) % geo.length];
        final userId = ((i + d) % 12 + 1).toString();
        final productId = ((i + d) % 8 + 1).toString(); // products 1..8
        final t =
            DateTime(day.year, day.month, day.day, (i * 3) % 24, (i * 7) % 60);
        logView(
          type: 'view.product',
          entityType: 'product',
          entityId: productId,
          userId: userId,
          state: g['state'],
          city: g['city'],
          at: t,
        );
        if (i % 5 == 0) {
          logView(
            type: 'view.profile',
            entityType: 'seller',
            entityId: 'U${(i % 5) + 1}',
            userId: userId,
            state: g['state'],
            city: g['city'],
            at: t.add(const Duration(minutes: 2)),
          );
        }
      }
    }
  }
}

class _ReportJob {
  final String id;
  final String name;
  final String type;
  String status; // processing, completed
  final DateTime startedAt;
  DateTime? completedAt;
  String? content; // CSV content
  _ReportJob(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      required this.startedAt});
}
