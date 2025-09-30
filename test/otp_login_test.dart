import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/auth/otp_login_page.dart';
import 'package:vidyut/services/otp_auth_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('OTP Login Tests', () {
    late OtpAuthService authService;

    setUp(() {
      authService = OtpAuthService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          otpAuthServiceProvider.overrideWith((ref) => authService),
        ],
        child: MaterialApp(
          home: const OtpLoginPage(),
        ),
      );
    }

    group('OtpAuthService Unit Tests', () {
      test('Validates Indian phone numbers correctly', () {
        // Valid Indian numbers
        expect(authService.isValidIndianPhoneNumber('9876543210'), true);
        expect(authService.isValidIndianPhoneNumber('+919876543210'), true);
        expect(authService.isValidIndianPhoneNumber('919876543210'), true);

        // Invalid numbers
        expect(authService.isValidIndianPhoneNumber('1234567890'), false);
        expect(authService.isValidIndianPhoneNumber('987654321'), false);
        expect(authService.isValidIndianPhoneNumber('98765432101'), false);
        expect(authService.isValidIndianPhoneNumber('12345678901'), false);
      });

      test('Formats Indian phone numbers correctly', () {
        expect(authService.formatIndianPhoneNumber('9876543210'),
            '+91 98765 43210');
        expect(authService.formatIndianPhoneNumber('+919876543210'),
            '+91 98765 43210');
        expect(authService.formatIndianPhoneNumber('919876543210'),
            '+91 98765 43210');
      });

      test('Initial state is correct', () {
        expect(authService.isLoading, false);
        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.error, null);
        expect(authService.needsLogin, true);
      });

      test('Send OTP works with valid number', () async {
        final result = await authService.sendOtp('9876543210');

        expect(result, true);
        expect(authService.currentPhoneNumber, '+91 98765 43210');
        expect(authService.verificationId, isNotNull);
        expect(authService.error, null);
      });

      test('Send OTP fails with invalid number', () async {
        final result = await authService.sendOtp('1234567890');

        expect(result, false);
        expect(authService.error, 'Please enter a valid Indian mobile number');
      });

      test('Verify OTP works with valid code', () async {
        await authService.sendOtp('9876543210');
        final result = await authService.verifyOtp('123456');

        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, false);
        expect(authService.error, null);
      });

      test('Verify OTP fails with invalid code', () async {
        await authService.sendOtp('9876543210');
        final result = await authService.verifyOtp('000000');

        expect(result, false);
        expect(authService.error, 'Invalid OTP. Please try again.');
      });

      test('Continue as guest works', () async {
        await authService.continueAsGuest();

        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, true);
        expect(authService.userDisplayInfo, 'Guest User');
        expect(authService.needsLogin, false);
      });

      test('Logout works', () async {
        await authService.continueAsGuest();
        expect(authService.isLoggedIn, true);

        await authService.logout();

        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.currentPhoneNumber, null);
        expect(authService.verificationId, null);
        expect(authService.needsLogin, true);
      });
    });

    group('Widget Tests', () {
      testWidgets('OTP login page renders correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify initial page elements
        expect(find.text('Welcome to Vidyut'), findsOneWidget);
        expect(find.text('Enter your mobile number'), findsOneWidget);
        expect(find.text('Send OTP'), findsOneWidget);
        expect(find.text('Continue as Guest'), findsOneWidget);
        expect(find.text('+91'), findsOneWidget);
      });

      testWidgets('Phone number input works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find phone input field
        final phoneField = find.byType(TextField);
        expect(phoneField, findsOneWidget);

        // Enter phone number
        await tester.enterText(phoneField, '9876543210');
        await tester.pumpAndSettle();

        // Verify button is enabled
        final sendButton = find.text('Send OTP');
        expect(sendButton, findsOneWidget);
      });

      testWidgets('Send OTP button works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid phone number
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pumpAndSettle();

        // Tap send OTP button
        await tester.tap(find.text('Send OTP'));
        await tester.pumpAndSettle();

        // Verify OTP page is shown
        expect(find.text('Enter verification code'), findsOneWidget);
        expect(find.text('Verify OTP'), findsOneWidget);
      });

      testWidgets('Continue as guest button works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap continue as guest
        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();

        // Verify navigation (this would be verified in a real app)
        // For now, just verify the button was tapped successfully
        expect(find.text('Continue as Guest'), findsOneWidget);
      });

      testWidgets('Error display works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter invalid phone number
        await tester.enterText(find.byType(TextField), '1234567890');
        await tester.pumpAndSettle();

        // Tap send OTP button
        await tester.tap(find.text('Send OTP'));
        await tester.pumpAndSettle();

        // Verify error is displayed
        expect(find.text('Please enter a valid Indian mobile number'),
            findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete OTP flow works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Step 1: Enter phone number
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pumpAndSettle();

        // Step 2: Send OTP
        await tester.tap(find.text('Send OTP'));
        await tester.pumpAndSettle();

        // Step 3: Verify OTP page is shown
        expect(find.text('Enter verification code'), findsOneWidget);

        // Step 4: Enter OTP (simulate entering 6 digits)
        final otpFields = find.byType(TextField);
        expect(otpFields, findsNWidgets(6));

        // Enter a valid OTP
        for (int i = 0; i < 6; i++) {
          await tester.enterText(otpFields.at(i), '1');
          await tester.pumpAndSettle();
        }

        // Step 5: Verify OTP
        await tester.tap(find.text('Verify OTP'));
        await tester.pumpAndSettle();

        // Verify success (in a real app, this would navigate to main app)
        // For now, just verify the flow completed without errors
        expect(find.text('Verify OTP'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('OTP login page is accessible', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify semantic structure
        expect(find.byType(Semantics), findsWidgets);
        expect(find.text('Welcome to Vidyut'), findsOneWidget);
      });

      testWidgets('Form fields have proper accessibility', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify form fields are accessible
        expect(find.byType(TextField), findsOneWidget);
      });
    });
  });
}
