import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/categories.dart';
import '../models/category.dart';

final categoriesProvider = Provider<List<ActivityCategory>>((ref) {
  return Categories.all;
});
