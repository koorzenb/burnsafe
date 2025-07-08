import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../burn_status_repository.dart';
import '../../models/burn_status.dart';
import '../../services/scheduler_service.dart';
import '../../services/status_bar_service.dart';
import '../../services/web_scraper_service.dart';
import 'homescreen_logic.dart';

class HomescreenController extends GetxController {
  final BurnStatusRepository _repository = Get.find();

  final Rx<BurnStatus?> currentStatus = Rx<BurnStatus?>(null);
  final RxBool isLoading = false.obs;
  final RxString nextScheduledTime = '-'.obs;

  late final StreamSubscription<BurnStatus> _statusSubscription;

  @override
  void onInit() {
    super.onInit();
    _statusSubscription = _repository.watchStatus().listen((status) {
      currentStatus.value = status;
    });

    // Load the initial status from the repository
    _loadInitialStatus();
    _updateScheduledTime();
  }

  @override
  void onClose() {
    _statusSubscription.cancel(); // Clean up the subscription
    super.onClose();
  }

  Future<void> _loadInitialStatus() async {
    isLoading.value = true;
    currentStatus.value = await _repository.getStatus();
    // If no status is in the repository, fetch it.
    if (currentStatus.value == null) {
      await fetchAndSaveStatus();
    }
    isLoading.value = false;
  }

  void _updateScheduledTime() {
    // Assuming SchedulerService provides this information.
    // This part might need adjustment based on SchedulerService's implementation.
    nextScheduledTime.value = SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];
  }

  /// Fetches the status from the web and saves it to the repository.
  Future<void> fetchAndSaveStatus() async {
    isLoading.value = true;
    try {
      final status = await WebScraperService.fetchBurnStatus();
      await _repository.saveStatus(status);
      // No need to set currentStatus.value here, the stream will do it.
    } catch (e) {
      // Handle potential errors, e.g., show a snackbar
      Get.snackbar('Error', 'Failed to fetch burn status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String get isBurningAllowedText {
    final status = currentStatus.value;

    if (status == null) {
      return 'No Burning Allowed';
    } else {
      return HomeScreenLogic.isBurningAllowed(status, DateTime.now()) ? 'Burning Allowed' : 'No Burning Allowed';
    }
  }

  Color get cardColor {
    final statusType = currentStatus.value?.statusType;
    if (statusType == BurnStatusType.restricted) {
      return Colors.yellow.shade700;
    } else if (statusType == BurnStatusType.burn) {
      return Colors.green.shade700;
    } else if (statusType == BurnStatusType.noBurn) {
      // Corrected from .none to .noBurn
      return Colors.red.shade700;
    }
    return Colors.grey.shade700; // Default color for unknown/null status
  }

  Color get cardTextColor {
    final statusType = currentStatus.value?.statusType;
    return statusType == BurnStatusType.restricted ? Colors.black87 : Colors.white;
  }
}
