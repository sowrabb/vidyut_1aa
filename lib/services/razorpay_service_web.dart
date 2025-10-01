/// Web-specific Razorpay implementation
import 'dart:js' as js;
import 'dart:html' as html;

/// Open Razorpay checkout on web
void openRazorpayCheckoutWeb({
  required Map<String, dynamic> options,
  required Function(Map<String, dynamic>) onSuccess,
  required Function() onDismiss,
}) {
  // Create Razorpay options object with JS interop
  final razorpayOptionsMap = Map<String, dynamic>.from(options);
  
  // Add handlers
  razorpayOptionsMap['handler'] = js.allowInterop((response) {
    final result = {
      'razorpay_payment_id': response['razorpay_payment_id'],
      'razorpay_order_id': response['razorpay_order_id'],
      'razorpay_signature': response['razorpay_signature'],
    };
    onSuccess(result);
  });
  
  razorpayOptionsMap['modal'] = {
    'ondismiss': js.allowInterop(() {
      onDismiss();
    })
  };
  
  final razorpayOptions = js.JsObject.jsify(razorpayOptionsMap);
  
  // Check if Razorpay is loaded
  if (js.context['Razorpay'] == null) {
    throw Exception('Razorpay script not loaded. Please refresh the page.');
  }
  
  // Create and open Razorpay instance
  final razorpayInstance = js.JsObject(js.context['Razorpay'], [razorpayOptions]);
  razorpayInstance.callMethod('open');
}

/// Check if Razorpay is available
bool isRazorpayAvailable() {
  return js.context['Razorpay'] != null;
}

