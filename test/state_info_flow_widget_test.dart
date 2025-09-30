import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/features/stateinfo/store/state_info_store.dart';
import 'package:vidyut/features/stateinfo/widgets/state_flow_screens.dart';
import 'package:vidyut/features/stateinfo/widgets/power_flow_screens.dart';
import 'package:vidyut/features/stateinfo/models/state_info_models.dart';
import 'package:vidyut/features/stateinfo/pages/comprehensive_state_info_page.dart';
import 'package:vidyut/features/stateinfo/data/static_data.dart';
import 'package:vidyut/app/provider_registry.dart';

// Mock widget wrapper for testing
class TestWrapper extends StatelessWidget {
  final Widget child;
  final StateInfoStore? store;

  const TestWrapper({
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
  group('State Info Flow Widget Tests', () {
    late StateInfoStore store;

    setUp(() {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      store = StateInfoStore();
    });

    group('StatesSelectionScreen', () {
      testWidgets('displays states grid correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        // Verify progress indicator is displayed
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify states are displayed in grid
        final firstState = StateInfoStaticData.indianStates.first;
        expect(find.text(firstState.name), findsOneWidget);

        // Verify at least 4 states are displayed
        expect(find.byType(Card), findsAtLeastNWidgets(4));

        // Verify state cards show correct information
        expect(find.text('Capital: ${firstState.capital}'), findsOneWidget);

        // Verify DISCOMs information
        expect(find.text('${firstState.discoms} DISCOMs'), findsOneWidget);

        // Verify navigation buttons
        expect(find.byType(NavigationButtons), findsOneWidget);
      });

      testWidgets('handles state selection correctly',
          (WidgetTester tester) async {
        final firstState = StateInfoStaticData.indianStates.first;

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        // Tap on first state card
        await tester.tap(find.text(firstState.name));
        await tester.pumpAndSettle();

        // Verify state is selected and flow progresses
        expect(store.selectedState, equals(firstState.id));
        expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));
      });

      testWidgets('displays empty state when no states available',
          (WidgetTester tester) async {
        // Create a store with empty states list
        final emptyStore = StateInfoStore();
        // Mock empty states by clearing the data
        await emptyStore.clearPersistedState();

        await tester.pumpWidget(
          TestWrapper(
            store: emptyStore,
            child: const StatesSelectionScreen(),
          ),
        );

        // Verify empty state message
        expect(find.text('No states available'), findsOneWidget);
        expect(find.text('Please check back later or contact support'),
            findsOneWidget);
      });

      testWidgets('navigation buttons work correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        // Test back button - should always be present
        final backButton = find.widgetWithText(TextButton, 'Back');
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(store.mainPath, equals(MainPath.selection));

        // Test start over button - should always be present
        final startOverButton = find.widgetWithText(TextButton, 'Start Over');
        expect(startOverButton, findsOneWidget);
        await tester.tap(startOverButton);
        await tester.pumpAndSettle();
        expect(store.mainPath, equals(MainPath.selection));
      });
    });

