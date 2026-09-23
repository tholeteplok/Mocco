import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/mascot/mascot_widget.dart';
import '../map/adventure_map_screen.dart';

/// Home funnel (reff: Hello Arjun + Featured Lesson + Let's Explore + Quiz Time).
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.stars = 12,
    this.streakDays = 7,
    this.coins = 120,
    this.badges = 5,
    this.onExploreZone,
    this.onContinueLearning,
    this.onOpenQuiz,
  });

  final int stars;
  final int streakDays;
  final int coins;
  final int badges;
  final ValueChanged<AdventureZone>? onExploreZone;
  final VoidCallback? onContinueLearning;
  final VoidCallback? onOpenQuiz;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space8),
            // Greeting header (reff: Hello, Arjun! + living mascot + stars)
            Row(
              children: [
                const MascotWidget(
                  mood: MascotMood.greeting,
                  size: 56.0,
                  animate: true,
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Petualang!',
                        style: AppTypography.uiHeading(fontSize: 22.0),
                      ),
                      Text(
                        'Siap belajar hal seru hari ini?',
                        style: AppTypography.uiBody(
                          fontSize: 13.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.retryBevel.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: AppColors.retryBevel.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18.0,
                        color: AppColors.retryBevel,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '$stars',
                        style: AppTypography.uiButton(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),

            // Stats strip (reff: Day Streak / Coins / Badges)
            Row(
              children: [
                _buildStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streakDays',
                  label: 'Hari Beruntun',
                  color: const Color(0xFFE0574A),
                ),
                const SizedBox(width: AppSpacing.space8),
                _buildStat(
                  icon: Icons.monetization_on_rounded,
                  value: '$coins',
                  label: 'Koin',
                  color: AppColors.retryBevel,
                ),
                const SizedBox(width: AppSpacing.space8),
                _buildStat(
                  icon: Icons.verified_rounded,
                  value: '$badges',
                  label: 'Lencana',
                  color: AppColors.letterPrimary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),

            // Featured Lesson (reff: The Letter A + Continue Learning)
            ChunkyCard(
              backgroundColor: const Color(0xFFE3EEF9),
              borderColor: AppColors.letterPrimary.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Featured Lesson',
                          style: AppTypography.uiBody(
                            fontSize: 12.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Huruf A untuk Apel',
                          style: AppTypography.uiHeading(fontSize: 20.0),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Dengar bunyinya, telusuri, dan pasangkan!',
                          style: AppTypography.uiBody(
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        ChunkyButton(
                          text: 'Continue Learning',
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20.0,
                            color: AppColors.textWhite,
                          ),
                          primaryColor: AppColors.brandMint,
                          bevelColor: AppColors.brandMintDark,
                          textColor: AppColors.textWhite,
                          fontSize: 15.0,
                          height: 48.0,
                          onPressed: () {
                            SoundPlayer.instance.playPop();
                            onContinueLearning?.call();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96.0,
                        height: 96.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          border: Border.all(
                            color: AppColors.letterPrimary.withValues(alpha: 0.4),
                            width: 2.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const MascotWidget(
                          mood: MascotMood.reading,
                          size: 78.0,
                          animate: true,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.letterPrimary,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            'Aa',
                            style: AppTypography.uiButton(
                              fontSize: 13.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            Text("Let's Explore", style: AppTypography.uiHeading(fontSize: 18.0)),
            const SizedBox(height: AppSpacing.space8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space8,
              crossAxisSpacing: AppSpacing.space8,
              childAspectRatio: 0.92,
              children: [
                _buildExploreTile(
                  context,
                  emoji: 'Aa',
                  label: 'English',
                  tileColor: const Color(0xFFE3EEF9),
                  onTap: () => onExploreZone?.call(AdventureZone.letters),
                ),
                _buildExploreTile(
                  context,
                  emoji: '123',
                  label: 'Numbers',
                  tileColor: AppColors.numberTint,
                  onTap: () => onExploreZone?.call(AdventureZone.numbers),
                ),
                _buildExploreTile(
                  context,
                  emoji: 'Ka',
                  label: 'Kata',
                  tileColor: AppColors.blendingTint,
                  onTap: () => onExploreZone?.call(AdventureZone.words),
                ),
                _buildExploreTile(
                  context,
                  emoji: '+',
                  label: 'Addition',
                  tileColor: const Color(0xFFE3F4EC),
                  locked: true,
                  onTap: () {},
                ),
                _buildExploreTile(
                  context,
                  emoji: '−',
                  label: 'Shapes',
                  tileColor: const Color(0xFFF3E8FD),
                  locked: true,
                  onTap: () {},
                ),
                _buildExploreTile(
                  context,
                  emoji: '★',
                  label: 'More',
                  tileColor: const Color(0xFFFFF3D6),
                  onTap: () => onExploreZone?.call(AdventureZone.numbers),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),

            // Quiz Time banner (reff)
            ChunkyCard(
              backgroundColor: const Color(0xFFFFF3D6),
              borderColor: AppColors.retryBevel.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 40.0,
                    color: AppColors.retryBevel,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiz Time',
                          style: AppTypography.uiHeading(fontSize: 18.0),
                        ),
                        Text(
                          'Main kuis seru dan menangkan koin!',
                          style: AppTypography.uiBody(
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChunkyButton(
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 24.0,
                      color: AppColors.textWhite,
                    ),
                    primaryColor: AppColors.numberPrimary,
                    bevelColor: AppColors.numberBevel,
                    height: 48.0,
                    width: 52.0,
                    onPressed: () {
                      SoundPlayer.instance.playPop();
                      onOpenQuiz?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.0, color: color),
            const SizedBox(height: 2.0),
            Text(value, style: AppTypography.uiButton(fontSize: 16.0)),
            Text(
              label,
              style: AppTypography.uiBody(
                fontSize: 10.0,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTile(
    BuildContext context, {
    required String emoji,
    required String label,
    required Color tileColor,
    bool locked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundPlayer.instance.playPop();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: AppTypography.uiHeading(fontSize: 22.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: AppTypography.uiBody(fontSize: 12.0),
            ),
            if (locked)
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.lock_rounded,
                  size: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
