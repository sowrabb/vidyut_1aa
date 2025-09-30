import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/provider_registry.dart';

/// Test harness for wrapping widgets with ProviderScope and common test setup
class TestHarness extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestHarness({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Helper function to create a test widget with ProviderScope
Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
  return TestHarness(
    overrides: overrides,
    child: child,
  );
}

/// Common test overrides for mocking services
class TestOverrides {
  /// Common test overrides for all tests
  static List<Override> get commonOverrides => [
        // Add common test overrides here as needed
        // For example, mock demo data service, analytics service, etc.
      ];
}
