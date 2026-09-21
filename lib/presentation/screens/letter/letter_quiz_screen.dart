import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../../domain/services/letter_distractor_generator.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/flashcard_answer.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';

/// Audio-to-Letter Quiz Screen (Spec §1.3)
/// Flow:
/// 1. Audio prompt plays letter name or phonic sound
/// 2. 4 Flashcard choices with research-backed distractors
/// 3. Gentle feedback (visual joy when correct, soft retry when wrong)
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
      // Pick a random letter from catalog
      final letterCatalog = LetterEntity.alphabet;
      _targetLetter = letterCatalog[(_currentStep * 3) % letterCatalog.length];
      _options = widget.generator.generateOptions(_targetLetter.char, isUppercase: true);
      _selectedLetter = null;
      _isAnswerCorrect = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SoundPlayer.instance.playLetterName(_targetLetter.char);
      }
    });
  }

  void _handleOptionTap(String option) {
    if (_isAnswerCorrect) return;

    setState(() => _selectedLetter = option);

    if (option == _targetLetter.char) {
      // Correct answer!
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 350), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));

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

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      header: ChunkyHeader(
        currentStep: _currentStep,
        totalSteps: widget.totalSteps,
        primaryColor: AppColors.letterPrimary,
        tintColor: AppColors.letterTint,
        bevelColor: AppColors.letterBevel,
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
              // Audio prompt button to replay the question
              AudioPromptButton(
                primaryColor: AppColors.letterTint,
                borderColor: AppColors.letterPrimary,
                bevelColor: AppColors.letterBevel,
                onPressed: () {
                  SoundPlayer.instance.playLetterName(_targetLetter.char);
                },
              ),
              const SizedBox(height: AppSpacing.space32),

              // 4 Flashcard Answer Choices (Category Huruf - Pastel Blue)
              Wrap(
                spacing: AppSpacing.cardGap,
                runSpacing: AppSpacing.cardGap,
                alignment: WrapAlignment.center,
                children: [
                  for (final option in _options)
                    FlashcardAnswer(
                      text: option,
                      isSelected: _selectedLetter == option,
                      primaryColor: _selectedLetter == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBackground
                              : AppColors.retryBackground)
                          : AppColors.letterTint,
                      borderColor: _selectedLetter == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBevel
                              : AppColors.retryBevel)
                          : AppColors.letterPrimary,
                      bevelColor: _selectedLetter == option
                          ? (_isAnswerCorrect
                              ? AppColors.successBevel
                              : AppColors.retryBevel)
                          : AppColors.letterBevel,
                      onTap: () => _handleOptionTap(option),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.space32),

              // Icon-Only Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Replay question
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
                      setState(() => _selectedLetter = null);
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
                    primaryColor: AppColors.letterPrimary,
                    bevelColor: AppColors.letterBevel,
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
}
