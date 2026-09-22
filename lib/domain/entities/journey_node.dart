import 'package:flutter/material.dart';

/// Tipe konten setiap node di peta perjalanan.
enum NodeType {
  numbers,
  letters,
  words,
}

/// Satu node dalam peta perjalanan linear Mocco.
///
/// Setiap node merepresentasikan satu sesi belajar yang harus diselesaikan
/// sebelum node berikutnya terbuka.
@immutable
class JourneyNode {
  const JourneyNode({
    required this.globalIndex,
    required this.type,
    required this.typeIndex,
    required this.label,
    required this.primaryColor,
    required this.bevelColor,
  });

  /// Posisi global node dalam seluruh path (1-based).
  final int globalIndex;

  /// Tipe konten node (angka, huruf, atau kata).
  final NodeType type;

  /// Index dalam tipenya sendiri (misal: angka ke-3, huruf ke-5).
  final int typeIndex;

  /// Label yang ditampilkan di dalam tombol node (misal: '3', 'Aa', 'bu·ku').
  final String label;

  /// Warna utama node sesuai zona.
  final Color primaryColor;

  /// Warna bevel (shadow bawah) node sesuai zona.
  final Color bevelColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyNode &&
          runtimeType == other.runtimeType &&
          globalIndex == other.globalIndex;

  @override
  int get hashCode => globalIndex.hashCode;
}

/// Status node berdasarkan progres global anak.
enum JourneyNodeStatus { locked, active, completed }

/// Helper: tentukan status node berdasarkan globalIndex dan unlockedIndex.
JourneyNodeStatus nodeStatus(int nodeGlobalIndex, int unlockedIndex) {
  if (nodeGlobalIndex < unlockedIndex) return JourneyNodeStatus.completed;
  if (nodeGlobalIndex == unlockedIndex) return JourneyNodeStatus.active;
  return JourneyNodeStatus.locked;
}
