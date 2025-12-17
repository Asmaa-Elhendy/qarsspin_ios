/// Request model for /api/Payment/execute
class PaymentExecuteRequest {
  final num amount;
  final String customerName;
  final String email;
  final String mobile;
  final int paymentMethodId;
  final String returnUrl;

  PaymentExecuteRequest({
    required this.amount,
    required this.customerName,
    required this.email,
    required this.mobile,
    required this.paymentMethodId,
    required this.returnUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'customerName': customerName,
      'email': email,
      'mobile': mobile,
      'paymentMethodId': paymentMethodId,
      'returnUrl': returnUrl,
    };
  }
}
