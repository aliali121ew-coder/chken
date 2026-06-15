import 'package:flutter/material.dart';

/// Per-store dynamic theme — derived from the `stores` table colors
/// (gradient_start, gradient_end, primary_color, secondary_color).
///
/// When a user opens a store page, this theme replaces the default
/// [ColorScheme] so the whole UI adopts the store's branding.
@immutable
class StoreTheme {
  const StoreTheme({
    required this.gradientStart,
    required this.gradientEnd,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final Color gradientStart;
  final Color gradientEnd;
  final Color primaryColor;
  final Color secondaryColor;

  factory StoreTheme.fromHex({
    required String gradientStart,
    required String gradientEnd,
    required String primaryColor,
    required String secondaryColor,
  }) {
    return StoreTheme(
      gradientStart: _colorFromHex(gradientStart),
      gradientEnd: _colorFromHex(gradientEnd),
      primaryColor: _colorFromHex(primaryColor),
      secondaryColor: _colorFromHex(secondaryColor),
    );
  }

  static Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    return Color(int.parse(value, radix: 16));
  }

  /// Generates a full [ColorScheme] seeded from this store's primary color.
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
  }

  /// The signature gradient used on store headers, cards and accent bars.
  /// In dark mode the colors are darkened to avoid eye strain.
  LinearGradient gradient(Brightness brightness) {
    final start = brightness == Brightness.dark
        ? _darken(gradientStart)
        : gradientStart;
    final end = brightness == Brightness.dark
        ? _darken(gradientEnd)
        : gradientEnd;

    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color _darken(Color color, [double amount = 0.25]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
