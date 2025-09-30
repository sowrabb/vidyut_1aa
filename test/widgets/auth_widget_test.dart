import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/app/provider_registry.dart';
import 'package:vidyut/features/auth/firebase_auth_page.dart';
import 'package:vidyut/state/auth/auth_controller.dart';
import 'package:vidyut/state/auth/auth_state.dart';

class _FakeAuthController extends BaseAuthController {
  _FakeAuthController() : super(AuthState.initial());

  @override
  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }

  @override
  Future<void> resendOtp(String phoneNumber) async {}

  @override
  Future<void> sendEmailVerification() async {
    state = state.copyWith(message: 'verification sent');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(message: 'reset sent');
  }

  @override
  Future<void> signInAsGuest() async {
    state = state.copyWith(status: AuthFlowStatus.authenticated);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthFlowStatus.authenticated);
  }

  @override
  Future<void> signInWithGoogle() async {
    state = state.copyWith(message: 'google');
  }

  @override
  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {}

  @override
  Future<void> signOut() async {
    state = state.copyWith(status: AuthFlowStatus.unauthenticated);
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthFlowStatus.authenticated);
  }
}

void main() {
  group('FirebaseAuthPage', () {
    Future<void> _pump(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => _FakeAuthController()),
          ],
          child: const MaterialApp(home: FirebaseAuthPage()),
        ),
      );
    }

    testWidgets('shows login form by default', (tester) async {
      await _pump(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('switches to sign up form when toggled', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('New to Vidyut? Create an account'));
      await tester.pump();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('I am registering as'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
    });

    testWidgets('reveals password reset actions', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Forgot password?'));
      await tester.pump();

      expect(find.text('Send password reset email'), findsOneWidget);
    });
  });
}
