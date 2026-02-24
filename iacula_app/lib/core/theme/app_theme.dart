import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  AppTheme._();

  static const Color nearlyWhite = Color(0xFFFFFFFF);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color darkGrey = Color(0xFF313A44);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color background = Color(0xFFEDF0F2); // The template's notWhite bg

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: nearlyBlue,
      onPrimary: nearlyWhite,
      secondary: nearlyBlue,
      onSecondary: nearlyWhite,
      surface: nearlyWhite,
      onSurface: darkerText,
      onSurfaceVariant: darkText,
    );

    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 36,
        letterSpacing: 0.4,
        color: darkerText,
      ),
      headlineMedium: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0.27,
        color: darkerText,
      ),
      headlineSmall: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 0.27,
        color: darkerText,
      ),
      titleLarge: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.18,
        color: darkerText,
      ),
      titleMedium: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: -0.04,
        color: darkText,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: -0.05,
        color: darkText,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.2,
        color: darkText,
      ),
      labelSmall: GoogleFonts.workSans(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.2,
        color: lightText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: nearlyBlack),
        titleTextStyle: TextStyle(
          fontFamily: 'WorkSans',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: darkerText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: nearlyWhite,
        selectedItemColor: nearlyBlue,
        unselectedItemColor: grey,
        elevation: 0,
      ),
    );
  }
}
