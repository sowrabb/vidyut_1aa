import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:vidyut/app/app.dart'; // adjust if your app name differs

Future<void> _pumpSize(WidgetTester tester, Size size) async {
  // Force a specific size without relying on window globals.
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, devicePixelRatio: 1.0),
      child: const Directionality(
          textDirection: TextDirection.ltr, child: VidyutApp()),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('No layout exceptions at phone/tablet/desktop sizes',
      (WidgetTester tester) async {
    final sizes = <Size>[
      const Size(375, 812), // phone portrait
      const Size(834, 1194), // tablet portrait
      const Size(1440, 900), // desktop
    ];

    for (final s in sizes) {
      await _pumpSize(tester, s);
      // Navigate through the 5 main tabs to smoke-test each page
      expect(find.text('Home'), findsOneWidget);
      // Go Search
      await tester.tap(find.byIcon(Ionicons.search_outline).first);
      await tester.pumpAndSettle();

      // Test Search filters on mobile
      final filtersBtn = find.widgetWithIcon(OutlinedButton, Icons.tune);
      if (filtersBtn.evaluate().isNotEmpty) {
        await tester.tap(filtersBtn);
        await tester.pumpAndSettle();
        // Close via Apply
        final apply = find.widgetWithText(FilledButton, 'Apply');
        if (apply.evaluate().isNotEmpty) {
          await tester.tap(apply);
          await tester.pumpAndSettle();
        } else {
          // or just back if not present
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }
      // Go Sell
      await tester.tap(find.byIcon(Ionicons.storefront_outline).first);
      await tester.pumpAndSettle();
      // Go State Info
      await tester.tap(find.byIcon(Ionicons.earth_outline).first);
      await tester.pumpAndSettle();
      // Go Profile
      await tester.tap(find.byIcon(Ionicons.person_circle_outline).first);
      await tester.pumpAndSettle();

      // Assert: no exceptions leaked from layout
      final err = tester.takeException();
      expect(err, isNull, reason: 'Layout threw an exception at size $s');
    }
  });
}
