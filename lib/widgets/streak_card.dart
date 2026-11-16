import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/repository_providers.dart';
import '../theme/styles.dart';

class StreakCard extends ConsumerWidget {
  StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(statisticsRepositoryProvider).getCurrentStreak();

    return Container(
      decoration: BoxDecoration(
        color: Color(0x15c9a84c),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1.0, color: Color(0x44c9a84c)),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              streak.toString(),
              style: AppStyle.header.copyWith(fontSize: 24),
            ),
            Text("Days Streak!", style: AppStyle.subtitle),
          ],
        ),
      ),
    );
  }
}
