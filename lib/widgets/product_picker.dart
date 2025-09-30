import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/sell/models.dart';
import '../../../app/provider_registry.dart';

typedef ProductSelected = void Function(Product product);

class ProductPicker extends ConsumerStatefulWidget {
  final ProductSelected onSelected;
  final String? initialQuery;
  final ProductStatus? statusFilter;

  const ProductPicker(
      {super.key,
      required this.onSelected,
      this.initialQuery,
      this.statusFilter});

  @override
  ConsumerState<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<ProductPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _page = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtrl.text = _query;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider({}));
    return productsAsync.when(
      data: (productPage) {
        List<Product> all = productPage.products;

        if (widget.statusFilter != null) {
          all = all.where((p) => p.status == widget.statusFilter).toList();
        }
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          all = all
              .where((p) =>
                  p.title.toLowerCase().contains(q) ||
                  p.brand.toLowerCase().contains(q))
              .toList();
        }

        final totalPages = (all.length / _pageSize).ceil();
        final start = _page * _pageSize;
        final end = (start + _pageSize).clamp(0, all.length);
        final items =
            start < all.length ? all.sublist(start, end) : <Product>[];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search products…',
                ),
                onChanged: (v) {
                  setState(() {
                    _query = v.trim();
                    _page = 0;
                  });
                },
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  all.isEmpty ? 'No products found' : 'No results on this page',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.2,
                  ),
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return _ProductTile(
                      product: p,
                      onTap: () {
                        widget.onSelected(p);
                      },
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Page ${totalPages == 0 ? 0 : _page + 1} of $totalPages'),
                  Row(children: [
                    IconButton(
                      onPressed: _page > 0
                          ? () => setState(() {
                                _page -= 1;
                              })
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: _page + 1 < totalPages
                          ? () => setState(() {
                                _page += 1;
                              })
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ])
                ],
              ),
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹ ${product.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
