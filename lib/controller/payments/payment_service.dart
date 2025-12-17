// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
//
// class PaymentService {
//   // Test API Key
//   static String apiKey =
//       "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL";
//   /// Initialize MyFatoorah SDK
//   static void initialize() {
//     try {
//       MFSDK.init(apiKey, MFCountry.KUWAIT, MFEnvironment.TEST);
//       log('MyFatoorah SDK initialized successfully');
//     } catch (e) {
//       log('Error initializing MyFatoorah SDK: $e');
//     }
//   }
//
//   /// Get available payment methods
//   static Future<List<MFPaymentMethod>> getPaymentMethods(double amount) async {
//     try {
//       final request = MFInitiatePaymentRequest(
//         invoiceAmount: amount,
//         currencyIso: MFCurrencyISO.KUWAIT_KWD,
//       );
//       final response = await MFSDK.initiatePayment(request, MFLanguage.ENGLISH);
//       return response.paymentMethods ?? [];
//     } catch (e) {
//       log('Error fetching payment methods: $e');
//       return [];
//     }
//   }
//
//   /// Execute payment (Redirect or Direct) with retry logic for status checking
//   static Future<bool> executePaymentWithPolling(
//       BuildContext context, int methodId, double amount) async {
//     log('[EXECUTE] Starting payment process');
//
//     try {
//       final request = MFExecutePaymentRequest(invoiceValue: amount)
//         ..paymentMethodId = methodId;
//
//       bool paymentSuccess = false;
//       bool isAuthError = false;
//
//       try {
//         await MFSDK.executePayment(
//           request,
//           MFLanguage.ENGLISH,
//               (String invoiceId) async {
//             log('[EXECUTE] Invoice created: $invoiceId');
//
//             // Add retry logic for status checking
//             int retries = 3;
//             bool statusChecked = false;
//
//             while (retries > 0 && !statusChecked && !isAuthError) {
//               try {
//                 log('[STATUS] Checking payment status (attempt ${4 - retries}/3)');
//                 await Future.delayed(const Duration(seconds: 5));
//
//                 try {
//                   log('[STATUS] Getting status for invoice: $invoiceId');
//                   final statusResponse = await getPaymentStatus(invoiceId);
//
//                   if (statusResponse != null) {
//                     final status = statusResponse.invoiceStatus?.toUpperCase() ?? "UNKNOWN";
//                     log('[STATUS] Invoice $invoiceId → $status');
//
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             status == "PAID"
//                                 ? "Payment successful!"
//                                 : "Payment status: $status",
//                           ),
//                           duration: const Duration(seconds: 5),
//                         ),
//                       );
//                     }
//
//                     paymentSuccess = status == "PAID" || status == "PENDING";
//                     statusChecked = true;
//                   }
//                 } on MFError catch (e) {
//                   log('[STATUS][MFError] code=${e.code}, message=${e.message}');
//                   if (e.code == 107) {
//                     log('[STATUS][AUTH_ERROR] Authentication failed, stopping retries');
//                     isAuthError = true;
//                     throw e; // Will be caught by the outer catch block
//                   }
//                   throw e; // Re-throw to be handled by the outer catch
//                 }
//               } catch (e) {
//                 log('[STATUS][ERROR] $e');
//                 retries--;
//
//                 if (retries == 0 && context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Payment status could not be verified. Please check your email."),
//                       duration: Duration(seconds: 5),
//                     ),
//                   );
//                 } else if (!isAuthError) {
//                   log('[STATUS] Retrying in 3 seconds...');
//                   await Future.delayed(const Duration(seconds: 3));
//                 }
//               }
//             }
//
//             if (isAuthError) {
//               log('[STATUS] Exiting due to authentication error');
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Payment authentication error. Please check your payment details and try again."),
//                     duration: Duration(seconds: 5),
//                   ),
//                 );
//               }
//             }
//           },
//         );
//       } on MFError catch (e) {
//         log('[EXECUTE][MFError] code=${e.code}, message=${e.message}');
//         if (e.code == 107 || isAuthError) {
//           log('[AUTH ERROR] Authentication failed, stopping payment process');
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("Payment authentication error. Please check your payment details and try again."),
//                 duration: Duration(seconds: 5),
//               ),
//             );
//           }
//           return false;
//         }
//         rethrow;
//       }
//
//       return paymentSuccess;
//     } on MFError catch (e) {
//       log('[EXECUTE][MFError] code=${e.code}, message=${e.message}');
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               e.code == 107
//                   ?"Payment authentication error. Please check your payment details and try again."
//                   : "Payment error: ${e.message}",
//             ),
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//       return false;
//     } catch (e) {
//       log('[EXECUTE][ERROR] $e');
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("An unexpected error occurred. Please try again."),
//             duration: Duration(seconds: 5),
//           ),
//         );
//       }
//       return false;
//     }
//   }
//
//   /// Get payment status by invoiceId
//   static Future<MFGetPaymentStatusResponse?> getPaymentStatus(
//       String invoiceId) async {
//     try {
//       final request = MFGetPaymentStatusRequest(
//         key: invoiceId,
//         keyType: MFKeyType.INVOICEID,
//       );
//       log('[GET_STATUS] Requesting status for invoice: $invoiceId');
//       final response = await MFSDK.getPaymentStatus(request, MFLanguage.ENGLISH);
//       log('[GET_STATUS] Response received for invoice: $invoiceId');
//       return response;
//     } on MFError catch (e) {
//       // Log the full error details
//       log('[GET_STATUS][MFError] code=${e.code}, message=${e.message}');
//       log('[GET_STATUS][MFError] Full error: $e');
//
//       // If this is an authentication error, log it specifically
//       if (e.code == 107) {
//         log('[GET_STATUS][AUTH_ERROR] Authentication failed for invoice: $invoiceId');
//       }
//
//       // Rethrow to be handled by the caller
//       rethrow;
//     } catch (e) {
//       log('[GET_STATUS][UNEXPECTED_ERROR] $e');
//       rethrow;
//     }
//   }
// }