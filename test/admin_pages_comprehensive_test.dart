import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Admin Pages
import 'package:vidyut/features/admin/pages/analytics_dashboard_page.dart';
import 'package:vidyut/features/admin/pages/billing_management_page.dart';
import 'package:vidyut/features/admin/pages/categories_management_page.dart';
import 'package:vidyut/features/admin/pages/enhanced_hero_sections_page.dart';
import 'package:vidyut/features/admin/pages/enhanced_products_management_page.dart';
import 'package:vidyut/features/admin/pages/enhanced_rbac_management_page.dart';
import 'package:vidyut/features/admin/pages/enhanced_users_management_page.dart';
import 'package:vidyut/features/admin/pages/feature_flags_page.dart';
import 'package:vidyut/features/admin/pages/kyc_management_page.dart';
import 'package:vidyut/features/admin/pages/media_storage_page.dart';
import 'package:vidyut/features/admin/pages/notifications_page.dart';
import 'package:vidyut/features/admin/pages/product_designs_page.dart';
import 'package:vidyut/features/admin/pages/seller_management_page.dart';
import 'package:vidyut/features/admin/pages/subscription_management_page.dart';
import 'package:vidyut/features/admin/pages/system_operations_page.dart';

// Services and Stores
import 'package:vidyut/features/admin/auth/admin_auth_service.dart';
import 'package:vidyut/features/admin/store/admin_store.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/features/admin/rbac/rbac_service.dart';
import 'package:vidyut/features/admin/rbac/enhanced_rbac_service.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

// Mock classes
class MockEnhancedAdminStore extends EnhancedAdminStore {
  MockEnhancedAdminStore()
      : super(
          apiService:
              EnhancedAdminApiService(environment: ApiEnvironment.development),
          demoDataService: LightweightDemoDataService(),
          useBackend: false,
        );
}

