import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../mascot/mascot_widget.dart';
import 'map_node_button.dart';

/// Model data generik untuk satu titik node pada SingleImageMapCanvas.
class MapCanvasNodeData {
  const MapCanvasNodeData({
    required this.id,
    required this.label,
    required this.status,
    this.primaryColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.nodeKey,
  });

  final int id;
  final String label;
  final MapNodeStatus status;
  final Color primaryColor;
  final Color bevelColor;
  final GlobalKey? nodeKey;
}

/// Single Image World Map Canvas for Mocco Adventure Map (896x4800 px)
/// Replaces tile-based LoopingMapCanvas with a rich narrative vertical ascent (Bottom to Top).
///
/// Features:
/// - Single seamless hand-crafted clay diorama map (AppAssets.worldMapSingle).
/// - 40 precision waypoints along the yellow road centerline.
/// - Bottom-to-Top progression: Level 1 starts at valley base, Level N reaches snow peak.
/// - Ergonomic node sizes: 44dp regular, 52dp active, with 60dp touch target.
/// - Adaptive mascot placement standing happily next to the active node.
class SingleImageMapCanvas extends StatelessWidget {
  const SingleImageMapCanvas({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.scrollController,
    this.activeSize = 44.0,
    this.normalSize = 36.0,
    this.touchTargetSize = 48.0,
    this.topPadding = 0.0,
    this.bottomPadding = 0.0,
  });

  final List<MapCanvasNodeData> nodes;
  final ValueChanged<int> onNodeTap;
  final ScrollController? scrollController;
  final double activeSize;
  final double normalSize;
  final double touchTargetSize;
  final double topPadding;
  final double bottomPadding;

  // Aspek rasio gambar asli 896 × 4800 (H / W = 5.35714)
  static const double aspectRatio = 4800.0 / 896.0;

