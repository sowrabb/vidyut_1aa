import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyut/services/firebase_auth_service.dart';

import 'firebase_auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  SharedPreferences,
])
void main() {
  group('FirebaseAuthService', () {
    late FirebaseAuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocument;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocument = MockDocumentReference();
      mockPrefs = MockSharedPreferences();

      authService = FirebaseAuthService();
    });

    group('Guest Mode', () {
      test('should sign in as guest successfully', () async {
        // Act
        final result = await authService.signInAsGuest();

        // Assert
        expect(result, true);
        expect(authService.isGuest, true);
        expect(authService.isLoggedIn, true);
        expect(authService.currentUserDisplayName, 'Guest User');
      });

      test('should sign out guest user', () async {
        // Arrange
        await authService.signInAsGuest();

        // Act
        await authService.signOut();

        // Assert
        expect(authService.isGuest, false);
        expect(authService.isLoggedIn, false);
      });
    });

    group('Email/Password Authentication', () {
      test('should handle sign up with email and password', () async {
        // Arrange
        final mockUser = MockUser();
        final mockCredential = MockUserCredential();

        when(mockCredential.user).thenReturn(mockUser);
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockCredential);

        when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
        when(mockFirestore.collection(any)).thenReturn(mockCollection);
        when(mockCollection.doc(any)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async {});

        // Act
        final result = await authService.signUpWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        // Assert
        expect(result, true);
        verify(mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should handle sign in with email and password', () async {
        // Arrange
        final mockUser = MockUser();
        final mockCredential = MockUserCredential();

        when(mockCredential.user).thenReturn(mockUser);
        when(mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockCredential);

        // Act
        final result = await authService.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, true);
        verify(mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });
    });

    group('Password Reset', () {
      test('should send password reset email', () async {
        // Arrange
        when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer((_) async {});

        // Act
        final result =
            await authService.sendPasswordResetEmail('test@example.com');

        // Assert
        expect(result, true);
        verify(mockAuth.sendPasswordResetEmail(email: 'test@example.com'))
            .called(1);
      });
    });

    group('Email Verification', () {
      test('should send email verification', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.sendEmailVerification();

        // Assert
        expect(result, true);
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should check email verification status', () {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.emailVerified).thenReturn(true);
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final isVerified = authService.isEmailVerified;

        // Assert
        expect(isVerified, true);
      });
    });

    group('Error Handling', () {
      test('should handle FirebaseAuthException', () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use',
        ));

        // Act
        final result = await authService.signUpWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        // Assert
        expect(result, false);
        expect(authService.error,
            'An account already exists with this email address.');
      });

      test('should handle generic exceptions', () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Generic error'));

        // Act
        final result = await authService.signUpWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        // Assert
        expect(result, false);
        expect(authService.error,
            'An unexpected error occurred: Exception: Generic error');
      });
    });

    group('Session Management', () {
      test('should reset session timer on user activity', () {
        // Arrange
        authService.signInAsGuest();

        // Act
        authService.resetSessionTimer();

        // Assert
        expect(authService.isLoggedIn, true);
      });
    });
  });
}
