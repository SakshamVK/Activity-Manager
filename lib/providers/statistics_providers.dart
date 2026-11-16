import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monthly_statistics.dart';
import '../models/weekly_statistics.dart';
import 'activity_provider.dart';
import 'daily_record_provider.dart';
import 'repository_providers.dart';

final weeklyStatisticsProvider = Provider<WeeklyStatistics>((ref) {
  // Establish dependencies so this provider recomputes
  ref.watch(activityProvider);
  ref.watch(dailyRecordProvider);

  return ref.read(statisticsRepositoryProvider).getCurrentWeekStatistics();
});

final monthlyStatisticsProvider = Provider<MonthlyStatistics>((ref) {
  // Recompute whenever activities change
  ref.watch(activityProvider);

  // Recompute whenever today's DailyRecord changes
  ref.watch(dailyRecordProvider);

  return ref.read(statisticsRepositoryProvider).getCurrentMonthStatistics();
});
