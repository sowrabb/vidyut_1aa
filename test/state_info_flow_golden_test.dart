import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/stateinfo/store/state_info_store.dart';
import 'package:vidyut/features/stateinfo/widgets/state_flow_screens.dart';
import 'package:vidyut/features/stateinfo/widgets/power_flow_screens.dart';
import 'package:vidyut/app/provider_registry.dart';

// Mock widget wrapper for golden tests
class GoldenTestWrapper extends StatelessWidget {
  final Widget child;
  final StateInfoStore? store;

  const GoldenTestWrapper({
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
  group('State Info Flow Golden Tests', () {
    late StateInfoStore store;

    setUp(() {
      store = StateInfoStore();
    });

    group('States Selection Screen', () {
      testWidgets('states selection screen mobile',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/states_selection_mobile.png'),
        );
      });

      testWidgets('states selection screen tablet',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(834, 1194));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/states_selection_tablet.png'),
        );
      });

      testWidgets('states selection screen desktop',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1440, 900));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/states_selection_desktop.png'),
        );
      });

      testWidgets('states selection empty state', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        // Create empty store
        final emptyStore = StateInfoStore();
        await emptyStore.clearPersistedState();

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: emptyStore,
            child: const StatesSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/states_selection_empty.png'),
        );
      });
    });

    group('State Detail Screen', () {
      testWidgets('state detail screen overview tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_overview_mobile.png'),
        );
      });

      testWidgets('state detail screen administration tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to administration tab
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_administration_mobile.png'),
        );
      });

      testWidgets('state detail screen energy mix tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to energy mix tab
        await tester.tap(find.text('Energy Mix'));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_energy_mix_mobile.png'),
        );
      });

      testWidgets('state detail screen districts tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to districts tab
        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_districts_mobile.png'),
        );
      });

      testWidgets('state detail screen error state',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('invalid_state');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_error_mobile.png'),
        );
      });

      testWidgets('state detail screen desktop layout',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1440, 900));

        store.selectState('maharashtra');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/state_detail_overview_desktop.png'),
        );
      });
    });

    group('Mandal Detail Screen', () {
      testWidgets('mandal detail screen overview tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');
        store.selectMandal('mumbai');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MandalDetailScreen),
          matchesGoldenFile('golden/mandal_detail_overview_mobile.png'),
        );
      });

      testWidgets('mandal detail screen administration tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');
        store.selectMandal('mumbai');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to administration tab
        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MandalDetailScreen),
          matchesGoldenFile('golden/mandal_detail_administration_mobile.png'),
        );
      });

      testWidgets('mandal detail screen discoms tab',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');
        store.selectMandal('mumbai');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to discoms tab
        await tester.tap(find.text('Local DISCOMs'));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MandalDetailScreen),
          matchesGoldenFile('golden/mandal_detail_discoms_mobile.png'),
        );
      });

      testWidgets('mandal detail screen error state',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectState('maharashtra');
        store.selectMandal('invalid_mandal');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MandalDetailScreen),
          matchesGoldenFile('golden/mandal_detail_error_mobile.png'),
        );
      });
    });

    group('Power Flow Screens', () {
      testWidgets('generator selection screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const GeneratorSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(GeneratorSelectionScreen),
          matchesGoldenFile('golden/generator_selection_mobile.png'),
        );
      });

      testWidgets('transmission selection screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const TransmissionSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TransmissionSelectionScreen),
          matchesGoldenFile('golden/transmission_selection_mobile.png'),
        );
      });

      testWidgets('distribution selection screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const DistributionSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(DistributionSelectionScreen),
          matchesGoldenFile('golden/distribution_selection_mobile.png'),
        );
      });

      testWidgets('generator profile screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectGenerator('ntpc');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const GeneratorProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(GeneratorProfileScreen),
          matchesGoldenFile('golden/generator_profile_mobile.png'),
        );
      });

      testWidgets('transmission profile screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectTransmission('powergrid');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const TransmissionProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TransmissionProfileScreen),
          matchesGoldenFile('golden/transmission_profile_mobile.png'),
        );
      });

      testWidgets('distribution profile screen', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectDistribution('best');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const DistributionProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(DistributionProfileScreen),
          matchesGoldenFile('golden/distribution_profile_mobile.png'),
        );
      });
    });

    group('Navigation Flow Golden Tests', () {
      testWidgets('complete navigation flow sequence',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        // Start with states selection
        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/navigation_flow_1_states_selection.png'),
        );

        // Select Maharashtra and navigate to state detail
        await tester.tap(find.text('Maharashtra'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StateDetailScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StateDetailScreen),
          matchesGoldenFile('golden/navigation_flow_2_state_detail.png'),
        );

        // Navigate to districts tab and select Mumbai
        await tester.tap(find.text('Districts/Mandals'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mumbai City'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const MandalDetailScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MandalDetailScreen),
          matchesGoldenFile('golden/navigation_flow_3_mandal_detail.png'),
        );
      });
    });

    group('Error States Golden Tests', () {
      testWidgets('generator profile error state', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectGenerator('invalid_generator');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const GeneratorProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(GeneratorProfileScreen),
          matchesGoldenFile('golden/generator_profile_error.png'),
        );
      });

      testWidgets('transmission profile error state',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectTransmission('invalid_transmission');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const TransmissionProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TransmissionProfileScreen),
          matchesGoldenFile('golden/transmission_profile_error.png'),
        );
      });

      testWidgets('distribution profile error state',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        store.selectDistribution('invalid_distribution');

        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const DistributionProfileScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(DistributionProfileScreen),
          matchesGoldenFile('golden/distribution_profile_error.png'),
        );
      });
    });

    group('Responsive Layout Golden Tests', () {
      testWidgets('states selection responsive layouts',
          (WidgetTester tester) async {
        // Mobile portrait
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(
          GoldenTestWrapper(
            store: store,
            child: const StatesSelectionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/responsive_states_mobile_portrait.png'),
        );

        // Mobile landscape
        await tester.binding.setSurfaceSize(const Size(812, 375));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/responsive_states_mobile_landscape.png'),
        );

        // Tablet
        await tester.binding.setSurfaceSize(const Size(834, 1194));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/responsive_states_tablet.png'),
        );

        // Desktop
        await tester.binding.setSurfaceSize(const Size(1440, 900));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StatesSelectionScreen),
          matchesGoldenFile('golden/responsive_states_desktop.png'),
        );

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
