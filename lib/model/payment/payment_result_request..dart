/// Query model for /api/Payment/payment-result
class PaymentResultRequest {
  final String paymentId;
  final String status;

  PaymentResultRequest({
    required this.paymentId,
    required this.status,
  });

  Map<String, String> toQueryParameters() {
    return {
      'paymentId': paymentId,
      'status': status,
    };
  }
}
