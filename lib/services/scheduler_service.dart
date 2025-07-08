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

  static Future<void> _schedulePeriodicHomescreenRefresh() async {
    // create smaller periodic tasks that does a screen update at 8am, 2pm, 2:02pm and 7pm
    try {
      await Workmanager().registerPeriodicTask(
        'homescreen_refresh_8am',
        'homescreen_refresh_8am', // TODO: consider general task type here for all tasks
        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelayForTime(8, 0),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );

      await Workmanager().registerPeriodicTask(
        'homescreen_pause_2pm',
        'homescreen_pause_2pm',

        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelayForTime(14, 0),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );

      await Workmanager().registerPeriodicTask(
        'my_periodic_task',
        'my_periodic_task',
        frequency: const Duration(hours: 24),
        initialDelay: Duration(minutes: 15, seconds: 30),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );
      print('Periodic refresh job task scheduled for ${DateTime.now().add(const Duration(minutes: 15, seconds: 30))}');

      await Workmanager().registerOneOffTask(
        'my_once_off_task',
        'my_once_off_task',
        initialDelay: Duration(seconds: 30),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );
      print('One-off refresh job task scheduled for ${DateTime.now().add(const Duration(seconds: 30))}');

      await Workmanager().registerPeriodicTask(
        'homescreen_refresh_2_03pm',
        'homescreen_refresh_2_03pm',
        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelayForTime(14, 2),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );

      await Workmanager().registerPeriodicTask(
        'homescreen_refresh_7pm',
        'homescreen_refresh_7pm',
        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelayForTime(19, 0),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );

      print('Periodic (refresh) tasks scheduled successfully');
    } catch (e) {
      print('Error scheduling periodic homescreen refresh tasks: $e');
    }
  }

  static Duration _getInitialDelayForTime(int hour, int minute) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, hour, minute);

    if (now.isAfter(target)) {
      // If the target time has already passed today, schedule for tomorrow
      return target.add(const Duration(days: 1)).difference(now);
    } else {
      return target.difference(now);
    }
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final instance = Get.find<HomescreenController>();
    if (task == 'homescreen_refresh_8am' || task == 'homescreen_refresh_2_03pm' || task == 'homescreen_refresh_7pm') {
      await instance.onPeriodicUpdate();
      print('Homescreen refreshed at ${DateTime.now()}');
    }

    if (task == 'homescreen_pause_2pm') {
      instance.onPauseStatus();
      print('Homescreen paused at ${DateTime.now()}');
    }

    if (task == 'my_periodic_task' || task == 'my_once_off_task') {
      await instance.fetchCurrentStatus();
      // await instance.onPeriodicUpdate();
      print('Refresh executed at ${DateTime.now()}');
    }

    if (task == 'once_off_2pm_check' || task == 'daily_2pm_check') {
      await WebScraperService.fetchBurnStatus();
      print('Fetching of burn status executed at ${DateTime.now()}');
    }

    return Future.value(true);
  });
}
