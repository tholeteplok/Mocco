import 'package:hive_ce/hive.dart';
import '../../domain/entities/mastery_record.dart';

/// Local Storage Data Source for Mastery Records and Linear Game Progress (Hive CE)
abstract class MasteryLocalDataSource {
  Future<void> init();
  Future<MasteryRecord?> getRecord(String id);
  Future<List<MasteryRecord>> getAllRecords();
  Future<void> saveRecord(MasteryRecord record);

  /// Linear progress tracking
  Future<int> getUnlockedNumberIndex();
  Future<void> setUnlockedNumberIndex(int index);

  Future<int> getUnlockedLetterIndex();
  Future<void> setUnlockedLetterIndex(int index);
}

class HiveMasteryLocalDataSource implements MasteryLocalDataSource {
  HiveMasteryLocalDataSource([this._customBox]);

  final Box? _customBox;
  static const String boxName = 'mocco_mastery_box';

  Box get _box => _customBox ?? Hive.box(boxName);

  @override
  Future<void> init() async {
    if (_customBox == null && !Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  @override
  Future<MasteryRecord?> getRecord(String id) async {
    final data = _box.get(id);
    if (data is Map) {
      return MasteryRecord.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<List<MasteryRecord>> getAllRecords() async {
    final list = <MasteryRecord>[];
    for (final key in _box.keys) {
      if (key is String && !key.startsWith('__system_')) {
        final data = _box.get(key);
        if (data is Map) {
          list.add(MasteryRecord.fromMap(Map<String, dynamic>.from(data)));
        }
      }
    }
    return list;
  }

  @override
  Future<void> saveRecord(MasteryRecord record) async {
    await _box.put(record.id, record.toMap());
  }

  @override
  Future<int> getUnlockedNumberIndex() async {
    return (_box.get('__system_unlocked_number') as num?)?.toInt() ?? 1;
  }

  @override
  Future<void> setUnlockedNumberIndex(int index) async {
    await _box.put('__system_unlocked_number', index);
  }

  @override
  Future<int> getUnlockedLetterIndex() async {
    return (_box.get('__system_unlocked_letter') as num?)?.toInt() ?? 1;
  }

  @override
  Future<void> setUnlockedLetterIndex(int index) async {
    await _box.put('__system_unlocked_letter', index);
  }
}
