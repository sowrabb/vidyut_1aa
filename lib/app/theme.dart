import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';
import 'typography.dart';

ThemeData buildVidyutTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.surfaceAlt,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.textSecondary,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.surfaceAlt,
    onTertiaryContainer: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFE7E7),
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    shadow: AppColors.shadow,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: buildTextTheme(),
    fontFamily: GoogleFonts.manrope().fontFamily,
    scaffoldBackgroundColor: AppColors.surface,
    dividerColor: AppColors.divider,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      scrolledUnderElevation: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppElevation.level1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primarySurface,
        disabledForegroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.sm,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.shadow,
      elevation: AppElevation.level8,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 80,
    ),
  );
}
