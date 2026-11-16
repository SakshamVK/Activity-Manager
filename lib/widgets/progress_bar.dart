import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../providers/activity_provider.dart';
import '../theme/styles.dart';

class ProgressBar extends ConsumerWidget {
  final int categoryId;
  final double height;

  const ProgressBar({super.key, required this.categoryId, this.height = 8});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double progress;
    final Color fillColor;

    if (categoryId == 0) {
      final overallProgress = ref.watch(overallProgressProvider);
      progress = overallProgress.percent / 100;
      fillColor = AppStyle.gold;
    } else {
      final categories = ref.watch(categoriesProvider);
      final category = categories.firstWhere(
        (category) => category.id == categoryId,
        orElse: () => categories.first,
      );
      progress = ref
          .read(activityProvider.notifier)
          .categoryProgress(categoryId);
      fillColor = category.color;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 72;

        return SizedBox(
          width: effectiveWidth,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFF1A2238)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: fillColor),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
