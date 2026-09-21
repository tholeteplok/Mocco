import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';

/// 2.5D Target Slot for Word Assembly (Design System V12, V18)
/// An indented target socket that visually receives a syllable card.
class WordSlot extends StatelessWidget {
  const WordSlot({
    super.key,
    this.syllable,
    this.onTapRemove,
    this.borderColor = AppColors.blendingPrimary,
    this.tintColor = AppColors.blendingTint,
    this.bevelColor = AppColors.blendingBevel,
  });

  final String? syllable;
  final VoidCallback? onTapRemove;
  final Color borderColor;
  final Color tintColor;
  final Color bevelColor;

  bool get isFilled => syllable != null && syllable!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.value(context, mobile: 88.0, tablet: 112.0);
    final height = ResponsiveHelper.value(context, mobile: 80.0, tablet: 100.0);

    if (isFilled) {
      return GestureDetector(
        onTap: onTapRemove,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: borderColor,
              width: 3.0,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: [
              BoxShadow(
                color: bevelColor,
                offset: const Offset(0, 3.0),
                blurRadius: 0.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              syllable!,
              style: AppTypography.learningDisplay(
                fontSize: ResponsiveHelper.value(context, mobile: 32.0, tablet: 42.0),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    // Empty Indented Socket
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.4),
          width: 2.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        // Visual indentation effect: top inner bevel shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 3.0),
            blurRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: borderColor.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
