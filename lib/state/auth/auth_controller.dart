import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase_providers.dart';
import '../core/repository_providers.dart';
import 'auth_state.dart';

abstract class BaseAuthController extends StateNotifier<AuthState> {
  BaseAuthController(AuthState initial) : super(initial);

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  });

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signInAsGuest();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<void> resendOtp(String phoneNumber);

  Future<void> signInWithGoogle();

  void clearMessage();
}

final authControllerProvider =
    StateNotifierProvider<BaseAuthController, AuthState>(
  (ref) => AuthController(ref),
);

class AuthController extends BaseAuthController {
  AuthController(
    this._ref, {
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    bool subscribeAuthChanges = true,
  }) : super(AuthState.initial()) {
    _auth = auth ?? _ref.read(firebaseAuthProvider);
    _firestore = firestore ?? _ref.read(firebaseFirestoreProvider);
    if (subscribeAuthChanges) {
      _subscription = _auth.authStateChanges().listen(_handleAuthChange);
    }
  }

  final Ref _ref;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      final user = credential.user;
      if (user != null) {
        await _ensureUserDocument(user, name: name, phoneNumber: phoneNumber);
        state = state.copyWith(
          user: user,
          status: AuthFlowStatus.authenticated,
          isLoading: false,
          clearMessage: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          status: AuthFlowStatus.unauthenticated,
          message: 'User registration failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: 'An unexpected error occurred. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      state = state.copyWith(
        user: user,
        status: user == null
            ? AuthFlowStatus.unauthenticated
            : AuthFlowStatus.authenticated,
        isLoading: false,
        clearMessage: true,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: 'An unexpected error occurred. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await _ensureUserDocument(user, name: 'Guest User');
      }
      state = state.copyWith(
        user: user,
        status: AuthFlowStatus.authenticated,
        isLoading: false,
        clearMessage: true,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: 'Unable to sign in as guest. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      await _auth.signOut();
      state = state.copyWith(
        user: null,
        status: AuthFlowStatus.unauthenticated,
        isLoading: false,
        clearMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Sign out failed. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(
        message: 'Password reset email sent to $email',
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(message: _mapFirebaseAuthError(e));
    } catch (e) {
      state = state.copyWith(
        message: 'Unable to send reset email. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.sendEmailVerification();
      state = state.copyWith(message: 'Verification email sent.');
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(message: _mapFirebaseAuthError(e));
    } catch (e) {
      state = state.copyWith(
        message: 'Failed to send verification email. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      state = state.copyWith(
        user: user,
        status: user == null
            ? AuthFlowStatus.unauthenticated
            : AuthFlowStatus.authenticated,
        isLoading: false,
        clearMessage: true,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        message: 'OTP verification failed. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearMessage: true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (error) {
          state = state.copyWith(
            isLoading: false,
            message: _mapFirebaseAuthError(error),
          );
        },
        codeSent: (_, __) {
          state = state.copyWith(
            isLoading: false,
            message: 'OTP sent to $phoneNumber',
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Failed to resend OTP. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      message:
          'Google Sign-In is not configured yet. Please use email or phone login.',
      clearMessage: false,
    );
  }

  @override
  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }

  Future<void> _ensureUserDocument(User user,
      {String? name, String? phoneNumber}) async {
    final repo = _ref.read(firestoreRepositoryServiceProvider);
    final existing = await repo.getUser(user.uid);
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': user.email ?? '',
      'name': name ?? user.displayName ?? user.email?.split('@').first ?? '',
      'phone': phoneNumber ?? user.phoneNumber,
      'role': 'buyer',
      'status': 'active',
      'subscription_plan': 'free',
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'is_seller': false,
    });
  }

  void _handleAuthChange(User? user) {
    if (user == null) {
      state = state.copyWith(
        user: null,
        status: AuthFlowStatus.unauthenticated,
        isLoading: false,
        clearMessage: true,
      );
      return;
    }

    state = state.copyWith(
      user: user,
      status: AuthFlowStatus.authenticated,
      isLoading: false,
      clearMessage: true,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with those credentials.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak. Choose a stronger one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. (${e.code})';
    }
  }
}
