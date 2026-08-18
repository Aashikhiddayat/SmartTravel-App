import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const navy = Color(0xFF103B4C);
    const teal = Color(0xFF287E79);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal, secondary: navy, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      appBarTheme: const AppBarTheme(centerTitle: false, backgroundColor: Color(0xFFF7FAF8), foregroundColor: navy),
      cardTheme: CardThemeData(elevation: 0, margin: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    );
  }
}
