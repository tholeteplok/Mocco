import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../buttons/bubble_icon_button.dart';
import 'jelly_progress_bar.dart';

/// Non-office Playful Header for Mocco screens
class ChunkyHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChunkyHeader({
    super.key,
    this.onBack,
    this.onSettings,
    this.onAudioToggle,
    this.isMuted = false,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.primaryColor = AppColors.numberPrimary,
    this.tintColor = AppColors.numberTint,
    this.bevelColor = AppColors.numberBevel,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final VoidCallback? onAudioToggle;
  final bool isMuted;
  final int currentStep;
  final int totalSteps;
  final Color primaryColor;
  final Color tintColor;
  final Color bevelColor;

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            if (onBack != null)
              BubbleIconButton.back(
                onPressed: onBack,
              )
            else
              const SizedBox(width: AppSpacing.bubbleButtonSize),

            // Center Progress Bar
            if (totalSteps > 0)
              JellyProgressBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                filledColor: primaryColor,
                unfilledColor: tintColor,
              )
            else
              const Spacer(),

            // Right Actions (Audio / Settings / Spacer)
            if (onAudioToggle != null || onSettings != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAudioToggle != null) ...[
                    BubbleIconButton.sound(
                      isMuted: isMuted,
                      onPressed: onAudioToggle,
                    ),
                    if (onSettings != null) const SizedBox(width: AppSpacing.space8),
                  ],
                  if (onSettings != null)
                    BubbleIconButton(
                      icon: Icons.settings_rounded,
                      onPressed: onSettings,
                      borderColor: primaryColor,
                      bevelColor: bevelColor,
                    ),
                ],
              )
            else
              const SizedBox(width: AppSpacing.bubbleButtonSize),
          ],
        ),
      ),
    );
  }
}
