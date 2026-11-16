import 'package:hive_ce/hive.dart';

part 'daily_record.g.dart';

@HiveType(typeId: 1)
class DailyRecord {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String notes;

  @HiveField(2)
  final Map<int, bool> completions;

  const DailyRecord({
    required this.date,
    required this.notes,
    required this.completions,
  });

  DailyRecord copyWith({
    DateTime? date,
    String? notes,
    Map<int, bool>? completions,
  }) {
    return DailyRecord(
      date: date ?? this.date,
      notes: notes ?? this.notes,
      completions: completions ?? this.completions,
    );
  }

  bool get hasProgress => completions.values.any((completed) => completed);
}
