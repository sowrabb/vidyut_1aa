import 'package:flutter/foundation.dart';

class PhoneAuthService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String? _currentPhoneNumber;
  String? _currentUserName;
  String? _currentUserEmail;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String? get currentPhoneNumber => _currentPhoneNumber;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;

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

  // Validate password
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Validate email (optional)
  bool isValidEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Login with phone number and password
  Future<bool> loginWithPhonePassword(
      String phoneNumber, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate phone number
      if (!isValidIndianPhoneNumber(phoneNumber)) {
        _setError('Please enter a valid Indian mobile number');
        return false;
      }

      // Validate password
      if (!isValidPassword(password)) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

      // Format phone number
      _currentPhoneNumber = formatIndianPhoneNumber(phoneNumber);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any valid phone number with password "123456"
      if (password != '123456') {
        _setError('Invalid phone number or password');
        return false;
      }

      // Login successful
      _isLoggedIn = true;
      _isGuest = false;
      _currentUserName = 'Demo User'; // In real app, fetch from API
      _currentUserEmail = null; // In real app, fetch from API
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to login: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with phone number, password, name, and optional email
  Future<bool> signUpWithPhonePassword({
    required String phoneNumber,
    required String password,
    required String name,
    String? email,
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
      if (!isValidPassword(password)) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

      // Validate name
      if (name.trim().isEmpty) {
        _setError('Please enter your name');
        return false;
      }

      // Validate email if provided
      if (email != null && email.isNotEmpty && !isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      // Format phone number
      _currentPhoneNumber = formatIndianPhoneNumber(phoneNumber);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, simulate successful signup
      // In real app, this would create user account in backend

      // Signup successful
      _isLoggedIn = true;
      _isGuest = false;
      _currentUserName = name.trim();
      _currentUserEmail = email?.trim();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Continue as guest
  Future<void> continueAsGuest() async {
    _setLoading(true);

    try {
      // Simulate delay
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoggedIn = true;
      _isGuest = true;
      _currentPhoneNumber = null;
      _currentUserName = null;
      _currentUserEmail = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to continue as guest: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _isGuest = false;
    _currentPhoneNumber = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _clearError();
    notifyListeners();
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
    if (_isGuest) {
      return 'Guest User';
    } else if (_currentUserName != null) {
      return _currentUserName!;
    } else if (_currentPhoneNumber != null) {
      return _currentPhoneNumber!;
    }
    return 'Unknown User';
  }

  // Check if user needs to login
  bool get needsLogin => !_isLoggedIn;
}
