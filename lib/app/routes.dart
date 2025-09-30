import 'package:flutter/material.dart';

import 'layout/responsive_scaffold.dart';
import '../features/search/comprehensive_search_page.dart';
import '../features/location/comprehensive_location_page.dart';
import '../features/reviews/reviews_page.dart';
import '../features/reviews/review_composer.dart';

Map<String, WidgetBuilder> buildAppRoutes() => {
      '/': (context) => const ResponsiveScaffold(initialIndex: 0),
      '/search': (context) => const ResponsiveScaffold(initialIndex: 1),
      '/messages': (context) => const ResponsiveScaffold(initialIndex: 2),
      '/categories': (context) => const ResponsiveScaffold(initialIndex: 3),
      '/sell': (context) => const ResponsiveScaffold(initialIndex: 4),
      '/state-info': (context) => const ResponsiveScaffold(initialIndex: 5),
      '/profile': (context) => const ResponsiveScaffold(initialIndex: 6),
      '/enhanced-search': (context) => const ComprehensiveSearchPage(),
      '/location-services': (context) => const ComprehensiveLocationPage(),
      '/reviews': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final productId = (args is String) ? args : '';
        return ReviewsPage(productId: productId);
      },
      '/write-review': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final productId = (args is String) ? args : '';
        return ReviewComposer(productId: productId);
      },
    };
