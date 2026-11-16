import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_search_result.dart';

final historySearchProvider =
        Provider.family<List<HistorySearchResult>, String>((ref, query) {
    // Return an empty list by default to satisfy non-nullable return type.
    return const <HistorySearchResult>[];
});
