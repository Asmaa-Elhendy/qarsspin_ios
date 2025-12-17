/// Query model for /api/Payment/test-status
class PaymentTestStatusRequest {
  final String paymentId;
  final bool isTest;

  PaymentTestStatusRequest({
    required this.paymentId,
    required this.isTest,
  });

  Map<String, String> toQueryParameters() {
    return {
      'paymentId': paymentId,
      'isTest': isTest.toString(), // "true" / "false"
    };
  }
}
