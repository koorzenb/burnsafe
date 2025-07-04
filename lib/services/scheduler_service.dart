import 'package:burnsafe/screens/homescreen/homescreen_controller.dart';
import 'package:workmanager/workmanager.dart';

class SchedulerService {
  static const String _taskName = 'burnStatusCheck';
  static DateTime _target = DateTime.now();

  static Future<void> initialize() async {
    print('Initializing WorkManager...');
    await scheduleDailyCheck();
  }

  static DateTime get nextScheduledTime => _target;

  static Future<void> scheduleDailyFetch([DateTime? target]) async {
    // Cancel all previous tasks
    await Workmanager().cancelAll();

    final now = DateTime.now();
    _target = target ?? DateTime(now.year, now.month, now.day, 14, 01);

    if (now.isAfter(_target)) {
      // If it's already past 2 PM today, schedule for 2 PM tomorrow
      _target = _target.add(const Duration(days: 1));
    }

    final initialDelay = _target.difference(now);

    try {
      // Schedule one-off task for the next 2 PM
      if (initialDelay.inMinutes < 15) {
        await Workmanager().registerOneOffTask(
          'daily_2pm_check',
          _taskName, // Use 'burnStatusCheck'
          initialDelay: initialDelay,
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
      }

      // Schedule periodic task for subsequent days (starts 24 hours from now)
      await Workmanager().registerPeriodicTask(
        'daily_periodic',
        _taskName,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay.inMinutes > 15 ? initialDelay : const Duration(hours: 24),
        constraints: Constraints(networkType: NetworkType.connected, requiresBatteryNotLow: false),
      );

      print('Daily 2 PM task scheduled successfully');
      print('Next execution: $_target');
    } catch (e) {
      print('Error scheduling daily task: $e');
    }
  }
}
