import 'dart:async';
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
import '../../widgets/feedback/celebration_banner.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/mascot/mascot_widget.dart';
import '../../widgets/stage/diorama_stage.dart';
import '../../widgets/tracing/guided_tracing_canvas.dart';

/// Screen for Letter Learning (Metode Angka — Pinterest v2.0 Standard: Airy Clay)
///
/// Features:
/// - Step 1: Integrated Guided Tracing (Tebalkan Huruf) with flowing dashes & pencil demo
/// - Step 2-5: Audio-visual Letter Recognition Quiz with 3D clay cues & 4 symmetrical cards
/// - Vibrant mint green (#2EC4B6) success state transition
/// - Dopamine loop with Mascot Celebration Banner + "[ Lanjut → ]" CTA
class LetterOnboardingScreen extends StatefulWidget {
  const LetterOnboardingScreen({
    super.key,
    this.letterIndex = 0,
    this.totalSteps = 5,
    this.generator = const LetterDistractorGenerator(),
    this.onCompleted,
    this.onBack,
  });

  final int letterIndex;
  final int totalSteps;
  final LetterDistractorGenerator generator;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<LetterOnboardingScreen> createState() => _LetterOnboardingScreenState();
}

class _LetterOnboardingScreenState extends State<LetterOnboardingScreen> {
  final GlobalKey<GuidedTracingCanvasState> _canvasKey =
      GlobalKey<GuidedTracingCanvasState>();

  late int _currentIndex;
  int _currentStep = 1;

  // Tracing state (Step 1)
  bool _isTracingCompleted = false;
  bool _hasUserProgress = false;

  // Matching & Quiz state (Step 2-5)
  late List<String> _quizOptions;
  String? _selectedOption;
  bool _isAnswerCorrect = false;
  bool _isObjectTapped = false;

  final List<Timer> _activeTimers = [];

  LetterEntity get _currentLetter =>
      LetterEntity.alphabet[_currentIndex.clamp(0, LetterEntity.alphabet.length - 1)];

