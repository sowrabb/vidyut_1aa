import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String? get currentUserId => _user?.uid;
  String? get currentUserEmail => _user?.email;
  String? get currentUserDisplayName => _user?.displayName;
  String? get currentUserPhoneNumber => _user?.phoneNumber;
  bool get isGuest => _user?.isAnonymous ?? false;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  FirebaseAuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _createUserDocument(
        result.user!,
        name: name,
        phoneNumber: phoneNumber,
      );

      _user = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google (requires additional setup)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Note: This requires google_sign_in package and proper configuration
      // For now, we'll show an error message
      _setError(
          'Google Sign-In not yet configured. Please use email/password.');
      return false;
    } catch (e) {
      _setError('Google Sign-In failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with phone number (Firebase Phone Auth)
  Future<bool> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      _user = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Phone authentication failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send OTP to phone number
  Future<bool> sendOTPToPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          final UserCredential result =
              await _auth.signInWithCredential(credential);
          _user = result.user;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_getAuthErrorMessage(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOTP(String phoneNumber) async {
    if (_resendToken == null) {
      _setError('Cannot resend OTP. Please request a new one.');
      return false;
    }

    return sendOTPToPhoneNumber(phoneNumber);
  }

  // Sign in as guest
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _clearError();

    try {
      // Add timeout to prevent hanging
      final UserCredential result = await _auth.signInAnonymously().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'timeout',
            message: 'Guest sign-in timed out. Please try again.',
          );
        },
      );

      _user = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Guest sign-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to send password reset email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    if (_user == null) {
      _setError('No user is currently signed in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _user!.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to send email verification: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _verificationId = null;
      _resendToken = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(_user!.uid).delete();

      // Delete Firebase Auth account
      await _user!.delete();

      _user = null;
      _verificationId = null;
      _resendToken = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _user!.updateDisplayName(displayName);
      if (photoURL != null) {
        await _user!.updatePhotoURL(photoURL);
      }

      // Update user document in Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    required String name,
    String? phoneNumber,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': name,
      'phoneNumber': phoneNumber,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'role': 'user', // Default role
      'isActive': true,
    });
  }

  // Get user document from Firestore
  Future<Map<String, dynamic>?> getUserDocument() async {
    if (_user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data();
    } catch (e) {
      _setError('Failed to fetch user data: ${e.toString()}');
      return null;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';
      case 'timeout':
        return 'Sign-in timed out. Please check your connection and try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Private fields for OTP verification
  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;
}
