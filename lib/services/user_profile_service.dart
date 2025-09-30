import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileService extends ChangeNotifier {
  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    ImagePicker? imagePicker,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _imagePicker = imagePicker ?? ImagePicker();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final ImagePicker _imagePicker;

  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize user profile
  Future<void> initializeProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userProfile = doc.data();
      }
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? bio,
    String? company,
    String? address,
    Map<String, dynamic>? preferences,
  }) async {
    if (_userProfile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final userId = _userProfile!['uid'];
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (bio != null) updateData['bio'] = bio;
      if (company != null) updateData['company'] = company;
      if (address != null) updateData['address'] = address;
      if (preferences != null) updateData['preferences'] = preferences;

      await _firestore.collection('users').doc(userId).update(updateData);

      // Update local profile
      _userProfile!.addAll(updateData);
      _userProfile!.remove('updatedAt'); // Remove server timestamp

      // Update Firebase Auth display name if changed
      if (displayName != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      // Create a reference to the file
      final ref = _storage.ref().child('profile_images/$userId.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(File(imageFile.path));

      // Get download URL
      final downloadURL = await uploadTask.ref.getDownloadURL();

      // Update user profile with new image URL
      await _firestore.collection('users').doc(userId).update({
        'photoURL': downloadURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local profile
      if (_userProfile != null) {
        _userProfile!['photoURL'] = downloadURL;
      }

      // Update Firebase Auth photo URL
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(downloadURL);
      }

      notifyListeners();
      return downloadURL;
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      _setError('Failed to pick image: ${e.toString()}');
      return null;
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      _setError('Failed to take photo: ${e.toString()}');
      return null;
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete from storage
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.delete();

      // Update user profile
      await _firestore.collection('users').doc(userId).update({
        'photoURL': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local profile
      if (_userProfile != null) {
        _userProfile!['photoURL'] = null;
      }

      // Update Firebase Auth photo URL
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(null);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete image: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update privacy settings
  Future<bool> updatePrivacySettings({
    bool? profileVisible,
    bool? emailVisible,
    bool? phoneVisible,
    bool? allowMessages,
  }) async {
    if (_userProfile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final userId = _userProfile!['uid'];
      final privacySettings = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (profileVisible != null)
        privacySettings['privacy.profileVisible'] = profileVisible;
      if (emailVisible != null)
        privacySettings['privacy.emailVisible'] = emailVisible;
      if (phoneVisible != null)
        privacySettings['privacy.phoneVisible'] = phoneVisible;
      if (allowMessages != null)
        privacySettings['privacy.allowMessages'] = allowMessages;

      await _firestore.collection('users').doc(userId).update(privacySettings);

      // Update local profile
      if (_userProfile!['privacy'] == null) {
        _userProfile!['privacy'] = <String, dynamic>{};
      }
      _userProfile!['privacy'].addAll(privacySettings);
      _userProfile!.remove('updatedAt');

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update privacy settings: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Export user data (GDPR compliance)
  Future<Map<String, dynamic>?> exportUserData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;

      // Add additional data if needed
      final exportData = {
        'profile': userData,
        'exportedAt': DateTime.now().toIso8601String(),
        'dataTypes': [
          'profile_information',
          'preferences',
          'privacy_settings',
          'account_creation_date',
        ],
      };

      return exportData;
    } catch (e) {
      _setError('Failed to export data: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user account and all associated data
  Future<bool> deleteUserAccount(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete profile image from storage
      try {
        final ref = _storage.ref().child('profile_images/$userId.jpg');
        await ref.delete();
      } catch (e) {
        // Image might not exist, continue
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete Firebase Auth account
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }

      // Clear local data
      _userProfile = null;
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
}
