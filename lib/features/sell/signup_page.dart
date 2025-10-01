import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';

class SellerSignupPage extends StatefulWidget {
  const SellerSignupPage({super.key});

  @override
  State<SellerSignupPage> createState() => _SellerSignupPageState();
}

class _SellerSignupPageState extends State<SellerSignupPage> {
  int _step = 0; // 0=qualify, 1=plan, 2=payment, 3=business, 4=kyc, 5=pending

  // Step 1: plan
  String _plan = 'Plus';

  // Step 2: payment (Razorpay) - no additional state needed

  // Step 3: business details
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

  double get _progress => (_step / 5).clamp(0, 1).toDouble();

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
        return _paymentStep(context);
      case 3:
        return _businessStep(context);
      case 4:
        return _kycStep(context);
      case 5:
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
    return Consumer(builder: (context, ref, _) {
      final adminStore = ref.watch(adminStoreProvider);
      final plans = adminStore.planCards; // source of truth
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Choose a plan', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, bc) {
          final isPhone = bc.maxWidth < AppBreaks.tablet;
          final cards = plans
              .map((c) => _planCard(
                  c.title,
                  c.features.join(' • '),
                  c.periodLabel.isNotEmpty
                      ? '${c.priceLabel}/${c.periodLabel}'
                      : c.priceLabel))
              .toList();
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
              onPressed: () => setState(() => _step = 2), // Go to payment step
              child: const Text('Next')),
        )
      ]);
    });
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

  Widget _paymentStep(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final session = ref.watch(sessionControllerProvider);
      final razorpayService = ref.read(razorpayServiceProvider);

      return FutureBuilder(
        future: () async {
          razorpayService.initialize();
          final selectedPlan = _plan == 'Plus' ? SubscriptionPlan.plus : SubscriptionPlan.pro;
          return razorpayService.createSubscriptionOrder(
            userId: session.userId ?? 'guest',
            userName: session.displayName ?? session.email ?? 'Guest',
            userEmail: session.email ?? 'guest@vidyut.com',
            plan: selectedPlan,
          );
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Error: ${snapshot.error ?? "Failed to load pricing"}'),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Back to Plans'),
                ),
              ],
            );
          }

          final orderDetails = snapshot.data!;
          final pricing = orderDetails['plan'] as Map<String, dynamic>;
          final amount = orderDetails['amount'] as int;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Card(
                elevation: AppElevation.level1,
                shadowColor: AppColors.shadowSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.outlineSoft),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plan: $_plan',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '₹${amount ~/ 100}/year',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Features included:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...(pricing['features'] as List).map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(feature.toString())),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _step = 1),
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (session.userId == null || session.email == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to continue.')),
                        );
                        return;
                      }

                      try {
                        await razorpayService.openCheckout(
                          orderId: orderDetails['order_id'],
                          amount: amount,
                          currency: orderDetails['currency'],
                          userName: session.displayName ?? session.email!,
                          userEmail: session.email!,
                          userPhone: '', // Optional
                          planName: pricing['name'],
                          onSuccess: (result) async {
                            final selectedPlan = _plan == 'Plus' ? SubscriptionPlan.plus : SubscriptionPlan.pro;
                            
                            // Activate subscription
                            await razorpayService.activateSubscription(
                              userId: session.userId!,
                              orderId: result.orderId!,
                              plan: selectedPlan,
                            );
                            
                            // Update local store
                            final sellerStore = ref.read(sellerStoreProvider);
                            sellerStore.updateSubscriptionPlan(_plan.toLowerCase());
                            
                            if (!mounted) return;
                            setState(() => _step = 3); // Go to business details
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment successful! Complete business details.')),
                            );
                          },
                          onFailure: (result) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment failed: ${result.error}')),
                            );
                          },
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Pay Now'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
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
            onPressed: () => setState(() => _step = 2), // Go back to payment
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
              setState(() => _step = 4); // Go to KYC
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
            onPressed: () => setState(() => _step = 3), // Go back to business details
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
              // Demo: auto-approve via EnhancedAdminStore and update seller store plan
              final container = ProviderScope.containerOf(context);
              final enhancedAdmin = container.read(enhancedAdminStoreProvider);
              final sellerStore = container.read(sellerStoreProvider);
              // Set chosen plan on seller store (lowercase code)
              final planCode = _plan.toLowerCase();
              sellerStore.updateSubscriptionPlan(planCode);
              // Auto-approve first pending seller in demo (safe fallback)
              final pending = enhancedAdmin.sellers.firstWhere(
                  (u) => u.status == UserStatus.pending,
                  orElse: () => enhancedAdmin.sellers.isNotEmpty
                      ? enhancedAdmin.sellers.first
                      : (throw Exception('No sellers present in demo data')));
              enhancedAdmin.approveSeller(pending.id,
                  comments: 'Auto-approved from signup flow');
              setState(() => _step = 5); // Go to pending approval
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
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
