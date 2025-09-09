import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import 'store/seller_store.dart';

class AdsCreatePage extends StatefulWidget {
  const AdsCreatePage({super.key});
  @override
  State<AdsCreatePage> createState() => _AdsCreatePageState();
}

class _AdsCreatePageState extends State<AdsCreatePage> {
  AdType _type = AdType.search;
  final _termCtrl = TextEditingController();
  String _previewRank = '';

  void _recomputePreview() {
    final store = context.read<SellerStore>();
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
    final store = context.watch<SellerStore>();
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: const [
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
                        context.read<SellerStore>().upsertAd(AdCampaign(
                            id: id,
                            type: _type,
                            term: _termCtrl.text.trim(),
                            slot: slot));
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
