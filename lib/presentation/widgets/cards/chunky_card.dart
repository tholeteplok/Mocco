import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Chunky 2.5D Container Card for Mocco (v2.0 Airy Clay & Playful Diorama)
/// Defaults to pure white card with soft 2.5D contact bevel and 24dp rounded corners.
class ChunkyCard extends StatelessWidget {
  const ChunkyCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.cardSurface,
    this.borderColor = AppColors.cardBorder,
    this.bevelColor = AppColors.cardBevel,
    this.borderWidth = 1.5,
    this.bevelHeight = AppSpacing.bevelCard,
    this.borderRadius = AppSpacing.roundedCard,
    this.padding = const EdgeInsets.all(AppSpacing.space20),
    this.width,
    this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color bevelColor;
  final double borderWidth;
  final double bevelHeight;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height != null ? height! + bevelHeight : null,
      child: Stack(
        children: [
          // 2.5D Contact Floor Bevel
          Positioned(
            top: bevelHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: bevelColor,
                borderRadius: borderRadius,
              ),
            ),
          ),
          // Luminous Card Body
          Container(
            margin: EdgeInsets.only(bottom: bevelHeight),
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
