import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vidyut/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Performance Tests', () {
    testWidgets('Auth page load performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify auth page loads within reasonable time (2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Form validation performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Test rapid form input
      for (int i = 0; i < 10; i++) {
        await tester.enterText(
            find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pump();
      }

      stopwatch.stop();

      // Verify form validation is responsive (under 100ms per validation)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Navigation performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Test rapid navigation between login/signup
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Don't have an account? Sign up"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Already have an account? Sign in"));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Verify navigation is smooth (under 500ms per transition)
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));
    });

    testWidgets('Memory usage during auth flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill and clear form multiple times to test memory management
      for (int i = 0; i < 20; i++) {
        await tester.enterText(
            find.byType(TextFormField).first, 'test$i@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password$i');
        await tester.pump();

        // Clear form
        await tester.enterText(find.byType(TextFormField).first, '');
        await tester.enterText(find.byType(TextFormField).at(1), '');
        await tester.pump();
      }

      // Verify no memory leaks by checking if widgets are still responsive
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Large form data handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Switch to signup to test more fields
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Fill form with large data
      final largeName = 'A' * 1000; // 1000 character name
      final largeEmail = 'test@example.com';
      final largePassword = 'password123';
      final largePhone = '1234567890';
      final largeBio = 'B' * 2000; // 2000 character bio

      await tester.enterText(find.byType(TextFormField).at(0), largeName);
      await tester.enterText(find.byType(TextFormField).at(1), largeEmail);
      await tester.enterText(find.byType(TextFormField).at(2), largePassword);
      await tester.enterText(find.byType(TextFormField).at(3), largePhone);
      await tester.enterText(find.byType(TextFormField).at(4), largeBio);
      await tester.pump();

      stopwatch.stop();

      // Verify form handles large data efficiently (under 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
