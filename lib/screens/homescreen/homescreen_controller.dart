import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/burn_status.dart';
import '../../services/scheduler_service.dart';
import '../../services/web_scraper_service.dart';

class HomescreenController extends GetxController {
  BurnStatus? _currentStatus;
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

  BurnStatus? get currentStatus => _currentStatus;
  bool get isLoading => _isLoading;
  String get nextScheduledTime => _nextScheduledTime ?? SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];

  Future<void> fetchCurrentStatus() async {
    _isLoading = true;
    update();
    _currentStatus = await WebScraperService.fetchBurnStatus();
    _isLoading = false;
    update();
  }

  Future<void> rescheduleTask() async {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, now.hour, now.minute + 16);
    await SchedulerService.scheduleDailyCheck(target);
    _nextScheduledTime = SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Task rescheduled ${target.hour}:${target.minute}!')));
  }
}
