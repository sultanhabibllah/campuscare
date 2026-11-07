import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const green = Color(0xFF437F10);
  static const ink = Color(0xFF171923);
  static const muted = Color(0xFF686D79);
  static const pale = Color(0xFFF0F5F3);
  static const field = Color(0xFFF0F2F4);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFBFDFC),
    colorScheme: ColorScheme.fromSeed(seedColor: green, primary: green),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFBFDFC), foregroundColor: ink,
      centerTitle: false, elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink),
      headlineMedium: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
      bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: field,
      hintStyle: const TextStyle(color: muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: green)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: green, foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    )),
    cardTheme: CardThemeData(
      color: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8ECE9))),
    ),
  );
}
