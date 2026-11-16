import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_record.dart';
import 'daily_record_provider.dart';
import 'repository_providers.dart';

final historyProvider = Provider<List<DailyRecord>>((ref) {
  ref.watch(dailyRecordProvider); // refresh trigger

  return ref.read(dailyRecordRepositoryProvider).getRecent();
});
