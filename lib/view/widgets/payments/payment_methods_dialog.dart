import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'payment_webview_page.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:qarsspin/controller/const/colors.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../controller/payments/payment_service.dart';
import '../../../l10n/app_localization.dart';
import '../../../model/payment/payment_initiate_request.dart';
import '../../../model/payment/payment_method_model.dart';

// class PaymentMethodDialog extends StatefulWidget {
//   final double amount;
//
//   const PaymentMethodDialog({Key? key, required this.amount}) : super(key: key);
//
//   static Future<bool?> show({required BuildContext context, required double amount}) {
//     return showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => PaymentMethodDialog(amount: amount),
//     );
//   }
//
//   @override
//   State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
// }
//
// class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
//   List<MFPaymentMethod> methods = [];
//   bool loading = true;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMethods();
//   }
//
//   Future<void> _loadMethods() async {
//     try {
//       methods = await PaymentService.getPaymentMethods(widget.amount);
//     } catch (e) {
//       debugPrint("Error loading payment methods: $e");
//       errorMessage = "Failed to load payment methods.";
//     }
//     if (mounted) setState(() => loading = false);
//   }
//
//   void _startPayment(MFPaymentMethod method, BuildContext context) async {
//     final lc = AppLocalizations.of(context)!;
//
//     setState(() {
//       errorMessage = null;
//       loading = true;
//     });
//
//     try {
//       final success = await PaymentService.executePaymentWithPolling(
//         context,
//         method.paymentMethodId!, // استخدمي الـ ID وليس الكائن كله
//         widget.amount,
//       );
//       if (method.isDirectPayment == true) {
//         if (mounted) Navigator.pop(context, success);
//       } else {
//         // Redirect: فقط نعلم المستخدم
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(lc.redirecting_payment)),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "${lc.payment_failed}: ${e.toString()}";
//       });
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final lc = AppLocalizations.of(context)!;
//     return Dialog(
//       backgroundColor: AppColors.toastBackground,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         height: 700.h,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               lc.choose_payment_method,
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16.sp,
//               ),
//             ),
//             16.verticalSpace,
//             if (loading)
//               const Center(child: CircularProgressIndicator(color: AppColors.primary))
//             else if (methods.isEmpty)
//               Text(
//                 lc.no_payment_methods_available,
//                 style: TextStyle(color: Colors.white, fontSize: 14.sp),
//               )
//             else
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: methods.length,
//                   separatorBuilder: (_, __) => 12.verticalSpace,
//                   itemBuilder: (context, index) {
//                     final method = methods[index];
//                     return InkWell(
//                       onTap: () => _startPayment(method, context),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
//                         decoration: BoxDecoration(
//                           color: AppColors.logoGray.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             if (method.imageUrl != null)
//                               Image.network(
//                                 method.imageUrl!,
//                                 width: 40.w,
//                                 height: 40.w,
//                                 errorBuilder: (_, __, ___) => const Icon(Icons.payment),
//                               ),
//                             12.horizontalSpace,
//                             Expanded(
//                               child: Text(
//                                 method.paymentMethodEn ?? lc.unknown,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14.sp,
//                                 ),
//                               ),
//                             ),
//                             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             if (errorMessage != null) ...[
//               12.verticalSpace,
//               Text(
//                 errorMessage!,
//                 style: TextStyle(color: Colors.red, fontSize: 14.sp),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//             16.verticalSpace,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _cancelButton(() => Navigator.pop(context, false), lc.btn_Cancel),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _cancelButton(VoidCallback ontap, String title) {
//     return InkWell(
//       onTap: ontap,
//       child: Container(
//         width: 95.w,
//         padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           color: AppColors.logoGray,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: AppColors.black,
//               fontWeight: FontWeight.w700,
//               fontSize: 13.sp,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class InvoiceLinkDialog extends StatefulWidget {
  final String invoiceId;
  final String? paymentId;
  final String paymentUrl;
  final bool isArabic;

  const InvoiceLinkDialog({
    Key? key,
    required this.invoiceId,
    this.paymentId,
    required this.paymentUrl,
    required this.isArabic,
  }) : super(key: key);

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required String invoiceId,
    String? paymentId,
    required String paymentUrl,
    required bool isArabic,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black54,
      builder: (_) => InvoiceLinkDialog(
        invoiceId: invoiceId,
        paymentId: paymentId,
        paymentUrl: paymentUrl,
        isArabic: isArabic,
      ),
    );
  }

  @override
  State<InvoiceLinkDialog> createState() => _InvoiceLinkDialogState();
}

