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

/// Interactive Counting Screen (Pinterest v2.0 Standard: Airy Clay & Playful Diorama)
/// Features:
/// - Floating 3D clay objects without enclosing boxes
/// - Symmetrical 1x4 horizontal answer choice row (Zero wrap / anti-orphan)
/// - Vibrant mint green (#2EC4B6) success state transition
/// - Gamified dopamine loop with Mascot Celebration Banner + "[ Lanjut → ]" CTA
class CountingScreen extends StatefulWidget {
  const CountingScreen({
    super.key,
    this.totalSteps = 5,
    this.generator = const CountingQuestionGenerator(),
    this.onCompleted,
    this.onBack,
  });

  final int totalSteps;
  final CountingQuestionGenerator generator;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  late CountingQuestion _currentQuestion;
  int _currentStep = 1;
  int _selectedAnswer = -1;
  bool _isAnswerCorrect = false;
  final Set<int> _countedItemIds = <int>{};
  final List<Timer> _activeTimers = [];

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
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
      // Correct!
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 350), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));

      // Auto-advance backup timer (gives child ample time to enjoy dopamine cheer)
      _activeTimers.add(Timer(const Duration(milliseconds: 3200), () {
        if (mounted && _isAnswerCorrect) {
          _advanceToNext();
        }
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
          child: Column(
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
                      fontSize: 18.0,
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
                          // Replay / Reset
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
                          const SizedBox(width: AppSpacing.space24),
                          // Skip / Forward
                          ChunkyButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 28.0,
                              color: AppColors.textWhite,
                            ),
                            primaryColor: AppColors.brandMint,
                            bevelColor: AppColors.brandMintDark,
                            onPressed: () {
                              SoundPlayer.instance.playPop();
                              _advanceToNext();
                            },
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.space12),
            ],
          ),
        ),
      ),
    );
  }
}
