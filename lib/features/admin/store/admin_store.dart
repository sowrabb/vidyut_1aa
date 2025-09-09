import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero_section.dart';
import '../models/notification.dart' as notif;
import '../models/subscription_models.dart' as sub;

class AdminStore extends ChangeNotifier {
  bool _isInitialized = false;
  
  AdminStore() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _hydrate();
    _isInitialized = true;
    notifyListeners();
  }
  
  bool get isInitialized => _isInitialized;

  // Hero sections data
  final List<HeroSection> _heroSections = [
    HeroSection(
      id: 'hero_1',
      title: 'First time in India, largest Electricity platform',
      subtitle: 'B2B • D2C • C2C',
      ctaText: null, // No CTA for first card
      ctaUrl: null,
      priority: 1,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HeroSection(
      id: 'hero_2',
      title: 'Find the right components fast',
      subtitle: 'Search by brand, spec, materials',
      ctaText: 'Start Searching',
      ctaUrl: '/search',
      priority: 2,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    HeroSection(
      id: 'hero_3',
      title: 'Post RFQs & get quotes',
      subtitle: 'Verified sellers, transparent pricing',
      ctaText: 'Post RFQ',
      ctaUrl: '/rfq',
      priority: 3,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  // Demo users data
  final List<AdminUser> _allUsers = List.generate(30, (i) => AdminUser(
        id: 'U${1000 + i}',
        name: i % 3 == 0 ? 'John Doe' : i % 3 == 1 ? 'Aarti' : 'Rahul',
        email: 'user${i}@example.com',
        role: i % 5 == 0 ? 'admin' : 'seller',
        status: i % 4 == 0 ? 'suspended' : i % 3 == 0 ? 'pending' : 'active',
        createdAt: DateTime.now().subtract(Duration(days: 30 - i)),
        isSeller: i % 2 == 0,
        plan: i % 6 == 0 ? 'pro' : i % 3 == 0 ? 'plus' : 'free',
        sellerProfile: i % 2 == 0
            ? const SellerProfile(
                legalName: 'Demo Co.',
                phone: '+91-9999999999',
                address: 'Somewhere, India',
                materials: ['Copper', 'PVC'],
              )
            : null,
      ));

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

  List<AdminUser> get allUsers => List.unmodifiable(_allUsers);
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

  // Hero sections getters
  List<HeroSection> get heroSections => List.unmodifiable(_heroSections);
  List<HeroSection> get activeHeroSections => _heroSections
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

  // CRUD: Users (demo)
  Future<void> addUser(AdminUser user) async {
    _allUsers.add(user);
    await addAudit('users', 'Added user ${user.id} (${user.email})');
    notifyListeners();
  }

  Future<void> updateUser(AdminUser updated) async {
    final idx = _allUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _allUsers[idx] = updated;
      await addAudit('users', 'Updated user ${updated.id}');
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _allUsers.removeWhere((u) => u.id == id);
    await addAudit('users', 'Deleted user $id');
    notifyListeners();
  }

  Future<void> resetPassword(String id) async {
    await addAudit('users', 'Password reset initiated for $id');
    notifyListeners();
  }

  // Role/plan helpers
  Future<void> promoteToSeller(String id, {String plan = 'free'}) async {
    final idx = _allUsers.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    final u = _allUsers[idx];
    final updated = u.copyWith(
      role: 'seller',
      isSeller: true,
      plan: plan,
      sellerProfile: u.sellerProfile ?? const SellerProfile(),
    );
    _allUsers[idx] = updated;
    await addAudit('users', 'Promoted $id to seller (plan=$plan)');
    notifyListeners();
  }

  Future<void> demoteToBuyer(String id) async {
    final idx = _allUsers.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    final u = _allUsers[idx];
    final updated = u.copyWith(
      role: 'buyer',
      isSeller: false,
      plan: 'free',
      sellerProfile: null,
      status: u.status,
    );
    _allUsers[idx] = updated;
    await addAudit('users', 'Demoted $id to buyer');
    notifyListeners();
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
    _allUsers.add(user);
    await addAudit('users', 'Created seller $id (plan=$plan)');
    notifyListeners();
    return user;
  }

  Future<void> grantPlan(String id, String plan) async {
    final idx = _allUsers.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    _allUsers[idx] = _allUsers[idx].copyWith(plan: plan);
    await addAudit('billing', 'Granted plan $plan to $id');
    notifyListeners();
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
    for (final id in userIds) {
      final idx = _allUsers.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _allUsers[idx] = _allUsers[idx].copyWith(status: status);
      }
    }
    await addAudit('users', 'Bulk updated ${userIds.length} users to $status');
    notifyListeners();
  }

  void exportUsersCsv(void Function(String csv) onReady) {
    final header = 'id,name,email,role,status,createdAt,plan,isSeller';
    final rows = _allUsers
        .map((u) => [
              u.id,
              u.name,
              u.email,
              u.role,
              u.status,
              u.createdAt.toIso8601String(),
              u.plan,
              u.isSeller.toString(),
            ].join(','))
        .join('\n');
    final csv = '$header\n$rows';
    onReady(csv);
    addAudit('users', 'Exported users CSV (${_allUsers.length})');
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
    await addAudit('categories', 'Added category: ${category.name}');
    notifyListeners();
    await _persistCategories();
  }

  Future<void> updateCategory(AdminCategoryData updated) async {
    final idx = _categories.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _categories[idx] = updated.copyWith(updatedAt: DateTime.now());
      await addAudit('categories', 'Updated category: ${updated.name}');
      notifyListeners();
      await _persistCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id);
    _categories.removeWhere((c) => c.id == id);
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
    Iterable<AdminUser> users = _allUsers;
    if (filter.roles.isNotEmpty) {
      users = users.where((u) => filter.roles.contains(u.role));
    }
    if (filter.isSeller != null) {
      users = users.where((u) => u.isSeller == filter.isSeller);
    }
    if (filter.userIds.isNotEmpty) {
      final ids = filter.userIds;
      users = users.where((u) => ids.contains(u.id));
    }
    // states filtering requires mapping users to states; demo: random simulate via email hash
    if (filter.states.isNotEmpty) {
      users = users.where((u) => filter.states.contains(_pseudoUserState(u)));
    }
    return users.length;
  }

  String _pseudoUserState(AdminUser u) {
    final states = geo.keys.toList();
    if (states.isEmpty) return 'Unknown';
    final idx = (u.email.hashCode.abs()) % states.length;
    return states[idx];
  }

  Future<void> sendNotification(notif.NotificationDraft draft) async {
    final size = estimateAudienceSize(draft.audience);
    await addAudit('notifications', 'Queued send for draft ${draft.id} to ~$size users via ${draft.channels.map((e)=>e.name).join('/')}');
    // Demo: no actual sending; assume success
    notifyListeners();
  }

  Future<void> _persistNotificationTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_templates', _notificationTemplates.map((t) => jsonEncode(t.toJson())).toList());
  }

  Future<void> _persistNotificationDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_drafts', _notificationDrafts.map((d) => jsonEncode(d.toJson())).toList());
  }

  // Hero sections CRUD operations
  Future<void> addHeroSection(HeroSection heroSection) async {
    _heroSections.add(heroSection);
    await addAudit('cms', 'Added hero section: ${heroSection.title}');
    notifyListeners();
    await _persistHeroSections();
  }

  Future<void> updateHeroSection(HeroSection updated) async {
    final idx = _heroSections.indexWhere((h) => h.id == updated.id);
    if (idx != -1) {
      _heroSections[idx] = updated.copyWith(updatedAt: DateTime.now());
      await addAudit('cms', 'Updated hero section: ${updated.title}');
      notifyListeners();
      await _persistHeroSections();
    }
  }

  Future<void> deleteHeroSection(String id) async {
    final hero = _heroSections.firstWhere((h) => h.id == id);
    _heroSections.removeWhere((h) => h.id == id);
    await addAudit('cms', 'Deleted hero section: ${hero.title}');
    notifyListeners();
    await _persistHeroSections();
  }

  Future<void> toggleHeroSectionActive(String id) async {
    final idx = _heroSections.indexWhere((h) => h.id == id);
    if (idx != -1) {
      final hero = _heroSections[idx];
      _heroSections[idx] = hero.copyWith(
        isActive: !hero.isActive,
        updatedAt: DateTime.now(),
      );
      await addAudit('cms', '${hero.isActive ? 'Deactivated' : 'Activated'} hero section: ${hero.title}');
      notifyListeners();
      await _persistHeroSections();
    }
  }

  Future<void> reorderHeroSections(List<String> orderedIds) async {
    final Map<String, HeroSection> heroMap = {
      for (final hero in _heroSections) hero.id: hero
    };
    
    _heroSections.clear();
    for (int i = 0; i < orderedIds.length; i++) {
      final hero = heroMap[orderedIds[i]];
      if (hero != null) {
        _heroSections.add(hero.copyWith(
          priority: i + 1,
          updatedAt: DateTime.now(),
        ));
      }
    }
    
    await addAudit('cms', 'Reordered hero sections');
    notifyListeners();
    await _persistHeroSections();
  }

  Future<void> _persistHeroSections() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> heroJsonList = _heroSections
        .map((h) => jsonEncode(h.toJson()))
        .toList();
    await prefs.setStringList('hero_sections', heroJsonList);
  }

  Future<void> _loadHeroSections() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? heroJsonList = prefs.getStringList('hero_sections');
    
    if (heroJsonList != null && heroJsonList.isNotEmpty) {
      _heroSections.clear();
      for (final jsonString in heroJsonList) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final heroSection = HeroSection.fromJson(jsonMap);
          _heroSections.add(heroSection);
        } catch (e) {
          print('Error loading hero section: $e');
        }
      }
    }
    
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


