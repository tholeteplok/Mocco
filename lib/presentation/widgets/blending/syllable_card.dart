import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';

/// 2.5D Syllable Card for Blending (Design System V12, V18)
/// Tactile chunky card displaying a syllable (e.g., "bu", "ku") with zero-blur bevel.
class SyllableCard extends StatefulWidget {
  const SyllableCard({
    super.key,
    required this.syllable,
    required this.onTap,
    this.isUsed = false,
    this.primaryColor = AppColors.blendingTint,
    this.borderColor = AppColors.blendingPrimary,
    this.bevelColor = AppColors.blendingBevel,
    this.textColor = AppColors.textPrimary,
  });

  final String syllable;
  final VoidCallback onTap;
  final bool isUsed;
  final Color primaryColor;
  final Color borderColor;
  final Color bevelColor;
  final Color textColor;

  @override
  State<SyllableCard> createState() => _SyllableCardState();
}

class _SyllableCardState extends State<SyllableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.value(context, mobile: 84.0, tablet: 108.0);
    final height = ResponsiveHelper.value(context, mobile: 76.0, tablet: 96.0);

    if (widget.isUsed) {
      // Show an empty/disabled placeholder outline when already chosen
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: widget.borderColor.withValues(alpha: 0.2),
            width: 2.0,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
      );
    }

    final bevelHeight = _isPressed ? AppSpacing.bevelPressed : AppSpacing.bevelNormal;
    final topOffset = _isPressed ? AppSpacing.pressOffsetY : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: topOffset,
          bottom: AppSpacing.pressOffsetY - topOffset,
        ),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: widget.borderColor,
            width: 3.0,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, bevelHeight),
              blurRadius: 0.0, // V12: Solid zero blur shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.syllable,
            style: AppTypography.learningDisplay(
              fontSize: ResponsiveHelper.value(context, mobile: 32.0, tablet: 42.0),
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