  /// 44 Titik Koordinat Proporsional (X / 896.0, Y / 4800.0)
  /// Terverifikasi 100% tepat di tengah jalan aspal dan jembatan
  static const List<Offset> calibrated44NodePositions = [
    // ── ZONA ANGKA: Node 1-10 (Lembah & Kebun) ──
    Offset(725.2 / 896.0, 4629.0 / 4800.0), // 1: Jalan masuk kanan bawah
    Offset(579.2 / 896.0, 4502.7 / 4800.0), // 2: Jembatan pelangi kayu bawah
    Offset(117.0 / 896.0, 4566.7 / 4800.0), // 3: Melingkari rumah ungu kiri
    Offset(350.0 / 896.0, 4130.0 / 4800.0), // 4: Jembatan pelangi kayu kebun wortel
    Offset(756.1 / 896.0, 4121.5 / 4800.0), // 5: Sisi kanan kebun wortel
    Offset(146.5 / 896.0, 3844.8 / 4800.0), // 6: Melingkari lumbung kuning kiri
    Offset(490.0 / 896.0, 3650.0 / 4800.0), // 7: Jembatan kayu tengah
    Offset(751.1 / 896.0, 3644.0 / 4800.0), // 8: Depan rumah jamur kanan
    Offset(622.8 / 896.0, 3524.4 / 4800.0), // 9: Lengkung kanan atas
    Offset(661.8 / 896.0, 3305.3 / 4800.0), // 10: Tepi kanan bawah jembatan pelangi

    // ── ZONA HURUF: Node 11-36 (Aa - Zz) ──
    Offset(701.6 / 896.0, 3135.2 / 4800.0), // 11 (Aa): Jalan kanan naik menuju jembatan pelangi
    Offset(497.0 / 896.0, 3066.8 / 4800.0), // 12 (Bb): Jembatan pelangi tengah (Kanan -> Kiri)
    Offset(249.5 / 896.0, 3054.1 / 4800.0), // 13 (Cc): Jalan kiri setelah jembatan pelangi
    Offset(203.2 / 896.0, 2893.4 / 4800.0), // 14 (Dd): Jalan kiri menyusuri tebing gunung
    Offset(314.4 / 896.0, 2761.5 / 4800.0), // 15 (Ee): Jalan kiri melewati pohon apel
    Offset(431.7 / 896.0, 2644.1 / 4800.0), // 16 (Ff): Jalan kiri sebelum jembatan kayu
    Offset(513.4 / 896.0, 2578.2 / 4800.0), // 17 (Gg): Jembatan kayu tengah (Kiri -> Kanan)
    Offset(646.8 / 896.0, 2508.1 / 4800.0), // 18 (Hh): Jalan kanan setelah jembatan
    Offset(731.2 / 896.0, 2376.2 / 4800.0), // 19 (Ii): Jalan kanan menanjak (depan kebun)
    Offset(687.5 / 896.0, 2236.8 / 4800.0), // 20 (Jj): Depan rumah pink kanan
    Offset(512.2 / 896.0, 2143.0 / 4800.0), // 21 (Kk): Jembatan pelangi kiwi (Kanan -> Kiri)
    Offset(323.9 / 896.0, 2128.0 / 4800.0), // 22 (Ll): Jalan kiri depan rumah ungu
    Offset(178.8 / 896.0, 2042.1 / 4800.0), // 23 (Mm): Jalan kiri melengkung
    Offset(200.6 / 896.0, 1903.1 / 4800.0), // 24 (Nn): Jalan kiri menanjak lereng kiwi
    Offset(342.7 / 896.0, 1813.9 / 4800.0), // 25 (Oo): Jalan lereng mendaki bukit
    Offset(448.2 / 896.0, 1710.9 / 4800.0), // 26 (Pp): Tangga lereng menuju jembatan batu
    Offset(617.4 / 896.0, 1614.3 / 4800.0), // 27 (Qq): Jembatan batu atas air terjun (Kiri -> Kanan)
    Offset(717.4 / 896.0, 1488.9 / 4800.0), // 28 (Rr): Jalan kanan atas air terjun
    Offset(627.8 / 896.0, 1407.7 / 4800.0), // 29 (Ss): Jalan kanan bukit
    Offset(482.4 / 896.0, 1381.4 / 4800.0), // 30 (Tt): Punggung bukit tengah
    Offset(322.6 / 896.0, 1363.5 / 4800.0), // 31 (Uu): Jalan tengah bukit
    Offset(212.4 / 896.0, 1276.7 / 4800.0), // 32 (Vv): Lengkung kiri bukit
    Offset(275.3 / 896.0, 1160.3 / 4800.0), // 33 (Ww): Jalan kiri sebelum jembatan tebing
    Offset(444.6 / 896.0, 1107.9 / 4800.0), // 34 (Xx): Jembatan pelangi tebing (Kiri -> Kanan)
    Offset(618.9 / 896.0, 1139.4 / 4800.0), // 35 (Yy): Jalan kanan bukit
    Offset(717.4 / 896.0, 1049.4 / 4800.0), // 36 (Zz): Jalan kanan atas

    // ── ZONA KATA: Node 37-44 (W1 - W8) ──
    Offset(615.6 / 896.0,  972.1 / 4800.0), // 37 (W1): Tikungan kanan menuju jembatan anyam
    Offset(454.0 / 896.0,  941.8 / 4800.0), // 38 (W2): Jembatan anyam kayu (Kanan -> Kiri)
    Offset(309.7 / 896.0,  969.7 / 4800.0), // 39 (W3): Sisi kiri jembatan depan rumah kuning
    Offset(200.1 / 896.0,  891.2 / 4800.0), // 40 (W4): Jalan kiri naik ke desa puncak
    Offset(342.6 / 896.0,  710.1 / 4800.0), // 41 (W5): Jalan depan rumah kuning puncak
    Offset(494.4 / 896.0,  696.5 / 4800.0), // 42 (W6): Jalan depan rumah merah tengah
    Offset(656.3 / 896.0,  663.7 / 4800.0), // 43 (W7): Tikungan kanan jalan salju
    Offset(325.0 / 896.0,  370.0 / 4800.0), // 44 (W8): Puncak salju depan pintu rumah puncak
  ];

