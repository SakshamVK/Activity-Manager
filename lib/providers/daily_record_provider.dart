import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_record.dart';
import '../repositories/daily_record_repository.dart';
import 'repository_providers.dart';

class DailyRecordProvider extends Notifier<DailyRecord> {
  late final DailyRecordRepository repository;
  @override
  DailyRecord build() {
    repository = ref.read(dailyRecordRepositoryProvider);

    return repository.getToday();
  }

  Future<void> saveNotes(String notes) async {
    state = state.copyWith(notes: notes);

    await repository.save(state);
  }

  Future<void> toggleCompletion(int activityId) async {
    final map = Map<int, bool>.from(state.completions);

    map[activityId] = !(map[activityId] ?? false);

    state = state.copyWith(completions: map);

    await repository.save(state);
  }

  bool isCompleted(int activityId) {
    return state.completions[activityId] ?? false;
  }
}

//   void resetForNewDay() {
//     final today = DateTime.now();

//     state = DailyRecord(
//       date: DateTime(today.year, today.month, today.day),
//       notes: '',
//       completions: {},
//     );
//   }
// }

final dailyRecordProvider = NotifierProvider<DailyRecordProvider, DailyRecord>(
  DailyRecordProvider.new,
);
