import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../app/breakpoints.dart';

/// Unified responsive grid system for consistent layouts across the app
class ResponsiveGridConfig {
  static const double defaultSpacing = 12.0;
  static const double mobileSpacing = 8.0;
  static const double tabletSpacing = 12.0;
  static const double desktopSpacing = 16.0;

  /// Product card configurations
  static const double productCardMaxWidth = 280.0;
  static const double productCardMinWidth = 140.0;

  /// Category card configurations
  static const double categoryCardMaxWidth = 200.0;
  static const double categoryCardMinWidth = 120.0;

  /// Get optimal spacing based on screen width
  static double getSpacing(double screenWidth) {
    if (screenWidth >= AppBreakpoints.desktop) return desktopSpacing;
    if (screenWidth >= AppBreakpoints.tablet) return tabletSpacing;
    return mobileSpacing;
  }

  /// Get optimal columns for product grid
  static int getProductColumns(double availableWidth) {
    final spacing = getSpacing(availableWidth);
    final minCardWidth = productCardMinWidth + spacing;

    // Calculate how many cards can fit
    int columns = (availableWidth / minCardWidth).floor();

    // Apply sensible limits based on screen size
    if (availableWidth >= AppBreakpoints.desktop) {
      return columns.clamp(3, 5); // 3-5 columns on desktop
    } else if (availableWidth >= AppBreakpoints.tablet) {
      return columns.clamp(2, 4); // 2-4 columns on tablet
    } else {
      return columns.clamp(2, 3); // 2-3 columns on mobile
    }
  }

  /// Get optimal columns for category grid
  static int getCategoryColumns(double availableWidth) {
    final spacing = getSpacing(availableWidth);
    final minCardWidth = categoryCardMinWidth + spacing;

    int columns = (availableWidth / minCardWidth).floor();

    if (availableWidth >= AppBreakpoints.desktop) {
      return columns.clamp(4, 6); // 4-6 columns on desktop (reduced from 8)
    } else if (availableWidth >= AppBreakpoints.tablet) {
      return columns.clamp(3, 4); // 3-4 columns on tablet (reduced from 6)
    } else {
      return columns.clamp(2, 3); // 2-3 columns on mobile (same as products)
    }
  }

  /// Get adaptive aspect ratio for product cards
  static double getProductAspectRatio(double screenWidth) {
    if (screenWidth >= AppBreakpoints.desktop) {
      return 0.65; // More height on desktop for content
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return 0.6; // More height on tablet
    }
    return 0.55; // Much taller on mobile to prevent overflow
  }

  /// Get adaptive aspect ratio for category cards - now same scale as product cards
  static double getCategoryAspectRatio(double screenWidth) {
    if (screenWidth >= AppBreakpoints.desktop) {
      return 0.65; // Same as product cards
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return 0.6; // Same as product cards
    }
    return 0.55; // Same as product cards for consistency
  }
}

/// Responsive grid delegate that adapts to screen size and content type
class ResponsiveGridDelegate extends SliverGridDelegate {
  final ResponsiveGridType gridType;
  final double availableWidth;

  const ResponsiveGridDelegate({
    required this.gridType,
    required this.availableWidth,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final spacing = ResponsiveGridConfig.getSpacing(availableWidth);

    int crossAxisCount;
    double childAspectRatio;

    switch (gridType) {
      case ResponsiveGridType.product:
        crossAxisCount = ResponsiveGridConfig.getProductColumns(availableWidth);
        childAspectRatio =
            ResponsiveGridConfig.getProductAspectRatio(availableWidth);
        break;
      case ResponsiveGridType.category:
        crossAxisCount =
            ResponsiveGridConfig.getCategoryColumns(availableWidth);
        childAspectRatio =
            ResponsiveGridConfig.getCategoryAspectRatio(availableWidth);
        break;
    }

    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
    );

    return delegate.getLayout(constraints);
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return oldDelegate is ResponsiveGridDelegate &&
        (oldDelegate.gridType != gridType ||
            oldDelegate.availableWidth != availableWidth);
  }
}

enum ResponsiveGridType {
  product,
  category,
}

/// Widget that provides consistent responsive grid behavior
class ResponsiveGrid extends StatelessWidget {
  final ResponsiveGridType gridType;
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool forceLandscapeOnMobile;

  const ResponsiveGrid({
    super.key,
    required this.gridType,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.forceLandscapeOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

        // Use landscape layout for product cards on mobile when forced
        if (forceLandscapeOnMobile &&
            gridType == ResponsiveGridType.product &&
            isMobile) {
          return ListView.builder(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        }

        // Use regular grid for desktop/tablet or categories
        final delegate = ResponsiveGridDelegate(
          gridType: gridType,
          availableWidth: constraints.maxWidth,
        );

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: delegate,
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Sliver version of responsive grid
class ResponsiveSliverGrid extends StatelessWidget {
  final ResponsiveGridType gridType;
  final List<Widget> children;

  const ResponsiveSliverGrid({
    super.key,
    required this.gridType,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final delegate = ResponsiveGridDelegate(
          gridType: gridType,
          availableWidth: constraints.crossAxisExtent,
        );

        return SliverGrid(
          gridDelegate: delegate,
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
        );
      },
    );
  }
}
