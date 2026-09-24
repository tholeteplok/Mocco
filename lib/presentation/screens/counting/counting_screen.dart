import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../data/datasources/mastery_local_datasource.dart';
import '../../../domain/entities/counting_question.dart';
import '../../../domain/services/counting_question_generator.dart';
import '../../widgets/buttons/adaptive_tracing_cta.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/bubble_icon_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/flashcard_answer.dart';
import '../../widgets/counting/counting_basket.dart';
import '../../widgets/counting/counting_floating_area.dart';
import '../../widgets/stage/diorama_stage.dart';
import '../../widgets/feedback/celebration_banner.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/tracing/guided_tracing_canvas.dart';

/// Interactive Counting Screen (Pinterest v2.0 Standard: Airy Clay & Playful Diorama)
/// Features:
/// - Step 1: Integrated Guided Tracing (Tebalkan Angka) with flowing dashes & pencil demo
/// - Step 2-5: Floating 3D clay objects counting diorama
/// - Symmetrical 1x4 horizontal answer choice row (Zero wrap / anti-orphan)
/// - Vibrant mint green (#2EC4B6) success state transition
/// - Gamified dopamine loop with Mascot Celebration Banner + "[ Lanjut → ]" CTA
class CountingScreen extends StatefulWidget {
  const CountingScreen({
    super.key,
    this.totalSteps = 5,
    this.targetNumber,
    this.generator = const CountingQuestionGenerator(),
    this.onCompleted,
    this.onBack,
  });

  final int totalSteps;
  final int? targetNumber;
  final CountingQuestionGenerator generator;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  final GlobalKey<GuidedTracingCanvasState> _canvasKey =
      GlobalKey<GuidedTracingCanvasState>();

  late CountingQuestion _currentQuestion;
  int _currentStep = 1;
  int _selectedAnswer = -1;
  bool _isAnswerCorrect = false;
  bool _showBasket = false;
  final Set<int> _countedItemIds = <int>{};
  final List<Timer> _activeTimers = [];
  bool _isTracingCompleted = false;
  bool _hasUserProgress = false;
  int _sessionAttempts = 0;
  int _sessionCorrect = 0;

  int? get _effectiveTargetNumber =>
      widget.targetNumber ?? widget.generator.fixedTargetCount;

  bool get _isTracingStep =>
      _currentStep == 1 &&
      _effectiveTargetNumber != null &&
      _effectiveTargetNumber! > 0;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();

