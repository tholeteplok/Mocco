import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/entities/mastery_record.dart';
import 'package:mocco/domain/services/mastery_engine.dart';

void main() {
  group('MasteryEngine', () {
    const engine = MasteryEngine();

    test('promotes item on correct answer up to box 5', () {
      var record = const MasteryRecord(id: 'num_1', box: 1);

      record = engine.recordResult(record, true);
      expect(record.box, equals(2));
      expect(record.attempts, equals(1));
      expect(record.correct, equals(1));

      // Max box is 5
      record = const MasteryRecord(id: 'num_1', box: 5);
      record = engine.recordResult(record, true);
      expect(record.box, equals(5));
      expect(record.isMastered, isTrue);
    });

    test('soft-demotes by 1 box on incorrect answer (minimum box 1)', () {
      var record = const MasteryRecord(id: 'num_1', box: 4, attempts: 5, correct: 4);

      record = engine.recordResult(record, false);
      expect(record.box, equals(3)); // Soft demotion, not dropped to 1!
      expect(record.attempts, equals(6));
      expect(record.correct, equals(4));

      // Minimum box is 1
      record = const MasteryRecord(id: 'num_1', box: 1);
      record = engine.recordResult(record, false);
      expect(record.box, equals(1));
    });

    test('selects candidates with higher probability for lower box items', () {
      final items = [
        const MasteryRecord(id: 'box_1_item', box: 1),
        const MasteryRecord(id: 'box_5_item', box: 5),
      ];

      var box1Count = 0;
      final rng = Random(123);
      for (int i = 0; i < 100; i++) {
        final picked = engine.selectSpacedCandidate(items, random: rng);
        if (picked?.id == 'box_1_item') box1Count++;
      }

      // Box 1 weight (16) vs Box 5 weight (1) -> Box 1 should be selected significantly more often
      expect(box1Count, greaterThan(80));
    });
  });
}
