import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/utils/sound_player.dart';
import 'map_node_button.dart';

/// Model data generik untuk satu titik node pada LoopingMapCanvas.
class MapCanvasNodeData {
  const MapCanvasNodeData({
    required this.id,
    required this.label,
    required this.status,
    this.primaryColor = AppColors.numberPrimary,
    this.bevelColor = AppColors.numberBevel,
    this.nodeKey,
  });

  final dynamic id;
  final String label;
  final MapNodeStatus status;
  final Color primaryColor;
  final Color bevelColor;
  final GlobalKey? nodeKey;
}

/// Kanvas Peta Berkelanjutan Tanpa Kartu (Full-Screen Seamless Looping Map).
///
/// Fitur:
/// - Menggunakan aset taman bermain (`AppAssets.mapCanvasBg`).
/// - Jalan masuk di (0.50, 0.0) dan jalan keluar di (0.50, 1.0) menyambung mulus antar-tile vertikal.
/// - Menempatkan setiap node tepat di atas 6 belokan jalan utama per tile.
/// - Mendukung pengulangan latihan (replay) untuk node yang sudah berstatus `completed`.
/// - Ukuran node proporsional (64dp aktif, 56dp reguler) agar pas di badan jalan tanpa menutupi ilustrasi.
class LoopingMapCanvas extends StatelessWidget {
  const LoopingMapCanvas({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.scrollController,
    this.activeSize = 64.0,
    this.normalSize = 56.0,
    this.topPadding = 76.0,
    this.bottomPadding = 64.0,
  });

  final List<MapCanvasNodeData> nodes;
  final ValueChanged<int> onNodeTap;
  final ScrollController? scrollController;
  final double activeSize;
  final double normalSize;
  final double topPadding;
  final double bottomPadding;

  // Rasio gambar asli: 768 × 1376 (H / W = 1.7916667)
  static const double _aspectRatio = 1376.0 / 768.0;

  // 6 Koordinat belokan jalan utama per tile (rasio dx & dy relatif)
  static const List<Offset> _tileTurns = [
    Offset(0.650, 0.155), // Belokan 1: Kanan (mengitari komidi putar)
    Offset(0.345, 0.310), // Belokan 2: Kiri (di atas kotak pasir)
    Offset(0.640, 0.445), // Belokan 3: Kanan (antara kotak pasir & kolam bebek)
    Offset(0.350, 0.570), // Belokan 4: Kiri (bawah kolam bebek, seluncuran spiral)
    Offset(0.655, 0.710), // Belokan 5: Kanan (antara seluncuran & ayunan)
    Offset(0.370, 0.865), // Belokan 6: Kiri (bawah ayunan, di atas labirin)
  ];

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final tileHeight = screenWidth * _aspectRatio;
        final numTiles = (nodes.length / _tileTurns.length).ceil().clamp(1, 999);
        final totalHeight = topPadding + (numTiles * tileHeight) + bottomPadding;

        return SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: screenWidth,
            height: totalHeight,
            child: Stack(
              children: [
                // 1. Lapisan Tile Peta Vertikal (Seamless Loop)
                Positioned(
                  top: topPadding,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(numTiles, (tileIndex) {
                      return Image.asset(
                        AppAssets.mapCanvasBg,
                        width: screenWidth,
                        height: tileHeight,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: screenWidth,
                          height: tileHeight,
                          color: const Color(0xFFFAF7F2),
                        ),
                      );
                    }),
                  ),
                ),

                // 2. Lapisan Node yang Ditempatkan Tepat pada Belokan Jalan
                for (int i = 0; i < nodes.length; i++)
                  _buildPositionedNode(
                    index: i,
                    node: nodes[i],
                    screenWidth: screenWidth,
                    tileHeight: tileHeight,
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
    required MapCanvasNodeData node,
    required double screenWidth,
    required double tileHeight,
  }) {
    final tileIndex = index ~/ _tileTurns.length;
    final turnIndex = index % _tileTurns.length;
    final turn = _tileTurns[turnIndex];

    final isCurrentActive = node.status == MapNodeStatus.active;
    final nodeSize = isCurrentActive ? activeSize : normalSize;

    final nodeLeft = (screenWidth * turn.dx) - (nodeSize / 2);
    final nodeTop = topPadding + (tileIndex * tileHeight) + (tileHeight * turn.dy) - (nodeSize / 2);

    return Positioned(
      key: node.nodeKey,
      left: nodeLeft,
      top: nodeTop,
      child: MapNodeButton(
        label: node.label,
        status: node.status,
        size: nodeSize,
        primaryColor: isCurrentActive ? AppColors.retryBevel : node.primaryColor,
        bevelColor: isCurrentActive ? const Color(0xFFD9A91E) : node.bevelColor,
        onTap: (node.status == MapNodeStatus.active || node.status == MapNodeStatus.completed)
            ? () => onNodeTap(index)
            : () => SoundPlayer.instance.playSoftRetry(),
      ),
    );
  }
}
