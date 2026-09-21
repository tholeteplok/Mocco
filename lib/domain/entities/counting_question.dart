import 'package:flutter/foundation.dart';

/// Entity representing a single counting question (1–10)
@immutable
class CountingQuestion {
  const CountingQuestion({
    required this.objectType,
    required this.count,
    required this.correctAnswer,
    required this.options,
  });

  /// The object asset/type to display (e.g. apple, banana, carrot)
  final String objectType;

  /// Total count of objects to display (1–10)
  final int count;

  /// The correct numerical answer (== count)
  final int correctAnswer;

  /// The 4 multiple choice options (including correctAnswer and 3 distractors)
  final List<int> options;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountingQuestion &&
          runtimeType == other.runtimeType &&
          objectType == other.objectType &&
          count == other.count &&
          correctAnswer == other.correctAnswer &&
          listEquals(options, other.options);

  @override
  int get hashCode =>
      objectType.hashCode ^
      count.hashCode ^
      correctAnswer.hashCode ^
      options.hashCode;
}
