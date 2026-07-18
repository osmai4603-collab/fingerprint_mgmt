import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const NOTO_NASKH_ARABIC = 'Noto_Naskh_Arabic';

class AppTheme {
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 68,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: NOTO_NASKH_ARABIC,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(brightness: Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(brightness: Brightness.dark);
  }

  static ThemeData _buildTheme({Brightness brightness = Brightness.light}) {
    final colorScheme = brightness == Brightness.light
        ? AppColorScheme.light
        : AppColorScheme.dark;
    final textTheme = _buildTextTheme(colorScheme);
    return ThemeData(
      // cardColor: colorScheme.surfaceContainer,
      cardTheme: CardThemeData(color: colorScheme.surfaceContainerHigh),
      brightness: brightness,
      fontFamily: NOTO_NASKH_ARABIC,

      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      colorScheme: colorScheme,
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodySmall,
        inputDecorationTheme: _getInputDecoration(
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
      ),

      inputDecorationTheme: _getInputDecoration(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .circular(4.0)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          fontFamily: NOTO_NASKH_ARABIC,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: NOTO_NASKH_ARABIC,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: NOTO_NASKH_ARABIC,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontFamily: NOTO_NASKH_ARABIC,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontFamily: NOTO_NASKH_ARABIC,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      useMaterial3: true,
      listTileTheme: ListTileThemeData(tileColor: colorScheme.surfaceContainer),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainer,
          foregroundColor: colorScheme.onSurface,
          textStyle: const TextStyle(
            fontFamily: NOTO_NASKH_ARABIC,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  static InputDecorationThemeData _getInputDecoration({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) => InputDecorationThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),

    hintStyle: textTheme.labelSmall,
    labelStyle: textTheme.labelMedium,

    errorStyle: textTheme.labelMedium!.copyWith(color: colorScheme.error),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colorScheme.primary),
    ),
    fillColor: colorScheme.surfaceContainer,
    filled: true,
    isDense: true,
    prefixIconConstraints: BoxConstraints(maxWidth: 40, minWidth: 40),
    suffixIconConstraints: BoxConstraints(maxWidth: 40),
  );
}
