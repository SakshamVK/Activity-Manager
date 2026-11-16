import '../models/activity.dart';

List<Activity> getActivitiesByCategory(
  List<Activity> activities,
  int categoryId,
) {
  final filtered = activities.where((a) => a.categoryId == categoryId).toList();

  filtered.sort((a, b) => a.order.compareTo(b.order));

  return filtered;
}
