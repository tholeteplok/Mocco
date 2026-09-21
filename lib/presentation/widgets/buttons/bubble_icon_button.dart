import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Bubble Round Icon Button (56-64dp) for Header & Navigation (V6, V10, V12)
class BubbleIconButton extends StatefulWidget {
  const BubbleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color primaryColor;
  final Color bevelColor;
  final Color borderColor;
  final Color iconColor;

  @override
  State<BubbleIconButton> createState() => _BubbleIconButtonState();
}

class _BubbleIconButtonState extends State<BubbleIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bevelHeight = _isPressed ? AppSpacing.bevelPressed : AppSpacing.bevelNormal;
    final topOffset = _isPressed ? AppSpacing.pressOffsetY : 0.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: topOffset, bottom: AppSpacing.pressOffsetY - topOffset),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.primaryColor,
          shape: BoxShape.circle,
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
        child: Icon(
          widget.icon,
          size: widget.size * 0.45,
          color: widget.iconColor,
        ),
      ),
    );
  }
}
