import 'package:hive_ce_flutter/hive_flutter.dart';

import '../constants/default_activities.dart';
import '../models/activity.dart';
import '../models/daily_record.dart';

class HiveService {
  static const String activityBoxName = 'activities';
  static const String dailyRecordBoxName = 'daily_records';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ActivityAdapter());
    Hive.registerAdapter(DailyRecordAdapter());

    await Hive.openBox<Activity>(activityBoxName);
    await Hive.openBox<DailyRecord>(dailyRecordBoxName);

    await _seedDefaultActivities();
  }

  static Future<void> _seedDefaultActivities() async {
    final activityBox = Hive.box<Activity>(activityBoxName);

    if (activityBox.isEmpty) {
      for (final activity in defaultActivities) {
        await activityBox.put(activity.id, activity);
      }
    }
  }

  static Box<Activity> get activityBox => Hive.box<Activity>(activityBoxName);

  static Box<DailyRecord> get dailyRecordBox =>
      Hive.box<DailyRecord>(dailyRecordBoxName);
}
