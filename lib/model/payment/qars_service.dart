class QarsService {
  final int qarsServiceId;
  final String qarsServiceName;
  final num qarsServicePrice;
  final String qarsServiceType;

  QarsService({
    required this.qarsServiceId,
    required this.qarsServiceName,
    required this.qarsServicePrice,
    required this.qarsServiceType,
  });

  factory QarsService.fromJson(Map<String, dynamic> json) {
    return QarsService(
      qarsServiceId: json['qarsServiceId'] as int,
      qarsServiceName: json['qarsServiceName'] as String,
      qarsServicePrice: json['qarsServicePrice'] as num,
      qarsServiceType: json['qarsServiceType'] as String,
    );
  }
}
