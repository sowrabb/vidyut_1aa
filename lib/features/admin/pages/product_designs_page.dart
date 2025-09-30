import 'package:flutter/material.dart';

/// Placeholder page while product design management is scoped.
///
/// The previous implementation referenced store methods that are no longer
/// available, which broke analyzer checks. This minimalist scaffold keeps the
/// navigation surface intact until the backing store/services are restored.
class ProductDesignsPage extends StatelessWidget {
  const ProductDesignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Designs Management')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Product design management is temporarily unavailable.\n'
            'Please connect this page to the enhanced admin store before re-enabling it.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
