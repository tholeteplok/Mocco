import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Centralized ThemeData for Mocco
abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.numberPrimary,
        secondary: AppColors.letterPrimary,
        surface: AppColors.background,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.uiHeading(),
        headlineMedium: AppTypography.uiHeading(fontSize: 24),
        bodyLarge: AppTypography.uiInstruction(),
        bodyMedium: AppTypography.uiInstruction(fontSize: 16),
        labelLarge: AppTypography.uiButton(),
      ),
    );
  }
}
