import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';

/// Single Floating Fruit/Vegetable Item (Pinterest v2.0 Standard)
/// Features:
/// - Pure transparent 3D clay presentation (zero enclosing box)
/// - Soft contact shadow on the floor for realistic diorama depth
/// - Interactive tactile bounce upon touch with visual count badge
class CountingObjectItem extends StatefulWidget {
  const CountingObjectItem({
    super.key,
    required this.id,
    required this.objectAsset,
    this.size = 68.0,
    this.isCounted = false,
    this.onTap,
  });

  final int id;
  final String objectAsset;
  final double size;
  final bool isCounted;
  final VoidCallback? onTap;

  @override
  State<CountingObjectItem> createState() => _CountingObjectItemState();
}

class _CountingObjectItemState extends State<CountingObjectItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(covariant CountingObjectItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCounted && !oldWidget.isCounted) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size + 10.0,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Soft Diorama Contact Shadow on the Floor
              Positioned(
                bottom: 2.0,
                child: Container(
                  width: widget.size * 0.65,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              // Transparent 3D Clay Fruit Asset
              Positioned(
                bottom: 8.0,
                child: Image.asset(
                  widget.objectAsset,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.eco_rounded,
                      size: widget.size * 0.7,
                      color: AppColors.numberPrimary,
                    );
                  },
                ),
              ),

              // Tactile Tap Badge (Visual checkmark when counted by touch)
              if (widget.isCounted)
                Positioned(
                  top: 0,
                  right: 4.0,
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      color: AppColors.brandMint,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2.0),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
