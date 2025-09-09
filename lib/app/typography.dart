import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

TextTheme buildTextTheme() {
  // Base colors: black primary, grey secondary
  final base = ThemeData.light().textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  // Manrope for all text, with system fallbacks (web+mobile safe)
  final manrope = GoogleFonts.manropeTextTheme(base);

  return manrope.copyWith(
    // Tighten and standardize weights/sizes we care about
    displayLarge: manrope.displayLarge?.copyWith(fontWeight: FontWeight.w700),
    displayMedium: manrope.displayMedium?.copyWith(fontWeight: FontWeight.w700),
    displaySmall: manrope.displaySmall?.copyWith(fontWeight: FontWeight.w700),
    headlineLarge: manrope.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: manrope.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: manrope.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
    titleLarge: manrope.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: manrope.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: manrope.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
    bodyLarge: manrope.bodyLarge,
    bodyMedium: manrope.bodyMedium,
    bodySmall: manrope.bodySmall?.copyWith(color: AppColors.textSecondary),
    labelLarge: manrope.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    labelMedium: manrope.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
    labelSmall: manrope.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}
