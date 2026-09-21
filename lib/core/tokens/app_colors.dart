import 'package:flutter/material.dart';

/// Centralized color palette for Mocco Design System (v1.5)
/// Ensures consistency across all screens without hardcoding colors.
abstract final class AppColors {
  // --- Background ---
  static const Color background = Color(0xFFFFF6EB); // Warm Cream

  // --- Category: Huruf (Letters) ---
  static const Color letterPrimary = Color(0xFF6FA8DC); // Pastel Blue
  static const Color letterTint = Color(0xFFE3EEF9);
  static const Color letterBevel = Color(0xFF4F86B8);

  // --- Category: Angka (Numbers) ---
  static const Color numberPrimary = Color(0xFFF4A259); // Pastel Orange
  static const Color numberTint = Color(0xFFFDEBD7);
  static const Color numberBevel = Color(0xFFD68236);

  // --- Category: Blending (Word Combining) ---
  static const Color blendingPrimary = Color(0xFF7BC47F); // Pastel Green
  static const Color blendingTint = Color(0xFFE3F4EC);
  static const Color blendingBevel = Color(0xFF5DA361);

  // --- Feedback ---
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color successBevel = Color(0xFF7BC47F);

  static const Color retryBackground = Color(0xFFFFF3D6);
  static const Color retryBevel = Color(0xFFF5C542);

  // --- Text & Glyphs (WCAG AAA Compliance) ---
  static const Color textPrimary = Color(0xFF000000); // Black for max contrast
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textWhite = Color(0xFFFFFFFF);

  // --- Overlays (V9 / V25: Solid 40% without blur) ---
  static const Color modalOverlay = Color(0x66000000); // 40% black
}
