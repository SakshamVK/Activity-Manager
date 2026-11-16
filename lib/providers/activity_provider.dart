import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import 'daily_record_provider.dart';
import '../repositories/activity_repository.dart';
import 'repository_providers.dart';

// final activityRepositoryProvider = Provider((ref) => ActivityRepository());

class ActivityProvider extends Notifier<List<Activity>> {
  late final ActivityRepository repository;

  @override
  List<Activity> build() {
    repository = ref.read(activityRepositoryProvider);
    return repository.getAll();
  }

  Future<void> addActivity(Activity activity) async {
    await repository.add(activity);

    state = repository.getAll();
  }

  Future<void> deleteActivity(int id) async {
    await repository.delete(id);

    state = repository.getAll();
  }

  Future<void> editActivity({
    required int id,
    required String title,
    required int categoryId,
    required int order,
  }) async {
    final activity = Activity(
      id: id,
      title: title,
      categoryId: categoryId,
      order: order,
    );

    await repository.update(activity);

    state = repository.getAll();
  }

  Future<void> toggleActivity(int id) async {
    await ref.read(dailyRecordProvider.notifier).toggleCompletion(id);
  }

  double categoryProgress(int categoryId) {
    final categoryActivities = state
        .where((activity) => activity.categoryId == categoryId)
        .toList();
    final total = categoryActivities.length;

    if (total == 0) return 0;

    final record = ref.read(dailyRecordProvider);
    final categoryActivityIds = categoryActivities
        .map((activity) => activity.id)
        .toSet();
    final completed = record.completions.entries
        .where(
          (entry) => categoryActivityIds.contains(entry.key) && entry.value,
        )
        .length;

    return completed / total;
  }

  Future<void> reorderCategory(List<Activity> reordered) async {
    await repository.reorderCategory(reordered);

    state = repository.getAll();
  }
}

final activityProvider = NotifierProvider<ActivityProvider, List<Activity>>(
  ActivityProvider.new,
);

final overallProgressProvider =
    Provider<({int percent, int tasksDone, int totalTasks})>((ref) {
      final activities = ref.watch(activityProvider);
      final record = ref.watch(dailyRecordProvider);
      final totalTasks = activities.length;
      final activityIds = activities.map((activity) => activity.id).toSet();
      final completed = record.completions.entries
          .where((entry) => activityIds.contains(entry.key) && entry.value)
          .length;
      final percent = totalTasks == 0
          ? 0
          : ((completed / totalTasks) * 100).round();

      return (percent: percent, tasksDone: completed, totalTasks: totalTasks);
    });
