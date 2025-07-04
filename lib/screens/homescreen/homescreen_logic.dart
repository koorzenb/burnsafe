import 'package:burnsafe/models/burn_status.dart';

class HomeScreenLogic {
  BurnStatus? _currentStatus;

  get currentStatus => _currentStatus;

  static bool isBurningAllowed(BurnStatus currentStatus, DateTime now) {
    // if condition that is time based: if it is between 7pm the previous day and 8am the current day, return _currentStatus
    final today8am = DateTime(now.year, now.month, now.day, 8);
    final today2pm = DateTime(now.year, now.month, now.day, 14);
    final today7pm = DateTime(now.year, now.month, now.day, 19);

    if (now.isBefore(today8am)) /* is before 8am*/ {
      return currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
    } else if (!now.isBefore(today8am) && now.isBefore(today2pm)) /* is between 8am and 2pm */ {
      return false;
    } else if (!now.isBefore(today2pm) && now.isBefore(today7pm)) /* is between 2pm and 7pm */ {
      return currentStatus.statusType == BurnStatusType.burn;
    } else /* is after 7pm */ {
      return currentStatus.statusType == BurnStatusType.restricted || currentStatus.statusType == BurnStatusType.burn;
    }
  }
}
