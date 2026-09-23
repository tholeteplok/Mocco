import 'dart:math';

/// Service to generate letter quiz distractors based on research-backed error patterns (§1.3)
/// Error sources:
/// 1. Visual similarity (rotation/reflection): b ↔ d, p ↔ q
/// 2. Visual similarity (general shape): m ↔ w, n ↔ h, c ↔ o
/// 3. Phonetic similarity: b ↔ p, d ↔ t, m ↔ n
class LetterDistractorGenerator {
  const LetterDistractorGenerator();

  static const Map<String, List<String>> _confusableMap = {
    // Rotations & Reflections
    'b': ['d', 'p', 'q'],
    'd': ['b', 'q', 'p'],
    'p': ['q', 'b', 'd'],
    'q': ['p', 'd', 'b'],
    'u': ['n', 'v'],
    'n': ['u', 'h', 'm'],

    // Shape similarities
    'm': ['w', 'n', 'h'],
    'w': ['m', 'v'],
    'h': ['n', 'b', 'k'],
    'c': ['o', 'e', 'g'],
    'o': ['c', 'e', 'q'],
    'e': ['c', 'o'],
    'i': ['j', 'l'],
    'j': ['i', 'l', 'y'],
    'l': ['i', 't'],
    'v': ['w', 'u'],
    'k': ['h', 'x'],
    's': ['z'],
    'z': ['s'],

    // Phonetic similarities (Indonesian phonetics)
    't': ['d', 'l'],
    'f': ['v', 'p'],
    'g': ['k', 'j'],
    'r': ['l'],
    'a': ['e', 'o'],
    'y': ['j', 'i'],
  };

  /// Generates 4 unique letter options including the target letter.
  /// When [mixedCase] is true, exactly 2 options are uppercase and 2 are lowercase.
  List<String> generateOptions(
    String targetLetter, {
    Random? random,
    bool isUppercase = false,
    bool mixedCase = false,
  }) {
    final rng = random ?? Random();
    final lowerTarget = targetLetter.toLowerCase();
    final optionsSet = <String>{lowerTarget};

    // 1. Add known confusables (visual or phonetic)
    final confusables = _confusableMap[lowerTarget];
    if (confusables != null && confusables.isNotEmpty) {
      final shuffledConfusables = List<String>.from(confusables)..shuffle(rng);
      for (final confusable in shuffledConfusables) {
        optionsSet.add(confusable);
        if (optionsSet.length >= 3) break; // Keep 1 slot for far distractor
      }
    }

    // 2. Add far distractors from the alphabet to complete 4 unique choices
    final allLetters = List<String>.generate(
      26,
      (i) => String.fromCharCode('a'.codeUnitAt(0) + i),
    )..shuffle(rng);

    for (final letter in allLetters) {
      if (optionsSet.length >= 4) break;
      optionsSet.add(letter);
    }

    // 3. Match desired case and shuffle final order
    if (mixedCase) {
      // Balanced 2:2 distribution (2 uppercase, 2 lowercase)
      final list = optionsSet.toList()..shuffle(rng);
      final result = <String>[
        list[0].toUpperCase(),
        list[1].toUpperCase(),
        list[2].toLowerCase(),
        list[3].toLowerCase(),
      ]..shuffle(rng);
      return result;
    }

    final result = optionsSet
        .map((l) => isUppercase ? l.toUpperCase() : l)
        .toList()
      ..shuffle(rng);

    return result;
  }
}
