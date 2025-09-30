import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero_section.dart';
import '../models/notification.dart' as notif;
import '../models/subscription_models.dart' as sub;
import '../models/admin_user.dart';
import '../../../services/lightweight_demo_data_service.dart';
import '../services/admin_persistence.dart';
import '../../categories/categories_page.dart';
import '../../messaging/models.dart';
import '../../stateinfo/models/state_info_models.dart';
import '../../sell/models.dart';

class AuditLog {
  final DateTime timestamp;
  final String area;
  final String message;

  AuditLog({
    required this.timestamp,
    required this.area,
    required this.message,
  });
}

class AdminCategoryData {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int productCount;
  final List<String> industries;
  final List<String> materials;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminCategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.productCount,
    required this.industries,
    required this.materials,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'productCount': productCount,
        'industries': industries,
        'materials': materials,
        'isActive': isActive,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AdminCategoryData.fromJson(Map<String, dynamic> json) =>
      AdminCategoryData(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        productCount: json['productCount'] as int,
        industries: List<String>.from(json['industries'] as List),
        materials: List<String>.from(json['materials'] as List),
        isActive: json['isActive'] as bool,
        priority: json['priority'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  AdminCategoryData copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? productCount,
    List<String>? industries,
    List<String>? materials,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminCategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      productCount: productCount ?? this.productCount,
      industries: industries ?? this.industries,
      materials: materials ?? this.materials,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AdminStore extends ChangeNotifier {
  final LightweightDemoDataService _demoDataService;
  final AdminPersistence _persistence;
  bool _isInitialized = false;

  AdminStore(
    this._demoDataService, {
    AdminPersistence? persistence,
  }) : _persistence = persistence ?? AdminPersistence() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _hydrate();
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  // Hero sections data - delegate to DemoDataService
  List<HeroSection> get heroSections => _demoDataService.heroSections;

  // Demo users data - delegate to DemoDataService
  List<AdminUser> get allUsers => _demoDataService.allUsers;

  // Feature flags (demo, in-memory)
  final Map<String, bool> _featureFlags = {
    'new_search': true,
    'lead_scoring': false,
    'ads_v2': true,
    'kyc_strict': false,
  };

  // Audit logs (demo)
  final List<AuditLog> _auditLogs = [];
  int _auditRetentionDays = 30;

  Map<String, Set<String>> get roleToPermissions =>
      _demoDataService.rolePermissions;

  Future<void> createRole(String role,
      {Iterable<String> permissions = const []}) async {
    final created = _demoDataService.createRole(role, permissions: permissions);
    if (!created) return;

    await addAudit(
        'rbac', 'Created role "$role" with ${permissions.length} perms');
    notifyListeners();
    await _persistRBAC();
  }

  Future<void> deleteRole(String role) async {
    if (role == 'admin' || role == 'seller' || role == 'buyer') {
      return; // protect core roles
    }
    final removed = _demoDataService.removeRole(role);
    if (removed) {
      await addAudit('rbac', 'Deleted role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  Future<void> grantPermissionToRole(String role, String permission) async {
    final added = _demoDataService.grantPermissionToRole(role, permission);
    if (added) {
      await addAudit('rbac', 'Granted "$permission" to role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  Future<void> revokePermissionFromRole(String role, String permission) async {
    final removed = _demoDataService.revokePermissionFromRole(role, permission);
    if (removed) {
      await addAudit('rbac', 'Revoked "$permission" from role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  bool roleHas(String role, String permission) {
    return _demoDataService.roleHasPermission(role, permission);
  }

  // Search tuning (demo)
  final Map<String, String> _synonyms = {'wire': 'cable'};
  final Set<String> _bannedTerms = {'spam', 'fraud'};
  final Map<String, double> _boosts = {'copper': 1.2, 'pro': 1.1};
  // Optional category-specific boosts: category => term => factor
  final Map<String, Map<String, double>> _categoryBoosts = {};
  Map<String, String> get synonyms => Map.unmodifiable(_synonyms);
  Set<String> get bannedTerms => Set.unmodifiable(_bannedTerms);
  Map<String, double> get boosts => Map.unmodifiable(_boosts);
  Map<String, Map<String, double>> get categoryBoosts => {
        for (final e in _categoryBoosts.entries)
          e.key: Map<String, double>.from(e.value)
      };
  Future<void> addSynonym(String a, String b) async {
    _synonyms[a] = b;
    await addAudit('search', 'Synonym $a → $b');
    notifyListeners();
    await _persistSearch();
  }

  Future<void> removeSynonym(String a) async {
    _synonyms.remove(a);
    await addAudit('search', 'Removed synonym $a');
    notifyListeners();
    await _persistSearch();
  }

  Future<void> addBanned(String term) async {
    _bannedTerms.add(term);
    await addAudit('search', 'Banned "$term"');
    notifyListeners();
    await _persistSearch();
  }

  Future<void> removeBanned(String term) async {
    _bannedTerms.remove(term);
    await addAudit('search', 'Unbanned "$term"');
    notifyListeners();
    await _persistSearch();
  }

  Future<void> setBoost(String term, double factor) async {
    _boosts[term] = factor;
    await addAudit('search', 'Boost $term=$factor');
    notifyListeners();
    await _persistSearch();
  }

  Future<void> setCategoryBoost(
      String category, String term, double factor) async {
    final map = _categoryBoosts.putIfAbsent(category, () => {});
    map[term] = factor;
    await addAudit('search', 'Boost [$category] $term=$factor');
    notifyListeners();
    await _persistSearch();
  }

  // Geo management (demo)
  final Map<String, Map<String, List<String>>> _geo = {
    'Maharashtra': {
      'Mumbai': ['Andheri', 'Bandra', 'Dadar'],
      'Pune': ['Kothrud', 'Hinjewadi']
    },
    'Karnataka': {
      'Bengaluru': ['Whitefield', 'HSR', 'Indiranagar']
    },
  };
  double _defaultServiceRadiusKm = 25;
  // Optional per-city radius overrides: key format "State|City"
  final Map<String, double> _cityRadiusOverridesKm = {};
  Map<String, Map<String, List<String>>> get geo => _geo;
  double get defaultServiceRadiusKm => _defaultServiceRadiusKm;
  Map<String, double> get cityRadiusOverridesKm =>
      Map.unmodifiable(_cityRadiusOverridesKm);
  Future<void> addState(String state) async {
    _geo.putIfAbsent(state, () => {});
    await addAudit('geo', 'Added state $state');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> addCity(String state, String city) async {
    _geo[state] ??= {};
    _geo[state]!.putIfAbsent(city, () => []);
    await addAudit('geo', 'Added city $city in $state');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> addArea(String state, String city, String area) async {
    _geo[state] ??= {};
    _geo[state]![city] ??= [];
    if (!_geo[state]![city]!.contains(area)) _geo[state]![city]!.add(area);
    await addAudit('geo', 'Added area $area in $city, $state');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> removeArea(String state, String city, String area) async {
    _geo[state]?[city]?.remove(area);
    await addAudit('geo', 'Removed area $area in $city, $state');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> setDefaultRadius(double km) async {
    _defaultServiceRadiusKm = km;
    await addAudit('geo', 'Default radius set to $km km');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> setCityRadius(String state, String city, double km) async {
    _cityRadiusOverridesKm['$state|$city'] = km;
    await addAudit('geo', 'Radius for $city, $state set to $km km');
    notifyListeners();
    await _persistGeo();
  }

  Future<void> clearCityRadius(String state, String city) async {
    _cityRadiusOverridesKm.remove('$state|$city');
    await addAudit('geo', 'Cleared radius override for $city, $state');
    notifyListeners();
    await _persistGeo();
  }

  // System Ops (demo)
  bool _maintenanceMode = false;
  bool get maintenanceMode => _maintenanceMode;
  Future<void> setMaintenance(bool value) async {
    _maintenanceMode = value;
    await addAudit('system', 'Maintenance ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
    await _persistSystem();
  }

  final List<String> _templates = ['Order Email', 'Lead Assignment'];
  List<String> get templates => List.unmodifiable(_templates);
  Future<void> addTemplate(String name) async {
    _templates.add(name);
    await addAudit('system', 'Template added: $name');
    notifyListeners();
    await _persistSystem();
  }

  Future<void> backupNow() async {
    await addAudit('system', 'Backup executed');
  }

  // DX helpers (demo)
  Future<void> seedDemoData() async {
    await addAudit('dev', 'Seeded demo data');
  }

  Future<void> reindexSearch() async {
    await addAudit('dev', 'Triggered search reindex');
  }

  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);
  List<AuditLog> get auditLogs => List.unmodifiable(_auditLogs.reversed);
  int get auditRetentionDays => _auditRetentionDays;
  set auditRetentionDays(int days) {
    _auditRetentionDays = days;
    notifyListeners();
    _persistLogs();
  }

  // Timer settings for hero slideshow
  int _firstSlideDurationSeconds = 10;
  int _otherSlidesDurationSeconds = 3;

  int get firstSlideDurationSeconds => _firstSlideDurationSeconds;
  int get otherSlidesDurationSeconds => _otherSlidesDurationSeconds;

  Future<void> updateSlideDurations({
    int? firstSlideDuration,
    int? otherSlidesDuration,
  }) async {
    if (firstSlideDuration != null) {
      _firstSlideDurationSeconds = firstSlideDuration;
    }
    if (otherSlidesDuration != null) {
      _otherSlidesDurationSeconds = otherSlidesDuration;
    }
    await addAudit('cms',
        'Updated slide durations: first=${_firstSlideDurationSeconds}s, others=${_otherSlidesDurationSeconds}s');
    notifyListeners();
    await _persistSlideDurations();
  }

  // Hero sections getters - delegate to DemoDataService
  List<HeroSection> get activeHeroSections =>
      heroSections.where((h) => h.isActive).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  String exportAuditCsv() {
    const header = 'timestamp,area,message';
    final rows = _auditLogs
        .map((a) => [
              a.timestamp.toIso8601String(),
              a.area,
              a.message.replaceAll(',', ' '),
            ].join(','))
        .join('\n');
    return '$header\n$rows';
  }

  // CRUD: Users (demo) - delegate to DemoDataService
  Future<void> addUser(AdminUser user) async {
    _demoDataService.addUser(user);
    await addAudit('users', 'Added user ${user.id} (${user.email})');
    // DemoDataService will notify listeners automatically
  }

  Future<void> updateUser(AdminUser updated) async {
    _demoDataService.updateUser(updated);
    await addAudit('users', 'Updated user ${updated.id}');
    // DemoDataService will notify listeners automatically
  }

  Future<void> deleteUser(String id) async {
    _demoDataService.removeUser(id);
    await addAudit('users', 'Deleted user $id');
    // DemoDataService will notify listeners automatically
  }

  Future<void> resetPassword(String id) async {
    await addAudit('users', 'Password reset initiated for $id');
    notifyListeners();
  }

  // Role/plan helpers - delegate to DemoDataService
  Future<void> promoteToSeller(String id, {String plan = 'free'}) async {
    final u = allUsers.firstWhere((user) => user.id == id);
    final updated = u.copyWith(
      role: UserRole.seller,
      isSeller: true,
      plan: plan,
      sellerProfile: u.sellerProfile ??
          SellerProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    _demoDataService.updateUser(updated);
    await addAudit('users', 'Promoted $id to seller (plan=$plan)');
    // DemoDataService will notify listeners automatically
  }

  Future<void> demoteToBuyer(String id) async {
    final u = allUsers.firstWhere((user) => user.id == id);
    final updated = u.copyWith(
      role: UserRole.buyer,
      isSeller: false,
      plan: 'free',
      sellerProfile: null,
      status: u.status,
    );
    _demoDataService.updateUser(updated);
    await addAudit('users', 'Demoted $id to buyer');
    // DemoDataService will notify listeners automatically
  }

  Future<AdminUser> createSeller({
    required String id,
    required String name,
    required String email,
    String plan = 'pro',
    SellerProfile? profile,
  }) async {
    final user = AdminUser(
      id: id,
      name: name,
      email: email,
      phone: '+91 00000 00000',
      role: UserRole.seller,
      status: UserStatus.active,
      subscription: SubscriptionPlan.free,
      joinDate: DateTime.now(),
      lastActive: DateTime.now(),
      location: 'Unknown',
      industry: 'Unknown',
      createdAt: DateTime.now(),
      isSeller: true,
      plan: plan,
      sellerProfile: profile ??
          SellerProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    _demoDataService.addUser(user);
    await addAudit('users', 'Created seller $id (plan=$plan)');
    // DemoDataService will notify listeners automatically
    return user;
  }

  Future<void> grantPlan(String id, String plan) async {
    final user = allUsers.firstWhere((u) => u.id == id);
    final updated = user.copyWith(plan: plan);
    _demoDataService.updateUser(updated);
    await addAudit('billing', 'Granted plan $plan to $id');
    // DemoDataService will notify listeners automatically
  }

  Future<void> refund(String id,
      {required double amount, String? reason}) async {
    await addAudit('billing',
        'Refunded $id amount=₹${amount.toStringAsFixed(2)} reason="${reason?.replaceAll('\n', ' ') ?? ''}"');
    notifyListeners();
  }

  Future<void> toggleFlag(String key, bool value) async {
    _featureFlags[key] = value;
    addAudit('feature_flag', 'Toggled $key to $value');
    notifyListeners();
    await _persistFlags();
  }

  Future<void> addAudit(String area, String message) async {
    _auditLogs.add(AuditLog(
      timestamp: DateTime.now(),
      area: area,
      message: message,
    ));
    _pruneOldAudits();
    notifyListeners();
    await _persistLogs();
  }

  void _pruneOldAudits() {
    final cutoff = DateTime.now().subtract(Duration(days: _auditRetentionDays));
    _auditLogs.removeWhere((a) => a.timestamp.isBefore(cutoff));
  }

  UserStatus _parseUserStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }

  Future<void> bulkUpdateUsersStatus(
      Iterable<String> userIds, String status) async {
    for (final userId in userIds) {
      final user = _demoDataService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(status: _parseUserStatus(status));
        _demoDataService.updateUser(updatedUser);
      }
    }
    await addAudit('users', 'Bulk updated ${userIds.length} users to $status');
    notifyListeners();
  }

  void exportUsersCsv(void Function(String csv) onReady) {
    final users = _demoDataService.allUsers;
    const header =
        'id,name,email,role,status,createdAt,plan,isSeller,legalName,gstin,address,materials';
    final rows = users.map((user) {
      final sellerProfile = user.sellerProfile;
      return [
        user.id,
        user.name,
        user.email,
        user.role,
        user.status,
        user.createdAt.toIso8601String(),
        user.plan,
        user.isSeller.toString(),
        sellerProfile?.companyName ?? '',
        sellerProfile?.gstNumber ?? '',
        sellerProfile?.address ?? '',
        sellerProfile?.materials.join(';') ?? '',
      ].map((field) => '"${field.toString().replaceAll('"', '""')}"').join(',');
    }).toList();

    final csv = [header, ...rows].join('\n');
    onReady(csv);
    addAudit('users', 'Exported users CSV (${users.length})');
  }

  Future<void> _hydrate() async {
    // Flags
    final keys = _featureFlags.keys.toList();
    for (final k in keys) {
      final v = await _persistence.getBool('flag_$k');
      if (v != null) {
        _featureFlags[k] = v;
      }
    }
    // Logs
    final raw = await _persistence.getStringList('audit_logs') ?? [];
    _auditLogs
      ..clear()
      ..addAll(raw.map((s) {
        final parts = s.split('|');
        if (parts.length < 3) {
          return AuditLog(
              timestamp: DateTime.now(), area: 'unknown', message: s);
        }
        return AuditLog(
            timestamp: DateTime.parse(parts[0]),
            area: parts[1],
            message: parts.sublist(2).join('|'));
      }));
    _auditRetentionDays = await _persistence.getInt('audit_retention_days') ??
        _auditRetentionDays;
    notifyListeners();

    // RBAC
    final rbacRaw = await _persistence.getStringList('rbac_roles') ?? [];
    if (rbacRaw.isNotEmpty) {
      final map = <String, Set<String>>{};
      for (final line in rbacRaw) {
        if (!line.contains(':')) continue;
        final parts = line.split(':');
        final role = parts.first;
        final permissions = parts.length > 1 && parts[1].isNotEmpty
            ? parts[1]
                .split(',')
                .where((permission) => permission.isNotEmpty)
                .toSet()
            : <String>{};
        map[role] = permissions;
      }
      if (map.isNotEmpty) {
        _demoDataService.replaceRolePermissions(map);
        notifyListeners();
      }
    }

    // Search
    final syn = await _persistence.getStringList('search_synonyms') ?? [];
    if (syn.isNotEmpty) {
      _synonyms
        ..clear()
        ..addAll({
          for (final s in syn)
            if (s.contains(':')) s.split(':')[0]: s.split(':')[1]
        });
    }
    final ban = await _persistence.getStringList('search_banned') ?? [];
    if (ban.isNotEmpty) {
      _bannedTerms
        ..clear()
        ..addAll(ban);
    }
    final bst = await _persistence.getStringList('search_boosts') ?? [];
    if (bst.isNotEmpty) {
      _boosts
        ..clear()
        ..addAll({
          for (final s in bst)
            if (s.contains(':'))
              s.split(':')[0]: double.tryParse(s.split(':')[1]) ?? 1.0
        });
    }
    final cbst =
        await _persistence.getStringList('search_category_boosts') ?? [];
    if (cbst.isNotEmpty) {
      _categoryBoosts.clear();
      for (final s in cbst) {
        final parts = s.split('|');
        if (parts.length == 3) {
          final cat = parts[0];
          final term = parts[1];
          final factor = double.tryParse(parts[2]) ?? 1.0;
          _categoryBoosts.putIfAbsent(cat, () => {});
          _categoryBoosts[cat]![term] = factor;
        }
      }
    }

    // Geo
    _defaultServiceRadiusKm =
        await _persistence.getDouble('geo_radius') ?? _defaultServiceRadiusKm;
    final cityOverrides =
        await _persistence.getStringList('geo_city_radius') ?? [];
    _cityRadiusOverridesKm
      ..clear()
      ..addAll({
        for (final s in cityOverrides)
          if (s.contains(':'))
            s.split(':')[0]:
                double.tryParse(s.split(':')[1]) ?? _defaultServiceRadiusKm
      });

    // System
    _maintenanceMode =
        await _persistence.getBool('system_maintenance') ?? _maintenanceMode;

    // Ads settings
    _adsPriorityPhone =
        await _persistence.getString('ads_priority_phone') ?? _adsPriorityPhone;

    // Load hero sections
    await _loadHeroSections();
    await _loadPlanCards();

    // Load categories
    await _loadCategories();

    // Load state flow data - removed

    // Notifications: templates & drafts
    try {
      final tmplList =
          await _persistence.getStringList('notif_templates') ?? [];
      if (tmplList.isNotEmpty) {
        _notificationTemplates
          ..clear()
          ..addAll(tmplList.map((s) {
            final Map<String, dynamic> jsonMap = jsonDecode(s);
            return notif.NotificationTemplate.fromJson(jsonMap);
          }));
      }
      final draftList = await _persistence.getStringList('notif_drafts') ?? [];
      if (draftList.isNotEmpty) {
        _notificationDrafts
          ..clear()
          ..addAll(draftList.map((s) {
            final Map<String, dynamic> jsonMap = jsonDecode(s);
            return notif.NotificationDraft.fromJson(jsonMap);
          }));
      }
    } catch (_) {
      // ignore corrupt entries in demo
    }

    if (_notificationTemplates.isEmpty &&
        _demoDataService.notificationTemplates.isNotEmpty) {
      _notificationTemplates.addAll(_demoDataService.notificationTemplates);
    }
  }

  Future<void> _persistFlags() async {
    for (final e in _featureFlags.entries) {
      await _persistence.setBool('flag_${e.key}', e.value);
    }
  }

  Future<void> _persistLogs() async {
    final list = _auditLogs
        .map((a) =>
            '${a.timestamp.toIso8601String()}|${a.area}|${a.message.replaceAll('\n', ' ')}')
        .toList(growable: false);
    await _persistence.setStringList('audit_logs', list);
    await _persistence.setInt('audit_retention_days', _auditRetentionDays);
  }

  Future<void> _persistRBAC() async {
    final roles = _demoDataService.rolePermissions;
    final list = roles.entries
        .map((e) => '${e.key}:${e.value.join(',')}')
        .toList(growable: false);
    await _persistence.setStringList('rbac_roles', list);
  }

  Future<void> _persistSearch() async {
    await _persistence.setStringList('search_synonyms',
        [for (final e in _synonyms.entries) '${e.key}:${e.value}']);
    await _persistence.setStringList('search_banned', _bannedTerms.toList());
    await _persistence.setStringList('search_boosts',
        [for (final e in _boosts.entries) '${e.key}:${e.value}']);
    final catList = <String>[];
    _categoryBoosts.forEach((cat, map) {
      map.forEach((term, factor) {
        catList.add('$cat|$term|$factor');
      });
    });
    await _persistence.setStringList('search_category_boosts', catList);
  }

  Future<void> _persistGeo() async {
    await _persistence.setDouble('geo_radius', _defaultServiceRadiusKm);
    await _persistence.setStringList('geo_city_radius', [
      for (final e in _cityRadiusOverridesKm.entries) '${e.key}:${e.value}'
    ]);
  }

  Future<void> _persistSystem() async {
    await _persistence.setBool('system_maintenance', _maintenanceMode);
  }

  Future<void> _persistAdsSettings() async {
    await _persistence.setString('ads_priority_phone', _adsPriorityPhone);
  }

  // ================= Ads Settings =================
  String _adsPriorityPhone = '+91-9876543210';
  String get adsPriorityPhone => _adsPriorityPhone;
  Future<void> setAdsPriorityPhone(String phone) async {
    _adsPriorityPhone = phone.trim();
    await addAudit('ads', 'Updated priority phone to $_adsPriorityPhone');
    notifyListeners();
    await _persistAdsSettings();
  }

  // ================= Categories Management (demo, in-memory) =================
  final List<AdminCategoryData> _categories = [
    AdminCategoryData(
      id: 'cat_1',
      name: 'Cables & Wires',
      description: 'Electrical cables and wires for various applications',
      imageUrl: 'https://picsum.photos/seed/cables/400/300',
      productCount: 1250,
      industries: ['Construction', 'EPC', 'MEP', 'Industrial'],
      materials: ['Copper', 'Aluminium', 'PVC', 'XLPE'],
      isActive: true,
      priority: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AdminCategoryData(
      id: 'cat_2',
      name: 'Switchgear',
      description: 'Electrical switchgear and control equipment',
      imageUrl: 'https://picsum.photos/seed/switchgear/400/300',
      productCount: 890,
      industries: ['Industrial', 'Commercial', 'Infrastructure'],
      materials: ['Steel', 'Iron', 'Plastic'],
      isActive: true,
      priority: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    AdminCategoryData(
      id: 'cat_3',
      name: 'Transformers',
      description: 'Power transformers and distribution equipment',
      imageUrl: 'https://picsum.photos/seed/transformers/400/300',
      productCount: 450,
      industries: ['Industrial', 'Infrastructure', 'EPC'],
      materials: ['Steel', 'Iron', 'Copper'],
      isActive: true,
      priority: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    AdminCategoryData(
      id: 'cat_4',
      name: 'Meters',
      description: 'Energy meters and measurement devices',
      imageUrl: 'https://picsum.photos/seed/meters/400/300',
      productCount: 320,
      industries: ['Commercial', 'Residential', 'Industrial'],
      materials: ['Plastic', 'Steel', 'Glass'],
      isActive: true,
      priority: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    AdminCategoryData(
      id: 'cat_5',
      name: 'Solar & Storage',
      description: 'Solar panels and energy storage systems',
      imageUrl: 'https://picsum.photos/seed/solar/400/300',
      productCount: 680,
      industries: ['Solar', 'EPC', 'Commercial'],
      materials: ['Steel', 'Aluminium', 'Glass'],
      isActive: true,
      priority: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<AdminCategoryData> get categories => List.unmodifiable(_categories);
  List<AdminCategoryData> get activeCategories =>
      _categories.where((c) => c.isActive).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  // Categories CRUD operations
  Future<void> addCategory(AdminCategoryData category) async {
    _categories.add(category);

    // Sync with DemoDataService
    final frontendCategory = CategoryData(
      name: category.name,
      imageUrl: category.imageUrl,
      productCount: category.productCount,
      industries: category.industries,
      materials: category.materials,
    );
    _demoDataService.addCategory(frontendCategory);

    await addAudit('categories', 'Added category: ${category.name}');
    notifyListeners();
    await _persistCategories();
  }

  Future<void> updateCategory(AdminCategoryData updated) async {
    final idx = _categories.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _categories[idx] = updated.copyWith(updatedAt: DateTime.now());

      // Sync with DemoDataService
      final frontendCategory = CategoryData(
        name: updated.name,
        imageUrl: updated.imageUrl,
        productCount: updated.productCount,
        industries: updated.industries,
        materials: updated.materials,
      );
      _demoDataService.updateCategory(frontendCategory);

      await addAudit('categories', 'Updated category: ${updated.name}');
      notifyListeners();
      await _persistCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id);
    _categories.removeWhere((c) => c.id == id);

    // Sync with DemoDataService
    _demoDataService.removeCategory(category.name);

    await addAudit('categories', 'Deleted category: ${category.name}');
    notifyListeners();
    await _persistCategories();
  }

  Future<void> toggleCategoryActive(String id) async {
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final category = _categories[idx];
      _categories[idx] = category.copyWith(
        isActive: !category.isActive,
        updatedAt: DateTime.now(),
      );
      await addAudit('categories',
          '${category.isActive ? 'Deactivated' : 'Activated'} category: ${category.name}');
      notifyListeners();
      await _persistCategories();
    }
  }

  Future<void> reorderCategories(List<String> orderedIds) async {
    final Map<String, AdminCategoryData> categoryMap = {
      for (final category in _categories) category.id: category
    };

    _categories.clear();
    for (int i = 0; i < orderedIds.length; i++) {
      final category = categoryMap[orderedIds[i]];
      if (category != null) {
        _categories.add(category.copyWith(
          priority: i + 1,
          updatedAt: DateTime.now(),
        ));
      }
    }

    await addAudit('categories', 'Reordered categories');
    notifyListeners();
    await _persistCategories();
  }

  Future<void> _persistCategories() async {
    final List<String> categoryJsonList =
        _categories.map((c) => jsonEncode(c.toJson())).toList();
    await _persistence.setStringList('admin_categories', categoryJsonList);
  }

  Future<void> _loadCategories() async {
    final List<String>? categoryJsonList =
        await _persistence.getStringList('admin_categories');

    if (categoryJsonList != null && categoryJsonList.isNotEmpty) {
      _categories.clear();
      for (final jsonString in categoryJsonList) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final category = AdminCategoryData.fromJson(jsonMap);
          _categories.add(category);
        } catch (e) {
          debugPrint('Error loading category: $e');
        }
      }
    }
  }

  // ================= Notifications (demo, in-memory) =================
  final List<notif.NotificationTemplate> _notificationTemplates = [];
  final List<notif.NotificationDraft> _notificationDrafts = [];

  List<notif.NotificationTemplate> get notificationTemplates =>
      List.unmodifiable(_notificationTemplates);
  List<notif.NotificationDraft> get notificationDrafts =>
      List.unmodifiable(_notificationDrafts);

  Future<void> addNotificationTemplate(
      notif.NotificationTemplate template) async {
    _notificationTemplates.add(template);
    await addAudit('notifications', 'Added template ${template.name}');
    notifyListeners();
    await _persistNotificationTemplates();
  }

  Future<void> updateNotificationTemplate(
      notif.NotificationTemplate updated) async {
    final idx = _notificationTemplates.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _notificationTemplates[idx] = updated;
      await addAudit('notifications', 'Updated template ${updated.name}');
      notifyListeners();
      await _persistNotificationTemplates();
    }
  }

  Future<void> deleteNotificationTemplate(String id) async {
    _notificationTemplates.removeWhere((t) => t.id == id);
    await addAudit('notifications', 'Deleted template $id');
    notifyListeners();
    await _persistNotificationTemplates();
  }

  Future<void> saveNotificationDraft(notif.NotificationDraft draft) async {
    final idx = _notificationDrafts.indexWhere((d) => d.id == draft.id);
    if (idx == -1) {
      _notificationDrafts.add(draft);
      await addAudit('notifications', 'Created draft ${draft.id}');
    } else {
      _notificationDrafts[idx] = draft;
      await addAudit('notifications', 'Updated draft ${draft.id}');
    }
    notifyListeners();
    await _persistNotificationDrafts();
  }

  Future<void> deleteNotificationDraft(String id) async {
    _notificationDrafts.removeWhere((d) => d.id == id);
    await addAudit('notifications', 'Deleted draft $id');
    notifyListeners();
    await _persistNotificationDrafts();
  }

  // Estimate audience size for current filters
  int estimateAudienceSize(notif.AudienceFilter filter) {
    // Pending: Implement user audience estimation via DemoDataService
    return 0; // Placeholder
  }

  Future<void> sendNotification(notif.NotificationDraft draft) async {
    final size = estimateAudienceSize(draft.audience);

    // Create conversations for in-app notifications
    if (draft.channels.contains(notif.NotificationChannel.inApp)) {
      await _createInAppNotifications(draft);
    }

    // For other channels (email, SMS, push), we would integrate with external services
    // For now, we'll just log them
    if (draft.channels.contains(notif.NotificationChannel.email)) {
      await addAudit(
          'notifications', 'Email notification queued for ${draft.id}');
    }
    if (draft.channels.contains(notif.NotificationChannel.sms)) {
      await addAudit(
          'notifications', 'SMS notification queued for ${draft.id}');
    }
    if (draft.channels.contains(notif.NotificationChannel.push)) {
      await addAudit(
          'notifications', 'Push notification queued for ${draft.id}');
    }

    await addAudit('notifications',
        'Sent notification ${draft.id} to ~$size users via ${draft.channels.map((e) => e.name).join('/')}');
    notifyListeners();
  }

  Future<void> _createInAppNotifications(notif.NotificationDraft draft) async {
    // Get target users based on audience filter
    final targetUsers = _getTargetUsers(draft.audience);

    // Create a conversation for each target user
    for (final user in targetUsers) {
      final conversationId = 'notif_${draft.id}_${user.id}';
      final messageText =
          '${draft.templates[notif.NotificationChannel.inApp]?.title ?? 'Notification'}\n\n${draft.templates[notif.NotificationChannel.inApp]?.body ?? ''}';

      final conversation = Conversation(
        id: conversationId,
        title: 'System Notification',
        subtitle: messageText.length > 50
            ? '${messageText.substring(0, 50)}...'
            : messageText,
        isPinned: false,
        isSupport: false,
        messages: [
          Message(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: conversationId,
            senderType:
                MessageSenderType.support, // Use support as closest to system
            senderName: 'System',
            text: messageText,
            sentAt: DateTime.now(),
          ),
        ],
        participants: ['system', user.id],
        updatedAt: DateTime.now(),
      );

      _demoDataService.addConversation(conversation);
    }
  }

  List<AdminUser> _getTargetUsers(notif.AudienceFilter filter) {
    var users = _demoDataService.allUsers;

    // Filter by roles
    if (filter.roles.isNotEmpty) {
      users = users.where((u) => filter.roles.contains(u.role.name)).toList();
    }

    // Filter by seller status
    if (filter.isSeller != null) {
      users = users.where((u) => u.isSeller == filter.isSeller).toList();
    }

    // Filter by specific user IDs
    if (filter.userIds.isNotEmpty) {
      users = users.where((u) => filter.userIds.contains(u.id)).toList();
    }

    // Filter by states (if we had location data)
    // For now, we'll skip state filtering as we don't have location data in AdminUser

    return users;
  }

  Future<void> _persistNotificationTemplates() async {
    await _persistence.setStringList(
      'notif_templates',
      _notificationTemplates.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  Future<void> _persistNotificationDrafts() async {
    await _persistence.setStringList(
      'notif_drafts',
      _notificationDrafts.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }

  // Hero sections CRUD operations - delegate to DemoDataService
  Future<void> addHeroSection(HeroSection heroSection) async {
    _demoDataService.addHeroSection(heroSection);
    await addAudit('cms', 'Added hero section: ${heroSection.title}');
    // DemoDataService will notify listeners automatically
  }

  Future<void> updateHeroSection(HeroSection updated) async {
    final updatedWithTimestamp = updated.copyWith(updatedAt: DateTime.now());
    _demoDataService.updateHeroSection(updatedWithTimestamp);
    await addAudit('cms', 'Updated hero section: ${updated.title}');
    // DemoDataService will notify listeners automatically
  }

  Future<void> deleteHeroSection(String id) async {
    final hero = heroSections.firstWhere((h) => h.id == id);
    _demoDataService.removeHeroSection(id);
    await addAudit('cms', 'Deleted hero section: ${hero.title}');
    // DemoDataService will notify listeners automatically
  }

  Future<void> toggleHeroSectionActive(String id) async {
    final hero = heroSections.firstWhere((h) => h.id == id);
    final updatedHero = hero.copyWith(
      isActive: !hero.isActive,
      updatedAt: DateTime.now(),
    );
    _demoDataService.updateHeroSection(updatedHero);
    await addAudit('cms',
        '${hero.isActive ? 'Deactivated' : 'Activated'} hero section: ${hero.title}');
    // DemoDataService will notify listeners automatically
  }

  Future<void> reorderHeroSections(List<String> orderedIds) async {
    final Map<String, HeroSection> heroMap = {
      for (final hero in heroSections) hero.id: hero
    };

    for (int i = 0; i < orderedIds.length; i++) {
      final hero = heroMap[orderedIds[i]];
      if (hero != null) {
        final updatedHero = hero.copyWith(
          priority: i + 1,
          updatedAt: DateTime.now(),
        );
        _demoDataService.updateHeroSection(updatedHero);
      }
    }

    await addAudit('cms', 'Reordered hero sections');
    // DemoDataService will notify listeners automatically
  }

  // _persistHeroSections method removed - using DemoDataService now

  Future<void> _loadHeroSections() async {
    // Hero sections loading removed - using DemoDataService now

    // Load slide durations
    _firstSlideDurationSeconds =
        await _persistence.getInt('first_slide_duration') ?? 10;
    _otherSlidesDurationSeconds =
        await _persistence.getInt('other_slides_duration') ?? 3;
  }

  Future<void> _persistSlideDurations() async {
    await _persistence.setInt(
        'first_slide_duration', _firstSlideDurationSeconds);
    await _persistence.setInt(
        'other_slides_duration', _otherSlidesDurationSeconds);
  }

  // ================= Plan Cards (public subscription page config) =================
  final List<sub.PlanCardConfig> _planCards = [
    const sub.PlanCardConfig(
      id: 'card_plus',
      title: 'Plus',
      priceLabel: '₹1,000',
      periodLabel: 'per year',
      features: [
        'Up to 50 products',
        'Advanced lead management',
        'Priority support',
        'Featured listings',
        'Analytics dashboard',
        'Custom fields'
      ],
      isPopular: true,
    ),
    const sub.PlanCardConfig(
      id: 'card_pro',
      title: 'Pro',
      priceLabel: '₹5,000',
      periodLabel: 'per year',
      features: [
        'Unlimited products',
        'Premium lead management',
        '24/7 phone support',
        'Top listings',
        'Advanced analytics',
        'Custom branding',
        'API access',
        'Dedicated account manager'
      ],
      isPopular: false,
    ),
  ];
  List<sub.PlanCardConfig> get planCards => List.unmodifiable(_planCards);
  Future<void> addPlanCard(sub.PlanCardConfig card) async {
    _planCards.add(card);
    await addAudit('billing', 'Added plan card ${card.title}');
    notifyListeners();
    await _persistPlanCards();
  }

  Future<void> updatePlanCard(sub.PlanCardConfig updated) async {
    final i = _planCards.indexWhere((c) => c.id == updated.id);
    if (i != -1) {
      _planCards[i] = updated;
      await addAudit('billing', 'Updated plan card ${updated.title}');
      notifyListeners();
      await _persistPlanCards();
    }
  }

  Future<void> deletePlanCard(String id) async {
    _planCards.removeWhere((c) => c.id == id);
    await addAudit('billing', 'Deleted plan card $id');
    notifyListeners();
    await _persistPlanCards();
  }

  // ================= Subscription Management (demo, in-memory) =================
  final List<sub.Plan> _plans = [
    const sub.Plan(
        id: 'plan_free',
        name: 'Free',
        code: 'free',
        description: 'Basic access',
        status: sub.PlanStatus.published,
        defaultPointsPerCycle: 50,
        visiblePublicly: true,
        version: 1),
    const sub.Plan(
        id: 'plan_plus',
        name: 'Plus',
        code: 'plus',
        description: 'For growing sellers',
        status: sub.PlanStatus.published,
        defaultPointsPerCycle: 200,
        visiblePublicly: true,
        version: 1),
  ];
  final List<sub.Price> _prices = [
    const sub.Price(
        id: 'price_plus_mo',
        planId: 'plan_plus',
        currency: 'INR',
        interval: sub.BillingInterval.monthly,
        amountMinor: 49900),
    const sub.Price(
        id: 'price_plus_y',
        planId: 'plan_plus',
        currency: 'INR',
        interval: sub.BillingInterval.annual,
        amountMinor: 499000),
  ];
  final List<sub.PointsRule> _pointsRules = [
    const sub.PointsRule(
        id: 'pr_free', planId: 'plan_free', pointsPerCycle: 50),
    const sub.PointsRule(
        id: 'pr_plus',
        planId: 'plan_plus',
        pointsPerCycle: 200,
        rolloverCap: 400,
        overageUnit: 50,
        overagePriceMinor: 9900),
  ];
  final List<sub.Addon> _addons = const [
    sub.Addon(
        id: 'addon_100',
        name: 'Extra 100 points',
        recurring: false,
        amountMinor: 9900,
        pointsGranted: 100),
  ];
  final List<sub.Promotion> _promotions = const [
    sub.Promotion(
        id: 'promo_LAUNCH10',
        code: 'LAUNCH10',
        description: '10% off first cycle',
        percentOff: 10),
  ];
  final List<sub.Subscription> _subscriptions = [
    sub.Subscription(
      id: 'sub_1001',
      sellerId: 'U1002',
      planId: 'plan_plus',
      priceId: 'price_plus_mo',
      state: sub.SubscriptionState.active,
      currentPeriodStart: DateTime.now().subtract(const Duration(days: 10)),
      currentPeriodEnd: DateTime.now().add(const Duration(days: 20)),
      accumulatedPoints: 200,
      consumedPoints: 80,
    ),
  ];

  List<sub.Plan> get plans => List.unmodifiable(_plans);
  List<sub.Price> get prices => List.unmodifiable(_prices);
  List<sub.PointsRule> get pointsRules => List.unmodifiable(_pointsRules);
  List<sub.Addon> get addons => List.unmodifiable(_addons);
  List<sub.Promotion> get promotions => List.unmodifiable(_promotions);
  List<sub.Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  Future<void> createPlan(sub.Plan plan) async {
    _plans.add(plan);
    await addAudit('billing', 'Created plan ${plan.code}');
    notifyListeners();
  }

  Future<void> updatePlan(sub.Plan updated) async {
    final idx = _plans.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _plans[idx] = updated;
      await addAudit('billing', 'Updated plan ${updated.code}');
      notifyListeners();
    }
  }

  Future<void> archivePlan(String id) async {
    final idx = _plans.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _plans[idx];
      _plans[idx] = p.copyWith(status: sub.PlanStatus.archived);
      await addAudit('billing', 'Archived plan ${p.code}');
      notifyListeners();
    }
  }

  // User subscription management methods
  Future<void> updateUserSubscription(String userId, String plan) async {
    final user = _demoDataService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(plan: plan);
      _demoDataService.updateUser(updatedUser);
      await addAudit(
          'subscriptions', 'Updated user $userId subscription to $plan');
      notifyListeners();
    }
  }

  Future<void> bulkUpdateUserSubscriptions(
      List<String> userIds, String plan) async {
    for (final userId in userIds) {
      final user = _demoDataService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(plan: plan);
        _demoDataService.updateUser(updatedUser);
      }
    }
    await addAudit(
        'subscriptions', 'Bulk updated ${userIds.length} users to $plan plan');
    notifyListeners();
  }

  Future<void> upgradeUser(String userId, String newPlan) async {
    final user = _demoDataService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(plan: newPlan);
      _demoDataService.updateUser(updatedUser);
      await addAudit('subscriptions', 'Upgraded user $userId to $newPlan');
      notifyListeners();
    }
  }

  Future<void> downgradeUser(String userId, String newPlan) async {
    final user = _demoDataService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(plan: newPlan);
      _demoDataService.updateUser(updatedUser);
      await addAudit('subscriptions', 'Downgraded user $userId to $newPlan');
      notifyListeners();
    }
  }

  Future<void> cancelUserSubscription(String userId) async {
    final user = _demoDataService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(plan: 'free');
      _demoDataService.updateUser(updatedUser);
      await addAudit(
          'subscriptions', 'Cancelled subscription for user $userId');
      notifyListeners();
    }
  }

  Future<void> pauseUserSubscription(String userId) async {
    // Demo: record audit log; subscription remains same
    await addAudit('subscriptions', 'Paused subscription for user $userId');
    notifyListeners();
  }

  Future<void> extendUserSubscription(String userId, int days) async {
    // For demo purposes, we'll just log the extension
    // In a real app, you'd update subscription expiry dates
    await addAudit('subscriptions',
        'Extended subscription for user $userId by $days days');
    notifyListeners();
  }

  // Get subscription statistics
  Map<String, int> getSubscriptionStats() {
    final users = _demoDataService.allUsers;
    final stats = <String, int>{};

    for (final user in users) {
      stats[user.plan] = (stats[user.plan] ?? 0) + 1;
    }

    return stats;
  }

  List<AdminUser> getUsersByPlan(String plan) {
    return _demoDataService.allUsers
        .where((user) => user.plan == plan)
        .toList();
  }

  // State Flow Data Management - Sync with DemoDataService
  List<PowerGenerator> get allPowerGenerators =>
      _demoDataService.allPowerGenerators;

  Future<void> addPowerGeneratorToStateInfo(PowerGenerator generator) async {
    _demoDataService.addPowerGenerator(generator);
    await addAudit('state_flow', 'Added power generator: ${generator.name}');
    notifyListeners();
  }

  Future<void> updatePowerGeneratorInStateInfo(PowerGenerator generator) async {
    _demoDataService.updatePowerGenerator(generator);
    await addAudit('state_flow', 'Updated power generator: ${generator.name}');
    notifyListeners();
  }

  Future<void> removePowerGeneratorFromStateInfo(String generatorId) async {
    _demoDataService.removePowerGenerator(generatorId);
    await addAudit('state_flow', 'Removed power generator: $generatorId');
    notifyListeners();
  }

  PowerGenerator? getPowerGeneratorFromStateInfo(String generatorId) {
    return _demoDataService.getPowerGenerator(generatorId);
  }

  Future<void> addPrice(sub.Price price) async {
    _prices.add(price);
    await addAudit('billing',
        'Added price for ${price.planId} ${price.interval.name} ${price.currency} ${price.amountMinor}m');
    notifyListeners();
  }

  Future<void> upsertPointsRule(sub.PointsRule rule) async {
    final idx = _pointsRules.indexWhere((r) => r.id == rule.id);
    if (idx == -1) {
      _pointsRules.add(rule);
      await addAudit('billing', 'Added points rule for ${rule.planId}');
    } else {
      _pointsRules[idx] = rule;
      await addAudit('billing', 'Updated points rule for ${rule.planId}');
    }
    notifyListeners();
  }

  Future<void> addAddon(sub.Addon addon) async {
    _addons.add(addon);
    await addAudit('billing', 'Added addon ${addon.name}');
    notifyListeners();
  }

  Future<void> addPromotion(sub.Promotion promo) async {
    _promotions.add(promo);
    await addAudit('billing', 'Added promo ${promo.code}');
    notifyListeners();
  }

  Future<void> addSubscription(sub.Subscription s) async {
    _subscriptions.add(s);
    await addAudit('billing', 'Added subscription ${s.id}');
    notifyListeners();
  }

  Future<void> _persistPlanCards() async {
    await _persistence.setStringList(
      'plan_cards',
      _planCards.map((e) => e.toJsonString()).toList(),
    );
  }

  Future<void> _loadPlanCards() async {
    final list = await _persistence.getStringList('plan_cards');
    if (list != null && list.isNotEmpty) {
      _planCards
        ..clear()
        ..addAll(list.map(sub.PlanCardConfig.fromJsonString));
      notifyListeners();
    }
  }
}
