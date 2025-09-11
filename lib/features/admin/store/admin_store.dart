import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero_section.dart';
import '../models/notification.dart' as notif;
import '../models/subscription_models.dart' as sub;
import '../models/state_flow_admin_models.dart';
import '../../../services/demo_data_service.dart';
import '../../categories/categories_page.dart';
import '../../messaging/models.dart';
import '../../stateinfo/models/state_info_models.dart';

class AdminStore extends ChangeNotifier {
  final DemoDataService _demoDataService;
  bool _isInitialized = false;
  
  AdminStore(this._demoDataService) {
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

  // RBAC roles and permissions (demo, in-memory)
  final Map<String, Set<String>> _roleToPermissions = {
    'admin': {
      'users.read','users.write','sellers.read','sellers.write','kyc.review','products.read','products.write','uploads.review','ads.manage','leads.manage','orders.manage','messaging.moderate','cms.manage','billing.manage','search.tune','geo.manage','analytics.view','compliance.manage','system.ops','feature.flags','rbac.manage','audit.read','bulk.ops','notifications.send','export.data','dev.tools'
    },
    'seller': {'products.read','products.write','orders.manage','leads.manage','messaging.use'},
    'buyer': {'products.read','messaging.use','orders.manage'},
  };
  Map<String, Set<String>> get roleToPermissions => {
    for (final e in _roleToPermissions.entries) e.key: Set<String>.from(e.value)
  };

  Future<void> createRole(String role, {Iterable<String> permissions = const []}) async {
    if (_roleToPermissions.containsKey(role)) return;
    _roleToPermissions[role] = {...permissions};
    await addAudit('rbac', 'Created role "$role" with ${permissions.length} perms');
    notifyListeners();
    await _persistRBAC();
  }

  Future<void> deleteRole(String role) async {
    if (role == 'admin' || role == 'seller' || role == 'buyer') return; // protect core roles
    if (_roleToPermissions.remove(role) != null) {
      await addAudit('rbac', 'Deleted role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  Future<void> grantPermissionToRole(String role, String permission) async {
    final set = _roleToPermissions.putIfAbsent(role, () => <String>{});
    if (!set.contains(permission)) {
      set.add(permission);
      await addAudit('rbac', 'Granted "$permission" to role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  Future<void> revokePermissionFromRole(String role, String permission) async {
    final set = _roleToPermissions[role];
    if (set != null && set.remove(permission)) {
      await addAudit('rbac', 'Revoked "$permission" from role "$role"');
      notifyListeners();
      await _persistRBAC();
    }
  }

  bool roleHas(String role, String permission) {
    final set = _roleToPermissions[role];
    if (set == null) return false;
    return set.contains(permission);
  }

  // Search tuning (demo)
  final Map<String, String> _synonyms = { 'wire':'cable' };
  final Set<String> _bannedTerms = { 'spam', 'fraud' };
  final Map<String, double> _boosts = { 'copper': 1.2, 'pro': 1.1 };
  // Optional category-specific boosts: category => term => factor
  final Map<String, Map<String,double>> _categoryBoosts = {};
  Map<String,String> get synonyms => Map.unmodifiable(_synonyms);
  Set<String> get bannedTerms => Set.unmodifiable(_bannedTerms);
  Map<String,double> get boosts => Map.unmodifiable(_boosts);
  Map<String, Map<String,double>> get categoryBoosts => { for (final e in _categoryBoosts.entries) e.key: Map<String,double>.from(e.value) };
  Future<void> addSynonym(String a, String b) async { _synonyms[a] = b; await addAudit('search', 'Synonym $a → $b'); notifyListeners(); await _persistSearch(); }
  Future<void> removeSynonym(String a) async { _synonyms.remove(a); await addAudit('search', 'Removed synonym $a'); notifyListeners(); await _persistSearch(); }
  Future<void> addBanned(String term) async { _bannedTerms.add(term); await addAudit('search', 'Banned "$term"'); notifyListeners(); await _persistSearch(); }
  Future<void> removeBanned(String term) async { _bannedTerms.remove(term); await addAudit('search', 'Unbanned "$term"'); notifyListeners(); await _persistSearch(); }
  Future<void> setBoost(String term, double factor) async { _boosts[term] = factor; await addAudit('search', 'Boost $term=$factor'); notifyListeners(); await _persistSearch(); }
  Future<void> setCategoryBoost(String category, String term, double factor) async {
    final map = _categoryBoosts.putIfAbsent(category, () => {});
    map[term] = factor;
    await addAudit('search', 'Boost [$category] $term=$factor');
    notifyListeners();
    await _persistSearch();
  }

  // Geo management (demo)
  final Map<String, Map<String, List<String>>> _geo = {
    'Maharashtra': {
      'Mumbai': ['Andheri','Bandra','Dadar'],
      'Pune': ['Kothrud','Hinjewadi']
    },
    'Karnataka': {
      'Bengaluru': ['Whitefield','HSR','Indiranagar']
    },
  };
  double _defaultServiceRadiusKm = 25;
  // Optional per-city radius overrides: key format "State|City"
  final Map<String, double> _cityRadiusOverridesKm = {};
  Map<String, Map<String, List<String>>> get geo => _geo;
  double get defaultServiceRadiusKm => _defaultServiceRadiusKm;
  Map<String,double> get cityRadiusOverridesKm => Map.unmodifiable(_cityRadiusOverridesKm);
  Future<void> addState(String state) async { _geo.putIfAbsent(state, () => {}); await addAudit('geo', 'Added state $state'); notifyListeners(); await _persistGeo(); }
  Future<void> addCity(String state, String city) async { _geo[state] ??= {}; _geo[state]!.putIfAbsent(city, () => []); await addAudit('geo', 'Added city $city in $state'); notifyListeners(); await _persistGeo(); }
  Future<void> addArea(String state, String city, String area) async { _geo[state] ??= {}; _geo[state]![city] ??= []; if (!_geo[state]![city]!.contains(area)) _geo[state]![city]!.add(area); await addAudit('geo', 'Added area $area in $city, $state'); notifyListeners(); await _persistGeo(); }
  Future<void> removeArea(String state, String city, String area) async { _geo[state]?[city]?.remove(area); await addAudit('geo', 'Removed area $area in $city, $state'); notifyListeners(); await _persistGeo(); }
  Future<void> setDefaultRadius(double km) async { _defaultServiceRadiusKm = km; await addAudit('geo', 'Default radius set to $km km'); notifyListeners(); await _persistGeo(); }
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
  Future<void> setMaintenance(bool value) async { _maintenanceMode = value; await addAudit('system', 'Maintenance ${value? 'enabled':'disabled'}'); notifyListeners(); await _persistSystem(); }
  final List<String> _templates = ['Order Email', 'Lead Assignment'];
  List<String> get templates => List.unmodifiable(_templates);
  Future<void> addTemplate(String name) async { _templates.add(name); await addAudit('system', 'Template added: $name'); notifyListeners(); await _persistSystem(); }
  Future<void> backupNow() async { await addAudit('system', 'Backup executed'); }

  // DX helpers (demo)
  Future<void> seedDemoData() async {
    await addAudit('dev', 'Seeded demo data');
  }
  Future<void> reindexSearch() async { await addAudit('dev', 'Triggered search reindex'); }

  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);
  List<AuditLog> get auditLogs => List.unmodifiable(_auditLogs.reversed);
  int get auditRetentionDays => _auditRetentionDays;
  set auditRetentionDays(int days) { _auditRetentionDays = days; notifyListeners(); _persistLogs(); }

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
    await addAudit('cms', 'Updated slide durations: first=${_firstSlideDurationSeconds}s, others=${_otherSlidesDurationSeconds}s');
    notifyListeners();
    await _persistSlideDurations();
  }

  // Hero sections getters - delegate to DemoDataService
  List<HeroSection> get activeHeroSections => heroSections
      .where((h) => h.isActive)
      .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

  String exportAuditCsv() {
    final header = 'timestamp,area,message';
    final rows = _auditLogs.map((a)=>[
      a.timestamp.toIso8601String(),
      a.area,
      a.message.replaceAll(',', ' '),
    ].join(',')).join('\n');
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
      role: 'seller',
      isSeller: true,
      plan: plan,
      sellerProfile: u.sellerProfile ?? const SellerProfile(),
    );
    _demoDataService.updateUser(updated);
    await addAudit('users', 'Promoted $id to seller (plan=$plan)');
    // DemoDataService will notify listeners automatically
  }

  Future<void> demoteToBuyer(String id) async {
    final u = allUsers.firstWhere((user) => user.id == id);
    final updated = u.copyWith(
      role: 'buyer',
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
      role: 'seller',
      status: 'active',
      createdAt: DateTime.now(),
      isSeller: true,
      plan: plan,
      sellerProfile: profile ?? const SellerProfile(),
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

  Future<void> refund(String id, {required double amount, String? reason}) async {
    await addAudit('billing', 'Refunded $id amount=₹${amount.toStringAsFixed(2)} reason="${reason?.replaceAll('\n',' ') ?? ''}"');
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

  Future<void> bulkUpdateUsersStatus(Iterable<String> userIds, String status) async {
    for (final userId in userIds) {
      final user = _demoDataService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(status: status);
        _demoDataService.updateUser(updatedUser);
      }
    }
    await addAudit('users', 'Bulk updated ${userIds.length} users to $status');
    notifyListeners();
  }

  void exportUsersCsv(void Function(String csv) onReady) {
    final users = _demoDataService.allUsers;
    final header = 'id,name,email,role,status,createdAt,plan,isSeller,legalName,gstin,address,materials';
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
        sellerProfile?.legalName ?? '',
        sellerProfile?.gstin ?? '',
        sellerProfile?.address ?? '',
        sellerProfile?.materials.join(';') ?? '',
      ].map((field) => '"${field.toString().replaceAll('"', '""')}"').join(',');
    }).toList();
    
    final csv = [header, ...rows].join('\n');
    onReady(csv);
    addAudit('users', 'Exported users CSV (${users.length})');
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    // Flags
    final keys = _featureFlags.keys.toList();
    for (final k in keys) {
      final v = prefs.getBool('flag_$k');
      if (v != null) {
        _featureFlags[k] = v;
      }
    }
    // Logs
    final raw = prefs.getStringList('audit_logs') ?? [];
    _auditLogs
      ..clear()
      ..addAll(raw.map((s) {
        final parts = s.split('|');
        if (parts.length < 3) return AuditLog(timestamp: DateTime.now(), area: 'unknown', message: s);
        return AuditLog(timestamp: DateTime.parse(parts[0]), area: parts[1], message: parts.sublist(2).join('|'));
      }));
    _auditRetentionDays = prefs.getInt('audit_retention_days') ?? _auditRetentionDays;
    notifyListeners();

    // RBAC
    final rbacRaw = prefs.getStringList('rbac_roles') ?? [];
    if (rbacRaw.isNotEmpty) {
      _roleToPermissions
        ..clear()
        ..addAll({
          for (final line in rbacRaw)
            if (line.contains(':'))
              line.split(':')[0]: line.split(':').length > 1 && line.split(':')[1].isNotEmpty
                ? line.split(':')[1].split(',').where((e)=>e.isNotEmpty).toSet()
                : <String>{}
        });
    }

    // Search
    final syn = prefs.getStringList('search_synonyms') ?? [];
    if (syn.isNotEmpty) { _synonyms
      ..clear()
      ..addAll({ for (final s in syn) if (s.contains(':')) s.split(':')[0]: s.split(':')[1] }); }
    final ban = prefs.getStringList('search_banned') ?? [];
    if (ban.isNotEmpty) { _bannedTerms
      ..clear()
      ..addAll(ban); }
    final bst = prefs.getStringList('search_boosts') ?? [];
    if (bst.isNotEmpty) { _boosts
      ..clear()
      ..addAll({ for (final s in bst) if (s.contains(':')) s.split(':')[0]: double.tryParse(s.split(':')[1]) ?? 1.0 }); }
    final cbst = prefs.getStringList('search_category_boosts') ?? [];
    if (cbst.isNotEmpty) {
      _categoryBoosts
        ..clear();
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
    _defaultServiceRadiusKm = prefs.getDouble('geo_radius') ?? _defaultServiceRadiusKm;
    final cityOverrides = prefs.getStringList('geo_city_radius') ?? [];
    _cityRadiusOverridesKm
      ..clear()
      ..addAll({
        for (final s in cityOverrides)
          if (s.contains(':')) s.split(':')[0]: double.tryParse(s.split(':')[1]) ?? _defaultServiceRadiusKm
      });

    // System
    _maintenanceMode = prefs.getBool('system_maintenance') ?? _maintenanceMode;
    
    // Ads settings
    _adsPriorityPhone = prefs.getString('ads_priority_phone') ?? _adsPriorityPhone;

    // Load hero sections
    await _loadHeroSections();
    await _loadPlanCards();
    
    // Load categories
    await _loadCategories();
    
    // Load state flow data
    await _loadStateFlowData();

    // Notifications: templates & drafts
    try {
      final tmplList = prefs.getStringList('notif_templates') ?? [];
      if (tmplList.isNotEmpty) {
        _notificationTemplates
          ..clear()
          ..addAll(tmplList.map((s) {
            final Map<String, dynamic> jsonMap = jsonDecode(s);
            return notif.NotificationTemplate.fromJson(jsonMap);
          }));
      }
      final draftList = prefs.getStringList('notif_drafts') ?? [];
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
  }

  Future<void> _persistFlags() async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in _featureFlags.entries) {
      await prefs.setBool('flag_${e.key}', e.value);
    }
  }

  Future<void> _persistLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _auditLogs
        .map((a) => '${a.timestamp.toIso8601String()}|${a.area}|${a.message.replaceAll('\n', ' ')}')
        .toList(growable: false);
    await prefs.setStringList('audit_logs', list);
    await prefs.setInt('audit_retention_days', _auditRetentionDays);
  }

  Future<void> _persistRBAC() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _roleToPermissions.entries
        .map((e) => '${e.key}:${e.value.join(',')}')
        .toList(growable: false);
    await prefs.setStringList('rbac_roles', list);
  }

