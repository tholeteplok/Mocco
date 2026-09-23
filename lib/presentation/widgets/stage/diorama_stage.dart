import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Centralized Organic Diorama Stage Widget (Prinsip "Gajah Tanpa Kontainer").
///
/// Features:
/// - Replaces rigid white square cards (`ChunkyCard`) with an open, organic,
///   tactile diorama stage.
/// - Soft elliptical clay backdrop with radial atmospheric glow.
/// - Optional 3D diorama floor contact shadow ([showFloorShadow]).
/// - 100% centralized styling across all exercise screens (Counting, Letters, Blending).
class DioramaStage extends StatelessWidget {
  const DioramaStage({
    super.key,
    required this.child,
    this.stageColor = AppColors.brandMint,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.space16,
      vertical: AppSpacing.space16,
    ),
    this.showFloorShadow = true,
    this.floorShadowWidth = 120.0,
    this.floorShadowHeight = 14.0,
    this.elevation = 0.08,
  });

  final Widget child;
  final Color stageColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool showFloorShadow;
  final double floorShadowWidth;
  final double floorShadowHeight;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft Organic Clay Silhouette Backdrop
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: elevation),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(200, 150),
                ),
                boxShadow: [
                  BoxShadow(
                    color: stageColor.withValues(alpha: elevation * 0.7),
                    blurRadius: 36.0,
                    spreadRadius: 8.0,
                  ),
                ],
              ),
            ),
          ),

          // Main Hero Interactive Content
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              if (showFloorShadow) ...[
                const SizedBox(height: AppSpacing.space8),
                // Soft 3D Diorama Floor Contact Shadow
                Container(
                  width: floorShadowWidth,
                  height: floorShadowHeight,
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(
                        floorShadowWidth / 2,
                        floorShadowHeight / 2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
