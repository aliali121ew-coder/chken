import 'package:flutter/material.dart';

/// Shared corner radius values used across the design system.
abstract final class AppRadius {
  static const double pill = 50;
  static const double card = 16;
  static const double input = 24;
  static const double image = 12;
  static const double dialog = 28;
  static const double bottomSheet = 28;

  static BorderRadius get pillRadius => BorderRadius.circular(pill);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get imageRadius => BorderRadius.circular(image);
  static BorderRadius get dialogRadius => BorderRadius.circular(dialog);

  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
}
