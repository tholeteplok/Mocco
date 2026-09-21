import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/headers/chunky_header.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/tracing/tracing_canvas.dart';

/// Screen for Letter Onboarding (Spec §1.1)
/// Flow:
/// 1. Display letter uppercase + lowercase side-by-side (e.g. "Aa")
/// 2. Audio button plays letter name and phonic sound
/// 3. Multisensory touch tracing canvas
/// 4. Proceed to quiz
class LetterOnboardingScreen extends StatefulWidget {
  const LetterOnboardingScreen({
    super.key,
    this.letterIndex = 0,
    this.onCompleted,
    this.onBack,
  });

  final int letterIndex;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<LetterOnboardingScreen> createState() => _LetterOnboardingScreenState();
}

class _LetterOnboardingScreenState extends State<LetterOnboardingScreen> {
  late int _currentIndex;
  bool _showTracing = false;
  final GlobalKey<TracingCanvasState> _tracingKey = GlobalKey();
  Timer? _phonicTimer;
  Timer? _praiseTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.letterIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playLetterAudio();
    });
  }

  @override
  void dispose() {
    _phonicTimer?.cancel();
    _praiseTimer?.cancel();
    super.dispose();
  }

  LetterEntity get _currentLetter => LetterEntity.alphabet[_currentIndex];

  void _playLetterAudio() {
    SoundPlayer.instance.playLetterName(_currentLetter.char);
    _phonicTimer?.cancel();
    _phonicTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        SoundPlayer.instance.playLetterPhonic(_currentLetter.char);
      }
    });
  }

  void _nextLetter() {
    if (_currentIndex < LetterEntity.alphabet.length - 1) {
      setState(() {
        _currentIndex++;
        _showTracing = false;
      });
      _playLetterAudio();
    } else {
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = ResponsiveHelper.isLandscape(context);

    return ResponsiveScaffold(
      header: ChunkyHeader(
        currentStep: _currentIndex + 1,
        totalSteps: LetterEntity.alphabet.length,
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
              // Audio prompt button to hear letter sound
              AudioPromptButton(
                primaryColor: AppColors.letterTint,
                borderColor: AppColors.letterPrimary,
                bevelColor: AppColors.letterBevel,
                onPressed: _playLetterAudio,
              ),
              const SizedBox(height: AppSpacing.space24),

              // Main Learning Card
              ChunkyCard(
                backgroundColor: const Color(0xFFE8F1FA),
                borderColor: AppColors.letterPrimary,
                bevelColor: AppColors.letterBevel,
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: isLandscape
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLetterDisplay(),
                          const SizedBox(width: AppSpacing.space24),
                          _buildTracingOrGuide(),
                        ],
                      )
                    : Column(
                        children: [
                          _buildLetterDisplay(),
                          const SizedBox(height: AppSpacing.space24),
                          _buildTracingOrGuide(),
                        ],
                      ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // Action Buttons (Icon-First)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle Tracing canvas
                  ChunkyButton(
                    icon: Icon(
                      _showTracing ? Icons.visibility_rounded : Icons.gesture_rounded,
                      size: 32.0,
                      color: AppColors.textPrimary,
                    ),
                    primaryColor: AppColors.letterTint,
                    bevelColor: AppColors.letterBevel,
                    onPressed: () {
                      setState(() => _showTracing = !_showTracing);
                      SoundPlayer.instance.playPop();
                    },
                  ),
                  const SizedBox(width: AppSpacing.space24),
                  // Forward / Next letter
                  ChunkyButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 32.0,
                      color: AppColors.textPrimary,
                    ),
                    primaryColor: AppColors.letterPrimary,
                    bevelColor: AppColors.letterBevel,
                    onPressed: _nextLetter,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Uppercase & Lowercase displayed together (Spec §1.1)
        Text(
          _currentLetter.pairDisplay,
          style: AppTypography.learningDisplay(
            fontSize: 110.0,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTracingOrGuide() {
    if (_showTracing) {
      return TracingCanvas(
        key: _tracingKey,
        letter: _currentLetter.char,
        width: 200.0,
        height: 200.0,
        onStrokeCompleted: () {
          SoundPlayer.instance.playSuccess();
          _praiseTimer?.cancel();
          _praiseTimer = Timer(const Duration(milliseconds: 350), () {
            if (mounted) SoundPlayer.instance.playPraise();
          });
        },
      );
    }

    // Default: Example object / word cue with tactile 3D clay aesthetic
    String? fruitAsset;
    switch (_currentLetter.char) {
      case 'A': fruitAsset = AppAssets.fruitApple; break;
      case 'B': fruitAsset = AppAssets.vegBroccoli; break;
      case 'J': fruitAsset = AppAssets.fruitOrange; break;
      case 'P': fruitAsset = AppAssets.fruitBanana; break;
      case 'S': fruitAsset = AppAssets.fruitStrawberry; break;
      case 'T': fruitAsset = AppAssets.vegTomato; break;
      case 'W': fruitAsset = AppAssets.vegCarrot; break;
    }

    return Container(
      width: 190.0,
      height: 190.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.letterPrimary,
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.letterBevel,
            offset: Offset(0, 4.0),
            blurRadius: 0.0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (fruitAsset != null)
            Image.asset(
              fruitAsset,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.contain,
            )
          else
            Icon(
              _currentLetter.icon,
              size: 72.0,
              color: AppColors.letterPrimary,
            ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            _currentLetter.exampleWord,
            style: AppTypography.uiHeading(
              fontSize: 22.0,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
