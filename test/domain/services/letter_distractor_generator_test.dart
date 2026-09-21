import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/services/letter_distractor_generator.dart';

void main() {
  group('LetterDistractorGenerator', () {
    const generator = LetterDistractorGenerator();

    test('generates 4 unique options containing the target letter', () {
      final options = generator.generateOptions('b', random: Random(42));

      expect(options.length, equals(4));
      expect(options.toSet().length, equals(4)); // all unique
      expect(options.contains('b'), isTrue); // contains target

      // Verify confusable for 'b' is included (d, p, or q)
      final hasConfusable = options.contains('d') || options.contains('p') || options.contains('q');
      expect(hasConfusable, isTrue);
    });

    test('respects uppercase flag', () {
      final options = generator.generateOptions('A', isUppercase: true, random: Random(42));

      expect(options.length, equals(4));
      expect(options.contains('A'), isTrue);
      for (final opt in options) {
        expect(opt, equals(opt.toUpperCase()));
      }
    });
  });
}
