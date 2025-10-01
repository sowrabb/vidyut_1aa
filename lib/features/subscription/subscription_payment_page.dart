/// Subscription payment page
/// Flow: Select Plan → Pay → Business Details
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/provider_registry.dart';
import '../../state/payments/razorpay_providers.dart';
import '../../services/razorpay_service.dart';
import '../auth/models/user_role_models.dart';
import '../sell/business_details_page.dart';

class SubscriptionPaymentPage extends ConsumerStatefulWidget {
  final bool isUpgrade;
  final SubscriptionPlan? currentPlan;

  const SubscriptionPaymentPage({
    super.key,
    this.isUpgrade = false,
    this.currentPlan,
  });

  @override
  ConsumerState<SubscriptionPaymentPage> createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState
    extends ConsumerState<SubscriptionPaymentPage> {
  SubscriptionPlan? _selectedPlan;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final allPlansAsync = ref.watch(allSubscriptionPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpgrade ? 'Upgrade Subscription' : 'Choose Your Plan'),
      ),
      body: allPlansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading plans: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allSubscriptionPlansProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (plans) {
          // Filter out free plan and current plan for upgrades
          final availablePlans = plans.entries.where((entry) {
            if (entry.key == SubscriptionPlan.free) return false;
            if (widget.isUpgrade && entry.key == widget.currentPlan) return false;
            if (widget.isUpgrade && 
                widget.currentPlan != null && 
                _isPlanDowngrade(widget.currentPlan!, entry.key)) return false;
            return true;
          }).toList();

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (widget.isUpgrade) ...[
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Current Plan: ${widget.currentPlan?.displayName ?? "Free"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        widget.isUpgrade ? 'Available Upgrades' : 'Select a Plan',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...availablePlans.map((entry) {
                        final plan = entry.key;
                        final pricing = entry.value;
                        final isSelected = _selectedPlan == plan;

                        return _PlanCard(
                          plan: plan,
                          pricing: pricing,
                          isSelected: isSelected,
                          onSelect: () => setState(() => _selectedPlan = plan),
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _selectedPlan == null || _isProcessing
                            ? null
                            : () => _proceedToPayment(plans[_selectedPlan]!),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _selectedPlan == null
                                    ? 'Select a plan to continue'
                                    : 'Proceed to Payment',
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isPlanDowngrade(SubscriptionPlan current, SubscriptionPlan target) {
    final hierarchy = [
      SubscriptionPlan.free,
      SubscriptionPlan.plus,
      SubscriptionPlan.pro,
      SubscriptionPlan.enterprise,
    ];
    
    final currentIndex = hierarchy.indexOf(current);
    final targetIndex = hierarchy.indexOf(target);
    
    return targetIndex < currentIndex;
  }

  Future<void> _proceedToPayment(Map<String, dynamic> pricing) async {
    if (_selectedPlan == null) return;

    setState(() => _isProcessing = true);

    try {
      final session = ref.read(sessionControllerProvider);
      final razorpay = ref.read(razorpayServiceProvider);

      if (session.userId == null) {
        throw Exception('Please sign in to continue');
      }

      // Create order
      final orderData = await razorpay.createSubscriptionOrder(
        userId: session.userId!,
        userName: session.displayName ?? 'User',
        userEmail: session.email ?? '',
        plan: _selectedPlan!,
      );

      if (!mounted) return;

      // Open Razorpay checkout
      await razorpay.openCheckout(
        orderId: orderData['order_id'] as String,
        amount: orderData['amount'] as int,
        currency: orderData['currency'] as String,
        userName: session.displayName ?? 'User',
        userEmail: session.email ?? '',
        userPhone: session.profile?.phone ?? '',
        planName: pricing['name'] as String,
        onSuccess: (result) async {
          if (!mounted) return;

          // Activate subscription
          if (widget.isUpgrade && widget.currentPlan != null) {
            await razorpay.upgradeSubscription(
              userId: session.userId!,
              orderId: result.orderId!,
              fromPlan: widget.currentPlan!,
              toPlan: _selectedPlan!,
            );
          } else {
            await razorpay.activateSubscription(
              userId: session.userId!,
              orderId: result.orderId!,
              plan: _selectedPlan!,
            );
          }

          if (!mounted) return;

          // Show success and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isUpgrade
                    ? 'Plan upgraded successfully!'
                    : 'Payment successful!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to business details page for new subscriptions
          if (!widget.isUpgrade) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const BusinessDetailsPage(),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        onFailure: (result) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );

          setState(() => _isProcessing = false);
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isProcessing = false);
    }
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final Map<String, dynamic> pricing;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.pricing,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final price = pricing['price'] as int;
    final displayPrice = price > 0 ? '₹${(price / 100).toStringAsFixed(0)}' : 'Free';
    final duration = pricing['duration'] as String;
    final features = pricing['features'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pricing['name'] as String,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$displayPrice${duration != 'forever' ? '/$duration' : ''}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    onChanged: (_) => onSelect(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              ...features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}




