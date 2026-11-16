import 'package:hive_ce/hive.dart';

import '../database/hive_service.dart';
import '../models/activity.dart';

class ActivityRepository {
  final Box<Activity> _box = HiveService.activityBox;

  List<Activity> getAll() {
    final activities = _box.values.toList();

    activities.sort((a, b) {
      if (a.categoryId != b.categoryId) {
        return a.categoryId.compareTo(b.categoryId);
      }
      return a.order.compareTo(b.order);
    });

    return activities;
  }

  Future<void> add(Activity activity) async {
    await _box.put(activity.id, activity);
  }

  Future<void> update(Activity activity) async {
    await _box.put(activity.id, activity);
  }

  Future<void> delete(int id) async {
    await _box.delete(id);
  }

  Future<void> reorderCategory(List<Activity> reordered) async {
    for (int i = 0; i < reordered.length; i++) {
      final updated = reordered[i].copyWith(order: i);

      await _box.put(updated.id, updated);
    }
  }
}
