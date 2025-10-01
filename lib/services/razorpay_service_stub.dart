/// Stub implementation for non-web platforms
/// This file is used when building for Android/iOS

/// Open Razorpay checkout (stub for mobile)
void openRazorpayCheckoutWeb({
  required Map<String, dynamic> options,
  required Function(Map<String, dynamic>) onSuccess,
  required Function() onDismiss,
}) {
  throw UnsupportedError('Web-specific Razorpay is not supported on this platform');
}

/// Check if Razorpay is available (stub for mobile)
bool isRazorpayAvailable() {
  return false;
}

