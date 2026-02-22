import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1D3557),
      onPrimary: Colors.white,
      secondary: Color(0xFFD4AF37),
      onSecondary: Color(0xFF1E1B16),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1D3557),
      ),
    );

    final textTheme = base.textTheme.copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        height: 1,
        color: Colors.black,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.08,
        color: Colors.black,
      ),
      titleMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyLarge: GoogleFonts.libreBaskerville(
        fontSize: 15,
        height: 1.6,
        color: Colors.black,
      ),
      bodyMedium: GoogleFonts.libreBaskerville(
        fontSize: 13,
        height: 1.55,
        color: Colors.black87,
      ),
      labelSmall: GoogleFonts.libreBaskerville(
        fontSize: 11,
        letterSpacing: 1.4,
        color: Colors.black54,
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
