import 'package:flutter/material.dart';

import 'screens/homescreen.dart';
import 'services/notification_service.dart';
import 'services/scheduler_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.initialize();
  await SchedulerService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurnSafe Nova Scotia',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
