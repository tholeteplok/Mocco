import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../../domain/services/letter_distractor_generator.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/flashcard_answer.dart';
import '../../widgets/stage/diorama_stage.dart';
import '../../widgets/feedback/celebration_banner.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';

/// Audio-to-Letter Quiz Screen (Pinterest v2.0 Standard: Airy Clay & Playful Diorama)
/// Features:
/// - Symmetrical 1x4 horizontal answer choice row
/// - Mint green (#2EC4B6) success highlight
/// - Gamified dopamine loop with Mascot Celebration Banner + "[ Lanjut → ]" CTA
class LetterQuizScreen extends StatefulWidget {
  const LetterQuizScreen({
    super.key,
    this.totalSteps = 5,
    this.generator = const LetterDistractorGenerator(),
    this.onCompleted,
    this.onBack,
  });

  final int totalSteps;
  final LetterDistractorGenerator generator;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<LetterQuizScreen> createState() => _LetterQuizScreenState();
}

class _LetterQuizScreenState extends State<LetterQuizScreen> {
  int _currentStep = 1;
  late LetterEntity _targetLetter;
  late List<String> _options;
  String? _selectedLetter;
  bool _isAnswerCorrect = false;
  final List<Timer> _activeTimers = [];
  final Random _random = Random();
  String _lastTargetChar = '';

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
      final letterCatalog = LetterEntity.alphabet;
      // Random target with no immediate repeat (early Leitner feel).
      LetterEntity candidate;
      do {
        candidate = letterCatalog[_random.nextInt(letterCatalog.length)];
      } while (candidate.char == _lastTargetChar && letterCatalog.length > 1);
      _targetLetter = candidate;
      _lastTargetChar = candidate.char;
      _options = widget.generator.generateOptions(_targetLetter.char, mixedCase: true);
      _selectedLetter = null;
      _isAnswerCorrect = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SoundPlayer.instance.playLetterName(_targetLetter.char);
      }
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

  void _handleOptionTap(String option) {
    if (_isAnswerCorrect) return;

    setState(() => _selectedLetter = option);

    if (option.toLowerCase() == _targetLetter.char.toLowerCase()) {
      // Correct answer! Child keeps full control — no auto-advance.
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));
      CelebrationPopup.show(
        context: context,
        title: 'Hebat Sekali!',
        subtitle:
            '${_targetLetter.pairDisplay} yang tepat! Bunyinya ${_targetLetter.phonic}',
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero Acoustic Sound Stage (Bebas Kartu — Living Stage)
              DioramaStage(
                stageColor: AppColors.letterPrimary,
                floorShadowWidth: 140.0,
                floorShadowHeight: 14.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AudioPromptButton(
                      size: 80.0,
                      primaryColor: AppColors.letterTint,
                      borderColor: AppColors.letterPrimary,
                      bevelColor: AppColors.letterBevel,
                      onPressed: () {
                        SoundPlayer.instance.playLetterName(_targetLetter.char);
                      },
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          size: 20.0,
                          color: AppColors.letterPrimary,
                        ),
                        const SizedBox(width: AppSpacing.space8),
                        Text(
                          'Dengarkan bunyinya 🎵',
                          style: AppTypography.uiHeading(
                            fontSize: 18.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // 4 Flashcard Answer Choices in 1x4 Symmetrical Horizontal Row
              Row(
                children: [
                  for (final option in _options)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FlashcardAnswer(
                          text: option,
                          isSelected: _selectedLetter == option,
                          isCorrect: _isAnswerCorrect && _selectedLetter == option,
                          primaryColor: _selectedLetter == option
                              ? (_isAnswerCorrect
                                  ? AppColors.successBackground
                                  : AppColors.retryBackground)
                              : AppColors.cardSurface,
                          borderColor: _selectedLetter == option
                              ? (_isAnswerCorrect
                                  ? AppColors.brandMintDark
                                  : AppColors.retryBevel)
                              : AppColors.cardBorder,
                          bevelColor: _selectedLetter == option
                              ? (_isAnswerCorrect
                                  ? AppColors.brandMintDark
                                  : AppColors.retryBevel)
                              : AppColors.cardBevel,
                          onTap: () => _handleOptionTap(option),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.space20),

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
                    ? const SizedBox(key: ValueKey('celebration'), height: 72.0)
                    : Row(
                        key: const ValueKey('navigation'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Replay question (only action before answering — no skip)
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
                              setState(() => _selectedLetter = null);
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
