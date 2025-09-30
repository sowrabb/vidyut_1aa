import 'package:flutter/material.dart';

import 'enhanced_state_info_page.dart';

/// Backwards-compatible wrapper so legacy imports keep working after the
/// enhanced routing refactor.
class LightweightStateInfoPage extends StatelessWidget {
  const LightweightStateInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EnhancedStateInfoPage();
  }
}
