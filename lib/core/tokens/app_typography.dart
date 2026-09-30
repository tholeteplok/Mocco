import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography for Mocco Design System (v2.0)
/// - Andika for learning display & tracing (local offline font asset)
/// - Nunito for UI interface & feedback (local offline font asset)
/// - Momentz for brand title (local offline font asset)
abstract final class AppTypography {
  /// Display for letters and numbers (120 - 200sp)
  static TextStyle learningDisplay({
    double fontSize = 140.0,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: 'Andika',
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
    return TextStyle(
      fontFamily: 'Nunito',
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
    return TextStyle(
      fontFamily: 'Nunito',
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
    return TextStyle(
      fontFamily: 'Nunito',
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
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Brand display text (Momentz playful claymorphic font for Mocco brand)
  static TextStyle brandTitle({
    double fontSize = 48.0,
    Color color = AppColors.brandOrange,
  }) {
    return TextStyle(
      fontFamily: 'Momentz',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 1.0,
    );
  }
}

