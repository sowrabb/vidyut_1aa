import 'package:flutter/material.dart';

class BiDirectionalScroller extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BiDirectionalScroller({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final ScrollController horizontal = ScrollController();
    final ScrollController vertical = ScrollController();

    Widget inner = SingleChildScrollView(
      controller: vertical,
      padding: padding,
      child: child,
    );

    Widget outer = SingleChildScrollView(
      controller: horizontal,
      scrollDirection: Axis.horizontal,
      child: inner,
    );

    final bool showScrollbars =
        Theme.of(context).platform == TargetPlatform.macOS ||
            Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.linux ||
            Theme.of(context).platform == TargetPlatform.fuchsia;

    if (showScrollbars) {
      outer = Scrollbar(
        controller: horizontal,
        thumbVisibility: true,
        notificationPredicate: (_) => true,
        child: Scrollbar(
          controller: vertical,
          thumbVisibility: true,
          notificationPredicate: (_) => true,
          child: outer,
        ),
      );
    }

    return outer;
  }
}
