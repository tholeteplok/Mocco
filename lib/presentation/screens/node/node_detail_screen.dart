import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/entities/journey_node.dart';
import '../../../domain/entities/letter_entity.dart';
import '../../../domain/services/word_catalog.dart';
import '../../widgets/buttons/bubble_icon_button.dart';

// Emoji objek untuk angka (10 item)
const _kCountEmoji = ['🍎', '⭐', '🐟', '🐤', '⚽', '🌸', '🍊', '🎈', '🦋', '🍓'];

/// Layar pengenalan node sebelum latihan (V2.0 — Zero-Choice Living Stage).
///
/// Mengusung prinsip "Gajah Tanpa Kontainer":
/// - Satu panggung interaktif terpadu tanpa kartu menu redundan.
/// - Objek pendukung (ikan, apel, bebek) dapat disentuh langsung di tempat untuk berhitung.
/// - Hanya 1 tombol aksi utama tunggal di bawah: "Ayo Latihan! ➜".
class NodeDetailScreen extends StatefulWidget {
  const NodeDetailScreen({
    super.key,
    required this.node,
    required this.onStartActivity,
    this.onBack,
  });

  final JourneyNode node;
  /// Dipanggil saat anak menekan "Ayo Latihan!" — caller membuka activity latihan.
  final VoidCallback onStartActivity;
  final VoidCallback? onBack;

  @override
  State<NodeDetailScreen> createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroScale;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heroScale = CurvedAnimation(parent: _heroController, curve: Curves.elasticOut);
    _heroController.forward();

