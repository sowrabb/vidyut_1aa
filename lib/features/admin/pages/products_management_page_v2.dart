/// Modern products management page using repository-backed providers
/// For product moderation and admin control.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../../state/session/rbac.dart';
import '../../../features/sell/models.dart';

class ProductsManagementPageV2 extends ConsumerStatefulWidget {
  const ProductsManagementPageV2({super.key});

  @override
  ConsumerState<ProductsManagementPageV2> createState() =>
      _ProductsManagementPageV2State();
}

class _ProductsManagementPageV2State
    extends ConsumerState<ProductsManagementPageV2> {
  String _searchQuery = '';
  ProductStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    // Use existing firebaseProductsProvider with filters
    final productsAsync = ref.watch(firebaseProductsProvider({
      'status': _statusFilter,
      'limit': 100,
    }));
    final rbac = ref.watch(rbacProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(firebaseProductsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: productsAsync.when(
              data: (products) => _buildProductsList(products, rbac),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(firebaseProductsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<ProductStatus?>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _statusFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...ProductStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    )),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products, RbacState rbac) {
    // Apply search filter
    var filteredProducts = products.where((product) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product, rbac);
      },
    );
  }

  Widget _buildProductCard(Product product, RbacState rbac) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: product.images.isNotEmpty
            ? Image.network(
                product.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
              )
            : const Icon(Icons.image, size: 60),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${product.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(product.status),
              ],
            ),
          ],
        ),
        trailing: rbac.can('products.write')
            ? PopupMenuButton<String>(
                onSelected: (action) => _handleProductAction(action, product),
                itemBuilder: (context) => [
                  if (product.status == ProductStatus.pending)
                    const PopupMenuItem(
                      value: 'approve',
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Approve'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (product.status == ProductStatus.active)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: ListTile(
                        leading: Icon(Icons.block),
                        title: Text('Deactivate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  else if (product.status == ProductStatus.inactive)
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.check_circle),
                        title: Text('Activate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
    Color color;
    switch (status) {
      case ProductStatus.active:
        color = Colors.green;
        break;
      case ProductStatus.pending:
        color = Colors.orange;
        break;
      case ProductStatus.inactive:
        color = Colors.grey;
        break;
      case ProductStatus.draft:
        color = Colors.blueGrey;
        break;
      case ProductStatus.archived:
        color = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleProductAction(String action, Product product) async {
    final repo = ref.read(firestoreRepositoryServiceProvider);

    switch (action) {
      case 'approve':
        final confirmed = await _showConfirmDialog(
          'Approve Product',
          'Approve ${product.name}?',
        );
        if (confirmed) {
          try {
            await repo.updateProduct(product.id, {
              'status': ProductStatus.active.value,
            });
            ref.invalidate(firebaseProductsProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product approved')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
        break;

      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon')),
        );
        break;

      case 'deactivate':
        try {
          await repo.updateProduct(product.id, {
            'status': ProductStatus.inactive.value,
          });
          ref.invalidate(firebaseProductsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deactivated')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
        break;

      case 'activate':
        try {
          await repo.updateProduct(product.id, {
            'status': ProductStatus.active.value,
          });
          ref.invalidate(firebaseProductsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product activated')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          'Delete Product',
          'Delete ${product.name}? This cannot be undone.',
        );
        if (confirmed) {
          try {
            // Soft delete by setting status to inactive
            await repo.updateProduct(product.id, {
              'status': ProductStatus.inactive.value,
            });
            ref.invalidate(firebaseProductsProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
        break;
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
