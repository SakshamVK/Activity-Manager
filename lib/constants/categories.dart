import 'package:activity_manager/theme/styles.dart';
import '../models/category.dart';

class Categories {
  static const ActivityCategory dailyActivities = ActivityCategory(
    id: 1,
    title: 'DAILY ACTIVITIES',
    color: AppStyle.blue,
  );
  static const ActivityCategory food = ActivityCategory(
    id: 2,
    title: 'FOOD',
    color: AppStyle.green,
  );
  static const ActivityCategory physicalActivities = ActivityCategory(
    id: 3,
    title: 'PHYSICAL ACTIVITIES',
    color: AppStyle.red,
  );
  static const ActivityCategory mentalWellness = ActivityCategory(
    id: 4,
    title: 'MENTAL WELLNESS',
    color: AppStyle.purple,
  );
  static const ActivityCategory study = ActivityCategory(
    id: 5,
    title: 'STUDY',
    color: AppStyle.yellow,
  );

  static const List<ActivityCategory> all = [
    dailyActivities,
    food,
    physicalActivities,
    mentalWellness,
    study,
  ];

  static ActivityCategory fromId(int id) {
    return all.firstWhere((category) => category.id == id);
  }
}
