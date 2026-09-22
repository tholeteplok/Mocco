import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/services/number_strokes.dart';

void main() {
  group('NumberStrokes Tests', () {
    test('Number 10 has exactly 2 separate strokes for digit 1 and digit 0', () {
      final strokes = NumberStrokes.forChar('10');

      expect(strokes, isNotNull, reason: 'Strokes for 10 must not be null');
      expect(strokes!.length, equals(2), reason: '10 must have exactly 2 strokes (digit 1 and digit 0)');

      final stroke1 = strokes[0]; // Digit '1'
      final stroke0 = strokes[1]; // Digit '0'

      // Digit 1: Left area (X roughly 20-40)
      expect(stroke1.length, greaterThanOrEqualTo(2));
      for (final pt in stroke1) {
        expect(pt[0], inInclusiveRange(15.0, 45.0), reason: 'Digit 1 X must stay in left half');
        expect(pt[1], inInclusiveRange(10.0, 90.0), reason: 'Digit 1 Y must stay in vertical bounds');
      }

      // Digit 0: Right area (X roughly 45-90)
      expect(stroke0.length, greaterThanOrEqualTo(10), reason: 'Digit 0 must be a smooth arc with many points');
      for (final pt in stroke0) {
        expect(pt[0], inInclusiveRange(45.0, 90.0), reason: 'Digit 0 X must stay in right half');
        expect(pt[1], inInclusiveRange(10.0, 90.0), reason: 'Digit 0 Y must stay in vertical bounds');
      }

      // Digit 0 should form a closed loop (start close to end)
      final start = stroke0.first;
      final end = stroke0.last;
      final loopGap = math.sqrt(math.pow(start[0] - end[0], 2) + math.pow(start[1] - end[1], 2));
      expect(loopGap, lessThan(2.0), reason: 'Digit 0 should close the loop');
    });

    test('Number 4 has exactly 2 strokes (L-stem and vertical stem)', () {
      final strokes = NumberStrokes.forChar('4');

      expect(strokes, isNotNull);
      expect(strokes!.length, equals(2), reason: 'Number 4 must require 2 independent strokes');

      final strokeL = strokes[0];
      final strokeVertical = strokes[1];

      expect(strokeL.length, greaterThanOrEqualTo(2));
      expect(strokeVertical.length, equals(2));

      // Stroke 2 must be a straight vertical line
      expect(strokeVertical[0][0], equals(strokeVertical[1][0]), reason: 'Vertical line X coordinates must match');
      expect(strokeVertical[0][1], lessThan(strokeVertical[1][1]), reason: 'Must go from top to bottom');
    });

    test('Number 9 has 1 smooth continuous stroke with closed loop and hook', () {
      final strokes = NumberStrokes.forChar('9');

      expect(strokes, isNotNull);
      if (strokes == null) return;
      expect(strokes.length, equals(1), reason: 'Number 9 should be drawn in 1 continuous movement');

      final stroke = strokes[0];
      expect(stroke.length, greaterThanOrEqualTo(12));

      // Verify smooth continuity: no sudden teleport jumps (> 25 units)
      for (int i = 1; i < stroke.length; i++) {
        final dist = math.sqrt(
          math.pow(stroke[i][0] - stroke[i - 1][0], 2) +
          math.pow(stroke[i][1] - stroke[i - 1][1], 2),
        );
        expect(dist, lessThan(25.0), reason: 'Point step $i must be smooth without jumps');
      }

      // Starts near top-right of loop
      expect(stroke.first[1], lessThan(40.0));
      // Ends at the bottom hook
      expect(stroke.last[1], greaterThan(75.0));
    });

    test('All numbers 0-10 have valid coordinates within 0..100 bounds', () {
      for (int n = 0; n <= 10; n++) {
        final strokes = NumberStrokes.forChar('$n');
        expect(strokes, isNotNull, reason: 'Number $n must have defined strokes');
        if (strokes == null) continue;
        expect(strokes, isNotEmpty, reason: 'Number $n must have at least 1 stroke');

        for (int s = 0; s < strokes.length; s++) {
          for (final pt in strokes[s]) {
            expect(pt.length, equals(2), reason: 'Each point must have [x, y]');
            expect(pt[0], inInclusiveRange(0.0, 100.0), reason: 'Number $n stroke $s pt X out of bounds: ${pt[0]}');
            expect(pt[1], inInclusiveRange(0.0, 100.0), reason: 'Number $n stroke $s pt Y out of bounds: ${pt[1]}');
          }
        }
      }
    });

    test('Returns null for empty or invalid characters', () {
      expect(NumberStrokes.forChar(''), isNull);
      expect(NumberStrokes.forChar('?'), isNull);
      expect(NumberStrokes.forChar('11'), isNull);
    });

    test('All letters A-Z have valid strokes', () {
      const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      for (int i = 0; i < alphabet.length; i++) {
        final ch = alphabet[i];
        final strokes = NumberStrokes.forChar(ch);
        expect(strokes, isNotNull, reason: 'Letter $ch must have strokes');
        if (strokes == null) continue;
        expect(strokes, isNotEmpty);
      }
    });
  });
}
