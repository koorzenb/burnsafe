import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class BurnStatus {
  @HiveField(0)
  final BurnStatusType statusType;

  @HiveField(1)
  final DateTime lastUpdated;

  BurnStatus({required this.statusType, required this.lastUpdated});

  String get status {
    switch (statusType) {
      case BurnStatusType.burn:
        return 'Burning Allowed';
      case BurnStatusType.restricted:
        return 'Burning Restricted';
      case BurnStatusType.noBurn:
        return 'No Burning Allowed';
      case BurnStatusType.unknown:
        return 'Unknown Status';
    }
  }
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
