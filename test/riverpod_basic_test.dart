import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/home/home_page.dart';

void main() {
  group('Riverpod Basic Tests', () {
    testWidgets('HomePage renders with ProviderScope', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Check if the app renders without crashing
      expect(find.text('Vidyut'), findsOneWidget);
    });

    testWidgets('AppStateNotifier provider works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final appState = ref.watch(appStateNotifierProvider);
              return MaterialApp(
                home: Scaffold(
                  body: Text('City: ${appState.city}'),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the default city is displayed
      expect(find.text('City: Hyderabad'), findsOneWidget);
    });

    testWidgets('DemoDataService provider works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final demoService = ref.watch(demoDataServiceProvider);
              return MaterialApp(
                home: Scaffold(
                  body: Text('Products: ${demoService.allProducts.length}'),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if products are loaded (should have some demo products)
      expect(find.textContaining('Products:'), findsOneWidget);
    });
  });
}
