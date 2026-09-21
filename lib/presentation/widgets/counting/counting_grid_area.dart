import 'package:flutter/material.dart';
import '../../../core/tokens/app_spacing.dart';
import 'counting_object_item.dart';

/// Area displaying the objects to count with conceptual subitizing rules (V30)
/// - 1–5: Natural flow
/// - 6–10: Grouped formation (2 rows of up to 5, ten-frame style)
class CountingGridArea extends StatelessWidget {
  const CountingGridArea({
    super.key,
    required this.totalCount,
    required this.objectAsset,
    required this.countedItemIds,
    required this.onItemTapped,
  });

  final int totalCount;
  final String objectAsset;
  final Set<int> countedItemIds;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 5) {
      // 1–5: Natural centered row / wrap
      return Wrap(
        spacing: AppSpacing.space16,
        runSpacing: AppSpacing.space16,
        alignment: WrapAlignment.center,
        children: [
          for (int i = 1; i <= totalCount; i++)
            CountingObjectItem(
              id: i,
              objectAsset: objectAsset,
              isCounted: countedItemIds.contains(i),
              onTap: () => onItemTapped(i),
            ),
        ],
      );
    }

    // 6–10: Grouped formation (Ten-Frame / 2 rows of 5)
    final firstRow = totalCount >= 5 ? 5 : totalCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1 (up to 5 items)
        Wrap(
          spacing: AppSpacing.space12,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 1; i <= firstRow; i++)
              CountingObjectItem(
                id: i,
                objectAsset: objectAsset,
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
          children: [
            for (int i = firstRow + 1; i <= totalCount; i++)
              CountingObjectItem(
                id: i,
                objectAsset: objectAsset,
                isCounted: countedItemIds.contains(i),
                onTap: () => onItemTapped(i),
              ),
          ],
        ),
      ],
    );
  }
}
