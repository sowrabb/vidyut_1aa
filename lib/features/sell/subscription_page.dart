import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../../features/admin/store/admin_store.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
import 'store/seller_store.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Plans',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the plan that best fits your business needs',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Current Plan Status
                Consumer<SellerStore>(builder: (context, sellerStore, _) {
                  return Card(
                    elevation: AppElevation.level1,
                    shadowColor: AppColors.shadowSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outlineSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                sellerStore.getSubscriptionStatus(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Current Usage:'),
                          const SizedBox(height: 8),
                          ...sellerStore.getSubscriptionLimits().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('• ${entry.key}: '),
                                  Text(
                                    entry.value.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Plans Grid
                Consumer<AdminStore>(builder: (context, store, _) {
                  final cards = store.planCards;
                  return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: context.isDesktop ? 3 : 1,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: context.isDesktop ? 0.9 : 1.4,
                  children: cards.map((c) => _PlanCard(
                    title: c.title,
                    price: c.priceLabel,
                    period: c.periodLabel,
                    features: c.features,
                    isPopular: c.isPopular,
                    onChoose: () => _showUpgradeDialog(context, c.title),
                  )).toList(),
                );
                }),

                const SizedBox(height: 48),

                // FAQ Section
                Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

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
                        _FAQItem(
                          question: 'Can I change my plan anytime?',
                          answer:
                              'Yes, you can upgrade or downgrade your plan at any time. Changes will be prorated based on your current billing cycle.',
                        ),
                        Divider(),
                        _FAQItem(
                          question:
                              'What happens if I exceed my product limit?',
                          answer:
                              'You\'ll receive a notification when you\'re close to your limit. To add more products, simply upgrade your plan.',
                        ),
                        Divider(),
                        _FAQItem(
                          question: 'Is there a setup fee?',
                          answer:
                              'No, there are no setup fees. You only pay for the plan you choose.',
                        ),
                        Divider(),
                        _FAQItem(
                          question: 'Do you offer refunds?',
                          answer:
                              'We offer a 30-day money-back guarantee. If you\'re not satisfied, contact our support team.',
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
  }

  void _showUpgradeDialog(BuildContext context, String plan) {
    final sellerStore = context.read<SellerStore>();
    final planKey = plan.toLowerCase();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to $plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Payment integration will be implemented in the next phase. For now, this is a demo of the subscription flow.'),
            const SizedBox(height: 16),
            Text(
              'New Limits:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('• Products: ${_getProductLimit(planKey)}'),
            Text('• Ads: ${_getAdLimit(planKey)}'),
            Text('• Analytics: ${planKey == 'free' ? 'Disabled' : 'Enabled'}'),
            if (planKey == 'pro') const Text('• Advanced Features: Enabled'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              sellerStore.updateSubscriptionPlan(planKey);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully upgraded to $plan plan!')),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  String _getProductLimit(String plan) {
    switch (plan) {
      case 'free': return '5 products';
      case 'plus': return '25 products';
      case 'pro': return '100 products';
      default: return '5 products';
    }
  }

  String _getAdLimit(String plan) {
    switch (plan) {
      case 'free': return '1 ad';
      case 'plus': return '5 ads';
      case 'pro': return '20 ads';
      default: return '1 ad';
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onChoose;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppElevation.level2,
      shadowColor: AppColors.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPopular ? AppColors.primary : AppColors.outlineSoft,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: isPopular ? 40 : 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                      ),
                      const SizedBox(width: 4),
                      if (period.isNotEmpty)
                        Text(
                          period,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Ionicons.checkmark_circle,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onChoose,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isPopular ? 'Choose Plus' : 'Choose $title',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
