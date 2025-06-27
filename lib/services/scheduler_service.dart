import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'web_scraper_service.dart';
import 'notification_service.dart';
import '../models/burn_status.dart';

class SchedulerService {
  static const String _taskName = 'burnStatusCheck';
  static const String _lastStatusKey = 'lastBurnStatus';

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
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 14, 0); // 2 PM
    
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

      // Always send notification for daily check, but highlight if status changed
      if (lastStatus == null || lastStatus.status != status.status) {
        await NotificationService.showBurnStatusNotification(status);
      } else {
        // Send daily update even if status hasn't changed
        await NotificationService.showBurnStatusNotification(status);
      }

      // Save the current status
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