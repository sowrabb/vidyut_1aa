import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vidyut/features/admin/pages/billing_management_page.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Billing overview shows stats and dunning list', (tester) async {
    final demo = LightweightDemoDataService();
    await demo.initializationFuture;

    final store = EnhancedAdminStore(
      apiService: EnhancedAdminApiService(),
      demoDataService: demo,
      useBackend: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          enhancedAdminStoreProvider.overrideWith((ref) => store),
        ],
        child: const MaterialApp(
          home: Scaffold(body: BillingManagementPage()),
        ),
      ),
    );

    // Let async loads settle
    await tester.pumpAndSettle();

    // Expect key stats labels present
    expect(find.textContaining('Total Revenue'), findsWidgets);
    expect(find.textContaining('Monthly Revenue'), findsWidgets);

    // Expect Dunning section title present
    expect(find.textContaining('Dunning ('), findsOneWidget);

    // Expect an overdue invoice appears (from demo seed INV-DEMO-002)
    expect(find.textContaining('INV-DEMO-002'), findsWidgets);
  });
}
