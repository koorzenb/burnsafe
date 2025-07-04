import 'package:burnsafe/screens/homescreen/homescreen_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/burn_status.dart';
import '../../services/scheduler_service.dart';
import '../../services/web_scraper_service.dart';

class HomescreenController extends GetxController {
  BurnStatus _currentStatus = BurnStatus(statusType: BurnStatusType.unknown, lastUpdated: DateTime.now());
  bool _isLoading = false;
  String? _nextScheduledTime;

  static HomescreenController get getOrPut {
    try {
      return Get.find<HomescreenController>();
    } catch (e) {
      return Get.put(HomescreenController._());
    }
  }

  HomescreenController._() {}

  /// currentStatus is updated daily at 2pm or when the user logs in the first time. This value therefor represents the status since the last update
  BurnStatus get currentStatus => _currentStatus;
  String get isBurningAllowed => HomeScreenLogic.isBurningAllowed(_currentStatus, DateTime.now()) ? 'Burning Allowed' : 'No Burning Allowed';

  bool get isLoading => _isLoading;
  String get nextScheduledTime => _nextScheduledTime ?? SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];

  Future<void> fetchCurrentStatus() async {
    _isLoading = true;
    update();
    _currentStatus = await WebScraperService.fetchBurnStatus(); // do not persist. Program can either fetch status online or return unknown if the user cannot connect
    _isLoading = false;
    update();
  }

  Future<void> rescheduleNotification() async {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, now.hour, now.minute + 16);
    await SchedulerService.scheduleDailyFetch(target);
    _nextScheduledTime = SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Task rescheduled ${target.hour}:${target.minute}!')));
    update();
  }
}
