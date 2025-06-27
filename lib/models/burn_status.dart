class BurnStatus {
  final String status;
  final DateTime lastUpdated;

  BurnStatus({
    required this.status,
    required this.lastUpdated,
  });

  factory BurnStatus.fromJson(Map<String, dynamic> json) {
    return BurnStatus(
      status: json['status'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}