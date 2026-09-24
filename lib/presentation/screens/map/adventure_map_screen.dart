import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../../data/datasources/mastery_local_datasource.dart';
import '../../../domain/entities/journey_node.dart';
import '../../../domain/services/counting_question_generator.dart';
import '../../../domain/services/journey_catalog.dart';
import '../../../domain/services/word_catalog.dart';
import '../../widgets/buttons/bubble_icon_button.dart';
import '../../widgets/dialogs/parent_gate_dialog.dart';
import '../../widgets/map/map_node_button.dart';
import '../../widgets/map/single_image_map_canvas.dart';
import '../blending/syllable_blending_screen.dart';
import '../counting/counting_screen.dart';
import '../letter/letter_onboarding_screen.dart';
import '../parent/parent_dashboard_screen.dart';

enum AdventureZone {
  numbers,
  letters,
  words,
}

/// Adventure Map Screen (Peta Petualangan Pure DS 2.0)
///
/// Mengusung 1 Jalur Pendakian Terpadu (44 Node) dari dasar lembah hingga puncak salju:
/// - Node 1–10  : Angka dasar (Counting & Tracing)
/// - Node 11–36 : Huruf A–Z (Letter Onboarding & Phonics)
/// - Node 37–44 : Kata dasar (Syllable Blending)
///
/// Dilengkapi Header Minimal Transparan Mengambang:
/// [🔊 Suara] | [⭐ Bintang] | [🔒 Parent Gate]
class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({
    super.key,
    this.initialZone = AdventureZone.numbers,
    this.unlockedIndex = 1,
    this.unlockedNumberIndex = 2,
    this.unlockedLetterIndex = 3,
    this.unlockedWordIndex = 1,
  });

  final AdventureZone initialZone;
  final int unlockedIndex;
  final int unlockedNumberIndex;
  final int unlockedLetterIndex;
  final int unlockedWordIndex;

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  late final ScrollController _scrollController;
  late final List<JourneyNode> _nodes;
  int _unlockedIndex = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _nodes = JourneyCatalog.allNodes;
    _unlockedIndex = widget.unlockedIndex != 1
        ? widget.unlockedIndex
        : (widget.unlockedNumberIndex != 2
            ? widget.unlockedNumberIndex
            : 1);
    _loadPersistedProgress();
    SoundPlayer.instance.playBgmMap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveNode(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    SoundPlayer.instance.stopBgm();
    super.dispose();
  }

  void _scrollToActiveNode({bool animate = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    final size = MediaQuery.of(context).size;
    final activeIndex = (_unlockedIndex - 1).clamp(0, _nodes.length - 1);
    final targetOffset = SingleImageMapCanvas.calculateActiveNodeScrollOffset(
      activeIndex: activeIndex,
      totalNodes: _nodes.length,
      screenWidth: size.width,
      screenHeight: size.height,
      bottomPadding: 0.0,
    );
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  Future<void> _loadPersistedProgress() async {
    try {
      final ds = HiveMasteryLocalDataSource();
      await ds.init();
      final index = await ds.getGlobalUnlockedIndex();
      if (mounted && index > _unlockedIndex) {
        setState(() {
          _unlockedIndex = index.clamp(1, JourneyCatalog.totalNodes);
        });
        _scrollToActiveNode(animate: false);
      }
    } catch (_) {
      // Safe fallback when running in headless tests or uninitialized Hive
    }
  }

  Future<void> _unlockNextNode(JourneyNode completedNode) async {
    if (completedNode.globalIndex == _unlockedIndex) {
      final nextIndex = (_unlockedIndex + 1).clamp(1, JourneyCatalog.totalNodes);
      await HiveMasteryLocalDataSource().setGlobalUnlockedIndex(nextIndex);
      if (mounted) {
        setState(() => _unlockedIndex = nextIndex);
        SoundPlayer.instance.playSuccess();
        _scrollToActiveNode(animate: true);
      }
    } else {
      SoundPlayer.instance.playSuccess();
    }
  }

  void _handleNodeTap(int index) {
    if (index >= _nodes.length) return;
    final node = _nodes[index];
    if (node.globalIndex > _unlockedIndex) {
      SoundPlayer.instance.playSoftRetry();
      return;
    }

    switch (node.type) {
      case NodeType.numbers:
        _openCountingActivity(node);
      case NodeType.letters:
        _openLetterActivity(node);
      case NodeType.words:
        _openWordActivity(node);
    }
  }

  void _openCountingActivity(JourneyNode node) {
    SoundPlayer.instance.stopBgm();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CountingScreen(
          totalSteps: 5,
          targetNumber: node.typeIndex,
          generator: CountingQuestionGenerator(
            fixedTargetCount: node.typeIndex,
          ),
          onCompleted: () {
            Navigator.of(context).pop();
            _unlockNextNode(node);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    ).then((_) {
      if (mounted) {
        SoundPlayer.instance.playBgmMap();
      }
    });
  }

  void _openLetterActivity(JourneyNode node) {
    SoundPlayer.instance.stopBgm();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LetterOnboardingScreen(
          letterIndex: node.typeIndex,
          onCompleted: () {
            Navigator.of(context).pop();
            _unlockNextNode(node);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    ).then((_) {
      if (mounted) {
        SoundPlayer.instance.playBgmMap();
      }
    });
  }

  void _openWordActivity(JourneyNode node) {
    SoundPlayer.instance.stopBgm();
    final words = WordCatalog.defaultWords;
    final wordList = (node.typeIndex >= 0 && node.typeIndex < words.length)
        ? [words[node.typeIndex]]
        : [words.first];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (exerciseContext) => SyllableBlendingScreen(
          words: wordList,
          onCompleted: () {
            Navigator.of(exerciseContext).pop();
            _unlockNextNode(node);
          },
          onBack: () => Navigator.of(exerciseContext).pop(),
        ),
      ),
    ).then((_) {
      if (mounted) {
        SoundPlayer.instance.playBgmMap();
      }
    });
  }

  List<MapCanvasNodeData> _getMapNodes() {
    return _nodes.map((node) {
      final status = node.globalIndex < _unlockedIndex
          ? MapNodeStatus.completed
          : node.globalIndex == _unlockedIndex
              ? MapNodeStatus.active
              : MapNodeStatus.locked;
      return MapCanvasNodeData(
        id: node.globalIndex,
        label: node.label,
        status: status,
        primaryColor: node.primaryColor,
        bevelColor: node.bevelColor,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = (_unlockedIndex - 1).clamp(0, JourneyCatalog.totalNodes);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // 1. Kanvas Peta Single Image Edge-to-Edge (top: 0)
            Positioned.fill(
              child: SingleImageMapCanvas(
                nodes: _getMapNodes(),
                onNodeTap: _handleNodeTap,
                scrollController: _scrollController,
                activeSize: 44.0,
                normalSize: 36.0,
                bottomPadding: 0.0,
              ),
            ),

            // 2. Floating Header Minimal DS 2.0 (Sound | StarChip | ParentGate)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _MapHeader(
                  starCount: completedCount,
                  isMuted: SoundPlayer.instance.isMuted,
                  onSoundTap: () => setState(() => SoundPlayer.instance.toggleMute()),
                  onParentTap: () async {
                    final ok = await ParentGateDialog.show(context);
                    if (ok == true && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header minimal mengambang murni DS 2.0:
/// [🔊 Sound toggle] | [⭐ Star Chip] | [🔒 Parent gate]
class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.starCount,
    required this.isMuted,
    required this.onSoundTap,
    required this.onParentTap,
  });

  final int starCount;
  final bool isMuted;
  final VoidCallback onSoundTap;
  final VoidCallback onParentTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔊 Sound toggle (3D Clay)
          BubbleIconButton.sound(
            isMuted: isMuted,
            onPressed: onSoundTap,
          ),

          // ⭐ Bintang (tengah)
          _StarChip(count: starCount),

          // 🔒 Parent gate (3D Clay)
          BubbleIconButton.parents(
            onPressed: onParentTap,
          ),
        ],
      ),
    );
  }
}

/// Chip bintang — menampilkan jumlah pencapaian bintang emas anak
class _StarChip extends StatelessWidget {
  const _StarChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.retryBevel.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: AppColors.retryBevel.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.icStar,
            width: 22.0,
            height: 22.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 6.0),
          Text(
            '$count',
            style: AppTypography.uiButton(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
