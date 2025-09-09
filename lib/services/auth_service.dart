import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/firebase_models.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  final FirebaseService _firebase = FirebaseService.instance;

  // Get current user
  User? get currentUser => _firebase.auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'user_sign_in',
        parameters: {'method': 'email'},
      );
      
      return credential;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
    String role,
  ) async {
    try {
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebase.users.doc(credential.user!.uid).set(userModel.toFirestore());

      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'user_sign_up',
        parameters: {'method': 'email', 'role': role},
      );

      return credential;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebase.auth.signOut();
      
      // Log analytics event
      await _firebase.analytics.logEvent(name: 'user_sign_out');
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firebase.users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firebase.users.doc(userId).update(updates);
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Update seller profile
  Future<void> updateSellerProfile(String userId, Map<String, dynamic> sellerProfile) async {
    try {
      await _firebase.users.doc(userId).update({
        'sellerProfile': sellerProfile,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email);
      
      // Log analytics event
      await _firebase.analytics.logEvent(name: 'password_reset_requested');
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebase.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Sign in with phone credential
  Future<UserCredential?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _firebase.auth.signInWithCredential(credential);
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'user_sign_in',
        parameters: {'method': 'phone'},
      );
      
      return result;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.role == 'admin';
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      return false;
    }
  }

  // Check if user is seller
  Future<bool> isSeller(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.role == 'seller';
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      return false;
    }
  }
}
