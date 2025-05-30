import 'package:flutter/material.dart';

class AppTheme {
  // Color constants - More yellowish theme
  static const Color primaryYellow = Color(0xFFFFF3B0);  // More vibrant yellow
  static const Color secondaryYellow = Color(0xFFFFEB3B); // Bright yellow
  static const Color accentOrange = Color(0xFFFFB74D);   // Orange-yellow
  static const Color deepOrange = Color(0xFFFFA000);     // Deep yellow-orange

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.amber,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: primaryYellow,
    );
  }

  // Common text styles
  static TextStyle get titleStyle => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.brown.shade800,
    shadows: [
      Shadow(
        color: Colors.amber.withOpacity(0.5),
        offset: const Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static TextStyle get subtitleStyle => TextStyle(
    fontSize: 16,
    color: Colors.brown.shade700,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyStyle => TextStyle(
    fontSize: 14,
    color: Colors.brown.shade600,
    fontWeight: FontWeight.w500,
  );

  // Common decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.amber.shade100.withOpacity(0.9),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.amber.shade300, width: 2),
  );

  static BoxDecoration get progressBarDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.amber.shade400, width: 3),
    boxShadow: [
      BoxShadow(
        color: Colors.amber.withOpacity(0.3),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );
}
