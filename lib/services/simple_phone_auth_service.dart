import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SimplePhoneAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _currentPhoneNumber;
  String? _currentUserName;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String? get currentUserId => _user?.uid;
  String? get currentPhoneNumber => _currentPhoneNumber;
  String? get currentUserName => _currentUserName;

  SimplePhoneAuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Validate Indian phone number
  bool isValidIndianPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Indian mobile numbers: +91 followed by 10 digits starting with 6,7,8,9
    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      final mobilePart = cleaned.substring(2);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(mobilePart);
    }

    // Indian mobile numbers without country code: 10 digits starting with 6,7,8,9
    if (cleaned.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }

    return false;
  }

  // Format Indian phone number
  String formatIndianPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      return '+91 ${cleaned.substring(2, 7)} ${cleaned.substring(7)}';
    }

    if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }

    return phoneNumber;
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign up with phone number and password
  Future<bool> signUpWithPhonePassword({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate phone number
      if (!isValidIndianPhoneNumber(phoneNumber)) {
        _setError('Please enter a valid Indian mobile number');
        return false;
      }

      // Validate password
      if (password.length < 6) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

      // Validate name
      if (name.trim().isEmpty) {
        _setError('Please enter your name');
        return false;
      }

      // Format phone number
      final formattedPhone = formatIndianPhoneNumber(phoneNumber);

      // Check if phone number already exists
      final existingUser = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .get();

      if (existingUser.docs.isNotEmpty) {
        _setError('An account with this phone number already exists');
        return false;
      }

      // Create email from phone number for Firebase Auth
      final email =
          '${formattedPhone.replaceAll(' ', '').replaceAll('+', '')}@vidyut.local';

      // Create Firebase Auth user with email/password
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await result.user!.updateDisplayName(name.trim());

      // Hash password for our custom storage
      final hashedPassword = _hashPassword(password);

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'phoneNumber': formattedPhone,
        'displayName': name.trim(),
        'email': email,
        'passwordHash': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'user',
        'isActive': true,
        'isVerified': true,
      });

      _user = result.user;
      _currentPhoneNumber = formattedPhone;
      _currentUserName = name.trim();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with phone number and password
  Future<bool> signInWithPhonePassword({
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate phone number
      if (!isValidIndianPhoneNumber(phoneNumber)) {
        _setError('Please enter a valid Indian mobile number');
        return false;
      }

      // Validate password
      if (password.isEmpty) {
        _setError('Please enter your password');
        return false;
      }

      // Format phone number
      final formattedPhone = formatIndianPhoneNumber(phoneNumber);

      // Find user by phone number
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .where('isActive', isEqualTo: true)
          .get();

      if (userQuery.docs.isEmpty) {
        _setError('No account found with this phone number');
        return false;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (userData['passwordHash'] != hashedPassword) {
        _setError('Invalid phone number or password');
        return false;
      }

      // Get the email from user data
      final email = userData['email'] as String?;
      if (email == null) {
        _setError('Account data is incomplete');
        return false;
      }

      // Sign in with email/password
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;
      _currentPhoneNumber = userData['phoneNumber'];
      _currentUserName = userData['displayName'];
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to sign in: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null || _currentPhoneNumber == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Verify current password
      final currentHashedPassword = _hashPassword(currentPassword);

      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: _currentPhoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        _setError('User not found');
        return false;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      if (userData['passwordHash'] != currentHashedPassword) {
        _setError('Current password is incorrect');
        return false;
      }

      // Update password
      final newHashedPassword = _hashPassword(newPassword);
      await userDoc.reference.update({
        'passwordHash': newHashedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _setError('Failed to update password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
  }) async {
    if (_user == null || _currentPhoneNumber == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: _currentPhoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        _setError('User not found');
        return false;
      }

      await userQuery.docs.first.reference.update({
        'displayName': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUserName = name.trim();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
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
      _currentPhoneNumber = null;
      _currentUserName = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

  // Delete account
  Future<bool> deleteAccount({
    required String password,
  }) async {
    if (_user == null || _currentPhoneNumber == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Verify password before deletion
      final hashedPassword = _hashPassword(password);

      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: _currentPhoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        _setError('User not found');
        return false;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      if (userData['passwordHash'] != hashedPassword) {
        _setError('Password is incorrect');
        return false;
      }

      // Mark account as inactive instead of deleting
      await userDoc.reference.update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Sign out
      await _auth.signOut();
      _user = null;
      _currentPhoneNumber = null;
      _currentUserName = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
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

  // Get user display info
  String get userDisplayInfo {
    if (_currentUserName != null) {
      return _currentUserName!;
    } else if (_currentPhoneNumber != null) {
      return _currentPhoneNumber!;
    }
    return 'Unknown User';
  }

  // Check if user needs to login
  bool get needsLogin => !isLoggedIn;
}
