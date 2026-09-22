import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../widgets/buttons/bubble_icon_button.dart';
import '../../widgets/buttons/chunky_button.dart';
import '../../widgets/dialogs/parent_gate_dialog.dart';
import '../../widgets/map/looping_map_canvas.dart';
import '../../widgets/map/map_node_button.dart';
import '../../../domain/services/counting_question_generator.dart';
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
          targetNumber: number,
          generator: CountingQuestionGenerator(
            fixedTargetCount: number,
          ),
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

  List<MapCanvasNodeData> _getZoneNodes(AdventureZone zone) {
    switch (zone) {
      case AdventureZone.numbers:
        return List.generate(10, (i) {
          final number = i + 1;
          final status = number < _unlockedNumber
              ? MapNodeStatus.completed
              : number == _unlockedNumber
                  ? MapNodeStatus.active
                  : MapNodeStatus.locked;
          return MapCanvasNodeData(
            id: number,
            label: '$number',
            status: status,
            primaryColor: AppColors.numberPrimary,
            bevelColor: AppColors.numberBevel,
          );
        });

      case AdventureZone.letters:
        final letters = LetterEntity.alphabet;
        return List.generate(letters.length, (i) {
          final status = (i + 1) < _unlockedLetter
              ? MapNodeStatus.completed
              : (i + 1) == _unlockedLetter
                  ? MapNodeStatus.active
                  : MapNodeStatus.locked;
          return MapCanvasNodeData(
            id: i,
            label: letters[i].pairDisplay,
            status: status,
            primaryColor: AppColors.letterPrimary,
            bevelColor: AppColors.letterBevel,
          );
        });

      case AdventureZone.words:
        final words = WordCatalog.defaultWords;
        return List.generate(words.length, (i) {
          final status = (i + 1) < _unlockedWord
              ? MapNodeStatus.completed
              : (i + 1) == _unlockedWord
                  ? MapNodeStatus.active
                  : MapNodeStatus.locked;
          return MapCanvasNodeData(
            id: i,
            label: words[i].hyphenated,
            status: status,
            primaryColor: AppColors.blendingPrimary,
            bevelColor: AppColors.blendingBevel,
          );
        });
    }
  }

  void _handleNodeTap(int index) {
    switch (_currentZone) {
      case AdventureZone.numbers:
        _openCountingActivity(index + 1);
        break;
      case AdventureZone.letters:
        _openLetterActivity(index);
        break;
      case AdventureZone.words:
        _openWordActivity(index + 1);
        break;
    }
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
    final bevelColor = isNumbers
        ? AppColors.numberBevel
        : isWords
            ? AppColors.blendingBevel
            : AppColors.letterBevel;

    final stars = (_unlockedNumber - 1).clamp(0, 10) +
        (_unlockedLetter - 1).clamp(0, 26) +
        (_unlockedWord - 1).clamp(0, 8);
    final zoneLabel = isNumbers
        ? 'Zona Angka'
        : isWords
            ? 'Zona Kata'
            : 'Zona Huruf';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          // 1. Kanvas Peta Berkelanjutan Full-Screen (Tanpa Kartu Pembatas)
          Positioned.fill(
            child: LoopingMapCanvas(
              nodes: _getZoneNodes(_currentZone),
              onNodeTap: _handleNodeTap,
              topPadding: 140.0,
              bottomPadding: 80.0,
              activeSize: 64.0,
              normalSize: 56.0,
            ),
          ),

          // 2. Floating Header Area (Zone Toggle & Stats)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Navigation Bar (Zone Toggle, Audio, and Parent Gate)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Parent Gate
                        BubbleIconButton(
                          icon: Icons.lock_rounded,
                          borderColor: primaryColor,
                          bevelColor: bevelColor,
                          onPressed: () {
                            ParentGateDialog.show(context);
                          },
                        ),

                        // Zone Selector (Numbers vs Letters vs Words, Icon + Label)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildZoneButton(
                              icon: Icons.pin_rounded,
                              label: 'Angka',
                              isActive: isNumbers,
                              activeColor: AppColors.numberPrimary,
                              tintColor: AppColors.numberTint,
                              bevel: AppColors.numberBevel,
                              onTap: () {
                                setState(() => _currentZone = AdventureZone.numbers);
                                SoundPlayer.instance.playPop();
                              },
                            ),
                            const SizedBox(width: AppSpacing.space8),
                            _buildZoneButton(
                              icon: Icons.sort_by_alpha_rounded,
                              label: 'Huruf',
                              isActive: (!isNumbers && !isWords),
                              activeColor: AppColors.letterPrimary,
                              tintColor: AppColors.letterTint,
                              bevel: AppColors.letterBevel,
                              onTap: () {
                                setState(() => _currentZone = AdventureZone.letters);
                                SoundPlayer.instance.playPop();
                              },
                            ),
                            const SizedBox(width: AppSpacing.space8),
                            _buildZoneButton(
                              icon: Icons.auto_stories_rounded,
                              label: 'Kata',
                              isActive: isWords,
                              activeColor: AppColors.blendingPrimary,
                              tintColor: AppColors.blendingTint,
                              bevel: AppColors.blendingBevel,
                              onTap: () {
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

                    const SizedBox(height: AppSpacing.space8),

                    // Greeting + progress chips (Floating Banner)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space16,
                        vertical: AppSpacing.space8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface.withValues(alpha: 0.94),
                        borderRadius: AppSpacing.roundedLarge,
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardBevel,
                            offset: Offset(0, 3.0),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Halo, Petualang!',
                                  style: AppTypography.uiHeading(fontSize: 16.0),
                                ),
                                Text(
                                  zoneLabel,
                                  style: AppTypography.uiBody(
                                    fontSize: 12.0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatChip(
                            icon: Icons.star_rounded,
                            value: '$stars',
                            chipColor: AppColors.retryBevel,
                          ),
                          const SizedBox(width: AppSpacing.space8),
                          _buildStatChip(
                            icon: Icons.emoji_events_rounded,
                            value: isNumbers
                                ? '${_unlockedNumber - 1}/10'
                                : isWords
                                    ? '${_unlockedWord - 1}/8'
                                    : '${_unlockedLetter - 1}/26',
                            chipColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color tintColor,
    required Color bevel,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChunkyButton(
          icon: Icon(
            icon,
            size: 24.0,
            color: isActive ? AppColors.textWhite : AppColors.textPrimary,
          ),
          height: 52.0,
          width: 64.0,
          primaryColor: isActive ? activeColor : tintColor,
          bevelColor: bevel,
          onPressed: onTap,
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: AppTypography.uiBody(
            fontSize: 11.0,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color chipColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: chipColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: chipColor),
          const SizedBox(width: 4.0),
          Text(
            value,
            style: AppTypography.uiButton(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
