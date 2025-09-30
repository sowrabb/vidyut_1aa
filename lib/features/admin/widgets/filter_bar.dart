import 'package:flutter/material.dart';

/// Filter bar for users management
class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedRole;
  final String selectedStatus;
  final String sortBy;
  final String sortOrder;
  final Function(String) onSearchChanged;
  final Function(String) onRoleChanged;
  final Function(String) onStatusChanged;
  final Function(String, String) onSortChanged;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.sortBy,
    required this.sortOrder,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final filters = <Widget>[
            _DropdownField(
              label: 'Role',
              value: selectedRole.isEmpty ? null : selectedRole,
              items: const [
                DropdownMenuItem(value: '', child: Text('All Roles')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'seller', child: Text('Seller')),
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
              ],
              onChanged: (value) => onRoleChanged(value ?? ''),
            ),
            _DropdownField(
              label: 'Status',
              value: selectedStatus.isEmpty ? null : selectedStatus,
              items: const [
                DropdownMenuItem(value: '', child: Text('All Statuses')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (value) => onStatusChanged(value ?? ''),
            ),
            _DropdownField(
              label: 'Sort By',
              value: '$sortBy:$sortOrder',
              items: const [
                DropdownMenuItem(
                    value: 'createdAt:desc', child: Text('Newest First')),
                DropdownMenuItem(
                    value: 'createdAt:asc', child: Text('Oldest First')),
                DropdownMenuItem(value: 'name:asc', child: Text('Name A-Z')),
                DropdownMenuItem(value: 'name:desc', child: Text('Name Z-A')),
                DropdownMenuItem(value: 'email:asc', child: Text('Email A-Z')),
                DropdownMenuItem(value: 'email:desc', child: Text('Email Z-A')),
                DropdownMenuItem(
                    value: 'lastActive:desc', child: Text('Most Active')),
                DropdownMenuItem(
                    value: 'lastActive:asc', child: Text('Least Active')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final parts = value.split(':');
                  onSortChanged(parts[0], parts[1]);
                }
              },
            ),
          ];

          return Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              isCompact
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filters.map((widget) {
                        final double itemWidth = constraints.maxWidth > 480
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints.tightFor(width: itemWidth),
                          child: widget,
                        );
                      }).toList(),
                    )
                  : Row(
                      children: filters
                          .map((widget) => Expanded(child: widget))
                          .expand(
                              (widget) => [widget, const SizedBox(width: 16)])
                          .toList()
                        ..removeLast(),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    );
  }
}
