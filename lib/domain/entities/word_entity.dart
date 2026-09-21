import 'package:flutter/material.dart';

/// Represents a simple 2-syllable (KV-KV) word for early reading blending.
class WordEntity {
  final String id;
  final String word;
  final String syllable1;
  final String syllable2;
  final IconData icon;
  final String meaningAudioKey;

  const WordEntity({
    required this.id,
    required this.word,
    required this.syllable1,
    required this.syllable2,
    required this.icon,
    this.meaningAudioKey = '',
  });

  /// Returns hyphenated syllable representation (e.g. "bu-ku")
  String get hyphenated => '$syllable1-$syllable2';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
