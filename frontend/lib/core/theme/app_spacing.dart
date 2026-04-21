import 'package:flutter/material.dart';

/// Consistent spacing and radii for SaaS layout polish.
abstract final class AppSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;

  static EdgeInsets pagePadding([double factor = 1]) =>
      EdgeInsets.all(lg * factor);

  static const listGap = SizedBox(height: md);
  static const rowGap = SizedBox(width: md);
}
