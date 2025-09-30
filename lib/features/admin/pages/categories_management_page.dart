import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../app/tokens.dart';
import '../store/admin_store.dart';
import '../admin_shell.dart';
import '../../../app/provider_registry.dart';
import '../../../widgets/multi_select_dropdown.dart';

class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  State<CategoriesManagementPage> createState() =>
      _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _showInactive = false;
  bool _reorderMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final store = ref.watch(adminStoreProvider);
        final categories = _getFilteredCategories(store.categories);

        return Column(
          children: [
            // Header with search and actions
            AdminPageHeader(
              title: 'Categories Management',
              actions: [
                // Search field
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Sort dropdown
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                    DropdownMenuItem(
                        value: 'nameDesc', child: Text('Name Z-A')),
                    DropdownMenuItem(
                        value: 'priority', child: Text('Priority')),
                    DropdownMenuItem(
                        value: 'productCount', child: Text('Product Count')),
                    DropdownMenuItem(
                        value: 'createdAt', child: Text('Created Date')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'name';
                    });
                  },
                ),
                const SizedBox(width: 12),

                // Show inactive toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showInactive,
                      onChanged: (value) {
                        setState(() {
                          _showInactive = value ?? false;
                        });
                      },
                    ),
                    const Text('Show Inactive'),
                  ],
                ),
                const SizedBox(width: 12),

                // Add category button
                ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context, store),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _exportTaxonomySnapshot(store),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export Taxonomy'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _reorderMode = !_reorderMode),
                  icon: Icon(_reorderMode ? Icons.lock : Icons.reorder),
                  label: Text(_reorderMode ? 'Done' : 'Reorder'),
                ),
              ],
            ),

            // Categories list
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: TextStyle(
                                fontSize: 18, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : _reorderMode
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          onReorder: (oldIndex, newIndex) {
                            final reordered = List.of(categories);
                            if (newIndex > oldIndex) newIndex--;
                            final item = reordered.removeAt(oldIndex);
                            reordered.insert(newIndex, item);
                            final orderedIds =
                                reordered.map((e) => e.id).toList();
                            store.reorderCategories(orderedIds);
                          },
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return KeyedSubtree(
                              key: ValueKey(category.id),
                              child: _CategoryCard(
                                category: category,
                                onEdit: () => _showEditCategoryDialog(
                                    context, store, category),
                                onDelete: () => _showDeleteCategoryDialog(
                                    context, store, category),
                                onToggleActive: () =>
                                    store.toggleCategoryActive(category.id),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CategoryCard(
                              category: category,
                              onEdit: () => _showEditCategoryDialog(
                                  context, store, category),
                              onDelete: () => _showDeleteCategoryDialog(
                                  context, store, category),
                              onToggleActive: () =>
                                  store.toggleCategoryActive(category.id),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  void _exportTaxonomySnapshot(AdminStore store) {
    final list = store.categories
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'description': c.description,
              'imageUrl': c.imageUrl,
              'productCount': c.productCount,
              'industries': c.industries,
              'materials': c.materials,
              'isActive': c.isActive,
              'priority': c.priority,
              'createdAt': c.createdAt.toIso8601String(),
              'updatedAt': c.updatedAt.toIso8601String(),
            })
        .toList();
    final json = const JsonEncoder.withIndent('  ').convert(list);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Taxonomy exported (${json.length} chars)')),
    );
  }

  List<AdminCategoryData> _getFilteredCategories(
      List<AdminCategoryData> categories) {
    var filtered = categories.where((category) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!category.name.toLowerCase().contains(query) &&
            !category.description.toLowerCase().contains(query) &&
            !category.industries
                .any((industry) => industry.toLowerCase().contains(query)) &&
            !category.materials
                .any((material) => material.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Filter by active status
      if (!_showInactive && !category.isActive) {
        return false;
      }

      return true;
    }).toList();

    // Sort categories
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'nameDesc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'priority':
        filtered.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case 'productCount':
        filtered.sort((a, b) => b.productCount.compareTo(a.productCount));
        break;
      case 'createdAt':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  void _showAddCategoryDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        store: store,
        onSave: (category) async {
          final navigator = Navigator.of(context);
          await store.addCategory(category);
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, AdminStore store, AdminCategoryData category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        store: store,
        category: category,
        onSave: (updatedCategory) async {
          final navigator = Navigator.of(context);
          await store.updateCategory(updatedCategory);
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }

  void _showDeleteCategoryDialog(
      BuildContext context, AdminStore store, AdminCategoryData category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await store.deleteCategory(category.id);
              if (navigator.mounted) {
                navigator.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AdminCategoryData category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.thumbBg,
              ),
              child: category.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        category.imageUrl,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              size: 40, color: AppColors.textSecondary);
                        },
                      ),
                    )
                  : const Icon(Icons.category,
                      size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: category.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.inventory,
                        label: '${category.productCount} products',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.trending_up,
                        label: 'Priority ${category.priority}',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.business,
                        label: '${category.industries.length} industries',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Industries and materials
                  if (category.industries.isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: category.industries
                          .take(3)
                          .map(
                            (industry) => Chip(
                              label: Text(industry,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primarySurface,
                              labelStyle:
                                  const TextStyle(color: AppColors.primary),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onToggleActive,
                  icon: Icon(category.isActive
                      ? Icons.visibility_off
                      : Icons.visibility),
                  tooltip: category.isActive ? 'Deactivate' : 'Activate',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final AdminStore store;
  final AdminCategoryData? category;
  final Function(AdminCategoryData) onSave;

  const _CategoryFormDialog({
    required this.store,
    this.category,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _productCountController = TextEditingController();
  final _priorityController = TextEditingController();

  final Set<String> _selectedIndustries = {};
  final Set<String> _selectedMaterials = {};
  bool _isActive = true;

  // Image picker temporarily disabled; use URL only in web-friendly demo
  bool _isUploadingImage = false;

  // Available options
  final List<String> _availableIndustries = [
    'Construction',
    'EPC',
    'MEP',
    'Solar',
    'Industrial',
    'Commercial',
    'Residential',
    'Infrastructure',
  ];

  final List<String> _availableMaterials = [
    'Copper',
    'Aluminium',
    'PVC',
    'XLPE',
    'Steel',
    'Iron',
    'Plastic',
    'Rubber',
    'Glass',
    'Ceramic',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _imageUrlController.text = widget.category!.imageUrl;
      _productCountController.text = widget.category!.productCount.toString();
      _priorityController.text = widget.category!.priority.toString();
      _selectedIndustries.addAll(widget.category!.industries);
      _selectedMaterials.addAll(widget.category!.materials);
      _isActive = widget.category!.isActive;
    } else {
      _priorityController.text =
          (widget.store.categories.length + 1).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _productCountController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isUploadingImage = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final imageUrl =
        'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/600';
    setState(() {
      _imageUrlController.text = imageUrl;
      _isUploadingImage = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image URL set (demo upload)')),
      );
    }
  }

  // Camera picker disabled in demo; use _pickImage to simulate

  void _removeImage() {
    setState(() {
      _imageUrlController.clear();
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text(
            'Choose how you want to add an image for this category. (Demo uses URL-based upload)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Gallery'),
              ],
            ),
          ),
          // Camera option disabled in demo
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Focus on the URL input field
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link),
                SizedBox(width: 8),
                Text('Enter URL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineSoft),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Image preview
          GestureDetector(
            onTap: _isUploadingImage ? null : _showImageSourceDialog,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.thumbBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: _imageUrlController.text.isNotEmpty
                    ? null
                    : Border.all(
                        color: AppColors.outlineSoft,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
              ),
              child: _buildImagePreview(),
            ),
          ),

          // Upload controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingImage ? null : _pickImage,
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library),
                    label: Text(_isUploadingImage ? 'Uploading...' : 'Gallery'),
                  ),
                ),
                if (_imageUrlController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove Image',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageUrlController.text.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        child: Image.network(
          _imageUrlController.text,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text('Failed to load image'),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add image URL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'URL only (demo)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.outlineSoft)),
              ),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic info
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image upload section
                      const Text('Category Image',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildImageUploadSection(),
                      const SizedBox(height: 12),

                      // Manual URL input
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Or enter image URL manually',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _productCountController,
                              decoration: const InputDecoration(
                                labelText: 'Product Count',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priorityController,
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Industries
                      const Text('Industries',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      MultiSelectDropdown<String>(
                        options: _availableIndustries,
                        value: _selectedIndustries.toList(),
                        onChanged: (list) {
                          setState(() {
                            _selectedIndustries
                              ..clear()
                              ..addAll(list);
                          });
                        },
                        itemLabel: (s) => s,
                        hintText: 'Select industries',
                        showChipsInField: false,
                      ),
                      const SizedBox(height: 16),

                      // Materials
                      const Text('Materials',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      MultiSelectDropdown<String>(
                        options: _availableMaterials,
                        value: _selectedMaterials.toList(),
                        onChanged: (list) {
                          setState(() {
                            _selectedMaterials
                              ..clear()
                              ..addAll(list);
                          });
                        },
                        itemLabel: (s) => s,
                        hintText: 'Select materials',
                        showChipsInField: false,
                      ),
                      const SizedBox(height: 16),

                      // Active status
                      Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value ?? true;
                              });
                            },
                          ),
                          const Text('Active'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.outlineSoft)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = AdminCategoryData(
      id: widget.category?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      productCount: int.parse(_productCountController.text),
      industries: _selectedIndustries.toList(),
      materials: _selectedMaterials.toList(),
      isActive: _isActive,
      priority: int.parse(_priorityController.text),
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(category);
  }
}
