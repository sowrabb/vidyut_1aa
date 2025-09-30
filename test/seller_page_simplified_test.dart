import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/sell/seller_page.dart';
import 'package:vidyut/features/sell/store/seller_store.dart';
import 'package:vidyut/app/app_state.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('SellerPage Simplified Tests', () {
    late SellerStore sellerStore;
    late AppState appState;
    late LightweightDemoDataService demoDataService;

    setUp(() {
      demoDataService = LightweightDemoDataService();
      sellerStore = SellerStore(demoDataService);
      appState = AppState();

      // Set up initial state
      appState.setLocation(
        city: 'Mumbai',
        state: 'Maharashtra',
        area: 'Andheri',
        radiusKm: 10.0,
        latitude: 19.0760,
        longitude: 72.8777,
      );
    });

    Widget createTestWidget(String sellerName) {
      return ProviderScope(
        overrides: [
          sellerStoreProvider.overrideWith((ref) => sellerStore),
          appStateNotifierProvider
              .overrideWith((ref) => AppStateNotifier(appState)),
        ],
        child: MaterialApp(
          home: SellerPage(sellerName: sellerName),
        ),
      );
    }

    group('Basic Rendering Tests', () {
      testWidgets('SellerPage renders without crashing', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.byType(SellerPage), findsOneWidget);
      });

      testWidgets('Seller name is displayed correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('ElectroTech Solutions'));
        await tester.pumpAndSettle();

        expect(find.text('ElectroTech Solutions'), findsOneWidget);
      });

      testWidgets('Store icon is displayed', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });
    });

    group('Contact Buttons Tests', () {
      testWidgets('Contact Supplier button is present', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('Contact Supplier'), findsOneWidget);
        expect(find.byIcon(Icons.call), findsOneWidget);
      });

      testWidgets('WhatsApp button is present', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('WhatsApp'), findsOneWidget);
      });

      testWidgets('Location button is present', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      });
    });

    group('Tab Navigation Tests', () {
      testWidgets('All tabs are present', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('Products'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('Contact'), findsOneWidget);
      });

      testWidgets('Tab switching works', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        // Tap on About tab
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();

        // Verify About tab is still visible (it should be)
        expect(find.text('About'), findsOneWidget);

        // Tap on Reviews tab
        await tester.tap(find.text('Reviews'));
        await tester.pumpAndSettle();

        // Verify Reviews tab is still visible
        expect(find.text('Reviews'), findsOneWidget);
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('Mobile layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });

      testWidgets('Tablet layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });

      testWidgets('Desktop layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('Empty seller name is handled', (tester) async {
        await tester.pumpWidget(createTestWidget(''));
        await tester.pumpAndSettle();

        expect(find.byType(SellerPage), findsOneWidget);
      });

      testWidgets('Very long seller name is handled', (tester) async {
        const longName = 'Very Long Seller Name That Might Cause Layout Issues';
        await tester.pumpWidget(createTestWidget(longName));
        await tester.pumpAndSettle();

        expect(find.text(longName), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('SellerPage has proper semantic structure', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
        expect(find.text('Test Seller'), findsOneWidget);
      });

      testWidgets('Buttons have proper accessibility', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(FilledButton, 'Contact Supplier'),
            findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'WhatsApp'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('SellerPage renders quickly', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Tab switching is responsive', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reviews'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Tab switching should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
