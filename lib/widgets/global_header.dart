import 'progress_widget.dart';
import 'package:flutter/material.dart';
import 'streak_card.dart';
import 'package:intl/intl.dart';
import '../theme/styles.dart';

class GlobalHeader extends StatefulWidget {
  const GlobalHeader({super.key});

  @override
  State<GlobalHeader> createState() => _GlobalHeaderState();
}

class _GlobalHeaderState extends State<GlobalHeader> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Daily Ops", style: AppStyle.header),
                    Text(
                      DateFormat(
                        "EEE, MMM d",
                      ).format(DateTime.now()).toUpperCase(),
                      style: AppStyle.subtitle,
                    ),
                  ],
                ),
                StreakCard(),
              ],
            ),
            const SizedBox(height: 8),
            const ProgressWidget(),
            const TabBar(
              tabs: [
                Tab(text: "TODAY"),
                Tab(text: "WEEK"),
                Tab(text: "MONTH"),
                Tab(text: "MANAGE"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
