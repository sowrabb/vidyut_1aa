import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/services/phone_auth_service.dart';

void main() {
  group('PhoneAuthService Tests', () {
    late PhoneAuthService authService;

    setUp(() {
      authService = PhoneAuthService();
    });

    tearDown(() {
      authService.dispose();
    });

    group('Phone Number Validation', () {
      test('Validates Indian phone numbers correctly', () {
        expect(authService.isValidIndianPhoneNumber('9876543210'), true);
        expect(authService.isValidIndianPhoneNumber('9123456789'),
            true); // starts with 9, valid
        expect(authService.isValidIndianPhoneNumber('1234567890'),
            false); // starts with 1
        expect(authService.isValidIndianPhoneNumber('987654321'),
            false); // too short
        expect(authService.isValidIndianPhoneNumber('98765432101'),
            false); // too long
      });

      test('Formats phone numbers correctly', () {
        expect(authService.formatIndianPhoneNumber('9876543210'),
            '+91 98765 43210');
        expect(authService.formatIndianPhoneNumber('919876543210'),
            '+91 98765 43210');
      });
    });

    group('Password Validation', () {
      test('Validates passwords correctly', () {
        expect(authService.isValidPassword('123456'), true);
        expect(authService.isValidPassword('12345'), false); // too short
        expect(authService.isValidPassword(''), false); // empty
      });
    });

    group('Email Validation', () {
      test('Validates emails correctly', () {
        expect(authService.isValidEmail(''), true); // empty is valid (optional)
        expect(authService.isValidEmail('test@example.com'), true);
        expect(authService.isValidEmail('invalid-email'), false);
        expect(authService.isValidEmail('test@'), false);
      });
    });

    group('Login Flow', () {
      test('Login fails with invalid phone number', () async {
        final result =
            await authService.loginWithPhonePassword('1234567890', '123456');
        expect(result, false);
        expect(authService.error, 'Please enter a valid Indian mobile number');
      });

      test('Login fails with invalid password', () async {
        final result =
            await authService.loginWithPhonePassword('9876543210', '12345');
        expect(result, false);
        expect(
            authService.error, 'Password must be at least 6 characters long');
      });

      test('Login fails with wrong password', () async {
        final result =
            await authService.loginWithPhonePassword('9876543210', 'wrongpass');
        expect(result, false);
        expect(authService.error, 'Invalid phone number or password');
      });

      test('Login succeeds with correct credentials', () async {
        final result =
            await authService.loginWithPhonePassword('9876543210', '123456');
        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, false);
        expect(authService.currentPhoneNumber, '+91 98765 43210');
        expect(authService.userDisplayInfo, 'Demo User');
      });
    });

    group('Signup Flow', () {
      test('Signup fails with invalid phone number', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '1234567890',
          password: '123456',
          name: 'Test User',
        );
        expect(result, false);
        expect(authService.error, 'Please enter a valid Indian mobile number');
      });

      test('Signup fails with invalid password', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '9876543210',
          password: '12345',
          name: 'Test User',
        );
        expect(result, false);
        expect(
            authService.error, 'Password must be at least 6 characters long');
      });

      test('Signup fails with empty name', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '9876543210',
          password: '123456',
          name: '',
        );
        expect(result, false);
        expect(authService.error, 'Please enter your name');
      });

      test('Signup fails with invalid email', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '9876543210',
          password: '123456',
          name: 'Test User',
          email: 'invalid-email',
        );
        expect(result, false);
        expect(authService.error, 'Please enter a valid email address');
      });

      test('Signup succeeds with valid data', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '9876543210',
          password: '123456',
          name: 'Test User',
          email: 'test@example.com',
        );
        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, false);
        expect(authService.currentPhoneNumber, '+91 98765 43210');
        expect(authService.currentUserName, 'Test User');
        expect(authService.currentUserEmail, 'test@example.com');
        expect(authService.userDisplayInfo, 'Test User');
      });

      test('Signup succeeds without email', () async {
        final result = await authService.signUpWithPhonePassword(
          phoneNumber: '9876543210',
          password: '123456',
          name: 'Test User',
        );
        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.currentUserName, 'Test User');
        expect(authService.currentUserEmail, null);
      });
    });

    group('Guest Flow', () {
      test('Continue as guest works', () async {
        await authService.continueAsGuest();
        expect(authService.isLoggedIn, true);
        expect(authService.isGuest, true);
        expect(authService.currentPhoneNumber, null);
        expect(authService.userDisplayInfo, 'Guest User');
      });
    });

    group('Logout Flow', () {
      test('Logout works', () async {
        await authService.loginWithPhonePassword('9876543210', '123456');
        expect(authService.isLoggedIn, true);

        await authService.logout();
        expect(authService.isLoggedIn, false);
        expect(authService.isGuest, false);
        expect(authService.currentPhoneNumber, null);
        expect(authService.needsLogin, true);
      });
    });
  });
}
