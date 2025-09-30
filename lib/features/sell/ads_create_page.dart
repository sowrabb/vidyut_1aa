import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
// seller store accessed via providers
import '../../../app/provider_registry.dart';
import '../../widgets/product_picker.dart';
import 'models.dart';

class AdsCreatePage extends ConsumerStatefulWidget {
  const AdsCreatePage({super.key});
  @override
  ConsumerState<AdsCreatePage> createState() => _AdsCreatePageState();
}

class _AdsCreatePageState extends ConsumerState<AdsCreatePage> {
  AdType _type = AdType.search;
  final _termCtrl = TextEditingController();
  String _previewRank = '';
  Product? _selectedProduct;

  void _recomputePreview() {
    final store = ref.read(sellerStoreProvider);
    final taken = store.ads
        .where((a) =>
            a.type == _type &&
            a.term.toLowerCase() == _termCtrl.text.trim().toLowerCase())
        .map((a) => a.slot)
        .toSet();
    int slot = 1;
    while (taken.contains(slot) && slot <= 5) {
      slot++;
    }
    if (slot > 5) {
      _previewRank = 'Top 5 full for this target';
    } else {
      _previewRank = 'You will get position #$slot';
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _termCtrl.addListener(_recomputePreview);
  }

  @override
  void dispose() {
    _termCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(sellerStoreProvider);
    final canCreateMore = store.ads.length < 3;
    return Scaffold(
      appBar: AppBar(title: const Text('New Ad')),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!canCreateMore)
                Card(
                  color: Colors.yellow.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'You already have 3 campaigns. Pay ₹999/year to unlock more.')),
                    ]),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                      value: AdType.search, child: Text('Search keyword')),
                  DropdownMenuItem(
                      value: AdType.category, child: Text('Category name')),
                  DropdownMenuItem(
                      value: AdType.product, child: Text('Specific product')),
                ],
                onChanged: (v) {
                  setState(() {
                    _type = v ?? AdType.search;
                  });
                  _recomputePreview();
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.campaign), labelText: 'Ad Type'),
              ),
              const SizedBox(height: 12),
              if (_type != AdType.product)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _type = AdType.product);
                        _recomputePreview();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                      label: const Text('Switch to Specific product'),
                    ),
                  ),
                ),
              if (_type == AdType.product)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_selectedProduct == null)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final analytics = ref.read(analyticsServiceProvider);
                          analytics.logEvent(type: 'ads_product_picker_opened');
                          final selected = await showDialog<Product>(
                            context: context,
                            builder: (ctx) => Dialog(
                              child: SizedBox(
                                width: 720,
                                height: 520,
                                child: ProductPicker(
                                  onSelected: (p) {
                                    Navigator.of(ctx).pop(p);
                                  },
                                ),
                              ),
                            ),
                          );
                          if (selected != null) {
                            setState(() {
                              _selectedProduct = selected;
                              _termCtrl.text = selected
                                  .id; // store id for backend term fallback if needed
                            });
                            analytics.logEvent(
                              type: 'ads_product_selected',
                              entityType: 'product',
                              entityId: selected.id,
                            );
                          }
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Select Product'),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedProduct!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '₹ ${_selectedProduct!.price.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  final analytics =
                                      ref.read(analyticsServiceProvider);
                                  analytics.logEvent(
                                      type: 'ads_product_picker_opened');
                                  final selected = await showDialog<Product>(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                      child: SizedBox(
                                        width: 720,
                                        height: 520,
                                        child: ProductPicker(
                                          onSelected: (p) {
                                            Navigator.of(ctx).pop(p);
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                  if (selected != null) {
                                    setState(() {
                                      _selectedProduct = selected;
                                      _termCtrl.text = selected.id;
                                    });
                                    analytics.logEvent(
                                      type: 'ads_product_selected',
                                      entityType: 'product',
                                      entityId: selected.id,
                                    );
                                  }
                                },
                                child: const Text('Change'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                  onPressed: () {
                                    final analytics =
                                        ref.read(analyticsServiceProvider);
                                    analytics.logEvent(
                                        type: 'ads_product_cleared');
                                    setState(() {
                                      _selectedProduct = null;
                                      _termCtrl.clear();
                                    });
                                  },
                                  child: const Text('Clear')),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              else
                TextField(
                  controller: _termCtrl,
                  decoration: InputDecoration(
                    labelText: _type == AdType.search ? 'Keyword' : 'Category',
                    hintText: _type == AdType.search
                        ? 'e.g., copper'
                        : 'e.g., Cables & Wires',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              const SizedBox(height: 12),
              if (_previewRank.isNotEmpty)
                Text(_previewRank,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: (!canCreateMore)
                    ? null
                    : () {
                        if (_type == AdType.product &&
                            _selectedProduct == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a product')),
                          );
                          return;
                        }
                        final taken = store.ads
                            .where((a) =>
                                a.type == _type &&
                                a.term.toLowerCase() ==
                                    _termCtrl.text.trim().toLowerCase())
                            .map((a) => a.slot)
                            .toSet();
                        int slot = 1;
                        while (taken.contains(slot) && slot <= 5) {
                          slot++;
                        }
                        if (slot > 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Top 5 slots are full for this target')));
                          return;
                        }
                        final id =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        ref.read(sellerStoreProvider).upsertAd(AdCampaign(
                              id: id,
                              type: _type,
                              term: _termCtrl.text.trim(),
                              slot: slot,
                              productId: _type == AdType.product
                                  ? _selectedProduct?.id
                                  : null,
                              productTitle: _type == AdType.product
                                  ? _selectedProduct?.title
                                  : null,
                              productThumbnail: _type == AdType.product &&
                                      _selectedProduct!.images.isNotEmpty
                                  ? _selectedProduct!.images.first
                                  : null,
                            ));
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.check),
                label: const Text('Create Campaign'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
