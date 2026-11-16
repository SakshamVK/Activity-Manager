import 'best_day.dart';
import 'monthly_week.dart';

enum TrendDirection { up, down, flat }

class MonthlyStatistics {
  final double monthlyAverage;

  final int strongDays;

  final int perfectDays;

  final List<double> heatmap;

  final List<MonthlyWeek> weeklyTrends;

  final Map<int, double> categoryPerformance;

  final int strongestCategoryId;

  final int growthCategoryId;

  final TrendDirection trendDirection;

  final BestDay? bestDay;

  const MonthlyStatistics({
    required this.monthlyAverage,
    required this.strongDays,
    required this.perfectDays,
    required this.heatmap,
    required this.weeklyTrends,
    required this.categoryPerformance,
    required this.strongestCategoryId,
    required this.growthCategoryId,
    required this.trendDirection,
    required this.bestDay,
  });
}
