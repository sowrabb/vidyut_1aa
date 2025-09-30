import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vidyut/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cross-Platform Authentication Tests', () {
    testWidgets('should work consistently across platforms',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test basic functionality that should work on all platforms
      await _testBasicAuthFlow(tester);
      await _testFormValidation(tester);
      await _testNavigation(tester);
    });

    testWidgets('should handle platform-specific features',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test platform-specific behavior
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _testiOSFeatures(tester);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await _testAndroidFeatures(tester);
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        await _testWindowsFeatures(tester);
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        await _testmacOSFeatures(tester);
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        await _testLinuxFeatures(tester);
      }
    });

    testWidgets('should maintain consistent UI across platforms',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test UI consistency
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in with Firebase'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('should handle different screen sizes',
        (WidgetTester tester) async {
      // Test on different screen sizes
      await _testScreenSize(tester, Size(320, 568)); // iPhone SE
      await _testScreenSize(tester, Size(375, 667)); // iPhone 8
      await _testScreenSize(tester, Size(414, 896)); // iPhone 11 Pro Max
      await _testScreenSize(tester, Size(768, 1024)); // iPad
      await _testScreenSize(tester, Size(1024, 768)); // Desktop
    });

    testWidgets('should handle different orientations',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test portrait orientation
      await _testOrientation(tester, Orientation.portrait);

      // Test landscape orientation
      await _testOrientation(tester, Orientation.landscape);
    });

    testWidgets('should work with different text scaling',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test with different text scaling factors
      await _testTextScaling(tester, 0.8); // Small text
      await _testTextScaling(tester, 1.0); // Normal text
      await _testTextScaling(tester, 1.5); // Large text
      await _testTextScaling(tester, 2.0); // Extra large text
    });

    testWidgets('should handle platform-specific keyboard types',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test email field keyboard type
      final emailField = find.byType(TextFormField).first;
      final emailWidget = tester.widget<TextFormField>(emailField);
      expect(emailWidget.keyboardType, TextInputType.emailAddress);

      // Test password field keyboard type
      final passwordField = find.byType(TextFormField).at(1);
      final passwordWidget = tester.widget<TextFormField>(passwordField);
      expect(passwordWidget.obscureText, true);
    });

    testWidgets('should handle platform-specific gestures',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to auth page
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test tap gestures
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Test long press gestures (if applicable)
      await tester.longPress(find.text('Sign In'));
      await tester.pump();

      // Test swipe gestures (if applicable)
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pump();
    });

    testWidgets('should handle platform-specific navigation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test back navigation
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Simulate back button press
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });
  });
}

Future<void> _testBasicAuthFlow(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Test guest mode
  await tester.tap(find.text('Continue as Guest'));
  await tester.pumpAndSettle();

  // Verify guest mode is active
  expect(find.text('Guest User'), findsOneWidget);
}

Future<void> _testFormValidation(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Test form validation
  await tester.tap(find.text('Sign In'));
  await tester.pump();

  // Verify validation messages appear
  expect(find.text('Please enter your email'), findsOneWidget);
  expect(find.text('Please enter your password'), findsOneWidget);
}

Future<void> _testNavigation(WidgetTester tester) async {
  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Test navigation between login and signup
  await tester.tap(find.text("Don't have an account? Sign up"));
  await tester.pumpAndSettle();

  await tester.tap(find.text("Already have an account? Sign in"));
  await tester.pumpAndSettle();

  // Verify we're back to login
  expect(find.text('Welcome Back'), findsOneWidget);
}

Future<void> _testiOSFeatures(WidgetTester tester) async {
  // iOS-specific tests
  app.main();
  await tester.pumpAndSettle();

  // Test iOS-specific UI elements
  expect(find.byType(MaterialApp), findsOneWidget);
}

Future<void> _testAndroidFeatures(WidgetTester tester) async {
  // Android-specific tests
  app.main();
  await tester.pumpAndSettle();

  // Test Android-specific UI elements
  expect(find.byType(MaterialApp), findsOneWidget);
}

Future<void> _testWindowsFeatures(WidgetTester tester) async {
  // Windows-specific tests
  app.main();
  await tester.pumpAndSettle();

  // Test Windows-specific UI elements
  expect(find.byType(MaterialApp), findsOneWidget);
}

Future<void> _testmacOSFeatures(WidgetTester tester) async {
  // macOS-specific tests
  app.main();
  await tester.pumpAndSettle();

  // Test macOS-specific UI elements
  expect(find.byType(MaterialApp), findsOneWidget);
}

Future<void> _testLinuxFeatures(WidgetTester tester) async {
  // Linux-specific tests
  app.main();
  await tester.pumpAndSettle();

  // Test Linux-specific UI elements
  expect(find.byType(MaterialApp), findsOneWidget);
}

Future<void> _testScreenSize(WidgetTester tester, Size size) async {
  // Set screen size
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  app.main();
  await tester.pumpAndSettle();

  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Verify UI adapts to screen size
  expect(find.text('Welcome Back'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
}

Future<void> _testOrientation(
    WidgetTester tester, Orientation orientation) async {
  // Set orientation
  tester.view.physicalSize = orientation == Orientation.portrait
      ? const Size(375, 667)
      : const Size(667, 375);

  app.main();
  await tester.pumpAndSettle();

  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Verify UI adapts to orientation
  expect(find.text('Welcome Back'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
}

Future<void> _testTextScaling(WidgetTester tester, double scale) async {
  // Set text scaling
  tester.view.textScaleFactor = scale;

  app.main();
  await tester.pumpAndSettle();

  // Navigate to auth page
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Verify UI adapts to text scaling
  expect(find.text('Welcome Back'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
}
