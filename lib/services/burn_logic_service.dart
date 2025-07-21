import '../../models/burn_status.dart';

/// A stateless service providing core business logic for burn rules.
class BurnLogicService {
  /// Determines if burning is currently allowed based on the status and time.
  /// This is a pure function with no side effects.
  static bool isBurningAllowed(BurnStatus currentStatus, DateTime now) {
    final today8am = DateTime(now.year, now.month, now.day, 8);
    final today2pm = DateTime(now.year, now.month, now.day, 14);
    final today7pm = DateTime(now.year, now.month, now.day, 19);
    bool isAllowed = false;

    // Before 8 AM: Allowed if status is Burn or Restricted.
    if (now.isBefore(today8am)) {
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    }
    // 8 AM to 2 PM: Never allowed.
    if (now.isBefore(today2pm)) {
      isAllowed = false;
      print('Burning is not allowed between 8am and 2pm. Current status is ${currentStatus.statusType}');
    }
    // 2 PM to 7 PM: Only allowed if status is Burn.
    if (now.isBefore(today7pm)) {
      isAllowed = currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    } else {
      // After 7 PM: Allowed if status is Burn or Restricted.
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} after 7pm. Current status is ${currentStatus.statusType}');
    }

    return isAllowed;
  }
}
