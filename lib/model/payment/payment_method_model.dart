// lib/model/payment/payment_method.dart
class PaymentMethod {
  final int paymentMethodId;
  final String paymentMethodAr;
  final String paymentMethodEn;
  final String paymentMethodCode;
  final bool isDirectPayment;
  final double serviceCharge;
  final double totalAmount;
  final String? currencyIso;
  final String imageUrl;
  final bool isEmbeddedSupported;
  final String paymentCurrencyIso;

  PaymentMethod({
    required this.paymentMethodId,
    required this.paymentMethodAr,
    required this.paymentMethodEn,
    required this.paymentMethodCode,
    required this.isDirectPayment,
    required this.serviceCharge,
    required this.totalAmount,
    this.currencyIso,
    required this.imageUrl,
    required this.isEmbeddedSupported,
    required this.paymentCurrencyIso,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['PaymentMethodId'] as int,
      paymentMethodAr: json['PaymentMethodAr'] as String? ?? '',
      paymentMethodEn: json['PaymentMethodEn'] as String? ?? '',
      paymentMethodCode: json['PaymentMethodCode'] as String? ?? '',
      isDirectPayment: json['IsDirectPayment'] as bool? ?? false,
      serviceCharge: (json['ServiceCharge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
      currencyIso: json['CurrencyIso'] as String?,
      imageUrl: json['ImageUrl'] as String? ?? '',
      isEmbeddedSupported: json['IsEmbeddedSupported'] as bool? ?? false,
      paymentCurrencyIso: json['PaymentCurrencyIso'] as String? ?? '',
    );
  }

  String getDisplayName(bool isArabic) {
    return isArabic ? paymentMethodAr : paymentMethodEn;
  }
}