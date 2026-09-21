import 'dart:math';
import '../entities/mastery_record.dart';

/// Leitner Spaced Repetition Engine with Soft DDA (Anti-Frustration)
/// Adapted from iTHUNG specifically for early childhood education (Spec §3)
class MasteryEngine {
  const MasteryEngine();

  /// Updates mastery record based on answer correctness
  /// Correct answers promote the item to the next box (up to 5).
  /// Incorrect answers soft-demote the item by 1 box (minimum 1) rather than wiping out progress.
  MasteryRecord recordResult(MasteryRecord current, bool isCorrect, {DateTime? timestamp}) {
    final now = timestamp ?? DateTime.now();

    if (isCorrect) {
      final nextBox = (current.box + 1).clamp(1, 5);
      return current.copyWith(
        box: nextBox,
        attempts: current.attempts + 1,
        correct: current.correct + 1,
        lastPracticed: now,
      );
    } else {
      // Soft DDA: demote by 1 box instead of punishing back to Box 1
      final nextBox = (current.box - 1).clamp(1, 5);
      return current.copyWith(
        box: nextBox,
        attempts: current.attempts + 1,
        lastPracticed: now,
      );
    }
  }

  /// Selects the next candidate to practice using Leitner box weights
  /// Lower box items have exponentially higher probability of being selected.
  MasteryRecord? selectSpacedCandidate(List<MasteryRecord> items, {Random? random}) {
    if (items.isEmpty) return null;

    final rng = random ?? Random();

    // Box weights: Box 1 = 16, Box 2 = 8, Box 3 = 4, Box 4 = 2, Box 5 = 1
    final weights = items.map((item) {
      switch (item.box) {
        case 1:
          return 16;
        case 2:
          return 8;
        case 3:
          return 4;
        case 4:
          return 2;
        default:
          return 1;
      }
    }).toList();

    final totalWeight = weights.fold<int>(0, (sum, w) => sum + w);
    var roll = rng.nextInt(totalWeight);

    for (int i = 0; i < items.length; i++) {
      roll -= weights[i];
      if (roll < 0) {
        return items[i];
      }
    }

    return items.first;
  }
}
