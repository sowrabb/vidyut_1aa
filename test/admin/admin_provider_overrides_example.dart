/// Example provider overrides for admin feature testing
/// 
/// This file demonstrates how to override admin providers in tests
/// using the new repository-backed architecture.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/state/admin/kyc_providers.dart';
import 'package:vidyut/state/admin/analytics_providers.dart';
import 'package:vidyut/state/session/rbac.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/admin/models/kyc_models.dart';

/// Example 1: Override RBAC for admin access testing
List<Override> createAdminRbacOverrides({
  String role = 'admin',
  Set<String> permissions = const {
    'admin.access',
    'kyc.review',
    'kyc.approve',
    'kyc.reject',
    'users.read',
    'users.write',
    'products.read',
    'products.write',
  },
}) {
  return [
    rbacProvider.overrideWith((ref) => Rbac(
      role: role,
      permissions: permissions,
    )),
  ];
}

/// Example 2: Override KYC providers with test data
List<Override> createKycTestOverrides({
  List<KycSubmission>? pendingSubmissions,
  List<KycSubmission>? allSubmissions,
}) {
  final pending = pendingSubmissions ?? [
    KycSubmission(
      id: 'kyc1',
      userId: 'user1',
      businessName: 'Test Business 1',
      status: KycDocumentStatus.pending,
      createdAt: DateTime(2025, 9, 1),
      documents: [],
    ),
    KycSubmission(
      id: 'kyc2',
      userId: 'user2',
      businessName: 'Test Business 2',
      status: KycDocumentStatus.pending,
      createdAt: DateTime(2025, 9, 2),
      documents: [],
    ),
  ];

  return [
    kycPendingSubmissionsProvider.overrideWith((ref) => Stream.value(pending)),
    kycSubmissionsByStatusProvider.overrideWith((ref, status) {
      final all = allSubmissions ?? pending;
      if (status == null || status == 'all') {
        return Stream.value(all);
      }
      return Stream.value(
        all.where((s) => s.status.value == status).toList(),
      );
    }),
    kycPendingCountProvider.overrideWith((ref) => Stream.value(pending.length)),
  ];
}

/// Example 3: Override analytics providers with test data
List<Override> createAnalyticsTestOverrides({
  int totalUsers = 1234,
  int activeSellers = 56,
  int totalProducts = 789,
  int totalOrders = 321,
}) {
  return [
    adminDashboardAnalyticsProvider.overrideWith((ref) => Future.value(
      DashboardAnalytics(
        totalUsers: totalUsers,
        activeSellers: activeSellers,
        totalProducts: totalProducts,
        totalOrders: totalOrders,
        revenue: 0.0,
        revenueGrowth: 0.0,
        timestamp: DateTime.now(),
      ),
    )),
    adminProductAnalyticsProvider.overrideWith((ref) => Future.value(
      ProductAnalytics(
        totalProducts: totalProducts,
        activeProducts: totalProducts - 10,
        pendingApproval: 5,
        topProducts: [],
        timestamp: DateTime.now(),
      ),
    )),
    adminUserAnalyticsProvider.overrideWith((ref) => Future.value(
      UserAnalytics(
        totalUsers: totalUsers,
        activeUsers: totalUsers - 100,
        newUsersToday: 10,
        growth: 5.5,
        timestamp: DateTime.now(),
      ),
    )),
  ];
}

/// Example 4: Complete test setup combining all overrides
class AdminTestSetup {
  static List<Override> get standard => [
    ...createAdminRbacOverrides(),
    ...createKycTestOverrides(),
    ...createAnalyticsTestOverrides(),
  ];

  static List<Override> get buyerUser => [
    ...createAdminRbacOverrides(
      role: 'buyer',
      permissions: {'products.read'},
    ),
    ...createKycTestOverrides(),
    ...createAnalyticsTestOverrides(),
  ];

  static List<Override> get sellerUser => [
    ...createAdminRbacOverrides(
      role: 'seller',
      permissions: {'products.read', 'products.write', 'kyc.submit'},
    ),
    ...createKycTestOverrides(),
    ...createAnalyticsTestOverrides(),
  ];
}

/// Example test using these overrides
void main() {
  group('Admin Dashboard Tests', () {
    testWidgets('Admin user can view dashboard', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: AdminTestSetup.standard,
          child: MaterialApp(
            home: AdminDashboardV2(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard loads
      expect(find.text('Admin Dashboard'), findsOneWidget);
      
      // Verify analytics cards render
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
      
      // Verify KYC badge shows pending count
      expect(find.text('2 pending'), findsOneWidget);
    });

    testWidgets('Non-admin user sees access denied', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: AdminTestSetup.buyerUser,
          child: MaterialApp(
            home: AdminDashboardV2(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('You do not have permission'), findsOneWidget);
    });
  });

  group('KYC Management Tests', () {
    testWidgets('Admin can view pending KYC submissions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...AdminTestSetup.standard,
            ...createKycTestOverrides(
              pendingSubmissions: [
                KycSubmission(
                  id: 'kyc1',
                  userId: 'user1',
                  businessName: 'Test Business',
                  status: KycDocumentStatus.pending,
                  createdAt: DateTime.now(),
                  documents: [],
                ),
              ],
            ),
          ],
          child: MaterialApp(
            home: KycManagementPageV2(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('KYC Management'), findsOneWidget);
      expect(find.text('Test Business'), findsOneWidget);
      expect(find.text('Status: pending'), findsOneWidget);
    });

    testWidgets('Admin can filter KYC by status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: AdminTestSetup.standard,
          child: MaterialApp(
            home: KycManagementPageV2(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open status dropdown
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      // Select approved filter
      await tester.tap(find.text('Approved').last);
      await tester.pumpAndSettle();

      // Verify filter applied (would show different submissions)
      // In real test, verify the provider was called with 'approved' status
    });
  });
}

/// Mock repository service for testing actions
class MockFirestoreRepository {
  final List<Map<String, dynamic>> updates = [];
  
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    updates.add({'path': path, 'data': data});
  }
  
  void reset() {
    updates.clear();
  }
}

/// Example test for KYC approval action
void testKycApproval() {
  test('Approving KYC submission updates Firestore', () async {
    final mockRepo = MockFirestoreRepository();
    
    // In real test, override firestoreRepositoryServiceProvider with mockRepo
    // Then trigger approval action and verify mockRepo.updates contains expected data
    
    await mockRepo.updateDocument('kyc_submissions/kyc1', {
      'status': 'approved',
      'reviewed_at': DateTime.now(),
      'reviewed_by': 'admin_user_id',
    });
    
    expect(mockRepo.updates.length, 1);
    expect(mockRepo.updates[0]['path'], 'kyc_submissions/kyc1');
    expect(mockRepo.updates[0]['data']['status'], 'approved');
  });
}




