import 'package:flutter/material.dart';
import '../../sell/models.dart';

class ProductsFilters extends StatelessWidget {
  final ValueChanged<String>? onQuery;
  final Set<String> selectedCategories;
  final Set<ProductStatus> selectedStatuses;
  final ValueChanged<String> onToggleCategory;
  final ValueChanged<ProductStatus> onToggleStatus;
  final void Function(double, double) onPrice;
  final void Function(String) onSort;
  final double priceStart;
  final double priceEnd;
  final String sort; // 'date','priceAsc','priceDesc'
  const ProductsFilters({
    super.key,
    this.onQuery,
    required this.selectedCategories,
    required this.selectedStatuses,
    required this.onToggleCategory,
    required this.onToggleStatus,
    required this.onPrice,
    required this.onSort,
    required this.priceStart,
    required this.priceEnd,
    required this.sort,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search your products...'),
        onChanged: onQuery,
      ),
      const SizedBox(height: 12),
      const Text('Category'),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final c in kCategories)
          FilterChip(
              label: Text(c),
              selected: selectedCategories.contains(c),
              onSelected: (_) => onToggleCategory(c)),
      ]),
      const SizedBox(height: 12),
      const Text('Status'),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ProductStatus.values)
          FilterChip(
              label: Text(s.name),
              selected: selectedStatuses.contains(s),
              onSelected: (_) => onToggleStatus(s)),
      ]),
      const SizedBox(height: 12),
      const Text('Price (₹)'),
      RangeSlider(
        values: RangeValues(priceStart, priceEnd),
        min: 0,
        max: 100000,
        divisions: 100,
        labels: RangeLabels('₹${priceStart.toStringAsFixed(0)}',
            '₹${priceEnd.toStringAsFixed(0)}'),
        onChanged: (v) => onPrice(v.start, v.end),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: sort,
        items: const [
          DropdownMenuItem(value: 'date', child: Text('Newest')),
          DropdownMenuItem(
              value: 'priceAsc', child: Text('Price: Low to High')),
          DropdownMenuItem(
              value: 'priceDesc', child: Text('Price: High to Low')),
        ],
        onChanged: (v) => onSort(v ?? 'date'),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
      ),
    ]);
  }
}
