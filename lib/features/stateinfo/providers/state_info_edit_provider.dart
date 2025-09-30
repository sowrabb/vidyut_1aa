import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/provider_registry.dart';
import '../store/state_info_edit_store.dart';

/// Provider for StateInfo Edit Store
/// Deprecated shim kept for backward references. Prefer using stateInfoEditStoreProvider.
class StateInfoEditProvider extends StatelessWidget {
  const StateInfoEditProvider({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
  static StateInfoEditStore of(BuildContext context) {
    return ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
  }

  static StateInfoEditStore watch(BuildContext context) {
    return ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
  }
}

extension StateInfoEditProviderExtension on BuildContext {
  StateInfoEditStore get stateInfoEditStore =>
      ProviderScope.containerOf(this).read(stateInfoEditStoreProvider);
  StateInfoEditStore get watchStateInfoEditStore =>
      ProviderScope.containerOf(this).read(stateInfoEditStoreProvider);
}
