import 'package:flutter/foundation.dart';
import 'categories_page.dart';
import '../../app/app_state.dart';
import '../../services/lightweight_demo_data_service.dart';

class CategoriesStore extends ChangeNotifier {
  final AppState _appState;
  final LightweightDemoDataService _demoDataService;
  String query = '';
  final Set<String> selectedIndustries = {};
  final Set<String> selectedMaterials = {};
  CategorySortBy sortBy = CategorySortBy.name;

  // Location properties that delegate to AppState
  String get city => _appState.city;
  String get state => _appState.state;
  double get radiusKm => _appState.radiusKm;

  // Categories data from DemoDataService
  List<CategoryData> get _allCategories => _demoDataService.allCategories;

  List<CategoryData> _filteredCategories = [];
  List<CategoryData> get filteredCategories => _filteredCategories;

  late final VoidCallback _locationChangeListener;
  late final VoidCallback _demoDataChangeListener;

  CategoriesStore(this._appState, this._demoDataService) {
    _filteredCategories = List.of(_allCategories);
    _applyFilters();

    // Listen to location changes from AppState
    _locationChangeListener = () => _refreshCategories();
    _appState.addLocationChangeListener(_locationChangeListener);

    // Listen to demo data changes from DemoDataService
    _demoDataChangeListener = () => _refreshCategories();
    _demoDataService.addListener(_demoDataChangeListener);
  }

  @override
  void dispose() {
    _appState.removeLocationChangeListener(_locationChangeListener);
    _demoDataService.removeListener(_demoDataChangeListener);
    super.dispose();
  }

  void _refreshCategories() {
    // Categories can be filtered based on location in the future
    // For now, just trigger a refresh
    _applyFilters();
  }

  void setQuery(String q) {
    query = q;
    _applyFilters();
  }

  void toggleIndustry(String industry) {
    if (selectedIndustries.contains(industry)) {
      selectedIndustries.remove(industry);
    } else {
      selectedIndustries.add(industry);
    }
    _applyFilters();
  }

  void toggleMaterial(String material) {
    if (selectedMaterials.contains(material)) {
      selectedMaterials.remove(material);
    } else {
      selectedMaterials.add(material);
    }
    _applyFilters();
  }

  void setSort(CategorySortBy sort) {
    sortBy = sort;
    _applyFilters();
  }

  void clearFilters() {
    query = '';
    selectedIndustries.clear();
    selectedMaterials.clear();
    sortBy = CategorySortBy.name;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<CategoryData>.from(_allCategories);

    // Apply search query
    if (query.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase()) ||
            category.industries.any((industry) =>
                industry.toLowerCase().contains(query.toLowerCase())) ||
            category.materials.any((material) =>
                material.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }

    // Apply industry filter
    if (selectedIndustries.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.industries
            .any((industry) => selectedIndustries.contains(industry));
      }).toList();
    }

    // Apply material filter
    if (selectedMaterials.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.materials
            .any((material) => selectedMaterials.contains(material));
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case CategorySortBy.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CategorySortBy.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CategorySortBy.popularity:
        filtered.sort((a, b) => b.productCount.compareTo(a.productCount));
        break;
    }

    _filteredCategories = filtered;
    notifyListeners();
  }
}