    // Auto-play suara saat layar terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) => _playNodeAudio());
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  void _playNodeAudio() {
    switch (widget.node.type) {
      case NodeType.numbers:
        SoundPlayer.instance.playNumber(widget.node.typeIndex);
      case NodeType.letters:
        if (widget.node.typeIndex < LetterEntity.alphabet.length) {
          final letter = LetterEntity.alphabet[widget.node.typeIndex];
          SoundPlayer.instance.playLetterName(letter.char);
        } else {
          SoundPlayer.instance.playPop();
        }
      case NodeType.words:
        if (widget.node.typeIndex < WordCatalog.defaultWords.length) {
          final word = WordCatalog.defaultWords[widget.node.typeIndex];
          SoundPlayer.instance.playWord(word.word);
        } else {
          SoundPlayer.instance.playPop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.node.primaryColor;
    final bevel = widget.node.bevelColor;

    // Warna solid pastel hangat, ramah anak & bebas bocor ke dark mode OS
    final bgSolid = switch (widget.node.type) {
      NodeType.numbers => const Color(0xFFFFF7EE), // Creamy Warm Honey Peach
      NodeType.letters => const Color(0xFFF1F8FD), // Soft Powder Sky Blue
      NodeType.words => const Color(0xFFF2F9F3),   // Gentle Meadow Leaf Mint
    };

    return Scaffold(
      backgroundColor: bgSolid,
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              child: Row(
                children: [
                  BubbleIconButton.back(
                    onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  BubbleIconButton.voice(
                    onPressed: _playNodeAudio,
                  ),
                ],
              ),
            ),

            // Hero Living Stage (Fokus Utama Interaktif)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _heroScale,
                        child: _InteractiveHeroStage(
                          node: widget.node,
                          onTapGlyph: _playNodeAudio,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space32),

                      // Single CTA: Ayo Latihan! (Zero Choice)
                      _LatihBtn(
                        color: color,
                        bevel: bevel,
                        onTap: widget.onStartActivity,
                      ),
                      const SizedBox(height: AppSpacing.space16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Interactive Hero Stage (Panggung Hidup Terpadu — Bebas Kontainer Kaku)
// ═══════════════════════════════════════════════════════════════════════════════

class _InteractiveHeroStage extends StatefulWidget {
  const _InteractiveHeroStage({
    required this.node,
    required this.onTapGlyph,
  });

  final JourneyNode node;
  final VoidCallback onTapGlyph;

  @override
  State<_InteractiveHeroStage> createState() => _InteractiveHeroStageState();
}

class _InteractiveHeroStageState extends State<_InteractiveHeroStage> {
  final Set<int> _tappedIndices = <int>{};
  bool _isLetterObjectTapped = false;

  void _handleItemTap(int index) {
    if (_tappedIndices.contains(index)) return;

    setState(() {
      _tappedIndices.add(index);
    });

    SoundPlayer.instance.playPop();
    SoundPlayer.instance.playNumber(_tappedIndices.length);

    // Jika semua item berhasil disentuh, bunyikan rangkaian selebrasi lengkap
    if (_tappedIndices.length == widget.node.typeIndex) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          SoundPlayer.instance.playCelebration();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.node.primaryColor;
    final bevel = widget.node.bevelColor;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final backdropWidth = ResponsiveHelper.value(
      context,
      mobile: math.min(340.0, screenWidth - 32.0),
      tablet: 420.0,
    );
    final backdropHeight = ResponsiveHelper.value(
      context,
      mobile: 300.0,
      tablet: 380.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft Organic Backdrop Stage (Siluet panggung organik ramah anak)
          Container(
            width: backdropWidth,
            height: backdropHeight,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.all(
                Radius.elliptical(backdropWidth / 2, backdropHeight / 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 48,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Content: Glyph Utama & Objek Interaktif
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glyph Utama (Angka / Huruf / Kata) — Gagah & Dominan
              GestureDetector(
                onTap: () {
                  SoundPlayer.instance.playPop();
                  widget.onTapGlyph();
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.node.label,
                          style: AppTypography.learningDisplay(
                            fontSize: 160.0,
                            color: color,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: bevel.withValues(alpha: 0.35),
                                offset: const Offset(0, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 18, color: color.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Ketuk untuk mendengar',
                          style: AppTypography.uiBody(
                            fontSize: 13,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space16),

              // Objek Pendukung yang Interaktif di tempat
              _buildInteractiveSubContent(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSubContent() {
    final color = widget.node.primaryColor;

    switch (widget.node.type) {
      case NodeType.numbers:
        final n = widget.node.typeIndex;
        if (n == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              'nol = kosong 🤗',
              style: AppTypography.uiBody(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }

        final emoji = _kCountEmoji[(n - 1) % _kCountEmoji.length];
        final allTapped = _tappedIndices.length == n;

        return Column(
          children: [
            // Status petunjuk
            Text(
              allTapped ? 'Hebat! Semuanya sudah dihitung! 🎉' : 'Sentuh benda untuk berhitung! 👇',
              style: AppTypography.uiBody(
                fontSize: 13,
                color: allTapped ? AppColors.brandMintDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),

            // Baris item interaktif (100% Bebas Tanpa Kontainer Kotak — Konsep Gajah Dribbble)
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(n, (i) {
                final isTapped = _tappedIndices.contains(i);
                return GestureDetector(
                  onTap: () => _handleItemTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedScale(
                    scale: isTapped ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Text(
                              emoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                            if (isTapped)
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.node.bevelColor.withValues(alpha: 0.35),
                                        offset: const Offset(0, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Bayangan lembut permukaan panggung di bawah benda melayang
                        Container(
                          width: 38,
                          height: 7,
                          decoration: BoxDecoration(
                            color: widget.node.bevelColor.withValues(alpha: 0.22),
                            borderRadius: const BorderRadius.all(
                              Radius.elliptical(19, 3.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case NodeType.letters:
        final letters = LetterEntity.alphabet;
        if (widget.node.typeIndex < letters.length) {
          final letter = letters[widget.node.typeIndex];
          final isTapped = _isLetterObjectTapped;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sentuh benda untuk mengenal huruf! 👇',
                style: AppTypography.uiBody(
                  fontSize: 13,
                  color: isTapped ? AppColors.brandMintDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space12),

              GestureDetector(
                onTap: () {
                  setState(() => _isLetterObjectTapped = true);
                  SoundPlayer.instance.playSquish();
                  SoundPlayer.instance.playWord(letter.exampleWord);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) setState(() => _isLetterObjectTapped = false);
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: isTapped ? 1.25 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
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

                          if (isTapped)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.node.bevelColor.withValues(alpha: 0.35),
                                      offset: const Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Soft Diorama Floor Contact Shadow
                      Container(
                        width: 96,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.node.bevelColor.withValues(alpha: 0.22),
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(48, 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space12),

              // Pill label: "A untuk Apel" + "Bunyi: /a/"
              GestureDetector(
                onTap: () {
                  SoundPlayer.instance.playSquish();
                  SoundPlayer.instance.playWord(letter.exampleWord);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.node.bevelColor.withValues(alpha: 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${letter.char} untuk ${letter.exampleWord}',
                        style: AppTypography.uiHeading(fontSize: 18).copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          letter.phonic,
                          style: AppTypography.uiButton(fontSize: 13).copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();

      case NodeType.words:
        final words = WordCatalog.defaultWords;
        if (widget.node.typeIndex < words.length) {
          final word = words[widget.node.typeIndex];
          return GestureDetector(
            onTap: () {
              SoundPlayer.instance.playPop();
              SoundPlayer.instance.playWord(word.word);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.node.bevelColor.withValues(alpha: 0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(word.icon, size: 36, color: color),
                  const SizedBox(width: 10),
                  Text(
                    word.word,
                    style: AppTypography.uiHeading(fontSize: 22).copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.volume_up_rounded, size: 18, color: color.withValues(alpha: 0.7)),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CTA Button (Satu-Satunya Tombol Aksi: Ayo Latihan!)
// ═══════════════════════════════════════════════════════════════════════════════

class _LatihBtn extends StatefulWidget {
  const _LatihBtn({
    required this.color,
    required this.bevel,
    required this.onTap,
  });

  final Color color;
  final Color bevel;
  final VoidCallback onTap;

  @override
  State<_LatihBtn> createState() => _LatihBtnState();
}

class _LatihBtnState extends State<_LatihBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        SoundPlayer.instance.playSuccess();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        margin: EdgeInsets.only(top: _pressed ? 4 : 0, bottom: _pressed ? 0 : 4),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: AppSpacing.roundedPill,
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: widget.bevel,
                    offset: const Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ayo Latihan!',
              style: AppTypography.uiButton(fontSize: 20).copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

