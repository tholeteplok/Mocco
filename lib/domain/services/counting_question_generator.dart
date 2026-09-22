import 'dart:math';
import '../../core/constants/app_assets.dart';
import '../entities/counting_question.dart';

/// Service to generate counting questions with research-backed distractors and subitizing rules
class CountingQuestionGenerator {
  final int? fixedTargetCount;

  const CountingQuestionGenerator({this.fixedTargetCount});

  /// Generates a counting question for numbers 1 to 10
  CountingQuestion generate({
    int? targetCount,
    String? objectType,
    Random? random,
  }) {
    final rng = random ?? Random();

    // 1. Pick count (1–10). Prioritaskan parameter, lalu fixedTargetCount, lalu acak
    final count = targetCount ?? fixedTargetCount ?? (rng.nextInt(10) + 1);

    // 2. Pick single object type (1 jenis objek per soal - V30)
    final object = objectType ??
        AppAssets.countingObjects[rng.nextInt(AppAssets.countingObjects.length)];

    // 3. Generate distractors based on natural errors (correct ± 1)
    final options = _generateOptions(count, rng);

    return CountingQuestion(
      objectType: object,
      count: count,
      correctAnswer: count,
      options: options,
    );
  }

  List<int> _generateOptions(int count, Random rng) {
    final optionsSet = <int>{count};

    // Priority 1: Natural counting error (correct ± 1)
    final plusOne = count + 1;
    final minusOne = count - 1;

    final nearOptions = <int>[];
    if (minusOne >= 1) nearOptions.add(minusOne);
    if (plusOne <= 10) nearOptions.add(plusOne);

    nearOptions.shuffle(rng);
    for (final near in nearOptions) {
      optionsSet.add(near);
      if (optionsSet.length >= 3) break;
    }

    // Priority 2: Far options to complete 4 unique choices (1..10)
    final allNumbers = List.generate(10, (i) => i + 1)..shuffle(rng);
    for (final num in allNumbers) {
      if (optionsSet.length >= 4) break;
      optionsSet.add(num);
    }

    final optionsList = optionsSet.toList()..shuffle(rng);
    return optionsList;
  }
}
