import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';

/// Single draggable fruit/vegetable item for counting (V16, V30)
/// Features:
/// - 1:1 uniform dimensions
/// - Chunky outline stiker look
/// - Drag-and-drop support into CountingBasket
class CountingObjectItem extends StatelessWidget {
  const CountingObjectItem({
    super.key,
    required this.id,
    required this.objectAsset,
    this.size = 64.0,
    this.isCounted = false,
    this.onTap,
  });

  final int id;
  final String objectAsset;
  final double size;
  final bool isCounted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isCounted) {
      // Hidden or empty placeholder when already placed in basket
      return SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: 0.2,
          child: _buildVisual(),
        ),
      );
    }

    return Draggable<int>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: _buildVisual(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildVisual(),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _buildVisual(),
      ),
    );
  }

  Widget _buildVisual() {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.numberPrimary,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.numberBevel,
            offset: Offset(0, 3.0),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: Image.asset(
          objectAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Graceful fallback icon for mock assets
            return Icon(
              Icons.eco_rounded,
              size: size * 0.55,
              color: AppColors.numberPrimary,
            );
          },
        ),
      ),
    );
  }
}
