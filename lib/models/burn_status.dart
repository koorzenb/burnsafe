class BurnStatus {
  final BurnStatusType _statusType;
  final DateTime lastUpdated;

  BurnStatus({required BurnStatusType statusType, required this.lastUpdated}) : _statusType = statusType;

  // Constructor from string for backward compatibility
  BurnStatus.fromString({required String status, required this.lastUpdated}) : _statusType = _parseStatusFromString(status);

  BurnStatusType get statusType => _statusType;

  String get status {
    switch (_statusType) {
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

  static BurnStatusType _parseStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'status-burn':
      case 'burning allowed':
        return BurnStatusType.burn;
      case 'status-restricted':
      case 'burning restricted':
        return BurnStatusType.restricted;
      case 'status-no-burn':
      case 'no burning allowed':
        return BurnStatusType.noBurn;
      default:
        return BurnStatusType.unknown;
    }
  }

  // TODO: only used for converting for persistence purposes. when persisting, can rather use the enum value
  String get _statusString {
    switch (_statusType) {
      case BurnStatusType.burn:
        return 'status-burn';
      case BurnStatusType.restricted:
        return 'status-restricted';
      case BurnStatusType.noBurn:
        return 'status-no-burn';
      case BurnStatusType.unknown:
        return 'unknown';
    }
  }

  factory BurnStatus.fromJson(Map<String, dynamic> json) {
    return BurnStatus.fromString(status: json['status'], lastUpdated: DateTime.parse(json['lastUpdated']));
  }

  Map<String, dynamic> toJson() {
    return {'status': _statusString, 'lastUpdated': lastUpdated.toIso8601String()};
  }
}

enum BurnStatusType { burn, restricted, noBurn, unknown }
