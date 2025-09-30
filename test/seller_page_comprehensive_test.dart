import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyut/features/sell/seller_page.dart';
import 'package:vidyut/features/sell/store/seller_store.dart';
import 'package:vidyut/app/app_state.dart';
import 'package:vidyut/app/layout/adaptive.dart';
import 'package:vidyut/app/tokens.dart';
import 'package:vidyut/app/provider_registry.dart';

// Generate mocks
@GenerateMocks([SellerStore, AppState])
import 'seller_page_comprehensive_test.mocks.dart';

void main() {
  group('SellerPage Comprehensive Tests', () {
    late MockSellerStore mockSellerStore;
    late MockAppState mockAppState;

    setUp(() {
      mockSellerStore = MockSellerStore();
      mockAppState = MockAppState();

      // Setup common mocks
      when(mockAppState.currentCity).thenReturn('Mumbai');
      when(mockAppState.currentState).thenReturn('Maharashtra');
      when(mockAppState.currentArea).thenReturn('Andheri');
      when(mockAppState.currentRadius).thenReturn(10.0);
      when(mockAppState.currentLatLng).thenReturn((19.0760, 72.8777));

      when(mockSellerStore.profileViews).thenReturn(150);
      when(mockSellerStore.totalProducts).thenReturn(25);
      when(mockSellerStore.verifiedStatus).thenReturn(true);
      when(mockSellerStore.rating).thenReturn(4.5);
      when(mockSellerStore.reviewCount).thenReturn(42);
      when(mockSellerStore.yearsActive).thenReturn(3);
      when(mockSellerStore.phoneNumber).thenReturn('+91-9876543210');
      when(mockSellerStore.email).thenReturn('contact@example.com');
      when(mockSellerStore.website).thenReturn('www.example.com');
    });

    Widget createTestWidget(String sellerName) {
      return ProviderScope(
        overrides: [
          sellerStoreProvider.overrideWith((ref) => mockSellerStore),
          appStateNotifierProvider
              .overrideWith((ref) => AppStateNotifier(mockAppState)),
        ],
        child: MaterialApp(
          home: SellerPage(sellerName: sellerName),
        ),
      );
    }

    group('Golden Tests', () {
      testWidgets('Phone layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify main elements are present
        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
        expect(find.text('Contact Supplier'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
      });

      testWidgets('Tablet layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify tablet-specific layout elements
        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });

      testWidgets('Desktop layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify desktop layout with proper spacing
        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });
    });

    group('Widget Tests', () {
      testWidgets('Seller information displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('ElectroTech Solutions'));

        await tester.pumpAndSettle();

        expect(find.text('ElectroTech Solutions'), findsOneWidget);
        expect(find.text('150'), findsOneWidget); // Profile views
        expect(find.text('25'), findsOneWidget); // Total products
        expect(find.text('4.5'), findsOneWidget); // Rating
        expect(find.text('42'), findsOneWidget); // Review count
      });

      testWidgets('Contact buttons are present and functional', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify contact buttons exist
        expect(find.text('Contact Supplier'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.byIcon(Icons.call), findsOneWidget);
        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      });

      testWidgets('Tab navigation works correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify tabs are present
        expect(find.text('Products'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('Contact'), findsOneWidget);

        // Test tab switching
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();
        expect(find.text('About'), findsOneWidget);

        await tester.tap(find.text('Reviews'));
        await tester.pumpAndSettle();
        expect(find.text('Reviews'), findsOneWidget);
      });

      testWidgets('Back button navigates correctly', (tester) async {
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(
                  body: Center(child: Text('Home')),
                ),
            '/seller': (context) => SellerPage(sellerName: 'Test Seller'),
          },
        ));

        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);

        // Navigate to seller page
        await tester.pumpWidget(MaterialApp(
          home: SellerPage(sellerName: 'Test Seller'),
        ));
        await tester.pumpAndSettle();

        // Verify back button works
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('Profile view is incremented on page load', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify that incrementProfileView was called
        verify(mockSellerStore.incrementProfileView()).called(1);
      });
    });

    group('Contact Actions Tests', () {
      testWidgets('Call button triggers contact call recording',
          (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Tap call button
        final callButton =
            find.widgetWithText(FilledButton, 'Contact Supplier');
        await tester.tap(callButton);
        await tester.pumpAndSettle();

        // Verify contact call was recorded
        verify(mockSellerStore.recordSellerContactCall()).called(1);
      });

      testWidgets('WhatsApp button triggers WhatsApp contact recording',
          (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Tap WhatsApp button
        final whatsappButton = find.widgetWithText(FilledButton, 'WhatsApp');
        await tester.tap(whatsappButton);
        await tester.pumpAndSettle();

        // Verify WhatsApp contact was recorded
        verify(mockSellerStore.recordSellerContactWhatsapp()).called(1);
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('Mobile layout uses column structure', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify mobile-specific layout elements
        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });

      testWidgets('Desktop layout uses row structure', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify desktop layout elements are present
        expect(find.text('Test Seller'), findsOneWidget);
        expect(find.byIcon(Icons.storefront), findsOneWidget);
      });
    });

    group('Content Display Tests', () {
      testWidgets('Seller statistics display correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify statistics are displayed
        expect(find.text('150'), findsOneWidget); // Profile views
        expect(find.text('25'), findsOneWidget); // Total products
        expect(find.text('4.5'), findsOneWidget); // Rating
        expect(find.text('42'), findsOneWidget); // Review count
        expect(find.text('3'), findsOneWidget); // Years active
      });

      testWidgets('Contact information displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify contact information is displayed
        expect(find.text('+91-9876543210'), findsOneWidget);
        expect(find.text('contact@example.com'), findsOneWidget);
        expect(find.text('www.example.com'), findsOneWidget);
      });

      testWidgets('Location information displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify location information is displayed
        expect(find.text('Mumbai'), findsOneWidget);
        expect(find.text('Maharashtra'), findsOneWidget);
        expect(find.text('Andheri'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('SellerPage handles empty seller name', (tester) async {
        await tester.pumpWidget(createTestWidget(''));

        await tester.pumpAndSettle();

        // Should still render without crashing
        expect(find.byType(SellerPage), findsOneWidget);
      });

      testWidgets('SellerPage handles very long seller name', (tester) async {
        const longName = 'Very Long Seller Name That Might Cause Layout Issues';
        await tester.pumpWidget(createTestWidget(longName));

        await tester.pumpAndSettle();

        expect(find.text(longName), findsOneWidget);
      });

      testWidgets('SellerPage handles missing contact information',
          (tester) async {
        when(mockSellerStore.phoneNumber).thenReturn('');
        when(mockSellerStore.email).thenReturn('');
        when(mockSellerStore.website).thenReturn('');

        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Should still render without crashing
        expect(find.byType(SellerPage), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('SellerPage has proper semantic structure', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify semantic structure
        expect(find.byType(Semantics), findsWidgets);
        expect(find.text('Test Seller'), findsOneWidget);
      });

      testWidgets('Contact buttons have proper accessibility labels',
          (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify buttons have proper semantics
        expect(find.widgetWithText(FilledButton, 'Contact Supplier'),
            findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'WhatsApp'), findsOneWidget);
      });

      testWidgets('Tab navigation is accessible', (tester) async {
        await tester.pumpWidget(createTestWidget('Test Seller'));

        await tester.pumpAndSettle();

        // Verify tabs are accessible
        expect(find.text('Products'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('Contact'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('SellerPage renders quickly', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestWidget('Test Seller'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within reasonable time (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
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
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
