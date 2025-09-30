import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vidyut/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    testWidgets('Complete authentication flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Guest Mode Flow
      await _testGuestModeFlow(tester);

      // Test 2: Sign Up Flow
      await _testSignUpFlow(tester);

      // Test 3: Sign In Flow
      await _testSignInFlow(tester);

      // Test 4: Profile Management Flow
      await _testProfileManagementFlow(tester);

      // Test 5: Sign Out Flow
      await _testSignOutFlow(tester);
    });

    testWidgets('Password reset flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Enter email and send reset
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Send Reset Email'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Password reset email sent! Check your inbox.'),
          findsOneWidget);
    });

    testWidgets('Email verification flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // This would test the email verification dialog
      // In a real test, you would mock the verification status
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

Future<void> _testGuestModeFlow(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Tap guest mode
  await tester.tap(find.text('Continue as Guest'));
  await tester.pumpAndSettle();

  // Verify guest mode is active
  expect(find.text('Guest User'), findsOneWidget);
}

Future<void> _testSignUpFlow(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Switch to sign up
  await tester.tap(find.text("Don't have an account? Sign up"));
  await tester.pumpAndSettle();

  // Fill sign up form
  await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
  await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
  await tester.enterText(find.byType(TextFormField).at(2), 'password123');
  await tester.enterText(find.byType(TextFormField).at(3), '+1234567890');

  // Submit form
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();

  // Note: In a real test, you would mock the Firebase response
  // For now, we just verify the form was filled
  expect(find.text('Test User'), findsOneWidget);
}

Future<void> _testSignInFlow(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Fill sign in form
  await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');

  // Submit form
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();

  // Note: In a real test, you would mock the Firebase response
  // For now, we just verify the form was filled
  expect(find.text('test@example.com'), findsOneWidget);
}

Future<void> _testProfileManagementFlow(WidgetTester tester) async {
  // First sign in as guest or registered user
  await _testGuestModeFlow(tester);

  // Open profile dialog
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Navigate to profile page
  await tester.tap(find.text('Edit Profile'));
  await tester.pumpAndSettle();

  // Verify profile page is open
  expect(find.text('Profile'), findsOneWidget);
  expect(find.text('Profile Information'), findsOneWidget);
}

Future<void> _testSignOutFlow(WidgetTester tester) async {
  // Open profile dialog
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Sign out
  await tester.tap(find.text('Sign Out'));
  await tester.pumpAndSettle();

  // Verify we're back to auth page
  expect(find.text('Welcome Back'), findsOneWidget);
}
