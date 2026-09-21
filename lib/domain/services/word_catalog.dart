import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/word_entity.dart';

/// Repository of standard Indonesian KV-KV words and distractor generator.
class WordCatalog {
  static const List<WordEntity> defaultWords = [
    WordEntity(
      id: 'buku',
      word: 'buku',
      syllable1: 'bu',
      syllable2: 'ku',
      icon: Icons.menu_book_rounded,
      meaningAudioKey: 'word_buku',
    ),
    WordEntity(
      id: 'bola',
      word: 'bola',
      syllable1: 'bo',
      syllable2: 'la',
      icon: Icons.sports_soccer_rounded,
      meaningAudioKey: 'word_bola',
    ),
    WordEntity(
      id: 'mata',
      word: 'mata',
      syllable1: 'ma',
      syllable2: 'ta',
      icon: Icons.visibility_rounded,
      meaningAudioKey: 'word_mata',
    ),
    WordEntity(
      id: 'susu',
      word: 'susu',
      syllable1: 'su',
      syllable2: 'su',
      icon: Icons.emoji_food_beverage_rounded,
      meaningAudioKey: 'word_susu',
    ),
    WordEntity(
      id: 'batu',
      word: 'batu',
      syllable1: 'ba',
      syllable2: 'tu',
      icon: Icons.terrain_rounded,
      meaningAudioKey: 'word_batu',
    ),
    WordEntity(
      id: 'topi',
      word: 'topi',
      syllable1: 'to',
      syllable2: 'pi',
      icon: Icons.checkroom_rounded,
      meaningAudioKey: 'word_topi',
    ),
    WordEntity(
      id: 'kaki',
      word: 'kaki',
      syllable1: 'ka',
      syllable2: 'ki',
      icon: Icons.directions_walk_rounded,
      meaningAudioKey: 'word_kaki',
    ),
    WordEntity(
      id: 'roti',
      word: 'roti',
      syllable1: 'ro',
      syllable2: 'ti',
      icon: Icons.bakery_dining_rounded,
      meaningAudioKey: 'word_roti',
    ),
  ];

  static const List<String> allPoolSyllables = [
    'ba', 'bi', 'bu', 'be', 'bo',
    'ka', 'ki', 'ku', 'ke', 'ko',
    'ma', 'mi', 'mu', 'me', 'mo',
    'ta', 'ti', 'tu', 'te', 'to',
    'sa', 'si', 'su', 'se', 'so',
    'la', 'li', 'lu', 'le', 'lo',
    'pa', 'pi', 'pu', 'pe', 'po',
    'ra', 'ri', 'ru', 're', 'ro',
  ];

  /// Generates 4 syllable options containing the required target syllables and distractors.
  static List<String> generateSyllableOptions(WordEntity word, {Random? random}) {
    final rng = random ?? Random();
    final options = <String>{word.syllable1, word.syllable2};

    final pool = List<String>.from(allPoolSyllables)..shuffle(rng);
    for (final syl in pool) {
      if (!options.contains(syl)) {
        options.add(syl);
      }
      if (options.length >= 4) break;
    }

    final list = options.toList()..shuffle(rng);
    return list;
  }
}
