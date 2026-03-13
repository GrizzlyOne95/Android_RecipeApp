import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFF6F0E4);
  const surface = Color(0xFFFFFCF5);
  const surfaceTint = Color(0xFFE7D9BF);
  const primary = Color(0xFF7B5138);
  const secondary = Color(0xFF4F6B44);
  const accent = Color(0xFFD87B42);
  const text = Color(0xFF23180F);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: surface,
      surfaceContainerHighest: surfaceTint,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: text,
    ),
    scaffoldBackgroundColor: background,
    cardTheme: const CardThemeData(
      elevation: 0,
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceTint,
      selectedColor: const Color(0xFFF0C6A6),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: GoogleFonts.manrope(color: text, fontWeight: FontWeight.w700),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      bodyLarge: GoogleFonts.manrope(fontSize: 15, color: text, height: 1.45),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 13,
        color: const Color(0xFF5A4638),
        height: 1.4,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface.withValues(alpha: 0.94),
      indicatorColor: const Color(0xFFF0C6A6),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: const Color(0xFFF0C6A6),
      selectedIconTheme: const IconThemeData(color: primary),
      selectedLabelTextStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      unselectedLabelTextStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF6B5B4E),
      ),
    ),
  );
}
