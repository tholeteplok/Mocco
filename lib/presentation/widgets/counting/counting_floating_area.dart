import 'package:flutter/material.dart';
import '../../../core/tokens/app_spacing.dart';
import 'counting_object_item.dart';

/// Floating Area displaying 3D clay objects for counting (Pinterest v2.0 Standard)
/// Features:
/// - Pure diorama layout: objects float on the card surface without grid cells
/// - Subitizing standard:
///   - 1–5: Single centered linear row
///   - 6–10: Two balanced rows (5 on top, remainder on bottom)
class CountingFloatingArea extends StatelessWidget {
  const CountingFloatingArea({
    super.key,
    required this.totalCount,
    required this.objectAsset,
    required this.countedItemIds,
    required this.onItemTapped,
    this.itemSize = 72.0,
  });

  final int totalCount;
  final String objectAsset;
  final Set<int> countedItemIds;
  final ValueChanged<int> onItemTapped;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 5) {
      // 1–5 items: Single horizontal centered row
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        child: Wrap(
          spacing: AppSpacing.space16,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 1; i <= totalCount; i++)
              CountingObjectItem(
                id: i,
                objectAsset: objectAsset,
                size: itemSize,
                isCounted: countedItemIds.contains(i),
                onTap: () => onItemTapped(i),
              ),
          ],
        ),
      );
    }

    // 6–10 items: Two balanced rows (5 on top row, remainder on bottom row)
    final firstRowCount = totalCount >= 5 ? 5 : totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1 (5 items)
          Wrap(
            spacing: AppSpacing.space12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 1; i <= firstRowCount; i++)
                CountingObjectItem(
                  id: i,
                  objectAsset: objectAsset,
                  size: itemSize * 0.92,
                  isCounted: countedItemIds.contains(i),
                  onTap: () => onItemTapped(i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),

          // Row 2 (remaining items)
          Wrap(
            spacing: AppSpacing.space12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = firstRowCount + 1; i <= totalCount; i++)
                CountingObjectItem(
                  id: i,
                  objectAsset: objectAsset,
                  size: itemSize * 0.92,
                  isCounted: countedItemIds.contains(i),
                  onTap: () => onItemTapped(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
