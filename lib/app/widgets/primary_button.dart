import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(leadingIcon ?? Ionicons.flash_outline),
      label: Text(label),
    );
  }
}
