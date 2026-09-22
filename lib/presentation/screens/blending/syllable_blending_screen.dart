import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/word_entity.dart';
import '../../../domain/services/word_catalog.dart';
import '../../widgets/blending/syllable_card.dart';
import '../../widgets/blending/word_slot.dart';
import '../../widgets/buttons/audio_prompt_button.dart';
import '../../widgets/buttons/bubble_icon_button.dart';
import '../../widgets/feedback/celebration_banner.dart';
import '../../widgets/headers/jelly_progress_bar.dart';
import '../../widgets/headers/responsive_scaffold.dart';

/// Syllable Blending & Word Assembly Screen (Spec §1.4, Design System V12, V18)
/// Designed exclusively for pre-readers: 100% icon-driven, auditory prompts,
/// tactile 2.5D physical cards, and magnetic inward-sliding syllable merge.
class SyllableBlendingScreen extends StatefulWidget {
  const SyllableBlendingScreen({
    super.key,
    this.words,
    this.onCompleted,
    this.onBack,
  });

  final List<WordEntity>? words;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<SyllableBlendingScreen> createState() => _SyllableBlendingScreenState();
}

class _SyllableBlendingScreenState extends State<SyllableBlendingScreen>
    with SingleTickerProviderStateMixin {
  late final List<WordEntity> _words;
  int _currentIndex = 0;

  String? _slot1;
  String? _slot2;
  late List<String> _options;

  bool _isSuccess = false;
  bool _isLockInput = false;

  late final AnimationController _blendAnimController;
  late final Animation<double> _slideAnimation;
  final List<Timer> _activeTimers = [];

  WordEntity get _currentWord => _words[_currentIndex];

  @override
  void initState() {
    super.initState();
    _words = widget.words ?? WordCatalog.defaultWords;
    _setupCurrentWord();

    _blendAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: AppSpacing.space16, end: 2.0).animate(
      CurvedAnimation(parent: _blendAnimController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _blendAnimController.dispose();
    super.dispose();
  }

  void _setupCurrentWord() {
    _slot1 = null;
    _slot2 = null;
    _isSuccess = false;
    _isLockInput = false;
    _options = WordCatalog.generateSyllableOptions(_currentWord);
  }

  void _playWordAudio() {
    SoundPlayer.instance.playWord(_currentWord.word);
  }

  void _handleSyllableTapped(String syllable) {
    if (_isLockInput || _isSuccess) return;

    SoundPlayer.instance.playSyllable(syllable);

    setState(() {
      if (_slot1 == null) {
        _slot1 = syllable;
      } else {
        _slot2 ??= syllable;
      }
    });

    // Check when both slots are filled
    if (_slot1 != null && _slot2 != null) {
      _verifyAnswer();
    }
  }

  void _advanceToNext() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _setupCurrentWord();
      });
      _blendAnimController.reset();
    } else {
      widget.onCompleted?.call();
    }
  }

  void _verifyAnswer() {
    if (_slot1 == _currentWord.syllable1 && _slot2 == _currentWord.syllable2) {
      // Correct! Child keeps full control — no auto-advance.
      setState(() {
        _isSuccess = true;
        _isLockInput = true;
      });

      _blendAnimController.forward();
      SoundPlayer.instance.playSuccess();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playWord(_currentWord.word);
      }));
      _activeTimers.add(Timer(const Duration(milliseconds: 800), () {
        if (mounted) SoundPlayer.instance.playPraise();
      }));
    } else {
      // Incorrect: gentle retry sound & soft bounce back
      SoundPlayer.instance.playSoftRetry();
      _activeTimers.add(Timer(const Duration(milliseconds: 300), () {
        if (mounted) SoundPlayer.instance.playEncouragement();
      }));
      _isLockInput = true;

      _activeTimers.add(Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _slot1 = null;
          _slot2 = null;
          _isLockInput = false;
        });
      }));
    }
  }

  void _removeSlot(int slotIndex) {
    if (_isLockInput || _isSuccess) return;
    SoundPlayer.instance.playPop();
    setState(() {
      if (slotIndex == 1) {
        _slot1 = null;
      } else {
        _slot2 = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: Column(
        children: [
          // Top Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BubbleIconButton(
                  icon: Icons.arrow_back_rounded,
                  borderColor: AppColors.blendingPrimary,
                  bevelColor: AppColors.blendingBevel,
                  onPressed: () {
                    SoundPlayer.instance.playPop();
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
                SizedBox(
                  width: ResponsiveHelper.value(context, mobile: 160.0, tablet: 260.0),
                  child: JellyProgressBar(
                    currentStep: _currentIndex + 1,
                    totalSteps: _words.length,
                    filledColor: AppColors.blendingPrimary,
                    unfilledColor: AppColors.blendingTint,
                  ),
                ),
                AudioPromptButton(
                  onPressed: _playWordAudio,
                  primaryColor: AppColors.blendingPrimary,
                  bevelColor: AppColors.blendingBevel,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Target Object Showcase (Visual Picture Card - 3D Clay Aesthetic)
          GestureDetector(
            onTap: () {
              SoundPlayer.instance.playPop();
              _playWordAudio();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: ResponsiveHelper.value(context, mobile: 140.0, tablet: 180.0),
              height: ResponsiveHelper.value(context, mobile: 140.0, tablet: 180.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(
                  color: AppColors.blendingPrimary,
                  width: 3.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blendingBevel,
                    offset: Offset(0, 6.0),
                    blurRadius: 0.0,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: ResponsiveHelper.value(context, mobile: 104.0, tablet: 136.0),
                  height: ResponsiveHelper.value(context, mobile: 104.0, tablet: 136.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blendingTint,
                    border: Border.all(
                      color: AppColors.blendingPrimary.withValues(alpha: 0.4),
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _currentWord.icon,
                      size: ResponsiveHelper.value(context, mobile: 64.0, tablet: 84.0),
                      color: AppColors.blendingBevel,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space24),

          // Word Assembly Slots (with animated merge/slide)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordSlot(
                    syllable: _slot1,
                    onTapRemove: () => _removeSlot(1),
                  ),
                  SizedBox(width: _slideAnimation.value),
                  WordSlot(
                    syllable: _slot2,
                    onTapRemove: () => _removeSlot(2),
                  ),
                ],
              );
            },
          ),

          // Success celebration (consistent dopamine loop with other screens)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSuccess
                ? CelebrationBanner(
                    key: const ValueKey('blending-celebration'),
                    title: 'Hebat Sekali!',
                    subtitle: 'Kata "${_currentWord.word}" berhasil dirangkai!',
                    onNextPressed: _advanceToNext,
                  )
                : const SizedBox(
                    key: ValueKey('blending-spacer'),
                    height: 12.0,
                  ),
          ),

          const Spacer(),

          // Syllable Selection Choices — symmetrical 1x4 anti-orphan row
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space16),
            child: Row(
              children: _options.map((syl) {
                // Determine if this specific option chip is currently placed in a slot
                final isUsed = (_slot1 == syl) || (_slot2 == syl && _slot1 != syl);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SyllableCard(
                      syllable: syl,
                      isUsed: isUsed,
                      onTap: () => _handleSyllableTapped(syl),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
