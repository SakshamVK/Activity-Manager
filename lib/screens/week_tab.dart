import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../providers/statistics_providers.dart';
import '../theme/styles.dart';

class WeekTab extends ConsumerWidget {
  const WeekTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatisticsProvider);
    final categories = ref.watch(categoriesProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: _formatPercent(stats.weeklyAverage),
                    label: 'WEEKLY AVG',
                    accentColor: AppStyle.goldLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    value: stats.currentStreak.toString(),
                    label: 'STREAK',
                    accentColor: AppStyle.goldLight,
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    value: stats.strongDays.toString(),
                    label: 'STRONG DAYS',
                    accentColor: AppStyle.goldLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'DAILY BREAKDOWN',
              style: AppStyle.header.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (index) {
                final day = _dayLabels[index];
                final percent = stats.dailyBreakdown[index];
                final isToday = index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
                    child: _DayTile(
                      label: day,
                      percent: percent,
                      highlight: isToday,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Text(
              'CATEGORY PERFORMANCE',
              style: AppStyle.header.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 10),
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryPerformanceRow(
                  title: category.title,
                  percent: stats.categoryPerformance[category.id] ?? 0,
                  color: category.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.local_fire_department_rounded,
              title: 'MOST CONSISTENT',
              message:
                  '${categories.firstWhere((c) => c.id == stats.mostConsistentCategoryId).title} at ${_formatPercent(stats.categoryPerformance[stats.mostConsistentCategoryId] ?? 0)} avg — keep it up!',
              accentColor: AppStyle.goldLight,
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.warning_amber_rounded,
              title: 'NEEDS ATTENTION',
              message:
                  '${categories.firstWhere((c) => c.id == stats.needsAttentionCategoryId).title} at ${_formatPercent(stats.categoryPerformance[stats.needsAttentionCategoryId] ?? 0)} — prioritise this category this week.',
              accentColor: AppStyle.yellow,
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.emoji_events_rounded,
              title: 'BEST DAY',
              message: stats.bestDay == null
                  ? 'No completed day yet this week.'
                  : '${_formatBestDay(stats.bestDay!.date)} — ${_formatPercent(stats.bestDay!.completion)} completion',
              accentColor: AppStyle.goldLight,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }

  // category name lookup is performed via the provider in build

  static String _formatBestDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, $month ${date.day}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.accentColor,
    this.icon,
  });

  final String value;
  final String label;
  final Color accentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyle.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, color: AppStyle.goldLight, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppStyle.textDim,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.label,
    required this.percent,
    required this.highlight,
  });

  final String label;
  final double percent;
  final bool highlight;

  Color get _tileColor {
    if (percent >= 0.8) {
      return AppStyle.green;
    }

    if (percent >= 0.2) {
      return AppStyle.gold;
    }

    return AppStyle.border;
  }

  @override
  Widget build(BuildContext context) {
    final tileColor = _tileColor;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: tileColor.withValues(
          alpha: tileColor == AppStyle.border ? 0.18 : 0.16,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: tileColor.withValues(alpha: 0.7)),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppStyle.green.withValues(alpha: 0.16),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppStyle.textDim,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(percent * 100).round()}%',
            style: TextStyle(
              color: tileColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPerformanceRow extends StatelessWidget {
  const _CategoryPerformanceRow({
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
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
