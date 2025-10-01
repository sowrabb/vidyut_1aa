import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) {}

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {}

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer containers) {}
}

class AppStateConfiguration {
  const AppStateConfiguration();

  List<Override> get globalOverrides => [
        // Add environment-specific overrides here when needed, e.g. stubs for tests or demo
        // firebaseAuthProvider.overrideWithValue(FirebaseAuth.instance),
      ];

  List<ProviderObserver> get observers => const [AppProviderObserver()];
}

ProviderScope buildAppProviderScope({required Widget child, AppStateConfiguration config = const AppStateConfiguration()}) {
  return ProviderScope(
    overrides: config.globalOverrides,
    observers: config.observers,
    child: child,
  );
}


