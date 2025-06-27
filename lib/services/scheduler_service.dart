import 'dart:convert';

import 'package:burnsafe/services/status_bar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/burn_status.dart';
import 'notification_service.dart';
import 'web_scraper_service.dart';

class SchedulerService {
  static const String _taskName = 'burnStatusCheck';
  static const String _lastStatusKey = 'lastBurnStatus';
  static DateTime _target = DateTime.now();

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await scheduleDaily2PMCheck();
  }

  static Future<void> scheduleDaily2PMCheck() async {
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _getInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 9, 51); // 2 PM

    if (now.isAfter(target)) {
      // If it's already past 2 PM today, schedule for 2 PM tomorrow
      return target.add(const Duration(days: 1)).difference(now);
    } else {
      // Schedule for 2 PM today
      return target.difference(now);
    }
  }

  static Future<void> checkBurnStatus() async {
    final status = await WebScraperService.fetchBurnStatus();
    if (status != null) {
      final prefs = await SharedPreferences.getInstance();
      final lastStatusJson = prefs.getString(_lastStatusKey);

      BurnStatus? lastStatus;
      if (lastStatusJson != null) {
        lastStatus = BurnStatus.fromJson(jsonDecode(lastStatusJson));
      }

      // Update status bar with smart notifications (includes both persistent status and dismissible alert)
      await StatusBarService.updateStatusBar(status, lastStatus);

      // Save current status
      await prefs.setString(_lastStatusKey, jsonEncode(status.toJson()));
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == SchedulerService._taskName) {
      await SchedulerService.checkBurnStatus();
    }
    return Future.value(true);
  });
}
