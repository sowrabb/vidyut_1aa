import 'dart:async';
import 'package:flutter/foundation.dart';
import '../sell/models.dart';
import '../../app/app_state.dart';

enum SearchMode { products, profiles }

class MaterialProfile {
  final String name;
  final List<String> materials;
  const MaterialProfile({required this.name, required this.materials});
}

enum SortBy { relevance, priceAsc, priceDesc, distance }

class SearchStore extends ChangeNotifier {
  final List<Product> _all;
  final AppState _appState;
  String query = '';
  final Set<String> selectedCategories = {};
  final Set<String> selectedMaterials = {};
  double minPrice = 0, maxPrice = 50000;
  double priceStart = 0, priceEnd = 50000;
  SortBy sortBy = SortBy.relevance;
  SearchMode mode = SearchMode.products;

  List<Product> _results = [];
  List<Product> get results => _results;

  late final List<MaterialProfile> _profilesAll;
  List<MaterialProfile> _profilesResults = const [];
  List<MaterialProfile> get profilesResults => _profilesResults;

  Timer? _debounce;

  // Location properties that delegate to AppState
  String get city => _appState.city;
  String get state => _appState.state;
  double get radiusKm => _appState.radiusKm;

  late final VoidCallback _locationChangeListener;

  SearchStore(this._all, this._appState) {
    _results = List.of(_all);
    // Aggregate simple "profiles" by brand name with union of materials
    final Map<String, Set<String>> byBrand = {};
    for (final p in _all) {
      byBrand.putIfAbsent(p.brand, () => <String>{}).addAll(p.materials);
    }
    _profilesAll = byBrand.entries
        .map((e) => MaterialProfile(name: e.key, materials: e.value.toList()))
        .toList();
    _profilesResults = List.of(_profilesAll);

    // Listen to location changes from AppState
    _locationChangeListener = () => _refresh(immediate: true);
    _appState.addLocationChangeListener(_locationChangeListener);
  }

  @override
  void dispose() {
    _appState.removeLocationChangeListener(_locationChangeListener);
    _debounce?.cancel();
    super.dispose();
  }

  // Location is now managed by AppState - use AppState.setLocation() instead
  void updateLocationFromAppState() {
    _refresh(immediate: true);
  }

  void setQuery(String q) {
    query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _refresh());
  }

  void toggleCategory(String c) {
    selectedCategories.toggle(c);
    _refresh();
  }

  void toggleMaterial(String m) {
    selectedMaterials.toggle(m);
    _refresh();
  }

  void setMode(SearchMode m) {
    mode = m;
    _refresh(immediate: true);
  }

  void setPriceRange(double start, double end) {
    priceStart = start;
    priceEnd = end;
    _refresh();
  }

  void setSort(SortBy s) {
    sortBy = s;
    _refresh();
  }

  void clearFilters() {
    query = '';
    selectedCategories.clear();
    selectedMaterials.clear();
    priceStart = minPrice;
    priceEnd = maxPrice;
    sortBy = SortBy.relevance;
    _refresh();
  }

  // Pretend distance: deterministic function of product id hash to keep demo stable
  double _mockDistance(Product p) => (p.id.hashCode % 150) / 5.0; // 0..30 km

  void _refresh({bool immediate = false}) {
    // Products filtering
    List<Product> list = _all.where((p) {
      final qok = query.isEmpty ||
          p.title.toLowerCase().contains(query.toLowerCase()) ||
          p.brand.toLowerCase().contains(query.toLowerCase()) ||
          p.subtitle.toLowerCase().contains(query.toLowerCase());
      final cok = selectedCategories.isEmpty ||
          selectedCategories.contains(p.subtitleCategorySafe);
      final mok = selectedMaterials.isEmpty ||
          p.materials.any(selectedMaterials.contains);
      final pok = (p.price >= priceStart && p.price <= priceEnd);
      final dok = _mockDistance(p) <= radiusKm + 0.0001;
      return qok && cok && mok && pok && dok;
    }).toList();

    list.sort((a, b) {
      switch (sortBy) {
        case SortBy.priceAsc:
          return a.price.compareTo(b.price);
        case SortBy.priceDesc:
          return b.price.compareTo(a.price);
        case SortBy.distance:
          return _mockDistance(a).compareTo(_mockDistance(b));
        case SortBy.relevance:
          return 0;
      }
    });

    _results = list;

    // Profiles filtering: match query/selectedMaterials against materials list
    final qLower = query.toLowerCase();
    _profilesResults = _profilesAll.where((prof) {
      final qok = query.isEmpty ||
          prof.name.toLowerCase().contains(qLower) ||
          prof.materials.any((m) => m.toLowerCase().contains(qLower));
      final mok = selectedMaterials.isEmpty ||
          prof.materials.any(selectedMaterials.contains);
      return qok && mok;
    }).toList();
    if (immediate) {
      notifyListeners();
    } else {
      scheduleMicrotask(notifyListeners);
    }
  }
}

// small helper to toggle set membership
extension _Toggle<E> on Set<E> {
  void toggle(E e) => contains(e) ? remove(e) : add(e);
}

// Add a category getter to Product without breaking your model file:
extension ProductCategory on Product {
  String get subtitleCategorySafe {
    // For demo, reuse subtitle to emulate category; fallback to first category.
    if (subtitle.isNotEmpty && kCategories.contains(subtitle)) return subtitle;
    return kCategories.first;
  }
}
