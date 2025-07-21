import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'burn_status_repository.dart';
import 'models/burn_status.dart';
import 'screens/homescreen/homescreen.dart';
import 'screens/homescreen/homescreen_controller.dart';
import 'services/notification_service.dart';
import 'services/scheduler_service.dart';
import 'storage/burn_status_adapter.dart';
import 'storage/burn_status_hive_repository.dart';
import 'storage/burn_status_type_adapter.dart';

void main() async {
  await _init();
  runApp(const MyApp());
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BurnStatusAdapter());
  Hive.registerAdapter(BurnStatusTypeAdapter());
  final burnStatusBox = await Hive.openBox<BurnStatus>('burnStatusBox');
  Get.lazyPut<BurnStatusRepository>(() => BurnStatusHiveRepository(burnStatusBox));
  await NotificationService.initialize();
  await SchedulerService.initialize();
  Get.put(HomescreenController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BurnSafe Nova Scotia',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
      home: HomeScreen(),
    );
  }
}
