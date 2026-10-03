import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ThirtySixPicsApp());
}

class ThirtySixPicsApp extends StatefulWidget {
  const ThirtySixPicsApp({super.key});

  @override
  State<ThirtySixPicsApp> createState() => _ThirtySixPicsAppState();
}

class _ThirtySixPicsAppState extends State<ThirtySixPicsApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '36 Pics',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
