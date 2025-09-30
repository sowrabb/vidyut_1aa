import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/tokens.dart';
import '../models/state_info_models.dart';
import 'enhanced_product_design_editor.dart';
import 'shared_media_components.dart';

// Product Design Tab Widget
class ProductDesignTab extends StatefulWidget {
  final List<ProductDesign> productDesigns;
  final String sectorType;
  final String sectorId;
  final bool isEditMode;

  const ProductDesignTab({
    super.key,
    required this.productDesigns,
    required this.sectorType,
    required this.sectorId,
    this.isEditMode = false,
  });

  @override
  State<ProductDesignTab> createState() => _ProductDesignTabState();
}

class _ProductDesignTabState extends State<ProductDesignTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedTag = 'All';
  List<String> _availableCategories = ['All'];
  List<String> _availableTags = ['All'];

  @override
  void initState() {
    super.initState();
    _updateFilters();
  }

  void _updateFilters() {
    final categories =
        widget.productDesigns.map((design) => design.category).toSet().toList();
    categories.sort();
    _availableCategories = ['All', ...categories];

    final tags =
        widget.productDesigns.expand((design) => design.tags).toSet().toList();
    tags.sort();
    _availableTags = ['All', ...tags];
  }

  List<ProductDesign> get _filteredDesigns {
    return widget.productDesigns.where((design) {
      final matchesSearch = _searchQuery.isEmpty ||
          design.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          design.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          design.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory =
          _selectedCategory == 'All' || design.category == _selectedCategory;
      final matchesTag =
          _selectedTag == 'All' || design.tags.contains(_selectedTag);

      return matchesSearch && matchesCategory && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search product designs...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: _availableCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'All';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTag,
                      decoration: InputDecoration(
                        labelText: 'Tag',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: _availableTags.map((tag) {
                        return DropdownMenuItem(
                          value: tag,
                          child: Text(tag),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTag = value ?? 'All';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Product Designs List
        Expanded(
          child: _filteredDesigns.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredDesigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final design = _filteredDesigns[index];
                    return ProductDesignCard(
                      design: design,
                      isEditMode: widget.isEditMode,
                      onEdit: widget.isEditMode ? () => _editProductDesign(design) : null,
                    );
                  },
                ),
        ),
          ],
        ),
        // Floating action button for creating new product design (only in edit mode)
        if (widget.isEditMode)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                StateInfoProductDesignEditor.show(
                  context: context,
                  entityId: widget.sectorId,
                  entityType: widget.sectorType,
                  author: 'Current User', // TODO: Get from auth context
                  sectorType: widget.sectorType,
                  sectorId: widget.sectorId,
                  stateId: 'current_state', // TODO: Get from context
                  onSave: (design) {
                    // Persist new design via parent/store as needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('New product design created: ${design.title}')),
                    );
                  },
                );
              },
              tooltip: 'Create new product design',
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.design_services_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No product designs found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editProductDesign(ProductDesign design) {
    showEnhancedProductDesignEditor(
      context: context,
      initialDesign: design,
      designId: design.id,
      author: design.author,
      sectorType: widget.sectorType,
      sectorId: widget.sectorId,
      stateId: design.stateId,
      onSave: (updatedDesign) {
        // Persist updated design via parent/store as needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product design updated: ${updatedDesign.title}')),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Product Design Card Widget (Facebook-style)
class ProductDesignCard extends StatelessWidget {
  final ProductDesign design;
  final bool isEditMode;
  final VoidCallback? onEdit;

  const ProductDesignCard({
    super.key, 
    required this.design,
    this.isEditMode = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final coverImage = design.getCoverImage();
    final heroImage = coverImage?.downloadUrl;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.design_services,
                      color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(design.title,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Text(design.author,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 6),
                        Text('• ${design.uploadDate}',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Product Designs',
                      style: textTheme.bodySmall?.copyWith(
                          color: Colors.green, fontWeight: FontWeight.w600)),
                ),
                if (isEditMode && onEdit != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                    tooltip: 'Edit Product Design',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),

          // Text content
          if (design.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(design.description, style: textTheme.bodyMedium),
            ),

          // Media hero (first image)
          if (heroImage != null) ...[
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                heroImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                ),
              ),
            ),
          ],

          // Category + tags as hashtags
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(design.category,
                      style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
                ...design.tags.map((t) => Text('#$t',
                    style: textTheme.bodySmall?.copyWith(color: Colors.blue))),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Social counts row (placeholders)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.thumb_up,
                            size: 12, color: Colors.white)),
                    Positioned(
                        left: 12,
                        child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.favorite,
                                size: 12, color: Colors.white))),
                  ],
                ),
                const SizedBox(width: 28),
                Text('4,220', style: textTheme.bodySmall),
                const Spacer(),
                Text('57 Comments',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Text('117 Shares',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Action bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PDActionButton(
                    icon: Icons.thumb_up_alt_outlined, label: 'Like'),
                _PDActionButton(
                    icon: Icons.mode_comment_outlined, label: 'Comment'),
                _PDActionButton(icon: Icons.ios_share_outlined, label: 'Share'),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _PDActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PDActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textSecondary;
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