  bool get _isTracingStep => _currentStep == 1;
  bool get _isMatchingStep => _currentStep == 2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.letterIndex;
    _prepareCurrentStep();
  }

  @override
  void dispose() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _prepareCurrentStep() {
    if (_isTracingStep) {
      _isTracingCompleted = false;
      _hasUserProgress = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SoundPlayer.instance.playLetterName(_currentLetter.char);
        }
      });
    } else if (_isMatchingStep) {
      _generateMatchingQuestion();
    } else {
      _generateQuizQuestion();
    }
  }

  void _generateMatchingQuestion() {
    setState(() {
      _quizOptions = widget.generator.generateOptions(
        _currentLetter.lowercaseChar,
        isUppercase: false,
      );
      _selectedOption = null;
      _isAnswerCorrect = false;
      _isObjectTapped = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SoundPlayer.instance.playLetterName(_currentLetter.char);
      }
    });
  }

  void _generateQuizQuestion() {
    setState(() {
      _quizOptions = widget.generator.generateOptions(
        _currentLetter.char,
        mixedCase: true,
      );
      _selectedOption = null;
      _isAnswerCorrect = false;
      _isObjectTapped = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SoundPlayer.instance.playLetterName(_currentLetter.char);
      }
    });
  }

  void _advanceToNext() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    if (_currentStep < widget.totalSteps) {
      setState(() {
        _currentStep++;
      });
      _prepareCurrentStep();
    } else {
      widget.onCompleted?.call();
    }
  }

  void _handleOptionTap(String option) {
    if (_isAnswerCorrect) return;

    setState(() => _selectedOption = option);

    final bool matches = _isMatchingStep
        ? option == _currentLetter.lowercaseChar
        : option.toLowerCase() == _currentLetter.char.toLowerCase();

    if (matches) {
      // Jawaban Benar
      setState(() => _isAnswerCorrect = true);
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));
      CelebrationPopup.show(
        context: context,
        title: _isMatchingStep ? 'Hebat!' : 'Luar Biasa!',
        subtitle: _isMatchingStep
            ? 'Pasangan ${_currentLetter.char} dan ${_currentLetter.lowercaseChar} cocok!'
            : 'Kamu menemukan huruf ${_currentLetter.char}!',
        buttonText: _currentStep < widget.totalSteps ? 'Lanjut' : 'Selesai',
        onNextPressed: _advanceToNext,
      );
    } else {
      // Soft retry ramah anak
      SoundPlayer.instance.playSoftRetry();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playEncouragement();
      }));
    }
  }

  void _playLetterAudio() {
    SoundPlayer.instance.playLetterName(_currentLetter.char);
    _activeTimers.add(Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        SoundPlayer.instance.playLetterPhonic(_currentLetter.char);
      }
    }));
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
          child: _isTracingStep
              ? _buildTracingStage()
              : _isMatchingStep
                  ? _buildMatchingStage()
                  : _buildQuizStage(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stage 1: Guided Tracing (Tebalkan Huruf Terintegrasi)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTracingStage() {
    final letter = _currentLetter;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header & Audio Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              primaryColor: AppColors.letterTint,
              borderColor: AppColors.letterPrimary,
              bevelColor: AppColors.letterBevel,
              onPressed: _playLetterAudio,
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(
              'Tebalkan huruf ${letter.pairDisplay}!',
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
            char: letter.char,
            strokeColor: AppColors.letterPrimary,
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
              SoundPlayer.instance.playSuccess();
              CelebrationPopup.show(
                context: context,
                title: 'Luar Biasa!',
                subtitle: 'Huruf ${letter.pairDisplay} berhasil ditebalkan!',
                buttonText: 'Lanjut Latihan',
                onNextPressed: _advanceToNext,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        // Single Combined Action Control: [ ▶ Contoh ]
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

        // Tombol CTA Adaptif: [ Tebalkan Dulu Ya ✏️ ] / [ Coba Lagi 🧽 ] / [ Lanjut Latihan ➜ ]
        if (_isTracingCompleted)
          SizedBox(
            width: 260.0,
            child: ChunkyButton(
              text: 'Lanjut Latihan ➜',
              primaryColor: AppColors.brandMint,
              bevelColor: AppColors.brandMintDark,
              textColor: AppColors.textWhite,
              fontSize: 16.0,
              height: 52.0,
              onPressed: () {
                SoundPlayer.instance.playSuccess();
                _advanceToNext();
              },
            ),
          )
        else if (_hasUserProgress)
          SizedBox(
            width: 260.0,
            child: ChunkyButton(
              text: 'Coba Lagi 🧽',
              primaryColor: AppColors.retryBackground,
              bevelColor: AppColors.retryBevel,
              textColor: const Color(0xFFC05621),
              fontSize: 16.0,
              height: 52.0,
              onPressed: () {
                SoundPlayer.instance.playEncouragement();
                _canvasKey.currentState?.clear();
                setState(() {
                  _hasUserProgress = false;
                  _isTracingCompleted = false;
                });
              },
            ),
          )
        else
          SizedBox(
            width: 260.0,
            child: ChunkyButton(
              text: 'Tebalkan Dulu Ya ✏️',
              primaryColor: AppColors.cardSurface,
              bevelColor: AppColors.cardBevel,
              textColor: AppColors.textSecondary,
              fontSize: 16.0,
              height: 52.0,
              onPressed: () {
                SoundPlayer.instance.playPromptTebalkan();
                _canvasKey.currentState?.playDemo();
              },
            ),
          ),
        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stage 2: Matching Uppercase to Lowercase (Latihan Pasangan Huruf Kapital & Kecil)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMatchingStage() {
    final letter = _currentLetter;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prompt Header & Audio Trigger (Minimalist)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              primaryColor: AppColors.letterTint,
              borderColor: AppColors.letterPrimary,
              bevelColor: AppColors.letterBevel,
              onPressed: _playLetterAudio,
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(
              'Pasangkan huruf ${letter.char}! 🧩',
              style: AppTypography.uiHeading(
                fontSize: 22.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),

        // Panggung Huruf Besar (Hero Diorama Stage — Bebas Kartu)
        DioramaStage(
          stageColor: AppColors.letterPrimary,
          floorShadowWidth: 120.0,
          floorShadowHeight: 12.0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
          child: Text(
            letter.char,
            style: AppTypography.learningDisplay(
              fontSize: 84.0,
              color: AppColors.letterPrimary,
            ).copyWith(
              shadows: [
                Shadow(
                  color: AppColors.letterBevel.withValues(alpha: 0.35),
                  offset: const Offset(0, 5.0),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // 4 Kartu Pilihan Huruf Kecil (Ukuran Seragam Simetris / Anti-Sosis)
        Row(
          children: _quizOptions.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrect = isSelected && option == letter.lowercaseChar;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FlashcardAnswer(
                  text: option,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  height: 72.0,
                  onTap: () => _handleOptionTap(option),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.space24),

        // Evaluasi Jawaban / Dorongan Coba Lagi
        if (!_isAnswerCorrect && _selectedOption != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MascotWidget(
                mood: MascotMood.thinking,
                size: 40.0,
                animate: true,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                'Yuk coba lagi! 🤗',
                style: AppTypography.uiHeading(
                  fontSize: 16.0,
                  color: const Color(0xFFC05621),
                ),
              ),
            ],
          ),

        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stage 3-5: Audio-to-Letter Quiz (Kuis Pengenalan Huruf Interaktif)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuizStage() {
    final letter = _currentLetter;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prompt Header & Audio Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioPromptButton(
              primaryColor: AppColors.letterTint,
              borderColor: AppColors.letterPrimary,
              bevelColor: AppColors.letterBevel,
              onPressed: _playLetterAudio,
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(
              'Mana huruf ${letter.pairDisplay}?',
              style: AppTypography.uiHeading(
                fontSize: 22.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),

        // Objek Cues Interaktif di Panggung (Airy Stage dengan Suara Benda Saat Ditekan)
        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space16,
            horizontal: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: AppColors.letterPrimary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.all(Radius.elliptical(140, 105)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isObjectTapped = true);
                  SoundPlayer.instance.playSquish();
                  SoundPlayer.instance.playWord(letter.exampleWord);
                  _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
                    if (mounted) setState(() => _isObjectTapped = false);
                  }));
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: _isObjectTapped ? 1.20 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (letter.imageAsset != null)
                        Image.asset(
                          letter.imageAsset!,
                          width: 140.0,
                          height: 140.0,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            letter.emoji.isNotEmpty ? letter.emoji : '🍎',
                            style: const TextStyle(fontSize: 90),
                          ),
                        )
                      else
                        Text(
                          letter.emoji.isNotEmpty ? letter.emoji : '🍎',
                          style: const TextStyle(fontSize: 90),
                        ),
                      const SizedBox(height: 6),
                      // Floor contact shadow
                      Container(
                        width: 90,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.letterBevel.withValues(alpha: 0.20),
                          borderRadius: const BorderRadius.all(Radius.elliptical(45, 6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${letter.char} untuk ${letter.exampleWord}',
                style: AppTypography.uiHeading(fontSize: 16.0).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.letterPrimary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Ketuk untuk mendengar',
                      style: AppTypography.uiBody(
                        fontSize: 12.0,
                        color: AppColors.letterPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // 4 Kartu Pilihan Jawaban Horizontal Simetris (Ukuran Seragam / Anti-Sosis)
        Row(
          children: _quizOptions.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrect =
                isSelected && option.toLowerCase() == letter.char.toLowerCase();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FlashcardAnswer(
                  text: option,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  height: 72.0,
                  onTap: () => _handleOptionTap(option),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.space24),

        // Evaluasi Jawaban / Dorongan Coba Lagi
        if (!_isAnswerCorrect && _selectedOption != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: const Color(0xFFFFD8A8),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                const MascotWidget(
                  mood: MascotMood.thinking,
                  size: 46.0,
                  animate: true,
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yuk coba lagi!',
                        style: AppTypography.uiHeading(
                          fontSize: 16.0,
                          color: const Color(0xFFC05621),
                        ),
                      ),
                      Text(
                        'Dengarkan suaranya dan pilih lagi ya.',
                        style: AppTypography.uiBody(
                          fontSize: 13.0,
                          color: const Color(0xFF9C4221),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }
}
