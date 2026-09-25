import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../buttons/bubble_icon_button.dart';
import '../mascot/mascot_widget.dart';

/// Semantic milestones for Level Up celebrations across Mocco.
enum LevelMilestoneType {
  /// Regular node completion (e.g. Node 1-9, 11-22, 24-35, 37-43)
  standard,

  /// 50% Midway Alphabet Milestone (Node 23 / Huruf M) - Dopamine recharge!
  halfwayAlphabet,

  /// Completing Node 10 (End of Numbers Zone -> Unlocks Alphabet Island)
  zoneAngka,

  /// Completing Node 36 (End of Alphabet Zone -> Unlocks Word Blending Summit)
  zoneHuruf,

  /// Completing Node 44 (Full Journey Mastery)
  grandCompletion,
}

/// Centralized Level-Up Celebration & Transition Dialog (DS 2.0 Pure Claymorphism).
///
/// Designed exclusively for toddlers and pre-readers (Visual-First):
/// 1. Big Breakout Mascot:
///    - Standard / Halfway: 170dp Mascot with Big 3D Star (64dp) floating above head.
///    - Zone Milestones: 200dp Mascot with Big 3D Trophy (76dp) floating above head.
/// 2. Minimalist Affirmation: 1-2 words punchy title ("Hore!", "Hebat!", "Luar Biasa!")
///    without overwhelming sentences toddlers cannot read.
/// 3. Jumbo 72dp 3D Clay Next Button ([BubbleIconButton.next]) with tactile press states.
/// 4. Centralized sound triggering with solo levelUp.mp3 fanfare.
class LevelUpDialog extends StatelessWidget {
  const LevelUpDialog({
    super.key,
    required this.onContinue,
    this.milestoneType = LevelMilestoneType.standard,
    this.title,
    this.subtitle,
    this.buttonText,
  });

  final VoidCallback onContinue;
  final LevelMilestoneType milestoneType;
  final String? title;
  final String? subtitle;
  final String? buttonText;

  /// Displays the centralized level up celebration dialog as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onContinue,
    LevelMilestoneType milestoneType = LevelMilestoneType.standard,
    String? title,
    String? subtitle,
    String? buttonText,
  }) {
    SoundPlayer.instance.playLevelUp();
    bool hasHandled = false;
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalOverlay,
      builder: (modalContext) => LevelUpDialog(
        milestoneType: milestoneType,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onContinue: () {
          if (hasHandled) return;
          hasHandled = true;
          Navigator.of(modalContext).pop();
          onContinue();
        },
      ),
    );
  }

  bool get _isZoneMilestone =>
      milestoneType == LevelMilestoneType.zoneAngka ||
      milestoneType == LevelMilestoneType.zoneHuruf ||
      milestoneType == LevelMilestoneType.grandCompletion;

  String get _effectiveTitle {
    if (title != null) return title!;
    switch (milestoneType) {
      case LevelMilestoneType.standard:
        return 'Hore!';
      case LevelMilestoneType.halfwayAlphabet:
        return 'Hebat!';
      case LevelMilestoneType.zoneAngka:
      case LevelMilestoneType.zoneHuruf:
      case LevelMilestoneType.grandCompletion:
        return 'Luar Biasa!';
    }
  }

  MascotMood get _mascotMood {
    switch (milestoneType) {
      case LevelMilestoneType.standard:
      case LevelMilestoneType.zoneAngka:
      case LevelMilestoneType.zoneHuruf:
      case LevelMilestoneType.grandCompletion:
        return MascotMood.celebrate;
      case LevelMilestoneType.halfwayAlphabet:
        return MascotMood.thumbsUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isZone = _isZoneMilestone;
    final double mascotSize = isZone ? 200.0 : 170.0;
    final double rewardSize = isZone ? 76.0 : 64.0;
    final double mascotOverlap = isZone ? 190.0 : 160.0;

    final double maxCardWidth = ResponsiveHelper.value(
      context,
      mobile: double.infinity,
      tablet: 440.0,
    );

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxCardWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main Celebration Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: mascotOverlap),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.space24,
                    (mascotSize + rewardSize + 4.0 - mascotOverlap) + AppSpacing.space12,
                    AppSpacing.space24,
                    AppSpacing.space24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: AppColors.celebrationBorder,
                      width: 3.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.celebrationShadow,
                        offset: Offset(0, 6.0),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Punchy 1-2 words title
                      Text(
                        _effectiveTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.uiHeading(
                          fontSize: 28.0,
                          color: AppColors.celebrationTitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space20),

                      // Jumbo 72dp 3D Clay Next Button
                      Center(
                        child: BubbleIconButton.next(
                          size: 72.0,
                          onPressed: onContinue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dominant Celebrating Mascot + Big Star / Trophy floating above head
                Positioned(
                  top: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Big Star or Big Trophy above Mascot
                      Image.asset(
                        isZone ? AppAssets.icTrophy : AppAssets.icStar,
                        width: rewardSize,
                        height: rewardSize,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4.0),

                      // Big Celebrating Mascot
                      MascotWidget(
                        mood: _mascotMood,
                        size: mascotSize,
                        animate: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
