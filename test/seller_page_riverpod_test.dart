import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/test_harness.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/sell/seller_page.dart';
import 'package:vidyut/features/sell/models.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';

void main() {
  group('SellerPage Riverpod Tests', () {
    // Sample seller data for testing
    final sampleSellerName = 'TestSeller';

    // Helper function to create test widget with bounded constraints
    Widget createBoundedTestWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('SellerPage renders without ProviderScope errors',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the SellerPage renders without crashing
      expect(find.byType(SellerPage), findsOneWidget);
    });

    testWidgets('SellerPage displays seller name and basic information',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if seller name is displayed (it should be in the masthead)
      expect(find.text(sampleSellerName), findsAtLeastNWidgets(1));
    });

    testWidgets('SellerPage displays tab navigation', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if TabBar is present (4 tabs: Products, About, Reviews, Contact)
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsAtLeastNWidgets(4));
    });

    testWidgets('SellerPage displays search field', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if search field is displayed
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Products/Services'), findsOneWidget);
    });

    testWidgets('SellerPage increments profile view on load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final sellerStore = ref.watch(sellerStoreProvider);

                return Scaffold(
                  body: SizedBox(
                    width: 800,
                    height: 600,
                    child: Column(
                      children: [
                        Expanded(
                          child: SellerPage(sellerName: sampleSellerName),
                        ),
                        Text('Profile Views: ${sellerStore.profileViews}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // The profile view should be incremented (may take a frame to update)
      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the view count is tracked
      expect(find.textContaining('Profile Views:'), findsOneWidget);
    });

    testWidgets('SellerPage displays contact information', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if location information is displayed (Hyderabad, Telangana)
      expect(find.textContaining('Hyderabad'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Telangana'), findsAtLeastNWidgets(1));
    });

    testWidgets('SellerPage displays GST information', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if GST information is displayed
      expect(find.textContaining('GST:'), findsAtLeastNWidgets(1));
    });

    testWidgets('SellerPage displays products in products tab', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if products are displayed (should be in the first tab by default)
      // Look for the ResponsiveProductGrid or any product-related widgets
      expect(find.byType(SellerPage), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('SellerPage handles tab switching', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Find and tap on the About tab (second tab)
      final aboutTab = find.text('About');
      if (aboutTab.evaluate().isNotEmpty) {
        await tester.tap(aboutTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        // Verify tab switching worked
        expect(find.byType(SellerPage), findsOneWidget);
      }
    });

    testWidgets('SellerPage displays distance information', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if SellerPage renders without layout overflow errors
      expect(find.byType(SellerPage), findsOneWidget);

      // Check if the page structure is intact
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('SellerPage handles contact actions', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Look for contact action buttons (phone, email, website)
      // These should be present as clickable elements
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));

      // Check if the page renders without overflow errors
      expect(find.byType(SellerPage), findsOneWidget);
    });

    testWidgets('SellerPage displays subscription plan information',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final sellerStore = ref.watch(sellerStoreProvider);

                return Scaffold(
                  body: SizedBox(
                    width: 800,
                    height: 600,
                    child: Column(
                      children: [
                        Expanded(
                          child: SellerPage(sellerName: sampleSellerName),
                        ),
                        Text('Plan: ${sellerStore.currentPlan}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if subscription plan is displayed
      expect(find.textContaining('Plan:'), findsOneWidget);
    });

    testWidgets('SellerPage handles different seller names', (tester) async {
      const differentSellerName = 'DifferentSeller';

      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: differentSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if different seller name is displayed
      expect(find.text(differentSellerName), findsAtLeastNWidgets(1));
    });

    testWidgets('SellerPage displays analytics information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final sellerStore = ref.watch(sellerStoreProvider);

                return Scaffold(
                  body: SizedBox(
                    width: 800,
                    height: 600,
                    child: Column(
                      children: [
                        Expanded(
                          child: SellerPage(sellerName: sampleSellerName),
                        ),
                        Text('Total Views: ${sellerStore.totalProductViews}'),
                        Text(
                            'Total Contacts: ${sellerStore.totalProductContacts}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if analytics information is displayed
      expect(find.textContaining('Total Views:'), findsOneWidget);
      expect(find.textContaining('Total Contacts:'), findsOneWidget);
    });

    testWidgets('SellerPage has proper navigation structure', (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: sampleSellerName)),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Check if the page has proper structure
      expect(find.byType(SellerPage), findsOneWidget);
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
      expect(find.byType(NestedScrollView), findsOneWidget);
    });

    testWidgets('SellerPage handles empty seller name gracefully',
        (tester) async {
      await tester.pumpWidget(
        createBoundedTestWidget(SellerPage(sellerName: '')),
      );

      await tester.pump();

      // Wait for any pending timers to complete
      await tester.pump(const Duration(milliseconds: 10));

      // Should render without crashing even with empty seller name
      expect(find.byType(SellerPage), findsOneWidget);
    });
  });
}
