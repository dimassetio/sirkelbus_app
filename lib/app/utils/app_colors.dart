import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const navy900 = Color(0xFF0F172A);
  static const navy = Color(0xFF14213D);
  static const navyHover = Color(0xFF1E3A5F);
  static const navyLight = Color(0xFFE8EEF8);

  // Secondary
  static const skyBlue = Color(0xFF3B82F6);
  static const skyBlueLight = Color(0xFFDBEAFE);

  // Accent (discounts / promotions only, never CTA)
  static const amber = Color(0xFFF59E0B);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Backgrounds
  static const pageBackground = Color(0xFFF8FAFC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const sectionBackground = Color(0xFFF1F5F9);
  static const disabled = Color(0xFFE2E8F0);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textCaption = Color(0xFF64748B);
  static const textDisabled = Color(0xFF94A3B8);

  // Border
  static const border = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF14213D);
  static const borderSecondary = Color(0xFFCBD5E1);
}
