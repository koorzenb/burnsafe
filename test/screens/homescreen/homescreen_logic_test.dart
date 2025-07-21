import 'package:burnsafe/models/burn_status.dart';
import 'package:burnsafe/screens/homescreen/burn_logic_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('homescreen logic ...', () {
    final startOfDay = DateTime(2025, 01, 01);
    final DateTime today8am = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 8);
    final DateTime today2pm = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 14);
    final DateTime today7pm = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 19);

    test('should return currentStatus before 8am', () {
      final previousDay = DateTime(startOfDay.year, startOfDay.month, startOfDay.day - 1, 14);
      final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: previousDay);

      bool isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, DateTime(startOfDay.year, startOfDay.month, startOfDay.day));
      expect(isBurningAllowed, isTrue, reason: 'Should return whatever the current status is before 8am');

      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today8am.subtract(Duration(minutes: 1)));
      expect(isBurningAllowed, isTrue, reason: 'Should return whatever the current status is before 8am');
    });

    test('should return false between 8am and 2pm', () {
      final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today8am);

      bool isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today8am);
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning between 8am and 2pm');

      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today2pm.subtract(Duration(seconds: 1)));
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning between 8am and 2pm');
    });

    test('should return true after 2pm and before 7pm and burnStatus is burn', () {
      final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: today2pm);

      bool isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today2pm);
      expect(isBurningAllowed, isTrue, reason: 'Should allow burning after 2pm and before 7pm if status is burn');

      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today7pm.subtract(Duration(seconds: 1)));
      expect(isBurningAllowed, isTrue, reason: 'Should allow burning after 2pm and before 7pm if status is burn');
    });

    test('should return false after 2pm and before 7pm and burnStatus is restricted or noBurn', () {
      final currentStatusRestricted = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
      final currentStatusNoBurn = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);

      bool isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatusRestricted, today2pm);
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning after 2pm and before 7pm if status is restricted');
      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatusNoBurn, today2pm);
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning after 2pm and before 7pm if status is restricted');

      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatusRestricted, today7pm.subtract(Duration(seconds: 1)));
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning after 2pm and before 7pm if status is noBurn');
      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatusNoBurn, today7pm.subtract(Duration(seconds: 1)));
      expect(isBurningAllowed, isFalse, reason: 'Should not allow burning after 2pm and before 7pm if status is noBurn');
    });

    test('should return currentStatus after 7pm', () {
      BurnStatus currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
      bool isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, today7pm);
      expect(isBurningAllowed, isTrue, reason: 'Should return whatever the current status is before 8am');

      currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);
      isBurningAllowed = BurnLogicService.isBurningAllowed(currentStatus, startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1))); // end of day
      expect(isBurningAllowed, isFalse, reason: 'Should return whatever the current status is before 8am');
    });
  });
}
