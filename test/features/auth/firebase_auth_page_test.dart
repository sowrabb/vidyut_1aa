import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidyut/features/auth/firebase_auth_page.dart';
import 'package:vidyut/services/firebase_auth_service.dart';
import 'package:vidyut/app/provider_registry.dart';

import 'firebase_auth_page_test.mocks.dart';

@GenerateMocks([FirebaseAuthService])
void main() {
  group('FirebaseAuthPage Widget Tests', () {
    late MockFirebaseAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockFirebaseAuthService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          firebaseAuthServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: const MaterialApp(
          home: FirebaseAuthPage(),
        ),
      );
    }

    testWidgets('should display login form by default',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in with Firebase'), findsOneWidget);
      expect(
          find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should switch to signup form when toggled',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pump();

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join with Firebase Authentication'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(5)); // Name, Email, Password, Phone, Role
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets(
        'should show password reset form when forgot password is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      // Assert
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Email'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should show guest sign in button',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('should show Google sign in button',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('should display error message when auth fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn('Invalid credentials');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show loading indicator when authenticating',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(true);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets(
        'should call signInWithEmailPassword when sign in button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);
      when(mockAuthService.signInWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets(
        'should call signUpWithEmailPassword when sign up button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);
      when(mockAuthService.signUpWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
        phoneNumber: anyNamed('phoneNumber'),
      )).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signUpWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        phoneNumber: null,
      )).called(1);
    });

    testWidgets('should call signInAsGuest when guest button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isLoading).thenReturn(false);
      when(mockAuthService.error).thenReturn(null);
      when(mockAuthService.signInAsGuest()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Continue as Guest'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signInAsGuest()).called(1);
    });
  });
}
