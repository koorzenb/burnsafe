import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../burn_status_repository.dart';
import '../../models/burn_status.dart';
import '../../services/scheduler_service.dart';
import '../../services/web_scraper_service.dart';
import 'burn_logic_service.dart';

class HomescreenController extends GetxController {
  final BurnStatusRepository _repository = Get.find();
  Timer? _timer;
  final Rx<BurnStatus?> currentStatus = Rx<BurnStatus?>(null);
  final RxBool isLoading = false.obs;
  final RxString nextScheduledTime = '-'.obs;
  Rx<Color> backgroundColor = Rx<Color>(Colors.grey.shade700);
  Rx<Color> textColor = Rx<Color>(Colors.grey.shade700);
  Rx<String> isBurningAllowedText = Rx<String>('Fetching data... ');

  late final StreamSubscription<BurnStatus> _statusSubscription;

  @override
  void onInit() {
    super.onInit();
    _statusSubscription = _repository.watchStatus().listen((status) {
      currentStatus.value = status;
    });

    _loadInitialStatus();
    _updateScheduledTime();
  }

  @override
  void onReady() {
    super.onReady();
    _startTimer();
  }

  @override
  void onClose() {
    _statusSubscription.cancel();
    _timer?.cancel();
    super.onClose();
  }

  /// Fetches the status from the web and saves it to the repository.
  Future<void> fetchAndSaveStatus() async {
    isLoading.value = true;
    try {
      final status = await WebScraperService.fetchBurnStatus();
      await _repository.saveStatus(status);
      // No need to set currentStatus.value here, the stream will do it.
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch burn status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInitialStatus() async {
    isLoading.value = true;
    currentStatus.value = await _repository.getStatus();

    if (currentStatus.value == null) {
      await fetchAndSaveStatus();
    }

    isLoading.value = false;
  }

  void _updateUI() {
    backgroundColor.value = _getCardColor();
    textColor.value = _getCardTextColor();
    isBurningAllowedText.value = _getIsBurningAllowedText();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updateUI();
    });
  }

  void _updateScheduledTime() {
    nextScheduledTime.value = SchedulerService.nextScheduledTime.toLocal().toString().split('.')[0];
  }

  String _getIsBurningAllowedText() {
    final status = currentStatus.value;

    if (status == null) {
      return 'No Burning Allowed';
    } else {
      return BurnLogicService.isBurningAllowed(status, DateTime.now()) ? 'Burning Allowed' : 'No Burning Allowed';
    }
  }

  Color _getCardColor() {
    final statusType = currentStatus.value?.statusType;

    if (statusType == BurnStatusType.restricted) {
      return Colors.yellow.shade700;
    } else if (statusType == BurnStatusType.burn) {
      return Colors.green.shade700;
    } else if (statusType == BurnStatusType.noBurn) {
      return Colors.red.shade700;
    }
    return Colors.grey.shade700;
  }

  Color _getCardTextColor() {
    final statusType = currentStatus.value?.statusType;
    return statusType == BurnStatusType.restricted ? Colors.black87 : Colors.white;
  }
}
