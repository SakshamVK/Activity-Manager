import 'package:flutter/material.dart';
import 'package:activity_manager/screens/daily_ops_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DailyOpsScreen(),
    );
  }
}
