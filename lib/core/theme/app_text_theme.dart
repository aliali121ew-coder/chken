import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds locale-aware [TextTheme]s — Cairo for Arabic, Poppins for English.
abstract final class AppTextTheme {
  static TextTheme of(Locale locale, ColorScheme colorScheme) {
    final base = locale.languageCode == 'ar'
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.poppinsTextTheme();

    return base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
