import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';

class PermissionGate extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate(
      {super.key,
      required this.permission,
      required this.child,
      this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(adminAuthServiceProvider);
    if (auth.hasPermission(permission)) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
