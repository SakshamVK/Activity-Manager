import 'activity.dart';
import 'daily_record.dart';

class HistorySearchResult {
  final DailyRecord record;

  final List<Activity> matchedActivities;

  const HistorySearchResult({
    required this.record,
    required this.matchedActivities,
  });
}
