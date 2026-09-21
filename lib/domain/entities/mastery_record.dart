import 'package:flutter/foundation.dart';

/// Entity tracking player mastery using a 5-box Leitner Spaced Repetition model
/// (Adapted from iTHUNG for early childhood education without punitive demotion)
@immutable
class MasteryRecord {
  const MasteryRecord({
    required this.id,
    this.box = 1,
    this.attempts = 0,
    this.correct = 0,
    this.lastPracticed,
  });

  /// Unique identifier (e.g. 'number_3', 'letter_a')
  final String id;

  /// Leitner Box (1 to 5, where 5 is fully mastered)
  final int box;

  /// Total attempts for this item
  final int attempts;

  /// Total correct answers
  final int correct;

  /// Timestamp of the last practice session
  final DateTime? lastPracticed;

  /// True if item reached box 5
  bool get isMastered => box >= 5;

  /// Success rate (0.0 to 1.0)
  double get accuracy => attempts > 0 ? correct / attempts : 0.0;

  MasteryRecord copyWith({
    int? box,
    int? attempts,
    int? correct,
    DateTime? lastPracticed,
  }) {
    return MasteryRecord(
      id: id,
      box: box ?? this.box,
      attempts: attempts ?? this.attempts,
      correct: correct ?? this.correct,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'box': box,
      'attempts': attempts,
      'correct': correct,
      'lastPracticed': lastPracticed?.toIso8601String(),
    };
  }

  factory MasteryRecord.fromMap(Map<String, dynamic> map) {
    return MasteryRecord(
      id: map['id'] as String,
      box: (map['box'] as num?)?.toInt() ?? 1,
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      correct: (map['correct'] as num?)?.toInt() ?? 0,
      lastPracticed: map['lastPracticed'] != null
          ? DateTime.tryParse(map['lastPracticed'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasteryRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          box == other.box &&
          attempts == other.attempts &&
          correct == other.correct;

  @override
  int get hashCode =>
      id.hashCode ^ box.hashCode ^ attempts.hashCode ^ correct.hashCode;
}
