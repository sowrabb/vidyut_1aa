import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/tokens.dart';
import '../store/admin_store.dart';
import '../admin_shell.dart';
import '../../../app/layout/adaptive.dart';

class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  State<CategoriesManagementPage> createState() => _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, store, _) {
        final categories = _getFilteredCategories(store.categories);
        
        return SafeArea(
          child: ContentClamp(
            child: Column(
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
                        DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                        DropdownMenuItem(value: 'products', child: Text('Sort by Products')),
                        DropdownMenuItem(value: 'created', child: Text('Sort by Created')),
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
                  ],
                ),
                
                // Categories list
                Expanded(
                  child: categories.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined, size: 64, color: AppColors.textSecondary),
                              SizedBox(height: 16),
                              Text(
                                'No categories found',
                                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CategoryCard(
                              category: category,
                              onEdit: () => _showEditCategoryDialog(context, store, category),
                              onDelete: () => _showDeleteCategoryDialog(context, store, category),
                              onToggleActive: () => store.toggleCategoryActive(category.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<AdminCategoryData> _getFilteredCategories(List<AdminCategoryData> categories) {
    var filtered = categories.where((category) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!category.name.toLowerCase().contains(query) &&
            !category.description.toLowerCase().contains(query)) {
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
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'products':
          return b.productCount.compareTo(a.productCount);
        case 'created':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });
    
    return filtered;
  }

  void _showAddCategoryDialog(BuildContext context, AdminStore store) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        onSave: (category) {
          store.addCategory(category);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, AdminStore store, AdminCategoryData category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        category: category,
        onSave: (updatedCategory) {
          store.updateCategory(updatedCategory);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, AdminStore store, AdminCategoryData category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              store.deleteCategory(category.id);
              Navigator.pop(context);
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.isActive ? AppColors.primary : AppColors.textSecondary,
          child: Text(
            category.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: category.isActive ? null : AppColors.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.description),
            const SizedBox(height: 4),
            Text(
              '${category.productCount} products',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onToggleActive,
              icon: Icon(
                category.isActive ? Icons.visibility : Icons.visibility_off,
                color: category.isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final AdminCategoryData? category;
  final Function(AdminCategoryData) onSave;

  const _CategoryDialog({
    this.category,
    required this.onSave,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priorityController = TextEditingController();
  
  List<String> _selectedMaterials = [];
  bool _isActive = true;

  final List<String> _availableMaterials = [
    'Copper', 'Aluminum', 'Steel', 'PVC', 'Rubber', 'Fiber', 'Plastic', 'Wood'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _loadCategoryData();
    }
  }

  void _loadCategoryData() {
    final category = widget.category!;
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _priorityController.text = category.priority.toString();
    _selectedMaterials = List.from(category.materials);
    _isActive = category.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.category != null ? 'Edit Category' : 'Add Category',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
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
                      
                      TextFormField(
                        controller: _priorityController,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Materials Selection
                      Text(
                        'Materials',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Wrap(
                        spacing: 8,
                        children: _availableMaterials.map((material) {
                          final isSelected = _selectedMaterials.contains(material);
                          return FilterChip(
                            label: Text(material),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMaterials.add(material);
                                } else {
                                  _selectedMaterials.remove(material);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Status
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Category will be visible to users'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text(widget.category != null ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;
    
    final category = AdminCategoryData(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      materials: _selectedMaterials.toList(),
      isActive: _isActive,
      priority: int.tryParse(_priorityController.text) ?? 0,
      productCount: widget.category?.productCount ?? 0,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: widget.category?.imageUrl ?? '',
      industries: widget.category?.industries ?? [],
    );
    
    widget.onSave(category);
  }
}
