import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Stitch Design System Colors
  static const Color primary = Color(0xFFAB3500); // Main deep orange
  static const Color primaryContainer = Color(0xFFFF6B35); // Accent vibrant orange
  
  static const Color secondary = Color(0xFF006A62); // Teal
  static const Color secondaryContainer = Color(0xFF2EC4B6); // Accent vibrant teal
  
  static const Color tertiary = Color(0xFF00677E); // Slate blue
  
  // Neutral Surfaces
  static const Color background = Color(0xFFFFF8F6);
  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceDim = Color(0xFFEED5CD);
  static const Color surfaceBright = Color(0xFFFFF8F6);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF1ED);
  static const Color surfaceContainer = Color(0xFFFFE9E3);
  static const Color surfaceContainerHigh = Color(0xFFFDE3DB);
  static const Color surfaceContainerHighest = Color(0xFFF7DDD5);

  // On-Color / Text
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF261814);
  static const Color onSurfaceVariant = Color(0xFF594139);
  
  static const Color outline = Color(0xFF8D7168);
  static const Color outlineVariant = Color(0xFFE1BFB5);

  // Semantics
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  
  static const Color success = Color(0xFF166534);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFF991B1B);
  static const Color warningContainer = Color(0xFFFEE2E2);

  // Premium UI Gradients
  static const List<Color> primaryGradient = [Color(0xFFAB3500), Color(0xFFFF6B35)];
  static const List<Color> secondaryGradient = [Color(0xFF006A62), Color(0xFF2EC4B6)];
  static const List<Color> tertiaryGradient = [Color(0xFF004D61), Color(0xFF0083A4)];
  static const List<Color> errorGradient = [Color(0xFF8E1717), Color(0xFFBA1A1A)];
  static const List<Color> successGradient = [Color(0xFF14532D), Color(0xFF22C55E)];
  static const List<Color> goldGradient = [Color(0xFFB45309), Color(0xFFF59E0B)];
  static const List<Color> indigoGradient = [Color(0xFF4338CA), Color(0xFF6366F1)];
}