  // 40 Koordinat relatif belokan jalan utama (X, Y) dari BAWAH (0.0) ke ATAS (1.0)
  // Dikalibrasi presisi piksel-per-piksel pada gambar 114875.webp
  static const List<Offset> _roadWaypoints = [
    Offset(430.0 / 896.0, 4720.0 / 4800.0), // WP  0: Dermaga masuk lembah bawah
    Offset(550.0 / 896.0, 4570.0 / 4800.0), // WP  1: Jembatan pelangi bawah
    Offset(670.0 / 896.0, 4460.0 / 4800.0), // WP  2: Sebelah kanan rumah kuning
    Offset(780.0 / 896.0, 4340.0 / 4800.0), // WP  3: Tikungan atas rumah kuning
    Offset(600.0 / 896.0, 4230.0 / 4800.0), // WP  4: Jalan kembali ke tengah
    Offset(400.0 / 896.0, 4130.0 / 4800.0), // WP  5: Jembatan kayu kiri
    Offset(220.0 / 896.0, 4040.0 / 4800.0), // WP  6: Depan rumah ungu
    Offset(140.0 / 896.0, 3920.0 / 4800.0), // WP  7: Tikungan kiri
    Offset(240.0 / 896.0, 3830.0 / 4800.0), // WP  8: Tikungan naik atas rumah ungu
    Offset(380.0 / 896.0, 3760.0 / 4800.0), // WP  9: Jembatan bawah kebun wortel
    Offset(530.0 / 896.0, 3660.0 / 4800.0), // WP 10: Lengkung bawah kebun bulat
    Offset(730.0 / 896.0, 3520.0 / 4800.0), // WP 11: Sisi kanan kebun wortel bulat
    Offset(640.0 / 896.0, 3400.0 / 4800.0), // WP 12: Lengkung atas kebun bulat
    Offset(440.0 / 896.0, 3320.0 / 4800.0), // WP 13: Jembatan kayu menuju rumah tengah
    Offset(250.0 / 896.0, 3200.0 / 4800.0), // WP 14: Melingkari rumah tengah
    Offset(140.0 / 896.0, 3080.0 / 4800.0), // WP 15: Tepi kiri lereng
    Offset(420.0 / 896.0, 2980.0 / 4800.0), // WP 16: Jembatan kayu tengah
    Offset(670.0 / 896.0, 2860.0 / 4800.0), // WP 17: Depan rumah merah kanan
    Offset(780.0 / 896.0, 2720.0 / 4800.0), // WP 18: Tikungan kanan kebun buah
    Offset(500.0 / 896.0, 2600.0 / 4800.0), // WP 19: Jembatan pelangi tengah
    Offset(260.0 / 896.0, 2490.0 / 4800.0), // WP 20: Lengkung kiri depan rumah pink
    Offset(160.0 / 896.0, 2350.0 / 4800.0), // WP 21: Kebun wortel kotak kiri
    Offset(440.0 / 896.0, 2220.0 / 4800.0), // WP 22: Jembatan kayu menuju bukit tengah
    Offset(330.0 / 896.0, 2080.0 / 4800.0), // WP 23: Melewati pohon apel & bebek biru
    Offset(550.0 / 896.0, 1960.0 / 4800.0), // WP 24: Jembatan pelangi kiwi
    Offset(730.0 / 896.0, 1830.0 / 4800.0), // WP 25: Tepi kanan bawah air terjun
    Offset(550.0 / 896.0, 1680.0 / 4800.0), // WP 26: Jembatan melintasi air terjun
    Offset(320.0 / 896.0, 1550.0 / 4800.0), // WP 27: Tikungan kiri lereng bukit
    Offset(200.0 / 896.0, 1420.0 / 4800.0), // WP 28: Perkebunan kiwi kiri
    Offset(340.0 / 896.0, 1300.0 / 4800.0), // WP 29: Jembatan pelangi naik
    Offset(490.0 / 896.0, 1200.0 / 4800.0), // WP 30: Jalan kuning tengah bukit
    Offset(360.0 / 896.0, 1080.0 / 4800.0), // WP 31: Tikungan kiri tebing
    Offset(230.0 / 896.0,  920.0 / 4800.0), // WP 32: Depan rumah hijau atas
    Offset(430.0 / 896.0,  800.0 / 4800.0), // WP 33: Jembatan kayu atas
    Offset(670.0 / 896.0,  680.0 / 4800.0), // WP 34: Depan cottage atap merah
    Offset(460.0 / 896.0,  560.0 / 4800.0), // WP 35: Jembatan pelangi menuju salju
    Offset(230.0 / 896.0,  440.0 / 4800.0), // WP 36: Tikungan lereng salju bawah
    Offset(460.0 / 896.0,  310.0 / 4800.0), // WP 37: Tanjakan lereng salju tengah
    Offset(400.0 / 896.0,  190.0 / 4800.0), // WP 38: Gerbang masuk desa gunung salju
    Offset(650.0 / 896.0,  140.0 / 4800.0), // WP 39: Puncak tertinggi gunung es (Finish)
  ];

