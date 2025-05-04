import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ThirtySixPicsApp());
}

class ThirtySixPicsApp extends StatelessWidget {
  const ThirtySixPicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '36 Pics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
