import 'best_day.dart';

class WeeklyStatistics {
  final double weeklyAverage;

  final int currentStreak;

  final int strongDays;

  final List<double> dailyBreakdown;

  final Map<int, double> categoryPerformance;

  final BestDay? bestDay;

  final int mostConsistentCategoryId;

  final int needsAttentionCategoryId;

  const WeeklyStatistics({
    required this.weeklyAverage,
    required this.currentStreak,
    required this.strongDays,
    required this.dailyBreakdown,
    required this.categoryPerformance,
    required this.bestDay,
    required this.mostConsistentCategoryId,
    required this.needsAttentionCategoryId,
  });
}
