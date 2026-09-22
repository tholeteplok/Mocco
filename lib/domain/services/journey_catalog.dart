import 'package:flutter/material.dart';

import '../../core/tokens/app_colors.dart';
import '../entities/journey_node.dart';
import '../entities/letter_entity.dart';
import 'word_catalog.dart';

// Alias warna zona — sentralisasi agar mudah di-maintain
const Color _numberPrimary = AppColors.numberPrimary;
const Color _numberBevel = AppColors.numberBevel;
const Color _letterPrimary = AppColors.letterPrimary;
const Color _letterBevel = AppColors.letterBevel;
const Color _blendingPrimary = AppColors.blendingPrimary;
const Color _blendingBevel = AppColors.blendingBevel;

/// Sumber kebenaran tunggal untuk seluruh urutan node dalam peta perjalanan.
///
/// Total 44 node linear:
///   Node  1–10 : Angka 1–10           (biru)
///   Node 11–36 : Huruf A–Z (26 huruf) (hijau)
///   Node 37–44 : Kata 8 kata dasar    (ungu)
///
/// Tidak ada percabangan — anak selalu mengikuti satu jalur dari awal hingga akhir.
abstract final class JourneyCatalog {
  JourneyCatalog._();

  /// Total jumlah node dalam seluruh path.
  static const int totalNodes = 44;

  /// Seluruh node dalam urutan linear.
  ///
  /// Dipanggil sekali dan di-cache oleh caller (lazy const tidak bisa untuk List
  /// yang bergantung entity lain, jadi dibuat sebagai getter).
  static List<JourneyNode> get allNodes {
    final nodes = <JourneyNode>[];

    // ── Zona Angka: Node 1–10 ──────────────────────────────────────────
    for (int i = 1; i <= 10; i++) {
      nodes.add(JourneyNode(
        globalIndex: i,
        type: NodeType.numbers,
        typeIndex: i,
        label: '$i',
        primaryColor: _numberPrimary,
        bevelColor: _numberBevel,
      ));
    }

    // ── Zona Huruf: Node 11–36 ─────────────────────────────────────────
    final letters = LetterEntity.alphabet;
    for (int i = 0; i < letters.length; i++) {
      nodes.add(JourneyNode(
        globalIndex: 11 + i,
        type: NodeType.letters,
        typeIndex: i,           // 0-based letter index
        label: letters[i].pairDisplay, // 'Aa', 'Bb', ...
        primaryColor: _letterPrimary,
        bevelColor: _letterBevel,
      ));
    }

    // ── Zona Kata: Node 37–44 ──────────────────────────────────────────
    final words = WordCatalog.defaultWords;
    for (int i = 0; i < words.length; i++) {
      nodes.add(JourneyNode(
        globalIndex: 37 + i,
        type: NodeType.words,
        typeIndex: i,           // 0-based word index
        label: words[i].hyphenated,  // 'bu·ku', 'bo·la', ...
        primaryColor: _blendingPrimary,
        bevelColor: _blendingBevel,
      ));
    }

    return nodes;
  }

  /// Kembalikan node berdasarkan globalIndex (1-based). Null jika tidak ditemukan.
  static JourneyNode? nodeAt(int globalIndex) {
    if (globalIndex < 1 || globalIndex > totalNodes) return null;
    return allNodes[globalIndex - 1];
  }
}