    group('StateDetailScreen', () {
      testWidgets('displays state details correctly',
          (WidgetTester tester) async {
        // Set up store with first state selected
        final firstState = StateInfoStaticData.indianStates.first;
        store.selectState(firstState.id);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        // Verify progress indicator
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify state header
        expect(find.text(firstState.name), findsOneWidget);
        expect(find.text('Capital: ${firstState.capital}'), findsOneWidget);
        expect(find.text(firstState.powerCapacity), findsOneWidget);

        // Verify tab bar
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Administration'), findsOneWidget);
        expect(find.text('Energy Mix'), findsOneWidget);
        expect(find.text('Districts/Mandals'), findsOneWidget);
        expect(find.text('Product Design'), findsOneWidget);

        // Verify navigation buttons
        expect(find.byType(NavigationButtons), findsOneWidget);
      });

      testWidgets('displays error state when state not found',
          (WidgetTester tester) async {
        // Set up store with invalid state
        store.selectState('invalid_state');

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        // Verify error message
        expect(find.text('State not found'), findsOneWidget);
      });

      testWidgets('tab navigation works correctly',
          (WidgetTester tester) async {
        final firstState = StateInfoStaticData.indianStates.first;
        store.selectState(firstState.id);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        // Test tab switching
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();

        // Verify administration content is displayed
        expect(find.text('Chief Minister'), findsOneWidget);
        expect(find.text('Energy Minister'), findsOneWidget);

        await tester.tap(find.text('Energy Mix'));
        await tester.pumpAndSettle();

        // Verify energy mix content
        expect(find.text('Energy Mix Breakdown'), findsOneWidget);
        expect(find.text('Thermal'), findsOneWidget);
        expect(find.text('Hydro'), findsOneWidget);
      });

      testWidgets('districts tab shows mandals correctly',
          (WidgetTester tester) async {
        final firstState = StateInfoStaticData.indianStates.first;
        store.selectState(firstState.id);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        // Switch to districts tab
        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        // Verify mandals are displayed
        expect(find.text('Mumbai City'), findsOneWidget);
        expect(find.text('Pune'), findsOneWidget);
        expect(find.text('Nagpur'), findsOneWidget);
        expect(find.text('Nashik'), findsOneWidget);
        expect(find.text('Aurangabad'), findsOneWidget);

        // Verify mandal information
        expect(find.text('12.5 Million'), findsOneWidget); // Mumbai population
        expect(find.text('2,800 MW'), findsOneWidget); // Mumbai power demand
      });
    });

    group('MandalDetailScreen', () {
      testWidgets('displays mandal details correctly',
          (WidgetTester tester) async {
        // Set up store with first state and first mandal selected
        final firstState = StateInfoStaticData.indianStates.first;
        final firstMandal = firstState.mandals.first;
        store.selectState(firstState.id);
        store.selectMandal(firstMandal.id);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        // Verify progress indicator
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify mandal header
        expect(find.text(firstMandal.name), findsOneWidget);
        expect(find.text(firstState.name), findsOneWidget);
        expect(find.text(firstMandal.population), findsOneWidget); // Population
        expect(
            find.text(firstMandal.powerDemand), findsOneWidget); // Power demand

        // Verify tab bar
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Administration'), findsOneWidget);
        expect(find.text('Local DISCOMs'), findsOneWidget);

        // Verify navigation buttons
        expect(find.byType(NavigationButtons), findsOneWidget);
      });

      testWidgets('displays error state when mandal not found',
          (WidgetTester tester) async {
        // Set up store with invalid mandal
        final firstState = StateInfoStaticData.indianStates.first;
        store.selectState(firstState.id);
        store.selectMandal('invalid_mandal');

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        // Verify error message
        expect(find.text('Mandal or State not found'), findsOneWidget);
      });

      testWidgets('tab navigation works correctly',
          (WidgetTester tester) async {
        final firstState = StateInfoStaticData.indianStates.first;
        final firstMandal = firstState.mandals.first;
        store.selectState(firstState.id);
        store.selectMandal(firstMandal.id);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        // Test tab switching
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();

        // Verify administration content
        expect(find.text('Division Controller'), findsOneWidget);
        expect(find.text('Contact Information'), findsOneWidget);

        await tester.tap(find.text('Local DISCOMs'));
        await tester.pumpAndSettle();

        // Verify DISCOMs content
        expect(find.text('Local Distribution Companies'), findsOneWidget);
        expect(find.text('BEST'), findsOneWidget);
        expect(find.text('Adani Electricity'), findsOneWidget);
      });
    });

