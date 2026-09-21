import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';

/// Flashcard Answer Card (V0.2, V0.5, V6, V12, V16)
/// Dimensions: Min 96x96dp on phone, 120x120dp on tablet
/// Frame: 3dp border in category color, 4dp solid bottom bevel
/// Glyph: Black #000000 for WCAG AAA compliance
class FlashcardAnswer extends StatefulWidget {
  const FlashcardAnswer({
    super.key,
    required this.text,
    required this.onTap,
    this.primaryColor = AppColors.numberTint,
    this.borderColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.textColor = AppColors.textPrimary,
    this.isSelected = false,
  });

  final String text;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color borderColor;
  final Color bevelColor;
  final Color textColor;
  final bool isSelected;

  @override
  State<FlashcardAnswer> createState() => _FlashcardAnswerState();
}

class _FlashcardAnswerState extends State<FlashcardAnswer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.value(
      context,
      mobile: AppSpacing.flashcardPhone,
      tablet: AppSpacing.flashcardTablet,
    );

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
        margin: EdgeInsets.only(top: topOffset, bottom: AppSpacing.pressOffsetY - topOffset),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.borderColor.withValues(alpha: 0.2) : widget.primaryColor,
          borderRadius: AppSpacing.roundedLarge,
          border: Border.all(
            color: widget.borderColor,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, bevelHeight),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: AppTypography.learningDisplay(
            fontSize: size * 0.5,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
