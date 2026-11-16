import '../providers/activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progress_bar.dart';
import '../theme/styles.dart';

class ProgressWidget extends ConsumerStatefulWidget {
  const ProgressWidget({super.key});

  @override
  ConsumerState<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends ConsumerState<ProgressWidget> {
  @override
  Widget build(BuildContext context) {
    final overallProgress = ref.watch(overallProgressProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${overallProgress.percent}', style: AppStyle.header),
                    Text('%', style: AppStyle.subtitle.copyWith(fontSize: 18)),
                  ],
                ),
                Text(
                  '${overallProgress.tasksDone}/${overallProgress.totalTasks} DONE',
                  style: AppStyle.subtitle,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressBar(categoryId: 0),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ProgressBar(categoryId: 1, height: 4),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ProgressBar(categoryId: 2, height: 4),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ProgressBar(categoryId: 3, height: 4),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ProgressBar(categoryId: 4, height: 4),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ProgressBar(categoryId: 5, height: 4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
