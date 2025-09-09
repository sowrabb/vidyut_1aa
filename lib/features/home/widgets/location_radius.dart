import 'package:flutter/material.dart';

class LocationRadius extends StatelessWidget {
  final double valueKm;
  final ValueChanged<double> onChanged;

  const LocationRadius({
    super.key,
    required this.valueKm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Location radius: ${valueKm.toStringAsFixed(0)} km',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Slider(
            value: valueKm.clamp(5, 200),
            min: 5,
            max: 200,
            divisions: 39,
            label: '${valueKm.toStringAsFixed(0)} km',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
