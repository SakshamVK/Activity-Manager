import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/day_details_data.dart';
import 'activity_provider.dart';
import 'daily_record_provider.dart';
import 'repository_providers.dart';

final dayDetailsProvider = Provider.family<DayDetailsData, DateTime>((
  ref,
  date,
) {
  ref.watch(activityProvider);
  ref.watch(dailyRecordProvider);

  final record = ref.read(dailyRecordRepositoryProvider).getByDate(date);

  return DayDetailsData(record: record, activities: const []);
});
