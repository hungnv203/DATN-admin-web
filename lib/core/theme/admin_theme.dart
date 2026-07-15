import 'package:flutter/material.dart';

abstract final class AdminColors {
  static const background = Color(0xFF0A0E17);
  static const surface = Color(0xFF111827);
  static const surfaceHigh = Color(0xFF192234);
  static const primary = Color(0xFF5EEAD4);
  static const secondary = Color(0xFFFFC857);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF94A3B8);
  static const outline = Color(0xFF263248);
  static const danger = Color(0xFFFB7185);
}

abstract final class AdminTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AdminColors.primary,
      brightness: Brightness.dark,
      surface: AdminColors.surface,
      error: AdminColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AdminColors.background,
      dividerColor: AdminColors.outline,
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AdminColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AdminColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: AdminColors.background,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.text,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AdminColors.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingTextStyle: TextStyle(
          color: AdminColors.muted,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: TextStyle(color: AdminColors.text),
        dividerThickness: 0.5,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminColors.surfaceHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AdminColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminColors.outline),
        ),
      ),
    );
  }
}
