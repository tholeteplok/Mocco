import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/sound_player.dart';

/// Interactive Counting Basket for one-to-one correspondence scaffold (v2.0 Soft Diorama)
/// Rules:
/// - Soft rounded toy container
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
    this.width = 110.0,
    this.height = 90.0,
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
            color: isHovered ? AppColors.numberTint : const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: isHovered ? AppColors.numberPrimary : AppColors.cardBorder,
              width: isHovered ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardBevel,
                offset: Offset(0, 3.0),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 3D Clay Basket Visual
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
                      size: 40.0,
                      color: AppColors.numberPrimary.withValues(alpha: 0.6),
                    );
                  },
                ),
              ),

              // Subtle drop prompt when empty
              if (countedItemIds.isEmpty)
                Positioned(
                  bottom: 4.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      border: Border.all(color: AppColors.cardBorder, width: 1.0),
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      size: 14.0,
                      color: AppColors.numberPrimary,
                    ),
                  ),
                ),

              // Stacked Items inside basket
              Wrap(
                spacing: 3.0,
                runSpacing: 3.0,
                alignment: WrapAlignment.center,
                children: [
                  for (final id in countedItemIds)
                    GestureDetector(
                      onTap: () {
                        onItemRemoved(id);
                        SoundPlayer.instance.playPop();
                      },
                      child: Container(
                        width: 26.0,
                        height: 26.0,
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 1.0),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          objectAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_rounded,
                              size: 14.0,
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
