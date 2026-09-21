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

/// Screen for Letter Onboarding (Pinterest v2.0 Standard: Airy Clay & Playful Diorama)
/// Features:
/// - Side-by-side / balanced vertical diorama card layout
/// - Letter display (Aa) with tactile tracing canvas
/// - Floating 3D clay fruit cue (e.g. Apel for A) without enclosing box
/// - Intuitive audio prompt and self-paced next action
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Audio prompt header
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
                    'Ayo Belajar Huruf ${_currentLetter.char}!',
                    style: AppTypography.uiHeading(
                      fontSize: 18.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),

              // Main Learning Card (Pure White Surface)
              ChunkyCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space24,
                  vertical: AppSpacing.space20,
                ),
                child: isLandscape
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _buildLetterOrTracingSection()),
                          Container(
                            width: 1.5,
                            height: 180.0,
                            color: AppColors.cardBorder,
                          ),
                          Expanded(child: _buildCueSection()),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLetterOrTracingSection(),
                          const SizedBox(height: AppSpacing.space16),
                          Container(
                            height: 1.5,
                            width: double.infinity,
                            color: AppColors.cardBorder,
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          _buildCueSection(),
                        ],
                      ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // Action Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle Tracing canvas
                  ChunkyButton(
                    icon: Icon(
                      _showTracing ? Icons.visibility_rounded : Icons.gesture_rounded,
                      size: 28.0,
                      color: AppColors.textPrimary,
                    ),
                    text: _showTracing ? 'Lihat' : 'Tulis',
                    primaryColor: AppColors.cardSurface,
                    bevelColor: AppColors.cardBevel,
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
                      size: 28.0,
                      color: AppColors.textWhite,
                    ),
                    text: 'Lanjut',
                    primaryColor: AppColors.brandMint,
                    bevelColor: AppColors.brandMintDark,
                    onPressed: _nextLetter,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterOrTracingSection() {
    if (_showTracing) {
      return Center(
        child: TracingCanvas(
          key: _tracingKey,
          letter: _currentLetter.char,
          width: 180.0,
          height: 180.0,
          onStrokeCompleted: () {
            SoundPlayer.instance.playSuccess();
            _praiseTimer?.cancel();
            _praiseTimer = Timer(const Duration(milliseconds: 350), () {
              if (mounted) SoundPlayer.instance.playPraise();
            });
          },
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentLetter.pairDisplay,
          style: AppTypography.learningDisplay(
            fontSize: 92.0,
            color: AppColors.letterPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCueSection() {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Floating 3D Object with soft floor shadow (No enclosing box)
        SizedBox(
          width: 96.0,
          height: 96.0,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Contact floor shadow
              Positioned(
                bottom: 2.0,
                child: Container(
                  width: 64.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              Positioned(
                bottom: 6.0,
                child: fruitAsset != null
                    ? Image.asset(
                        fruitAsset,
                        width: 84.0,
                        height: 84.0,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        _currentLetter.icon,
                        size: 64.0,
                        color: AppColors.letterPrimary,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          _currentLetter.exampleWord,
          style: AppTypography.uiHeading(
            fontSize: 20.0,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
