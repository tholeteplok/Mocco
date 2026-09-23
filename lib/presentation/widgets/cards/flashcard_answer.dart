import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import 'answer_choice_tile.dart';

/// Flashcard Answer Card (Pinterest v2.0 Standard)
/// Supports both flexible 1x4 horizontal pill mode and fixed dimension mode.
/// Smoothly transitions to mint green (#2EC4B6) when answered correctly.
class FlashcardAnswer extends StatelessWidget {
  const FlashcardAnswer({
    super.key,
    required this.text,
    required this.onTap,
    this.primaryColor,
    this.borderColor,
    this.bevelColor,
    this.textColor,
    this.isSelected = false,
    this.isCorrect = false,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String text;
  final VoidCallback onTap;
  final Color? primaryColor;
  final Color? borderColor;
  final Color? bevelColor;
  final Color? textColor;
  final bool isSelected;
  final bool isCorrect;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // If state is indicated by primaryColor or explicit isCorrect flag
    final AnswerTileState state;
    if (isCorrect || (isSelected && primaryColor == AppColors.successBackground)) {
      state = AnswerTileState.correct;
    } else if (isSelected && (primaryColor == AppColors.retryBackground || borderColor == AppColors.retryBevel)) {
      state = AnswerTileState.incorrect;
    } else {
      state = AnswerTileState.normal;
    }

    final tile = AnswerChoiceTile(
      text: text,
      onTap: onTap,
      state: state,
      height: height ?? 68.0,
      fontSize: 28.0,
      borderRadius: borderRadius,
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: tile,
      );
    }

    return tile;
  }
}
