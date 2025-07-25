import 'package:burnsafe/models/burn_status.dart';
import 'package:burnsafe/services/burn_logic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startOfDay = DateTime(2025, 01, 01);
  final DateTime today8am = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 8);
  final DateTime today2pm = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 14);
  final DateTime today7pm = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 19);
  group('homescreen logic ...', () {
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

  group('BurnLogicService.calculateDisplayState', () {
    Color fakeCardColor(BurnStatusType type) {
      switch (type) {
        case BurnStatusType.burn:
          return Colors.green;
        case BurnStatusType.restricted:
          return Colors.orange;
        case BurnStatusType.noBurn:
          return Colors.red;
        case BurnStatusType.unknown:
          return Colors.grey;
      }
    }

    Color fakeCardTextColor(BurnStatusType type) => Colors.white;

    test('Returns Status Unknown if status is null', () {
      final result = BurnLogicService.calculateDisplayState(
        status: null,
        now: DateTime.now(),
        wasBurningAllowed: null,
        getCardColor: fakeCardColor,
        getCardTextColor: fakeCardTextColor,
      );
      expect(result.isBurningAllowedText, 'Status Unknown');
      expect(result.backgroundColor, Colors.grey.shade700);
      expect(result.textColor, Colors.white);
      expect(result.isBurningAllowed, isFalse);
      expect(result.shouldNotify, isFalse);
    });

    group('at 8am', () {
      test('status is "noBurn", now is before 8am, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is before 8am, wasBurningAllowed is true', () {
        // not a valid scenario, since wasBurningAllowed is true and updates only occur after 2pm
      });

      test('status is "noBurn", now is at 8am, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is at 8am, wasBurningAllowed is true', () {
        // not a valid scenario, since wasBurningAllowed is true and updates only occur after 2pm
      });

      test('status is "restricted", now is before 8am, wasBurningAllowed is false', () {
        // not a valid scenario, since wasBurningAllowed is false and updates only occur after 2pm
      });

      test('status is "restricted", now is before 8am, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am.subtract(Duration(seconds: 1)),
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is at 8am, wasBurningAllowed is false', () {
        // not a valid scenario, since wasBurningAllowed is false and updates only occur after 2pm
      });

      test('status is "restricted", now is at 8am, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is before 8am, wasBurningAllowed is false', () {
        // not a valid scenario, since wasBurningAllowed is false and updates only occur after 2pm
      });

      test('status is "burn", now is before 8am, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am.subtract(Duration(seconds: 1)),
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is at 8am, wasBurningAllowed is false', () {
        // not a valid scenario, since wasBurningAllowed is false and updates only occur after 2pm
      });

      test('status is "burn", now is at 8am, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today8am,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });
    });

    group('at 2pm', () {
      test('status is "noBurn", now is before 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is before 2pm, wasBurningAllowed is true', () {
        // not a valid scenario, since wasBurningAllowed is true and updates only occur after 2pm
      });

      test('status is "noBurn", now is at 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is at 2pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is before 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is before 2pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is at 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is at 2pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is before 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is before 2pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: startOfDay);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is at 2pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isTrue);
      });

      test('status is "burn", now is at 2pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today2pm,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isFalse);
      });
    });

    group('at 7pm', () {
      test('status is "noBurn", now is before 7pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is before 7pm, wasBurningAllowed is true', () {
        // not a valid scenario, since wasBurningAllowed is true and update already occurred at 2pm
      });

      test('status is "noBurn", now is at 7pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.noBurn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.red);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "noBurn", now is at 7pm, wasBurningAllowed is true', () {
        // not a valid scenario, since wasBurningAllowed is true and update already occurred at 2pm
      });

      test('status is "restricted", now is before 7pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'No Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isFalse);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "restricted", now is before 7pm, wasBurningAllowed is true', () {
        // not a valid scenario, no burning allowed between 2pm and 7pm, wasBurningAllowed could not have been set to true
      });

      test('status is "restricted", now is at 7pm, wasBurningAllowed is false', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.restricted, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm,
          wasBurningAllowed: false,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.orange);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isTrue);
      });

      test('status is "restricted", now is at 7pm, wasBurningAllowed is true', () {
        // not a valid scenario, no burning allowed between 2pm and 7pm, wasBurningAllowed could not have been set to true
      });

      test('status is "burn", now is before 7pm, wasBurningAllowed is false', () {
        // not a valid scenario. wasBurningAllowed would have been set to true at 2pm
      });

      test('status is "burn", now is before 7pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm.subtract(Duration(seconds: 1)),
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isFalse);
      });

      test('status is "burn", now is at 7pm, wasBurningAllowed is false', () {
        // not a valid scenario, wasBurningAllowed would have been set to true at 2pm
      });

      test('status is "burn", now is at 7pm, wasBurningAllowed is true', () {
        final currentStatus = BurnStatus(statusType: BurnStatusType.burn, lastUpdated: today2pm);
        final result = BurnLogicService.calculateDisplayState(
          status: currentStatus,
          now: today7pm,
          wasBurningAllowed: true,
          getCardColor: fakeCardColor,
          getCardTextColor: fakeCardTextColor,
        );

        expect(result.isBurningAllowedText, 'Burning Allowed');
        expect(result.backgroundColor, Colors.green);
        expect(result.textColor, Colors.white);
        expect(result.isBurningAllowed, isTrue);
        expect(result.shouldNotify, isFalse);
      });
    });
  });
}
