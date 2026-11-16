import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/activity_provider.dart';
import '../providers/daily_record_provider.dart';
import '../theme/styles.dart';
import 'progress_bar.dart';
import '../providers/category_provider.dart';

class ActivitySection extends ConsumerWidget {
  final int categoryId;

  const ActivitySection({super.key, required this.categoryId});

  // category lookup will be done in build using the provider

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref
        .watch(activityProvider)
        .where((activity) => activity.categoryId == categoryId)
        .toList();
    final categories = ref.watch(categoriesProvider);
    final matchedCategory = categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => categories.first,
    );
    final progress = ref
        .read(activityProvider.notifier)
        .categoryProgress(categoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: matchedCategory.color, width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
            color: matchedCategory.color.withValues(alpha: 0.08),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  matchedCategory.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: matchedCategory.color,
                  ),
                ),
                Row(
                  children: [
                    ProgressBar(categoryId: categoryId),
                    const SizedBox(width: 4.0),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(color: matchedCategory.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...activities.map(
          (activity) => CheckboxListTile(
            activeColor: AppStyle.surface,
            tileColor: AppStyle.surface,
            title: Text(activity.title, style: TextStyle(color: AppStyle.text)),
            value:
                ref.watch(dailyRecordProvider).completions[activity.id] ??
                false,
            onChanged: (_) {
              ref
                  .read(dailyRecordProvider.notifier)
                  .toggleCompletion(activity.id);
            },
          ),
        ),

        const SizedBox(height: 14),
      ],
    );
  }
}
