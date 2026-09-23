import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/dialogs/screen_time_dialog.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/mascot/mascot_widget.dart';

/// Parent Dashboard (reff: Total Time + Lessons + Stars + Subject + Weekly).
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({
    super.key,
    this.totalMinutes = 405,
    this.lessonsCompleted = 32,
    this.starsEarned = 128,
    this.englishProgress = 0.78,
    this.mathProgress = 0.62,
    this.weeklyMinutes = const [45, 60, 75, 50, 80],
  });

  final int totalMinutes;
  final int lessonsCompleted;
  final int starsEarned;
  final double englishProgress;
  final double mathProgress;
  final List<int> weeklyMinutes;

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return ResponsiveScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space8),
            Text('Parent Dashboard', style: AppTypography.uiHeading(fontSize: 22.0)),
            Text(
              'Perkembangan belajar anak minggu ini',
              style: AppTypography.uiBody(
                fontSize: 13.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            ChunkyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Learning Time',
                    style: AppTypography.uiBody(
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${hours}h ${minutes}m',
                    style: AppTypography.uiHeading(fontSize: 32.0),
                  ),
                  Text(
                    '↑ 18% vs last week',
                    style: AppTypography.uiBody(
                      fontSize: 12.0,
                      color: AppColors.brandMintDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space12),

            // Screen Time & Wellbeing Control (Rest Priming)
            ChunkyCard(
              backgroundColor: const Color(0xFFF0F4FC),
              borderColor: const Color(0xFF90B4EE),
              child: Row(
                children: [
                  const MascotWidget(
                    mood: MascotMood.sleeping,
                    size: 52.0,
                    animate: true,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batas Waktu Layar',
                          style: AppTypography.uiHeading(fontSize: 16.0),
                        ),
                        Text(
                          'Mencegah kecanduan layar secara halus',
                          style: AppTypography.uiBody(
                            fontSize: 12.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChunkyButton(
                    text: 'Istirahat',
                    height: 38.0,
                    fontSize: 13.0,
                    primaryColor: const Color(0xFF4A7BD0),
                    bevelColor: const Color(0xFF2E5499),
                    textColor: AppColors.textWhite,
                    onPressed: () => ScreenTimeDialog.show(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Lessons Completed',
                    '$lessonsCompleted',
                    '↑ 6 vs last week',
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: _buildMiniStat(
                    'Stars Earned',
                    '$starsEarned',
                    '↑ 22 vs last week',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Text('Subject Progress', style: AppTypography.uiHeading(fontSize: 18.0)),
            const SizedBox(height: AppSpacing.space8),
            _buildProgressRow('English', englishProgress, AppColors.letterPrimary),
            const SizedBox(height: AppSpacing.space8),
            _buildProgressRow('Pre-Math', mathProgress, AppColors.numberPrimary),
            const SizedBox(height: AppSpacing.space16),
            Text('Weekly Activity (Minutes)', style: AppTypography.uiHeading(fontSize: 18.0)),
            const SizedBox(height: AppSpacing.space8),
            ChunkyCard(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: SizedBox(
                height: 120.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < weeklyMinutes.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: (weeklyMinutes[i] / 90.0 * 80.0).clamp(8.0, 80.0),
                                    decoration: BoxDecoration(
                                      color: i == 2
                                          ? AppColors.brandMint
                                          : AppColors.letterPrimary.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][i],
                                style: AppTypography.uiBody(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            ChunkyCard(
              backgroundColor: AppColors.successBannerBg,
              borderColor: const Color(0xFFB2EAE3),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    size: 36.0,
                    color: AppColors.brandMintDark,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teacher Insight',
                          style: AppTypography.uiHeading(fontSize: 16.0),
                        ),
                        Text(
                          'Konsistensi bagus! Ajak anak menjelajah 1 zona baru setiap hari.',
                          style: AppTypography.uiBody(fontSize: 13.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String delta) {
    return ChunkyCard(
      padding: const EdgeInsets.all(AppSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.uiBody(
              fontSize: 11.0,
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTypography.uiHeading(fontSize: 24.0)),
          Text(
            delta,
            style: AppTypography.uiBody(
              fontSize: 11.0,
              color: AppColors.brandMintDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double progress, Color color) {
    return ChunkyCard(
      padding: const EdgeInsets.all(AppSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.uiButton(fontSize: 15.0)),
              Text(
                '${(progress * 100).round()}%',
                style: AppTypography.uiButton(fontSize: 15.0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.0,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
