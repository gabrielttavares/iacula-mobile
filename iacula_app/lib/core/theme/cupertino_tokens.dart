import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class IaculaColorScheme {
  final Color background;
  final Color card;
  final Color title;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryButton;
  final Color success;
  final Color warning;
  final Color error;
  final Color separator;
  final Color placeholder;
  final Color systemGray6;
  final Color secondaryButton;
  final Color bannerBackground;
  final Color bannerForeground;
  final Color homeWarmBackground;
  final Color homeSacredAccent;
  final Color homeHeroTop;
  final Color homeHeroBottom;
  final Color homeHeroText;
  final Color homeHeroSubtext;
  final Color homeHeroLabel;
  final Color homeHeroFallback;

  const IaculaColorScheme._({
    required this.background,
    required this.card,
    required this.title,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryButton,
    required this.success,
    required this.warning,
    required this.error,
    required this.separator,
    required this.placeholder,
    required this.systemGray6,
    required this.secondaryButton,
    required this.bannerBackground,
    required this.bannerForeground,
    required this.homeWarmBackground,
    required this.homeSacredAccent,
    required this.homeHeroTop,
    required this.homeHeroBottom,
    required this.homeHeroText,
    required this.homeHeroSubtext,
    required this.homeHeroLabel,
    required this.homeHeroFallback,
  });

  static const dark = IaculaColorScheme._(
    background: Color(0xFF121212), // soft black, not pure #000000
    card: Color(0xFF1C1C1E), // secondarySystemGroupedBackground dark
    title: Color(0xFFFFFFFF), // label
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA0A0A0), // Adjusted for better contrast as requested
    primaryButton: Color(0xFF0A84FF), // activeBlue dark
    success: Color(0xFF30D158), // systemGreen dark
    warning: Color(0xFFFF9F0A), // systemOrange dark
    error: Color(0xFFFF453A), // systemRed dark
    separator: Color(0xFF38383A), // separator dark
    placeholder: Color(0xFF48484A), // systemGrey4 dark
    systemGray6: Color(0xFF1C1C1E),
    secondaryButton: Color(0x33FFFFFF),
    bannerBackground: Color(0xFF2C2C2E), // elevated gray
    bannerForeground: Color(0xFFFFE082),
    homeWarmBackground: Color(0xFF121212),
    homeSacredAccent: Color(0xFF0A84FF),
    homeHeroTop: Color(0x40000000), // 0.25 opacity black
    homeHeroBottom: Color(0x99000000), // 0.6 opacity black
    homeHeroText: Color(0xFFFFFFFF),
    homeHeroSubtext: Color(0x99FFFFFF),
    homeHeroLabel: Color(0x47FFFFFF),
    homeHeroFallback: Color(0xFF1C1C1E),
  );

  static const light = IaculaColorScheme._(
    background: Color(0xFFF5F3EF),
    card: Color(0xFFFFFFFF),
    title: Color(0xFF030D22),
    textPrimary: Color(0xFF030D22),
    textSecondary: Color(0xFF5A6478),
    primaryButton: Color(0xFF0975C8),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    error: Color(0xFFFF3B30),
    separator: Color(0x1A000000),
    placeholder: Color(0xFFE7E7EC),
    systemGray6: Color(0xFFF2F2F7),
    secondaryButton: Color(0x1A000000),
    bannerBackground: Color(0xFFFFF3CD),
    bannerForeground: Color(0xFF856404),
    homeWarmBackground: Color(0xFFF5F3EF),
    homeSacredAccent: Color(0xFF0975C8),
    homeHeroTop: Color(0x4D000000),
    homeHeroBottom: Color(0xDB000000),
    homeHeroText: Color(0xFFF6F6F8),
    homeHeroSubtext: Color(0x99F6F6F8),
    homeHeroLabel: Color(0x47FFFFFF),
    homeHeroFallback: Color(0xFF3D3125),
  );
}

/// Deprecated: use `context.colors` instead.
@Deprecated('Use context.colors instead')
final class IaculaColors {
  IaculaColors._();

