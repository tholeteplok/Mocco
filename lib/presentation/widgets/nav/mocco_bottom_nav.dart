import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';

/// Bottom navigation (reff: Home / Explore / Rewards / Profile).
class MoccoBottomNav extends StatelessWidget {
  const MoccoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        0,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardBevel,
            offset: Offset(0, 4.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(context, 0, Icons.home_rounded, 'Beranda'),
          _buildItem(context, 1, Icons.explore_rounded, 'Jelajah'),
          _buildItem(context, 2, Icons.emoji_events_rounded, 'Hadiah'),
          _buildItem(context, 3, Icons.family_restroom_rounded, 'Ortu'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isActive ? AppColors.numberTint : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24.0,
                color: isActive ? AppColors.numberPrimary : AppColors.textSecondary,
              ),
              const SizedBox(height: 2.0),
              Text(
                label,
                style: AppTypography.uiBody(
                  fontSize: 11.0,
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
