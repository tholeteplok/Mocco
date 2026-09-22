import 'package:flutter/material.dart';

/// Centralized color palette for Mocco Design System (v2.0 - Airy Clay & Playful Diorama)
/// Ensures consistency across all screens without hardcoding colors.
abstract final class AppColors {
  // --- Canvas & Surfaces (Pinterest Warm Calm Standard) ---
  static const Color canvasBackground = Color(0xFFFAF8F5); // Warm Cream Milk Canvas
  static const Color background = canvasBackground; // Compatibility alias
  static const Color cardSurface = Color(0xFFFFFFFF); // Pure Luminous White
  static const Color cardBorder = Color(0xFFF0EAE1); // Subtle card outline (1.5dp)
  static const Color cardBevel = Color(0xFFE8E0D5); // Soft 2.5D floor bevel

  // --- Category: Huruf (Letters) ---
  static const Color letterPrimary = Color(0xFF4EA8DE); // Pastel Sky Blue
  static const Color letterTint = Color(0xFFE3EEF9);
  static const Color letterBevel = Color(0xFF388AC0);

  // --- Category: Angka (Numbers) ---
  static const Color numberPrimary = Color(0xFFFF9F1C); // Warm Honeycomb Orange
  static const Color numberTint = Color(0xFFFDEBD7);
  static const Color numberBevel = Color(0xFFE08628);

  // --- Category: Blending (Word Combining) ---
  // Distinct leaf-green so it never confuses with letter sky-blue (reff).
  static const Color blendingPrimary = Color(0xFF7BC47F); // Pastel Leaf Green
  static const Color blendingTint = Color(0xFFE3F4EC);
  static const Color blendingBevel = Color(0xFF5DA361);

  // --- Feedback & Gamification (Pinterest Dopamine Standard) ---
  static const Color brandMint = Color(0xFF2EC4B6); // Luminous Mint Green (Success & Next CTA)
  static const Color brandMintDark = Color(0xFF25A296); // Bevel for Mint buttons
  static const Color successBackground = Color(0xFF2EC4B6);
  static const Color successBevel = Color(0xFF25A296);
  static const Color successBannerBg = Color(0xFFE8F8F5); // Very soft mint wash for banner

  static const Color retryBackground = Color(0xFFFFF3D6);
  static const Color retryBevel = Color(0xFFF5C542);

  // --- Text & Glyphs (WCAG AAA Compliance) ---
  static const Color textPrimary = Color(0xFF2B2D42); // Warm Charcoal - easier on young eyes than harsh black
  static const Color textSecondary = Color(0xFF495057); // Darkened for AAA on cream canvas
  static const Color textWhite = Color(0xFFFFFFFF);

  // --- Overlays ---
  static const Color modalOverlay = Color(0x66000000); // 40% black
}