class _InvoiceLinkDialogState extends State<InvoiceLinkDialog> {
  bool checking = false;
  String? checkError;
  Map<String, dynamic>? statusResponse;

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    // Open dedicated in-app webview that auto-detects returnUrl and closes with normalized result
    const String returnBase = "$baseUrlWeb/api/Payment/result";
    final normalized = await PaymentWebViewPage.open(
      context,
      url: url,
      returnBase: returnBase,
    );
    if (!mounted) return;
    if (normalized is Map<String, dynamic>) {
      log("normalized herr $normalized");
      final status = normalized['status']?.toString();
      final paid = status != null && status.toLowerCase() == 'success';
      debugPrint(' [InvoiceLinkDialog] WebView returned normalized=$normalized, paid=$paid');
      Navigator.pop(context, {
        'paid': paid,
        'statusResponse': normalized,
        'normalizedResult': normalized,
      });
    }
  }

  Future<void> _confirmPaid() async {
    setState(() {
      checking = true;
      checkError = null;
    });
    try {
      final ctrl = Get.find<PaymentController>();
      final id = (widget.paymentId?.isNotEmpty ?? false) ? widget.paymentId! : widget.invoiceId;
      final resp = await ctrl.getTestStatus(paymentId: id, isTest: true);
      statusResponse = resp;
      final paid = (resp?['IsSuccess'] == true) ||
          ((resp?['status']?.toString().toLowerCase() == 'success'));
      final normalized = {
        'message': 'Payment result received.',
        'paymentId': id,
        'status': paid ? 'Success' : 'Failed',
      };
      if (mounted) Navigator.pop(context, {'paid': paid, 'statusResponse': resp, 'normalizedResult': normalized});
    } catch (e) {
      setState(() {
        checkError = e.toString();
      });
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final copiedMsg = isAr ? 'تم النسخ' : 'Copied to clipboard';
    final copyLabel = isAr ? 'نسخ' : 'Copy';

    return Dialog(
      backgroundColor: AppColors.toastBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAr ? 'رقم الفاتورة' : 'Invoice ID',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            8.verticalSpace,
            Text(
              widget.invoiceId,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            16.verticalSpace,
            Text(
              isAr ? 'رابط الدفع' : 'Payment Link',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            8.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openUrl(widget.paymentUrl),
                    child: Text(
                      widget.paymentUrl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        decorationColor: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                8.horizontalSpace,
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: widget.paymentUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(copiedMsg)),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.logoGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        copyLabel,
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                8.horizontalSpace,
                InkWell(
                  onTap: () => _openUrl(widget.paymentUrl),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.logoGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        isAr ? 'فتح' : 'Open',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            if (checkError != null) ...[
              12.verticalSpace,
              Text(checkError!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
            ],
            12.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _actionButton(
                //   onTap: checking ? null : _confirmPaid,
                //   title: isAr ? 'دفعت' : 'I Paid',
                //   disabled: checking,
                // ),
              //  12.horizontalSpace,
                _actionButton(
                  onTap: () => Navigator.pop(context, {'paid': false}),
                  title: isAr ? 'إلغاء' : 'Cancel',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({VoidCallback? onTap, required String title, bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 110.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.logoGray,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class NewPaymentMethodsDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentInitiateRequest? userInformationRequest;
  final bool isArabic;
  final int orderMasterId;
  final Map<String, dynamic> initiateResponse;

  const NewPaymentMethodsDialog({
    Key? key,
    required this.paymentMethods,
    this.userInformationRequest,
    this.isArabic = true,
    required this.orderMasterId,
    required this.initiateResponse,
  })  : assert(
          (userInformationRequest != null) ||
          (orderMasterId != null && initiateResponse != null),
          'Either userInformationRequest or both orderMasterId and initiateResponse must be provided'
        ),
        super(key: key);

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required List<PaymentMethod> paymentMethods,
    PaymentInitiateRequest? userInformationRequest,
    bool isArabic = true,
    int? orderMasterId,
    Map<String, dynamic>? initiateResponse,
  }) async {
    // Validate that we have either userInformationRequest or both orderMasterId and initiateResponse
    if (userInformationRequest == null && (orderMasterId == null || initiateResponse == null)) {
      throw ArgumentError(
        'Either userInformationRequest or both orderMasterId and initiateResponse must be provided'
      );
    }

    final paymentController = Get.find<PaymentController>();
    final supportedCurrencies = paymentController.currencies
        .map((currency) => currency.toUpperCase())
        .toList();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black87,
      builder: (_) => NewPaymentMethodsDialog(
        paymentMethods: paymentMethods,
        userInformationRequest: userInformationRequest,
        isArabic: isArabic,
        orderMasterId: orderMasterId!,
        initiateResponse: initiateResponse!,
      ),
    );
  }

  @override
  State<NewPaymentMethodsDialog> createState() => _NewPaymentMethodsDialogState();
}

class _NewPaymentMethodsDialogState extends State<NewPaymentMethodsDialog> {
  late List<PaymentMethod> filteredPaymentMethods;
  bool loading = false;
  String? errorMessage;
  Map<String, dynamic>? lastExecuteResponse;

  @override
  void initState() {
    super.initState();
    _filterPaymentMethods();
  }

  void _filterPaymentMethods() {
    final paymentController = Get.find<PaymentController>();
    final supportedCurrencies = paymentController.currencies
        .map((c) => c.toUpperCase())
        .toList();

    print('Supported Currencies: $supportedCurrencies');
    print('All Payment Methods: ${widget.paymentMethods.length}');

    filteredPaymentMethods = widget.paymentMethods.where((method) {
      final currencyIso = method.paymentCurrencyIso.toUpperCase();
      final isSupported = supportedCurrencies.contains(currencyIso);
      print('Method: ${method.paymentMethodEn} - Currency: $currencyIso - Supported: $isSupported');
    //  return isSupported; comment payment methods by currencies for now because get currencies 404
      return true;
    }).toList();

    log('Filtered Payment Methods: ${filteredPaymentMethods.length}');
  }

  Future<void> _handlePaymentMethodTap(PaymentMethod method) async {
    if (loading) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final paymentController = Get.find<PaymentController>();
      final int paymentMethodId = method.paymentMethodId;
      const String returnUrl = "$baseUrlWeb/api/Payment/result";

      // We must have both orderMasterId and initiateResponse from the parent
      if (widget.orderMasterId == null || widget.initiateResponse == null) {
        throw Exception('Payment initiation data is missing. Please provide both orderMasterId and initiateResponse');
      }

      log('Executing payment for order ${widget.orderMasterId} with method $paymentMethodId');
      
      final executeResponse = await paymentController.executePayment(
        orderMasterId: widget.orderMasterId!,
        paymentMethodId: paymentMethodId,
        returnUrl: returnUrl,
      );

      log('Payment execution response: $executeResponse');
      
      // Process the response
      final data = executeResponse as Map<String, dynamic>? ?? {};
      
      // Add debug logging for the response
      log('Processing payment response: $data');
      if (data['raw'] != null) {
        log('Raw payment data: ${data['raw']}');
        log('Payment URL from raw: ${(data['raw'] as Map)['PaymentUrl']}');
      }
      
      // Get the raw data if it exists, otherwise use the root object
      final rawData = (data['raw'] as Map<String, dynamic>?) ?? {};
      log(rawData.toString());
      // Try to get values from rawData first, then fall back to root object
      final invoiceId = rawData['InvoiceId']?.toString() ?? 
                       data['invoiceId']?.toString() ?? 
                       data['InvoiceId']?.toString() ?? 
                       data['orderId']?.toString() ??
                       '';
                       
      final paymentId = rawData['PaymentId']?.toString() ??
                       data['paymentId']?.toString() ?? 
                       data['PaymentId']?.toString() ?? 
                       data['paymentID']?.toString() ??
                       '';
                       
      final paymentUrl = rawData['PaymentUrl']?.toString() ??
                        rawData['paymentUrl']?.toString() ??
                        data['paymentUrl']?.toString() ??
                        data['PaymentUrl']?.toString() ??
                        data['paymentURL']?.toString() ??
                        data['redirectUrl']?.toString() ??
                        data['RedirectUrl']?.toString() ??
                        '';
                        
      log('Extracted payment URL: $paymentUrl');

      // Sequential flow: close this dialog first, let parent open the invoice dialog next
      if (mounted) {
        final payload = {
          'paymentMethod': method,
          'executeResponse': executeResponse,
          'initiateResponse': widget.initiateResponse,
          'invoice': {
            'invoiceId': invoiceId,
            'paymentId': paymentId.isNotEmpty ? paymentId : null,
            'paymentUrl': paymentUrl,
            'isArabic': widget.isArabic,
          },
        };
        debugPrint(' [NewPaymentMethodsDialog] returning payload = $payload');
        Navigator.pop(context, payload);
        return;
      }
    } catch (e) {
      log("fail $e");
      setState(() {
        errorMessage = widget.isArabic
            ? 'حدث خطأ أثناء تنفيذ عملية الدفع'
            : 'An error occurred while executing the payment';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.toastBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
      //  height: 600.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.isArabic ? 'اختر طريقة الدفع' : 'Choose Payment Method',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            16.verticalSpace,

            if (loading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (filteredPaymentMethods.isEmpty)
              Text(
                widget.isArabic ? 'لا توجد طرق دفع متاحة' : 'No payment methods available',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filteredPaymentMethods.length,
                  separatorBuilder: (_, __) => 12.verticalSpace,
                  itemBuilder: (context, index) {
                    final method = filteredPaymentMethods[index];
                    final methodName = method.getDisplayName(widget.isArabic);

                    return InkWell(
                      onTap: () => _handlePaymentMethodTap(method),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.logoGray.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if ((method.imageUrl).isNotEmpty)
                              Image.network(
                                method.imageUrl,
                                width: 40.w,
                                height: 40.w,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.payment, size: 40.w, color: Colors.white),
                              ),
                            12.horizontalSpace,
                            Expanded(
                              child: Text(
                                methodName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (errorMessage != null) ...[
              12.verticalSpace,
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],

            16.verticalSpace,
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 95.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.logoGray,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            widget.isArabic ? 'إلغاء' : 'Cancel',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}