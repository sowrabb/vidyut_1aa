// Error Handler Widget for consistent error display with SnackBars
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Error types for consistent styling
enum ErrorType {
  info,
  success,
  warning,
  error,
}

/// Error handler widget that shows SnackBars for errors
class ErrorHandlerWidget extends ConsumerWidget {
  final Widget child;
  final String? error;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final bool showSnackBar;

  const ErrorHandlerWidget({
    super.key,
    required this.child,
    this.error,
    this.errorType = ErrorType.error,
    this.onRetry,
    this.showSnackBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error SnackBar if error exists
    if (error != null && showSnackBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, error!, errorType, onRetry);
      });
    }

    return child;
  }

  /// Show error SnackBar
  void _showErrorSnackBar(
    BuildContext context,
    String error,
    ErrorType type,
    VoidCallback? onRetry,
  ) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getErrorIcon(type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: _getErrorColor(type),
      duration: Duration(seconds: type == ErrorType.error ? 5 : 3),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Get error icon based on type
  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.info:
        return Icons.info_outline;
      case ErrorType.success:
        return Icons.check_circle_outline;
      case ErrorType.warning:
        return Icons.warning_outlined;
      case ErrorType.error:
        return Icons.error_outline;
    }
  }

  /// Get error color based on type
  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.info:
        return Colors.blue;
      case ErrorType.success:
        return Colors.green;
      case ErrorType.warning:
        return Colors.orange;
      case ErrorType.error:
        return Colors.red;
    }
  }
}

/// Error handler for AsyncValue
class AsyncErrorHandler extends ConsumerWidget {
  final AsyncValue<dynamic> asyncValue;
  final Widget Function(dynamic data) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onRetry;
  final bool showSnackBar;

  const AsyncErrorHandler({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.onRetry,
    this.showSnackBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      data: (data) => builder(data),
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        if (showSnackBar) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, error.toString());
          });
        }

        return errorWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry!,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

/// Success message handler
class SuccessHandler {
  static void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

/// Info message handler
class InfoHandler {
  static void showInfo(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
