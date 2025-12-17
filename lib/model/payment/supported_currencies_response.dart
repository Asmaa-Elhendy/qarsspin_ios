import 'dart:convert';

/// Model for /api/Payment/supported-currencies response
class SupportedCurrenciesResponse {
  final String environment;
  final List<String> currencies;

  SupportedCurrenciesResponse({
    required this.environment,
    required this.currencies,
  });

  factory SupportedCurrenciesResponse.fromJson(Map<String, dynamic> json) {
    return SupportedCurrenciesResponse(
      environment: json['environment'] as String,
      currencies: (json['currencies'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  static SupportedCurrenciesResponse fromJsonString(String source) {
    return SupportedCurrenciesResponse.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}
