import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import 'store/seller_store.dart';
import 'widgets/kpi_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SellerStore>();
    final t = Theme.of(context).textTheme;

    // Check if analytics is available for current plan
    if (!store.hasAnalytics) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: ContentClamp(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Analytics Not Available',
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Analytics is available for Plus and Pro plans. Upgrade your plan to access detailed analytics.',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/subscription');
                  },
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Upgrade Plan'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ContentClamp(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Analytics', style: t.headlineSmall),
              const SizedBox(height: 12),
              // KPI Grid
              _KpiGrid(
                items: [
                  _KpiItem(
                    label: 'Profile Views',
                    value: store.profileViews.toString(),
                    icon: Icons.visibility_outlined,
                  ),
                  _KpiItem(
                    label: 'Product Views',
                    value: store.totalProductViews.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                  _KpiItem(
                    label: 'Contacts (All)',
                    value: store.totalProductContacts + store.totalSellerContacts == 0
                        ? '0'
                        : (store.totalProductContacts + store.totalSellerContacts).toString(),
                    icon: Icons.phone_in_talk_outlined,
                  ),
                  _KpiItem(
                    label: 'Direct Calls',
                    value: store.sellerContactCalls.toString(),
                    icon: Icons.call_outlined,
                  ),
                  _KpiItem(
                    label: 'WhatsApp',
                    value: store.sellerContactWhatsapps.toString(),
                    icon: Icons.chat_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Top products by views
              Text('Top Products by Views', style: t.titleLarge),
              const SizedBox(height: 8),
              _TopProductsList(),
              const SizedBox(height: 16),
              // Breakdown charts (placeholder simple bars)
              Text('Engagement Breakdown', style: t.titleLarge),
              const SizedBox(height: 8),
              _EngagementBreakdown(),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiItem> items;
  const _KpiGrid({required this.items});
  @override
  Widget build(BuildContext context) {
    final cross = context.isDesktop ? 4 : (context.isTablet ? 3 : 2);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (_, i) => KpiCard(
        icon: items[i].icon,
        title: items[i].label,
        value: items[i].value,
      ),
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  const _KpiItem({required this.label, required this.value, required this.icon});
}

class _TopProductsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SellerStore>();
    final top = store.topViewedProducts;
    if (top.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No product views yet.'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: top.map((p) {
            final views = store.productViewsOf(p.id);
            final calls = store.productContactCallsOf(p.id);
            final wa = store.productContactWhatsappsOf(p.id);
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(p.title.isEmpty ? 'Product' : p.title),
              subtitle: Text('Views: $views • Calls: $calls • WhatsApp: $wa'),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EngagementBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SellerStore>();
    final entries = <(String, int)>[
      ('Profile Views', store.profileViews),
      ('Product Views', store.totalProductViews),
      ('Seller Calls', store.sellerContactCalls),
      ('Seller WhatsApp', store.sellerContactWhatsapps),
    ];
    return Column(
      children: entries.map((e) => _Bar(label: e.$1, value: e.$2)).toList(),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  const _Bar({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final max = value.clamp(0, 1000); // simple scaling guard
    final width = MediaQuery.sizeOf(context).width;
    final barWidth = ((value == 0 ? 1 : value).toDouble() / (max == 0 ? 1 : max)) * (width - 120);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 140, child: Text(label, style: t.bodySmall)),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.outlineSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.right)),
      ]),
    );
  }
}


