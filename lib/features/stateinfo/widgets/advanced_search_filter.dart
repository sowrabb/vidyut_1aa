import 'package:flutter/material.dart';
import '../../../app/tokens.dart';

/// Advanced Search and Filter System for StateInfo editing
class AdvancedSearchFilter extends StatefulWidget {
  final List<SearchFilterField> availableFields;
  final Function(List<SearchFilter>)? onFiltersChanged;
  final Function(String)? onSearchChanged;
  final String initialSearchQuery;
  final List<SearchFilter> initialFilters;
  final String entityType;

  const AdvancedSearchFilter({
    super.key,
    required this.availableFields,
    this.onFiltersChanged,
    this.onSearchChanged,
    this.initialSearchQuery = '',
    this.initialFilters = const [],
    required this.entityType,
  });

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  late TextEditingController _searchController;
  List<SearchFilter> _filters = [];
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _filters = List.from(widget.initialFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Search & Filter ${widget.entityType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(
                    () => _showAdvancedFilters = !_showAdvancedFilters),
                icon: Icon(
                  _showAdvancedFilters
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  color: AppColors.primary,
                ),
                tooltip: _showAdvancedFilters ? 'Hide Filters' : 'Show Filters',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ${widget.entityType.toLowerCase()}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged?.call('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) => widget.onSearchChanged?.call(value),
          ),

          // Advanced Filters
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            _buildFiltersSection(),
          ],

          // Active Filters Summary
          if (_filters.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildActiveFiltersSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Advanced Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addFilter,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Filter'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_filters.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: const Center(
              child: Text(
                'No filters added. Click "Add Filter" to create one.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...(_filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            return _buildFilterRow(index, filter);
          }).toList()),
      ],
    );
  }

  Widget _buildFilterRow(int index, SearchFilter filter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Row(
        children: [
          // Field Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: filter.field,
              decoration: const InputDecoration(
                labelText: 'Field',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.availableFields.map((field) {
                return DropdownMenuItem(
                  value: field.name,
                  child: Text(field.displayName),
                );
              }).toList(),
              onChanged: (value) =>
                  _updateFilter(index, filter.copyWith(field: value!)),
            ),
          ),
          const SizedBox(width: 8),

          // Operator Dropdown
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<SearchOperator>(
              value: filter.operator,
              decoration: const InputDecoration(
                labelText: 'Operator',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: SearchOperator.values.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Text(_getOperatorDisplayName(op)),
                );
              }).toList(),
              onChanged: (value) =>
                  _updateFilter(index, filter.copyWith(operator: value!)),
            ),
          ),
          const SizedBox(width: 8),

          // Value Input
          Expanded(
            flex: 2,
            child: TextField(
              controller: TextEditingController(text: filter.value),
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) =>
                  _updateFilter(index, filter.copyWith(value: value)),
            ),
          ),
          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            onPressed: () => _removeFilter(index),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Remove Filter',
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Active Filters (${_filters.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _filters.map((filter) {
              return Chip(
                label: Text(
                  '${_getFieldDisplayName(filter.field)} ${_getOperatorDisplayName(filter.operator)} ${filter.value}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeFilter(_filters.indexOf(filter)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                deleteIconColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addFilter() {
    if (widget.availableFields.isNotEmpty) {
      setState(() {
        _filters.add(SearchFilter(
          field: widget.availableFields.first.name,
          operator: SearchOperator.contains,
          value: '',
        ));
      });
      widget.onFiltersChanged?.call(_filters);
    }
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
    widget.onFiltersChanged?.call(_filters);
  }

  void _updateFilter(int index, SearchFilter updatedFilter) {
    setState(() {
      _filters[index] = updatedFilter;
    });
    widget.onFiltersChanged?.call(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged?.call(_filters);
  }

  String _getOperatorDisplayName(SearchOperator operator) {
    switch (operator) {
      case SearchOperator.contains:
        return 'Contains';
      case SearchOperator.equals:
        return 'Equals';
      case SearchOperator.startsWith:
        return 'Starts With';
      case SearchOperator.endsWith:
        return 'Ends With';
      case SearchOperator.greaterThan:
        return 'Greater Than';
      case SearchOperator.lessThan:
        return 'Less Than';
      case SearchOperator.isEmpty:
        return 'Is Empty';
      case SearchOperator.isNotEmpty:
        return 'Is Not Empty';
    }
  }

  String _getFieldDisplayName(String fieldName) {
    final field = widget.availableFields.firstWhere(
      (f) => f.name == fieldName,
      orElse: () => SearchFilterField(name: fieldName, displayName: fieldName),
    );
    return field.displayName;
  }
}

/// Search filter field definition
class SearchFilterField {
  final String name;
  final String displayName;
  final SearchFieldType type;

  const SearchFilterField({
    required this.name,
    required this.displayName,
    this.type = SearchFieldType.text,
  });
}

/// Search field types
enum SearchFieldType {
  text,
  number,
  date,
  boolean,
  email,
  url,
}

/// Search operators
enum SearchOperator {
  contains,
  equals,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  isEmpty,
  isNotEmpty,
}

/// Search filter model
class SearchFilter {
  final String field;
  final SearchOperator operator;
  final String value;

  const SearchFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  SearchFilter copyWith({
    String? field,
    SearchOperator? operator,
    String? value,
  }) {
    return SearchFilter(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilter &&
        other.field == field &&
        other.operator == operator &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(field, operator, value);
}

/// Search and filter utilities
class SearchFilterUtils {
  /// Apply search query to a list of entities
  static List<T> applySearch<T>(
    List<T> entities,
    String searchQuery,
    List<String> searchableFields,
    T Function(T) getEntity,
  ) {
    if (searchQuery.isEmpty) return entities;

    final query = searchQuery.toLowerCase();
    return entities.where((entity) {
      final entityData = getEntity(entity);
      // This is a simplified version - in real implementation,
      // you'd extract field values based on searchableFields
      return entityData.toString().toLowerCase().contains(query);
    }).toList();
  }

  /// Apply filters to a list of entities
  static List<T> applyFilters<T>(
    List<T> entities,
    List<SearchFilter> filters,
    dynamic Function(T, String) getFieldValue,
  ) {
    if (filters.isEmpty) return entities;

    return entities.where((entity) {
      return filters.every((filter) {
        final fieldValue = getFieldValue(entity, filter.field);
        return _evaluateFilter(fieldValue, filter);
      });
    }).toList();
  }

  static bool _evaluateFilter(dynamic fieldValue, SearchFilter filter) {
    final value = fieldValue?.toString() ?? '';
    final filterValue = filter.value;

    switch (filter.operator) {
      case SearchOperator.contains:
        return value.toLowerCase().contains(filterValue.toLowerCase());
      case SearchOperator.equals:
        return value.toLowerCase() == filterValue.toLowerCase();
      case SearchOperator.startsWith:
        return value.toLowerCase().startsWith(filterValue.toLowerCase());
      case SearchOperator.endsWith:
        return value.toLowerCase().endsWith(filterValue.toLowerCase());
      case SearchOperator.greaterThan:
        return _compareNumbers(value, filterValue) > 0;
      case SearchOperator.lessThan:
        return _compareNumbers(value, filterValue) < 0;
      case SearchOperator.isEmpty:
        return value.isEmpty;
      case SearchOperator.isNotEmpty:
        return value.isNotEmpty;
    }
  }

  static int _compareNumbers(String a, String b) {
    final numA = double.tryParse(a.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    final numB = double.tryParse(b.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    return numA.compareTo(numB);
  }
}
