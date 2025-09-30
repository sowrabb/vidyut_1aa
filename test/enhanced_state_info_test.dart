import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/stateinfo/enhanced_state_info_page.dart';

// Test wrapper for the enhanced state info page
class TestWrapper extends StatelessWidget {
  final Widget child;

  const TestWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }
}

void main() {
  group('Enhanced State Info Flow Tests', () {
    testWidgets('displays selection screen correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify selection screen is displayed
      expect(find.text('State Electricity Board Info'), findsOneWidget);
      expect(find.text('Choose Information Flow'), findsOneWidget);
      expect(find.text('Power Generation Flow'), findsOneWidget);
      expect(find.text('State-Based Flow'), findsOneWidget);
    });

    testWidgets('navigates to power flow screen when power flow is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Power Generation Flow
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();

      // Verify power flow screen is displayed
      expect(find.text('Power Generation Flow'), findsOneWidget);
      expect(find.text('Power Generators'), findsOneWidget);
    });

    testWidgets('navigates to state flow screen when state flow is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on State-Based Flow
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();

      // Verify state flow screen is displayed
      expect(find.text('State-Based Flow'), findsOneWidget);
      expect(find.text('Select a State'), findsOneWidget);
    });

    testWidgets('navigates to generator profile with tab bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to power flow
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();

      // Tap on first generator
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify generator profile with tabs is displayed
      expect(find.text('NTPC Limited'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('navigates to state profile with tab bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to state flow
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();

      // Tap on first state
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify state profile with tabs is displayed
      expect(find.text('Maharashtra'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Districts'), findsOneWidget);
    });

    testWidgets('tab switching works in generator profile',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to generator profile
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Switch to Company tab
      await tester.tap(find.text('Company'));
      await tester.pumpAndSettle();

      // Verify company tab content
      expect(find.text('Total Plants'), findsOneWidget);
      expect(find.text('Employees'), findsOneWidget);
    });

    testWidgets('tab switching works in state profile',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to state profile
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Switch to Energy tab
      await tester.tap(find.text('Energy'));
      await tester.pumpAndSettle();

      // Verify energy tab content
      expect(find.text('Thermal'), findsOneWidget);
      expect(find.text('Hydro'), findsOneWidget);
    });

    testWidgets('back navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: EnhancedStateInfoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to power flow
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();

      // Verify we're in power flow screen
      expect(find.text('Power Generation Flow'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back to selection screen
      expect(find.text('Choose Information Flow'), findsOneWidget);
    });
  });
}
