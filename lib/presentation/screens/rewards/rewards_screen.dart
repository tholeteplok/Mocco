import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/mascot/mascot_widget.dart';

/// Rewards shelf (reff: Stars Earned + badges + prize feel).
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, this.stars = 12, this.badges = 5});

  final int stars;
  final int badges;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space8),
            Text('Hadiahku', style: AppTypography.uiHeading(fontSize: 24.0)),
            Text(
              'Setiap bintang bikin Mocco bangga!',
              style: AppTypography.uiBody(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            ChunkyCard(
              backgroundColor: const Color(0xFFFFF3D6),
              borderColor: AppColors.retryBevel.withValues(alpha: 0.5),
              child: Row(
                children: [
                  const MascotWidget(
                    mood: MascotMood.thumbsUp,
                    size: 64.0,
                    animate: true,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$stars Bintang',
                          style: AppTypography.uiHeading(fontSize: 22.0),
                        ),
                        Text(
                          '$badges dari 12 lencana terbuka',
                          style: AppTypography.uiBody(
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 40.0,
                    color: AppColors.retryBevel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text('Lencana', style: AppTypography.uiHeading(fontSize: 18.0)),
            const SizedBox(height: AppSpacing.space8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space8,
              crossAxisSpacing: AppSpacing.space8,
              children: [
                for (int i = 0; i < 9; i++)
                  _buildBadge(i < badges, 'Level ${i + 1}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool unlocked, String label) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : AppColors.cardSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: unlocked ? AppColors.retryBevel : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? Icons.verified_rounded : Icons.lock_rounded,
            size: 30.0,
            color: unlocked ? AppColors.retryBevel : AppColors.textSecondary,
          ),
          const SizedBox(height: 4.0),
          Text(label, style: AppTypography.uiBody(fontSize: 11.0)),
        ],
      ),
    );
  }
}
