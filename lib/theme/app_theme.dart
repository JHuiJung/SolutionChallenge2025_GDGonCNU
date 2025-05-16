import 'package:flutter/material.dart';

class AppTheme {
  // Light theme definition
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Use Material 3 design
    brightness: Brightness.light,
    primaryColor: Colors.purple.shade200, // Bright and vibrant primary color
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple.shade200, // Create entire color scheme from seed color
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[100], // Light background color
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.purple.shade100, // Light AppBar background
      foregroundColor: Colors.black87, // AppBar text/icon color
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade200, // Button background color
        foregroundColor: Colors.white, // Button text color
      ),
    ),
    // Other widget themes can also be customized as needed
  );

  // Dark theme definition
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.purple.shade100, // Primary color in dark mode
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple.shade200, // Seed color
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade100, // Button background color
        foregroundColor: Colors.purple.shade200, // Button text color
      ),
    ),
    // Other widget themes can also be customized as needed
  );
}