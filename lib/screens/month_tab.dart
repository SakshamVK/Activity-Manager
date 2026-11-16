import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../providers/statistics_providers.dart';
import '../theme/styles.dart';

class MonthTab extends ConsumerWidget {
  const MonthTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatisticsProvider);
    final categories = ref.watch(categoriesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 14.0,
        left: 12,
        right: 12,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: _MetricCard(
                    value: _formatPercent(stats.monthlyAverage),
                    label: 'MONTHLY AVG',
                    accentColor: AppStyle.goldLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: _MetricCard(
                    value: stats.strongDays.toString(),
                    label: 'STRONG DAYS',
                    accentColor: AppStyle.goldLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: _MetricCard(
                    value: stats.perfectDays.toString(),
                    label: 'PERFECT DAYS',
                    accentColor: AppStyle.goldLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('30-DAY HEATMAP', style: AppStyle.header.copyWith(fontSize: 17)),
          const SizedBox(height: 10),
          _HeatmapGrid(values: stats.heatmap),
          const SizedBox(height: 18),
          Text('WEEKLY TREND', style: AppStyle.header.copyWith(fontSize: 17)),
          const SizedBox(height: 10),
          _WeeklyTrend(weeks: stats.weeklyTrends),
          const SizedBox(height: 18),
          Text(
            'CATEGORY AVERAGES',
            style: AppStyle.header.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryRow(
                title: c.title,
                percent: stats.categoryPerformance[c.id] ?? 0,
                color: c.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.trending_up,
            title: 'TRENDING UP',
            message: _trendingMessage(stats.weeklyTrends),
            accentColor: AppStyle.goldLight,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.emoji_events_rounded,
            title: 'STRONGEST CATEGORY',
            message:
                '${categories.firstWhere((x) => x.id == stats.strongestCategoryId).title} averaged ${_formatPercent(stats.categoryPerformance[stats.strongestCategoryId] ?? 0)} this month.',
            accentColor: AppStyle.goldLight,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.lightbulb,
            title: 'GROWTH AREA',
            message:
                '${categories.firstWhere((x) => x.id == stats.growthCategoryId).title} averaged ${_formatPercent(stats.categoryPerformance[stats.growthCategoryId] ?? 0)} — one small habit change can shift this.',
            accentColor: AppStyle.yellow,
          ),
        ],
      ),
    );
  }

  static String _formatPercent(double value) => '${(value * 100).round()}%';

  static String _trendingMessage(List weekly) {
    if (weekly.isEmpty) return 'No trend data available.';
    final first = (weekly.first.average * 100).round();
    final last = (weekly.last.average * 100).round();
    return 'Improved from $first% (W1) to $last% (W${weekly.length}) — great momentum!';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyle.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppStyle.textDim,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.values});

  final List<double> values;

  Color _colorFor(double v) {
    if (v >= 0.8) return AppStyle.goldLight;
    if (v >= 0.4) return AppStyle.gold;
    if (v > 0) return AppStyle.surface2;
    return AppStyle.border;
  }

  @override
  Widget build(BuildContext context) {
    final count = values.length;
    final cols = 7;
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: cols,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 1.6,
      children: List.generate(count, (i) {
        final val = values[i];
        final color = _colorFor(val);
        return Container(
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: color == AppStyle.border ? 0.18 : 0.18,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color: color == AppStyle.border ? AppStyle.textDim : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WeeklyTrend extends StatelessWidget {
  const _WeeklyTrend({required this.weeks});

  final List weeks;

  @override
  Widget build(BuildContext context) {
    final max = weeks
        .map((w) => w.average as double)
        .fold<double>(0, (p, e) => e > p ? e : p);
    final maxFactor = (max <= 0) ? 1.0 : max;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weeks.length, (i) {
        final week = weeks[i];
        final value = (week.average as double);
        final pct = (value * 100).round();
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  color: AppStyle.goldLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 90,
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: (maxFactor == 0) ? 0 : (value / maxFactor),
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppStyle.goldLight, AppStyle.gold],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox.shrink(),
              Text(
                'W${i + 1}',
                style: const TextStyle(
                  color: AppStyle.textDim,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.percent,
    required this.color,
  });

  final String title;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppStyle.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppStyle.surface2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppStyle.text,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