    if (_isTracingStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SoundPlayer.instance.playNumber(_effectiveTargetNumber!);
      });
    }
  }

  @override
  void dispose() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _loadNextQuestion() {
    setState(() {
      _currentQuestion = widget.generator.generate();
      _selectedAnswer = -1;
      _isAnswerCorrect = false;
      _countedItemIds.clear();
      _isTracingCompleted = false;
      _hasUserProgress = false;
    });
  }

  void _advanceToNext() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    if (_currentStep < widget.totalSteps) {
      setState(() => _currentStep++);
      _loadNextQuestion();
    } else {
      final targetNum = _effectiveTargetNumber;
      if (targetNum != null && targetNum > 0) {
        final attempts = _sessionAttempts > 0 ? _sessionAttempts : widget.totalSteps;
        final correct = _sessionCorrect > 0 ? _sessionCorrect : widget.totalSteps;
        HiveMasteryLocalDataSource().recordSessionResult(
          id: 'number_$targetNum',
          attempts: attempts,
          correct: correct,
        );
      }
      widget.onCompleted?.call();
    }
  }

  void _handleAnswerTap(int answer) {
    if (_isAnswerCorrect) return; // already answered correctly

    setState(() => _selectedAnswer = answer);
    _sessionAttempts++;

    if (answer == _currentQuestion.correctAnswer) {
      _sessionCorrect++;
      // Correct! Child keeps full control — no auto-advance (v2.0 dopamine loop).
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));
      CelebrationPopup.show(
        context: context,
        title: 'Luar Biasa!',
        subtitle: 'Kamu berhasil menghitung dengan benar!',
        buttonText: _currentStep < widget.totalSteps ? 'Lanjut' : 'Selesai',
        onNextPressed: _advanceToNext,
      );
    } else {
      // Soft retry - anti frustration (V0.4)
      SoundPlayer.instance.playSoftRetry();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playEncouragement();
      }));
    }
  }

  void _handleItemDropped(int id) {
    setState(() {
      _countedItemIds.add(id);
    });
    SoundPlayer.instance.playSquish();
    SoundPlayer.instance.playNumber(_countedItemIds.length);
  }

  void _handleItemRemoved(int id) {
    setState(() {
      _countedItemIds.remove(id);
    });
    SoundPlayer.instance.playPop();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      header: ChunkyHeader(
        currentStep: _currentStep,
        totalSteps: widget.totalSteps,
        onBack: widget.onBack,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
          child: _isTracingStep ? _buildTracingStage() : _buildCountingStage(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stage 1: Guided Tracing (Tebalkan Angka Terintegrasi)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTracingStage() {
    final target = _effectiveTargetNumber!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prompt Header & Audio Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              onPressed: () {
                SoundPlayer.instance.playNumber(target);
              },
            ),
            const SizedBox(width: AppSpacing.space12),
            Flexible(
              child: Text(
                'Tebalkan angka $target!',
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
        const SizedBox(height: AppSpacing.space20),

        // Tracing Canvas with flowing dashes, pencil demo & proximity coverage
        Center(
          child: GuidedTracingCanvas(
            key: _canvasKey,
            char: '$target',
            strokeColor: AppColors.numberPrimary,
            size: 290.0,
            onProgressChanged: (p) {
              final hasStrokes = p > 0 || (_canvasKey.currentState?.hasUserStrokes ?? false);
              if (_hasUserProgress != hasStrokes) {
                setState(() => _hasUserProgress = hasStrokes);
              }
            },
            onCompleted: () {
              setState(() {
                _isTracingCompleted = true;
                _hasUserProgress = true;
              });
              CelebrationPopup.show(
                context: context,
                title: 'Luar Biasa!',
                subtitle: 'Angka $target berhasil ditebalkan!',
                buttonText: 'Lanjut Berhitung',
                onNextPressed: _advanceToNext,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        // Tracing Action Controls: [ ▶ Contoh ] (Gabungan Contoh & Hapus)
        ChunkyButton(
          icon: const Icon(Icons.play_arrow_rounded, size: 20.0, color: AppColors.textSecondary),
          text: 'Contoh',
          primaryColor: AppColors.cardSurface,
          bevelColor: AppColors.cardBevel,
          textColor: AppColors.textSecondary,
          fontSize: 14.0,
          height: 44.0,
          onPressed: () {
            _canvasKey.currentState?.clear();
            _canvasKey.currentState?.playDemo();
            setState(() {
              _isTracingCompleted = false;
              _hasUserProgress = false;
            });
          },
        ),
        const SizedBox(height: AppSpacing.space24),

        // Tombol CTA Adaptif Sentral: [ Tebalkan Dulu Ya ✏️ ] / [ Coba Lagi 🧽 ] / [ Lanjut Berhitung ➜ ]
        AdaptiveTracingCta(
          isCompleted: _isTracingCompleted,
          hasUserProgress: _hasUserProgress,
          advanceText: 'Lanjut Berhitung ➜',
          onAdvance: () {
            SoundPlayer.instance.playSuccess();
            _advanceToNext();
          },
          onRetry: () {
            SoundPlayer.instance.playEncouragement();
            _canvasKey.currentState?.clear();
            setState(() {
              _hasUserProgress = false;
              _isTracingCompleted = false;
            });
          },
          onPrompt: () {
            SoundPlayer.instance.playPromptTebalkan();
            _canvasKey.currentState?.playDemo();
          },
        ),
        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stage 2-5: Interactive Counting Diorama
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCountingStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prompt Header & Audio Trigger (Minimalist / Pre-reader friendly)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              onPressed: () {
                SoundPlayer.instance.playPromptCount();
              },
            ),
            const SizedBox(width: AppSpacing.space12),
            Flexible(
              child: Text(
                'Hitung buahnya! 🍎',
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

        // Open Floating Diorama Stage (Bebas Kartu — Living Island)
        DioramaStage(
          stageColor: AppColors.numberPrimary,
          floorShadowWidth: 240.0,
          floorShadowHeight: 16.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating 3D Fruit Area
              CountingFloatingArea(
                totalCount: _currentQuestion.count,
                objectAsset: _currentQuestion.objectType,
                countedItemIds: _countedItemIds,
                onItemTapped: (id) {
                  if (_countedItemIds.contains(id)) {
                    _handleItemRemoved(id);
                  } else {
                    _handleItemDropped(id);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.space8),

              // Optional counting helper (Icon-only: Shopping Basket 🧺)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChunkyButton(
                    icon: Icon(
                      _showBasket
                          ? Icons.visibility_off_rounded
                          : Icons.shopping_basket_rounded,
                      size: 22.0,
                      color: AppColors.numberBevel,
                    ),
                    primaryColor: AppColors.numberTint,
                    bevelColor: AppColors.numberBevel,
                    height: 44.0,
                    width: 52.0,
                    onPressed: () {
                      SoundPlayer.instance.playPop();
                      setState(() => _showBasket = !_showBasket);
                    },
                  ),
                ],
              ),
              if (_showBasket) ...[
                const SizedBox(height: AppSpacing.space8),
                // Soft Basket Shelf (Clean diorama companion)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CountingBasket(
                      width: 84.0,
                      height: 74.0,
                      countedItemIds: _countedItemIds,
                      objectAsset: _currentQuestion.objectType,
                      onItemDropped: _handleItemDropped,
                      onItemRemoved: _handleItemRemoved,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space20),

        // Symmetrical 1x4 Answer Choices (Pinterest Anti-Orphan Grid)
        Row(
          children: [
            for (final option in _currentQuestion.options)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FlashcardAnswer(
                    text: '$option',
                    isSelected: _selectedAnswer == option,
                    isCorrect: _isAnswerCorrect && _selectedAnswer == option,
                    primaryColor: _selectedAnswer == option
                        ? (_isAnswerCorrect
                            ? AppColors.successBackground
                            : AppColors.retryBackground)
                        : AppColors.cardSurface,
                    borderColor: _selectedAnswer == option
                        ? (_isAnswerCorrect
                            ? AppColors.brandMintDark
                            : AppColors.retryBevel)
                        : AppColors.cardBorder,
                    bevelColor: _selectedAnswer == option
                        ? (_isAnswerCorrect
                            ? AppColors.brandMintDark
                            : AppColors.retryBevel)
                        : AppColors.cardBevel,
                    onTap: () => _handleAnswerTap(option),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.space16),

        // Bottom Section: Celebration Banner OR Navigation Controls
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _isAnswerCorrect
              ? const SizedBox(key: ValueKey('celebration'), height: 52.0)
              : Row(
                  key: const ValueKey('navigation'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replay / Reset (3D Clay Replay Button)
                    BubbleIconButton.replay(
                      onPressed: () {
                        setState(() {
                          _countedItemIds.clear();
                          _selectedAnswer = -1;
                        });
                      },
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.space12),
      ],
    );
  }
}
