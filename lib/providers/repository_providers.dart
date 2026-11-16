import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/activity_repository.dart';
import '../repositories/daily_record_repository.dart';
import '../repositories/statistics_repository.dart';
import 'category_provider.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return DailyRecordRepository();
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(
    activityRepository: ref.read(activityRepositoryProvider),
    dailyRecordRepository: ref.read(dailyRecordRepositoryProvider),
    categories: ref.read(categoriesProvider),
  );
});
