import 'package:flutter/material.dart';

class HorizontalScroller extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  const HorizontalScroller(
      {super.key, required this.child, this.padding, this.controller});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = controller ?? ScrollController();
    Widget content = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      padding: padding,
      child: child,
    );

    // Always show a scrollbar on desktop/tablet for better discoverability
    final bool useScrollbar =
        Theme.of(context).platform == TargetPlatform.macOS ||
            Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.linux ||
            Theme.of(context).platform == TargetPlatform.fuchsia;

    if (useScrollbar) {
      content = Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        notificationPredicate: (_) => true,
        child: content,
      );
    }

    return content;
  }
}
