import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../store/enhanced_admin_store.dart';
import '../../sell/models.dart' as sell;
import '../models/product_models.dart' as admin;
import '../../../models/product_status.dart';
import '../../../services/enhanced_admin_api_service.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';

/// Enhanced products management page with full CRUD, pagination, filtering, and bulk operations
class EnhancedProductsManagementPage extends StatefulWidget {
  final EnhancedAdminStore adminStore;

  const EnhancedProductsManagementPage({
    super.key,
    required this.adminStore,
  });

  @override
  State<EnhancedProductsManagementPage> createState() =>
      _EnhancedProductsManagementPageState();
}

class _EnhancedProductsManagementPageState
    extends State<EnhancedProductsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = '';
  String _selectedMaterial = '';
  String _selectedStatus = '';
  String _selectedStock = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.adminStore.addListener(_onStoreChange);
    // Ensure initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.adminStore.refreshProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    widget.adminStore.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.adminStore.loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.adminStore.refreshProducts(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Bulk Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),

          // Error Banner
          if (widget.adminStore.error != null)
            ErrorBanner(
              message: widget.adminStore.error!,
              onDismiss: () => widget.adminStore.clearError(),
            ),

          // Bulk Actions Bar
          if (widget.adminStore.selectedProductIds.isNotEmpty)
            BulkActionsBar(
              selectedCount: widget.adminStore.selectedProductIds.length,
              totalCount: widget.adminStore.totalCount,
              onSelectAll: () => widget.adminStore.selectAllProducts(),
              onDeselectAll: () => widget.adminStore.deselectAllProducts(),
              onBulkAction: _handleBulkAction,
            ),

          // Products List
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => widget.adminStore.refreshProducts(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.adminStore.products.length +
                        (widget.adminStore.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= widget.adminStore.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final product = widget.adminStore.products[index];
                      final isSelected = widget.adminStore.selectedProductIds
                          .contains(product.id);

                      return _buildProductCard(product, isSelected);
                    },
                  ),
                ),

                // Loading Overlay
                if (widget.adminStore.isLoading) const LoadingOverlay(),
              ],
            ),
          ),

          // Pagination Bar
          PaginationBar(
            currentPage: widget.adminStore.currentPage,
            totalCount: widget.adminStore.totalCount,
            hasMore: widget.adminStore.hasMore,
            onPageChanged: (page) {
              // Handle page change if needed
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) =>
                      widget.adminStore.setProductSearchQuery(query),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                hint: const Text('Category'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Categories')),
                  DropdownMenuItem(
                      value: 'wires-cables', child: Text('Wires & Cables')),
                  DropdownMenuItem(value: 'lights', child: Text('Lights')),
                  DropdownMenuItem(value: 'motors', child: Text('Motors')),
                  DropdownMenuItem(value: 'tools', child: Text('Tools')),
                  DropdownMenuItem(
                      value: 'circuit-breakers',
                      child: Text('Circuit Breakers')),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value ?? '');
                  widget.adminStore.setProductCategoryFilter(value ?? '');
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedMaterial.isEmpty ? null : _selectedMaterial,
                hint: const Text('Material'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Materials')),
                  DropdownMenuItem(value: 'copper', child: Text('Copper')),
                  DropdownMenuItem(value: 'aluminum', child: Text('Aluminum')),
                  DropdownMenuItem(value: 'steel', child: Text('Steel')),
                  DropdownMenuItem(value: 'plastic', child: Text('Plastic')),
                ],
                onChanged: (value) {
                  setState(() => _selectedMaterial = value ?? '');
                  widget.adminStore.setProductMaterialFilter(value ?? '');
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedStatus.isEmpty ? null : _selectedStatus,
                hint: const Text('Status'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(
                      value: 'pending', child: Text('Pending Review')),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value ?? '');
                  widget.adminStore.setProductStatusFilter(value ?? '');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedStock.isEmpty ? null : _selectedStock,
                hint: const Text('Stock'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Stock')),
                  DropdownMenuItem(value: 'in-stock', child: Text('In Stock')),
                  DropdownMenuItem(
                      value: 'low-stock', child: Text('Low Stock')),
                  DropdownMenuItem(
                      value: 'out-of-stock', child: Text('Out of Stock')),
                ],
                onChanged: (value) {
                  setState(() => _selectedStock = value ?? '');
                  widget.adminStore.setProductStockFilter(value ?? '');
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _sortBy,
                hint: const Text('Sort By'),
                items: const [
                  DropdownMenuItem(
                      value: 'createdAt', child: Text('Created Date')),
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'price', child: Text('Price')),
                  DropdownMenuItem(value: 'stock', child: Text('Stock')),
                  DropdownMenuItem(value: 'views', child: Text('Views')),
                ],
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  if (value != null)
                    widget.adminStore.setProductSorting(value, _sortOrder);
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _sortOrder,
                hint: const Text('Order'),
                items: const [
                  DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                  DropdownMenuItem(value: 'desc', child: Text('Descending')),
                ],
                onChanged: (value) {
                  setState(() => _sortOrder = value!);
                  if (value != null)
                    widget.adminStore.setProductSorting(_sortBy, value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(admin.Product product, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        child: CheckboxListTile(
          value: isSelected,
          onChanged: (selected) {
            if (selected == true) {
              widget.adminStore.selectProduct(product.id);
            } else {
              widget.adminStore.deselectProduct(product.id);
            }
          },
          secondary: CircleAvatar(
            backgroundImage: product.images.isNotEmpty
                ? (product.images.first.startsWith('assets/')
                    ? AssetImage(product.images.first) as ImageProvider
                    : NetworkImage(product.images.first))
                : null,
            child: product.images.isEmpty ? const Icon(Icons.image) : null,
          ),
          title: Text(product.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.description),
              const SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(product.category),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(product.materials.isNotEmpty
                        ? product.materials.first
                        : ''),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('₹${product.price.toStringAsFixed(2)}'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.green.shade100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportProducts();
        break;
      case 'import':
        _importProducts();
        break;
      case 'bulk_edit':
        _showBulkEditDialog();
        break;
    }
  }

  void _handleBulkAction(String action) {
    switch (action) {
      case 'activate':
        _bulkUpdateStatus('active');
        break;
      case 'deactivate':
        _bulkUpdateStatus('inactive');
        break;
      case 'delete':
        _showBulkDeleteDialog();
        break;
    }
  }

  Future<void> _exportProducts() async {
    try {
      final csv = await widget.adminStore.exportProductsCsv();
      await Clipboard.setData(ClipboardData(text: csv));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products exported to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importProducts() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final content = String.fromCharCodes(file.bytes!);

        // Show preview dialog first
        final previewResult = await _showImportPreviewDialog(content);
        if (previewResult != null && previewResult) {
          final importResult =
              await widget.adminStore.importProductsCsv(content);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Import completed: ${importResult.successCount} successful, ${importResult.failureCount} failed'),
                action: importResult.errors.isNotEmpty
                    ? SnackBarAction(
                        label: 'View Errors',
                        onPressed: () =>
                            _showImportErrorsDialog(importResult.errors),
                      )
                    : null,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<bool?> _showImportPreviewDialog(String csvContent) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'This will import products from the CSV file. Continue?'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Show dry run first
                final dryRunResult = await widget.adminStore
                    .importProductsCsv(csvContent, dryRun: true);

                if (mounted) {
                  Navigator.of(context).pop();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Dry Run Results'),
                      content: Text(
                        'Found ${dryRunResult.successCount} valid products, ${dryRunResult.failureCount} errors.\n\n'
                        'Proceed with import?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
              child: const Text('Preview & Import'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImportErrorsDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Errors'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: errors.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(errors[index]),
              dense: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkUpdateStatus(String status) async {
    try {
      final result = await widget.adminStore.bulkUpdateProductStatus(status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Bulk update completed: ${result.successCount} successful, ${result.failureCount} failed'),
            action: result.errors.isNotEmpty
                ? SnackBarAction(
                    label: 'View Errors',
                    onPressed: () => _showImportErrorsDialog(result.errors),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk update failed: $e')),
        );
      }
    }
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Products'),
        content: Text(
          'Are you sure you want to delete ${widget.adminStore.selectedProductIds.length} products? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Implement bulk delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bulk delete not implemented yet')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Edit Products'),
        content: const Text('Bulk edit functionality will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(admin.Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', product.description),
              _buildDetailRow('Category', product.category),
              _buildDetailRow('Material',
                  product.materials.isNotEmpty ? product.materials.first : ''),
              _buildDetailRow('Price', '₹${product.price.toStringAsFixed(2)}'),
              _buildDetailRow('MOQ', product.moq.toString()),
              _buildDetailRow('Unit', ''),
              _buildDetailRow('Created', product.createdAt.toString()),
              if (product.images.isNotEmpty) ...[
                const Divider(),
                const Text('Images',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.images.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        product.images[index],
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditProductDialog(product);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCreateProductDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateProductDialog(
        onSave: (request) async {
          try {
            await widget.adminStore.createProduct(request);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product created successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create product: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditProductDialog(admin.Product product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        product: product,
        onSave: (request) async {
          try {
            await widget.adminStore.updateProduct(product.id, request);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update product: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteProductDialog(admin.Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await widget.adminStore.deleteProduct(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Product deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete product: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ================= Dialog Widgets =================

class CreateProductDialog extends StatefulWidget {
  final Function(admin.CreateProductRequest) onSave;

  const CreateProductDialog({super.key, required this.onSave});

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _gstController = TextEditingController();
  final _unitController = TextEditingController();

  String _selectedCategory = 'wires-cables';
  String _selectedMaterial = 'copper';
  String _selectedStatus = 'active';

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _gstController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Price is required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Stock is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: const [
                          DropdownMenuItem(
                              value: 'wires-cables',
                              child: Text('Wires & Cables')),
                          DropdownMenuItem(
                              value: 'lights', child: Text('Lights')),
                          DropdownMenuItem(
                              value: 'motors', child: Text('Motors')),
                          DropdownMenuItem(
                              value: 'tools', child: Text('Tools')),
                          DropdownMenuItem(
                              value: 'circuit-breakers',
                              child: Text('Circuit Breakers')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        decoration:
                            const InputDecoration(labelText: 'Material'),
                        items: const [
                          DropdownMenuItem(
                              value: 'copper', child: Text('Copper')),
                          DropdownMenuItem(
                              value: 'aluminum', child: Text('Aluminum')),
                          DropdownMenuItem(
                              value: 'steel', child: Text('Steel')),
                          DropdownMenuItem(
                              value: 'plastic', child: Text('Plastic')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedMaterial = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending Review')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final request = admin.CreateProductRequest(
        title: _nameController.text,
        brand: _brandController.text,
        subtitle: _subtitleController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        images: [],
        price: double.parse(_priceController.text),
        moq: int.parse(_stockController.text),
        gstRate: double.parse(_gstController.text),
        materials: _selectedMaterial.isNotEmpty ? [_selectedMaterial] : [],
        customValues: {},
        status: ProductStatus.fromString(_selectedStatus),
      );

      widget.onSave(request);
    }
  }
}

class EditProductDialog extends StatefulWidget {
  final admin.Product product;
  final Function(admin.UpdateProductRequest) onSave;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _subtitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _gstController;
  late TextEditingController _unitController;

  late String _selectedCategory;
  late String _selectedMaterial;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.title);
    _brandController = TextEditingController(text: widget.product.brand);
    _subtitleController = TextEditingController(text: widget.product.subtitle);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _stockController =
        TextEditingController(text: widget.product.moq.toString());
    _gstController =
        TextEditingController(text: widget.product.gstRate.toString());
    _unitController = TextEditingController(text: '');

    _selectedCategory = widget.product.category;
    _selectedMaterial = widget.product.materials.isNotEmpty
        ? widget.product.materials.first
        : '';
    _selectedStatus = widget.product.status.toString().split('.').last;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _gstController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.product.title}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Price is required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Stock is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: const [
                          DropdownMenuItem(
                              value: 'wires-cables',
                              child: Text('Wires & Cables')),
                          DropdownMenuItem(
                              value: 'lights', child: Text('Lights')),
                          DropdownMenuItem(
                              value: 'motors', child: Text('Motors')),
                          DropdownMenuItem(
                              value: 'tools', child: Text('Tools')),
                          DropdownMenuItem(
                              value: 'circuit-breakers',
                              child: Text('Circuit Breakers')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        decoration:
                            const InputDecoration(labelText: 'Material'),
                        items: const [
                          DropdownMenuItem(
                              value: 'copper', child: Text('Copper')),
                          DropdownMenuItem(
                              value: 'aluminum', child: Text('Aluminum')),
                          DropdownMenuItem(
                              value: 'steel', child: Text('Steel')),
                          DropdownMenuItem(
                              value: 'plastic', child: Text('Plastic')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedMaterial = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending Review')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final request = admin.UpdateProductRequest(
        title: _nameController.text,
        brand: _brandController.text,
        subtitle: _subtitleController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        images: [],
        price: double.parse(_priceController.text),
        moq: int.parse(_stockController.text),
        gstRate: double.parse(_gstController.text),
        materials: _selectedMaterial.isNotEmpty ? [_selectedMaterial] : [],
        customValues: {},
        status: ProductStatus.fromString(_selectedStatus),
      );

      widget.onSave(request);
    }
  }
}
