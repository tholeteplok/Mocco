import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';

/// Jelly Capsule Segmented Progress Bar (V28)
/// Features:
/// - Semi-transparent pill casing with subtle border
/// - Pastel colored filled segments
/// - High contrast with background
class JellyProgressBar extends StatelessWidget {
  const JellyProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.filledColor = AppColors.numberPrimary,
    this.unfilledColor = AppColors.numberTint,
    this.height = 24.0,
    this.width = 180.0,
  });

  final int currentStep;
  final int totalSteps;
  final Color filledColor;
  final Color unfilledColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final progressFraction = totalSteps > 0 ? (currentStep / totalSteps).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: unfilledColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: filledColor.withValues(alpha: 0.5),
          width: 2.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Filled Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: constraints.maxWidth * progressFraction,
                decoration: BoxDecoration(
                  color: filledColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
