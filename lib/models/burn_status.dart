import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class BurnStatus {
  @HiveField(0)
  final BurnStatusType statusType;

  @HiveField(1)
  final DateTime lastUpdated;

  BurnStatus({required this.statusType, required this.lastUpdated});

  String get status => statusType.displayName;
}

@HiveType(typeId: 1)
enum BurnStatusType {
  @HiveField(0)
  burn,
  @HiveField(1)
  restricted,
  @HiveField(2)
  noBurn,
  @HiveField(3)
  unknown,
}

extension BurnStatusTypeInfo on BurnStatusType {
  String get displayName {
    switch (this) {
      case BurnStatusType.burn:
        return 'Burning Allowed';
      case BurnStatusType.restricted:
        return 'Burning Restricted';
      case BurnStatusType.noBurn:
        return 'No Burning Allowed';
      default:
        return 'Unknown Status';
    }
  }

  Color get color {
    switch (this) {
      case BurnStatusType.burn:
        return Colors.green.shade700;
      case BurnStatusType.restricted:
        return Colors.yellow.shade700;
      case BurnStatusType.noBurn:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
