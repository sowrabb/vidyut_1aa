import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import 'store/seller_store.dart';
import 'models.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';
import 'widgets/product_row.dart';
import 'widgets/products_filters.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});
  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  final _selected = <String>{};
  final _cats = <String>{};
  final _stats = <ProductStatus>{};
  double _pStart = 0, _pEnd = 100000;
  String _sort = 'date';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerStore(),
      builder: (context, _) {
        final store = context.watch<SellerStore>();
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
                  // Top bar: add / bulk actions (hidden on mobile, shown on web)
                  if (context.isDesktop || context.isTablet) ...[
                    ResponsiveRow(children: [
                      FilledButton.icon(
                          onPressed: () async {
                            final p = await Navigator.of(context).push<Product>(
                                MaterialPageRoute(
                                    builder: (_) => const ProductFormPage()));
                            if (p != null) store.addProduct(p);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product')),
                      if (_selected.isNotEmpty)
                        OutlinedButton.icon(
                            onPressed: () {
                              for (final id in _selected.toList()) {
                                store.deleteProduct(id);
                                _selected.remove(id);
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete),
                            label: Text('Delete (${_selected.length})')),
                    ]),
                    const SizedBox(height: 12),
                  ],

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
                      onEdit: () async {
                        final updated = await Navigator.of(context)
                            .push<Product>(MaterialPageRoute(
                                builder: (_) => ProductFormPage(product: p)));
                        if (updated != null) store.updateProduct(updated);
                      },
                      onView: () {
                        context.read<SellerStore>().recordProductView(p.id);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: p)));
                      },
                      onDelete: () {
                        store.deleteProduct(p.id);
                        setState(() {
                          _selected.remove(p.id);
                        });
                      },
                      // add selection on tile tap (optional)
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
      },
    );
  }
}

extension _Toggle<E> on Set<E> {
  void toggle(E e) => contains(e) ? remove(e) : add(e);
}
