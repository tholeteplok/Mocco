import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
import '../../widgets/map/looping_map_canvas.dart';
import '../../widgets/map/map_node_button.dart';
import '../blending/syllable_blending_screen.dart';
import '../counting/counting_screen.dart';
import '../letter/letter_onboarding_screen.dart';
import '../node/node_detail_screen.dart';
import '../parent/parent_dashboard_screen.dart';

/// Layar utama Mocco — Peta Perjalanan Linear.
///
/// Menggantikan MoccoShell + HomeScreen + AdventureMapScreen.
/// Tidak ada bottom nav, tidak ada pilihan zona, tidak ada menu.
///
/// Anak hanya melihat satu jalur winding path dengan node yang harus
/// diselesaikan satu per satu. Node berikutnya terbuka otomatis setelah
/// node sebelumnya selesai.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // ── State ──────────────────────────────────────────────────────────
  int _unlockedIndex = 1; // 1-based: node dengan globalIndex ini yang active
  bool _isLoading = true;

  // ── Scroll & Keys ──────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _nodeKeys = {};

  // ── Data Source ────────────────────────────────────────────────────
  late final HiveMasteryLocalDataSource _dataSource;

  // ── Nodes (dibuild sekali) ─────────────────────────────────────────
  late final List<JourneyNode> _nodes;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _dataSource = HiveMasteryLocalDataSource();
    _nodes = JourneyCatalog.allNodes;

    // Siapkan GlobalKey untuk setiap node agar bisa auto-scroll
    for (final node in _nodes) {
      _nodeKeys[node.globalIndex] = GlobalKey();
    }

    _loadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Data Methods ───────────────────────────────────────────────────

  Future<void> _loadProgress() async {
    await _dataSource.init();
    final index = await _dataSource.getGlobalUnlockedIndex();
    if (mounted) {
      setState(() {
        _unlockedIndex = index;
        _isLoading = false;
      });
      _scrollToActiveNode();
    }
  }

  Future<void> _unlockNextNode([JourneyNode? completedNode]) async {
    if (completedNode == null || completedNode.globalIndex == _unlockedIndex) {
      final nextIndex = (_unlockedIndex + 1).clamp(1, JourneyCatalog.totalNodes);
      await _dataSource.setGlobalUnlockedIndex(nextIndex);
      if (mounted) {
        setState(() => _unlockedIndex = nextIndex);
        SoundPlayer.instance.playSuccess();
        _scrollToActiveNode();
      }
    } else {
      // Replay node yang sudah pernah selesai: putar audio sukses tanpa mengubah progres
      SoundPlayer.instance.playSuccess();
    }
  }

  /// Auto-scroll ke node aktif dengan animasi halus.
  void _scrollToActiveNode() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final key = _nodeKeys[_unlockedIndex];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.4, // 40% dari atas layar
        );
      }
    });
  }

  // ── Activity Launchers ─────────────────────────────────────────────

  void _launchActivity(JourneyNode node) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NodeDetailScreen(
          node: node,
          onStartActivity: () {
            Navigator.of(context).pop();
            _startNodeExercise(node);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _startNodeExercise(JourneyNode node) {
    switch (node.type) {
      case NodeType.numbers:
        _launchCounting(node);
      case NodeType.letters:
        _launchLetter(node);
      case NodeType.words:
        _launchBlending(node);
    }
  }

  void _launchCounting(JourneyNode node) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountingScreen(
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
    );
  }

  void _launchLetter(JourneyNode node) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LetterOnboardingScreen(
          letterIndex: node.typeIndex,
          onCompleted: () {
            Navigator.of(context).pop();
            _unlockNextNode(node);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _launchBlending(JourneyNode node) {
    final words = WordCatalog.defaultWords;
    // Sajikan hanya kata yang sesuai dengan node ini
    final wordList = (node.typeIndex >= 0 && node.typeIndex < words.length)
        ? [words[node.typeIndex]]
        : [words.first];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyllableBlendingScreen(
          words: wordList,
          onCompleted: () {
            Navigator.of(context).pop();
            _unlockNextNode(node);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // ── Parent Gate ────────────────────────────────────────────────────

  Future<void> _openParentArea() async {
    final ok = await ParentGateDialog.show(context);
    if (ok == true && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final completedCount = (_unlockedIndex - 1).clamp(0, JourneyCatalog.totalNodes);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          // ── 1. Full-Screen Looping Map Canvas (Tanpa Kartu, Seamless Loop) ──
          Positioned.fill(
            child: LoopingMapCanvas(
              nodes: _nodes.map((node) {
                final status = nodeStatus(node.globalIndex, _unlockedIndex);
                final mapStatus = _toMapNodeStatus(status);
                return MapCanvasNodeData(
                  id: node.globalIndex,
                  label: node.label,
                  status: mapStatus,
                  primaryColor: node.primaryColor,
                  bevelColor: node.bevelColor,
                  nodeKey: _nodeKeys[node.globalIndex],
                );
              }).toList(),
              scrollController: _scrollController,
              activeSize: 64.0,
              normalSize: 56.0,
              topPadding: 92.0,
              bottomPadding: 64.0,
              onNodeTap: (index) {
                final node = _nodes[index];
                _launchActivity(node);
              },
            ),
          ),

          // ── 2. Floating Header Minimal (SafeArea, Tanpa Kartu Pembatas) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _JourneyHeader(
                starCount: completedCount,
                onSoundTap: () => setState(() => SoundPlayer.instance.toggleMute()),
                isMuted: SoundPlayer.instance.isMuted,
                onParentTap: _openParentArea,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static MapNodeStatus _toMapNodeStatus(JourneyNodeStatus status) {
    return switch (status) {
      JourneyNodeStatus.completed => MapNodeStatus.completed,
      JourneyNodeStatus.active => MapNodeStatus.active,
      JourneyNodeStatus.locked => MapNodeStatus.locked,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-widgets (tersentralisasi dalam file ini — tidak diekspor)
// ═══════════════════════════════════════════════════════════════════════════════

/// Header minimal mengambang: sound toggle | bintang | parent gate.
class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({
    required this.starCount,
    required this.onSoundTap,
    required this.isMuted,
    required this.onParentTap,
  });

  final int starCount;
  final VoidCallback onSoundTap;
  final bool isMuted;
  final VoidCallback onParentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          // 🔊 Sound toggle
          BubbleIconButton(
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            borderColor: AppColors.numberPrimary,
            bevelColor: AppColors.numberBevel,
            onPressed: onSoundTap,
          ),

          // ⭐ Bintang (tengah, expanded)
          Expanded(
            child: Center(
              child: _StarChip(count: starCount),
            ),
          ),

          // 🔒 Parent gate
          BubbleIconButton(
            icon: Icons.lock_rounded,
            borderColor: AppColors.numberPrimary,
            bevelColor: AppColors.numberBevel,
            onPressed: onParentTap,
          ),
        ],
      ),
    );
  }
}

/// Chip bintang — menampilkan jumlah node yang telah diselesaikan.
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
          const Icon(Icons.star_rounded, size: 20.0, color: AppColors.retryBevel),
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
