import '../entities/mastery_record.dart';
import 'word_catalog.dart';

class ZoneProgress {
  const ZoneProgress({
    required this.total,
    required this.trained,
    required this.mastered,
    required this.attempts,
    required this.correct,
  });
  final int total;
  final int trained;
  final int mastered;
  final int attempts;
  final int correct;
  double get coverage => total == 0 ? 0.0 : trained / total;
  double get accuracy => attempts == 0 ? 0.0 : correct / attempts;
  double get masteryRate => total == 0 ? 0.0 : mastered / total;
}

class ParentStats {
  const ParentStats({
    required this.totalNodes,
    required this.unlockedLessons,
    required this.trainedCount,
    required this.masteredCount,
    required this.attemptsTotal,
    required this.correctTotal,
    required this.numbers,
    required this.letters,
    required this.words,
    required this.weakestZone,
  });
  final int totalNodes;
  final int unlockedLessons;
  final int trainedCount;
  final int masteredCount;
  final int attemptsTotal;
  final int correctTotal;
  final ZoneProgress numbers;
  final ZoneProgress letters;
  final ZoneProgress words;
  final String? weakestZone;
  double get accuracy => attemptsTotal == 0 ? 0.0 : correctTotal / attemptsTotal;
}

class ParentStatsService {
  ParentStatsService._();
  static const int numbersTotal = 10;
  static const int lettersTotal = 26;
  static String zoneOf(String id) {
    if (id.startsWith('number_')) return 'numbers';
    if (id.startsWith('letter_')) return 'letters';
    if (id.startsWith('word_')) return 'words';
    return 'unknown';
  }

  static ParentStats compute(List<MasteryRecord> records, int globalUnlockedIndex) {
    final wordsTotal = WordCatalog.defaultWords.length;
    var nTrained = 0;
    var nMastered = 0;
    var nAttempts = 0;
    var nCorrect = 0;
    var lTrained = 0;
    var lMastered = 0;
    var lAttempts = 0;
    var lCorrect = 0;
    var wTrained = 0;
    var wMastered = 0;
    var wAttempts = 0;
    var wCorrect = 0;
    var trainedCount = 0;
    var masteredCount = 0;
    var attemptsTotal = 0;
    var correctTotal = 0;
    for (final r in records) {
      if (r.attempts <= 0) continue;
      final zone = zoneOf(r.id);
      if (zone == 'unknown') continue;
      trainedCount += 1;
      attemptsTotal += r.attempts;
      correctTotal += r.correct;
      if (r.isMastered) masteredCount += 1;
      if (zone == 'numbers') {
        nTrained += 1;
        nAttempts += r.attempts;
        nCorrect += r.correct;
        if (r.isMastered) nMastered += 1;
      } else if (zone == 'letters') {
        lTrained += 1;
        lAttempts += r.attempts;
        lCorrect += r.correct;
        if (r.isMastered) lMastered += 1;
      } else {
        wTrained += 1;
        wAttempts += r.attempts;
        wCorrect += r.correct;
        if (r.isMastered) wMastered += 1;
      }
    }
    final numbers = ZoneProgress(
      total: numbersTotal,
      trained: nTrained,
      mastered: nMastered,
      attempts: nAttempts,
      correct: nCorrect,
    );
    final letters = ZoneProgress(
      total: lettersTotal,
      trained: lTrained,
      mastered: lMastered,
      attempts: lAttempts,
      correct: lCorrect,
    );
    final words = ZoneProgress(
      total: wordsTotal,
      trained: wTrained,
      mastered: wMastered,
      attempts: wAttempts,
      correct: wCorrect,
    );
    String? weakest;
    var worst = 2.0;
    final candidates = {'Angka': numbers, 'Huruf': letters, 'Kata': words};
    for (final entry in candidates.entries) {
      if (entry.value.trained == 0) continue;
      if (entry.value.accuracy < worst) {
        worst = entry.value.accuracy;
        weakest = entry.key;
      }
    }
    return ParentStats(
      totalNodes: 44,
      unlockedLessons: (globalUnlockedIndex - 1).clamp(0, 44),
      trainedCount: trainedCount,
      masteredCount: masteredCount,
      attemptsTotal: attemptsTotal,
      correctTotal: correctTotal,
      numbers: numbers,
      letters: letters,
      words: words,
      weakestZone: weakest,
    );
  }
}
