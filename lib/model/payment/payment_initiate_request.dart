/// Request model for /api/Payment/initiate
class PaymentInitiateRequest {
  final int postId;
  final List<int> qarsServiceIds;
  final num amount;
  final String customerName;
  final String email;
  final String mobile;

  PaymentInitiateRequest({
    required this.postId,
    required this.qarsServiceIds,
    required this.amount,
    required this.customerName,
    required this.email,
    required this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'qarsServiceIds': qarsServiceIds,
      'amount': amount,
      'customerName': customerName,
      'email': email,
      'mobile': mobile,
    };
  }
}
