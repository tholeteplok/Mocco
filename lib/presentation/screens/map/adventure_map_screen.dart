import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../widgets/buttons/bubble_icon_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/dialogs/parent_gate_dialog.dart';
import '../../widgets/headers/responsive_scaffold.dart';
import '../../widgets/map/map_node_button.dart';
import '../../../domain/services/word_catalog.dart';
import '../blending/syllable_blending_screen.dart';
import '../counting/counting_screen.dart';
import '../letter/letter_onboarding_screen.dart';

enum AdventureZone {
  numbers,
  letters,
  words,
}

/// Adventure Map Screen (Peta Petualangan Board Game)
/// Spec v1.4 §5, V21
class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({
    super.key,
    this.initialZone = AdventureZone.numbers,
    this.unlockedNumberIndex = 2,
    this.unlockedLetterIndex = 3,
    this.unlockedWordIndex = 1,
  });

  final AdventureZone initialZone;
  final int unlockedNumberIndex;
  final int unlockedLetterIndex;
  final int unlockedWordIndex;

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  late AdventureZone _currentZone;
  late int _unlockedNumber;
  late int _unlockedLetter;
  late int _unlockedWord;

  @override
  void initState() {
    super.initState();
    _currentZone = widget.initialZone;
    _unlockedNumber = widget.unlockedNumberIndex;
    _unlockedLetter = widget.unlockedLetterIndex;
    _unlockedWord = widget.unlockedWordIndex;
  }

  void _openCountingActivity(int number) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CountingScreen(
          totalSteps: 5,
          onCompleted: () {
            setState(() {
              if (number >= _unlockedNumber && _unlockedNumber < 10) {
                _unlockedNumber = number + 1;
              }
            });
            Navigator.of(context).pop();
            SoundPlayer.instance.playSuccess();
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openLetterActivity(int letterIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LetterOnboardingScreen(
          letterIndex: letterIndex,
          onCompleted: () {
            setState(() {
              if (letterIndex >= _unlockedLetter - 1 && _unlockedLetter < 26) {
                _unlockedLetter = letterIndex + 2;
              }
            });
            Navigator.of(context).pop();
            SoundPlayer.instance.playSuccess();
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openWordActivity(int wordIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SyllableBlendingScreen(
          words: WordCatalog.defaultWords,
          onCompleted: () {
            setState(() {
              if (wordIndex >= _unlockedWord && _unlockedWord < WordCatalog.defaultWords.length) {
                _unlockedWord = wordIndex + 1;
              }
            });
            Navigator.of(context).pop();
            SoundPlayer.instance.playSuccess();
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNumbers = _currentZone == AdventureZone.numbers;
    final isWords = _currentZone == AdventureZone.words;
    final primaryColor = isNumbers
        ? AppColors.numberPrimary
        : isWords
            ? AppColors.blendingPrimary
            : AppColors.letterPrimary;
    final tintColor = isNumbers
        ? AppColors.numberTint
        : isWords
            ? AppColors.blendingTint
            : AppColors.letterTint;
    final bevelColor = isNumbers
        ? AppColors.numberBevel
        : isWords
            ? AppColors.blendingBevel
            : AppColors.letterBevel;

    return ResponsiveScaffold(
      body: Column(
        children: [
          // Top Navigation Bar (Zone Toggle, Audio, and Parent Gate)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Parent Gate (Hold 3s)
                BubbleIconButton(
                  icon: Icons.lock_rounded,
                  borderColor: primaryColor,
                  bevelColor: bevelColor,
                  onPressed: () {
                    ParentGateDialog.show(context);
                  },
                ),

                // Zone Selector (Numbers vs Letters vs Words, Icon-First)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChunkyButton(
                      icon: const Icon(Icons.pin_rounded, size: 28.0),
                      height: 52.0,
                      width: 58.0,
                      primaryColor: isNumbers ? AppColors.numberPrimary : AppColors.numberTint,
                      bevelColor: AppColors.numberBevel,
                      onPressed: () {
                        setState(() => _currentZone = AdventureZone.numbers);
                        SoundPlayer.instance.playPop();
                      },
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    ChunkyButton(
                      icon: const Icon(Icons.sort_by_alpha_rounded, size: 28.0),
                      height: 52.0,
                      width: 58.0,
                      primaryColor: (!isNumbers && !isWords) ? AppColors.letterPrimary : AppColors.letterTint,
                      bevelColor: AppColors.letterBevel,
                      onPressed: () {
                        setState(() => _currentZone = AdventureZone.letters);
                        SoundPlayer.instance.playPop();
                      },
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    ChunkyButton(
                      icon: const Icon(Icons.auto_stories_rounded, size: 28.0),
                      height: 52.0,
                      width: 58.0,
                      primaryColor: isWords ? AppColors.blendingPrimary : AppColors.blendingTint,
                      bevelColor: AppColors.blendingBevel,
                      onPressed: () {
                        setState(() => _currentZone = AdventureZone.words);
                        SoundPlayer.instance.playPop();
                      },
                    ),
                  ],
                ),

                // Audio Mute Toggle
                BubbleIconButton(
                  icon: SoundPlayer.instance.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  borderColor: primaryColor,
                  bevelColor: bevelColor,
                  onPressed: () {
                    setState(() => SoundPlayer.instance.toggleMute());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          // Board Game Path (Winding list of 3D node buttons)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tintColor.withValues(alpha: 0.6),
                    tintColor.withValues(alpha: 0.25),
                  ],
                ),
                borderRadius: AppSpacing.roundedLarge,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.6),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bevelColor.withValues(alpha: 0.4),
                    offset: const Offset(0, 6.0),
                    blurRadius: 0.0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space24,
                  horizontal: AppSpacing.space16,
                ),
                child: isNumbers
                    ? _buildNumbersPath()
                    : isWords
                        ? _buildWordsPath()
                        : _buildLettersPath(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersPath() {
    return Column(
      children: [
        for (int i = 1; i <= 10; i++) ...[
          _buildNodeRow(
            index: i,
            label: '$i',
            status: i < _unlockedNumber
                ? MapNodeStatus.completed
                : i == _unlockedNumber
                    ? MapNodeStatus.active
                    : MapNodeStatus.locked,
            onTap: () => _openCountingActivity(i),
            primaryColor: AppColors.numberPrimary,
            bevelColor: AppColors.numberBevel,
          ),
          if (i < 10) _buildPathConnector(AppColors.numberPrimary),
        ],
      ],
    );
  }

  Widget _buildLettersPath() {
    final letters = LetterEntity.alphabet;

    return Column(
      children: [
        for (int i = 0; i < letters.length; i++) ...[
          _buildNodeRow(
            index: i + 1,
            label: letters[i].pairDisplay,
            status: (i + 1) < _unlockedLetter
                ? MapNodeStatus.completed
                : (i + 1) == _unlockedLetter
                    ? MapNodeStatus.active
                    : MapNodeStatus.locked,
            onTap: () => _openLetterActivity(i),
            primaryColor: AppColors.letterPrimary,
            bevelColor: AppColors.letterBevel,
          ),
          if (i < letters.length - 1) _buildPathConnector(AppColors.letterPrimary),
        ],
      ],
    );
  }

  Widget _buildWordsPath() {
    final words = WordCatalog.defaultWords;

    return Column(
      children: [
        for (int i = 0; i < words.length; i++) ...[
          _buildNodeRow(
            index: i + 1,
            label: words[i].hyphenated,
            status: (i + 1) < _unlockedWord
                ? MapNodeStatus.completed
                : (i + 1) == _unlockedWord
                    ? MapNodeStatus.active
                    : MapNodeStatus.locked,
            onTap: () => _openWordActivity(i + 1),
            primaryColor: AppColors.blendingPrimary,
            bevelColor: AppColors.blendingBevel,
          ),
          if (i < words.length - 1) _buildPathConnector(AppColors.blendingPrimary),
        ],
      ],
    );
  }

  Widget _buildNodeRow({
    required int index,
    required String label,
    required MapNodeStatus status,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color bevelColor,
  }) {
    // Alternating horizontal alignment (left, center, right) to simulate winding physical board game
    final alignment = (index % 3 == 1)
        ? Alignment.centerLeft
        : (index % 3 == 2)
            ? Alignment.center
            : Alignment.centerRight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
      child: Align(
        alignment: alignment,
        child: MapNodeButton(
          label: label,
          status: status,
          onTap: onTap,
          primaryColor: primaryColor,
          bevelColor: bevelColor,
        ),
      ),
    );
  }

  Widget _buildPathConnector(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPebble(10.0),
          const SizedBox(height: 4.0),
          _buildPebble(13.0),
          const SizedBox(height: 4.0),
          _buildPebble(10.0),
        ],
      ),
    );
  }

  Widget _buildPebble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8DECF),
        border: Border.all(color: const Color(0xFFC7BBAA), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB3A694),
            offset: Offset(0, 2.0),
            blurRadius: 0.0,
          ),
        ],
      ),
    );
  }
}
