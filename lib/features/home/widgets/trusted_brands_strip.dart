import 'package:flutter/material.dart';
import '../../../app/breakpoints.dart';
import '../../../app/tokens.dart';

class TrustedBrandsStrip extends StatelessWidget {
  const TrustedBrandsStrip({super.key});

  static const _brands = [
    'Philips',
    'Schneider',
    'ABB',
    'Siemens',
    'L&T',
    'Havells',
    'Crompton',
    'Polycab',
    'Finolex',
    'Orient',
    'Anchor',
    'Syska',
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= AppBreakpoints.desktop;

    Widget chip(String name) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(name, style: Theme.of(context).textTheme.titleSmall),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trusted by leading brands',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (isDesktop)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _brands.map(chip).toList(),
            )
          else
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _brands.length,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Center(child: chip(_brands[i])),
              ),
            ),
        ],
      ),
    );
  }
}
