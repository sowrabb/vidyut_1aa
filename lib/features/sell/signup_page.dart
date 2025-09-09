import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';

class SellerSignupPage extends StatefulWidget {
  const SellerSignupPage({super.key});

  @override
  State<SellerSignupPage> createState() => _SellerSignupPageState();
}

class _SellerSignupPageState extends State<SellerSignupPage> {
  int _step = 0; // 0=qualify, 1=plan, 2=business, 3=kyc, 4=pending

  // Step 1: plan
  String _plan = 'Plus';

  // Step 2: business details
  final _ownerCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _tradeLicenseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Step 3: KYC
  final _panCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final List<MapEntry<String, String>> _companyDocs = [];

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _companyCtrl.dispose();
    _gstCtrl.dispose();
    _tradeLicenseCtrl.dispose();
    _notesCtrl.dispose();
    _panCtrl.dispose();
    _aadhaarCtrl.dispose();
    super.dispose();
  }

  double get _progress => (_step / 4).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Signup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: _progress),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStep(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _qualifyStep(context);
      case 1:
        return _planStep(context);
      case 2:
        return _businessStep(context);
      case 3:
        return _kycStep(context);
      case 4:
        return _pendingStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _qualifyStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Are you a seller?',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Wrap(spacing: 12, children: [
        FilledButton.icon(
          onPressed: () => setState(() => _step = 1),
          icon: const Icon(Ionicons.checkmark_circle_outline),
          label: const Text('Yes'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showNotSellerInfo(context),
          icon: const Icon(Ionicons.close_circle_outline),
          label: const Text('No'),
        ),
      ]),
    ]);
  }

  Widget _planStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Choose a plan', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, bc) {
        final isPhone = bc.maxWidth < AppBreaks.tablet;
        final cards = [
          _planCard('Plus', 'Essential features for SMBs', '₹499/mo'),
          _planCard('Pro', 'Advanced tools and analytics', '₹999/mo'),
        ];
        return isPhone
            ? Column(
                children: cards
                    .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 12), child: w))
                    .toList())
            : Row(
                children: cards
                    .map((w) => Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: w)))
                    .toList());
      }),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text('Next')),
      )
    ]);
  }

  Widget _planCard(String name, String desc, String price) {
    final bool selected = _plan == name;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: () => setState(() => _plan = name),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ]),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _businessStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Business details',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      TextField(
          controller: _ownerCtrl,
          decoration: const InputDecoration(
              labelText: 'Owner Name *', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(
          controller: _companyCtrl,
          decoration: const InputDecoration(
              labelText: 'Company Name *', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(
          controller: _gstCtrl,
          decoration: const InputDecoration(
              labelText: 'GST (optional)', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(
          controller: _tradeLicenseCtrl,
          decoration: const InputDecoration(
              labelText: 'Trade License (optional)',
              border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(
          controller: _notesCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Anything to help us approve faster',
              border: OutlineInputBorder())),
      const SizedBox(height: 16),
      Row(children: [
        OutlinedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Back')),
        const Spacer(),
        FilledButton(
            onPressed: () {
              if (_ownerCtrl.text.trim().isEmpty ||
                  _companyCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Owner and Company are required')));
                return;
              }
              setState(() => _step = 3);
            },
            child: const Text('Next')),
      ])
    ]);
  }

  Widget _kycStep(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('KYC information', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      _uploadField('PAN Card (mandatory)', _panCtrl),
      const SizedBox(height: 10),
      _uploadField('Aadhaar Card (mandatory)', _aadhaarCtrl),
      const SizedBox(height: 16),
      Text('Company Documents (optional)',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ..._companyDocs
          .asMap()
          .entries
          .map((e) => _companyDocRow(e.key, e.value)),
      OutlinedButton.icon(
        onPressed: () =>
            setState(() => _companyDocs.add(const MapEntry('', ''))),
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
      ),
      const SizedBox(height: 16),
      Row(children: [
        OutlinedButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text('Back')),
        const Spacer(),
        FilledButton(
            onPressed: () {
              if (_panCtrl.text.trim().isEmpty ||
                  _aadhaarCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('PAN and Aadhaar are required')));
                return;
              }
              setState(() => _step = 4);
            },
            child: const Text('Upload & Submit')),
      ])
    ]);
  }

  Widget _uploadField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Paste file URL or reference (demo)',
        border: const OutlineInputBorder(),
        suffixIcon:
            IconButton(onPressed: () {}, icon: const Icon(Icons.upload_file)),
      ),
    );
  }

  Widget _companyDocRow(int i, MapEntry<String, String> kv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: kv.key),
            decoration: const InputDecoration(
                labelText: 'Title (e.g., GST)', border: OutlineInputBorder()),
            onChanged: (v) => setState(
                () => _companyDocs[i] = MapEntry(v, _companyDocs[i].value)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: kv.value),
            decoration: const InputDecoration(
                labelText: 'File URL / Note', border: OutlineInputBorder()),
            onChanged: (v) => setState(
                () => _companyDocs[i] = MapEntry(_companyDocs[i].key, v)),
          ),
        ),
        IconButton(
            onPressed: () => setState(() => _companyDocs.removeAt(i)),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error),
      ]),
    );
  }

  Widget _pendingStep(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.yellow.shade50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.outlineSoft)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.access_time, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Waiting for admin approval',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
                'Your signup is under review. We will notify you once approved.',
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  void _showNotSellerInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: const Text(
            'This flow is for sellers. You can continue browsing the marketplace.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }
}
