import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:qarsspin/model/payment/supported_currencies_response.dart';
import 'package:qarsspin/model/payment/payment_initiate_request.dart';
import 'package:qarsspin/model/payment/payment_execute_request.dart';
import 'package:qarsspin/model/payment/payment_test_status_request.dart';

import '../../model/payment/payment_result_request..dart';
import '../../model/payment/qars_service.dart';

class PaymentServiceNew {
  static const String _baseUrl =
      'https://qarspartnersportalapitest.smartvillageqatar.com';

  final http.Client _client;

  PaymentServiceNew({http.Client? client}) : _client = client ?? http.Client();

  /// GET /api/Payment/supported-currencies?env=Sandbox
  Future<SupportedCurrenciesResponse> getSupportedCurrencies({
    String env = 'Sandbox',
  }) async {
    try {
      log('🌐 [PaymentService] Fetching supported currencies...');
      final uri = Uri.parse('$_baseUrl/api/Payment/supported-currencies')
          .replace(queryParameters: {'env': env});

      log('🔗 API Endpoint: $uri');
      final response = await _client.get(
        uri,
        headers: const {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      log('✅ [${response.statusCode}] Response received');
      log('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        log('🔍 Parsed JSON: $jsonData');
        return SupportedCurrenciesResponse.fromJson(jsonData);
      } else {
        final errorMsg = '❌ [${response.statusCode}] Failed to load currencies: ${response.body}';
        log(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      log('❌ Error in getSupportedCurrencies: $e');
      log('📜 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// POST /api/Payment/initiate
  ///
  /// Body example:
  /// {
  ///   "amount": 0,
  ///   "customerName": "Amira",
  ///   "email": "Amira@gmail.com",
  ///   "mobile": "01280077763"
  /// }
  Future<Map<String, dynamic>> initiatePayment(
      PaymentInitiateRequest request,
      ) async {
    final uri = Uri.parse('$_baseUrl/api/Payment/initiate');

    final response = await _client.post(
      uri,
      headers: const {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return <String, dynamic>{'statusCode': 200, 'message': 'Success'};
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return <String, dynamic>{
          'raw': body,
          'statusCode': response.statusCode,
        };
      }
    } else {
      throw Exception(
        'Failed to initiate payment. '
            'Status code: ${response.statusCode}, body: ${response.body}',
      );
    }
  }

  /// POST /api/Payment/execute
  ///
  /// Body example:
  /// {
  ///   "amount": 0,
  ///   "customerName": "string",
  ///   "email": "string",
  ///   "mobile": "string",
  ///   "paymentMethodId": 0,
  ///   "returnUrl": "string"
  /// }
  Future<Map<String, dynamic>> executePayment(
      PaymentExecuteRequest request,
      ) async {
    final uri = Uri.parse('$_baseUrl/api/Payment/execute');

    final response = await _client.post(
      uri,
      headers: const {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return <String, dynamic>{'statusCode': 200, 'message': 'Success'};
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return <String, dynamic>{
          'raw': body,
          'statusCode': response.statusCode,
        };
      }
    } else {
      throw Exception(
        'Failed to execute payment. '
            'Status code: ${response.statusCode}, body: ${response.body}',
      );
    }
  }

  /// GET /api/Payment/payment-result?paymentId=...&status=...
  Future<Map<String, dynamic>> getPaymentResult(
      PaymentResultRequest request,
      ) async {
    final uri = Uri.parse('$_baseUrl/api/Payment/payment-result')
        .replace(queryParameters: request.toQueryParameters());

    final response = await _client.get(
      uri,
      headers: const {
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return <String, dynamic>{'statusCode': 200, 'message': 'Success'};
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return <String, dynamic>{
          'raw': body,
          'statusCode': response.statusCode,
        };
      }
    } else {
      throw Exception(
        'Failed to get payment result. '
            'Status code: ${response.statusCode}, body: ${response.body}',
      );
    }
  }

  /// GET /api/Payment/test-status?paymentId=...&isTest=...
  Future<Map<String, dynamic>> getTestStatus(
      PaymentTestStatusRequest request,
      ) async {
    final uri = Uri.parse('$_baseUrl/api/Payment/test-status')
        .replace(queryParameters: request.toQueryParameters());

    final response = await _client.get(
      uri,
      headers: const {
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return <String, dynamic>{'statusCode': 200, 'message': 'Success'};
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return <String, dynamic>{
          'raw': body,
          'statusCode': response.statusCode,
        };
      }
    } else {
      throw Exception(
        'Failed to get test status. '
            'Status code: ${response.statusCode}, body: ${response.body}',
      );
    }
  }
  /// GET /api/v1/QarsRequests/Get-QarsServices
  /// Returns list of Qars services, optionally filtered by serviceType
  Future<List<QarsService>> getQarsServices({   // get price of services 360, features and others
    String? serviceTypeFilter, // e.g. "Individual"
  }) async {
    try {
      log('🌐 [PaymentService] Fetching Qars services...');
      final uri = Uri.parse('$_baseUrl/api/v1/QarsRequests/Get-QarsServices');

      log('🔗 API Endpoint: $uri');
      final response = await _client.get(
        uri,
        headers: const {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      log('✅ [${response.statusCode}] Response received');
      log('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

        // Parse to model list
        List<QarsService> services = jsonList
            .map((e) => QarsService.fromJson(e as Map<String, dynamic>))
            .toList();

        log('🔍 Parsed ${services.length} services before filtering');

        // Filter by type if provided (e.g. "Individual")
        if (serviceTypeFilter != null && serviceTypeFilter.isNotEmpty) {
          services = services
              .where((s) => s.qarsServiceType == serviceTypeFilter)
              .toList();
          log('🧮 Services after filtering by "$serviceTypeFilter": ${services.length}');
        }

        return services;
      } else {
        final errorMsg =
            '❌ [${response.statusCode}] Failed to load Qars services: ${response.body}';
        log(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      log('❌ Error in getQarsServices: $e');
      log('📜 Stack trace: $stackTrace');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