  static final List<double> _cumulativeDistances = _initDistances();

  static List<double> _initDistances() {
    final dists = <double>[0.0];
    for (int i = 0; i < _roadWaypoints.length - 1; i++) {
      final p1 = _roadWaypoints[i];
      final p2 = _roadWaypoints[i + 1];
      final dx = p2.dx - p1.dx;
      final dy = (p2.dy - p1.dy) * aspectRatio;
      final d = math.sqrt(dx * dx + dy * dy);
      dists.add(dists.last + d);
    }
    return dists;
  }

  static double get totalRoadLength => _cumulativeDistances.last;

  /// Mengambil titik koordinat node, memprioritaskan 44 koordinat terkalibrasi presisi
  static Offset getNodePoint(int index, int totalNodes) {
    if (totalNodes == 44 && index >= 0 && index < calibrated44NodePositions.length) {
      return calibrated44NodePositions[index];
    }
    final t = totalNodes <= 1 ? 0.0 : index / (totalNodes - 1);
    return getPointOnPath(t);
  }

  /// Interpolasi posisi kurva jalan untuk parameter t dari 0.0 (Bawah) s/d 1.0 (Atas)
  static Offset getPointOnPath(double t) {
    final clampedT = t.clamp(0.0, 1.0);
    final targetDistance = clampedT * totalRoadLength;

    for (int i = 0; i < _cumulativeDistances.length - 1; i++) {
      final dStart = _cumulativeDistances[i];
      final dEnd = _cumulativeDistances[i + 1];
      if (targetDistance >= dStart && targetDistance <= dEnd) {
        final segLength = dEnd - dStart;
        final remainder = segLength > 0 ? (targetDistance - dStart) / segLength : 0.0;
        final p1 = _roadWaypoints[i];
        final p2 = _roadWaypoints[i + 1];
        return Offset(
          p1.dx + (p2.dx - p1.dx) * remainder,
          p1.dy + (p2.dy - p1.dy) * remainder,
        );
      }
    }
    return _roadWaypoints.last;
  }

  /// Menghitung target scroll offset (dalam pixel) untuk memusatkan kamera ke node aktif
  static double calculateActiveNodeScrollOffset({
    required int activeIndex,
    required int totalNodes,
    required double screenWidth,
    required double screenHeight,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
  }) {
    if (totalNodes <= 0) return 0.0;
    final canvasHeight = screenWidth * aspectRatio;
    final totalHeight = canvasHeight + bottomPadding;
    final maxScroll = (totalHeight - screenHeight).clamp(0.0, double.infinity);

    final point = getNodePoint(activeIndex, totalNodes);
    final nodeAbsoluteY = canvasHeight * point.dy;

    // Pusatkan node di tengah layar
    final targetOffset = nodeAbsoluteY - (screenHeight / 2);
    return targetOffset.clamp(0.0, maxScroll);
  }

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final canvasHeight = screenWidth * aspectRatio;
        final totalHeight = canvasHeight + bottomPadding;

