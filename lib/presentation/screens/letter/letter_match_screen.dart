import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/feedback/celebration_banner.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/stage/diorama_stage.dart';

/// Match uppercase to lowercase (reff: Match the Letter drag B-a).
/// 3 pairs per round, drag kiri ke kanan, tanpa gagal keras.
class LetterMatchScreen extends StatefulWidget {
  const LetterMatchScreen({
    super.key,
    this.totalSteps = 3,
    this.onCompleted,
    this.onBack,
  });

  final int totalSteps;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<LetterMatchScreen> createState() => _LetterMatchScreenState();
}

class _LetterMatchScreenState extends State<LetterMatchScreen> {
  int _currentStep = 1;
  late List<LetterEntity> _pairs;
  late List<String> _shuffledLower;
  final Map<String, String> _matches = {};
  String? _highlightLower;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  void _loadRound() {
    final catalog = List<LetterEntity>.from(LetterEntity.alphabet)..shuffle(_random);
    _pairs = catalog.take(3).toList();
    _shuffledLower = _pairs.map((e) => e.lowercaseChar).toList()..shuffle(_random);
    _matches.clear();
    _highlightLower = null;
  }

  bool get _isRoundComplete => _matches.length == _pairs.length;

  void _advance() {
    if (_currentStep < widget.totalSteps) {
      setState(() {
        _currentStep++;
        _loadRound();
      });
    } else {
      widget.onCompleted?.call();
    }
  }

  void _handleAccept(String upper, String lower) {
    final pair = _pairs.firstWhere((e) => e.char == upper);
    if (pair.lowercaseChar == lower) {
      setState(() {
        _matches[upper] = lower;
        _highlightLower = null;
      });
      if (_matches.length == _pairs.length) {
        SoundPlayer.instance.playCelebration();
        CelebrationPopup.show(
          context: context,
          title: 'Luar Biasa!',
          subtitle: 'Semua huruf berhasil dipasangkan!',
          buttonText: _currentStep < widget.totalSteps ? 'Lanjut' : 'Selesai',
          onNextPressed: _advance,
        );
      } else {
        SoundPlayer.instance.playSuccess();
      }
    } else {
      SoundPlayer.instance.playSoftRetry();
      setState(() => _highlightLower = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      header: ChunkyHeader(
        currentStep: _currentStep,
        totalSteps: widget.totalSteps,
        primaryColor: AppColors.letterPrimary,
        tintColor: AppColors.letterTint,
        bevelColor: AppColors.letterBevel,
        onBack: widget.onBack,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AudioPromptButton(
                    primaryColor: AppColors.letterTint,
                    borderColor: AppColors.letterPrimary,
                    bevelColor: AppColors.letterBevel,
                    onPressed: () {
                      SoundPlayer.instance.playPop();
                      if (_pairs.isNotEmpty) {
                        SoundPlayer.instance.playLetterName(_pairs.first.char);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Flexible(
                    child: Text(
                      'Pasangkan Huruf! 🧩',
                      style: AppTypography.uiHeading(
                        fontSize: 22.0,
                        color: AppColors.textPrimary,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              DioramaStage(
                stageColor: AppColors.letterPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space16,
                ),
                floorShadowWidth: 260.0,
                floorShadowHeight: 16.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: uppercase draggables
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final pair in _pairs) ...[
                            _buildUpperTile(pair),
                            if (pair != _pairs.last)
                              const SizedBox(height: AppSpacing.space16),
                          ],
                        ],
                      ),
                    ),
                    // Middle dashed connector hint
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomPaint(
                        size: const Size(24, 220),
                        painter: _MatchDashPainter(),
                      ),
                    ),
                    // Right: lowercase targets
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final lower in _shuffledLower) ...[
                            _buildLowerTarget(lower),
                            if (lower != _shuffledLower.last)
                              const SizedBox(height: AppSpacing.space16),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isRoundComplete
                    ? const SizedBox(key: ValueKey('match-celebration'), height: 32.0)
                    : Row(
                        key: const ValueKey('match-hint'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pairs.length, (index) {
                          final isFilled = index < _matches.length;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(
                              Icons.star_rounded,
                              size: 32.0,
                              color: isFilled
                                  ? AppColors.brandOrange
                                  : AppColors.cardBevel.withValues(alpha: 0.6),
                            ),
                          );
                        }),
                      ),
              ),
              const SizedBox(height: AppSpacing.space12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpperTile(LetterEntity pair) {
    final isMatched = _matches.containsKey(pair.char);
    if (isMatched) {
      return Container(
        height: 64.0,
        decoration: BoxDecoration(
          color: AppColors.successBannerBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.brandMint, width: 2.0),
        ),
        alignment: Alignment.center,
        child: Text(
          pair.char,
          style: AppTypography.learningDisplay(
            fontSize: 34.0,
            color: AppColors.brandMintDark,
          ),
        ),
      );
    }
    return Draggable<String>(
      data: pair.char,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 72.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.letterPrimary, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.letterBevel,
                offset: Offset(0, 4.0),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            pair.char,
            style: AppTypography.learningDisplay(
              fontSize: 34.0,
              color: const Color(0xFFE0574A),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        height: 64.0,
        decoration: BoxDecoration(
          color: AppColors.cardSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 2.0,
          ),
        ),
      ),
      child: Container(
        height: 64.0,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.letterPrimary, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardBevel,
              offset: Offset(0, 4.0),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          pair.char,
          style: AppTypography.learningDisplay(
            fontSize: 34.0,
            color: const Color(0xFFE0574A),
          ),
        ),
      ),
    );
  }

  Widget _buildLowerTarget(String lower) {
    final matchedUpper = _matches.entries
        .where((e) => e.value == lower)
        .map((e) => e.key)
        .firstOrNull;
    final isHighlighted = _highlightLower == lower;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          matchedUpper == null && !_matches.containsKey(details.data),
      onMove: (details) {
        if (_highlightLower != lower) setState(() => _highlightLower = lower);
      },
      onLeave: (data) {
        if (_highlightLower == lower) setState(() => _highlightLower = null);
      },
      onAcceptWithDetails: (details) => _handleAccept(details.data, lower),
      builder: (context, candidate, rejected) {
        final isHovered = candidate.isNotEmpty || isHighlighted;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64.0,
          decoration: BoxDecoration(
            color: matchedUpper != null
                ? AppColors.brandMint.withValues(alpha: 0.15)
                : isHovered
                    ? AppColors.letterTint
                    : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: matchedUpper != null
                  ? AppColors.brandMint
                  : AppColors.letterPrimary.withValues(alpha: 0.6),
              width: matchedUpper != null ? 2.5 : 2.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            matchedUpper ?? lower,
            style: AppTypography.learningDisplay(
              fontSize: 34.0,
              color: matchedUpper != null
                  ? AppColors.brandMintDark
                  : AppColors.letterPrimary,
            ),
          ),
        );
      },
    );
  }
}

class _MatchDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandMint.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const dash = 8.0;
    const gap = 7.0;
    double y = 4.0;
    final cx = size.width / 2;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
