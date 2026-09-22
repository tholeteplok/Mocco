import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/counting_question.dart';
import '../../../domain/services/counting_question_generator.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/cards/flashcard_answer.dart';
import '../../widgets/counting/counting_basket.dart';
import '../../widgets/counting/counting_floating_area.dart';
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
      widget.onCompleted?.call();
    }
  }

  void _handleAnswerTap(int answer) {
    if (_isAnswerCorrect) return; // already answered correctly

    setState(() => _selectedAnswer = answer);

    if (answer == _currentQuestion.correctAnswer) {
      // Correct! Child keeps full control — no auto-advance (v2.0 dopamine loop).
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 350), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));
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
        isMuted: SoundPlayer.instance.isMuted,
        onBack: widget.onBack,
        onAudioToggle: () {
          setState(() => SoundPlayer.instance.toggleMute());
        },
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
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
            Text(
              'Tebalkan angka $target!',
              style: AppTypography.uiHeading(
                fontSize: 22.0,
                color: AppColors.textPrimary,
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
            onCompleted: () {
              setState(() => _isTracingCompleted = true);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        // Tracing Action Controls: [ ▶ Contoh ] [ 🧽 Hapus ]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChunkyButton(
              text: '▶ Contoh',
              primaryColor: AppColors.cardSurface,
              bevelColor: AppColors.cardBevel,
              textColor: AppColors.textPrimary,
              fontSize: 14.0,
              height: 44.0,
              onPressed: () {
                _canvasKey.currentState?.playDemo();
              },
            ),
            const SizedBox(width: AppSpacing.space12),
            ChunkyButton(
              text: '🧽 Hapus',
              primaryColor: AppColors.cardSurface,
              bevelColor: AppColors.cardBevel,
              textColor: AppColors.textPrimary,
              fontSize: 14.0,
              height: 44.0,
              onPressed: () {
                _canvasKey.currentState?.clear();
                setState(() => _isTracingCompleted = false);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),

        // Primary CTA: Lanjut ke Berhitung ➜ (Adaptif & Anti-Frustrasi)
        SizedBox(
          width: 260.0,
          child: ChunkyButton(
            text: _isTracingCompleted
                ? 'Lanjut Berhitung ➜'
                : 'Tebalkan Dulu Ya ✏️',
            primaryColor: _isTracingCompleted
                ? AppColors.brandMintDark
                : AppColors.cardSurface,
            bevelColor: _isTracingCompleted
                ? const Color(0xFF1E8C82)
                : AppColors.cardBevel,
            textColor: _isTracingCompleted
                ? Colors.white
                : AppColors.textSecondary,
            fontSize: 16.0,
            height: 52.0,
            onPressed: () {
              if (_isTracingCompleted) {
                SoundPlayer.instance.playSuccess();
                _advanceToNext();
              } else {
                // Dorongan ramah anti-frustrasi: bimbing anak dengan demo
                SoundPlayer.instance.playEncouragement();
                _canvasKey.currentState?.playDemo();
              }
            },
          ),
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
        // Prompt Header & Audio Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              onPressed: () {
                SoundPlayer.instance.playPromptCount();
              },
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(
              'Hitung ada berapa buah?',
              style: AppTypography.uiHeading(
                fontSize: 22.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),

        // Main Diorama Card (Pure White Surface)
        ChunkyCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space16,
          ),
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

              // Optional counting helper (Single-Task Principle: hidden by default)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChunkyButton(
                    icon: Icon(
                      _showBasket
                          ? Icons.visibility_off_rounded
                          : Icons.shopping_basket_rounded,
                      size: 20.0,
                      color: AppColors.numberBevel,
                    ),
                    text: _showBasket ? 'Sembunyi' : 'Bantu',
                    primaryColor: AppColors.numberTint,
                    bevelColor: AppColors.numberBevel,
                    textColor: AppColors.textPrimary,
                    fontSize: 14.0,
                    height: 44.0,
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
              ? CelebrationBanner(
                  key: const ValueKey('celebration'),
                  title: 'Luar Biasa!',
                  subtitle: 'Kamu berhasil menghitung dengan benar!',
                  onNextPressed: _advanceToNext,
                )
              : Row(
                  key: const ValueKey('navigation'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replay / Reset (only action before answering — no skip)
                    ChunkyButton(
                      icon: const Icon(
                        Icons.replay_rounded,
                        size: 28.0,
                        color: AppColors.textPrimary,
                      ),
                      primaryColor: AppColors.cardSurface,
                      bevelColor: AppColors.cardBevel,
                      onPressed: () {
                        SoundPlayer.instance.playPop();
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
