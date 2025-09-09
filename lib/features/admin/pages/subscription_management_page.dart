import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/admin_store.dart';
import '../models/subscription_models.dart' as sub;

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> with TickerProviderStateMixin {
  late TabController _controller;
  final List<Tab> _tabs = const [
    Tab(text: 'Plan Cards'),
    Tab(text: 'Plans'),
    Tab(text: 'Prices'),
    Tab(text: 'Points & Usage'),
    Tab(text: 'Add-ons'),
    Tab(text: 'Promotions'),
    Tab(text: 'Subscriptions'),
    Tab(text: 'Billing & Taxes'),
    Tab(text: 'Reports'),
    Tab(text: 'Settings'),
    Tab(text: 'Audit & Approvals'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _PlanCardsTab(),
          _PlansTab(),
          _placeholder('Prices: Regional pricing, intervals, proration, effective windows'),
          _placeholder('Points & Usage: allocations, rollover, overage, usage charts'),
          _placeholder('Add-ons: point packs, feature unlocks, attach rules'),
          _placeholder('Promotions: coupons, intro pricing, bundles, eligibility'),
          _placeholder('Subscriptions: search, lifecycle actions, invoices, adjustments'),
          _placeholder('Billing & Taxes: tax regions, GST/VAT, provider settings'),
          _placeholder('Reports: MRR/ARR, churn, cohorts, plan performance'),
          _placeholder('Settings: trials, grace, cancellation, emails, guardrails'),
          _placeholder('Audit & Approvals: drafts, approvals, change history'),
        ],
      ),
    );
  }

  Widget _placeholder(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _PlanCardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(builder: (context, store, _) {
      final cards = store.planCards;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              FilledButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Card'),
              ),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: cards.isEmpty
                  ? const Center(child: Text('No cards'))
                  : ListView.separated(
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final c = cards[i];
                        return Card(
                          child: ListTile(
                            title: Text('${c.title} • ${c.priceLabel} ${c.periodLabel.isNotEmpty ? '(${c.periodLabel})' : ''}'),
                            subtitle: Text(c.features.join(' • '), maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              if (c.isPopular) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.star, color: Colors.amber)),
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditor(context, existing: c)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => store.deletePlanCard(c.id)),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _openEditor(BuildContext context, {sub.PlanCardConfig? existing}) {
    showDialog(context: context, builder: (_) => _PlanCardEditor(existing: existing));
  }
}

class _PlanCardEditor extends StatefulWidget {
  final sub.PlanCardConfig? existing;
  const _PlanCardEditor({this.existing});

  @override
  State<_PlanCardEditor> createState() => _PlanCardEditorState();
}

class _PlanCardEditorState extends State<_PlanCardEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _price;
  late TextEditingController _period;
  late TextEditingController _features;
  bool popular = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _price = TextEditingController(text: e?.priceLabel ?? '');
    _period = TextEditingController(text: e?.periodLabel ?? '');
    _features = TextEditingController(text: e?.features.join(', ') ?? '');
    popular = e?.isPopular ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _period.dispose();
    _features.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(widget.existing == null ? 'Add Plan Card' : 'Edit Plan Card'),
              automaticallyImplyLeading: false,
              actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()), validator: (v)=> (v==null||v.trim().isEmpty)?'Required':null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Price label (e.g., ₹1,000)', border: OutlineInputBorder()), validator: (v)=> (v==null||v.trim().isEmpty)?'Required':null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _period, decoration: const InputDecoration(labelText: 'Period label (optional, e.g., per year)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _features, decoration: const InputDecoration(labelText: 'Features (comma-separated)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    SwitchListTile(value: popular, onChanged: (v)=>setState(()=>popular=v), title: const Text('Mark as Most Popular')),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      FilledButton(onPressed: () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        final store = context.read<AdminStore>();
                        final features = _features.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList();
                        if (widget.existing == null) {
                          final card = sub.PlanCardConfig(
                            id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                            title: _title.text.trim(),
                            priceLabel: _price.text.trim(),
                            periodLabel: _period.text.trim(),
                            features: features,
                            isPopular: popular,
                          );
                          await store.addPlanCard(card);
                        } else {
                          final updated = widget.existing!.copyWith(
                            title: _title.text.trim(),
                            priceLabel: _price.text.trim(),
                            periodLabel: _period.text.trim(),
                            features: features,
                            isPopular: popular,
                          );
                          await store.updatePlanCard(updated);
                        }
                        if (context.mounted) Navigator.pop(context);
                      }, child: Text(widget.existing==null?'Add':'Save')),
                    ])
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PlansTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(builder: (context, store, _) {
      final plans = store.plans;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _openPlanEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Plan'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: plans.isEmpty ? null : () {},
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Matrix (CSV)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: plans.isEmpty
                  ? const Center(child: Text('No plans yet'))
                  : ListView.separated(
                      itemCount: plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = plans[index];
                        return Card(
                          child: ListTile(
                            title: Text('${p.name} • ${p.code}'),
                            subtitle: Text('Status: ${p.status.name} • Version: ${p.version} • Default points: ${p.defaultPointsPerCycle}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openPlanEditor(context, existing: p),
                                ),
                                IconButton(
                                  tooltip: p.status == sub.PlanStatus.archived ? 'Archived' : 'Archive',
                                  onPressed: p.status == sub.PlanStatus.archived ? null : () => store.archivePlan(p.id),
                                  icon: const Icon(Icons.archive_outlined),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _openPlanEditor(BuildContext context, {sub.Plan? existing}) {
    showDialog(
      context: context,
      builder: (_) => _PlanEditor(existing: existing),
    );
  }
}

class _PlanEditor extends StatefulWidget {
  final sub.Plan? existing;
  const _PlanEditor({this.existing});

  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _code;
  late TextEditingController _desc;
  late TextEditingController _points;
  bool visible = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _code = TextEditingController(text: e?.code ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _points = TextEditingController(text: e?.defaultPointsPerCycle.toString() ?? '0');
    visible = e?.visiblePublicly ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _desc.dispose();
    _points.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(widget.existing == null ? 'Create Plan' : 'Edit Plan'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _code,
                      decoration: const InputDecoration(labelText: 'Code/Slug', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _desc,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _points,
                      decoration: const InputDecoration(labelText: 'Default points per cycle', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 0) return 'Enter a valid non-negative number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: visible,
                      onChanged: (v) => setState(() => visible = v),
                      title: const Text('Visible publicly'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            final store = context.read<AdminStore>();
                            if (widget.existing == null) {
                              final plan = sub.Plan(
                                id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                                name: _name.text.trim(),
                                code: _code.text.trim(),
                                description: _desc.text.trim(),
                                defaultPointsPerCycle: int.parse(_points.text.trim()),
                                visiblePublicly: visible,
                                status: sub.PlanStatus.draft,
                              );
                              await store.createPlan(plan);
                            } else {
                              final upd = widget.existing!.copyWith(
                                name: _name.text.trim(),
                                code: _code.text.trim(),
                                description: _desc.text.trim(),
                                defaultPointsPerCycle: int.parse(_points.text.trim()),
                                visiblePublicly: visible,
                              );
                              await store.updatePlan(upd);
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(widget.existing == null ? 'Create' : 'Save'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


