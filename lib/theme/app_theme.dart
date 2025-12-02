import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Helper method for Light Theme
ThemeData buildLightTheme() {
  // Classic, Trusted Palette (Light)
  const Color navyBlue = Color(0xFF002868);
  const Color white = Color(0xFFFFFFFF);
  const Color lightGray = Color(0xFFF6F8FA);
  const Color gold = Color(0xFFFFD700);
  const Color accessibleGreen = Color(0xFF007A4D);
  const Color red = Color(0xFFBF0A30);

  final baseTheme = ThemeData.light(useMaterial3: true);

  return baseTheme.copyWith(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navyBlue,
      brightness: Brightness.light,
      primary: navyBlue,
      onPrimary: white,
      secondary: gold,
      onSecondary: navyBlue,
      surface: white,
      onSurface: navyBlue,
      error: red,
      onError: white,
    ),
    scaffoldBackgroundColor: lightGray,
    appBarTheme: const AppBarTheme(
      backgroundColor: navyBlue,
      foregroundColor: white,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: navyBlue), // Default icon color
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: navyBlue),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 30, fontWeight: FontWeight.bold, color: navyBlue),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: navyBlue),
      titleLarge: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: navyBlue),
      titleMedium: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: navyBlue),
      titleSmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: navyBlue),
      bodyLarge: GoogleFonts.lato(fontSize: 18, color: navyBlue),
      bodyMedium: GoogleFonts.lato(fontSize: 16, color: navyBlue),
      bodySmall: GoogleFonts.lato(fontSize: 14, color: navyBlue),
      labelLarge: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.w300, color: navyBlue),
      labelSmall: GoogleFonts.lato(
          fontSize: 12, fontWeight: FontWeight.w300, color: navyBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accessibleGreen,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: navyBlue.withOpacity(0.8),
      labelStyle: GoogleFonts.lato(color: navyBlue.withOpacity(0.8)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: navyBlue.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: navyBlue)),
    ),
  );
}

// Helper method for Dark Theme
ThemeData buildDarkTheme() {
  const Color navyBlue = Color(0xFF002868);
  const Color darkSurface = Color(0xFF121212);
  const Color darkOnSurface = Color(0xFFE4E4E4);
  const Color gold = Color(0xFFFFD700);
  const Color accessibleGreen = Color(0xFF007A4D);
  const Color red = Color(0xFFCF6679); // Material spec dark theme error color

  final baseTheme = ThemeData.dark(useMaterial3: true);

  return baseTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navyBlue,
      brightness: Brightness.dark,
      primary: navyBlue,
      onPrimary: darkOnSurface,
      secondary: gold,
      onSecondary: navyBlue,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: red,
      onError: darkSurface,
    ),
    scaffoldBackgroundColor: darkSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: darkOnSurface,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: darkOnSurface), // Default icon color
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: darkOnSurface),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 30, fontWeight: FontWeight.bold, color: darkOnSurface),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: darkOnSurface),
      titleLarge: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: darkOnSurface),
      titleMedium: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: darkOnSurface),
      titleSmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: darkOnSurface),
      bodyLarge: GoogleFonts.lato(fontSize: 18, color: darkOnSurface),
      bodyMedium: GoogleFonts.lato(fontSize: 16, color: darkOnSurface),
      bodySmall: GoogleFonts.lato(fontSize: 14, color: darkOnSurface),
      labelLarge: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.w300, color: darkOnSurface),
      labelSmall: GoogleFonts.lato(
          fontSize: 12, fontWeight: FontWeight.w300, color: darkOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accessibleGreen,
        foregroundColor: darkOnSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: darkOnSurface.withOpacity(0.8),
      labelStyle: GoogleFonts.lato(color: darkOnSurface.withOpacity(0.8)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkOnSurface.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkOnSurface)),
    ),
  );
}
