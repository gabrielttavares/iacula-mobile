import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF8E6438),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFD4AF37),
      onSecondary: Color(0xFF1E1B16),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFF9F4EA),
      onSurface: Color(0xFF2B2419),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F0E4),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );

    final textTheme = base.textTheme.copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        height: 1,
        color: const Color(0xFF2B2419),
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.08,
        color: const Color(0xFF2B2419),
      ),
      titleMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2B2419),
      ),
      bodyLarge: GoogleFonts.libreBaskerville(
        fontSize: 15,
        height: 1.6,
        color: const Color(0xFF2B2419),
      ),
      bodyMedium: GoogleFonts.libreBaskerville(
        fontSize: 13,
        height: 1.55,
        color: const Color(0xFF5F5342),
      ),
      labelSmall: GoogleFonts.libreBaskerville(
        fontSize: 11,
        letterSpacing: 1.4,
        color: const Color(0xFF837562),
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }
}
