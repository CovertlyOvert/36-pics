import 'package:flutter/material.dart';

enum AppThemeMode { vintage, darkroom }

class _Palette {
  final Color background;
  final Color foreground;
  final Color foregroundSoft;
  final Color primary;
  final Color primaryDeep;
  final Color primaryForeground;
  final Color secondary;
  final Color muted;
  final Color border;
  final Color card;
  final Color cardForeground;

  const _Palette({
    required this.background,
    required this.foreground,
    required this.foregroundSoft,
    required this.primary,
    required this.primaryDeep,
    required this.primaryForeground,
    required this.secondary,
    required this.muted,
    required this.border,
    required this.card,
    required this.cardForeground,
  });
}

const _vintagePalette = _Palette(
  background: Color(0xFFFAF3E0),
  foreground: Color(0xFF4A3F35),
  foregroundSoft: Color(0xFF8A7F6E),
  primary: Color(0xFF704214),
  primaryDeep: Color(0xFF4F2E15),
  primaryForeground: Color(0xFFFAF3E0),
  secondary: Color(0xFFB6895B),
  muted: Color(0xFFF1F0EB),
  border: Color(0xFFE5DED0),
  card: Color(0xFFFFFFFF),
  cardForeground: Color(0xFF4A3F35),
);

// Darkroom: lit the way a real photo darkroom is — a red safelight glow
// against near-black, since that's the one color film paper isn't exposed by.
const _darkroomPalette = _Palette(
  background: Color(0xFF1E1A17),
  foreground: Color(0xFFF2E9DC),
  foregroundSoft: Color(0xFF9C8F7E),
  primary: Color(0xFFB2362A),
  primaryDeep: Color(0xFF5C1B14),
  primaryForeground: Color(0xFFF2E9DC),
  secondary: Color(0xFFC98A3D),
  muted: Color(0xFF2A2420),
  border: Color(0xFF3A332C),
  card: Color(0xFFFCF8EE),
  cardForeground: Color(0xFF2B241C),
);

/// Holds which theme is active and notifies the app to rebuild when it
/// changes. A plain singleton ChangeNotifier keeps this simple without
/// pulling in a state-management package for one toggle.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  AppThemeMode _mode = AppThemeMode.vintage;
  AppThemeMode get mode => _mode;

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    setMode(_mode == AppThemeMode.vintage
        ? AppThemeMode.darkroom
        : AppThemeMode.vintage);
  }
}

class AppColors {
  static _Palette get _active => ThemeController.instance.mode == AppThemeMode.vintage
      ? _vintagePalette
      : _darkroomPalette;

  static Color get background => _active.background;
  static Color get foreground => _active.foreground;
  static Color get foregroundSoft => _active.foregroundSoft;
  static Color get primary => _active.primary;
  static Color get primaryDeep => _active.primaryDeep;
  static Color get primaryForeground => _active.primaryForeground;
  static Color get secondary => _active.secondary;
  static Color get muted => _active.muted;
  static Color get border => _active.border;
  static Color get card => _active.card;
  static Color get cardForeground => _active.cardForeground;
}

class AppFonts {
  static const heading = 'PlayfairDisplay';
  static const body = 'Inter';
  static const mono = 'Courier Prime';
}

ThemeData buildAppTheme() {
  final isDarkroom = ThemeController.instance.mode == AppThemeMode.darkroom;
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.body,
    brightness: isDarkroom ? Brightness.dark : Brightness.light,
    appBarTheme: AppBarTheme(
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
      brightness: isDarkroom ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
    ),
  );
}
