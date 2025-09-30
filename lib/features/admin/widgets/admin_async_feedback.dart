import 'package:flutter/material.dart';

import '../models/admin_action_result.dart';

/// Central helper for showing async feedback inside the admin console.
class AdminAsyncFeedback {
  const AdminAsyncFeedback._();

  static void showSnackBar(BuildContext context, AdminActionResult result) {
    final theme = Theme.of(context);
    final backgroundColor = switch (result.status) {
      AdminActionStatus.success => theme.colorScheme.primaryContainer,
      AdminActionStatus.warning => theme.colorScheme.tertiaryContainer,
      AdminActionStatus.error => theme.colorScheme.errorContainer,
    };
    final foregroundColor = switch (result.status) {
      AdminActionStatus.success => theme.colorScheme.onPrimaryContainer,
      AdminActionStatus.warning => theme.colorScheme.onTertiaryContainer,
      AdminActionStatus.error => theme.colorScheme.onErrorContainer,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: result.details != null
            ? SnackBarAction(
                label: 'DETAILS',
                textColor: foregroundColor,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Action details'),
                      content: SelectableText(result.details.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
