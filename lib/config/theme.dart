// lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const primary   = Color(0xFF1e3a5f);
  static const primary2  = Color(0xFF2d5f9e);
  static const accent    = Color(0xFF10b981);
  static const warning   = Color(0xFFf59e0b);
  static const danger    = Color(0xFFef4444);
  static const bg        = Color(0xFFf8fafc);
  static const card      = Color(0xFFffffff);
  static const textMain  = Color(0xFF1e293b);
  static const textMuted = Color(0xFF64748b);
  static const border    = Color(0xFFe2e8f0);

  // Grade colors
  static const gradeColors = [
    Color(0xFF10b981), Color(0xFF3b82f6), Color(0xFFef4444),
    Color(0xFF8b5cf6), Color(0xFFf59e0b), Color(0xFF06b6d4),
    Color(0xFF84cc16), Color(0xFFf97316), Color(0xFFec4899),
    Color(0xFF6366f1),
  ];

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    fontFamily: 'Padauk',
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Padauk', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: card, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary2, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Padauk', fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
