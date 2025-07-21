import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'background_task_handler.dart';

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Native called background task: $task');
    // All background tasks will now go through the handler
    return await BackgroundTaskHandler.fetchAndSaveStatus();
  });
}

class SchedulerService {
  static const String _taskName = 'burnStatusCheck';
  static DateTime _target = DateTime.now();

  static Future<void> initialize() async {
    print('Initializing WorkManager...');

    if (kDebugMode) {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: true,
      ); // this creates a workmanager and defines the callback dispatcher, but no recurring task has yet been created
      await scheduleOnceOffTask(); // for testing purposes, we can schedule a one-off task
    } else {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: false,
      ); // this creates a workmanager and defines the callback dispatcher, but no recurring task has yet been created
      await scheduleDailyFetch(); // this schedules the recurring task
    }
  }

  static DateTime get nextScheduledTime => _target;

  static Future<void> scheduleDailyFetch([DateTime? target]) async {
    await Workmanager().cancelAll();

    final now = DateTime.now();
    _target = target ?? DateTime(now.year, now.month, now.day, 14, 0);

    if (now.isAfter(_target)) {
      _target = _target.add(const Duration(days: 1));
    }

    final initialDelay = _target.difference(now);

    try {
      await Workmanager().registerPeriodicTask(
        'daily_2pm_check',
        _taskName,
        frequency: const Duration(days: 1),
        initialDelay: initialDelay.inMinutes > 15 ? initialDelay : const Duration(hours: 24),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
        backoffPolicy: BackoffPolicy.linear,
      );

      print('Daily 2 PM task scheduled successfully');
      print('Next execution: $_target');
    } catch (e) {
      print('Error scheduling daily task: $e');
    }
  }

  static Future<void> scheduleOnceOffTask() async {
    await Workmanager().cancelAll();

    final now = DateTime.now();
    print('Now: $now');
    final plusFifteenSeconds = now.add(const Duration(seconds: 15));
    _target = DateTime(now.year, now.month, now.day, now.hour, now.minute, plusFifteenSeconds.second);
    print('Target: $_target');

    final initialDelay = _target.difference(now);
    print('Initial delay: $initialDelay');

    try {
      await Workmanager().registerOneOffTask(
        'once_off_task',
        'once_off_task',
        initialDelay: initialDelay,
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
        backoffPolicy: BackoffPolicy.linear,
      );

      print('Once off task scheduled successfully');
      print('Next execution: ${_target}');
    } catch (e) {
      print('Error scheduling daily task: $e');
    }
  }
}
