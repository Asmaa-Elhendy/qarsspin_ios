import 'dart:developer';

import 'package:get/get.dart';
import 'package:qarsspin/controller/payments/payment_service_new.dart';
import 'package:qarsspin/model/payment/payment_initiate_request.dart';
import 'package:qarsspin/model/payment/payment_execute_request.dart';
import 'package:qarsspin/model/payment/payment_test_status_request.dart';
import 'package:qarsspin/model/payment/supported_currencies_response.dart';

import '../../model/payment/payment_result_request..dart';
import '../../model/payment/qars_service.dart';

class PaymentController extends GetxController {
  final PaymentServiceNew _service;

  PaymentController({PaymentServiceNew? service})
      : _service = service ?? PaymentServiceNew();

  // ---------- Supported Currencies ----------
  final RxList<String> currencies = <String>[].obs;
  final RxBool isLoadingCurrencies = false.obs;
  final RxString environment = ''.obs;
  final RxString currenciesErrorMessage = ''.obs;

  // ---------- Initiate Payment ----------
  final RxBool isInitiatingPayment = false.obs;
  final Rxn<Map<String, dynamic>> lastPaymentInitiateResponse =
  Rxn<Map<String, dynamic>>();
  final RxString paymentErrorMessage = ''.obs;

  // ---------- Execute Payment ----------
  final RxBool isExecutingPayment = false.obs;
  final Rxn<Map<String, dynamic>> lastPaymentExecuteResponse =
  Rxn<Map<String, dynamic>>();
  final RxString executePaymentErrorMessage = ''.obs;

  // ---------- Payment Result ----------
  final RxBool isFetchingPaymentResult = false.obs;
  final Rxn<Map<String, dynamic>> lastPaymentResultResponse =
  Rxn<Map<String, dynamic>>();
  final RxString paymentResultErrorMessage = ''.obs;

  // ---------- Test Status ----------
  final RxBool isFetchingTestStatus = false.obs;
  final Rxn<Map<String, dynamic>> lastTestStatusResponse =
  Rxn<Map<String, dynamic>>();
  final RxString testStatusErrorMessage = ''.obs;

  // ---------- Qars Services (Individual) ----------  for prices 360,featured and others
  final RxList<QarsService> individualQarsServices = <QarsService>[].obs;
  final RxBool isLoadingQarsServices = false.obs;
  final RxString qarsServicesErrorMessage = ''.obs;
  
  // Service details for easy access
  final Rx<QarsService?> featuredService = Rx<QarsService?>(null);
  final Rx<QarsService?> request360Service = Rx<QarsService?>(null);
  
  // Convenience getters with null safety
  int? get featuredServiceId => featuredService.value?.qarsServiceId;
  double? get featuredServicePrice => featuredService.value?.qarsServicePrice.toDouble();
  int? get request360ServiceId => request360Service.value?.qarsServiceId;
  double? get request360ServicePrice => request360Service.value?.qarsServicePrice.toDouble();


  // ---------- Check Order Flow ----------
  final RxBool isCheckingOrderFlow = false.obs;
  final Rxn<Map<String, dynamic>> lastCheckOrderFlowResponse = Rxn<Map<String, dynamic>>();
  final RxString checkOrderFlowErrorMessage = ''.obs;


  @override
  void onInit() {
    super.onInit();
    print('🔄 PaymentController initialized');
    // Load currencies when controller is initialized
    // loadSupportedCurrencies().then((_) {
    //   print('💰 Currencies loaded successfully: ${currencies.length} items');
    // }).catchError((error) {
    //   print('❌ Failed to load currencies: $error');
    // });
    // Load Qars services (Individual)
    loadIndividualQarsServices().then((_) {
      print(
          '🧾 Qars Individual services loaded: ${individualQarsServices.length} items');
    }).catchError((error) {
      print('❌ Failed to load Qars services: $error');
    });
  }


