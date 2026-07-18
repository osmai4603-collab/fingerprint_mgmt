import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: AppColors.indigo500,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: AppColors.indigo100,
    onPrimaryContainer: AppColors.indigo900,

    // Secondary
    secondary: AppColors.teal600,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: AppColors.teal100,
    onSecondaryContainer: AppColors.teal900,

    // Tertiary
    tertiary: AppColors.mint600,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: AppColors.mint100,
    onTertiaryContainer: AppColors.mint950,

    // Errors
    error: AppColors.errorRed,
    onError: Color(0xFFFFFFFF),
    errorContainer: AppColors.errorRedContainer,
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.slate50,
    onSurface: AppColors.slate900,
    surfaceDim: AppColors.slate200,
    surfaceBright: Color(0xFFFCFDFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F4F8),
    surfaceContainer: AppColors.slate100,
    surfaceContainerHigh: Color(0xFFE6EBF0),
    surfaceContainerHighest: Color(0xFFE0E5EA),

    // Outlines
    onSurfaceVariant: AppColors.slate700,
    outline: Color(0xFF73777F),
    outlineVariant: Color(0xFFC3C7CF),

    // Inverse
    inverseSurface: Color(0xFF2E3033),
    // inverseOnSurface: Color(0xFFF0F0F4),
    inversePrimary: AppColors.indigo200,
    surfaceTint: AppColors.indigo500,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: AppColors.indigo200,
    onPrimary: AppColors.indigo800,
    primaryContainer: AppColors.indigo700,
    onPrimaryContainer: AppColors.indigo100,

    // Secondary
    secondary: AppColors.teal200,
    onSecondary: AppColors.teal900,
    secondaryContainer: AppColors.teal700,
    onSecondaryContainer: AppColors.teal100,

    // Tertiary
    tertiary: AppColors.mint200,
    onTertiary: AppColors.mint950,
    tertiaryContainer: AppColors.mint800,
    onTertiaryContainer: AppColors.mint100,

    // Errors
    error: AppColors.errorRedContainer,
    onError: AppColors.errorRedDark,
    errorContainer: AppColors.errorRedDarkContainer,
    onErrorContainer: AppColors.errorRedContainer,
    surface: AppColors.darkSlate950,
    onSurface: AppColors.darkSlate200,
    surfaceDim: AppColors.darkSlate950,
    surfaceBright: AppColors.darkSlate500,
    surfaceContainerLowest: AppColors.darkSlate900,
    surfaceContainerLow: AppColors.darkSlate900,
    surfaceContainer: AppColors.darkSlate800,
    surfaceContainerHigh: AppColors.darkSlate700,
    surfaceContainerHighest: AppColors.darkSlate600,

    // Outlines
    onSurfaceVariant: AppColors.darkSlate300,
    // outline: AppColors.outline, // Fallback to outline
    outlineVariant: AppColors.darkSlate600,

    // Inverse
    inverseSurface: AppColors.slate900,
    // inverseOnSurface: AppColors.slate50,
    inversePrimary: AppColors.indigo500,
    surfaceTint: AppColors.indigo200,
  );
}

extension ColorSchemeExtension on ColorScheme {
  Color get success => brightness == Brightness.light
      ? const Color(0xFF1A8754)
      : const Color(0xFF46C37B);

  Color get lateStatus => brightness == Brightness.light
      ? const Color(0xFFD97706)
      : const Color(0xFFFBBF24);

  Color get absent => brightness == Brightness.light
      ? const Color(0xFFDC3545)
      : const Color(0xFFE63946);
}
