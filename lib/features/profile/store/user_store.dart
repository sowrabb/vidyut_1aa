import 'package:flutter/foundation.dart';
import '../models/user_models.dart';

class UserStore extends ChangeNotifier {
  UserProfile _profile;
  UserPreferences _preferences;
  NotificationSettings _notificationSettings;
  bool _isLoading = false;
  String? _error;

  UserStore({
    UserProfile? profile,
    UserPreferences? preferences,
    NotificationSettings? notificationSettings,
  })  : _profile = profile ?? _defaultProfile,
        _preferences = preferences ?? const UserPreferences(),
        _notificationSettings =
            notificationSettings ?? const NotificationSettings();

  static UserProfile get _defaultProfile {
    return UserProfile(
      id: 'user_001',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+91-9876543210',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: false,
    );
  }

  // Getters
  UserProfile get profile => _profile;
  UserPreferences get preferences => _preferences;
  NotificationSettings get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Profile management
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _profile = _profile.copyWith(
        name: name,
        email: email,
        phone: phone,
        updatedAt: DateTime.now(),
      );

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _profile = _profile.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile image: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Password management
  Future<bool> changePassword(PasswordChangeRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate password validation
      if (request.currentPassword != 'current123') {
        _setError('Current password is incorrect');
        return false;
      }

      // In a real app, you would hash the new password and send it to the server
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Preferences management
  Future<void> updatePreferences(UserPreferences newPreferences) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      _preferences = newPreferences;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update preferences: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Notification settings management
  Future<void> updateNotificationSettings(
      NotificationSettings newSettings) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      _notificationSettings = newSettings;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notification settings: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // In a real app, this would send an email verification link
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to send verification email: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Phone verification
  Future<void> sendPhoneVerification() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // In a real app, this would send an SMS verification code
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to send verification SMS: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Account deletion
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      // Simulate password validation
      if (password != 'current123') {
        _setError('Password is incorrect');
        return false;
      }

      _clearError();
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

  // Export data for backup
  Map<String, dynamic> exportData() {
    return {
      'profile': _profile.toJson(),
      'preferences': _preferences.toJson(),
      'notificationSettings': _notificationSettings.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      if (data.containsKey('profile')) {
        _profile = UserProfile.fromJson(data['profile']);
      }

      if (data.containsKey('preferences')) {
        _preferences = UserPreferences.fromJson(data['preferences']);
      }

      if (data.containsKey('notificationSettings')) {
        _notificationSettings =
            NotificationSettings.fromJson(data['notificationSettings']);
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to import data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
