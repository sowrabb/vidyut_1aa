import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../sell/models.dart';
import '../leads/leads_store.dart';
import '../leads/lead_detail_page.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeadsStore(),
      builder: (context, _) {
        final store = context.watch<LeadsStore>();
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: ContentClamp(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ResponsiveRow(children: [
                    TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search leads...'),
                      onChanged: store.setQuery,
                    ),
                    DropdownButtonFormField<String>(
                      value: store.region,
                      items: const [
                        DropdownMenuItem(
                            value: 'All', child: Text('All States')),
                        DropdownMenuItem(
                            value: 'Telangana', child: Text('Telangana')),
                        DropdownMenuItem(
                            value: 'Karnataka', child: Text('Karnataka')),
                        DropdownMenuItem(
                            value: 'Maharashtra', child: Text('Maharashtra')),
                      ],
                      onChanged: (v) => store.setRegion(v ?? 'All'),
                      decoration:
                          const InputDecoration(prefixIcon: Icon(Icons.public)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Chips
                  const Text('Industry'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final s in const [
                      'Construction',
                      'EPC',
                      'MEP',
                      'Solar'
                    ])
                      FilterChip(
                          label: Text(s),
                          selected: store.industries.contains(s),
                          onSelected: (_) => store.toggleIndustry(s)),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Materials Used'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final m in kMaterials)
                      FilterChip(
                          label: Text(m),
                          selected: store.materials.contains(m),
                          onSelected: (_) => store.toggleMaterial(m)),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Turnover (₹ Cr)'),
                  RangeSlider(
                    values: RangeValues(store.minTurnCr, store.maxTurnCr),
                    min: 0,
                    max: 1000,
                    divisions: 50,
                    labels: RangeLabels(store.minTurnCr.toStringAsFixed(0),
                        store.maxTurnCr.toStringAsFixed(0)),
                    onChanged: (v) => store.setTurnover(v.start, v.end),
                  ),
                  const SizedBox(height: 12),

                  // Results - Facebook-style profile cards
                  ResponsiveRow(
                    desktop: 2,
                    tablet: 2,
                    phone: 1,
                    children: store.results
                        .map((l) => _LeadProfileCard(
                            lead: l, onOpen: () => _open(context, l)))
                        .toList(),
                  ),

                  if (store.results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No leads match filters.')),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, Lead l) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LeadDetailPage(lead: l)));
  }
}

class _LeadProfileCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onOpen;

  const _LeadProfileCard({
    required this.lead,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and company name
              Row(
                children: [
                  // Company logo placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.thumbBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lead.industry} • ${lead.city}, ${lead.state}',
                          style: t.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Company stats
              Row(
                children: [
                  _StatChip(
                    icon: Icons.trending_up,
                    label: '₹${lead.turnoverCr.toStringAsFixed(0)} Cr',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.schedule,
                    label:
                        'Need by ${lead.needBy.toLocal().toString().split(' ').first}',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Materials used
              if (lead.materials.isNotEmpty) ...[
                Text(
                  'Materials Used',
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: lead.materials
                      .take(3)
                      .map((m) => Chip(
                            label: Text(m),
                            backgroundColor: AppColors.primarySurface,
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ))
                      .toList(),
                ),
                if (lead.materials.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${lead.materials.length - 3} more',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Quote'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
