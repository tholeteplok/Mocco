import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';

/// Parent Gate Dialog with "Hold 3s" protection (V9, V25, V29)
/// Protects exit and adult settings from accidental child presses.
class ParentGateDialog extends StatefulWidget {
  const ParentGateDialog({
    super.key,
    required this.onVerified,
  });

  final VoidCallback onVerified;

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.modalOverlay, // 40% solid dark overlay (V9/V25)
      builder: (context) => ParentGateDialog(
        onVerified: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog> {
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  static const int _holdDurationMs = 3000;
  static const int _tickIntervalMs = 50;

  void _startHolding() {
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0.0);

    _holdTimer = Timer.periodic(const Duration(milliseconds: _tickIntervalMs), (timer) {
      setState(() {
        _holdProgress += _tickIntervalMs / _holdDurationMs;
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          timer.cancel();
          SoundPlayer.instance.playSuccess();
          widget.onVerified();
        }
      });
    });
  }

  void _cancelHolding() {
    _holdTimer?.cancel();
    if (_holdProgress < 1.0) {
      setState(() => _holdProgress = 0.0);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
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
            color: AppColors.background,
            borderRadius: AppSpacing.roundedLarge,
            border: Border.all(
              color: AppColors.numberPrimary,
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.numberBevel,
                offset: Offset(0, AppSpacing.bevelNormal),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock Icon
              const Icon(
                Icons.lock_rounded,
                size: 56.0,
                color: AppColors.numberPrimary,
              ),
              const SizedBox(height: AppSpacing.space16),

              // Title (For parents)
              Text(
                'Area Orang Tua',
                style: AppTypography.uiHeading(fontSize: 22.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),

              Text(
                'Tekan dan tahan tombol selama 3 detik untuk melanjutkan.',
                style: AppTypography.uiInstruction(
                  fontSize: 15.0,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space24),

              // Hold Button with Circular / Linear Progress Fill
              GestureDetector(
                onTapDown: (_) => _startHolding(),
                onTapUp: (_) => _cancelHolding(),
                onTapCancel: () => _cancelHolding(),
                child: Container(
                  height: 64.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.numberTint,
                    borderRadius: AppSpacing.roundedPill,
                    border: Border.all(
                      color: AppColors.numberPrimary,
                      width: 2.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Progress fill
                      FractionallySizedBox(
                        widthFactor: _holdProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.numberPrimary,
                            borderRadius: AppSpacing.roundedPill,
                          ),
                        ),
                      ),
                      // Text label
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: _holdProgress > 0.5
                                  ? AppColors.textPrimary
                                  : AppColors.numberPrimary,
                            ),
                            const SizedBox(width: AppSpacing.space8),
                            Text(
                              'Tahan 3 Detik',
                              style: AppTypography.uiButton(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Cancel button
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 28.0),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
