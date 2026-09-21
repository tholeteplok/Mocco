import 'package:flutter/material.dart';

/// Centralized spacing, dimensions, and radii for Mocco Design System (v2.0)
/// Based on 8dp grid system, large touch targets, and generous soft corners.
abstract final class AppSpacing {
  // 8dp grid system
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Inter-card minimum spacing
  static const double cardGap = 16.0;

  // Touch targets (Minimum 64x64dp)
  static const double minTouchTarget = 64.0;
  static const double bubbleButtonSize = 56.0;
  static const double bubbleButtonSizeTablet = 64.0;

  // Flashcard Answer dimensions
  static const double flashcardPhone = 96.0;
  static const double flashcardTablet = 120.0;

  // Border Radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusCard = 24.0; // Pinterest standard card radius
  static const double radiusPill = 32.0; // Symmetrical answer & action pills

  static const BorderRadius roundedSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius roundedMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius roundedLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(radiusPill));

  // Bevel Offsets (2.5D Tactile Toy Depth)
  static const double bevelNormal = 4.0;
  static const double bevelCard = 4.0;
  static const double bevelThick = 6.0;
  static const double bevelPressed = 1.0;
  static const double pressOffsetY = 4.0;
}
