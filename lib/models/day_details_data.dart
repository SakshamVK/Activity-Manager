import 'activity.dart';
import 'daily_record.dart';

class DayDetailsData {
  final DailyRecord? record;

  final List<Activity> activities;

  const DayDetailsData({required this.record, required this.activities});
}
