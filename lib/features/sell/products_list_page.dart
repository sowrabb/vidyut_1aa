import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import 'models.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';
import 'widgets/product_row.dart';
import 'widgets/products_filters.dart';

class ProductsListPage extends ConsumerStatefulWidget {
  const ProductsListPage({super.key});
  @override
  ConsumerState<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends ConsumerState<ProductsListPage> {
  final _selected = <String>{};
  final _cats = <String>{};
  final _stats = <ProductStatus>{};
  double _pStart = 0, _pEnd = 100000;
  String _sort = 'date';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(sellerStoreProvider);
    var list = store.products;

    // filter
    list = list.where((p) {
      final qOk = _query.isEmpty ||
          p.title.toLowerCase().contains(_query.toLowerCase()) ||
          p.brand.toLowerCase().contains(_query.toLowerCase());
      final cOk = _cats.isEmpty || _cats.contains(p.categorySafe);
      final sOk = _stats.isEmpty || _stats.contains(p.status);
      final prOk = p.price >= _pStart && p.price <= _pEnd;
      return qOk && cOk && sOk && prOk;
    }).toList();

    // sort
    list.sort((a, b) {
      switch (_sort) {
        case 'priceAsc':
          return a.price.compareTo(b.price);
        case 'priceDesc':
          return b.price.compareTo(a.price);
        case 'date':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!store.canAddProduct()) {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Product Limit Reached'),
                content: Text(
                    'You have reached your product limit (${store.products.length}/${store.maxProducts}). Upgrade your plan to add more products.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/subscription');
                    },
                    child: const Text('Upgrade Plan'),
                  ),
                ],
              ),
            );
            return;
          }
          final p = await Navigator.of(context).push<Product>(
              MaterialPageRoute(builder: (_) => const ProductFormPage()));
          if (p != null) store.addProduct(p);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: SafeArea(
        child: ContentClamp(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Top bar: add / bulk actions - visible on all screen sizes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Product button and Select All checkbox
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                          onPressed: () async {
                            if (!store.canAddProduct()) {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Product Limit Reached'),
                                  content: Text(
                                      'You have reached your product limit (${store.products.length}/${store.maxProducts}). Upgrade your plan to add more products.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close')),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.of(context)
                                            .pushNamed('/subscription');
                                      },
                                      child: const Text('Upgrade Plan'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            final p = await Navigator.of(context).push<Product>(
                                MaterialPageRoute(
                                    builder: (_) => const ProductFormPage()));
                            if (p != null) store.addProduct(p);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product')),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _selected.length == list.length &&
                                list.isNotEmpty,
                            tristate: list.isNotEmpty &&
                                _selected.isNotEmpty &&
                                _selected.length < list.length,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selected
                                    ..clear()
                                    ..addAll(list.map((p) => p.id));
                                } else {
                                  _selected.clear();
                                }
                              });
                            },
                          ),
                          const Text('Select All'),
                        ],
                      ),
                    ],
                  ),
                  // Bulk actions - shown when items are selected
                  if (_selected.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _BulkActionsBar(
                      selectedCount: _selected.length,
                      onDeleteSoft: () {
                        final store = ref.read(sellerStoreProvider);
                        store.bulkDelete(_selected, hard: false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Archived ${_selected.length} item(s)')),
                        );
                        setState(_selected.clear);
                      },
                      onDeleteHard: () {
                        final store = ref.read(sellerStoreProvider);
                        store.bulkDelete(_selected, hard: true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Deleted ${_selected.length} item(s)')),
                        );
                        setState(_selected.clear);
                      },
                      onSetStatus: (status) {
                        final store = ref.read(sellerStoreProvider);
                        store.bulkSetStatus(_selected, status);
                        final label = switch (status) {
                          ProductStatus.active => 'Active',
                          ProductStatus.inactive => 'Inactive',
                          ProductStatus.pending => 'Pending',
                          ProductStatus.draft => 'Draft',
                          ProductStatus.archived => 'Archived',
                        };
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Set $label for ${_selected.length} item(s)')),
                        );
                        setState(_selected.clear);
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Filters
              ProductsFilters(
                onQuery: (q) => setState(() => _query = q),
                selectedCategories: _cats,
                selectedStatuses: _stats,
                onToggleCategory: (c) => setState(() => _cats.toggle(c)),
                onToggleStatus: (s) => setState(() => _stats.toggle(s)),
                onPrice: (a, b) => setState(() {
                  _pStart = a;
                  _pEnd = b;
                }),
                onSort: (v) => setState(() => _sort = v),
                priceStart: _pStart,
                priceEnd: _pEnd,
                sort: _sort,
              ),
              const SizedBox(height: 12),

              // List
              for (final p in list)
                ProductRow(
                  product: p,
                  selectable: true,
                  selected: _selected.contains(p.id),
                  onSelectedChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(p.id);
                    } else {
                      _selected.remove(p.id);
                    }
                  }),
                  onEdit: () async {
                    final updated = await Navigator.of(context).push<Product>(
                        MaterialPageRoute(
                            builder: (_) => ProductFormPage(product: p)));
                    if (updated != null) store.updateProduct(updated);
                  },
                  onView: () {
                    ref.read(sellerStoreProvider).recordProductView(p.id);
                    final location = ref.read(locationControllerProvider);
                    final analytics = ref.read(analyticsServiceProvider);
                    analytics.logView(
                      type: 'view.product',
                      entityType: 'product',
                      entityId: p.id,
                      userId: 'anon',
                      state: location.stateName,
                      city: location.city,
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: p)));
                  },
                  onDelete: () {
                    store.deleteProduct(p.id);
                    setState(() {
                      _selected.remove(p.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                  },
                ),

              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No products match filters.')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkActionsBar extends StatelessWidget {
  final int selectedCount;
  final void Function(ProductStatus status) onSetStatus;
  final VoidCallback onDeleteSoft;
  final VoidCallback onDeleteHard;

  const _BulkActionsBar({
    required this.selectedCount,
    required this.onSetStatus,
    required this.onDeleteSoft,
    required this.onDeleteHard,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onDeleteSoft,
          icon: const Icon(Icons.archive_outlined),
          label: Text('Archive ($selectedCount)'),
        ),
        OutlinedButton.icon(
          onPressed: onDeleteHard,
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text('Delete ($selectedCount)'),
        ),
        PopupMenuButton<ProductStatus>(
          tooltip: 'Set Status',
          onSelected: onSetStatus,
          itemBuilder: (context) => const [
            PopupMenuItem(
                value: ProductStatus.active, child: Text('Set Active')),
            PopupMenuItem(
                value: ProductStatus.inactive, child: Text('Set Inactive')),
            PopupMenuItem(
                value: ProductStatus.pending, child: Text('Set Pending')),
            PopupMenuItem(value: ProductStatus.draft, child: Text('Set Draft')),
            PopupMenuItem(
                value: ProductStatus.archived, child: Text('Set Archived')),
          ],
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Set Status'),
          ),
        ),
      ],
    );
  }
}

extension _Toggle<E> on Set<E> {
  void toggle(E e) => contains(e) ? remove(e) : add(e);
}
