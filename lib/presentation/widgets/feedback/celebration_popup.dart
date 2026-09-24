import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../buttons/chunky_button.dart';
import '../mascot/mascot_widget.dart';

/// Hero Overlap Mascot Celebration Popup (Opsi A: Bottom Sheet Modal)
///
/// Designed exclusively for pre-readers and toddlers:
/// 1. Dominant celebratory mascot (130dp) overflowing/overlapping the top card border (3D Breakout Mascot).
/// 2. Clean, high-contrast congratulatory typography.
/// 3. Wide, full-width ChunkyButton (54dp high) that prevents text truncation ("Lanjut Latihan")
///    and provides a massive, satisfying tap hit-box for little fingers.
class CelebrationPopup extends StatelessWidget {
  const CelebrationPopup({
    super.key,
    required this.onNextPressed,
    this.title = 'Hebat Sekali!',
    this.subtitle = 'Jawabanmu benar!',
    this.buttonText = 'Lanjut Latihan',
    this.mascotMood = MascotMood.celebrate,
  });

  final VoidCallback onNextPressed;
  final String title;
  final String subtitle;
  final String buttonText;
  final MascotMood mascotMood;

  /// Displays the modal bottom-sheet celebration popup with dimmed background scrim.
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onNextPressed,
    String title = 'Hebat Sekali!',
    String subtitle = 'Jawabanmu benar!',
    String buttonText = 'Lanjut Latihan',
    MascotMood mascotMood = MascotMood.celebrate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalOverlay,
      builder: (modalContext) => CelebrationPopup(
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        mascotMood: mascotMood,
        onNextPressed: () {
          Navigator.of(modalContext).pop();
          onNextPressed();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double mascotSize = 130.0;
    const double mascotOverlap = 65.0; // Half of mascot stands outside card top
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
                  margin: const EdgeInsets.only(top: mascotOverlap),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space24,
                    mascotOverlap + AppSpacing.space12,
                    AppSpacing.space24,
                    AppSpacing.space20,
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
                      // Joyful Affirmation Title
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.uiHeading(
                          fontSize: 24.0,
                          color: AppColors.celebrationTitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),

                      // Explanatory Affirmation Subtitle
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.uiBody(
                          fontSize: 16.0,
                          color: AppColors.celebrationSubtitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space20),

                      // Full-width Heroic Action Button (No truncated text)
                      SizedBox(
                        width: double.infinity,
                        height: 54.0,
                        child: ChunkyButton(
                          text: buttonText,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.textWhite,
                            size: 22.0,
                          ),
                          primaryColor: AppColors.brandMint,
                          bevelColor: AppColors.brandMintDark,
                          textColor: AppColors.textWhite,
                          fontSize: 18.0,
                          height: 54.0,
                          onPressed: onNextPressed,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dominant Celebrating Mascot overlapping top card border
                Positioned(
                  top: 0,
                  child: MascotWidget(
                    mood: mascotMood,
                    size: mascotSize,
                    animate: true,
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
