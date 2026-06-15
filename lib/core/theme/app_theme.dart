import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_theme.dart';
import 'store_theme.dart';

/// Builds the app's [ThemeData] for light/dark mode, optionally overridden
/// by a [StoreTheme] when the user is browsing a specific store.
abstract final class AppTheme {
  static ThemeData light({Locale locale = const Locale('ar'), StoreTheme? storeTheme}) {
    return _build(
      locale: locale,
      brightness: Brightness.light,
      colorScheme: storeTheme?.toColorScheme(Brightness.light) ??
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
      backgroundColor: AppColors.backgroundLight,
      surfaceColor: AppColors.surfaceLight,
    );
  }

  static ThemeData dark({Locale locale = const Locale('ar'), StoreTheme? storeTheme}) {
    return _build(
      locale: locale,
      brightness: Brightness.dark,
      colorScheme: storeTheme?.toColorScheme(Brightness.dark) ??
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
      backgroundColor: AppColors.backgroundDark,
      surfaceColor: AppColors.surfaceDark,
    );
  }

  static ThemeData _build({
    required Locale locale,
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color surfaceColor,
  }) {
    final textTheme = AppTextTheme.of(locale, colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheetRadius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
}
