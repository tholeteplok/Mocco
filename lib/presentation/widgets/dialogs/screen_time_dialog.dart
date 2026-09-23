import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../buttons/chunky_button.dart';
import '../mascot/mascot_widget.dart';

/// Screen Time Rest Dialog (Child Wellbeing & Gentle Habit Priming)
///
/// Features:
/// - Sleeping Mocco mascot ([MascotMood.sleeping]) with gentle breathing animation.
/// - Calming pastel night palette.
/// - Non-punitive, positive boundary setting for healthy screen habits.
class ScreenTimeDialog extends StatelessWidget {
  const ScreenTimeDialog({
    super.key,
    this.onDismiss,
  });

  final VoidCallback? onDismiss;

  static Future<void> show(BuildContext context, {VoidCallback? onDismiss}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.modalOverlay,
      builder: (context) => ScreenTimeDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320.0,
          padding: const EdgeInsets.all(AppSpacing.space24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FC),
            borderRadius: AppSpacing.roundedLarge,
            border: Border.all(
              color: const Color(0xFF90B4EE),
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF6B92D6),
                offset: Offset(0, AppSpacing.bevelNormal),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleeping Mascot with subtle floating breath
              const MascotWidget(
                mood: MascotMood.sleeping,
                size: 96.0,
                animate: true,
                showShadow: true,
              ),
              const SizedBox(height: AppSpacing.space16),

              // Title
              Text(
                'Waktunya Istirahat!',
                style: AppTypography.uiHeading(
                  fontSize: 22.0,
                  color: const Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),

              // Description (Gentle Priming)
              Text(
                'Mocco sudah mengantuk zzz...\nYuk simpan dulu dan istirahatkan matamu!',
                style: AppTypography.uiBody(
                  fontSize: 14.0,
                  color: const Color(0xFF3B5998),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space20),

              // Dismiss CTA Button
              ChunkyButton(
                text: 'Oke, Mocco!',
                primaryColor: const Color(0xFF4A7BD0),
                bevelColor: const Color(0xFF2E5499),
                textColor: AppColors.textWhite,
                height: 48.0,
                onPressed: () {
                  SoundPlayer.instance.playPop();
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
