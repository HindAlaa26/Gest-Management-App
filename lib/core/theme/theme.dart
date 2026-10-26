import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep teal-navy (sidebar color of the dashboard): headers, dark cards, dark text
  static const Color navy = Color(0xFF0F3043);
  static const Color navySurface = Color(0xFF17394C);
  static const Color navyDeep = Color(0xFF0B2536);

  // Teal accent (dashboard buttons, links, active items)
  static const Color teal = Color(0xFF158A84);
  static const Color tealLight = Color(0xFF3DAFA9);
  static const Color tealSoft = Color(0xFFE3F2F1);

  // Gold (logo letter and small uppercase labels)
  static const Color gold = Color(0xFFD2AE6D);
  static const Color goldDeep = Color(0xFFA9803F);
  static const Color goldLight = Color(0xFFF3E6CC);

  // Silver tier and neutral soft grey
  static const Color silver = Color(0xFF94A3B8);
  static const Color silverSoft = Color(0xFFE2E8F0);
  static const Color silverDeep = Color(0xFF475569);
  static const Color softGrey = Color(0xFFEEF2F4);

  // Platinum tier: charcoal "black card"
  static const Color charcoal = Color(0xFF2A2D34);
  static const Color charcoalDeep = Color(0xFF0F1115);

  // Backgrounds
  static const Color ivory = Color(0xFFF5F8F9);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color text = Color(0xFF0E2433);
  static const Color muted = Color(0xFF64748B);

  // Status
  static const Color success = Color(0xFF1A7F6F);
  static const Color error = Color(0xFFB3261E);
}

ThemeData appTheme() {
  final baseText = ThemeData.light().textTheme;

  final TextTheme textTheme = baseText
      .copyWith(
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
        displayLarge: GoogleFonts.cormorantGaramond(
            fontSize: 44, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.cormorantGaramond(
            fontSize: 36, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.cormorantGaramond(
            fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.cormorantGaramond(
            fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.cormorantGaramond(
            fontSize: 24, fontWeight: FontWeight.w700),
      )
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.ivory,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.teal,
      secondary: AppColors.gold,
      error: AppColors.error,
      surface: AppColors.card,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.ivory,
      foregroundColor: AppColors.navy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        side: const BorderSide(color: AppColors.teal, width: 1.2),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.teal,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.tealSoft),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.teal,
      selectedIconTheme: IconThemeData(color: AppColors.teal),
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.gold.withValues(alpha: 0.4),
      thickness: 1,
    ),
  );
}
