// Cloud Functions Usage Examples
// This file demonstrates how to use the Cloud Functions service in your Flutter app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/provider_registry.dart';

/// Example widget showing how to use Cloud Functions providers
class CloudFunctionsUsageExample extends ConsumerWidget {
  const CloudFunctionsUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Analytics Example
            _buildSection(
              title: 'Product Analytics',
              children: [
                _buildExample(
                  title: 'Update Product Analytics',
                  description: 'Track product views, inquiries, and favorites',
                  onTap: () => _updateProductAnalytics(ref),
                ),
                _buildExample(
                  title: 'Get Product Analytics',
                  description: 'Retrieve analytics data for a product',
                  onTap: () => _getProductAnalytics(ref, 'product123'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lead Management Example
            _buildSection(
              title: 'Lead Management',
              children: [
                _buildExample(
                  title: 'Create Lead',
                  description: 'Create a new product inquiry',
                  onTap: () => _createLead(ref),
                ),
                _buildExample(
                  title: 'Update Lead Status',
                  description: 'Update lead status and add notes',
                  onTap: () => _updateLeadStatus(ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Example
            _buildSection(
              title: 'Search Functions',
              children: [
                _buildExample(
                  title: 'Search Products',
                  description: 'Advanced product search with filters',
                  onTap: () => _searchProducts(ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Example
            _buildSection(
              title: 'Notifications',
              children: [
                _buildExample(
                  title: 'Send Notification',
                  description: 'Send notification to a specific user',
                  onTap: () => _sendNotification(ref),
                ),
                _buildExample(
                  title: 'Send Bulk Notification',
                  description: 'Send notification to multiple users',
                  onTap: () => _sendBulkNotification(ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Analytics Example
            _buildSection(
              title: 'Analytics',
              children: [
                _buildExample(
                  title: 'Get Dashboard Stats',
                  description: 'Get overall dashboard statistics',
                  onTap: () => _getDashboardStats(ref),
                ),
                _buildExample(
                  title: 'Get Analytics Data',
                  description: 'Get analytics data for specific period',
                  onTap: () => _getAnalyticsData(ref, '30d'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // System Functions Example
            _buildSection(
              title: 'System Functions',
              children: [
                _buildExample(
                  title: 'Get System Health',
                  description: 'Check system health status',
                  onTap: () => _getSystemHealth(ref),
                ),
                _buildExample(
                  title: 'Run Daily Cleanup',
                  description: 'Execute daily maintenance tasks',
                  onTap: () => _runDailyCleanup(ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildExample({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  // Example methods showing how to use Cloud Functions providers

  void _updateProductAnalytics(WidgetRef ref) {
    // Using the provider directly
    ref.read(firebaseUpdateProductAnalyticsProvider({
      'productId': 'product123',
      'action': 'view',
    }));

    // Or using the service directly
    final functions = ref.read(cloudFunctionsProvider);
    functions.updateProductAnalytics(
      productId: 'product123',
      action: 'view',
    );
  }

  void _getProductAnalytics(WidgetRef ref, String productId) {
    // Watch the provider for reactive updates
    ref.listen(firebaseProductAnalyticsProvider(productId), (previous, next) {
      next.when(
        data: (data) => print('Product analytics: $data'),
        loading: () => print('Loading analytics...'),
        error: (error, stack) => print('Error: $error'),
      );
    });
  }

  void _createLead(WidgetRef ref) {
    ref.read(firebaseCreateLeadProvider({
      'productId': 'product123',
      'inquiry':
          'I am interested in this product. Can you provide more details?',
      'contactInfo': {
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
      },
    }));
  }

  void _updateLeadStatus(WidgetRef ref) {
    ref.read(firebaseUpdateLeadStatusProvider({
      'leadId': 'lead123',
      'status': 'contacted',
      'notes': 'Customer contacted via phone',
    }));
  }

  void _searchProducts(WidgetRef ref) {
    ref.read(firebaseSearchResultsProvider({
      'query': 'electrical equipment',
      'category': 'electrical',
      'minPrice': 100.0,
      'maxPrice': 1000.0,
      'location': 'Mumbai',
      'limit': 20,
      'offset': 0,
    }));
  }

  void _sendNotification(WidgetRef ref) {
    ref.read(firebaseSendNotificationProvider({
      'userId': 'user123',
      'title': 'New Product Available',
      'message': 'Check out our latest electrical equipment!',
      'type': 'product_update',
      'data': {'productId': 'product123'},
    }));
  }

  void _sendBulkNotification(WidgetRef ref) {
    ref.read(firebaseSendBulkNotificationProvider({
      'userIds': ['user1', 'user2', 'user3'],
      'title': 'System Maintenance',
      'message': 'The system will be under maintenance from 2-4 AM',
      'type': 'system',
      'data': {'maintenanceWindow': '2-4 AM'},
    }));
  }

  void _getDashboardStats(WidgetRef ref) {
    ref.listen(firebaseDashboardAnalyticsProvider, (previous, next) {
      next.when(
        data: (data) => print('Dashboard stats: $data'),
        loading: () => print('Loading dashboard stats...'),
        error: (error, stack) => print('Error: $error'),
      );
    });
  }

  void _getAnalyticsData(WidgetRef ref, String period) {
    ref.listen(firebaseAnalyticsDataProvider(period), (previous, next) {
      next.when(
        data: (data) => print('Analytics data for $period: $data'),
        loading: () => print('Loading analytics data...'),
        error: (error, stack) => print('Error: $error'),
      );
    });
  }

  void _getSystemHealth(WidgetRef ref) {
    ref.listen(firebaseAppHealthProvider, (previous, next) {
      next.when(
        data: (data) => print('System health: $data'),
        loading: () => print('Checking system health...'),
        error: (error, stack) => print('Error: $error'),
      );
    });
  }

  void _runDailyCleanup(WidgetRef ref) {
    ref.read(firebaseRunDailyCleanupProvider);
  }
}

/// Example of using Cloud Functions in a StateNotifier
class ProductAnalyticsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  ProductAnalyticsNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> trackProductView(String productId) async {
    try {
      // Update analytics
      await ref.read(cloudFunctionsProvider).updateProductAnalytics(
            productId: productId,
            action: 'view',
          );

      // Get updated analytics
      final analytics =
          await ref.read(cloudFunctionsProvider).getProductAnalytics(productId);
      state = AsyncValue.data(analytics);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> trackProductInquiry(String productId) async {
    try {
      await ref.read(cloudFunctionsProvider).updateProductAnalytics(
            productId: productId,
            action: 'inquiry',
          );

      final analytics =
          await ref.read(cloudFunctionsProvider).getProductAnalytics(productId);
      state = AsyncValue.data(analytics);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

/// Provider for the ProductAnalyticsNotifier
final productAnalyticsNotifierProvider = StateNotifierProvider<
    ProductAnalyticsNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return ProductAnalyticsNotifier(ref);
});

/// Example of using Cloud Functions in a service class
class LeadManagementService {
  LeadManagementService(this.ref);

  final Ref ref;

  Future<void> createProductInquiry({
    required String productId,
    required String inquiry,
    required Map<String, dynamic> contactInfo,
  }) async {
    try {
      await ref.read(cloudFunctionsProvider).createLead(
            productId: productId,
            inquiry: inquiry,
            contactInfo: contactInfo,
          );

      // Invalidate related providers to refresh data
      ref.invalidate(firebaseUserLeadsProvider);
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  Future<void> updateLead({
    required String leadId,
    required String status,
    String? notes,
  }) async {
    try {
      await ref.read(cloudFunctionsProvider).updateLeadStatus(
            leadId: leadId,
            status: status,
            notes: notes,
          );

      // Invalidate related providers
      ref.invalidate(firebaseUserLeadsProvider);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }
}

/// Provider for the LeadManagementService
final leadManagementServiceProvider = Provider<LeadManagementService>((ref) {
  return LeadManagementService(ref);
});
