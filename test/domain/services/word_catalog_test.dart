import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/services/word_catalog.dart';

void main() {
  group('WordCatalog Tests', () {
    test('defaultWords contains valid KV-KV words', () {
      final words = WordCatalog.defaultWords;
      expect(words.length, greaterThanOrEqualTo(5));

      for (final w in words) {
        expect(w.id, isNotEmpty);
        expect(w.word, isNotEmpty);
        expect(w.syllable1, isNotEmpty);
        expect(w.syllable2, isNotEmpty);
        expect(w.word, equals('${w.syllable1}${w.syllable2}'));
        expect(w.hyphenated, equals('${w.syllable1}-${w.syllable2}'));
      }
    });

    test('generateSyllableOptions produces 4 options containing target syllables', () {
      final word = WordCatalog.defaultWords.first; // e.g. "buku" -> "bu", "ku"
      final options = WordCatalog.generateSyllableOptions(word, random: Random(42));

      expect(options.length, equals(4));
      expect(options.contains(word.syllable1), isTrue);
      expect(options.contains(word.syllable2), isTrue);
    });

    test('generateSyllableOptions works with duplicate syllables like susu', () {
      final susu = WordCatalog.defaultWords.firstWhere((w) => w.id == 'susu');
      final options = WordCatalog.generateSyllableOptions(susu, random: Random(42));

      expect(options.length, equals(4));
      expect(options.contains(susu.syllable1), isTrue);
    });
  });
}