  /// GET /api/Payment/supported-currencies
  // Future<void> loadSupportedCurrencies({String env = 'Sandbox'}) async {
  //   try {
  //     print('⏳ Loading supported currencies...');
  //     isLoadingCurrencies.value = true;
  //     currenciesErrorMessage.value = '';
  //
  //     print('🌍 Environment: $env');
  //     final SupportedCurrenciesResponse response =
  //         await _service.getSupportedCurrencies(env: env);
  //
  //     environment.value = response.environment;
  //     print('🌐 Environment set to: ${environment.value}');
  //
  //     print('🔄 Updating currencies list...');
  //     currencies.assignAll(response.currencies);
  //     print('✅ Successfully loaded ${currencies.length} currencies');
  //
  //   } catch (e, stackTrace) {
  //     final errorMsg = '❌ Error loading currencies: $e';
  //     print(errorMsg);
  //     print('📜 Stack trace: $stackTrace');
  //
  //     currenciesErrorMessage.value = errorMsg;
  //     // Re-throw to allow callers to handle the error if needed
  //     rethrow;
  //   } finally {
  //     isLoadingCurrencies.value = false;
  //     print('🏁 Currency loading completed. isError: ${currenciesErrorMessage.isNotEmpty}');
  //   }
  // }

  /// POST /api/Payment/initiate
  /// 
  /// Initiates a payment for a specific post with the given services
  /// 
  /// [postId] - The ID of the post to make payment for
  /// [serviceIds] - List of Qars service IDs to apply to the post
  /// [amount] - The total amount to be paid
  /// [customerName] - Name of the customer making the payment
  /// [email] - Email of the customer
  /// [mobile] - Mobile number of the customer
  /// [externalUser] - Optional external user identifier
  Future<Map<String, dynamic>?> initiatePayment({
    required int postId,
    required List<int> serviceIds,
    required num amount,
    required String customerName,
    required String email,
    required String mobile,
    String? externalUser,
  }) async {
    try {
      isInitiatingPayment.value = true;
      paymentErrorMessage.value = '';
      lastPaymentInitiateResponse.value = null;

      log('💳 Initializing payment for post $postId with services: $serviceIds');
      
      final request = PaymentInitiateRequest(
        postId: postId,
        qarsServiceIds: serviceIds,
        amount: amount,
        customerName: customerName,
        email: email,
        mobile: mobile,
      );

      log('📦 Payment request created: ${request.toJson()}');
      
      final response = await _service.initiatePayment(
        request,
        externalUser: externalUser,
      );

      log('✅ Payment initiated successfully');
      lastPaymentInitiateResponse.value = response;
      return response;
      
    } catch (e, stackTrace) {
      final errorMsg = '❌ Failed to initiate payment: $e';
      log(errorMsg);
      log('📜 Stack trace: $stackTrace');
      
      paymentErrorMessage.value = e.toString();
      return null;
    } finally {
      isInitiatingPayment.value = false;
    }
  }

  /// POST /api/Payment/execute
  /// 
  /// Executes a payment for a specific order with the selected payment method
  /// 
  /// [orderMasterId] - The ID of the order from the initiate payment response
  /// [paymentMethodId] - The ID of the selected payment method
  /// [returnUrl] - The URL to return to after payment completion
  /// [externalUser] - Optional external user identifier
  Future<Map<String, dynamic>?> executePayment({
    required int orderMasterId,
    required int paymentMethodId,
    required String returnUrl,
    String? externalUser,
  }) async {
    try {
      isExecutingPayment.value = true;
      executePaymentErrorMessage.value = '';
      lastPaymentExecuteResponse.value = null;

      log('💳 Executing payment for order $orderMasterId with method $paymentMethodId');
      
      final request = PaymentExecuteRequest(
        orderMasterId: orderMasterId,
        paymentMethodId: paymentMethodId,
        returnUrl: returnUrl,
      );
      
      log('📦 Payment execution request: ${request.toJson()}');
      
      final response = await _service.executePayment(
        request,
        externalUser: externalUser,
      );

      log('✅ Payment executed successfully');
      log('response of execute is $response');
      lastPaymentExecuteResponse.value = response;
      return response;
      
    } catch (e, stackTrace) {
      final errorMsg = '❌ Failed to execute payment: $e';
      log(errorMsg);
      log('📜 Stack trace: $stackTrace');
      
      executePaymentErrorMessage.value = errorMsg;
      return null;
    } finally {
      isExecutingPayment.value = false;
    }
  }

