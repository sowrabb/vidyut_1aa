import 'package:flutter/foundation.dart';

/// Describes the outcome of an admin-side asynchronous action.
@immutable
class AdminActionResult {
  final AdminActionStatus status;
  final String message;
  final Object? details;

  const AdminActionResult.success(String message, {Object? details})
      : status = AdminActionStatus.success,
        message = message,
        details = details;

  const AdminActionResult.warning(String message, {Object? details})
      : status = AdminActionStatus.warning,
        message = message,
        details = details;

  const AdminActionResult.error(String message, {Object? details})
      : status = AdminActionStatus.error,
        message = message,
        details = details;

  bool get isSuccess => status == AdminActionStatus.success;
  bool get isWarning => status == AdminActionStatus.warning;
  bool get isError => status == AdminActionStatus.error;
}

enum AdminActionStatus { success, warning, error }
