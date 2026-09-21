import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/sound_player.dart';

/// Interactive Counting Basket for one-to-one correspondence scaffold (V16)
/// Rules:
/// - Chunky rounded container in Category Angka Tint (#FDEBD7 / bevel #D68236)
/// - NO live numerical counter (V16: never spoil the answer!)
/// - Displays stacked visual objects as they are dropped
/// - Tap item inside to undo/return it back
class CountingBasket extends StatelessWidget {
  const CountingBasket({
    super.key,
    required this.countedItemIds,
    required this.objectAsset,
    required this.onItemDropped,
    required this.onItemRemoved,
    this.width = 130.0,
    this.height = 130.0,
  });

  final Set<int> countedItemIds;
  final String objectAsset;
  final ValueChanged<int> onItemDropped;
  final ValueChanged<int> onItemRemoved;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => !countedItemIds.contains(details.data),
      onAcceptWithDetails: (details) {
        onItemDropped(details.data);
        SoundPlayer.instance.playSquish();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          padding: const EdgeInsets.all(AppSpacing.space8),
          decoration: BoxDecoration(
            color: isHovered ? AppColors.numberPrimary.withValues(alpha: 0.3) : AppColors.numberTint,
            borderRadius: AppSpacing.roundedLarge,
            border: Border.all(
              color: AppColors.numberPrimary,
              width: isHovered ? 4.0 : 3.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.numberBevel,
                offset: Offset(0, AppSpacing.bevelNormal),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 3D Clay Basket Image (Pinterest Toy Aesthetic)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Image.asset(
                  AppAssets.basketClay,
                  width: width - 16.0,
                  height: height - 16.0,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.shopping_basket_rounded,
                      size: 48.0,
                      color: AppColors.numberBevel.withValues(alpha: 0.7),
                    );
                  },
                ),
              ),

              // Subtle drop prompt when empty
              if (countedItemIds.isEmpty)
                Positioned(
                  bottom: 10.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      border: Border.all(color: AppColors.numberPrimary, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      size: 18.0,
                      color: AppColors.numberBevel,
                    ),
                  ),
                ),

              // Stacked Items (Without live numbers - V16)
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: [
                  for (final id in countedItemIds)
                    GestureDetector(
                      onTap: () {
                        onItemRemoved(id);
                        SoundPlayer.instance.playPop();
                      },
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.numberPrimary,
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          objectAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_rounded,
                              size: 18.0,
                              color: AppColors.numberPrimary,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