        return SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: screenWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Gambar Tunggal Peta Petualangan Penuh (Edge-to-Edge mulai dari top: 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: canvasHeight,
                  child: Image.asset(
                    AppAssets.worldMapSingle,
                    width: screenWidth,
                    height: canvasHeight,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: screenWidth,
                      height: canvasHeight,
                      color: const Color(0xFFFAF7F2),
                    ),
                  ),
                ),

                // 2. Lapisan Node Selesai & Terkunci (Background Nodes)
                for (int i = 0; i < nodes.length; i++)
                  if (nodes[i].status != MapNodeStatus.active)
                    _buildPositionedNode(
                      index: i,
                      totalNodes: nodes.length,
                      node: nodes[i],
                      screenWidth: screenWidth,
                      canvasHeight: canvasHeight,
                    ),

                // 3. Lapisan Node Aktif & Maskot (Foreground - Selalu di Atas / di Depan)
                for (int i = 0; i < nodes.length; i++)
                  if (nodes[i].status == MapNodeStatus.active)
                    _buildPositionedNode(
                      index: i,
                      totalNodes: nodes.length,
                      node: nodes[i],
                      screenWidth: screenWidth,
                      canvasHeight: canvasHeight,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionedNode({
    required int index,
    required int totalNodes,
    required MapCanvasNodeData node,
    required double screenWidth,
    required double canvasHeight,
  }) {
    // Menggunakan posisi node terkalibrasi presisi atau interpolasi kurva jalan
    final point = getNodePoint(index, totalNodes);

    final isCurrentActive = node.status == MapNodeStatus.active;
    final nodeSize = isCurrentActive ? activeSize : normalSize;

    final absoluteX = screenWidth * point.dx;
    final absoluteY = canvasHeight * point.dy;

    final nodeLeft = absoluteX - (touchTargetSize / 2);
    final nodeTop = absoluteY - (touchTargetSize / 2);

    final nodeButton = MapNodeButton(
      label: node.label,
      status: node.status,
      size: nodeSize,
      primaryColor: isCurrentActive ? AppColors.retryBevel : node.primaryColor,
      bevelColor: isCurrentActive ? const Color(0xFFD9A91E) : node.bevelColor,
      onTap: (node.status == MapNodeStatus.active || node.status == MapNodeStatus.completed)
          ? () => onNodeTap(index)
          : () => SoundPlayer.instance.playSoftRetry(),
    );

    // Target sentuh ramah prasekolah (60x60dp)
    final touchWrappedButton = SizedBox(
      width: touchTargetSize,
      height: touchTargetSize,
      child: Center(child: nodeButton),
    );

    if (isCurrentActive) {
      // Maskot bertengger di atas (Center Top) node aktif secara simetris di depan
      const mascotW = 46.0;
      const mascotH = 46.0;
      const mascotTopOffset = -mascotH - 2.0;

      return Positioned(
        key: node.nodeKey,
        left: nodeLeft,
        top: nodeTop,
        width: touchTargetSize,
        height: touchTargetSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tombol Node Aktif
            touchWrappedButton,

            // Maskot Ramah Mocco Bertengger di Atas Node
            Positioned(
              left: (touchTargetSize - mascotW) / 2,
              top: mascotTopOffset,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  SoundPlayer.instance.playPop();
                  onNodeTap(index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge "Ayo!" Mungil
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 3,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Text(
                        'Ayo!',
                        style: AppTypography.uiButton(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    // Maskot Mocco
                    const SizedBox(
                      width: mascotW,
                      height: mascotH,
                      child: MascotWidget(
                        mood: MascotMood.greeting,
                        size: mascotW,
                        animate: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Positioned(
      key: node.nodeKey,
      left: nodeLeft,
      top: nodeTop,
      width: touchTargetSize,
      height: touchTargetSize,
      child: touchWrappedButton,
    );
  }
}
