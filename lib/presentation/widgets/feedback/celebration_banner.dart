import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../buttons/chunky_button.dart';

/// Dopamine Celebration Banner (Pinterest v2.0 Standard)
/// Displays living mascot encouragement + affirmative copy + "[ Lanjut → ]" CTA button.
class CelebrationBanner extends StatelessWidget {
  const CelebrationBanner({
    super.key,
    required this.onNextPressed,
    this.title = 'Hebat Sekali!',
    this.subtitle = 'Jawabanmu benar!',
    this.buttonText = 'Lanjut',
  });

  final VoidCallback onNextPressed;
  final String title;
  final String subtitle;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBannerBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: const Color(0xFFB2EAE3),
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0F0EB),
            offset: Offset(0, 4.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Living Mascot Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: Image.asset(
              AppAssets.mascotJump,
              width: 52.0,
              height: 52.0,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.sentiment_very_satisfied_rounded,
                size: 48.0,
                color: AppColors.brandMint,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),

          // Affirmative Affirmation Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.uiHeading(
                    fontSize: 18.0,
                    color: const Color(0xFF13695F),
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.uiBody(
                    fontSize: 13.0,
                    color: const Color(0xFF267D73),
                  ),
                ),
              ],
            ),
          ),

          // Primary "Lanjut →" Action Button
          ChunkyButton(
            text: buttonText,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.textWhite,
              size: 20.0,
            ),
            primaryColor: AppColors.brandMint,
            bevelColor: AppColors.brandMintDark,
            textColor: AppColors.textWhite,
            height: 48.0,
            onPressed: onNextPressed,
          ),
        ],
      ),
    );
  }
}
