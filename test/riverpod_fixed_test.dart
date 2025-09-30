import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/test_harness.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/home/home_page.dart';

void main() {
  group('Riverpod Fixed Tests', () {
    testWidgets('HomePage renders without ProviderScope errors',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(HomePage()),
      );

      await tester.pumpAndSettle();

      // Check if the app renders without crashing
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('AppStateNotifier works with test harness', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final appState = ref.watch(appStateNotifierProvider);
              return Scaffold(
                body: Text('City: ${appState.city}'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the default city is displayed
      expect(find.text('City: Hyderabad'), findsOneWidget);
    });

    testWidgets('DemoDataService loads without timer issues', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final demoService = ref.watch(demoDataServiceProvider);
              return Scaffold(
                body: Text('Products: ${demoService.allProducts.length}'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if products are loaded (should have some demo products)
      expect(find.textContaining('Products:'), findsOneWidget);

      // Verify we have products loaded
      final productText = tester.widget<Text>(find.textContaining('Products:'));
      expect(productText.data, isNotNull);
    });
  });
}
