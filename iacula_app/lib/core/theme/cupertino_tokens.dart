import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

final class IaculaColors {
  IaculaColors._();

  static const background = Color(0xFF030D22);
  static const card = Color(0xFF0C1938);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9AA9CD);
  static const primaryButton = Color(0xFFF7F5EC);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const separator = Color(0x33000000);
  static const homeWarmBackground = Color(0xFF030D22);
  static const homeSacredAccent = Color(0xFFF7F5EC);
  static const homeHeroTop = Color(0xFF030D22);
  static const homeHeroBottom = Color(0xFF05102A);
}

final class IaculaShadows {
  IaculaShadows._();

  static const card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

final class IaculaSpacing {
  IaculaSpacing._();

  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

final class IaculaRadius {
  IaculaRadius._();

  static const small = 12.0;
  static const card = 24.0;
  static const banner = 24.0;
}

final class IaculaMetrics {
  IaculaMetrics._();

  static const inputHeight = 44.0;
  static const modalCornerRadius = 24.0;
  static const minTapTarget = 44.0;
}

final class IaculaText {
  IaculaText._();

  static final largeTitle = GoogleFonts.lora(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFF7F5EC),
  );

  static final sectionTitle = GoogleFonts.lora(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFF7F5EC),
  );

  static final cardTitle = GoogleFonts.lora(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFF7F5EC),
  );

  static final secondary = GoogleFonts.lora(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: IaculaColors.textSecondary,
  );

  static final tabLabel = GoogleFonts.lora(
    fontSize: 11, 
    fontWeight: FontWeight.w500,
  );
}
