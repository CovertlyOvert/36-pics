import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFAF3E0);
  static const foreground = Color(0xFF4A3F35);
  static const primary = Color(0xFF704214);
  static const primaryForeground = Color(0xFFFAF3E0);
  static const secondary = Color(0xFFB6895B);
  static const muted = Color(0xFFF1F0EB);
  static const border = Color(0xFFE5DED0);
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF4A3F35);
}

class AppFonts {
  static const heading = 'PlayfairDisplay';
  static const body = 'Inter';
  static const mono = 'Courier Prime';
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: AppFonts.body,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.foreground,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Courier Prime',
      fontSize: 14,
    ),
  ),
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.card,
  ),
);
