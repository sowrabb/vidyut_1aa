import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/stateinfo/lightweight_state_info_page.dart';
import 'package:vidyut/features/stateinfo/store/lightweight_state_info_store.dart';
import 'package:vidyut/features/stateinfo/models/state_info_models.dart';

// Test wrapper for the lightweight state info page
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
  group('Lightweight State Info Flow Tests', () {
    testWidgets('displays selection screen correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Verify selection screen is displayed
      expect(find.text('Choose Information Flow'), findsOneWidget);
      expect(find.text('Power Generation Flow'), findsOneWidget);
      expect(find.text('State-Based Flow'), findsOneWidget);
    });

    testWidgets('navigates to states screen when state flow is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Tap on State-Based Flow
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();

      // Verify states screen is displayed
      expect(find.text('Select a State'), findsOneWidget);
      expect(find.text('Maharashtra'), findsOneWidget);
      expect(find.text('Delhi'), findsOneWidget);
    });

    testWidgets('navigates to generators screen when power flow is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Tap on Power Generation Flow
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();

      // Verify generators screen is displayed
      expect(find.text('Power Generators'), findsOneWidget);
      expect(find.text('Explore India\'s major power generation companies'),
          findsOneWidget);
    });

    testWidgets('state selection and detail navigation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate to states screen
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();

      // Select Maharashtra
      await tester.tap(find.text('Maharashtra'));
      await tester.pumpAndSettle();

      // Verify state detail screen is displayed
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Districts'), findsOneWidget);
    });

    testWidgets('tab switching works in state detail screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate to state detail
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maharashtra'));
      await tester.pumpAndSettle();

      // Switch to Admin tab
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();

      // Verify admin content is displayed
      expect(find.text('Chief Minister'), findsOneWidget);
      expect(find.text('Energy Minister'), findsOneWidget);

      // Switch to Energy tab
      await tester.tap(find.text('Energy'));
      await tester.pumpAndSettle();

      // Verify energy content is displayed
      expect(find.text('Thermal'), findsOneWidget);
      expect(find.text('Hydro'), findsOneWidget);
    });

    testWidgets('mandal selection works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate to state detail
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maharashtra'));
      await tester.pumpAndSettle();

      // Switch to Districts tab
      await tester.tap(find.text('Districts'));
      await tester.pumpAndSettle();

      // Select a mandal
      await tester.tap(find.text('Mumbai City'));
      await tester.pumpAndSettle();

      // Verify mandal detail screen is displayed
      expect(find.text('Mandal Details'), findsOneWidget);
      expect(find.text('Population'), findsOneWidget);
      expect(find.text('Power Demand'), findsOneWidget);
    });

    testWidgets('generator selection and profile navigation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate to generators screen
      await tester.tap(find.text('Power Generation Flow'));
      await tester.pumpAndSettle();

      // Select NTPC generator
      await tester.tap(find.text('NTPC Limited'));
      await tester.pumpAndSettle();

      // Verify generator profile is displayed
      expect(find.text('Generator Profile'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Capacity'), findsOneWidget);
      expect(find.text('CEO'), findsOneWidget);
    });

    testWidgets('navigation buttons work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate to states screen
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();

      // Test back button
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back at selection screen
      expect(find.text('Choose Information Flow'), findsOneWidget);
    });

    testWidgets('start over button works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: LightweightStateInfoPage(),
        ),
      );

      // Navigate deep into the flow
      await tester.tap(find.text('State-Based Flow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maharashtra'));
      await tester.pumpAndSettle();

      // Test start over button
      await tester.tap(find.text('Start Over'));
      await tester.pumpAndSettle();

      // Should be back at selection screen
      expect(find.text('Choose Information Flow'), findsOneWidget);
    });
  });

  group('Lightweight Store Tests', () {
    test('store initializes with correct default values', () {
      final store = LightweightStateInfoStore();

      expect(store.mainPath, equals(MainPath.selection));
      expect(store.powerFlowStep, equals(PowerFlowStep.generator));
      expect(store.stateFlowStep, equals(StateFlowStep.states));
      expect(store.selectedState, isEmpty);
      expect(store.selectedGenerator, isEmpty);
    });

    test('path selection updates correctly', () {
      final store = LightweightStateInfoStore();

      store.selectPath(MainPath.powerFlow);
      expect(store.mainPath, equals(MainPath.powerFlow));
      expect(store.powerFlowStep, equals(PowerFlowStep.generator));

      store.selectPath(MainPath.stateFlow);
      expect(store.mainPath, equals(MainPath.stateFlow));
      expect(store.stateFlowStep, equals(StateFlowStep.states));
    });

    test('state selection works correctly', () {
      final store = LightweightStateInfoStore();

      store.selectState('maharashtra');
      expect(store.selectedState, equals('maharashtra'));
      expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));
      expect(store.selectedStateData?.name, equals('Maharashtra'));
    });

    test('mandal selection works correctly', () {
      final store = LightweightStateInfoStore();

      store.selectState('maharashtra');
      store.selectMandal('mumbai');
      expect(store.selectedState, equals('maharashtra'));
      expect(store.selectedMandal, equals('mumbai'));
      expect(store.stateFlowStep, equals(StateFlowStep.mandalDetail));
      expect(store.selectedMandalData?.name, equals('Mumbai City'));
    });

    test('generator selection works correctly', () {
      final store = LightweightStateInfoStore();

      store.selectGenerator('ntpc');
      expect(store.selectedGenerator, equals('ntpc'));
      expect(store.powerFlowStep, equals(PowerFlowStep.generatorProfile));
      expect(store.selectedGeneratorData?.name, equals('NTPC Limited'));
    });

    test('reset functions work correctly', () {
      final store = LightweightStateInfoStore();

      // Set some state
      store.selectState('maharashtra');
      store.selectMandal('mumbai');
      store.selectGenerator('ntpc');

      // Reset to selection
      store.resetToSelection();

      expect(store.mainPath, equals(MainPath.selection));
      expect(store.selectedState, isEmpty);
      expect(store.selectedMandal, isEmpty);
      expect(store.selectedGenerator, isEmpty);
    });

    test('progress calculation works correctly', () {
      final store = LightweightStateInfoStore();

      expect(store.stateFlowProgress, equals(1));

      store.selectState('maharashtra');
      expect(store.stateFlowProgress, equals(2));

      store.selectMandal('mumbai');
      expect(store.stateFlowProgress, equals(3));
    });

    test('title generation works correctly', () {
      final store = LightweightStateInfoStore();

      expect(store.currentTitle, equals('State Electricity Board Info'));

      store.selectPath(MainPath.powerFlow);
      expect(store.currentTitle, equals('Power Generators'));

      store.selectPath(MainPath.stateFlow);
      expect(store.currentTitle, equals('Indian States'));

      store.selectState('maharashtra');
      expect(store.currentTitle, equals('Maharashtra'));
    });
  });
}
