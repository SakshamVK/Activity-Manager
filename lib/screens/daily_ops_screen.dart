import 'package:activity_manager/screens/insights_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/global_header.dart';
import 'today_tab.dart';
import 'week_tab.dart';
import 'month_tab.dart';
import 'manage_tab.dart';
import '../theme/styles.dart';

class DailyOpsScreen extends StatelessWidget {
  const DailyOpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Scaffold(
            backgroundColor: AppStyle.background,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D0F14), Color(0xFF131824)],
                    ),
                  ),
                  child: GlobalHeader(),
                ),
                Expanded(
                  child: TabBarView(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      TodayTab(),
                      InsightsScreen(),
                      MonthTab(),
                      ManageTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