  static const background = Color(0xFF121212);
  static const card = Color(0xFF1C1C1E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const primaryButton = Color(0xFF0A84FF);
  static const success = Color(0xFF30D158);
  static const warning = Color(0xFFFF9F0A);
  static const error = Color(0xFFFF453A);
  static const separator = Color(0xFF38383A);
  static const homeWarmBackground = Color(0xFF121212);
  static const homeSacredAccent = Color(0xFF0A84FF);
  static const homeHeroTop = Color(0xFF000000);
  static const homeHeroBottom = Color(0xFF1C1C1E);
}

class IaculaTextScheme {
  final TextStyle largeTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle secondary;
  final TextStyle readingBody;
  final TextStyle tabLabel;

  const IaculaTextScheme._({
    required this.largeTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.secondary,
    required this.readingBody,
    required this.tabLabel,
  });

  factory IaculaTextScheme.from(BuildContext context, IaculaColorScheme colors) {
    final scaler = MediaQuery.textScalerOf(context);
    return IaculaTextScheme._(
      largeTitle: GoogleFonts.lora(
        fontSize: scaler.scale(34),
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: colors.title,
      ),
      sectionTitle: GoogleFonts.lora(
        fontSize: scaler.scale(20), // Adjusted to 20-22 as requested
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: colors.title,
      ),
      cardTitle: GoogleFonts.inter(
        fontSize: scaler.scale(16), // Adjusted to 15-16 as requested
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: colors.title,
      ),
      secondary: GoogleFonts.inter(
        fontSize: scaler.scale(15),
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      readingBody: GoogleFonts.lora(
        fontSize: scaler.scale(17),
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colors.textPrimary,
      ),
      tabLabel: GoogleFonts.inter(
        fontSize: scaler.scale(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  factory IaculaTextScheme.fromColors(IaculaColorScheme colors) =>
      IaculaTextScheme._(
        largeTitle: GoogleFonts.lora(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: colors.title,
        ),
        sectionTitle: GoogleFonts.lora(
          fontSize: 20, // Adjusted
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: colors.title,
        ),
        cardTitle: GoogleFonts.inter(
          fontSize: 16, // Adjusted
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: colors.title,
        ),
        secondary: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        readingBody: GoogleFonts.lora(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: colors.textPrimary,
        ),
        tabLabel: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      );
}

/// Deprecated: use `context.textStyles` instead.
@Deprecated('Use context.textStyles instead')
final class IaculaText {
  IaculaText._();

  static final largeTitle = GoogleFonts.lora(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: const Color(0xFFF7F5EC),
  );

  static final sectionTitle = GoogleFonts.lora(
    fontSize: 20, // Adjusted
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: const Color(0xFFF7F5EC),
  );

  static final cardTitle = GoogleFonts.inter(
    fontSize: 16, // Adjusted
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: const Color(0xFFF7F5EC),
  );

  static final secondary = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: IaculaColorScheme.dark.textSecondary,
  );

  static final readingBody = GoogleFonts.lora(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: IaculaColorScheme.dark.textPrimary,
  );

  static final tabLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}

extension IaculaThemeX on BuildContext {
  IaculaColorScheme get colors {
    final brightness = CupertinoTheme.brightnessOf(this);
    return brightness == Brightness.dark
        ? IaculaColorScheme.dark
        : IaculaColorScheme.light;
  }

  IaculaTextScheme get textStyles => IaculaTextScheme.from(this, colors);
}

final class IaculaShadows {
  IaculaShadows._();

  // Card shadows — floating layer metaphor
  static const cardResting = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const cardPressed = [
    BoxShadow(color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  // Backward compat alias
  static const card = cardResting;

  // Button shadows — spring compression metaphor
  static const buttonResting = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const buttonPressed = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
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
  static const card = 18.0;
  static const banner = 18.0;
  static const innerPadding = 24.0; // Added for internal card padding
  static const cardSpacing = 24.0; // Added for spacing between cards
  static const elementSpacing = 16.0; // Added for spacing between elements inside card
}

final class IaculaMetrics {
  IaculaMetrics._();

  static const inputHeight = 44.0;
  static const modalCornerRadius = 24.0;
  static const minTapTarget = 44.0;
}
