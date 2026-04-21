import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stripe / Notion inspired: soft neutrals, restrained accent, generous radius.
class AppTheme {
  static const _radius = 14.0;

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAFC),
    );
    return _build(base);
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
      surface: const Color(0xFF0E1628),
      onSurface: const Color(0xFFE7ECF7),
      onSurfaceVariant: const Color(0xFFBEC8DF),
      outlineVariant: const Color(0xFF3A4664),
      primary: const Color(0xFF8D92FF),
    );
    return _build(base);
  }

  static ThemeData _build(ColorScheme scheme) {
    final text = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh.withValues(alpha: scheme.brightness == Brightness.dark ? 0.78 : 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: scheme.brightness == Brightness.dark ? 0.6 : 0.35)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: scheme.brightness == Brightness.dark ? 0.72 : 0.4),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.9)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: scheme.brightness == Brightness.dark ? 0.75 : 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: scheme.brightness == Brightness.dark ? 0.7 : 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: scheme.brightness == Brightness.dark ? 0.6 : 0.35)),
        backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: scheme.brightness == Brightness.dark ? 0.72 : 0.5),
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: text.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
        dividerThickness: 0.4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
