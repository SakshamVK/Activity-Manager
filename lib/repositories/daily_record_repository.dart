import '../database/hive_service.dart';
import '../models/daily_record.dart';

class DailyRecordRepository {
  final box = HiveService.dailyRecordBox;

  String _key(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  DailyRecord getToday() {
    return getByDate(DateTime.now()) ?? createToday();
  }

  DailyRecord? getByDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    return box.get(_key(normalized));
  }

  DailyRecord createToday() {
    final today = DateTime.now();

    final normalized = DateTime(today.year, today.month, today.day);

    final record = DailyRecord(date: normalized, notes: '', completions: {});

    box.put(_key(normalized), record);

    return record;
  }

  Future<void> save(DailyRecord record) async {
    await box.put(_key(record.date), record);
  }

  List<DailyRecord> getAll() {
    final records = box.values.toList();

    records.sort((a, b) => b.date.compareTo(a.date));

    return records;
  }

  List<DailyRecord> getRecent({int limit = 30}) {
    return getAll().take(limit).toList();
  }

  List<DailyRecord> getRecordsBetween(DateTime start, DateTime end) {
    return box.values.where((record) {
      return !record.date.isBefore(start) && !record.date.isAfter(end);
    }).toList();
  }

  List<DailyRecord> searchNotes(String query) {
    final lower = query.toLowerCase();

    return getAll()
        .where((record) => record.notes.toLowerCase().contains(lower))
        .toList();
  }

  List<DailyRecord> getCurrentWeek() {
    final today = DateTime.now();

    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));

    final sunday = monday.add(const Duration(days: 6));

    return getRecordsBetween(monday, sunday);
  }
}
