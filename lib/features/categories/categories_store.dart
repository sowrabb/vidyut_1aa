import 'package:flutter/foundation.dart';
import 'categories_page.dart';

class CategoriesStore extends ChangeNotifier {
  String query = '';
  final Set<String> selectedIndustries = {};
  final Set<String> selectedMaterials = {};
  CategorySortBy sortBy = CategorySortBy.name;

  // All categories data
  final List<CategoryData> _allCategories = [
    CategoryData(
      name: 'Cables & Wires',
      imageUrl: 'https://picsum.photos/seed/cables/400/300',
      productCount: 1250,
      industries: ['Construction', 'EPC', 'MEP', 'Industrial'],
      materials: ['Copper', 'Aluminium', 'PVC', 'XLPE'],
    ),
    CategoryData(
      name: 'Switchgear',
      imageUrl: 'https://picsum.photos/seed/switchgear/400/300',
      productCount: 890,
      industries: ['Industrial', 'Commercial', 'Infrastructure'],
      materials: ['Steel', 'Iron', 'Plastic'],
    ),
    CategoryData(
      name: 'Transformers',
      imageUrl: 'https://picsum.photos/seed/transformers/400/300',
      productCount: 450,
      industries: ['Industrial', 'Infrastructure', 'EPC'],
      materials: ['Steel', 'Iron', 'Copper'],
    ),
    CategoryData(
      name: 'Meters',
      imageUrl: 'https://picsum.photos/seed/meters/400/300',
      productCount: 320,
      industries: ['Commercial', 'Residential', 'Industrial'],
      materials: ['Plastic', 'Steel', 'Glass'],
    ),
    CategoryData(
      name: 'Solar & Storage',
      imageUrl: 'https://picsum.photos/seed/solar/400/300',
      productCount: 680,
      industries: ['Solar', 'EPC', 'Commercial'],
      materials: ['Steel', 'Aluminium', 'Glass'],
    ),
    CategoryData(
      name: 'Lighting',
      imageUrl: 'https://picsum.photos/seed/lighting/400/300',
      productCount: 2100,
      industries: ['Commercial', 'Residential', 'Infrastructure'],
      materials: ['Plastic', 'Aluminium', 'Glass'],
    ),
    CategoryData(
      name: 'Motors & Drives',
      imageUrl: 'https://picsum.photos/seed/motors/400/300',
      productCount: 750,
      industries: ['Industrial', 'Commercial'],
      materials: ['Steel', 'Iron', 'Copper'],
    ),
    CategoryData(
      name: 'Tools & Safety',
      imageUrl: 'https://picsum.photos/seed/tools/400/300',
      productCount: 1800,
      industries: ['Construction', 'Industrial', 'Commercial'],
      materials: ['Steel', 'Rubber', 'Plastic'],
    ),
    CategoryData(
      name: 'Services',
      imageUrl: 'https://picsum.photos/seed/services/400/300',
      productCount: 150,
      industries: ['Construction', 'EPC', 'MEP'],
      materials: [],
    ),
  ];

  List<CategoryData> _filteredCategories = [];
  List<CategoryData> get filteredCategories => _filteredCategories;

  CategoriesStore() {
    _filteredCategories = List.of(_allCategories);
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
