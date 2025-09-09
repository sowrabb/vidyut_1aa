import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'package:ionicons/ionicons.dart';
import 'location_picker.dart';

class LocationButton extends StatelessWidget {
  final String city;
  final String state;
  final double radiusKm;
  final ValueChanged<LocationResult> onPicked;
  final String? area;

  const LocationButton({
    super.key,
    required this.city,
    required this.state,
    required this.radiusKm,
    required this.onPicked,
    this.area,
  });

  @override
  Widget build(BuildContext context) {
    final areaPart =
        (area != null && area!.trim().isNotEmpty) ? area!.trim() : city;
    final bool isPhone =
        MediaQuery.sizeOf(context).width < 768; // AppBreaks.tablet
    final label = isPhone ? city : '$areaPart, $state';
    return TextButton.icon(
      onPressed: () => _openPicker(context),
      icon: const Icon(Ionicons.location_outline, color: AppColors.textPrimary),
      label: Text(label, style: Theme.of(context).textTheme.titleSmall),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.outlineSoft),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!context.mounted) return;

    LocationResult? result;

    if (kIsWeb) {
      result = await showDialog<LocationResult>(
        context: context,
        builder: (ctx) => Dialog(
          child: LocationPicker(
            city: city,
            state: state,
            radiusKm: radiusKm,
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<LocationResult>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16),
          child: LocationPicker(
            city: city,
            state: state,
            radiusKm: radiusKm,
          ),
        ),
      );
    }

    if (result != null && context.mounted) {
      onPicked(result);
    }
  }
}
