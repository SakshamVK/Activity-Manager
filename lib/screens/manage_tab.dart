import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import '../models/category.dart';
import '../providers/activity_provider.dart';
import '../providers/category_provider.dart';
import '../theme/styles.dart';
import '../widgets/activity_dialog.dart';
import '../widgets/activity_manage_tile.dart';

class ManageTab extends ConsumerWidget {
  const ManageTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityProvider);
    final categories = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 14, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 2)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showActivityDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.gold,
                foregroundColor: AppStyle.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CategorySection(
                category: category,
                activities: _activitiesForCategory(activities, category.id),
                onEdit: (activity) =>
                    _showActivityDialog(context, activity: activity),
                onDelete: (activity) => _confirmDelete(context, ref, activity),
                onReorder: (oldIndex, newIndex, categoryActivities) {
                  _reorderCategory(
                    ref,
                    category.id,
                    oldIndex,
                    newIndex,
                    categoryActivities,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Activity> _activitiesForCategory(
    List<Activity> activities,
    int categoryId,
  ) {
    final filtered = activities
        .where((activity) => activity.categoryId == categoryId)
        .toList();
    filtered.sort((a, b) => a.order.compareTo(b.order));
    return filtered;
  }

  Future<void> _showActivityDialog(
    BuildContext context, {
    Activity? activity,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ActivityDialog(activity: activity),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppStyle.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Activity?',
            style: TextStyle(color: AppStyle.text, fontWeight: FontWeight.w700),
          ),
          content: Text(
            activity.title,
            style: const TextStyle(color: AppStyle.textDim),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.red,
                foregroundColor: AppStyle.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final notifier = ref.read(activityProvider.notifier);
    await notifier.deleteActivity(activity.id);

    final remainingActivities = ref.read(activityProvider);
    final oldCategoryActivities =
        remainingActivities
            .where((item) => item.categoryId == activity.categoryId)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    if (oldCategoryActivities.isNotEmpty) {
      await notifier.reorderCategory(oldCategoryActivities);
    }
  }

  Future<void> _reorderCategory(
    WidgetRef ref,
    int categoryId,
    int oldIndex,
    int newIndex,
    List<Activity> activities,
  ) async {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final reordered = List<Activity>.from(activities);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    await ref.read(activityProvider.notifier).reorderCategory(reordered);
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.activities,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final ActivityCategory category;
  final List<Activity> activities;
  final ValueChanged<Activity> onEdit;
  final ValueChanged<Activity> onDelete;
  final void Function(int oldIndex, int newIndex, List<Activity> activities)
  onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: category.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: TextStyle(
                  color: category.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'No activities yet.',
                style: TextStyle(color: AppStyle.textMuted, fontSize: 13),
              ),
            )
          else
            ReorderableListView.builder(
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 8,
                          shadowColor: Colors.black54,
                          child: child,
                        );
                      },
                    );
                  },
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: activities.length,
              onReorder: (oldIndex, newIndex) {
                onReorder(oldIndex, newIndex, activities);
              },
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityManageTile(
                  key: ValueKey(activity.id),
                  activity: activity,
                  index: index,
                  onEdit: () => onEdit(activity),
                  onDelete: () => onDelete(activity),
                );
              },
            ),
        ],
      ),
    );
  }
}
