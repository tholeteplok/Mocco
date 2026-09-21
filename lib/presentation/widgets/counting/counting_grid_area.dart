import 'package:flutter/material.dart';
import 'counting_floating_area.dart';

/// Legacy alias for CountingFloatingArea to maintain test & component compatibility
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
    return CountingFloatingArea(
      totalCount: totalCount,
      objectAsset: objectAsset,
      countedItemIds: countedItemIds,
      onItemTapped: onItemTapped,
    );
  }
}
