import 'package:flutter/material.dart';
import '../../../app/breakpoints.dart';

/// Responsive layout utilities following Material Design guidelines
class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.tablet &&
      MediaQuery.of(context).size.width < AppBreakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

  /// Get appropriate column count based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// Get appropriate card aspect ratio based on screen size
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 1.4;
    if (isTablet(context)) return 1.2;
    return 1.1;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  /// Get appropriate content margin
  static EdgeInsets getContentMargin(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.symmetric(horizontal: 16);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 48);
  }

  /// Get spacing between elements
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 20;
  }

  /// Show content in appropriate modal for mobile vs desktop
  static void showResponsiveModal({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? title,
  }) {
    if (isMobile(context)) {
      // Use full-screen modal on mobile
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: builder,
        ),
      );
    } else {
      // Use dialog on desktop/tablet
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: builder(context),
          ),
        ),
      );
    }
  }

  /// Show bottom sheet on mobile, regular modal on desktop
  static void showResponsiveBottomSheet({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) {
    if (isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        useSafeArea: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => builder(context),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: builder,
      );
    }
  }
}

/// Responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool enableMaxWidth;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.enableMaxWidth = true,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (enableMaxWidth && ResponsiveLayout.isDesktop(context)) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? 1200,
          ),
          child: child,
        ),
      );
    }

    return Padding(
      padding: ResponsiveLayout.getScreenPadding(context),
      child: content,
    );
  }
}

/// Responsive grid that adapts column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ResponsiveLayout.getGridColumns(context),
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio:
          childAspectRatio ?? ResponsiveLayout.getCardAspectRatio(context),
      children: children,
    );
  }
}

/// Mobile-optimized app bar
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
        backgroundColor: backgroundColor,
        elevation: 1,
        scrolledUnderElevation: 2,
      );
    } else {
      return AppBar(
        title: Text(title),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
        backgroundColor: backgroundColor,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Mobile-first navigation buttons
class ResponsiveNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onStartOver;
  final String? nextLabel;
  final String? backLabel;
  final bool showFloatingActionButton;

  const ResponsiveNavigationButtons({
    super.key,
    this.onBack,
    this.onNext,
    this.onStartOver,
    this.nextLabel,
    this.backLabel,
    this.showFloatingActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return _MobileNavigationButtons(
        onBack: onBack,
        onNext: onNext,
        onStartOver: onStartOver,
        nextLabel: nextLabel,
        backLabel: backLabel,
        showFloatingActionButton: showFloatingActionButton,
      );
    } else {
      return _DesktopNavigationButtons(
        onBack: onBack,
        onNext: onNext,
        onStartOver: onStartOver,
        nextLabel: nextLabel,
        backLabel: backLabel,
      );
    }
  }
}

class _MobileNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onStartOver;
  final String? nextLabel;
  final String? backLabel;
  final bool showFloatingActionButton;

  const _MobileNavigationButtons({
    this.onBack,
    this.onNext,
    this.onStartOver,
    this.nextLabel,
    this.backLabel,
    this.showFloatingActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary action as prominent button
        if (onNext != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: Text(nextLabel ?? 'Next'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        // Secondary actions in a row
        if (onBack != null || onStartOver != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                if (onBack != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(backLabel ?? 'Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (onStartOver != null) const SizedBox(width: 8),
                ],
                if (onStartOver != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onStartOver,
                      icon: const Icon(Icons.home),
                      label: const Text('Start Over'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DesktopNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onStartOver;
  final String? nextLabel;
  final String? backLabel;

  const _DesktopNavigationButtons({
    this.onBack,
    this.onNext,
    this.onStartOver,
    this.nextLabel,
    this.backLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: Text(backLabel ?? 'Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (onNext != null) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: Text(nextLabel ?? 'Next'),
              ),
            ),
          ],
          if (onStartOver != null) ...[
            if (onBack != null || onNext != null) const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onStartOver,
              icon: const Icon(Icons.home),
              label: const Text('Start Over'),
            ),
          ],
        ],
      ),
    );
  }
}
