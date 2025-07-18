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
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
    await scheduleDailyFetch();
  }

  static DateTime get nextScheduledTime => _target;

  static Future<void> scheduleDailyFetch([DateTime? target]) async {
    final workManager = Workmanager();
    await workManager.cancelAll();

    final now = DateTime.now();
    _target = target ?? DateTime(now.year, now.month, now.day, 14, 0);

    if (now.isAfter(_target)) {
      _target = _target.add(const Duration(days: 1));
    }

    final initialDelay = _target.difference(now);

    try {
      await workManager.registerPeriodicTask(
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
}
