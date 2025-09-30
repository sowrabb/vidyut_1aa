import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vidyut/features/admin/pages/billing_management_page.dart';
import 'package:vidyut/features/admin/pages/subscription_management_page.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

Future<Widget> _wrapWithProviders(Widget child) async {
  final demo = LightweightDemoDataService();
  await demo.initializationFuture;
  final store = EnhancedAdminStore(
    apiService: EnhancedAdminApiService(),
    demoDataService: demo,
    useBackend: false,
  );
  return ProviderScope(
    overrides: [
      enhancedAdminStoreProvider.overrideWith((ref) => store),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 goldens - Billing', () {
    testWidgets('Billing Overview golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      final app = await _wrapWithProviders(const BillingManagementPage());
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Ensure Overview tab selected (it is by default)
      expect(find.text('Billing Management'), findsOneWidget);
      expect(find.text('Dunning ('), findsOneWidget);

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/billing_overview.png'),
      );
    });

    testWidgets('Billing Payments golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      final app = await _wrapWithProviders(const BillingManagementPage());
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Switch to Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/billing_payments.png'),
      );
    });

    testWidgets('Billing Invoices golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      final app = await _wrapWithProviders(const BillingManagementPage());
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Switch to Invoices tab
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/billing_invoices.png'),
      );
    });
  });

  group('Phase 3 goldens - Subscriptions', () {
    testWidgets('Subscriptions tab golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      final app = await _wrapWithProviders(const SubscriptionManagementPage());
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Navigate to Subscriptions tab
      await tester.dragUntilVisible(
        find.text('Subscriptions'),
        find.byType(TabBar),
        const Offset(-200, 0),
      );
      await tester.tap(find.text('Subscriptions'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/subscriptions_tab.png'),
      );
    });
  });
}
