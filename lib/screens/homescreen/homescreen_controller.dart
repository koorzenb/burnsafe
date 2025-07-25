import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../burn_status_repository.dart';
import '../../models/burn_status.dart';
import '../../services/burn_logic_service.dart';
import '../../services/notification_service.dart';
import '../../services/scheduler_service.dart';
import '../../services/web_scraper_service.dart';

class HomescreenController extends GetxController {
  final BurnStatusRepository _repository = Get.find();
  Timer? _timer;
  final Rx<BurnStatus?> _currentStatus = Rx<BurnStatus?>(null);
  bool? _wasBurningAllowed;

  // Reactive UI Properties
  final RxBool isLoading = false.obs;
  final RxString nextScheduledTime = '-'.obs;
  final Rx<Color> backgroundColor = Rx<Color>(Colors.grey.shade700);
  final Rx<Color> textColor = Rx<Color>(Colors.white);
  final RxString isBurningAllowedText = RxString('Checking...');

  late final StreamSubscription<BurnStatus> _statusSubscription;

  @override
  void onInit() {
    super.onInit();
    _statusSubscription = _repository.watchStatus().listen((status) {
      _currentStatus.value = status;
      _updateDisplayStatus();
    });

    _loadInitialStatus();
    _updateScheduledTime();
  }

  @override
  void onReady() {
    super.onReady();
    _startTimer(); // Start the timer only when the screen is ready.
  }

  @override
  void onClose() {
    _statusSubscription.cancel();
    _timer?.cancel();
    super.onClose();
  }

  get currentStatus => _currentStatus;

  /// The core logic for updating the UI based on the current state.
  void _updateDisplayStatus() {
    final now = DateTime.now();
    final result = BurnLogicService.calculateDisplayState(
      status: _currentStatus.value,
      now: now,
      wasBurningAllowed: _wasBurningAllowed,
      getCardColor: _getCardColor,
      getCardTextColor: _getCardTextColor,
    );

    // Apply the calculated state
    isBurningAllowedText.value = result.isBurningAllowedText;
    backgroundColor.value = result.backgroundColor;
    textColor.value = result.textColor;
    _wasBurningAllowed = result.isBurningAllowed;

    // Handle side-effects
    if (result.shouldNotify) {
      NotificationService.showBurningAllowedNotification();
    }
  }

  /// Fetches the status from the web and saves it to the repository.
  Future<void> fetchAndSaveStatus([bool shouldShowNotification = true]) async {
    isLoading.value = true;
    try {
      final status = await WebScraperService.fetchBurnStatus();
      await _repository.saveStatus(status);
      // The stream listener will automatically call _updateDisplayStatus.
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch burn status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInitialStatus() async {
    isLoading.value = true;
    _currentStatus.value = await _repository.getStatus();

    if (_currentStatus.value == null) {
      await fetchAndSaveStatus();
    } else {
      _updateDisplayStatus();
    }

    isLoading.value = false;
  }

  void _startTimer() {
    // Re-evaluate the display status every 10 seconds to catch time-based changes.
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateDisplayStatus();
    });
  }

  void _updateScheduledTime() {
    nextScheduledTime.value = SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];
  }

  Color _getCardColor(BurnStatusType statusType) {
    switch (statusType) {
      case BurnStatusType.burn:
        return Colors.green.shade700;
      case BurnStatusType.restricted:
        return Colors.yellow.shade700;
      case BurnStatusType.noBurn:
        return Colors.red.shade700;
      case BurnStatusType.unknown:
        return Colors.grey.shade700;
    }
  }

  Color _getCardTextColor(BurnStatusType statusType) {
    return statusType == BurnStatusType.restricted ? Colors.black87 : Colors.white;
  }
}
