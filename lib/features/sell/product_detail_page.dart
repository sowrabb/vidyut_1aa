import 'package:flutter/material.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/tokens.dart';
import '../../app/app_state.dart';
import '../../app/geo.dart';
import 'package:provider/provider.dart';
import '../sell/models.dart';
import '../home/widgets/product_card.dart';
import 'seller_page.dart';
import 'package:ionicons/ionicons.dart';
import 'store/seller_store.dart';
import '../search/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    // Record a view when this page builds (simple demo; could be guarded to once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<SellerStore>().recordProductView(product.id);
      }
    });

    return AppShellScaffold(
      selectedIndex: 1, // default: Search tab for product discovery context
      appBar: const VidyutAppBar(title: 'Vidyut'),
      body: SafeArea(
        child: ContentClamp(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Gallery + Meta  (2-col desktop / 1-col mobile)
              ResponsiveRow(desktop: 2, tablet: 2, phone: 1, children: [
                // Gallery
                _Gallery(images: product.images),
                // Meta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleBlock(product: product),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<SellerStore>().recordProductContactCall(product.id);
                          },
                          icon: const Icon(Icons.call),
                          label: const Text('Contact Supplier'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<SellerStore>().recordProductContactWhatsapp(product.id);
                          },
                          icon: const Icon(Ionicons.logo_whatsapp),
                          label: const Text('WhatsApp'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.whatsapp,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _SellerMiniCard(product: product),
                  ],
                ),
              ]),
              const SizedBox(height: 24),

              // Description
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.outlineSoft),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(product.description.isEmpty
                      ? 'No description provided.'
                      : product.description),
                ),
              ),

              const SizedBox(height: 24),
              // Specifications
              _SpecTable(product: product),

              const SizedBox(height: 24),
              // Related products by category/materials (mock: you can pass in actual list in real app)
              Text('Related in ${product.categorySafe}', style: t.titleLarge),
              const SizedBox(height: 12),
              _RelatedStrip(anchor: product),
              const SizedBox(height: 24),

              // Reviews placeholder
              Text('Reviews', style: t.titleLarge),
              const SizedBox(height: 8),
              const Text('TODO: Show reviews here'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;
  const _Gallery({required this.images});

  @override
  Widget build(BuildContext context) {
    final pics = images.isEmpty
        ? List<String>.generate(
            4, (i) => 'https://picsum.photos/seed/detail_$i/1200/800')
        : images;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(pics.first, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(pics[i],
                  width: 96, height: 72, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecTable extends StatelessWidget {
  final Product product;
  const _SpecTable({required this.product});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = <MapEntry<String, String>>[
      MapEntry('Brand', product.brand),
      MapEntry('Category', product.categorySafe),
      MapEntry('MOQ', '${product.moq}'),
      MapEntry('GST %', product.gstRate.toStringAsFixed(0)),
      MapEntry('Materials',
          product.materials.isEmpty ? '-' : product.materials.join(', ')),
      MapEntry('Status', product.status.name),
    ];
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineSoft)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: rows
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 120, child: Text(e.key, style: t.bodySmall)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(e.value,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final Product product;
  const _TitleBlock({required this.product});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Title
      Text(product.title.isEmpty ? 'Product' : product.title,
          style: t.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      // Brand and Category links
      Wrap(spacing: 8, runSpacing: 8, children: [
        ActionChip(
          label: Text(product.brand),
          avatar: const Icon(Icons.sell_outlined, size: 16),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchPage()));
          },
        ),
        ActionChip(
          label: Text(product.categorySafe),
          avatar: const Icon(Icons.category_outlined, size: 16),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchPage()));
          },
        ),
      ]),
      const SizedBox(height: 12),
      // Price on separate row, 2x size
      Text('₹${product.price.toStringAsFixed(0)}',
          style: t.headlineMedium
              ?.copyWith(fontSize: (t.headlineMedium?.fontSize ?? 24) * 2)),
    ]);
  }
}

class _SellerMiniCard extends StatelessWidget {
  final Product product;
  const _SellerMiniCard({required this.product});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final appState = context.read<AppState>();
    final buyerLat = appState.latitude;
    final buyerLng = appState.longitude;
    double? distKm;
    if (buyerLat != null && buyerLng != null) {
      final baseLat = 17.3850;
      final baseLng = 78.4867;
      final delta = (product.brand.hashCode % 1000) / 10000.0;
      final sLat = baseLat + delta;
      final sLng = baseLng + delta;
      distKm =
          distanceKm(lat1: buyerLat, lon1: buyerLng, lat2: sLat, lon2: sLng);
    }
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineSoft)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  SellerPage(sellerName: '${product.brand} Distributors'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sold by', style: t.bodySmall),
            const SizedBox(height: 6),
            Row(
              children: [
                const CircleAvatar(radius: 16, child: Icon(Icons.storefront)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('${product.brand} Distributors',
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(
                label: const Text('Verified'),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(color: Colors.green.shade800),
                avatar: const Icon(Icons.check_circle,
                    color: Colors.green, size: 16),
              ),
              Chip(label: const Text('4.5 ★ (127 reviews)')),
              if (distKm != null)
                Chip(label: Text('${distKm.toStringAsFixed(1)} km away')),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: Text('Video native verified',
                    style:
                        t.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ),
              IconButton(
                tooltip: 'View on map',
                onPressed: () {
                  final baseLat = 17.3850;
                  final baseLng = 78.4867;
                  final delta = (product.brand.hashCode % 1000) / 10000.0;
                  final sLat = baseLat + delta;
                  final sLng = baseLng + delta;
                  final url = Uri.parse(
                      'https://www.openstreetmap.org/?mlat=$sLat&mlon=$sLng#map=14/$sLat/$sLng');
                  launchUrl(url, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.location_on_outlined),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RelatedStrip extends StatelessWidget {
  final Product anchor;
  const _RelatedStrip({required this.anchor});
  @override
  Widget build(BuildContext context) {
    // For demo, synthesize 8 similar cards
    final related = List<Product>.generate(
        8,
        (i) => Product(
              id: 'R${i + 1}',
              title: 'Similar ${i + 1}',
              brand: i.isEven ? anchor.brand : 'Generic',
              category: anchor.categorySafe,
              subtitle: 'Spec ${i + 1}',
              price: anchor.price * (0.8 + i * 0.03),
              materials:
                  anchor.materials.isEmpty ? ['Copper'] : anchor.materials,
            ));
    return LayoutBuilder(
      builder: (_, bc) {
        final isDesktop = bc.maxWidth >= AppBreaks.desktop;
        final extent = isDesktop ? AppLayout.productCardMax : 300.0;
        final ratio = isDesktop ? 0.80 : 0.74;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: related.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: extent,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemBuilder: (_, i) => ProductCard(
            productId: related[i].id,
            title: related[i].title,
            brand: related[i].brand,
            price: '₹${related[i].price.toStringAsFixed(0)}',
            subtitle: related[i].subtitle,
            imageUrl: 'https://picsum.photos/seed/related_$i/800/600',
            phone: '9000000000',
            whatsappNumber: '9000000000',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: related[i]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
