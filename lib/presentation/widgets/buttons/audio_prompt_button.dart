import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/utils/sound_player.dart';

/// Audio Prompt Button for Pre-Readers (V0.7, V24, V32)
/// Replaces written text instructions with an interactive 3D clay speaker button.
/// Children tap this button to hear the voice instruction repeatedly.
/// PENTING: Tidak dibingkai dengan container/border/box-shadow artifisial.
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        SoundPlayer.instance.playPop();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.94 : _pulseAnimation.value,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Image.asset(
              _isPressed ? AppAssets.btnVoicePressed : AppAssets.btnVoice,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
