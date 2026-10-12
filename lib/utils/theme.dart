import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main  colors
  static const Color navy = Color(0xFF0B1F3A); // buttons, headings
  static const Color navySurface = Color(0xFF13294B); // dark cards
  static const Color gold = Color(0xFFC9A24B); // accents, icons, lines
  static const Color goldLight = Color(0xFFF1E3BE); // soft gold background

  // Backgrounds
  static const Color ivory = Color(0xFFFAF7F0); // screen background
  static const Color card = Color(0xFFFFFFFF); // white cards

  // Text
  static const Color text = Color(0xFF0B1F3A); // main text
  static const Color muted = Color(0xFF6B7280); // secondary text

  // Status
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFB3261E);
}

ThemeData appTheme() {
  // Body font 
  final baseText = ThemeData.light().textTheme;

  // Headings font 
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
      primary: AppColors.navy,
      secondary: AppColors.gold,
      error: AppColors.error,
      surface: AppColors.card,
    ),

    // Top bar
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

    // Main button: navy
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.ivory,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Second button: gold outline
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.gold, width: 1.2),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
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
    ),

    // Cards: white, rounded, thin gold line
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,  
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
    ),

    // Event / Party / categories
    chipTheme: ChipThemeData(
      labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.navy),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: DividerThemeData(
      color: AppColors.gold.withValues(alpha: 0.3),
      thickness: 1,
    ),
  );
}
