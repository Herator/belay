import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BelayColors {
  static const background = Color(0xFF0A0E1A);
  static const surface = Color(0xFF141928);
  static const card = Color(0xFF1E2538);
  static const accent = Color(0xFFFF6B35);
  static const teal = Color(0xFF4ECDC4);
  static const purple = Color(0xFF7B68EE);
  static const gold = Color(0xFFFFD166);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8892B0);
  static const border = Color(0xFF2A3350);
  static const success = Color(0xFF6BCB77);
  static const error = Color(0xFFFF4D6D);
}

class BelayTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: BelayColors.accent,
        secondary: BelayColors.teal,
        surface: BelayColors.surface,
        error: BelayColors.error,
      ),
      scaffoldBackgroundColor: BelayColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: BelayColors.textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: BelayColors.textPrimary),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: BelayColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: BelayColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: BelayColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: BelayColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: BelayColors.textSecondary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: BelayColors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BelayColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: BelayColors.textPrimary),
        iconTheme: const IconThemeData(color: BelayColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: BelayColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BelayColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BelayColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: BelayColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BelayColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BelayColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BelayColors.accent, width: 1.5)),
        labelStyle: const TextStyle(color: BelayColors.textSecondary),
        hintStyle: const TextStyle(color: BelayColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BelayColors.card,
        selectedColor: Color(0x33FF6B35),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: BelayColors.textPrimary),
        side: const BorderSide(color: BelayColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BelayColors.surface,
        selectedItemColor: BelayColors.accent,
        unselectedItemColor: BelayColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: BelayColors.border, space: 0),
      sliderTheme: const SliderThemeData(
        activeTrackColor: BelayColors.accent,
        inactiveTrackColor: BelayColors.border,
        thumbColor: BelayColors.accent,
        valueIndicatorColor: BelayColors.accent,
      ),
    );
  }
}
