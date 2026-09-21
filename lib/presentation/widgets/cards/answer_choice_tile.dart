import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';

/// Symmetrical Answer Choice Tile (Pinterest v2.0 Standard)
/// Features:
/// - Anti-orphan 1x4 horizontal pill or 2x2 grid design
/// - Luminous white surface in normal state
/// - Instant mint green (#2EC4B6) transition upon correct selection
/// - Spring bounce & tactile 2.5D press-down depth
enum AnswerTileState { normal, correct, incorrect }

class AnswerChoiceTile extends StatefulWidget {
  const AnswerChoiceTile({
    super.key,
    required this.text,
    required this.onTap,
    this.state = AnswerTileState.normal,
    this.height = 68.0,
    this.fontSize = 32.0,
  });

  final String text;
  final VoidCallback onTap;
  final AnswerTileState state;
  final double height;
  final double fontSize;

  @override
  State<AnswerChoiceTile> createState() => _AnswerChoiceTileState();
}

class _AnswerChoiceTileState extends State<AnswerChoiceTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _wobbleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _wobbleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant AnswerChoiceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AnswerTileState.incorrect &&
        oldWidget.state != AnswerTileState.incorrect) {
      _wobbleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.state == AnswerTileState.correct;
    final isIncorrect = widget.state == AnswerTileState.incorrect;

    // Palette per state
    final Color bgColor;
    final Color borderColor;
    final Color bevelColor;
    final Color textColor;

    if (isCorrect) {
      bgColor = AppColors.brandMint;
      borderColor = AppColors.brandMintDark;
      bevelColor = AppColors.brandMintDark;
      textColor = AppColors.textWhite;
    } else if (isIncorrect) {
      bgColor = AppColors.retryBackground;
      borderColor = AppColors.retryBevel;
      bevelColor = AppColors.retryBevel;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = AppColors.cardSurface;
      borderColor = AppColors.cardBorder;
      bevelColor = AppColors.cardBevel;
      textColor = AppColors.numberPrimary;
    }

    final bevelHeight = _isPressed ? AppSpacing.bevelPressed : AppSpacing.bevelNormal;
    final topOffset = _isPressed ? AppSpacing.pressOffsetY : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _wobbleAnimation,
        builder: (context, child) {
          if (_wobbleAnimation.value == 0.0) {
            return child!;
          }
          return Transform.translate(
            offset: Offset(_wobbleAnimation.value, 0),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          transform: isCorrect ? Matrix4.diagonal3Values(1.04, 1.04, 1.0) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          margin: EdgeInsets.only(
            top: topOffset,
            bottom: AppSpacing.pressOffsetY - topOffset,
          ),
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: borderColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: bevelColor,
                offset: Offset(0, bevelHeight),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: AppTypography.learningDisplay(
              fontSize: widget.fontSize,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
