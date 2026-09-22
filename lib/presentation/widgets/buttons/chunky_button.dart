import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';

/// Tactile 2.5D Toy Button for Mocco (V6, V8, V12)
/// Supports:
/// - Icon-Only mode for pre-readers (e.g. big chunky arrow or replay icon)
/// - Text mode or Icon+Text mode
/// - Solid-color bottom bevel (no blur shadow, V12)
/// - Physical pressed state: shifts down 4dp on Y-axis and bevel thins to 1dp (V6)
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    this.text,
    required this.onPressed,
    this.primaryColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.textColor = AppColors.textPrimary,
    this.fontSize = 22.0,
    this.height = AppSpacing.minTouchTarget,
    this.width,
    this.borderRadius = AppSpacing.roundedPill,
    this.icon,
  });

  final String? text;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color bevelColor;
  final Color textColor;
  final double fontSize;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final Widget? icon;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
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
    final isIconOnly = widget.text == null && widget.icon != null;
    final defaultWidth = isIconOnly ? widget.height : null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: topOffset, bottom: AppSpacing.pressOffsetY - topOffset),
        width: widget.width ?? defaultWidth,
        height: widget.height,
        padding: EdgeInsets.symmetric(
          horizontal: isIconOnly ? AppSpacing.space12 : AppSpacing.space24,
        ),
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, bevelHeight),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.icon != null && widget.text != null)
              const SizedBox(width: AppSpacing.space8),
            if (widget.text != null)
              Flexible(
                child: Text(
                  widget.text!,
                  style: AppTypography.uiButton(
                    fontSize: widget.fontSize,
                    color: widget.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