  Future<void> _persistSearch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_synonyms', [ for (final e in _synonyms.entries) '${e.key}:${e.value}' ]);
    await prefs.setStringList('search_banned', _bannedTerms.toList());
    await prefs.setStringList('search_boosts', [ for (final e in _boosts.entries) '${e.key}:${e.value}' ]);
    final catList = <String>[];
    _categoryBoosts.forEach((cat, map) {
      map.forEach((term, factor) { catList.add('$cat|$term|$factor'); });
    });
    await prefs.setStringList('search_category_boosts', catList);
  }

  Future<void> _persistGeo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('geo_radius', _defaultServiceRadiusKm);
    await prefs.setStringList('geo_city_radius', [ for (final e in _cityRadiusOverridesKm.entries) '${e.key}:${e.value}' ]);
  }

  Future<void> _persistSystem() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('system_maintenance', _maintenanceMode);
  }

  Future<void> _persistAdsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ads_priority_phone', _adsPriorityPhone);
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
  List<AdminCategoryData> get activeCategories => _categories
      .where((c) => c.isActive)
      .toList()
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
      await addAudit('categories', '${category.isActive ? 'Deactivated' : 'Activated'} category: ${category.name}');
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
    final prefs = await SharedPreferences.getInstance();
    final List<String> categoryJsonList = _categories
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList('admin_categories', categoryJsonList);
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? categoryJsonList = prefs.getStringList('admin_categories');
    
    if (categoryJsonList != null && categoryJsonList.isNotEmpty) {
      _categories.clear();
      for (final jsonString in categoryJsonList) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final category = AdminCategoryData.fromJson(jsonMap);
          _categories.add(category);
        } catch (e) {
          print('Error loading category: $e');
        }
      }
    }
  }

  // ================= Notifications (demo, in-memory) =================
  final List<notif.NotificationTemplate> _notificationTemplates = [
    notif.NotificationTemplate(
      id: 'tmpl_welcome_push',
      name: 'Welcome Push',
      channel: notif.NotificationChannel.push,
      title: 'Welcome to Vidyut, {{name}}',
      body: 'Discover components and trusted sellers near you.',
    ),
  ];
  final List<notif.NotificationDraft> _notificationDrafts = [];

  List<notif.NotificationTemplate> get notificationTemplates => List.unmodifiable(_notificationTemplates);
  List<notif.NotificationDraft> get notificationDrafts => List.unmodifiable(_notificationDrafts);

  Future<void> addNotificationTemplate(notif.NotificationTemplate template) async {
    _notificationTemplates.add(template);
    await addAudit('notifications', 'Added template ${template.name}');
    notifyListeners();
    await _persistNotificationTemplates();
  }

  Future<void> updateNotificationTemplate(notif.NotificationTemplate updated) async {
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
    // TODO: Implement user audience estimation via DemoDataService
    return 0; // Placeholder
  }

  String _pseudoUserState(AdminUser u) {
    // TODO: Implement user state mapping via DemoDataService
    return 'Unknown'; // Placeholder
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
      await addAudit('notifications', 'Email notification queued for ${draft.id}');
    }
    if (draft.channels.contains(notif.NotificationChannel.sms)) {
      await addAudit('notifications', 'SMS notification queued for ${draft.id}');
    }
    if (draft.channels.contains(notif.NotificationChannel.push)) {
      await addAudit('notifications', 'Push notification queued for ${draft.id}');
    }
    
    await addAudit('notifications', 'Sent notification ${draft.id} to ~$size users via ${draft.channels.map((e)=>e.name).join('/')}');
    notifyListeners();
  }

  Future<void> _createInAppNotifications(notif.NotificationDraft draft) async {
    // Get target users based on audience filter
    final targetUsers = _getTargetUsers(draft.audience);
    
    // Create a conversation for each target user
    for (final user in targetUsers) {
      final conversationId = 'notif_${draft.id}_${user.id}';
      final messageText = '${draft.templates[notif.NotificationChannel.inApp]?.title ?? 'Notification'}\n\n${draft.templates[notif.NotificationChannel.inApp]?.body ?? ''}';
      
      final conversation = Conversation(
        id: conversationId,
        title: 'System Notification',
        subtitle: messageText.length > 50 ? '${messageText.substring(0, 50)}...' : messageText,
        isPinned: false,
        isSupport: false,
        messages: [
          Message(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: conversationId,
            senderType: MessageSenderType.support, // Use support as closest to system
            senderName: 'System',
            text: messageText,
            sentAt: DateTime.now(),
          ),
        ],
      );
      
      _demoDataService.addConversation(conversation);
    }
  }

  List<AdminUser> _getTargetUsers(notif.AudienceFilter filter) {
    var users = _demoDataService.allUsers;
    
    // Filter by roles
    if (filter.roles.isNotEmpty) {
      users = users.where((u) => filter.roles.contains(u.role)).toList();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_templates', _notificationTemplates.map((t) => jsonEncode(t.toJson())).toList());
  }

  Future<void> _persistNotificationDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_drafts', _notificationDrafts.map((d) => jsonEncode(d.toJson())).toList());
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
    await addAudit('cms', '${hero.isActive ? 'Deactivated' : 'Activated'} hero section: ${hero.title}');
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
    final prefs = await SharedPreferences.getInstance();
    // Hero sections loading removed - using DemoDataService now
    
    // Load slide durations
    _firstSlideDurationSeconds = prefs.getInt('first_slide_duration') ?? 10;
    _otherSlidesDurationSeconds = prefs.getInt('other_slides_duration') ?? 3;
  }

  Future<void> _persistSlideDurations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('first_slide_duration', _firstSlideDurationSeconds);
    await prefs.setInt('other_slides_duration', _otherSlidesDurationSeconds);
  }

  // ================= Plan Cards (public subscription page config) =================
  final List<sub.PlanCardConfig> _planCards = [
    sub.PlanCardConfig(
      id: 'card_plus',
      title: 'Plus',
      priceLabel: '₹1,000',
      periodLabel: 'per year',
      features: const ['Up to 50 products','Advanced lead management','Priority support','Featured listings','Analytics dashboard','Custom fields'],
      isPopular: true,
    ),
    sub.PlanCardConfig(
      id: 'card_pro',
      title: 'Pro',
      priceLabel: '₹5,000',
      periodLabel: 'per year',
      features: const ['Unlimited products','Premium lead management','24/7 phone support','Top listings','Advanced analytics','Custom branding','API access','Dedicated account manager'],
      isPopular: false,
    ),
  ];
  List<sub.PlanCardConfig> get planCards => List.unmodifiable(_planCards);
  Future<void> addPlanCard(sub.PlanCardConfig card) async { _planCards.add(card); await addAudit('billing', 'Added plan card ${card.title}'); notifyListeners(); await _persistPlanCards(); }
  Future<void> updatePlanCard(sub.PlanCardConfig updated) async { final i = _planCards.indexWhere((c) => c.id == updated.id); if (i != -1) { _planCards[i] = updated; await addAudit('billing', 'Updated plan card ${updated.title}'); notifyListeners(); await _persistPlanCards(); } }
  Future<void> deletePlanCard(String id) async { _planCards.removeWhere((c) => c.id == id); await addAudit('billing', 'Deleted plan card $id'); notifyListeners(); await _persistPlanCards(); }

  // ================= Subscription Management (demo, in-memory) =================
  final List<sub.Plan> _plans = [
    const sub.Plan(id: 'plan_free', name: 'Free', code: 'free', description: 'Basic access', status: sub.PlanStatus.published, defaultPointsPerCycle: 50, visiblePublicly: true, version: 1),
    const sub.Plan(id: 'plan_plus', name: 'Plus', code: 'plus', description: 'For growing sellers', status: sub.PlanStatus.published, defaultPointsPerCycle: 200, visiblePublicly: true, version: 1),
  ];
  final List<sub.Price> _prices = [
    sub.Price(id: 'price_plus_mo', planId: 'plan_plus', currency: 'INR', interval: sub.BillingInterval.monthly, amountMinor: 49900),
    sub.Price(id: 'price_plus_y', planId: 'plan_plus', currency: 'INR', interval: sub.BillingInterval.annual, amountMinor: 499000),
  ];
  final List<sub.PointsRule> _pointsRules = [
    const sub.PointsRule(id: 'pr_free', planId: 'plan_free', pointsPerCycle: 50),
    const sub.PointsRule(id: 'pr_plus', planId: 'plan_plus', pointsPerCycle: 200, rolloverCap: 400, overageUnit: 50, overagePriceMinor: 9900),
  ];
  final List<sub.Addon> _addons = const [
    sub.Addon(id: 'addon_100', name: 'Extra 100 points', recurring: false, amountMinor: 9900, pointsGranted: 100),
  ];
  final List<sub.Promotion> _promotions = const [
    sub.Promotion(id: 'promo_LAUNCH10', code: 'LAUNCH10', description: '10% off first cycle', percentOff: 10),
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
      await addAudit('subscriptions', 'Updated user $userId subscription to $plan');
      notifyListeners();
    }
  }

  Future<void> bulkUpdateUserSubscriptions(List<String> userIds, String plan) async {
    for (final userId in userIds) {
      final user = _demoDataService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(plan: plan);
        _demoDataService.updateUser(updatedUser);
      }
    }
    await addAudit('subscriptions', 'Bulk updated ${userIds.length} users to $plan plan');
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
      await addAudit('subscriptions', 'Cancelled subscription for user $userId');
      notifyListeners();
    }
  }

  Future<void> extendUserSubscription(String userId, int days) async {
    // For demo purposes, we'll just log the extension
    // In a real app, you'd update subscription expiry dates
    await addAudit('subscriptions', 'Extended subscription for user $userId by $days days');
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
    return _demoDataService.allUsers.where((user) => user.plan == plan).toList();
  }

  // State Flow Data Management - Sync with DemoDataService
  List<PowerGenerator> get allPowerGenerators => _demoDataService.allPowerGenerators;

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
    await addAudit('billing', 'Added price for ${price.planId} ${price.interval.name} ${price.currency} ${price.amountMinor}m');
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

  Future<void> addAddon(sub.Addon addon) async { _addons.add(addon); await addAudit('billing', 'Added addon ${addon.name}'); notifyListeners(); }
  Future<void> addPromotion(sub.Promotion promo) async { _promotions.add(promo); await addAudit('billing', 'Added promo ${promo.code}'); notifyListeners(); }
  Future<void> addSubscription(sub.Subscription s) async { _subscriptions.add(s); await addAudit('billing', 'Added subscription ${s.id}'); notifyListeners(); }

  Future<void> _persistPlanCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('plan_cards', _planCards.map((e) => e.toJsonString()).toList());
  }

  Future<void> _loadPlanCards() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('plan_cards');
    if (list != null && list.isNotEmpty) {
      _planCards
        ..clear()
        ..addAll(list.map(sub.PlanCardConfig.fromJsonString));
      notifyListeners();
    }
  }

  // ================= STATE FLOW MANAGEMENT =================
  
  // Custom Fields Management
  final List<CustomField> _customFields = [];
  final Map<EntityType, List<String>> _entityCustomFields = {};
  
  List<CustomField> get customFields => List.unmodifiable(_customFields);
  
  List<CustomField> getCustomFieldsForEntity(EntityType entityType) {
    final fieldIds = _entityCustomFields[entityType] ?? [];
    return _customFields.where((field) => fieldIds.contains(field.id)).toList();
  }
  
  Future<void> addCustomField(CustomField field, {EntityType? entityType}) async {
    _customFields.add(field);
    if (entityType != null) {
      final fieldIds = _entityCustomFields.putIfAbsent(entityType, () => []);
      if (!fieldIds.contains(field.id)) {
        fieldIds.add(field.id);
      }
    }
    await addAudit('state_flow', 'Added custom field: ${field.label}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> updateCustomField(CustomField updated) async {
    final idx = _customFields.indexWhere((f) => f.id == updated.id);
    if (idx != -1) {
      _customFields[idx] = updated.copyWith(updatedAt: DateTime.now());
      await addAudit('state_flow', 'Updated custom field: ${updated.label}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  Future<void> deleteCustomField(String fieldId) async {
    final field = _customFields.firstWhere((f) => f.id == fieldId);
    _customFields.removeWhere((f) => f.id == fieldId);
    
    // Remove from all entity types
    _entityCustomFields.forEach((entityType, fieldIds) {
      fieldIds.remove(fieldId);
    });
    
    await addAudit('state_flow', 'Deleted custom field: ${field.label}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  // Custom Tabs Management
  final List<CustomTab> _customTabs = [];
  final Map<EntityType, List<String>> _entityCustomTabs = {};
  
  List<CustomTab> get customTabs => List.unmodifiable(_customTabs);
  
  List<CustomTab> getCustomTabsForEntity(EntityType entityType) {
    final tabIds = _entityCustomTabs[entityType] ?? [];
    return _customTabs.where((tab) => tabIds.contains(tab.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
  
  Future<void> addCustomTab(CustomTab tab, EntityType entityType) async {
    _customTabs.add(tab);
    final tabIds = _entityCustomTabs.putIfAbsent(entityType, () => []);
    if (!tabIds.contains(tab.id)) {
      tabIds.add(tab.id);
    }
    await addAudit('state_flow', 'Added custom tab: ${tab.label} for ${entityType.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> updateCustomTab(CustomTab updated) async {
    final idx = _customTabs.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _customTabs[idx] = updated.copyWith(updatedAt: DateTime.now());
      await addAudit('state_flow', 'Updated custom tab: ${updated.label}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  Future<void> deleteCustomTab(String tabId) async {
    final tab = _customTabs.firstWhere((t) => t.id == tabId);
    _customTabs.removeWhere((t) => t.id == tabId);
    
    // Remove from all entity types
    _entityCustomTabs.forEach((entityType, tabIds) {
      tabIds.remove(tabId);
    });
    
    await addAudit('state_flow', 'Deleted custom tab: ${tab.label}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> reorderCustomTabs(EntityType entityType, List<String> orderedTabIds) async {
    for (int i = 0; i < orderedTabIds.length; i++) {
      final tabIdx = _customTabs.indexWhere((t) => t.id == orderedTabIds[i]);
      if (tabIdx != -1) {
        _customTabs[tabIdx] = _customTabs[tabIdx].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );
      }
    }
    await addAudit('state_flow', 'Reordered tabs for ${entityType.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  // Entity Templates Management
  final List<EntityTemplate> _entityTemplates = [];
  
  List<EntityTemplate> get entityTemplates => List.unmodifiable(_entityTemplates);
  
  List<EntityTemplate> getTemplatesForEntityType(EntityType entityType) {
    return _entityTemplates.where((t) => t.entityType == entityType).toList();
  }
  
  EntityTemplate? getDefaultTemplate(EntityType entityType) {
    try {
      return _entityTemplates.firstWhere(
        (t) => t.entityType == entityType && t.isDefault,
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> addEntityTemplate(EntityTemplate template) async {
    // If this is marked as default, unset other defaults for the same entity type
    if (template.isDefault) {
      for (int i = 0; i < _entityTemplates.length; i++) {
        if (_entityTemplates[i].entityType == template.entityType && _entityTemplates[i].isDefault) {
          _entityTemplates[i] = EntityTemplate(
            id: _entityTemplates[i].id,
            name: _entityTemplates[i].name,
            entityType: _entityTemplates[i].entityType,
            description: _entityTemplates[i].description,
            tabs: _entityTemplates[i].tabs,
            globalFields: _entityTemplates[i].globalFields,
            defaultValues: _entityTemplates[i].defaultValues,
            isDefault: false,
            isActive: _entityTemplates[i].isActive,
            createdAt: _entityTemplates[i].createdAt,
            updatedAt: DateTime.now(),
          );
        }
      }
    }
    
    _entityTemplates.add(template);
    await addAudit('state_flow', 'Added entity template: ${template.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> updateEntityTemplate(EntityTemplate updated) async {
    final idx = _entityTemplates.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      // Handle default template logic
      if (updated.isDefault) {
        for (int i = 0; i < _entityTemplates.length; i++) {
          if (i != idx && _entityTemplates[i].entityType == updated.entityType && _entityTemplates[i].isDefault) {
            _entityTemplates[i] = EntityTemplate(
              id: _entityTemplates[i].id,
              name: _entityTemplates[i].name,
              entityType: _entityTemplates[i].entityType,
              description: _entityTemplates[i].description,
              tabs: _entityTemplates[i].tabs,
              globalFields: _entityTemplates[i].globalFields,
              defaultValues: _entityTemplates[i].defaultValues,
              isDefault: false,
              isActive: _entityTemplates[i].isActive,
              createdAt: _entityTemplates[i].createdAt,
              updatedAt: DateTime.now(),
            );
          }
        }
      }
      
      _entityTemplates[idx] = EntityTemplate(
        id: updated.id,
        name: updated.name,
        entityType: updated.entityType,
        description: updated.description,
        tabs: updated.tabs,
        globalFields: updated.globalFields,
        defaultValues: updated.defaultValues,
        isDefault: updated.isDefault,
        isActive: updated.isActive,
        createdAt: updated.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await addAudit('state_flow', 'Updated entity template: ${updated.name}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  Future<void> deleteEntityTemplate(String templateId) async {
    final template = _entityTemplates.firstWhere((t) => t.id == templateId);
    _entityTemplates.removeWhere((t) => t.id == templateId);
    await addAudit('state_flow', 'Deleted entity template: ${template.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  // Admin Power Generators Management
  final List<AdminPowerGenerator> _adminPowerGenerators = [];
  
  List<AdminPowerGenerator> get adminPowerGenerators => List.unmodifiable(_adminPowerGenerators);
  
  List<AdminPowerGenerator> get publishedPowerGenerators => 
      _adminPowerGenerators.where((g) => g.isPublished).toList();
  
  Future<void> addAdminPowerGenerator(AdminPowerGenerator generator) async {
    _adminPowerGenerators.add(generator);
    await addAudit('state_flow', 'Added power generator: ${generator.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> updateAdminPowerGenerator(AdminPowerGenerator updated) async {
    final idx = _adminPowerGenerators.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      _adminPowerGenerators[idx] = updated;
      await addAudit('state_flow', 'Updated power generator: ${updated.name}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  Future<void> deleteAdminPowerGenerator(String generatorId) async {
    final generator = _adminPowerGenerators.firstWhere((g) => g.id == generatorId);
    _adminPowerGenerators.removeWhere((g) => g.id == generatorId);
    await addAudit('state_flow', 'Deleted power generator: ${generator.name}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> togglePowerGeneratorPublished(String generatorId) async {
    final idx = _adminPowerGenerators.indexWhere((g) => g.id == generatorId);
    if (idx != -1) {
      final generator = _adminPowerGenerators[idx];
      _adminPowerGenerators[idx] = generator.copyWith(
        isPublished: !generator.isPublished,
        publishedAt: !generator.isPublished ? DateTime.now() : null,
      );
      await addAudit('state_flow', '${generator.isPublished ? 'Unpublished' : 'Published'} power generator: ${generator.name}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  // Media Management
  final List<MediaAsset> _mediaAssets = [];
  
  List<MediaAsset> get mediaAssets => List.unmodifiable(_mediaAssets);
  
  List<MediaAsset> get imageAssets => _mediaAssets
      .where((asset) => asset.mimeType.startsWith('image/'))
      .toList();
  
  List<MediaAsset> get documentAssets => _mediaAssets
      .where((asset) => !asset.mimeType.startsWith('image/') && !asset.mimeType.startsWith('video/'))
      .toList();
  
  Future<void> addMediaAsset(MediaAsset asset) async {
    _mediaAssets.add(asset);
    await addAudit('state_flow', 'Uploaded media: ${asset.originalName}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> updateMediaAsset(MediaAsset updated) async {
    final idx = _mediaAssets.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _mediaAssets[idx] = updated;
      await addAudit('state_flow', 'Updated media: ${updated.originalName}');
      notifyListeners();
      await _persistStateFlowData();
    }
  }
  
  Future<void> deleteMediaAsset(String assetId) async {
    final asset = _mediaAssets.firstWhere((a) => a.id == assetId);
    _mediaAssets.removeWhere((a) => a.id == assetId);
    await addAudit('state_flow', 'Deleted media: ${asset.originalName}');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  Future<void> bulkDeleteMediaAssets(List<String> assetIds) async {
    final deletedCount = assetIds.length;
    _mediaAssets.removeWhere((a) => assetIds.contains(a.id));
    await addAudit('state_flow', 'Bulk deleted $deletedCount media assets');
    notifyListeners();
    await _persistStateFlowData();
  }
  
  List<MediaAsset> searchMediaAssets({
    String? query,
    String? mimeType,
    List<String>? tags,
    String? uploadedBy,
    DateTime? uploadedAfter,
    DateTime? uploadedBefore,
  }) {
    return _mediaAssets.where((asset) {
      if (query != null && query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        if (!asset.originalName.toLowerCase().contains(searchQuery) &&
            !(asset.caption?.toLowerCase().contains(searchQuery) ?? false) &&
            !(asset.altText?.toLowerCase().contains(searchQuery) ?? false)) {
          return false;
        }
      }
      
      if (mimeType != null && !asset.mimeType.startsWith(mimeType)) {
        return false;
      }
      
      if (tags != null && tags.isNotEmpty) {
        if (!tags.any((tag) => asset.tags.contains(tag))) {
          return false;
        }
      }
      
      if (uploadedBy != null && asset.uploadedBy != uploadedBy) {
        return false;
      }
      
      if (uploadedAfter != null && asset.uploadedAt.isBefore(uploadedAfter)) {
        return false;
      }
      
      if (uploadedBefore != null && asset.uploadedAt.isAfter(uploadedBefore)) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Search and Filter for State Flow Entities
  List<AdminPowerGenerator> searchPowerGenerators(StateFlowSearchFilter filter) {
    return _adminPowerGenerators.where((generator) {
      if (filter.query != null && filter.query!.isNotEmpty) {
        final query = filter.query!.toLowerCase();
        if (!generator.name.toLowerCase().contains(query) &&
            !generator.description.toLowerCase().contains(query) &&
            !generator.location.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      if (filter.isPublished != null && generator.isPublished != filter.isPublished) {
        return false;
      }
      
      if (filter.location != null && 
          !generator.location.toLowerCase().contains(filter.location!.toLowerCase())) {
        return false;
      }
      
      if (filter.tags != null && filter.tags!.isNotEmpty) {
        if (!filter.tags!.any((tag) => generator.tags.contains(tag))) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  // Data Import/Export
  Map<String, dynamic> exportStateFlowData() {
    return {
      'customFields': _customFields.map((f) => f.toJson()).toList(),
      'entityCustomFields': _entityCustomFields.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'customTabs': _customTabs.map((t) => t.toJson()).toList(),
      'entityCustomTabs': _entityCustomTabs.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'entityTemplates': _entityTemplates.map((t) => t.toJson()).toList(),
      'adminPowerGenerators': _adminPowerGenerators.map((g) => g.toJson()).toList(),
      'mediaAssets': _mediaAssets.map((a) => a.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
  
  Future<void> importStateFlowData(Map<String, dynamic> data) async {
    try {
      // Import custom fields
      if (data['customFields'] != null) {
        _customFields.clear();
        _customFields.addAll((data['customFields'] as List<dynamic>)
            .map((f) => CustomField.fromJson(f as Map<String, dynamic>)));
      }
      
      // Import entity custom fields mappings
      if (data['entityCustomFields'] != null) {
        _entityCustomFields.clear();
        (data['entityCustomFields'] as Map<String, dynamic>).forEach((key, value) {
          final entityType = EntityType.values.byName(key);
          _entityCustomFields[entityType] = (value as List<dynamic>).cast<String>();
        });
      }
      
      // Import custom tabs
      if (data['customTabs'] != null) {
        _customTabs.clear();
        _customTabs.addAll((data['customTabs'] as List<dynamic>)
            .map((t) => CustomTab.fromJson(t as Map<String, dynamic>)));
      }
      
      // Import entity custom tabs mappings
      if (data['entityCustomTabs'] != null) {
        _entityCustomTabs.clear();
        (data['entityCustomTabs'] as Map<String, dynamic>).forEach((key, value) {
          final entityType = EntityType.values.byName(key);
          _entityCustomTabs[entityType] = (value as List<dynamic>).cast<String>();
        });
      }
      
      // Import entity templates
      if (data['entityTemplates'] != null) {
        _entityTemplates.clear();
        _entityTemplates.addAll((data['entityTemplates'] as List<dynamic>)
            .map((t) => EntityTemplate.fromJson(t as Map<String, dynamic>)));
      }
      
      // Import admin power generators
      if (data['adminPowerGenerators'] != null) {
        _adminPowerGenerators.clear();
        _adminPowerGenerators.addAll((data['adminPowerGenerators'] as List<dynamic>)
            .map((g) => AdminPowerGenerator.fromJson(g as Map<String, dynamic>)));
      }
      
      // Import media assets
      if (data['mediaAssets'] != null) {
        _mediaAssets.clear();
        _mediaAssets.addAll((data['mediaAssets'] as List<dynamic>)
            .map((a) => MediaAsset.fromJson(a as Map<String, dynamic>)));
      }
      
      await addAudit('state_flow', 'Imported state flow data');
      notifyListeners();
      await _persistStateFlowData();
    } catch (e) {
      await addAudit('state_flow', 'Failed to import state flow data: $e');
      rethrow;
    }
  }
  
  // Analytics placeholder - would connect to actual analytics service
  Future<StateFlowAnalytics> getEntityAnalytics(String entityId, EntityType entityType, 
      {DateTime? startDate, DateTime? endDate}) async {
    // This would typically fetch from an analytics service
    // For now, return mock data
    return StateFlowAnalytics(
      entityId: entityId,
      entityType: entityType,
      viewCount: 1250,
      uniqueViewers: 890,
      avgTimeSpent: 180.5,
      tabViews: {'overview': 450, 'details': 320, 'posts': 280},
      searchTerms: {'power': 45, 'electricity': 32, 'generation': 28},
      deviceTypes: {'mobile': 60, 'desktop': 35, 'tablet': 5},
      locations: {'Mumbai': 25, 'Delhi': 20, 'Bangalore': 15},
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
    );
  }
  
  Future<void> _persistStateFlowData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Persist custom fields
    await prefs.setStringList('state_flow_custom_fields', 
        _customFields.map((f) => jsonEncode(f.toJson())).toList());
    
    // Persist entity custom fields mappings
    final entityFieldsJson = <String>[];
    _entityCustomFields.forEach((entityType, fieldIds) {
      entityFieldsJson.add('${entityType.name}:${fieldIds.join(',')}');
    });
    await prefs.setStringList('state_flow_entity_fields', entityFieldsJson);
    
    // Persist custom tabs
    await prefs.setStringList('state_flow_custom_tabs',
        _customTabs.map((t) => jsonEncode(t.toJson())).toList());
    
    // Persist entity custom tabs mappings
    final entityTabsJson = <String>[];
    _entityCustomTabs.forEach((entityType, tabIds) {
      entityTabsJson.add('${entityType.name}:${tabIds.join(',')}');
    });
    await prefs.setStringList('state_flow_entity_tabs', entityTabsJson);
    
    // Persist entity templates
    await prefs.setStringList('state_flow_entity_templates',
        _entityTemplates.map((t) => jsonEncode(t.toJson())).toList());
    
    // Persist admin power generators
    await prefs.setStringList('state_flow_admin_generators',
        _adminPowerGenerators.map((g) => jsonEncode(g.toJson())).toList());
    
    // Persist media assets
    await prefs.setStringList('state_flow_media_assets',
        _mediaAssets.map((a) => jsonEncode(a.toJson())).toList());
  }
  
  Future<void> _loadStateFlowData() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Load custom fields
      final customFieldsJson = prefs.getStringList('state_flow_custom_fields') ?? [];
      if (customFieldsJson.isNotEmpty) {
        _customFields.clear();
        _customFields.addAll(customFieldsJson.map((json) => 
            CustomField.fromJson(jsonDecode(json) as Map<String, dynamic>)));
      }
      
      // Load entity custom fields mappings
      final entityFieldsJson = prefs.getStringList('state_flow_entity_fields') ?? [];
      if (entityFieldsJson.isNotEmpty) {
        _entityCustomFields.clear();
        for (final mapping in entityFieldsJson) {
          final parts = mapping.split(':');
          if (parts.length == 2) {
            final entityType = EntityType.values.byName(parts[0]);
            final fieldIds = parts[1].split(',').where((id) => id.isNotEmpty).toList();
            _entityCustomFields[entityType] = fieldIds;
          }
        }
      }
      
      // Load custom tabs
      final customTabsJson = prefs.getStringList('state_flow_custom_tabs') ?? [];
      if (customTabsJson.isNotEmpty) {
        _customTabs.clear();
        _customTabs.addAll(customTabsJson.map((json) => 
            CustomTab.fromJson(jsonDecode(json) as Map<String, dynamic>)));
      }
      
      // Load entity custom tabs mappings
      final entityTabsJson = prefs.getStringList('state_flow_entity_tabs') ?? [];
      if (entityTabsJson.isNotEmpty) {
        _entityCustomTabs.clear();
        for (final mapping in entityTabsJson) {
          final parts = mapping.split(':');
          if (parts.length == 2) {
            final entityType = EntityType.values.byName(parts[0]);
            final tabIds = parts[1].split(',').where((id) => id.isNotEmpty).toList();
            _entityCustomTabs[entityType] = tabIds;
          }
        }
      }
      
      // Load entity templates
      final entityTemplatesJson = prefs.getStringList('state_flow_entity_templates') ?? [];
      if (entityTemplatesJson.isNotEmpty) {
        _entityTemplates.clear();
        _entityTemplates.addAll(entityTemplatesJson.map((json) => 
            EntityTemplate.fromJson(jsonDecode(json) as Map<String, dynamic>)));
      }
      
      // Load admin power generators
      final adminGeneratorsJson = prefs.getStringList('state_flow_admin_generators') ?? [];
      if (adminGeneratorsJson.isNotEmpty) {
        _adminPowerGenerators.clear();
        _adminPowerGenerators.addAll(adminGeneratorsJson.map((json) => 
            AdminPowerGenerator.fromJson(jsonDecode(json) as Map<String, dynamic>)));
      }
      
      // Load media assets
      final mediaAssetsJson = prefs.getStringList('state_flow_media_assets') ?? [];
      if (mediaAssetsJson.isNotEmpty) {
        _mediaAssets.clear();
        _mediaAssets.addAll(mediaAssetsJson.map((json) => 
            MediaAsset.fromJson(jsonDecode(json) as Map<String, dynamic>)));
      }
      
    } catch (e) {
      print('Error loading state flow data: $e');
      // Continue with empty data if loading fails
    }
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // admin | seller | buyer
  final String status; // active | pending | suspended
  final DateTime createdAt;
  final bool isSeller;
  final String plan; // free | plus | pro
  final SellerProfile? sellerProfile;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.isSeller = false,
    this.plan = 'free',
    this.sellerProfile,
  });

  AdminUser copyWith({
    String? name,
    String? email,
    String? role,
    String? status,
    bool? isSeller,
    String? plan,
    SellerProfile? sellerProfile,
  }) => AdminUser(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        status: status ?? this.status,
        createdAt: createdAt,
        isSeller: isSeller ?? this.isSeller,
        plan: plan ?? this.plan,
        sellerProfile: sellerProfile ?? this.sellerProfile,
      );
}

class SellerProfile {
  final String legalName;
  final String gstin;
  final String phone;
  final String address;
  final String bannerUrl;
  final List<String> materials;
  final Map<String, String> customFields;

  const SellerProfile({
    this.legalName = '',
    this.gstin = '',
    this.phone = '',
    this.address = '',
    this.bannerUrl = '',
    this.materials = const [],
    this.customFields = const {},
  });

  SellerProfile copyWith({
    String? legalName,
    String? gstin,
    String? phone,
    String? address,
    String? bannerUrl,
    List<String>? materials,
    Map<String,String>? customFields,
  }) => SellerProfile(
    legalName: legalName ?? this.legalName,
    gstin: gstin ?? this.gstin,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    bannerUrl: bannerUrl ?? this.bannerUrl,
    materials: materials ?? this.materials,
    customFields: customFields ?? this.customFields,
  );
}

class AuditLog {
  final DateTime timestamp;
  final String area;
  final String message;

  const AuditLog({
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

  AdminCategoryData copyWith({
    String? name,
    String? description,
    String? imageUrl,
    int? productCount,
    List<String>? industries,
    List<String>? materials,
    bool? isActive,
    int? priority,
    DateTime? updatedAt,
  }) => AdminCategoryData(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        productCount: productCount ?? this.productCount,
        industries: industries ?? this.industries,
        materials: materials ?? this.materials,
        isActive: isActive ?? this.isActive,
        priority: priority ?? this.priority,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

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

  factory AdminCategoryData.fromJson(Map<String, dynamic> json) => AdminCategoryData(
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
}


