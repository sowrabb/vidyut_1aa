import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../sell/models.dart';

class LeadDetailPage extends StatelessWidget {
  final Lead lead;
  const LeadDetailPage({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final double logoSize = 112;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(lead.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SafeArea(
        child: ContentClamp(
          child: NestedScrollView(
            headerSliverBuilder: (c, inner) => [
              SliverToBoxAdapter(child: _masthead(context, t, logoSize)),
            ],
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _aboutSection(context),
                const SizedBox(height: 16),
                _requirementsSection(context),
                const SizedBox(height: 16),
                _contactSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _masthead(BuildContext context, TextTheme t, double logoSize) {
    final isPhone = context.isPhone;

    // Contact meta information
    final contactMeta = [
      _Meta('${lead.city}, ${lead.state}'),
      _Meta('Industry: ${lead.industry}'),
      _MetaIcon(Icons.schedule,
          'Need by ${lead.needBy.toLocal().toString().split(' ').first}'),
    ];

    // Company stats
    final statsMeta = [
      _Badge('₹${lead.turnoverCr.toStringAsFixed(0)} Cr'),
      _Meta('${lead.materials.length} Materials'),
      _Meta('Active Lead'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: !isPhone
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left cluster (desktop): logo left, details right
                Expanded(
                  child: Row(children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: AppColors.thumbBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.business,
                          color: AppColors.textSecondary, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead.title, style: t.headlineSmall),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: contactMeta),
                          const SizedBox(height: 6),
                          Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                // Right: desktop CTAs
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Send Quote'),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: AppColors.thumbBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.business,
                      color: AppColors.textSecondary, size: 36),
                ),
                const SizedBox(height: 12),
                Text(lead.title, style: t.headlineSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 12, runSpacing: 6, children: contactMeta),
                const SizedBox(height: 6),
                Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                const SizedBox(height: 10),
                // Mobile CTAs under details
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Send Quote'),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _aboutSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About This Lead', style: t.titleLarge),
            const SizedBox(height: 8),
            Text(
              lead.about.isEmpty
                  ? 'No additional information provided.'
                  : lead.about,
              style: t.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _requirementsSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requirements', style: t.titleLarge),
            const SizedBox(height: 12),
            _RequirementItem(
              icon: Icons.trending_up,
              label: 'Annual Turnover',
              value: '₹${lead.turnoverCr.toStringAsFixed(0)} Cr',
            ),
            const SizedBox(height: 8),
            _RequirementItem(
              icon: Icons.inventory,
              label: 'Quantity Required',
              value: '${lead.qty} units',
            ),
            const SizedBox(height: 8),
            _RequirementItem(
              icon: Icons.schedule,
              label: 'Need By',
              value: lead.needBy.toLocal().toString().split(' ').first,
            ),
            const SizedBox(height: 12),
            Text('Materials Used', style: t.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lead.materials
                  .map((m) => Chip(
                        label: Text(m),
                        backgroundColor: AppColors.primarySurface,
                        labelStyle: TextStyle(color: AppColors.primary),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: t.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Send Quote'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);
}

class _MetaIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaIcon(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 14), const SizedBox(width: 4), _Meta(text)]);
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class _RequirementItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RequirementItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
