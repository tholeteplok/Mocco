import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/counting_question.dart';
import '../../../domain/services/counting_question_generator.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/cards/flashcard_answer.dart';
import '../../widgets/counting/counting_basket.dart';
import '../../widgets/counting/counting_grid_area.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';

/// Interactive Counting Practice Screen (Core Numerasi - Jalur Angka)
/// Features:
/// - Pre-reader friendly (Icon-First navigation & Audio Prompt)
/// - Drag-and-drop CountingBasket for tactile 1-to-1 correspondence (V16)
/// - Subitizing 5+n grid for numbers 6–10
/// - 4 Flashcard answers with correct ± 1 distractors
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

      // Auto advance after 1 second of visual joy
      _activeTimers.add(Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        if (_currentStep < widget.totalSteps) {
          setState(() => _currentStep++);
          _loadNextQuestion();
        } else {
          widget.onCompleted?.call();
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
    final isLandscape = ResponsiveHelper.isLandscape(context);

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Audio prompt button at top
              AudioPromptButton(
                onPressed: () {
                  SoundPlayer.instance.playPromptCount();
                },
              ),
              const SizedBox(height: AppSpacing.space16),

              // Main Counting Area (Card with Objects & Basket)
              ChunkyCard(
                backgroundColor: const Color(0xFFFFF3E0),
                borderColor: AppColors.numberPrimary,
                bevelColor: AppColors.numberBevel,
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: isLandscape
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _buildGridArea()),
                          const SizedBox(width: AppSpacing.space16),
                          _buildBasket(),
                        ],
                      )
                    : Column(
                        children: [
                          _buildGridArea(),
                          const SizedBox(height: AppSpacing.space16),
                          _buildBasket(),
                        ],
                      ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // 4 Flashcard Answer Options
              Wrap(
                spacing: AppSpacing.cardGap,
                runSpacing: AppSpacing.cardGap,
                alignment: WrapAlignment.center,
                children: [
                  for (final option in _currentQuestion.options)
                    FlashcardAnswer(
                      text: '$option',
                      isSelected: _selectedAnswer == option,
                      primaryColor: _selectedAnswer == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBackground
                              : AppColors.retryBackground)
                          : AppColors.numberTint,
                      borderColor: _selectedAnswer == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBevel
                              : AppColors.retryBevel)
                          : AppColors.numberPrimary,
                      bevelColor: _selectedAnswer == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBevel
                              : AppColors.retryBevel)
                          : AppColors.numberBevel,
                      onTap: () => _handleAnswerTap(option),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.space24),

              // Icon-Only Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Replay question / reset basket
                  ChunkyButton(
                    icon: const Icon(
                      Icons.replay_rounded,
                      size: 32.0,
                      color: AppColors.textPrimary,
                    ),
                    primaryColor: AppColors.letterTint,
                    bevelColor: AppColors.letterBevel,
                    onPressed: () {
                      SoundPlayer.instance.playPop();
                      setState(() {
                        _countedItemIds.clear();
                        _selectedAnswer = -1;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.space24),
                  // Forward / Next
                  ChunkyButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 32.0,
                      color: AppColors.textPrimary,
                    ),
                    primaryColor: AppColors.numberPrimary,
                    bevelColor: AppColors.numberBevel,
                    onPressed: () {
                      SoundPlayer.instance.playPop();
                      if (_currentStep < widget.totalSteps) {
                        setState(() => _currentStep++);
                        _loadNextQuestion();
                      } else {
                        widget.onCompleted?.call();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridArea() {
    return CountingGridArea(
      totalCount: _currentQuestion.count,
      objectAsset: _currentQuestion.objectType,
      countedItemIds: _countedItemIds,
      onItemTapped: (id) {
        // Tapping an item drops it into the basket
        if (_countedItemIds.contains(id)) {
          _handleItemRemoved(id);
        } else {
          _handleItemDropped(id);
        }
      },
    );
  }

  Widget _buildBasket() {
    return CountingBasket(
      countedItemIds: _countedItemIds,
      objectAsset: _currentQuestion.objectType,
      onItemDropped: _handleItemDropped,
      onItemRemoved: _handleItemRemoved,
    );
  }
}
