import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/utils/sound_player.dart';

/// Semantic emotional moods for the Mocco mascot.
enum MascotMood {
  greeting,
  reading,
  celebrate,
  love,
  thinking,
  thumbsUp,
  crawling,
  sleeping,
  exploring;

  String get assetPath {
    switch (this) {
      case MascotMood.greeting:
        return AppAssets.mascotGreeting;
      case MascotMood.reading:
        return AppAssets.mascotReading;
      case MascotMood.celebrate:
        return AppAssets.mascotCelebrate;
      case MascotMood.love:
        return AppAssets.mascotLove;
      case MascotMood.thinking:
        return AppAssets.mascotThinking;
      case MascotMood.thumbsUp:
        return AppAssets.mascotThumbsUp;
      case MascotMood.crawling:
        return AppAssets.mascotCrawling;
      case MascotMood.sleeping:
        return AppAssets.mascotSleeping;
      case MascotMood.exploring:
        return AppAssets.mascotExploring;
    }
  }
}

/// Centralized 3D Clay Mascot Widget (Pinterest Toy Aesthetic).
///
/// Features:
/// - Contextual mood switching via [MascotMood].
/// - Optional lightweight breathing/floating micro-animation ([animate]).
/// - Optional soft clay ambient shadow underneath ([showShadow]).
/// - Tactile playful tap interaction with sound feedback ([onTap]).
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    super.key,
    required this.mood,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.animate = false,
    this.showShadow = false,
    this.onTap,
  });

  final MascotMood mood;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool animate;
  final bool showShadow;
  final VoidCallback? onTap;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _floatAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _initAnimation();
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        if (_controller == null) {
          _initAnimation();
        } else {
          _controller?.repeat(reverse: true);
        }
      } else {
        _controller?.stop();
        _controller?.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double targetWidth = widget.width ?? widget.size ?? 64.0;
    final double targetHeight = widget.height ?? widget.size ?? 64.0;

    Widget imageContent = Image.asset(
      widget.mood.assetPath,
      width: targetWidth,
      height: targetHeight,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: targetWidth,
        height: targetHeight,
        decoration: BoxDecoration(
          color: AppColors.brandMint.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.sentiment_very_satisfied_rounded,
          size: targetWidth * 0.6,
          color: AppColors.brandMint,
        ),
      ),
    );

    if (widget.animate && _floatAnimation != null) {
      imageContent = AnimatedBuilder(
        animation: _floatAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation!.value),
            child: child,
          );
        },
        child: imageContent,
      );
    }

    Widget content;
    if (widget.showShadow) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imageContent,
          Container(
            width: targetWidth * 0.65,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.all(
                Radius.elliptical(targetWidth * 0.65, 4.5),
              ),
            ),
          ),
        ],
      );
    } else {
      content = imageContent;
    }

    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          SoundPlayer.instance.playSquish();
          widget.onTap!();
        },
        child: content,
      );
    }

    return content;
  }
}