    group('Power Flow Screens', () {
      testWidgets('GeneratorSelectionScreen displays generators correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const GeneratorSelectionScreen(),
          ),
        );

        // Verify progress indicator
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify generators are displayed
        expect(find.text('NTPC Limited'), findsOneWidget);
        expect(find.text('NHPC Limited'), findsOneWidget);
        expect(find.text('Nuclear Power Corporation'), findsOneWidget);
        expect(find.text('Adani Power'), findsOneWidget);
        expect(find.text('Tata Power'), findsOneWidget);

        // Verify generator details
        expect(find.text('Thermal - 65,810 MW'), findsOneWidget);
        expect(find.text('Hydro - 7,071 MW'), findsOneWidget);
        expect(find.text('Nuclear - 6,780 MW'), findsOneWidget);
      });

      testWidgets(
          'TransmissionSelectionScreen displays transmission lines correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const TransmissionSelectionScreen(),
          ),
        );

        // Verify progress indicator
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify transmission lines are displayed
        expect(find.text('Power Grid Corporation'), findsOneWidget);
        expect(find.text('State Transmission Utility'), findsOneWidget);
        expect(find.text('Regional Grid'), findsOneWidget);

        // Verify transmission details
        expect(find.text('765 kV - National'), findsOneWidget);
        expect(find.text('400 kV - State'), findsOneWidget);
        expect(find.text('220 kV - Regional'), findsOneWidget);
      });

      testWidgets(
          'DistributionSelectionScreen displays distribution companies correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const DistributionSelectionScreen(),
          ),
        );

        // Verify progress indicator
        expect(find.byType(StateProgressIndicator), findsOneWidget);

        // Verify distribution companies are displayed
        expect(
            find.text('Mumbai Electricity Supply & Transport'), findsOneWidget);
        expect(find.text('Delhi Electricity Regulatory Commission'),
            findsOneWidget);

        // Verify distribution details
        expect(find.text('3.2 Million'), findsOneWidget); // BEST customers
        expect(find.text('7.5 Million'), findsOneWidget); // DERC customers
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets('complete state flow navigation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        // Start with states selection
        expect(store.stateFlowStep, equals(StateFlowStep.states));

        // Select first state
        final firstState = StateInfoStaticData.indianStates.first;
        await tester.tap(find.text(firstState.name));
        await tester.pumpAndSettle();
        expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));

        // Navigate to mandal detail
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mumbai City'));
        await tester.pumpAndSettle();
        expect(store.stateFlowStep, equals(StateFlowStep.mandalDetail));

        // Verify back navigation
        final backButton = find.widgetWithText(TextButton, 'Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(store.stateFlowStep, equals(StateFlowStep.stateDetail));
        }
      });

      testWidgets('power flow navigation works correctly',
          (WidgetTester tester) async {
        // Set power flow path
        store.selectPath(MainPath.powerFlow);

        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const GeneratorSelectionScreen(),
          ),
        );

        // Start with generator selection
        expect(store.powerFlowStep, equals(PowerFlowStep.generator));

        // Select NTPC generator
        await tester.tap(find.text('NTPC Limited'));
        await tester.pumpAndSettle();
        expect(store.powerFlowStep, equals(PowerFlowStep.generatorProfile));

        // Navigate to transmission
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const GeneratorProfileScreen(),
          ),
        );

        final nextButton = find.widgetWithText(TextButton, 'View Transmission');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(store.powerFlowStep, equals(PowerFlowStep.transmission));
        }
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles null selected data gracefully',
          (WidgetTester tester) async {
        // Create store with invalid selections
        final errorStore = StateInfoStore();
        errorStore.selectState('invalid_state');

        await tester.pumpWidget(
          TestWrapper(
            store: errorStore,
            child: const StateDetailScreen(),
          ),
        );

        // Verify error state is displayed
        expect(find.text('State not found'), findsOneWidget);
        expect(
            find.text('Please select a state from the list'), findsOneWidget);
      });

      testWidgets('handles empty data lists gracefully',
          (WidgetTester tester) async {
        // Test with empty generators list
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const GeneratorSelectionScreen(),
          ),
        );

        // Should not throw exceptions even with empty data
        expect(find.byType(GeneratorSelectionScreen), findsOneWidget);
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('adapts to different screen sizes',
          (WidgetTester tester) async {
        // Test mobile size
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(
          TestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        expect(find.byType(StatesSelectionScreen), findsOneWidget);

        // Test tablet size
        await tester.binding.setSurfaceSize(const Size(834, 1194));
        await tester.pumpAndSettle();

        expect(find.byType(StatesSelectionScreen), findsOneWidget);

        // Test desktop size
        await tester.binding.setSurfaceSize(const Size(1440, 900));
        await tester.pumpAndSettle();

        expect(find.byType(StatesSelectionScreen), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
