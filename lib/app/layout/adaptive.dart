import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppBreaks {
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

class AppLayout {
  // Content wrappers
  static const double contentMax = 1200;

  // Form field max widths (desktop/tablet get column widths; phone uses full)
  static const double fieldMaxDesktop = 420;
  static const double fieldMaxTablet = 360;

  // Card caps
  static const double productCardMax = 300;
}

extension XAdaptive on BuildContext {
  Size get _sz => MediaQuery.sizeOf(this);
  bool get isPhone => _sz.width < AppBreaks.tablet;
  bool get isTablet =>
      _sz.width >= AppBreaks.tablet && _sz.width < AppBreaks.desktop;
  bool get isDesktop => _sz.width >= AppBreaks.desktop;

  double get fieldMaxWidth => isDesktop
      ? AppLayout.fieldMaxDesktop
      : isTablet
          ? AppLayout.fieldMaxTablet
          : double.infinity;

  double colWidth(
      {int desktop = 2, int tablet = 2, int phone = 1, double gap = 12}) {
    final cols = isDesktop
        ? desktop
        : isTablet
            ? tablet
            : phone;
    final w = _sz.width;
    final content = math.min(w, AppLayout.contentMax) - (gap * (cols - 1));
    return content / cols;
  }
}

/// Wraps page content to center and clamp width.
class ContentClamp extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const ContentClamp(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.contentMax),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Grid-like row that never overflows and never full-stretches on desktop.
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final int desktop;
  final int tablet;
  final int phone;
  final bool useFieldMaxWidth;
  const ResponsiveRow({
    super.key,
    required this.children,
    this.gap = 12,
    this.desktop = 2,
    this.tablet = 2,
    this.phone = 1,
    this.useFieldMaxWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final cw = context.colWidth(
        desktop: desktop, tablet: tablet, phone: phone, gap: gap);
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: children.map((w) {
          final targetWidth =
              useFieldMaxWidth ? math.min(cw, context.fieldMaxWidth) : cw;
          return SizedBox(width: targetWidth, child: w);
        }).toList(),
      );
    });
  }
}
