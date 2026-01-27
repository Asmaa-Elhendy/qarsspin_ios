// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qarsspin/controller/auth/auth_controller.dart';
// import '../../../controller/payments/payment_controller.dart';
// import '../../../l10n/app_localizations.dart';
// import '../../../model/payment/payment_method_model.dart';
// import 'package:qarsspin/view/widgets/my_ads/dialog.dart';
// import 'package:qarsspin/view/widgets/payments/payment_methods_dialog.dart';
//
// import 'package:qarsspin/view/widgets/ads/dialogs/contact_info_dialog.dart';
//
// import 'package:qarsspin/view/widgets/my_ads/dialog.dart' as dialog;
//
//
//
// Future<void> handleServiceTap({
//   required BuildContext context,
//   required  lc,
//   required PaymentController paymentController,
//   required int postId,
//   required String userName,
//   required int qarsServiceId,
//   required double servicePrice,
//   required bool isRequest360,
//   required bool isFeatured,
//   required String confirmTitle,
//   required String confirmMessage,
// }) async {
//   // 1) call check-order-flow
//   final checkResp = await paymentController.checkOrderFlow(
//     postId: postId,
//     qarsServiceId: qarsServiceId,
//   );
//
//   if (checkResp == null) {
//     dialog.SuccessDialog.show(
//       request: true,
//       context: context,
//       title: lc.payment_failed,
//       message: paymentController.checkOrderFlowErrorMessage.value,
//       onClose: () {},
//       onTappp: () {},
//     );
//     return;
//   }
//
//   final status = (checkResp['status'] ?? '').toString().trim();
//   final message = (checkResp['message'] ?? '').toString();
//   final canCreateNew = checkResp['canCreateNew'] == true;
//
//   log('🔎 check-order-flow status=$status, canCreateNew=$canCreateNew, message=$message');
//
//   // Helper: map paymentMethods if exists
//   List<PaymentMethod> _extractMethodsFromCheckResp(Map<String, dynamic> checkResp) {
//     final pmRoot = checkResp['paymentMethods'];
//
//     // Case 1: paymentMethods is already a List (just in case)
//     if (pmRoot is List) {
//       return pmRoot
//           .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     }
//
//     // Case 2: paymentMethods is a Map with Data.PaymentMethods (your real case)
//     if (pmRoot is Map) {
//       final pmMap = Map<String, dynamic>.from(pmRoot);
//
//       final data = pmMap['Data'];
//       if (data is Map) {
//         final dataMap = Map<String, dynamic>.from(data);
//
//         final list = dataMap['PaymentMethods'];
//         if (list is List) {
//           return list
//               .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
//               .toList();
//         }
//       }
//     }
//
//     return <PaymentMethod>[];
//   }
//
//
//   // 2) Switch on status
//   if (status == 'SERVICE_ACTIVE') {
//     // already requested
//     SuccessDialog.show(
//       request: true,
//       context: context,
//       title: lc.note,
//       message: lc.youHaveRequestedThisServiceBefore,
//       onClose: () {},
//       onTappp: () {},
//     );
//     return;
//   }
// //k
//   if (status == 'NO_PAYMENT') {
//     // Show payment methods dialog from same response
//     final masterId = checkResp['masterId'] as int?;
//     final methods = _extractMethodsFromCheckResp(checkResp);
//
//     if (masterId == null) {
//       dialog.SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.payment_failed,
//         message: lc.missingMasterIdError,
//         onClose: () {},
//         onTappp: () {},
//       );
//       return;
//     }
//     if (methods.isEmpty) {
//       dialog.SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.payment_failed,
//         message: lc.noPaymentMethodsError,
//         onClose: () {},
//         onTappp: () {},
//       );
//       return;
//     }
//
//     final payload = await NewPaymentMethodsDialog.show(
//       context: context,
//       paymentMethods: methods,
//       isArabic: Get.locale?.languageCode == 'ar',
//       orderMasterId: masterId,
//       initiateResponse: checkResp, // reuse checkResp as "initiateResponse"
//     );
//
//     if (payload == null) return;
//
//     Map<String, dynamic>? normalized;
//     final invoice = payload['invoice'] as Map<String, dynamic>?;
//     if (invoice != null) {
//       final invoiceResult = await InvoiceLinkDialog.show(
//         context: context,
//         invoiceId: (invoice['invoiceId'] ?? masterId.toString()).toString(),
//         paymentId: (invoice['paymentId'] ?? '').toString(),
//         paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
//         isArabic: (invoice['isArabic'] == true),
//       );
//       normalized = invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
//     } else {
//       normalized = payload['normalizedResult'] as Map<String, dynamic>?;
//     }
//
//     final normalizedStatus = normalized?['status']?.toString();
//     final paymentId = normalized?['paymentId']?.toString();
//     final success = (normalizedStatus != null && normalizedStatus.toLowerCase() == 'success') &&
//         (paymentId != null && paymentId.isNotEmpty);
//
//     if (success) {
//       SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.confirmation,
//         message: lc.receive_request_msg,
//         onClose: () {},
//         onTappp: () {},
//       );
//     } else {
//       SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.payment_failed,
//         message: lc.payment_failed_or_cancelled,
//         onClose: () {},
//         onTappp: () {},
//       );
//     }
//     return;
//   }
//
//   if (status == 'NO_TRANSACTION') {
//     // Open invoice link directly using paymentUrl
//     final paymentUrl = (checkResp['paymentUrl'] ?? '').toString();
//     final masterId = (checkResp['masterId'] ?? '').toString();
//     final detailId = (checkResp['detailId'] ?? '').toString();
//
//     if (paymentUrl.isEmpty) {
//       dialog.SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.payment_failed,
//         message: lc.noTransactionUrlError,
//         onClose: () {},
//         onTappp: () {},
//       );
//       return;
//     }
//
//     final invoiceResult = await InvoiceLinkDialog.show(
//       context: context,
//       invoiceId: detailId.isNotEmpty ? detailId : masterId,
//       paymentId: null,
//       paymentUrl: paymentUrl,
//       isArabic: Get.locale?.languageCode == 'ar',
//     );
//
//     final normalized = invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
//     final normalizedStatus = normalized?['status']?.toString();
//     final paymentId = normalized?['paymentId']?.toString();
//
//     final success = (normalizedStatus != null && normalizedStatus.toLowerCase() == 'success') &&
//         (paymentId != null && paymentId.isNotEmpty);
//
//     if (success) {
//       SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.confirmation,
//         message: lc.receive_request_msg,
//         onClose: () {},
//         onTappp: () {},
//       );
//     } else {
//       SuccessDialog.show(
//         request: true,
//         context: context,
//         title: lc.payment_failed,
//         message: lc.payment_failed_or_cancelled,
//         onClose: () {},
//         onTappp: () {},
//       );
//     }
//     return;
//   }
//
//   // Allow create new for these statuses:
//   final allowCreateNew = status == 'NO_ORDER' || status == 'NO_DETAIL' || status == 'SERVICE_EXPIRED';
//
//   if (!allowCreateNew) {
//     // NO_REQUEST أو أي حالة تانية
//     SuccessDialog.show(
//       request: true,
//       context: context,
//       title: lc.note,
//       message: '${lc.unhandledStatusError}\nStatus: $status\n$message',
//       onClose: () {},
//       onTappp: () {},
//     );
//     return;
//   }
//
//   // 3) allowed to create new => show confirmation + proceed normal flow (contactInfo -> initiatePayment -> methods dialog -> invoice)
//   SuccessDialog.show(
//     request: false,
//     context: context,
//     title: confirmTitle,
//     message: confirmMessage,
//     onClose: () {},
//     onTappp: () async {
//       Navigator.pop(context);
//
//       final contactInfo = await ContactInfoDialog.show(
//         totalAmount: servicePrice,
//         req360Amount: isRequest360 ? servicePrice : 0,
//         featuredAmount: isFeatured ? servicePrice : 0,
//         context: context,
//         isRequest360: isRequest360,
//         isFeauredPost: isFeatured,
//       );
//
//       if (contactInfo == null) return;
//
//       try {
//         final String customerName =
//         '${(contactInfo['firstName'] ?? '').toString().trim()} ${(contactInfo['lastName'] ?? '').toString().trim()}'
//             .trim();
//         final String email = (contactInfo['email'] ?? '').toString().trim();
//         final String mobile = (contactInfo['mobile'] ?? '').toString().trim();
//
//         final result = await paymentController.initiatePayment(
//           postId: postId,
//           serviceIds: [qarsServiceId],
//           amount: servicePrice,
//           customerName: customerName.isEmpty ? 'Customer' : customerName,
//           email: email,
//           mobile: mobile,
//           externalUser: Get.find<AuthController>().userName!,
//         );
//
//         if (result?['myFatoorahRawJson']?['IsSuccess'] == true &&
//             result?['myFatoorahRawJson']?['Data'] != null &&
//             result?['myFatoorahRawJson']?['Data']['PaymentMethods'] != null) {
//           final methodsRaw = List<dynamic>.from(
//             result!['myFatoorahRawJson']['Data']['PaymentMethods'] as List,
//           );
//
//           final methods = methodsRaw
//               .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
//               .toList();
//
//           final orderMasterId = result['masterOrderId'] as int?;
//           if (orderMasterId == null) {
//             throw Exception('No orderMasterId in payment initiation response');
//           }
//
//           final methodsPayload = await NewPaymentMethodsDialog.show(
//             context: context,
//             paymentMethods: methods,
//             isArabic: Get.locale?.languageCode == 'ar',
//             orderMasterId: orderMasterId,
//             initiateResponse: result,
//           );
//
//           if (methodsPayload == null) return;
//
//           Map<String, dynamic>? normalized;
//           final invoice = methodsPayload['invoice'] as Map<String, dynamic>?;
//           if (invoice != null) {
//             final invoiceResult = await InvoiceLinkDialog.show(
//               context: context,
//               invoiceId: (invoice['invoiceId'] ?? '').toString(),
//               paymentId: (invoice['paymentId'] ?? '').toString(),
//               paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
//               isArabic: (invoice['isArabic'] == true),
//             );
//             normalized = invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
//           } else {
//             normalized = methodsPayload['normalizedResult'] as Map<String, dynamic>?;
//           }
//
//           final status = normalized?['status']?.toString();
//           final paymentId = normalized?['paymentId']?.toString();
//           final success = (status != null && status.toLowerCase() == 'success') &&
//               (paymentId != null && paymentId.isNotEmpty);
//
//           if (success) {
//             SuccessDialog.show(
//               request: true,
//               context: context,
//               title: lc.confirmation,
//               message: lc.receive_request_msg,
//               onClose: () {},
//               onTappp: () {},
//             );
//           } else {
//             SuccessDialog.show(
//               request: true,
//               context: context,
//               title: lc.payment_failed,
//               message: lc.payment_failed_or_cancelled,
//               onClose: () {},
//               onTappp: () {},
//             );
//           }
//         } else {
//           SuccessDialog.show(
//             request: true,
//             context: context,
//             title: lc.payment_failed,
//             message: lc.payment_failed_or_cancelled,
//             onClose: () {},
//             onTappp: () {},
//           );
//         }
//       } catch (e, st) {
//         log('Payment flow error: $e');
//         log('Stack: $st');
//         dialog.SuccessDialog.show(
//           request: true,
//           context: context,
//           title: lc.payment_failed,
//           message: '${lc.paymentflowfailed} $e',
//           onClose: () {
//             Navigator.pop(context);
//           },
//           onTappp: () {
//             Navigator.pop(context);
//           },
//         );
//       }
//     },
//   );
// }
