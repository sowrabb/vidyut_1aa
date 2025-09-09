import 'package:flutter/material.dart';

final class AppColors {
  // Surfaces & text
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color border = Color(0xFFE5E7EB); // gray-200
  static const Color divider = Color(0xFFE5E7EB);

  // Brand (Dark Blue)
  // Picked: #0D47A1 (indigo-800 range) — accessible on white
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryHover = Color(0xFF0B3F91);
  static const Color primaryPressed = Color(0xFF093679);
  static const Color primarySurface = Color(0xFFE6EEF9); // subtle tint

  // States
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Shadows
  static const Color shadow = Color(0x1A000000); // 10% black

  // Additional colors
  static const Color whatsapp = Color(0xFF25D366);
  static const Color outlineSoft = Color(0xFFEAECEE);
  static const Color thumbBg = Color(0xFFF3F4F6); // light gray for thumbs
  static const Color shadowSoft = Color(0x14000000); // 8% black
}

final class AppSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

final class AppElevation {
  static const double none = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level4 = 4;
  static const double level8 = 8;
}
