/// Request model for /api/Payment/execute
class PaymentExecuteRequest {
  final int orderMasterId;
  final int paymentMethodId;
  final String returnUrl;

  PaymentExecuteRequest({
    required this.orderMasterId,
    required this.paymentMethodId,
    required this.returnUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'ordermasterId': orderMasterId,
      'paymentMethodId': paymentMethodId,
      'returnUrl': returnUrl,
    };
  }
}
