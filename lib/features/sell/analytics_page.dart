import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import 'widgets/kpi_card.dart';
import 'store/seller_store.dart';
import 'models.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sellerStoreProvider);
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
                const Icon(
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
                    value: store.totalProductContacts +
                                store.totalSellerContacts ==
                            0
                        ? '0'
                        : (store.totalProductContacts +
                                store.totalSellerContacts)
                            .toString(),
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
                  _KpiItem(
                    label: 'Total Clicks',
                    value: store.totalProductClicks.toString(),
                    icon: Icons.mouse_outlined,
                  ),
                  _KpiItem(
                    label: 'Total Contacts',
                    value: store.totalProductContacts.toString(),
                    icon: Icons.phone_in_talk_outlined,
                  ),
                  _KpiItem(
                    label: 'Marketplace Interactions',
                    value: store.totalMarketplaceInteractions.toString(),
                    icon: Icons.analytics_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Performance Metrics
              Text('Performance Metrics', style: t.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.insights_outlined),
                        const SizedBox(width: 8),
                        Text('Conversion Rates', style: t.titleMedium),
                      ]),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Profile → Contact',
                        value: (store.profileToContactRate * 100)
                                .toStringAsFixed(1) +
                            '%',
                      ),
                      _MetricRow(
                        label: 'Product View → Contact',
                        value: (store.productViewToContactRate * 100)
                                .toStringAsFixed(1) +
                            '%',
                      ),
                      _MetricRow(
                        label: 'Overall CTR',
                        value:
                            '${(store.overallClickThroughRate * 100).toStringAsFixed(1)}%',
                      ),
                      _MetricRow(
                        label: 'Overall Contact Rate',
                        value:
                            '${(store.overallContactRate * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Product Performance Section
              Text('Product Performance', style: t.titleLarge),
              const SizedBox(height: 8),
              _ProductPerformanceTabs(),
              const SizedBox(height: 16),
              // Product Performance Reports (CSV)
              Text('Product Performance Reports', style: t.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Icon(Icons.assessment_outlined),
                    const SizedBox(width: 8),
                    const Text('Export product performance data'),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _downloadProductPerformanceReport(context, store),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Download CSV'),
                    ),
                  ]),
                ),
              ),
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
  const _KpiItem(
      {required this.label, required this.value, required this.icon});
}

class _ProductPerformanceTabs extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProductPerformanceTabs> createState() =>
      _ProductPerformanceTabsState();
}

class _ProductPerformanceTabsState
    extends ConsumerState<_ProductPerformanceTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Top Views', icon: Icon(Icons.visibility)),
              Tab(text: 'Top Clicks', icon: Icon(Icons.mouse)),
              Tab(text: 'Top Contacts', icon: Icon(Icons.phone_in_talk)),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProductList(
                  products: ref.watch(sellerStoreProvider).topViewedProducts,
                  metricType: 'views',
                ),
                _ProductList(
                  products: ref.watch(sellerStoreProvider).topClickedProducts,
                  metricType: 'clicks',
                ),
                _ProductList(
                  products: ref.watch(sellerStoreProvider).topContactedProducts,
                  metricType: 'contacts',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  final List<Product> products;
  final String metricType;

  const _ProductList({
    required this.products,
    required this.metricType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sellerStoreProvider);

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No data available.')),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final views = store.productViewsOf(product.id);
        final clicks = store.productClicksOf(product.id);
        final calls = store.productContactCallsOf(product.id);
        final wa = store.productContactWhatsappsOf(product.id);
        final ctr = store.getProductClickThroughRate(product.id);
        final contactRate = store.getProductContactRate(product.id);
        final lastViewed = store.productLastViewedOf(product.id);

        String subtitle;
        IconData icon;
        Color color;

        switch (metricType) {
          case 'views':
            subtitle =
                'Views: $views • CTR: ${(ctr * 100).toStringAsFixed(1)}%';
            icon = Icons.visibility;
            color = Colors.blue;
            break;
          case 'clicks':
            subtitle =
                'Clicks: $clicks • Views: $views • CTR: ${(ctr * 100).toStringAsFixed(1)}%';
            icon = Icons.mouse;
            color = Colors.green;
            break;
          case 'contacts':
            subtitle =
                'Contacts: ${calls + wa} • Views: $views • Rate: ${(contactRate * 100).toStringAsFixed(1)}%';
            icon = Icons.phone_in_talk;
            color = Colors.orange;
            break;
          default:
            subtitle = 'Views: $views • Calls: $calls • WhatsApp: $wa';
            icon = Icons.inventory_2_outlined;
            color = Colors.grey;
        }

        return ListTile(
          leading: Icon(icon, color: color),
          title: Text(
              product.title.isEmpty ? 'Product ${product.id}' : product.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle),
              if (lastViewed != null)
                Text(
                  'Last viewed: ${_formatLastViewed(lastViewed)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getMetricValue(product.id, store),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                _getMetricLabel(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMetricValue(String productId, SellerStore store) {
    switch (metricType) {
      case 'views':
        return store.productViewsOf(productId).toString();
      case 'clicks':
        return store.productClicksOf(productId).toString();
      case 'contacts':
        return (store.productContactCallsOf(productId) +
                store.productContactWhatsappsOf(productId))
            .toString();
      default:
        return '0';
    }
  }

  String _getMetricLabel() {
    switch (metricType) {
      case 'views':
        return 'Views';
      case 'clicks':
        return 'Clicks';
      case 'contacts':
        return 'Contacts';
      default:
        return '';
    }
  }

  String _formatLastViewed(DateTime lastViewed) {
    final now = DateTime.now();
    final difference = now.difference(lastViewed);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _EngagementBreakdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sellerStoreProvider);
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
    final barWidth =
        ((value == 0 ? 1 : value).toDouble() / (max == 0 ? 1 : max)) *
            (width - 120);
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

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetricRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: t.bodyMedium)),
        Text(value, style: t.titleSmall),
      ]),
    );
  }
}

// Helper function for CSV download
Future<void> _downloadProductPerformanceReport(
    BuildContext context, SellerStore store) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Generate CSV
    final csv = await store.generateProductPerformanceCsv();

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show success message with CSV preview
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Product Performance Report Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CSV generated successfully (${csv.length} characters)'),
              const SizedBox(height: 16),
              const Text('Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csv,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveAndShareCsv(context, csv);
              },
              child: const Text('Download File'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Close loading dialog if still open
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate performance report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Helper function to save CSV file and share it
Future<void> _saveAndShareCsv(BuildContext context, String csvContent) async {
  try {
    if (kIsWeb) {
      // Web implementation - direct download
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_performance_$timestamp.csv';

      // For web, use a simple text share
      await Share.share(csvContent, subject: fileName);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV file downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Mobile/Desktop implementation - save and share
      final directory = await getTemporaryDirectory();

      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_performance_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV content to file
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Product Performance Report - ${DateTime.now().toString().split(' ')[0]}',
        subject: 'Vidyut Product Performance Report',
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved and ready to share!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    // Show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
