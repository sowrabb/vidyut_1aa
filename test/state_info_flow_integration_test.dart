import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/stateinfo/store/state_info_store.dart';
import 'package:vidyut/features/stateinfo/widgets/state_flow_screens.dart';
import 'package:vidyut/features/stateinfo/widgets/power_flow_screens.dart';
import 'package:vidyut/features/stateinfo/models/state_info_models.dart';
import 'package:vidyut/features/stateinfo/pages/comprehensive_state_info_page.dart';
import 'package:vidyut/app/provider_registry.dart';

// Integration test wrapper
class IntegrationTestWrapper extends StatelessWidget {
  final Widget child;
  final StateInfoStore? store;

  const IntegrationTestWrapper({
    super.key,
    required this.child,
    this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ProviderScope(
        overrides: [
          stateInfoStoreProvider
              .overrideWith((ref) => store ?? StateInfoStore()),
        ],
        child: Scaffold(
          body: child,
        ),
      ),
    );
  }
}

void main() {
  group('State Info Flow Integration Tests', () {
    late StateInfoStore store;

    setUp(() {
      store = StateInfoStore();
    });

    group('Complete State Flow Loop', () {
      testWidgets('full state flow navigation loop works correctly',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        // Start with comprehensive state info page
        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial state
        expect(store.mainPath, equals(MainPath.selection));

        // Navigate to state flow
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
          expect(store.mainPath, equals(MainPath.stateFlow));
          expect(store.stateFlowStep, equals(StateFlowStep.states));
        }

        // Verify states selection screen is displayed
        expect(find.byType(StatesSelectionScreen), findsOneWidget);
        expect(find.text('Maharashtra'), findsOneWidget);

        // Select Maharashtra state
        await tester.tap(find.text('Maharashtra'));
        await tester.pumpAndSettle();

        // Verify state detail screen is displayed
        expect(find.byType(StateDetailScreen), findsOneWidget);
        expect(store.selectedState, equals('maharashtra'));
        expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));

        // Test tab navigation in state detail
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();
        expect(find.text('Chief Minister'), findsOneWidget);

        await tester.tap(find.text('Energy Mix'));
        await tester.pumpAndSettle();
        expect(find.text('Energy Mix Breakdown'), findsOneWidget);

        // Navigate to districts tab
        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        // Select Mumbai mandal
        await tester.tap(find.text('Mumbai City'));
        await tester.pumpAndSettle();

        // Verify mandal detail screen is displayed
        expect(find.byType(MandalDetailScreen), findsOneWidget);
        expect(store.selectedMandal, equals('mumbai'));
        expect(store.stateFlowStep, equals(StateFlowStep.mandalDetail));

        // Test mandal detail tabs
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();
        expect(find.text('Division Controller'), findsOneWidget);

        await tester.tap(find.text('Local DISCOMs'));
        await tester.pumpAndSettle();
        expect(find.text('Local Distribution Companies'), findsOneWidget);

        // Test back navigation
        final backButton = find.widgetWithText(TextButton, 'Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));
        }

        // Test start over navigation
        final startOverButton = find.widgetWithText(TextButton, 'Start Over');
        if (startOverButton.evaluate().isNotEmpty) {
          await tester.tap(startOverButton);
          await tester.pumpAndSettle();
          expect(store.mainPath, equals(MainPath.selection));
          expect(store.selectedState, isEmpty);
          expect(store.selectedMandal, isEmpty);
        }

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('state flow handles rapid navigation correctly',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to state flow
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        // Rapidly select different states
        await tester.tap(find.text('Maharashtra'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Go back and select different state
        final backButton = find.widgetWithText(TextButton, 'Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delhi'));
        await tester.pumpAndSettle();

        // Verify Delhi is selected
        expect(store.selectedState, equals('delhi'));

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Complete Power Flow Loop', () {
      testWidgets('full power flow navigation loop works correctly',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to power flow
        final powerFlowButton =
            find.widgetWithText(ElevatedButton, 'Power Flow');
        if (powerFlowButton.evaluate().isNotEmpty) {
          await tester.tap(powerFlowButton);
          await tester.pumpAndSettle();
          expect(store.mainPath, equals(MainPath.powerFlow));
          expect(store.powerFlowStep, equals(PowerFlowStep.generator));
        }

        // Verify generator selection screen
        expect(find.byType(GeneratorSelectionScreen), findsOneWidget);
        expect(find.text('NTPC Limited'), findsOneWidget);

        // Select NTPC generator
        await tester.tap(find.text('NTPC Limited'));
        await tester.pumpAndSettle();

        // Verify generator profile screen
        expect(find.byType(GeneratorProfileScreen), findsOneWidget);
        expect(store.selectedGenerator, equals('ntpc'));
        expect(store.powerFlowStep, equals(PowerFlowStep.generatorProfile));

        // Navigate to transmission
        final nextButton = find.widgetWithText(TextButton, 'View Transmission');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(store.powerFlowStep, equals(PowerFlowStep.transmission));
        }

        // Verify transmission selection screen
        expect(find.byType(TransmissionSelectionScreen), findsOneWidget);
        expect(find.text('Power Grid Corporation'), findsOneWidget);

        // Select Power Grid transmission
        await tester.tap(find.text('Power Grid Corporation'));
        await tester.pumpAndSettle();

        // Verify transmission profile screen
        expect(find.byType(TransmissionProfileScreen), findsOneWidget);
        expect(store.selectedTransmission, equals('powergrid'));
        expect(store.powerFlowStep, equals(PowerFlowStep.transmissionProfile));

        // Navigate to distribution
        final nextTransmissionButton =
            find.widgetWithText(TextButton, 'View Distribution');
        if (nextTransmissionButton.evaluate().isNotEmpty) {
          await tester.tap(nextTransmissionButton);
          await tester.pumpAndSettle();
          expect(store.powerFlowStep, equals(PowerFlowStep.distribution));
        }

        // Verify distribution selection screen
        expect(find.byType(DistributionSelectionScreen), findsOneWidget);
        expect(
            find.text('Mumbai Electricity Supply & Transport'), findsOneWidget);

        // Select BEST distribution
        await tester.tap(find.text('Mumbai Electricity Supply & Transport'));
        await tester.pumpAndSettle();

        // Verify distribution profile screen
        expect(find.byType(DistributionProfileScreen), findsOneWidget);
        expect(store.selectedDistribution, equals('best'));
        expect(store.powerFlowStep, equals(PowerFlowStep.profile));

        // Test back navigation through power flow
        final backButton =
            find.widgetWithText(TextButton, 'Back to Distribution');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(store.powerFlowStep, equals(PowerFlowStep.distribution));
        }

        // Test start over
        final startOverButton = find.widgetWithText(TextButton, 'Start Over');
        if (startOverButton.evaluate().isNotEmpty) {
          await tester.tap(startOverButton);
          await tester.pumpAndSettle();
          expect(store.mainPath, equals(MainPath.selection));
          expect(store.selectedGenerator, isEmpty);
          expect(store.selectedTransmission, isEmpty);
          expect(store.selectedDistribution, isEmpty);
        }

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('power flow handles rapid navigation correctly',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to power flow
        final powerFlowButton =
            find.widgetWithText(ElevatedButton, 'Power Flow');
        if (powerFlowButton.evaluate().isNotEmpty) {
          await tester.tap(powerFlowButton);
          await tester.pumpAndSettle();
        }

        // Rapidly select different generators
        await tester.tap(find.text('NTPC Limited'));
        await tester.pumpAndSettle();

        // Go back and select different generator
        final backButton = find.widgetWithText(TextButton, 'Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const GeneratorSelectionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('NHPC Limited'));
        await tester.pumpAndSettle();

        // Verify NHPC is selected
        expect(store.selectedGenerator, equals('nhpc'));

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Cross Flow Navigation', () {
      testWidgets('switching between state flow and power flow works',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Start with state flow
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Maharashtra'));
        await tester.pumpAndSettle();

        // Switch to power flow
        final powerFlowButton =
            find.widgetWithText(ElevatedButton, 'Power Flow');
        if (powerFlowButton.evaluate().isNotEmpty) {
          await tester.tap(powerFlowButton);
          await tester.pumpAndSettle();
          expect(store.mainPath, equals(MainPath.powerFlow));
        }

        // Verify state flow selections are preserved
        expect(store.selectedState, equals('maharashtra'));
        expect(store.selectedMandal,
            isEmpty); // Should be reset when switching flows

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('state persistence across navigation works',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Set up state flow with selections
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Maharashtra'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mumbai City'));
        await tester.pumpAndSettle();

        // Switch to power flow and make selections
        final powerFlowButton =
            find.widgetWithText(ElevatedButton, 'Power Flow');
        if (powerFlowButton.evaluate().isNotEmpty) {
          await tester.tap(powerFlowButton);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('NTPC Limited'));
        await tester.pumpAndSettle();

        // Switch back to state flow
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        // Verify state flow selections are preserved
        expect(store.selectedState, equals('maharashtra'));
        expect(store.selectedMandal, equals('mumbai'));

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('handles invalid selections gracefully',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        // Create store with invalid selections
        final errorStore = StateInfoStore();
        errorStore.selectState('invalid_state');
        errorStore.selectMandal('invalid_mandal');
        errorStore.selectGenerator('invalid_generator');

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: errorStore,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to state flow
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: errorStore,
            child: const StateDetailScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify error state is displayed
        expect(find.text('State not found'), findsOneWidget);

        // Navigate to power flow
        final powerFlowButton =
            find.widgetWithText(ElevatedButton, 'Power Flow');
        if (powerFlowButton.evaluate().isNotEmpty) {
          await tester.tap(powerFlowButton);
          await tester.pumpAndSettle();
        }

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: errorStore,
            child: const GeneratorProfileScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify error state is displayed
        expect(find.text('Generator not found'), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles empty data gracefully', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        // Create empty store
        final emptyStore = StateInfoStore();
        await emptyStore.clearPersistedState();

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: emptyStore,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to state flow
        final stateFlowButton =
            find.widgetWithText(ElevatedButton, 'State Flow');
        if (stateFlowButton.evaluate().isNotEmpty) {
          await tester.tap(stateFlowButton);
          await tester.pumpAndSettle();
        }

        // Verify empty state is displayed
        expect(find.text('No states available'), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Performance Tests', () {
      testWidgets('handles rapid state changes without errors',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Rapidly change states
        for (int i = 0; i < 10; i++) {
          store.selectState('maharashtra');
          await tester.pumpAndSettle();

          store.selectState('delhi');
          await tester.pumpAndSettle();

          store.selectState('karnataka');
          await tester.pumpAndSettle();
        }

        // Verify no exceptions occurred
        expect(tester.takeException(), isNull);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles rapid navigation without memory leaks',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          IntegrationTestWrapper(
            store: store,
            child: const ComprehensiveStateInfoPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Rapidly navigate between flows
        for (int i = 0; i < 20; i++) {
          final stateFlowButton =
              find.widgetWithText(ElevatedButton, 'State Flow');
          if (stateFlowButton.evaluate().isNotEmpty) {
            await tester.tap(stateFlowButton);
            await tester.pumpAndSettle();
          }

          final powerFlowButton =
              find.widgetWithText(ElevatedButton, 'Power Flow');
          if (powerFlowButton.evaluate().isNotEmpty) {
            await tester.tap(powerFlowButton);
            await tester.pumpAndSettle();
          }
        }

        // Verify no exceptions occurred
        expect(tester.takeException(), isNull);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