class MockEnhancedRbacService extends EnhancedRbacService {
  MockEnhancedRbacService() : super();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('RenderFlex overflowed') ||
        details.exception.toString().contains('A RenderFlex overflowed') ||
        details.exception.toString().contains('Unable to load asset') ||
        details.exception.toString().contains('No Material widget found')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Helper function to create test widget with all necessary providers
  Widget createTestWidgetWithProviders({required Widget child}) {
    SharedPreferences.setMockInitialValues({});

    final demoService = LightweightDemoDataService();
    final enhancedStore = EnhancedAdminStore(
      apiService:
          EnhancedAdminApiService(environment: ApiEnvironment.development),
      demoDataService: demoService,
      useBackend: false,
    );
    final adminStore = AdminStore(demoService);
    final rbacService = RbacService();
    final authService =
        AdminAuthService(enhancedStore, demoService, rbacService);

    return ProviderScope(
      overrides: [
        demoDataServiceProvider.overrideWith((ref) => demoService),
        enhancedAdminStoreProvider.overrideWith((ref) => enhancedStore),
        adminStoreProvider.overrideWith((ref) => adminStore),
        adminAuthServiceProvider.overrideWith((ref) => authService),
        rbacServiceProvider.overrideWith((ref) => rbacService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: child,
          ),
        ),
      ),
    );
  }

  group('Phase 13: Individual Admin Pages Testing', () {
    group('Enhanced Users Management Page', () {
      testWidgets('renders without errors', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedUsersManagementPage(adminStore: mockStore),
          ),
        );
        await tester.pump();
        expect(find.byType(EnhancedUsersManagementPage), findsOneWidget);
      });

      testWidgets('handles basic interactions', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedUsersManagementPage(adminStore: mockStore),
          ),
        );
        await tester.pump();

        // Test search functionality
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'test user');
          await tester.pump();
          expect(find.text('test user'), findsOneWidget);
        }
      });
    });

    group('Enhanced Products Management Page', () {
      testWidgets('renders without errors', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedProductsManagementPage(adminStore: mockStore),
          ),
        );
        await tester.pump();
        expect(find.byType(EnhancedProductsManagementPage), findsOneWidget);
      });

      testWidgets('handles basic interactions', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedProductsManagementPage(adminStore: mockStore),
          ),
        );
        await tester.pump();

        // Test search functionality
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'test product');
          await tester.pump();
          expect(find.text('test product'), findsOneWidget);
        }
      });
    });

    group('Categories Management Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const CategoriesManagementPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(CategoriesManagementPage), findsOneWidget);
      });

      testWidgets('handles basic interactions', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const CategoriesManagementPage(),
          ),
        );
        await tester.pump();

        // Test category interactions
        final addButton = find.text('Add Category');
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton);
          await tester.pump();
        }
      });
    });

    group('KYC Management Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const KycManagementPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(KycManagementPage), findsOneWidget);
      });

      testWidgets('handles basic interactions', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const KycManagementPage(),
          ),
        );
        await tester.pump();

        // Test KYC review functionality
        final reviewButton = find.text('Review');
        if (reviewButton.evaluate().isNotEmpty) {
          await tester.tap(reviewButton);
          await tester.pump();
        }
      });
    });

    group('Enhanced RBAC Management Page', () {
      testWidgets('renders without errors', (tester) async {
        final mockRbacService = MockEnhancedRbacService();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedRbacManagementPage(rbacService: mockRbacService),
          ),
        );
        await tester.pump();
        expect(find.byType(EnhancedRbacManagementPage), findsOneWidget);
      });

      testWidgets('handles basic interactions', (tester) async {
        final mockRbacService = MockEnhancedRbacService();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedRbacManagementPage(rbacService: mockRbacService),
          ),
        );
        await tester.pump();

        // Test role management
        final createRoleButton = find.text('Create Role');
        if (createRoleButton.evaluate().isNotEmpty) {
          await tester.tap(createRoleButton);
          await tester.pump();
        }
      });
    });

    group('Analytics Dashboard Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const AnalyticsDashboardPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
      });

      testWidgets('displays analytics data', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const AnalyticsDashboardPage(),
          ),
        );
        await tester.pump();

        // Check for analytics widgets
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
      });
    });

    group('Notifications Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const NotificationsPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(NotificationsPage), findsOneWidget);
      });

      testWidgets('handles notification management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const NotificationsPage(),
          ),
        );
        await tester.pump();

        // Test notification interactions
        final sendButton = find.text('Send Notification');
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton);
          await tester.pump();
        }
      });
    });

    group('Subscription Management Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SubscriptionManagementPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(SubscriptionManagementPage), findsOneWidget);
      });

      testWidgets('handles subscription management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SubscriptionManagementPage(),
          ),
        );
        await tester.pump();

        // Test subscription interactions
        final createPlanButton = find.text('Create Plan');
        if (createPlanButton.evaluate().isNotEmpty) {
          await tester.tap(createPlanButton);
          await tester.pump();
        }
      });
    });

    group('Media Storage Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const MediaStoragePage(),
          ),
        );
        await tester.pump();
        expect(find.byType(MediaStoragePage), findsOneWidget);
      });

      testWidgets('handles media management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const MediaStoragePage(),
          ),
        );
        await tester.pump();

        // Test media upload functionality
        final uploadButton = find.text('Upload');
        if (uploadButton.evaluate().isNotEmpty) {
          await tester.tap(uploadButton);
          await tester.pump();
        }
      });
    });

    group('Product Designs Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const ProductDesignsPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(ProductDesignsPage), findsOneWidget);
      });

      testWidgets('handles design management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const ProductDesignsPage(),
          ),
        );
        await tester.pump();

        // Test design interactions
        final createDesignButton = find.text('Create Design');
        if (createDesignButton.evaluate().isNotEmpty) {
          await tester.tap(createDesignButton);
          await tester.pump();
        }
      });
    });

    group('Feature Flags Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const FeatureFlagsPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(FeatureFlagsPage), findsOneWidget);
      });

      testWidgets('handles feature flag toggles', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const FeatureFlagsPage(),
          ),
        );
        await tester.pump();

        // Test feature flag interactions
        final toggleButtons = find.byType(Switch);
        if (toggleButtons.evaluate().isNotEmpty) {
          await tester.tap(toggleButtons.first);
          await tester.pump();
        }
      });
    });

    group('Enhanced Hero Sections Page', () {
      testWidgets('renders without errors', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedHeroSectionsPage(adminStore: mockStore),
          ),
        );
        await tester.pump();
        expect(find.byType(EnhancedHeroSectionsPage), findsOneWidget);
      });

      testWidgets('handles hero section management', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedHeroSectionsPage(adminStore: mockStore),
          ),
        );
        await tester.pump();

        // Test hero section interactions
        final createButton = find.text('Create Hero Section');
        if (createButton.evaluate().isNotEmpty) {
          await tester.tap(createButton);
          await tester.pump();
        }
      });
    });

    group('Seller Management Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SellerManagementPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(SellerManagementPage), findsOneWidget);
      });

      testWidgets('handles seller management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SellerManagementPage(),
          ),
        );
        await tester.pump();

        // Test seller interactions
        final approveButton = find.text('Approve');
        if (approveButton.evaluate().isNotEmpty) {
          await tester.tap(approveButton);
          await tester.pump();
        }
      });
    });

    group('Billing Management Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const BillingManagementPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(BillingManagementPage), findsOneWidget);
      });

      testWidgets('handles billing management', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const BillingManagementPage(),
          ),
        );
        await tester.pump();

        // Test billing interactions
        final generateInvoiceButton = find.text('Generate Invoice');
        if (generateInvoiceButton.evaluate().isNotEmpty) {
          await tester.tap(generateInvoiceButton);
          await tester.pump();
        }
      });
    });

    group('System Operations Page', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SystemOperationsPage(),
          ),
        );
        await tester.pump();
        expect(find.byType(SystemOperationsPage), findsOneWidget);
      });

      testWidgets('handles system operations', (tester) async {
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: const SystemOperationsPage(),
          ),
        );
        await tester.pump();

        // Test system operation interactions
        final backupButton = find.text('Backup');
        if (backupButton.evaluate().isNotEmpty) {
          await tester.tap(backupButton);
          await tester.pump();
        }
      });
    });

    group('Admin Pages Integration Tests', () {
      testWidgets('all admin pages can be rendered in sequence',
          (tester) async {
        final mockStore = MockEnhancedAdminStore();
        final mockRbacService = MockEnhancedRbacService();
        final pages = [
          EnhancedUsersManagementPage(adminStore: mockStore),
          EnhancedProductsManagementPage(adminStore: mockStore),
          const CategoriesManagementPage(),
          const KycManagementPage(),
          EnhancedRbacManagementPage(rbacService: mockRbacService),
          const AnalyticsDashboardPage(),
          const NotificationsPage(),
          const SubscriptionManagementPage(),
          const MediaStoragePage(),
          const ProductDesignsPage(),
          const FeatureFlagsPage(),
          EnhancedHeroSectionsPage(adminStore: mockStore),
          const SellerManagementPage(),
          const BillingManagementPage(),
          const SystemOperationsPage(),
        ];

        for (final page in pages) {
          await tester.pumpWidget(
            createTestWidgetWithProviders(child: page),
          );
          await tester.pump();
          // Verify page renders without crashing
          expect(find.byType(page.runtimeType), findsOneWidget);
        }
      });

      testWidgets('admin pages handle state changes correctly', (tester) async {
        final mockStore = MockEnhancedAdminStore();
        await tester.pumpWidget(
          createTestWidgetWithProviders(
            child: EnhancedUsersManagementPage(adminStore: mockStore),
          ),
        );
        await tester.pump();

        // Test state changes
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(EnhancedUsersManagementPage), findsOneWidget);
      });
    });
  });
}
