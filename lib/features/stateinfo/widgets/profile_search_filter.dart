import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import '../data/profile_posts_data.dart';

/// Search and filter widget for profile posts
class ProfileSearchFilter extends StatefulWidget {
  final PostCategory category;
  final Function(String) onSearchChanged;
  final Function(List<String>) onFiltersChanged;

  const ProfileSearchFilter({
    super.key,
    required this.category,
    required this.onSearchChanged,
    required this.onFiltersChanged,
  });

  @override
  State<ProfileSearchFilter> createState() => _ProfileSearchFilterState();
}

class _ProfileSearchFilterState extends State<ProfileSearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFilters = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildFilterDropdown(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search ${widget.category.displayName.toLowerCase()}...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final availableFilters = ProfilePostsData.getFilterTags(widget.category);
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        tooltip: 'Filters',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        constraints: const BoxConstraints(minWidth: 240),
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.filter_list),
          label: Text(_selectedFilters.isEmpty
              ? 'Filters'
              : 'Filters (${_selectedFilters.length})'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.outlineSoft),
          ),
        ),
        onSelected: (_) {},
        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: Row(
                children: [
                  const Text('Select filters',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_selectedFilters.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllFilters();
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            ...availableFilters.map((filter) {
              final selected = _selectedFilters.contains(filter);
              return PopupMenuItem<String>(
                value: filter,
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedFilters.remove(filter);
                    } else {
                      _selectedFilters.add(filter);
                    }
                  });
                  // Delay notify to after popup closes
                  Future.microtask(
                      () => widget.onFiltersChanged(_selectedFilters));
                },
                child: Row(
                  children: [
                    Checkbox(value: selected, onChanged: (_) {}),
                    const SizedBox(width: 8),
                    Expanded(child: Text(filter)),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
    widget.onFiltersChanged(_selectedFilters);
  }
}
