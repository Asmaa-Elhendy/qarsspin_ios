/// Request model for /api/Payment/initiate
class PaymentInitiateRequest {
  final num amount;
  final String customerName;
  final String email;
  final String mobile;

  PaymentInitiateRequest({
    required this.amount,
    required this.customerName,
    required this.email,
    required this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'customerName': customerName,
      'email': email,
      'mobile': mobile,
    };
  }
}
