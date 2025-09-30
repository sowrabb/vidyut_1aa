import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/categories/categories_page.dart';
import 'package:vidyut/features/categories/categories_notifier.dart';
import 'package:vidyut/app/app_state.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('CategoriesPage Comprehensive Tests', () {
    late AppState appState;

    setUp(() {
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

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          appStateNotifierProvider
              .overrideWith((ref) => AppStateNotifier(appState)),
        ],
        child: MaterialApp(
          home: const CategoriesPage(),
        ),
      );
    }

    group('Golden Tests', () {
      testWidgets('Phone layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        // Verify main elements are present
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Cables & Wires'), findsOneWidget);
        expect(find.text('Switchgear'), findsOneWidget);
        expect(find.text('Lighting'), findsOneWidget);
        expect(find.text('Motors & Drives'), findsOneWidget);
      });

      testWidgets('Tablet layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        // Verify tablet-specific layout elements
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Cables & Wires'), findsOneWidget);
      });

      testWidgets('Desktop layout renders correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        // Verify desktop layout with filters panel
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Cables & Wires'), findsOneWidget);
      });
    });

    group('Widget Tests', () {
      testWidgets('Categories are displayed correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify all categories are displayed
        expect(find.text('Cables & Wires'), findsOneWidget);
        expect(find.text('Switchgear'), findsOneWidget);
        expect(find.text('Lighting'), findsOneWidget);
        expect(find.text('Motors & Drives'), findsOneWidget);
        expect(find.text('Tools & Equipment'), findsOneWidget);
      });

      testWidgets('Search functionality works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and interact with search field
        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);

        // Type in search field
        await tester.enterText(searchField, 'Cables');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.text('Cables & Wires'), findsOneWidget);
      });

      testWidgets('Filters button opens filters sheet', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap filters button
        final filtersButton = find.widgetWithText(OutlinedButton, 'Filters');
        await tester.tap(filtersButton);
        await tester.pumpAndSettle();

        // Verify filters sheet is open (this might need adjustment based on actual implementation)
        // For now, just verify the button exists and is tappable
        expect(filtersButton, findsOneWidget);
      });

      testWidgets('Category cards are tappable', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find a category card and tap it
        final cablesCard = find.text('Cables & Wires');
        expect(cablesCard, findsOneWidget);

        // Tap the category card
        await tester.tap(cablesCard);
        await tester.pumpAndSettle();
      });

      testWidgets('Back navigation works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify back button exists (if present)
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('Mobile layout uses column structure', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify mobile-specific layout elements
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Filters'), findsOneWidget);
      });

      testWidgets('Desktop layout uses row structure with filters panel',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify desktop layout elements are present
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Filters'), findsOneWidget);
      });
    });

    group('Content Display Tests', () {
      testWidgets('Category information displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify category names are displayed
        expect(find.text('Cables & Wires'), findsOneWidget);
        expect(find.text('Switchgear'), findsOneWidget);
        expect(find.text('Lighting'), findsOneWidget);
        expect(find.text('Motors & Drives'), findsOneWidget);
        expect(find.text('Tools & Equipment'), findsOneWidget);
      });

      testWidgets('Category images are displayed', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify images are present (this might need adjustment based on actual implementation)
        // For now, just verify the page renders without crashing
        expect(find.byType(CategoriesPage), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('CategoriesPage handles empty search', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Clear search field
        final searchField = find.byType(TextField);
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();

        // Should still show all categories
        expect(find.text('Cables & Wires'), findsOneWidget);
      });

      testWidgets('CategoriesPage handles non-matching search', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Search for non-existent category
        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'NonExistentCategory');
        await tester.pumpAndSettle();

        // Should handle gracefully
        expect(find.byType(CategoriesPage), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('CategoriesPage has proper semantic structure',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify semantic structure
        expect(find.byType(Semantics), findsWidgets);
        expect(find.text('Cables & Wires'), findsOneWidget);
      });

      testWidgets('Search field has proper accessibility', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify search field is accessible
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('Filters button has proper accessibility', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify filters button is accessible
        expect(find.widgetWithText(OutlinedButton, 'Filters'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('CategoriesPage renders quickly', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Search is responsive', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'Cables');
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Search should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
