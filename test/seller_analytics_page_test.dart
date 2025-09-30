import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/features/sell/analytics_page.dart';
import '../lib/app/provider_registry.dart';

void main() {
  testWidgets('Seller AnalyticsPage renders KPIs, metrics and reports',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const AnalyticsPage(),
          routes: {
            '/subscription': (context) =>
                const Scaffold(body: Center(child: Text('Subscription'))),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Title
    expect(find.text('Analytics'), findsOneWidget);

    // KPI labels
    expect(find.text('Profile Views'), findsOneWidget);
    expect(find.text('Product Views'), findsOneWidget);
    expect(find.text('Contacts (All)'), findsOneWidget);

    // Performance Metrics section
    expect(find.text('Performance Metrics'), findsOneWidget);
    expect(find.text('Conversion Rates'), findsOneWidget);

    // Sales Reports section and button
    expect(find.text('Sales Reports'), findsOneWidget);
    expect(find.text('Download CSV'), findsOneWidget);

    // Tap Download CSV and expect a SnackBar
    await tester.tap(find.text('Download CSV'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