  /// GET /api/Payment/payment-result?paymentId=...&status=...
  Future<Map<String, dynamic>?> getPaymentResult({
    required String paymentId,
    required String status,
  }) async {
    try {
      isFetchingPaymentResult.value = true;
      paymentResultErrorMessage.value = '';
      lastPaymentResultResponse.value = null;

      final request = PaymentResultRequest(
        paymentId: paymentId,
        status: status,
      );

      final response = await _service.getPaymentResult(request);

      lastPaymentResultResponse.value = response;
      return response;
    } catch (e) {
      paymentResultErrorMessage.value = e.toString();
      return null;
    } finally {
      isFetchingPaymentResult.value = false;
    }
  }

  /// GET /api/Payment/test-status?paymentId=...&isTest=...
  Future<Map<String, dynamic>?> getTestStatus({
    required String paymentId,
    required bool isTest,
  }) async {
    try {
      isFetchingTestStatus.value = true;
      testStatusErrorMessage.value = '';
      lastTestStatusResponse.value = null;

      final request = PaymentTestStatusRequest(
        paymentId: paymentId,
        isTest: isTest,
      );

      final response = await _service.getTestStatus(request);

      lastTestStatusResponse.value = response;
      return response;
    } catch (e) {
      testStatusErrorMessage.value = e.toString();
      return null;
    } finally {
      isFetchingTestStatus.value = false;
    }
  }

  /// GET /api/v1/QarsRequests/Get-QarsServices
  /// Load only services where qarsServiceType == "Individual"
  Future<void> loadIndividualQarsServices() async {
    try {
      isLoadingQarsServices.value = true;
      qarsServicesErrorMessage.value = '';
      
      final services = await _service.getQarsServices();
      
      // Filter for Individual services only
      final individualServices = services
          .where((service) => service.qarsServiceType == 'Individual')
          .toList();
      
      individualQarsServices.assignAll(individualServices);
      
      // Extract and store specific services
      for (var service in individualServices) {
        if (service.qarsServiceName.toLowerCase().contains('feature')) {
          featuredService.value = service;
          print('⭐ Featured service stored - ID: ${service.qarsServiceId}, Name: ${service.qarsServiceName}, Price: ${service.qarsServicePrice}');
        } else if (service.qarsServiceName.toLowerCase().contains('360')) {
          request360Service.value = service;
          print('🔄 360 service stored - ID: ${service.qarsServiceId}, Name: ${service.qarsServiceName}, Price: ${service.qarsServicePrice}');
        }
      }
      
    } catch (e) {
      final errorMsg = 'Failed to load Qars services: $e';
      qarsServicesErrorMessage.value = errorMsg;
      rethrow;
    } finally {
      isLoadingQarsServices.value = false;
      print(
          '🏁 Qars services loading completed. isError: ${qarsServicesErrorMessage.isNotEmpty}');
    }
  }


  Future<Map<String, dynamic>?> checkOrderFlow({
    required int postId,
    required int qarsServiceId,
  }) async {
    try {
      isCheckingOrderFlow.value = true;
      checkOrderFlowErrorMessage.value = '';
      lastCheckOrderFlowResponse.value = null;

      log('🧭 Checking order flow for postId=$postId, serviceId=$qarsServiceId');

      final resp = await _service.checkOrderFlow(
        postId: postId,
        qarsServiceId: qarsServiceId,
      );

      lastCheckOrderFlowResponse.value = resp;
      log('✅ checkOrderFlow success: $resp');
      return resp;
    } catch (e, st) {
      final msg = '❌ checkOrderFlow failed: $e';
      log(msg);
      log('📜 Stack trace: $st');
      checkOrderFlowErrorMessage.value = msg;
      return null;
    } finally {
      isCheckingOrderFlow.value = false;
    }
  }


}
