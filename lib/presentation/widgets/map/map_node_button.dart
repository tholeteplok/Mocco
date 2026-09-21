import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';

enum MapNodeStatus {
  locked,
  active,
  completed,
}

/// 3D Clay Stepping Stone Node for Adventure Map (Spec v1.4 §5, Pinterest Toy Aesthetic)
/// Tactile rounded plasticine pebble with radial specular highlight, solid 2.5D bevel,
/// active glowing pulse, and 3D golden star badges.
class MapNodeButton extends StatefulWidget {
  const MapNodeButton({
    super.key,
    required this.label,
    required this.status,
    required this.onTap,
    this.primaryColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.size = 80.0,
  });

  final String label;
  final MapNodeStatus status;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color bevelColor;
  final double size;

  @override
  State<MapNodeButton> createState() => _MapNodeButtonState();
}

class _MapNodeButtonState extends State<MapNodeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == MapNodeStatus.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MapNodeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == MapNodeStatus.active && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.status != MapNodeStatus.active && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == MapNodeStatus.locked;
    final isActive = widget.status == MapNodeStatus.active;
    final isCompleted = widget.status == MapNodeStatus.completed;

    final stoneColor = isLocked ? const Color(0xFFDCD8D3) : widget.primaryColor;
    final bevelColor = isLocked ? const Color(0xFFB0ABA4) : widget.bevelColor;

    final bevelHeight = _isPressed ? 2.0 : 6.0;
    final topOffset = _isPressed ? 4.0 : 0.0;

    Widget content = GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isLocked
          ? null
          : (_) {
              setState(() => _isPressed = false);
              SoundPlayer.instance.playPop();
              widget.onTap();
            },
      onTapCancel: isLocked ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: topOffset, bottom: 6.0 - topOffset),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 0.85,
            colors: [
              HSLColor.fromColor(stoneColor)
                  .withLightness((HSLColor.fromColor(stoneColor).lightness + 0.14).clamp(0.0, 1.0))
                  .toColor(),
              stoneColor,
              HSLColor.fromColor(stoneColor)
                  .withLightness((HSLColor.fromColor(stoneColor).lightness - 0.08).clamp(0.0, 1.0))
                  .toColor(),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: bevelColor,
            width: 3.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            // Active golden halo ring
            if (isActive)
              BoxShadow(
                color: AppColors.retryBevel.withValues(alpha: 0.8),
                offset: const Offset(0, 0),
                blurRadius: 10.0,
                spreadRadius: 3.0,
              ),
            // Solid 2.5D bottom bevel
            BoxShadow(
              color: bevelColor,
              offset: Offset(0, bevelHeight),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isLocked)
              const Icon(
                Icons.lock_rounded,
                size: 32.0,
                color: Color(0xFF8C867F),
              )
            else
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTypography.learningDisplay(
                  fontSize: widget.label.length > 3 ? 24.0 : 34.0,
                  color: AppColors.textPrimary,
                ),
              ),

            // Top flag for Active node
            if (isActive)
              Positioned(
                top: -14.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.retryBevel,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(color: AppColors.textPrimary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 16.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            // 3 Stars badge for Completed node
            if (isCompleted)
              Positioned(
                bottom: -10.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: AppColors.retryBevel, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 2.0),
                        blurRadius: 0.0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 13.0, color: AppColors.retryBevel),
                      Icon(Icons.star_rounded, size: 15.0, color: AppColors.retryBevel),
                      Icon(Icons.star_rounded, size: 13.0, color: AppColors.retryBevel),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isActive) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      );
    }

    return content;
  }
}
