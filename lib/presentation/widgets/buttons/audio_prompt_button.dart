import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Audio Prompt Button for Pre-Readers (V0.7, V24, V32)
/// Replaces written text instructions with an interactive chunky speaker button.
/// Children tap this button to hear the voice instruction repeatedly.
class AudioPromptButton extends StatefulWidget {
  const AudioPromptButton({
    super.key,
    required this.onPressed,
    this.size = 72.0,
    this.primaryColor = AppColors.letterTint,
    this.borderColor = AppColors.letterPrimary,
    this.bevelColor = AppColors.letterBevel,
    this.iconColor = AppColors.textPrimary,
  });

  final VoidCallback onPressed;
  final double size;
  final Color primaryColor;
  final Color borderColor;
  final Color bevelColor;
  final Color iconColor;

  @override
  State<AudioPromptButton> createState() => _AudioPromptButtonState();
}

class _AudioPromptButtonState extends State<AudioPromptButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bevelHeight = _isPressed ? AppSpacing.bevelPressed : AppSpacing.bevelNormal;
    final topOffset = _isPressed ? AppSpacing.pressOffsetY : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 1.0 : _pulseAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(
            top: topOffset,
            bottom: AppSpacing.pressOffsetY - topOffset,
          ),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.borderColor,
              width: 3.5,
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
          child: Icon(
            Icons.volume_up_rounded,
            size: widget.size * 0.55,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
