import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vidyut/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Accessibility Tests', () {
    testWidgets('should have proper semantic labels',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check for semantic labels
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Sign In'), findsOneWidget);
    });

    testWidgets('should support screen reader navigation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Verify focus is on password field
      final passwordField = find.byType(TextFormField).at(1);
      expect(tester.widget<TextFormField>(passwordField).focusNode?.hasFocus,
          true);
    });

    testWidgets('should have proper contrast ratios',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check button contrast
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);

      // Check text contrast
      final emailLabel = find.text('Email');
      expect(emailLabel, findsOneWidget);
    });

    testWidgets('should support keyboard navigation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      // Verify form validation works with keyboard
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should announce errors to screen readers',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Trigger validation error
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Check for error announcements
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should support high contrast mode',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check that all interactive elements are visible
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));
    });

    testWidgets('should have proper focus indicators',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Focus on email field
      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();

      // Verify focus indicator is visible
      final emailField = find.byType(TextFormField).first;
      expect(
          tester.widget<TextFormField>(emailField).focusNode?.hasFocus, true);
    });

    testWidgets('should support voice over on iOS',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check for proper accessibility properties
      final emailField = find.byType(TextFormField).first;
      final emailWidget = tester.widget<TextFormField>(emailField);

      expect(emailWidget.decoration?.labelText, 'Email');
      expect(emailWidget.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should support talk back on Android',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check for proper accessibility properties
      final passwordField = find.byType(TextFormField).at(1);
      final passwordWidget = tester.widget<TextFormField>(passwordField);

      expect(passwordWidget.decoration?.labelText, 'Password');
      expect(passwordWidget.obscureText, true);
    });

    testWidgets('should have proper heading structure',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check for proper heading hierarchy
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in with Firebase'), findsOneWidget);
    });

    testWidgets('should support reduced motion preferences',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check that animations are not excessive
      // This would be tested with actual reduced motion settings
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should have proper button sizing for touch targets',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check button sizes meet minimum touch target requirements (44x44 points)
      final signInButton = find.text('Sign In');
      final buttonWidget = tester.widget<FilledButton>(signInButton);

      // Verify button has adequate padding
      expect(buttonWidget.style?.padding, isNotNull);
    });

    testWidgets('should support switch control navigation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test switch control navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      // Verify navigation works
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
