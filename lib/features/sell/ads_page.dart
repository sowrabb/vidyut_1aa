import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
import '../../../app/provider_registry.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ads_create_page.dart';
import '../../widgets/product_picker.dart';
import 'models.dart';

class AdsPage extends ConsumerWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sellerStoreProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ads')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!store.canAddAd()) {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Ad Limit Reached'),
                content: Text(
                    'You have reached your ad limit (${store.ads.length}/${store.maxAds}). Upgrade your plan to create more ads.'),
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
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdsCreatePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Ad'),
      ),
      body: const SafeArea(
        child: ContentClamp(
          padding: EdgeInsets.all(24),
          child: _AdsManager(),
        ),
      ),
    );
  }
}

class _AdsManager extends ConsumerWidget {
  const _AdsManager();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sellerStoreProvider);
    final ads = store.ads;
    return LayoutBuilder(builder: (context, bc) {
      final isPhone = bc.maxWidth < AppBreaks.tablet;
      final children = [for (final ad in ads) _AdCard(ad: ad)];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'Create up to ${store.maxAds} campaigns (${store.ads.length}/${store.maxAds} used)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (isPhone)
          Column(
              children: children
                  .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12), child: w))
                  .toList())
        else
          Wrap(spacing: 12, runSpacing: 12, children: children),
        if (ads.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('No campaigns yet. Tap New Ad to create one.',
                style: Theme.of(context).textTheme.bodyMedium),
          )
      ]);
    });
  }
}

class _AdCard extends ConsumerWidget {
  final AdCampaign ad;
  const _AdCard({required this.ad});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(999)),
            child: Text('Ad',
                style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(
              ad.type == AdType.search
                  ? 'Search campaign'
                  : ad.type == AdType.category
                      ? 'Category campaign'
                      : 'Product campaign',
              style: t.titleSmall),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ProviderScope.containerOf(context)
                .read(sellerStoreProvider)
                .deleteAd(ad.id),
          ),
        ]),
        const SizedBox(height: 6),
        if (ad.type == AdType.product)
          Row(children: [
            const Icon(Icons.inventory_2_outlined, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ad.productTitle ?? ad.productId ?? '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Change selected product?'),
                    content: const Text(
                        'Replacing the product will update this campaign. Continue?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Change')),
                    ],
                  ),
                );
                if (confirmed != true) return;
                final selected = await showDialog<Product>(
                  context: context,
                  builder: (ctx) => Dialog(
                    child: SizedBox(
                      width: 720,
                      height: 520,
                      child: ProductPicker(
                        onSelected: (p) => Navigator.of(ctx).pop(p),
                      ),
                    ),
                  ),
                );
                if (selected != null) {
                  ProviderScope.containerOf(context)
                      .read(sellerStoreProvider)
                      .upsertAd(ad.copyWith(
                        term: selected.id,
                        productId: selected.id,
                        productTitle: selected.title,
                        productThumbnail: selected.images.isNotEmpty
                            ? selected.images.first
                            : null,
                      ));
                }
              },
              child: const Text('Change'),
            ),
            TextButton(
              onPressed: () {
                ProviderScope.containerOf(context)
                    .read(sellerStoreProvider)
                    .upsertAd(ad.copyWith(
                        productId: null,
                        productTitle: null,
                        productThumbnail: null));
              },
              child: const Text('Clear'),
            )
          ])
        else
          Text('Target: ${ad.term}'),
        const SizedBox(height: 6),
        Text('Requested slot: #${ad.slot} (Top 5, first-come-first-serve)',
            style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () async {
              final admin = ref.read(adminStoreProvider);
              final sellerStore = ref.read(sellerStoreProvider);
              final messenger = ScaffoldMessenger.of(context);
              final phone = (admin.adsPriorityPhone.isNotEmpty)
                  ? admin.adsPriorityPhone
                  : '+91-9876543210';
              final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                sellerStore.recordSellerContactCall();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Calling not supported on this device')),
                );
              }
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Request priority with admin'),
          ),
        ),
      ]),
    );
  }
}
