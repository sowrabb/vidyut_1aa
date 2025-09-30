import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/provider_registry.dart';
import '../../services/lightweight_demo_data_service.dart';
import 'categories_page.dart';

class CategoriesState {
  final String query;
  final Set<String> selectedIndustries;
  final Set<String> selectedMaterials;
  final CategorySortBy sortBy;
  final List<CategoryData> filteredCategories;

  const CategoriesState({
    this.query = '',
    this.selectedIndustries = const {},
    this.selectedMaterials = const {},
    this.sortBy = CategorySortBy.name,
    this.filteredCategories = const [],
  });

  CategoriesState copyWith({
    String? query,
    Set<String>? selectedIndustries,
    Set<String>? selectedMaterials,
    CategorySortBy? sortBy,
    List<CategoryData>? filteredCategories,
  }) {
    return CategoriesState(
      query: query ?? this.query,
      selectedIndustries: selectedIndustries ?? this.selectedIndustries,
      selectedMaterials: selectedMaterials ?? this.selectedMaterials,
      sortBy: sortBy ?? this.sortBy,
      filteredCategories: filteredCategories ?? this.filteredCategories,
    );
  }
}

class CategoriesNotifier extends Notifier<CategoriesState> {
  List<CategoryData> get _allCategories =>
      ref.read(demoDataServiceProvider).allCategories;

  @override
  CategoriesState build() {
    // Recompute when app state changes (e.g., location) or demo data changes
    ref.listen(locationControllerProvider, (_, __) {
      _applyFilters();
    });
    ref.listen<LightweightDemoDataService>(demoDataServiceProvider, (_, __) {
      _applyFilters();
    });

    final initial = CategoriesState(
      filteredCategories: List.of(_allCategories),
    );
    return initial;
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
    _applyFilters();
  }

  void toggleIndustry(String industry) {
    final next = Set<String>.from(state.selectedIndustries);
    if (next.contains(industry)) {
      next.remove(industry);
    } else {
      next.add(industry);
    }
    state = state.copyWith(selectedIndustries: next);
    _applyFilters();
  }

  void toggleMaterial(String material) {
    final next = Set<String>.from(state.selectedMaterials);
    if (next.contains(material)) {
      next.remove(material);
    } else {
      next.add(material);
    }
    state = state.copyWith(selectedMaterials: next);
    _applyFilters();
  }

  void setSort(CategorySortBy sort) {
    state = state.copyWith(sortBy: sort);
    _applyFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      query: '',
      selectedIndustries: {},
      selectedMaterials: {},
      sortBy: CategorySortBy.name,
    );
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<CategoryData>.from(_allCategories);

    // Apply search query
    if (state.query.isNotEmpty) {
      filtered = filtered.where((category) {
        final q = state.query.toLowerCase();
        return category.name.toLowerCase().contains(q) ||
            category.industries
                .any((industry) => industry.toLowerCase().contains(q)) ||
            category.materials
                .any((material) => material.toLowerCase().contains(q));
      }).toList();
    }

    // Apply industry filter
    if (state.selectedIndustries.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.industries
            .any((industry) => state.selectedIndustries.contains(industry));
      }).toList();
    }

    // Apply material filter
    if (state.selectedMaterials.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.materials
            .any((material) => state.selectedMaterials.contains(material));
      }).toList();
    }

    // Apply sorting
    switch (state.sortBy) {
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

    state = state.copyWith(filteredCategories: filtered);
  }
}

final categoriesNotifierProvider =
    NotifierProvider<CategoriesNotifier, CategoriesState>(() {
  return CategoriesNotifier();
});
