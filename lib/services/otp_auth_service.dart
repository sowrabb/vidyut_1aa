import 'package:flutter/foundation.dart';

class OtpAuthService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String? _currentPhoneNumber;
  String? _verificationId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String? get currentPhoneNumber => _currentPhoneNumber;
  String? get verificationId => _verificationId;

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

  // Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate phone number
      if (!isValidIndianPhoneNumber(phoneNumber)) {
        _setError('Please enter a valid Indian mobile number');
        return false;
      }

      // Format phone number
      _currentPhoneNumber = formatIndianPhoneNumber(phoneNumber);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate OTP sending (in real app, integrate with SMS service)
      _verificationId =
          'demo_verification_${DateTime.now().millisecondsSinceEpoch}';

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate OTP format (6 digits)
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        _setError('Please enter a valid 6-digit OTP');
        return false;
      }

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any 6-digit OTP starting with 1-9
      if (otp.startsWith('0')) {
        _setError('Invalid OTP. Please try again.');
        return false;
      }

      // Login successful
      _isLoggedIn = true;
      _isGuest = false;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to verify OTP: ${e.toString()}');
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
      _verificationId = null;
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
    _verificationId = null;
    _clearError();
    notifyListeners();
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (_currentPhoneNumber == null) {
      _setError('No phone number found');
      return false;
    }

    return await sendOtp(_currentPhoneNumber!);
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
    } else if (_currentPhoneNumber != null) {
      return _currentPhoneNumber!;
    }
    return 'Unknown User';
  }

  // Check if user needs to login
  bool get needsLogin => !_isLoggedIn;
}
