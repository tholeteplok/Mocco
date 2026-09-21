import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/services/counting_question_generator.dart';

void main() {
  group('CountingQuestionGenerator', () {
    const generator = CountingQuestionGenerator();

    test('generates valid question with 4 unique options and correct answer', () {
      for (int target = 1; target <= 10; target++) {
        final question = generator.generate(targetCount: target, random: Random(42 + target));

        expect(question.count, equals(target));
        expect(question.correctAnswer, equals(target));
        expect(question.options.length, equals(4));
        expect(question.options.toSet().length, equals(4)); // all unique
        expect(question.options.contains(target), isTrue); // contains correct answer

        // Verify correct ± 1 distractor rule
        final hasPlusOrMinusOne = question.options.contains(target + 1) ||
            question.options.contains(target - 1);
        expect(hasPlusOrMinusOne, isTrue);
      }
    });
  });
}
