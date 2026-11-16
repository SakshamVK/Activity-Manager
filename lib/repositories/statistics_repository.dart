import '../models/category.dart';
import '../models/best_day.dart';
import '../models/daily_record.dart';
import '../models/monthly_statistics.dart';
import '../models/weekly_statistics.dart';
import '../models/monthly_week.dart';
import 'activity_repository.dart';
import 'daily_record_repository.dart';

class StatisticsRepository {
  final ActivityRepository _activityRepository;
  final DailyRecordRepository _dailyRepository;
  final List<ActivityCategory> _categories;

  StatisticsRepository({
    required ActivityRepository activityRepository,
    required DailyRecordRepository dailyRecordRepository,
    required List<ActivityCategory> categories,
  })  : _activityRepository = activityRepository,
       _dailyRepository = dailyRecordRepository,
       _categories = categories;

  WeeklyStatistics getCurrentWeekStatistics() {
    final today = DateTime.now();

    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));

    final sunday = monday.add(const Duration(days: 6));

    final breakdown = _breakdown(monday, sunday);
    final categoryPerformance = _categoryPerformance(monday, sunday);

    return WeeklyStatistics(
      weeklyAverage: _average(breakdown),

      currentStreak: getCurrentWeekStreak(today, monday),

      strongDays: _strongDays(breakdown),

      dailyBreakdown: breakdown,

      categoryPerformance: categoryPerformance,

      bestDay: _bestDay(breakdown, monday),

      mostConsistentCategoryId: _mostConsistentCategory(categoryPerformance),

      needsAttentionCategoryId: _needsAttentionCategory(categoryPerformance),
    );
  }

  MonthlyStatistics getCurrentMonthStatistics() {
    final today = DateTime.now();

    final firstDay = DateTime(today.year, today.month, 1);

    final lastDay = DateTime(today.year, today.month + 1, 0);

    final breakdown = _breakdown(firstDay, lastDay);

    final categoryPerformance = _categoryPerformance(firstDay, lastDay);

    final weeks = _weeklySummaries();

    return MonthlyStatistics(
      monthlyAverage: _average(breakdown),

      strongDays: _strongDays(breakdown),

      perfectDays: _perfectDays(breakdown),

      heatmap: breakdown,

      weeklyTrends: weeks,

      categoryPerformance: categoryPerformance,

      strongestCategoryId: _mostConsistentCategory(categoryPerformance),

      growthCategoryId: _needsAttentionCategory(categoryPerformance),

      trendDirection: _trendDirection(weeks),

      bestDay: _bestDay(breakdown, firstDay),
    );
  }

  int getCurrentStreak() {
    final today = DateTime.now();

    int streak = 0;

    DateTime currentDay = DateTime(today.year, today.month, today.day);

    while (true) {
      final record = _dailyRepository.getByDate(currentDay);

      if (record == null) {
        break;
      }

      final completed = record.completions.values.any((e) => e);

      if (!completed) {
        break;
      }

      streak++;

      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Returns the current streak but only counts days from the start of
  /// the current week (Monday) — it resets on Monday.
  int getCurrentWeekStreak(DateTime today, DateTime monday) {
    int streak = 0;

    DateTime currentDay = DateTime(today.year, today.month, today.day);

    while (!currentDay.isBefore(monday)) {
      final record = _dailyRepository.getByDate(currentDay);

      if (record == null) {
        break;
      }

      final completed = record.completions.values.any((e) => e);

      if (!completed) {
        break;
      }

      streak++;

      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  double _dayCompletion(DailyRecord record, int totalActivities) {
    if (totalActivities == 0) {
      return 0;
    }

    final completed = record.completions.values.where((e) => e).length;

    return completed / totalActivities;
  }

  List<double> _breakdown(DateTime start, DateTime end) {
    final totalActivities = _activityRepository.getAll().length;

    final breakdown = <double>[];

    DateTime current = DateTime(start.year, start.month, start.day);

    while (!current.isAfter(end)) {
      final record = _dailyRepository.getByDate(current);

      if (record == null) {
        breakdown.add(0);
      } else {
        breakdown.add(_dayCompletion(record, totalActivities));
      }

      current = current.add(const Duration(days: 1));
    }

    return breakdown;
  }

  double _average(List<double> breakdown) {
    if (breakdown.isEmpty) {
      return 0;
    }

    final sum = breakdown.fold(0.0, (total, value) => total + value);

    return sum / breakdown.length;
  }

  int _strongDays(List<double> breakdown) {
    return breakdown.where((day) => day >= 0.8).length;
  }

  BestDay? _bestDay(List<double> breakdown, DateTime startDate) {
    if (breakdown.every((e) => e == 0)) {
      return null;
    }

    int best = 0;

    for (int i = 1; i < breakdown.length; i++) {
      if (breakdown[i] > breakdown[best]) {
        best = i;
      }
    }

    return BestDay(
      date: startDate.add(Duration(days: best)),
      completion: breakdown[best],
    );
  }

  int _perfectDays(List<double> breakdown) {
    return breakdown.where((e) => e >= 1.0).length;
  }

  Map<int, double> _categoryPerformance(DateTime start, DateTime end) {
    final activities = _activityRepository.getAll();

    final records = _dailyRepository.getRecordsBetween(start, end);

    final performance = <int, double>{};

    for (final category in _categories) {
      final categoryActivities = activities
          .where((activity) => activity.categoryId == category.id)
          .toList();

      if (categoryActivities.isEmpty) {
        performance[category.id] = 0;
        continue;
      }

      int completed = 0;
      int total = 0;

      for (final record in records) {
        for (final activity in categoryActivities) {
          total++;

          if (record.completions[activity.id] == true) {
            completed++;
          }
        }
      }

      performance[category.id] = total == 0 ? 0 : completed / total;
    }

    return performance;
  }

  List<MonthlyWeek> _weeklySummaries() {
    final today = DateTime.now();

    final firstDay = DateTime(today.year, today.month, 1);

    final lastDay = DateTime(today.year, today.month + 1, 0);

    final summaries = <MonthlyWeek>[];

    DateTime currentStart = firstDay;

    while (!currentStart.isAfter(lastDay)) {
      DateTime currentEnd = currentStart.add(
        Duration(days: 6 - (currentStart.weekday - 1)),
      );

      if (currentEnd.isAfter(lastDay)) {
        currentEnd = lastDay;
      }

      final breakdown = _breakdown(currentStart, currentEnd);

      final average = breakdown.isEmpty
          ? 0.0
          : breakdown.reduce((a, b) => a + b) / breakdown.length;

      summaries.add(
        MonthlyWeek(start: currentStart, end: currentEnd, average: average),
      );

      currentStart = currentEnd.add(const Duration(days: 1));
    }

    return summaries;
  }

  int _mostConsistentCategory(Map<int, double> performance) {
    int bestId = _categories.first.id;

    double bestValue = -1;

    performance.forEach((id, value) {
      if (value > bestValue) {
        bestValue = value;
        bestId = id;
      }
    });

    return bestId;
  }

  int _needsAttentionCategory(Map<int, double> performance) {
    int worstId = _categories.first.id;

    double worstValue = 2;

    performance.forEach((id, value) {
      if (value < worstValue) {
        worstValue = value;
        worstId = id;
      }
    });

    return worstId;
  }

  TrendDirection _trendDirection(List<MonthlyWeek> weeks) {
    if (weeks.length < 2) {
      return TrendDirection.flat;
    }

    final first = weeks.first.average;
    final last = weeks.last.average;

    if (last > first) {
      return TrendDirection.up;
    }

    if (last < first) {
      return TrendDirection.down;
    }

    return TrendDirection.flat;
  }
}
