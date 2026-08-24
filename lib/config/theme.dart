import 'package:flutter/material.dart';
import '../constants/Colors.dart';

class AppTheme {
  /// 🌞 Light Theme — matches Indicab user app design system
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    // 🎨 Core colors
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.white,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    // 🧾 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // 🧾 Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    // 🧠 Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  /// 🌚 Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.black,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
