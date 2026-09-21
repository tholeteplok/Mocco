import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Chunky 2.5D Container Card for Mocco
class ChunkyCard extends StatelessWidget {
  const ChunkyCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.borderColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.borderWidth = 3.0,
    this.bevelHeight = AppSpacing.bevelNormal,
    this.borderRadius = AppSpacing.roundedLarge,
    this.padding = const EdgeInsets.all(AppSpacing.space16),
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
          // Bevel Base
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
          // Card Body
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
