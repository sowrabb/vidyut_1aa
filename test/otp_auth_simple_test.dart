import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/services/otp_auth_service.dart';

void main() {
  group('OTP Authentication Simple Tests', () {
    late OtpAuthService authService;

    setUp(() {
      authService = OtpAuthService();
    });

    group('Phone Number Validation', () {
      test('Validates Indian phone numbers correctly', () {
        // Valid Indian numbers (starting with 6,7,8,9)
        expect(authService.isValidIndianPhoneNumber('9876543210'), true);
        expect(authService.isValidIndianPhoneNumber('8765432109'), true);
        expect(authService.isValidIndianPhoneNumber('7654321098'), true);
        expect(authService.isValidIndianPhoneNumber('6543210987'), true);

        // Valid with country code
        expect(authService.isValidIndianPhoneNumber('+919876543210'), true);
        expect(authService.isValidIndianPhoneNumber('919876543210'), true);

        // Invalid numbers (starting with 1,2,3,4,5)
        expect(authService.isValidIndianPhoneNumber('1234567890'), false);
        expect(authService.isValidIndianPhoneNumber('2345678901'), false);
        expect(authService.isValidIndianPhoneNumber('3456789012'), false);
        expect(authService.isValidIndianPhoneNumber('4567890123'), false);
        expect(authService.isValidIndianPhoneNumber('5678901234'), false);

        // Invalid length
        expect(authService.isValidIndianPhoneNumber('987654321'), false);
        expect(authService.isValidIndianPhoneNumber('98765432101'), false);
      });

      test('Formats Indian phone numbers correctly', () {
        expect(authService.formatIndianPhoneNumber('9876543210'),
            '+91 98765 43210');
        expect(authService.formatIndianPhoneNumber('+919876543210'),
            '+91 98765 43210');
        expect(authService.formatIndianPhoneNumber('919876543210'),
            '+91 98765 43210');
      });
    });

    group('Authentication Flow', () {
      test('Initial state is correct', () {
        expect(authService.isLoading, false);
        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.error, null);
        expect(authService.needsLogin, true);
        expect(authService.userDisplayInfo, 'Unknown User');
      });

      test('Send OTP works with valid number', () async {
        final result = await authService.sendOtp('9876543210');

        expect(result, true);
        expect(authService.currentPhoneNumber, '+91 98765 43210');
        expect(authService.verificationId, isNotNull);
        expect(authService.error, null);
        expect(authService.isLoading, false);
      });

      test('Send OTP fails with invalid number', () async {
        final result = await authService.sendOtp('1234567890');

        expect(result, false);
        expect(authService.error, 'Please enter a valid Indian mobile number');
        expect(authService.currentPhoneNumber, null);
        expect(authService.verificationId, null);
      });

      test('Verify OTP works with valid code', () async {
        await authService.sendOtp('9876543210');
        final result = await authService.verifyOtp('123456');

        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, false);
        expect(authService.error, null);
        expect(authService.userDisplayInfo, '+91 98765 43210');
      });

      test('Verify OTP fails with invalid code', () async {
        await authService.sendOtp('9876543210');
        final result = await authService.verifyOtp('000000');

        expect(result, false);
        expect(authService.error, 'Invalid OTP. Please try again.');
        expect(authService.isLoggedIn, false);
      });

      test('Continue as guest works', () async {
        await authService.continueAsGuest();

        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, true);
        expect(authService.userDisplayInfo, 'Guest User');
        expect(authService.needsLogin, false);
        expect(authService.currentPhoneNumber, null);
        expect(authService.verificationId, null);
      });

      test('Logout works', () async {
        // First login as guest
        await authService.continueAsGuest();
        expect(authService.isLoggedIn, true);

        // Then logout
        await authService.logout();

        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.currentPhoneNumber, null);
        expect(authService.verificationId, null);
        expect(authService.needsLogin, true);
        expect(authService.userDisplayInfo, 'Unknown User');
      });

      test('Resend OTP works', () async {
        await authService.sendOtp('9876543210');
        final firstVerificationId = authService.verificationId;

        final result = await authService.resendOtp();

        expect(result, true);
        expect(authService.verificationId, isNotNull);
        expect(authService.verificationId, isNot(equals(firstVerificationId)));
        expect(authService.error, null);
      });

      test('Resend OTP fails without phone number', () async {
        final result = await authService.resendOtp();

        expect(result, false);
        expect(authService.error, 'No phone number found');
      });
    });

    group('Error Handling', () {
      test('Clear error works', () {
        authService.clearError();
        expect(authService.error, null);
      });

      test('Invalid OTP format is rejected', () async {
        await authService.sendOtp('9876543210');

        final result1 = await authService.verifyOtp('12345'); // Too short
        expect(result1, false);
        expect(authService.error, 'Please enter a valid 6-digit OTP');

        final result2 = await authService.verifyOtp('1234567'); // Too long
        expect(result2, false);
        expect(authService.error, 'Please enter a valid 6-digit OTP');

        final result3 = await authService.verifyOtp('abcdef'); // Non-numeric
        expect(result3, false);
        expect(authService.error, 'Please enter a valid 6-digit OTP');
      });
    });

    group('Complete Authentication Flow', () {
      test('Complete phone login flow', () async {
        // Step 1: Send OTP
        final sendResult = await authService.sendOtp('9876543210');
        expect(sendResult, true);
        expect(authService.currentPhoneNumber, '+91 98765 43210');

        // Step 2: Verify OTP
        final verifyResult = await authService.verifyOtp('123456');
        expect(verifyResult, true);
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, false);
        expect(authService.userDisplayInfo, '+91 98765 43210');

        // Step 3: Logout
        await authService.logout();
        expect(authService.isLoggedIn, false);
        expect(authService.needsLogin, true);
      });

      test('Guest flow', () async {
        // Step 1: Continue as guest
        await authService.continueAsGuest();
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, true);
        expect(authService.userDisplayInfo, 'Guest User');

        // Step 2: Logout
        await authService.logout();
        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.needsLogin, true);
      });
    });
  });
}
