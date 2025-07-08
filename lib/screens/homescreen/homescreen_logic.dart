import '../../models/burn_status.dart';

class HomeScreenLogic {
  BurnStatus? _currentStatus;

  get currentStatus => _currentStatus;

  static bool isBurningAllowed(BurnStatus currentStatus, DateTime now) {
    // if condition that is time based: if it is between 7pm the previous day and 8am the current day, return _currentStatus
    final today8am = DateTime(now.year, now.month, now.day, 8);
    final today2pm = DateTime(now.year, now.month, now.day, 14);
    final today7pm = DateTime(now.year, now.month, now.day, 19);
    bool isAllowed = false;

    if (now.isBefore(today8am)) /* is before 8am*/ {
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    } else if (!now.isBefore(today8am) && now.isBefore(today2pm)) /* is between 8am and 2pm */ {
      isAllowed = false;
      print('Burning is not allowed between 8am and 2pm. Current status is ${currentStatus.statusType}');
    } else if (!now.isBefore(today2pm) && now.isBefore(today7pm)) /* is between 2pm and 7pm */ {
      isAllowed = currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} before 8am. Current status is ${currentStatus.statusType}');
    } else /* is after 7pm */ {
      isAllowed = currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
      print('Burning is ${isAllowed ? "allowed" : "not allowed"} after 7pm. Current status is ${currentStatus.statusType}');
    }

    return isAllowed;
  }
}
