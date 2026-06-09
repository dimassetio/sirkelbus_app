import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light {
    final interBase = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.skyBlue,
        onSecondary: Colors.white,
        error: AppColors.error,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.sectionBackground,
      ),
      scaffoldBackgroundColor: AppColors.pageBackground,
      textTheme: interBase.copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textCaption),
        labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        labelMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textCaption),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.borderSecondary),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textCaption),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textCaption),
        floatingLabelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.navy, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: Color(0xFF94A3B8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
    );
  }
}
