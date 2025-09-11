import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
import 'store/seller_store.dart';
import 'models.dart';
import 'widgets/kpi_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerStore>(
      builder: (context, store, child) {
        return Scaffold(
          body: SafeArea(
            child: ContentClamp(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 24),

                    // KPI Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: context.isDesktop ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: context.isDesktop ? 1.5 : 1.2,
                      children: [
                        const KpiCard(
                          title: 'Total Views',
                          value: '1,234',
                          icon: Ionicons.eye_outline,
                          color: AppColors.primary,
                        ),
                        KpiCard(
                          title: 'Active Leads',
                          value:
                              '${store.leads.where((l) => l.status == 'New' || l.status == 'In Progress').length}',
                          icon: Ionicons.people_outline,
                          color: AppColors.warning,
                        ),
                        KpiCard(
                          title: 'Products',
                          value: '${store.products.length}',
                          icon: Ionicons.cube_outline,
                          color: AppColors.success,
                        ),
                        const KpiCard(
                          title: 'Conversion Rate',
                          value: '12.5%',
                          icon: Ionicons.trending_up_outline,
                          color: AppColors.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _QuickActionCard(
                          title: 'Add Product',
                          subtitle: 'Create a new product listing',
                          icon: Ionicons.add_circle_outline,
                          color: AppColors.primary,
                          onTap: () {
                            // TODO: Navigate to add product
                          },
                        ),
                        _QuickActionCard(
                          title: 'View Leads',
                          subtitle: 'Check incoming B2B inquiries',
                          icon: Ionicons.people_outline,
                          color: AppColors.warning,
                          onTap: () {
                            // TODO: Navigate to leads
                          },
                        ),
                        _QuickActionCard(
                          title: 'Analytics',
                          subtitle: 'View detailed performance metrics',
                          icon: Ionicons.analytics_outline,
                          color: AppColors.success,
                          onTap: () {
                            // TODO: Navigate to analytics
                          },
                        ),
                        _QuickActionCard(
                          title: 'Settings',
                          subtitle: 'Manage profile and preferences',
                          icon: Ionicons.settings_outline,
                          color: AppColors.textSecondary,
                          onTap: () {
                            // TODO: Navigate to settings
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Ads Manager
                    const Text(
                      'Ads',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AdsManager(),
                    const SizedBox(height: 32),

                    // Recent Activity
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: AppElevation.level1,
                      shadowColor: AppColors.shadowSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.outlineSoft),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _ActivityItem(
                              icon: Ionicons.people_outline,
                              title: 'New lead received',
                              subtitle:
                                  'Bulk Cable Order for Construction Project',
                              time: '2 hours ago',
                              color: AppColors.warning,
                            ),
                            Divider(),
                            _ActivityItem(
                              icon: Ionicons.cube_outline,
                              title: 'Product updated',
                              subtitle: 'Copper Cable 1.5sqmm - Price updated',
                              time: '4 hours ago',
                              color: AppColors.success,
                            ),
                            Divider(),
                            _ActivityItem(
                              icon: Ionicons.eye_outline,
                              title: 'Profile viewed',
                              subtitle:
                                  'Your profile was viewed 15 times today',
                              time: '6 hours ago',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdsManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SellerStore>();
    final ads = store.ads;
    return Card(
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create up to 3 campaigns',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (final ad in ads) _AdCard(ad: ad),
            if (ads.length < 3)
              _NewAdCard(onCreate: (ad) => store.upsertAd(ad)),
          ]),
        ]),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final AdCampaign ad;
  const _AdCard({required this.ad});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: 320,
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
                  : 'Category campaign',
              style: t.titleSmall),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<SellerStore>().deleteAd(ad.id),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Target: ${ad.term}'),
        const SizedBox(height: 6),
        Text('Requested slot: #${ad.slot} (Top 5, first-come-first-serve)',
            style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent),
            label: const Text('Request priority with admin'),
          ),
        ),
      ]),
    );
  }
}

class _NewAdCard extends StatefulWidget {
  final ValueChanged<AdCampaign> onCreate;
  const _NewAdCard({required this.onCreate});
  @override
  State<_NewAdCard> createState() => _NewAdCardState();
}

class _NewAdCardState extends State<_NewAdCard> {
  AdType _type = AdType.search;
  final _termCtrl = TextEditingController();
  int _slot = 1;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: 320,
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
          Text('New campaign', style: t.titleSmall),
        ]),
        const SizedBox(height: 8),
        DropdownButtonFormField<AdType>(
          value: _type,
          onChanged: (v) => setState(() => _type = v ?? AdType.search),
          items: const [
            DropdownMenuItem(
                value: AdType.search, child: Text('Search keyword')),
            DropdownMenuItem(
                value: AdType.category, child: Text('Category name')),
          ],
          decoration: const InputDecoration(prefixIcon: Icon(Icons.campaign)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _termCtrl,
          decoration: InputDecoration(
            hintText: _type == AdType.search
                ? 'e.g., copper'
                : 'e.g., Cables & Wires',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Slot #'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _slot,
            items: [1, 2, 3, 4, 5]
                .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                .toList(),
            onChanged: (v) => setState(() => _slot = v ?? 1),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              widget.onCreate(AdCampaign(
                  id: id,
                  type: _type,
                  term: _termCtrl.text.trim(),
                  slot: _slot));
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          )
        ]),
      ]),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
