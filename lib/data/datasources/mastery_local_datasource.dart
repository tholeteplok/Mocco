import 'package:hive_ce/hive.dart';
import '../../domain/entities/mastery_record.dart';
import '../../domain/services/mastery_engine.dart';

/// Local Storage Data Source for Mastery Records and Linear Game Progress (Hive CE)
abstract class MasteryLocalDataSource {
  Future<void> init();
  Future<MasteryRecord?> getRecord(String id);
  Future<List<MasteryRecord>> getAllRecords();
  Future<void> saveRecord(MasteryRecord record);

  /// Records session result aggregating attempts and correct answers.
  /// Automatically applies Leitner 5-box Spaced Repetition logic.
  Future<void> recordSessionResult({
    required String id,
    required int attempts,
    required int correct,
    DateTime? timestamp,
  });

  /// Linear progress tracking (legacy — per-zone)
  Future<int> getUnlockedNumberIndex();
  Future<void> setUnlockedNumberIndex(int index);

  Future<int> getUnlockedLetterIndex();
  Future<void> setUnlockedLetterIndex(int index);

  Future<int> getUnlockedWordIndex();
  Future<void> setUnlockedWordIndex(int index);

  /// Global journey node index (sumber kebenaran utama untuk JourneyScreen).
  /// Nilai 1 = node pertama (Angka 1) aktif.
  Future<int> getGlobalUnlockedIndex();
  Future<void> setGlobalUnlockedIndex(int index);
}

class HiveMasteryLocalDataSource implements MasteryLocalDataSource {
  HiveMasteryLocalDataSource([this._customBox]);

  final Box? _customBox;
  static const String boxName = 'mocco_mastery_box';

  Box? get _boxSafe {
    if (_customBox != null) return _customBox;
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> init() async {
    if (_customBox != null) return;
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (_) {
      // Safe fallback if Hive is not initialized (e.g. during headless tests)
    }
  }

  @override
  Future<MasteryRecord?> getRecord(String id) async {
    final box = _boxSafe;
    if (box == null) return null;
    try {
      final data = box.get(id);
      if (data is Map) {
        return MasteryRecord.fromMap(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<MasteryRecord>> getAllRecords() async {
    final box = _boxSafe;
    if (box == null) return [];
    final list = <MasteryRecord>[];
    try {
      for (final key in box.keys) {
        if (key is String && !key.startsWith('__system_')) {
          final data = box.get(key);
          if (data is Map) {
            list.add(MasteryRecord.fromMap(Map<String, dynamic>.from(data)));
          }
        }
      }
    } catch (_) {}
    return list;
  }

  @override
  Future<void> saveRecord(MasteryRecord record) async {
    final box = _boxSafe;
    if (box == null) return;
    try {
      await box.put(record.id, record.toMap());
    } catch (_) {}
  }

  @override
  Future<int> getUnlockedNumberIndex() async {
    final box = _boxSafe;
    if (box == null) return 1;
    try {
      return (box.get('__system_unlocked_number') as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  @override
  Future<void> setUnlockedNumberIndex(int index) async {
    final box = _boxSafe;
    if (box == null) return;
    try {
      await box.put('__system_unlocked_number', index);
    } catch (_) {}
  }

  @override
  Future<int> getUnlockedLetterIndex() async {
    final box = _boxSafe;
    if (box == null) return 1;
    try {
      return (box.get('__system_unlocked_letter') as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  @override
  Future<void> setUnlockedLetterIndex(int index) async {
    final box = _boxSafe;
    if (box == null) return;
    try {
      await box.put('__system_unlocked_letter', index);
    } catch (_) {}
  }

  @override
  Future<int> getUnlockedWordIndex() async {
    final box = _boxSafe;
    if (box == null) return 1;
    try {
      return (box.get('__system_unlocked_word') as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  @override
  Future<void> setUnlockedWordIndex(int index) async {
    final box = _boxSafe;
    if (box == null) return;
    try {
      await box.put('__system_unlocked_word', index);
    } catch (_) {}
  }

  @override
  Future<int> getGlobalUnlockedIndex() async {
    final box = _boxSafe;
    if (box == null) return 1;
    try {
      return (box.get('__system_global_node') as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  @override
  Future<void> setGlobalUnlockedIndex(int index) async {
    final box = _boxSafe;
    if (box == null) return;
    try {
      await box.put('__system_global_node', index);
    } catch (_) {}
  }

  @override
  Future<void> recordSessionResult({
    required String id,
    required int attempts,
    required int correct,
    DateTime? timestamp,
  }) async {
    await init();
    if (_boxSafe == null) return;
    final existing = await getRecord(id) ?? MasteryRecord(id: id);
    final now = timestamp ?? DateTime.now();
    const engine = MasteryEngine();

    var updated = existing;
    final incorrect = (attempts - correct).clamp(0, attempts);

    // Apply correct answers (promoting Leitner box)
    for (int i = 0; i < correct; i++) {
      updated = engine.recordResult(updated, true, timestamp: now);
    }
    // Apply incorrect attempts (soft demoting Leitner box)
    for (int i = 0; i < incorrect; i++) {
      updated = engine.recordResult(updated, false, timestamp: now);
    }

    await saveRecord(updated);
  }
}

/// In-memory implementation of MasteryLocalDataSource for tests and environments without disk access.
class InMemoryMasteryLocalDataSource implements MasteryLocalDataSource {
  final Map<String, MasteryRecord> _records = {};
  int _unlockedNumber = 1;
  int _unlockedLetter = 1;
  int _unlockedWord = 1;
  int _globalUnlocked = 1;

  @override
  Future<void> init() async {}

  @override
  Future<MasteryRecord?> getRecord(String id) async => _records[id];

  @override
  Future<List<MasteryRecord>> getAllRecords() async => _records.values.toList();

  @override
  Future<void> saveRecord(MasteryRecord record) async {
    _records[record.id] = record;
  }

  @override
  Future<int> getUnlockedNumberIndex() async => _unlockedNumber;

  @override
  Future<void> setUnlockedNumberIndex(int index) async => _unlockedNumber = index;

  @override
  Future<int> getUnlockedLetterIndex() async => _unlockedLetter;

  @override
  Future<void> setUnlockedLetterIndex(int index) async => _unlockedLetter = index;

  @override
  Future<int> getUnlockedWordIndex() async => _unlockedWord;

  @override
  Future<void> setUnlockedWordIndex(int index) async => _unlockedWord = index;

  @override
  Future<int> getGlobalUnlockedIndex() async => _globalUnlocked;

  @override
  Future<void> setGlobalUnlockedIndex(int index) async => _globalUnlocked = index;

  @override
  Future<void> recordSessionResult({
    required String id,
    required int attempts,
    required int correct,
    DateTime? timestamp,
  }) async {
    final existing = await getRecord(id) ?? MasteryRecord(id: id);
    final now = timestamp ?? DateTime.now();
    const engine = MasteryEngine();

    var updated = existing;
    final incorrect = (attempts - correct).clamp(0, attempts);

    for (int i = 0; i < correct; i++) {
      updated = engine.recordResult(updated, true, timestamp: now);
    }
    for (int i = 0; i < incorrect; i++) {
      updated = engine.recordResult(updated, false, timestamp: now);
    }

    await saveRecord(updated);
  }
}

