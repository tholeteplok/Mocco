import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography for Mocco Design System (v2.0)
/// - Andika for learning display & tracing
/// - Nunito for UI interface & feedback
abstract final class AppTypography {
  /// Display for letters and numbers (120 - 200sp)
  static TextStyle learningDisplay({
    double fontSize = 140.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.andika(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      height: 1.1,
    );
  }

  /// UI Heading (for titles, screen headers)
  static TextStyle uiHeading({
    double fontSize = 28.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  /// UI Subheading / Button text (20 - 24sp)
  static TextStyle uiButton({
    double fontSize = 22.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  /// UI Body / Instruction text (WCAG AAA contrast)
  static TextStyle uiInstruction({
    double fontSize = 20.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// UI Body / Label text
  static TextStyle uiBody({
    double fontSize = 16.0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Brand display text (Fredoka font matching icon launcher)
  static TextStyle brandTitle({
    double fontSize = 48.0,
    Color color = AppColors.brandOrange,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 1.2,
    );
  }
}

