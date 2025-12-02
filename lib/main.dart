import 'package:flutter/material.dart';
import 'package:khel_mitra/screens/splash_screen.dart';
import 'package:khel_mitra/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khel Mitra',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode:
      ThemeMode.system, // Automatically switch based on system settings
      home: const SplashScreen(),
    );
  }
}
