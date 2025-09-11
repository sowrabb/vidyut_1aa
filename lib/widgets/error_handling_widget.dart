import 'package:flutter/material.dart';
import '../app/tokens.dart';

/// A reusable widget for displaying error states
class ErrorHandlingWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? errorIcon;
  final String? title;

  const ErrorHandlingWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.retryText = 'Retry',
    this.errorIcon = Icons.error_outline,
    this.title = 'Something went wrong',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for displaying loading states
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? progress;
  final bool showProgress;

  const LoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.progress,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProgress && progress != null)
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.outlineSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for displaying empty states
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A wrapper widget that handles loading, error, and empty states
class StateHandlingWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;
  final String? emptyTitle;
  final String? emptySubtitle;
  final IconData? emptyIcon;
  final VoidCallback? onEmptyAction;
  final String? emptyActionText;
  final String? loadingMessage;
  final double? loadingProgress;
  final bool showLoadingProgress;

  const StateHandlingWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.isEmpty,
    required this.child,
    this.onRetry,
    this.emptyTitle = 'No data available',
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_outlined,
    this.onEmptyAction,
    this.emptyActionText,
    this.loadingMessage = 'Loading...',
    this.loadingProgress,
    this.showLoadingProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(
        message: loadingMessage,
        progress: loadingProgress,
        showProgress: showLoadingProgress,
      );
    }

    if (errorMessage != null) {
      return ErrorHandlingWidget(
        errorMessage: errorMessage,
        onRetry: onRetry,
      );
    }

    if (isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle!,
        subtitle: emptySubtitle,
        icon: emptyIcon,
        onAction: onEmptyAction,
        actionText: emptyActionText,
      );
    }

    return child;
  }
}
