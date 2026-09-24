import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/sound_player.dart';

/// Types of 3D Clay Diorama Buttons
enum ClayButtonType {
  back,
  next,
  parents,
  play,
  sound,
  voice,
  replay,
  custom,
}

/// Border-free 3D Claymorphic Button for Mocco (DS 2.0)
///
/// Menggunakan aset 3D render tanah liat asli dengan varian normal & pressed.
/// PENTING: Komponen ini TIDAK dibingkai dengan container/border/box-shadow artifisial,
/// melainkan merender bentuk organik mainan tanah liat langsung secara transparan.
class BubbleIconButton extends StatefulWidget {
  const BubbleIconButton({
    super.key,
    this.type,
    this.icon,
    required this.onPressed,
    this.isMuted = false,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  });

  const BubbleIconButton.back({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.back,
        icon = null,
        isMuted = false;

  const BubbleIconButton.next({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.next,
        icon = null,
        isMuted = false;

  const BubbleIconButton.parents({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.parents,
        icon = null,
        isMuted = false;

  const BubbleIconButton.play({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.play,
        icon = null,
        isMuted = false;

  const BubbleIconButton.sound({
    super.key,
    required this.isMuted,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.sound,
        icon = null;

  const BubbleIconButton.voice({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.voice,
        icon = null,
        isMuted = false;

  const BubbleIconButton.replay({
    super.key,
    required this.onPressed,
    this.size = AppSpacing.bubbleButtonSize,
    this.primaryColor = AppColors.background,
    this.bevelColor = AppColors.numberBevel,
    this.borderColor = AppColors.numberPrimary,
    this.iconColor = AppColors.textPrimary,
  })  : type = ClayButtonType.replay,
        icon = null,
        isMuted = false;

  final ClayButtonType? type;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isMuted;
  final double size;
  final Color primaryColor;
  final Color bevelColor;
  final Color borderColor;
  final Color iconColor;

  @override
  State<BubbleIconButton> createState() => _BubbleIconButtonState();
}

class _BubbleIconButtonState extends State<BubbleIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    SoundPlayer.instance.playPop();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  ({String normal, String pressed})? _resolveAssets() {
    ClayButtonType? effectiveType = widget.type;

    if (effectiveType == null && widget.icon != null) {
      final code = widget.icon!.codePoint;
      if (widget.icon == Icons.arrow_back_rounded ||
          widget.icon == Icons.arrow_back ||
          code == Icons.arrow_back_rounded.codePoint) {
        effectiveType = ClayButtonType.back;
      } else if (widget.icon == Icons.arrow_forward_rounded ||
          widget.icon == Icons.arrow_forward ||
          code == Icons.arrow_forward_rounded.codePoint) {
        effectiveType = ClayButtonType.next;
      } else if (widget.icon == Icons.lock_rounded ||
          widget.icon == Icons.lock ||
          code == Icons.lock_rounded.codePoint) {
        effectiveType = ClayButtonType.parents;
      } else if (widget.icon == Icons.play_arrow_rounded ||
          widget.icon == Icons.play_arrow ||
          code == Icons.play_arrow_rounded.codePoint) {
        effectiveType = ClayButtonType.play;
      } else if (widget.icon == Icons.volume_up_rounded ||
          widget.icon == Icons.volume_up ||
          code == Icons.volume_up_rounded.codePoint) {
        effectiveType = ClayButtonType.sound;
      } else if (widget.icon == Icons.volume_off_rounded ||
          widget.icon == Icons.volume_off ||
          code == Icons.volume_off_rounded.codePoint) {
        effectiveType = ClayButtonType.sound;
      } else if (widget.icon == Icons.replay_rounded ||
          widget.icon == Icons.refresh_rounded ||
          widget.icon == Icons.replay ||
          code == Icons.replay_rounded.codePoint) {
        effectiveType = ClayButtonType.replay;
      }
    }

    switch (effectiveType) {
      case ClayButtonType.back:
        return (normal: AppAssets.btnBack, pressed: AppAssets.btnBackPressed);
      case ClayButtonType.next:
        return (normal: AppAssets.btnNext, pressed: AppAssets.btnNextPressed);
      case ClayButtonType.parents:
        return (normal: AppAssets.btnParents, pressed: AppAssets.btnParentsPressed);
      case ClayButtonType.play:
        return (normal: AppAssets.btnPlay, pressed: AppAssets.btnPlayPressed);
      case ClayButtonType.sound:
        final bool muted = widget.isMuted || widget.icon == Icons.volume_off_rounded;
        final asset = muted ? AppAssets.btnSoundOff : AppAssets.btnSoundOn;
        return (normal: asset, pressed: asset);
      case ClayButtonType.voice:
        return (normal: AppAssets.btnVoice, pressed: AppAssets.btnVoicePressed);
      case ClayButtonType.replay:
        return (normal: AppAssets.btnReplay, pressed: AppAssets.btnReplayPressed);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPair = _resolveAssets();

    Widget buttonContent;
    if (assetPair != null) {
      final assetPath = _isPressed ? assetPair.pressed : assetPair.normal;
      buttonContent = Image.asset(
        assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    } else {
      // Fallback transparan tanpa kontainer jika ikon khusus
      buttonContent = Icon(
        widget.icon ?? Icons.circle,
        size: widget.size * 0.5,
        color: widget.iconColor,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: _isPressed ? 0.94 : 1.0,
        alignment: Alignment.center,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
