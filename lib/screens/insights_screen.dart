import 'package:flutter/material.dart';

import 'week_tab.dart';
import 'month_tab.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          body: Expanded(child: TabBarView(children: [WeekTab(), MonthTab()])),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
