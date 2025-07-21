import 'package:flutter/material.dart';

import '../../models/burn_status.dart';

/// A stateless service providing core business logic for burn rules.
class BurnLogicService {
  /// Determines if burning is currently allowed based on the status and time.
  /// This is a pure function with no side effects.
  @visibleForTesting
  static bool isBurningAllowed(BurnStatus currentStatus, DateTime now) {
    final today8am = DateTime(now.year, now.month, now.day, 8);
    final today2pm = DateTime(now.year, now.month, now.day, 14);
    final today7pm = DateTime(now.year, now.month, now.day, 19);
    bool isAllowed = false;

    // Before 8 AM: Allowed if status is Burn or Restricted.
    if (now.isBefore(today8am)) {
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    } else if (!now.isBefore(today8am) && now.isBefore(today2pm)) {
      /*8 AM to 2 PM: Never allowed.*/
      isAllowed = false;
      print('Burning is not allowed between 8am and 2pm. Current status is ${currentStatus.statusType}');
    } else if (!now.isBefore(today2pm) && now.isBefore(today7pm)) /*2 PM to 7 PM: Only allowed if status is Burn.*/ {
      isAllowed = currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    } else /*After 7 PM: Allowed if status is Burn or Restricted */ {
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} after 7pm. Current status is ${currentStatus.statusType}');
    }

    return isAllowed;
  }

  /// Calculates the display state based on the current burn status and time.
  ///  [wasBurningAllowed] represent the previous day's state of burning allowance. This is used to determine if a notification should be sent for the current day.
  static ({String isBurningAllowedText, Color backgroundColor, Color textColor, bool isBurningAllowed, bool shouldNotify}) calculateDisplayState({
    required BurnStatus? status,
    required DateTime now,
    required bool? wasBurningAllowed,
    required Color Function(BurnStatusType statusType) getCardColor,
    required Color Function(BurnStatusType statusType) getCardTextColor,
  }) {
    if (status == null) {
      return (
        isBurningAllowedText: 'Status Unknown',
        backgroundColor: Colors.grey.shade700,
        textColor: Colors.white,
        isBurningAllowed: false,
        shouldNotify: false,
      );
    }

    final isAllowed = isBurningAllowed(status, now);
    final shouldNotify = wasBurningAllowed == false && isAllowed == true;

    return (
      isBurningAllowedText: isAllowed ? 'Burning Allowed' : 'No Burning Allowed',
      backgroundColor: getCardColor(status.statusType),
      textColor: getCardTextColor(status.statusType),
      isBurningAllowed: isAllowed,
      shouldNotify: shouldNotify,
    );
  }
}
