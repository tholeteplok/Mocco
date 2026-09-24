import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import 'chunky_button.dart';

/// Centralized Adaptive Tracing Action Button (DS v2.0 Hero CTA Standard)
/// Unifies the 3-state action lifecycle across all tracing screens (Counting, Letters):
/// 1. [Idle / Prompt]: "Tebalkan Dulu Ya ✏️"
/// 2. [In-progress / Retry]: "Coba Lagi 🧽"
/// 3. [Completed / Advance]: "Lanjut Latihan ➜" (or customizable action label)
///
/// Guaranteed full-width (double.infinity), 54dp heroic height, 18sp typography,
/// and centralized design token colors with zero hardcoding.
class AdaptiveTracingCta extends StatelessWidget {
  const AdaptiveTracingCta({
    super.key,
    required this.isCompleted,
    required this.hasUserProgress,
    required this.onAdvance,
    required this.onRetry,
    required this.onPrompt,
    this.advanceText = 'Lanjut Latihan ➜',
    this.retryText = 'Coba Lagi 🧽',
    this.promptText = 'Tebalkan Dulu Ya ✏️',
  });

  final bool isCompleted;
  final bool hasUserProgress;
  final VoidCallback onAdvance;
  final VoidCallback onRetry;
  final VoidCallback onPrompt;
  final String advanceText;
  final String retryText;
  final String promptText;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return SizedBox(
        width: double.infinity,
        height: 54.0,
        child: ChunkyButton(
          text: advanceText,
          primaryColor: AppColors.brandMint,
          bevelColor: AppColors.brandMintDark,
          textColor: AppColors.textWhite,
          fontSize: 18.0,
          height: 54.0,
          onPressed: onAdvance,
        ),
      );
    }

    if (hasUserProgress) {
      return SizedBox(
        width: double.infinity,
        height: 54.0,
        child: ChunkyButton(
          text: retryText,
          primaryColor: AppColors.retryBackground,
          bevelColor: AppColors.retryBevel,
          textColor: AppColors.retryText,
          fontSize: 18.0,
          height: 54.0,
          onPressed: onRetry,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54.0,
      child: ChunkyButton(
        text: promptText,
        primaryColor: AppColors.cardSurface,
        bevelColor: AppColors.cardBevel,
        textColor: AppColors.textSecondary,
        fontSize: 18.0,
        height: 54.0,
        onPressed: onPrompt,
      ),
    );
  }
}
