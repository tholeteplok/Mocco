import 'package:flutter/material.dart';
import '../../../core/tokens/app_spacing.dart';

/// Centralized 3D Claymorphism Container (Pinterest Toy Aesthetic)
/// Features:
/// - Tactile 2.5D solid bottom bevel (zero blur shadow, V12)
/// - Top specular highlight gradient giving a plasticine / clay look
/// - Soft spring bounce when tapped
class ClayContainer extends StatefulWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFFFE0B2),
    this.bevelColor = const Color(0xFFE6A15C),
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.bevelHeight = 5.0,
    this.borderWidth = 2.5,
  });

  final Widget child;
  final Color baseColor;
  final Color bevelColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double bevelHeight;
  final double borderWidth;

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge);
    final currentBevel = _isPressed ? 1.0 : widget.bevelHeight;
    final topOffset = _isPressed ? widget.bevelHeight - 1.0 : 0.0;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: topOffset, bottom: widget.bevelHeight - 1.0 - topOffset),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HSLColor.fromColor(widget.baseColor)
                  .withLightness((HSLColor.fromColor(widget.baseColor).lightness + 0.08).clamp(0.0, 1.0))
                  .toColor(),
              widget.baseColor,
              HSLColor.fromColor(widget.baseColor)
                  .withLightness((HSLColor.fromColor(widget.baseColor).lightness - 0.04).clamp(0.0, 1.0))
                  .toColor(),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          border: Border.all(
            color: widget.borderColor ?? widget.bevelColor,
            width: widget.borderWidth,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            // Solid 2.5D Bevel (Zero blur, V12)
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, currentBevel),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
