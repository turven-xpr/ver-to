import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBrick = Color(0xFFD84315);
  static const Color brickSecondary = Color(0xFFBF360C);
  static const Color brickMortar = Color(0xFFE0D8D0);
  static const Color brickLight = Color(0xFFFF8A65);
  static const Color accentGold = Color(0xFFFFB300);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBrick,
      brightness: Brightness.light,
      primary: primaryBrick,
      secondary: const Color(0xFFE65100),
      surface: const Color(0xFFFBF9F7),
      surfaceContainerLowest: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F4F0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF2E2420),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF2E2420)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEBE5DF), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2DDD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2DDD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBrick, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBrick,
      foregroundColor: Colors.white,
      elevation: 3,
    ),
  );
}
