// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../../controller/const/colors.dart';
//
// class PaymentWebViewPage extends StatefulWidget {
//   final String initialUrl;
//   final String returnBase;
//
//   const PaymentWebViewPage({
//     super.key,
//     required this.initialUrl,
//     required this.returnBase,
//   });
//
//   static Future<Map<String, dynamic>?> open(
//       BuildContext context, {
//         required String url,
//         required String returnBase,
//       }) {
//     return Navigator.of(context).push<Map<String, dynamic>>(
//       MaterialPageRoute(
//         builder: (_) => PaymentWebViewPage(initialUrl: url, returnBase: returnBase),
//         fullscreenDialog: true,
//       ),
//     );
//   }
//
//   @override
//   State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
// }
//
// class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
//   late final WebViewController _controller;
//   bool _loading = true;
//
//   // Convert HTML-escaped query separators (&amp;) to real '&' so Uri parsing works.
//   String _fixUrl(String url) => url.replaceAll('&amp;', '&');
//
//   bool _isReturnUrl(String url) {
//     final fixed = _fixUrl(url);
//     return fixed.startsWith(widget.returnBase);
//   }
//
//   Map<String, dynamic> _normalizeResult(String url) {
//     final fixed = _fixUrl(url);
//     final uri = Uri.parse(fixed);
//
//     final qp = uri.queryParameters;
//
//     final paymentId =
//         qp['paymentId'] ?? qp['PaymentId'] ?? qp['Id'] ?? qp['ID'] ?? '';
//
//     final rawStatus = qp['status'] ?? qp['Status'] ?? '';
//     final isSuccessFlag = qp['IsSuccess'] ?? qp['isSuccess'];
//
//     String status;
//     if (rawStatus.isNotEmpty) {
//       status = rawStatus.toString().toLowerCase();
//     } else if (isSuccessFlag != null) {
//       final val = isSuccessFlag.toString().toLowerCase();
//       status = (val == 'true' || val == '1') ? 'success' : 'failed';
//     } else {
//       status = 'unknown';
//     }
//
//     final ref = qp['ref'] ?? qp['Ref'] ?? qp['CustomerReference'] ?? '';
//
//     return {
//       'message': 'Payment result received.',
//       'paymentId': paymentId,
//       'status': status,
//       'ref': ref,
//       'url': fixed, // helpful for debugging/logging
//     };
//   }
//
//   bool _handlePossibleReturnUrl(String url, {required String source}) {
//     log('🔎 [WebView] ($source) checking url: $url');
//
//     if (!_isReturnUrl(url)) return false;
//
//     final normalized = _normalizeResult(url);
//     log('✅ [WebView] ($source) Matched returnBase. normalized=$normalized');
//
//     if (Navigator.of(context).canPop()) {
//       Navigator.of(context).pop(normalized);
//     }
//     return true;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     log('🧭 [WebView] init with initialUrl=${widget.initialUrl}');
//     log('🧭 [WebView] returnBase=${widget.returnBase}');
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (request) {
//             final url = request.url;
//             log('➡️ [WebView] onNavigationRequest: $url');
//
//             final handled = _handlePossibleReturnUrl(url, source: 'onNavigationRequest');
//             if (handled) return NavigationDecision.prevent;
//
//             return NavigationDecision.navigate;
//           },
//           onUrlChange: (change) {
//             final url = change.url ?? '';
//             if (url.isEmpty) return;
//
//             log('🔄 [WebView] onUrlChange: $url');
//             _handlePossibleReturnUrl(url, source: 'onUrlChange');
//           },
//           onPageStarted: (url) {
//             log('⏳ [WebView] onPageStarted: $url');
//             if (mounted) setState(() => _loading = true);
//           },
//           onPageFinished: (url) {
//             log('🏁 [WebView] onPageFinished: $url');
//             if (mounted) setState(() => _loading = false);
//           },
//           onWebResourceError: (error) {
//             log('❌ [WebView] WebResourceError: ${error.errorCode} - ${error.description}');
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.initialUrl));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.background(context),
//         toolbarHeight: 60.h,
//         shadowColor: Colors.grey.shade300,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             color: AppColors.background(context),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.blackColor(context).withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 5.h,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//         ),
//         elevation: 0,
//         title: Text(
//           'Payment',
//           style: TextStyle(
//             color: AppColors.blackColor(context),
//             fontWeight: FontWeight.bold,
//             fontSize: 18.sp,
//           ),
//         ),
//         iconTheme: IconThemeData(
//           color: AppColors.blackColor(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _controller.reload(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_loading)
//             const Center(
//               child: CircularProgressIndicator(color: AppColors.primary),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../controller/const/colors.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String initialUrl;
  final String returnBase;

  const PaymentWebViewPage({
    super.key,
    required this.initialUrl,
    required this.returnBase,
  });

  static Future<Map<String, dynamic>?> open(
      BuildContext context, {
        required String url,
        required String returnBase,
      }) {
    return Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => PaymentWebViewPage(initialUrl: url, returnBase: returnBase),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  bool _closing = false;
  String? _matchedUrl; // used to ensure ping+close happens once

  // Convert HTML-escaped query separators (&amp;) to real '&' so Uri parsing works.
  String _fixUrl(String url) => url.replaceAll('&amp;', '&');

  bool _isReturnUrl(String url) {
    final fixed = _fixUrl(url);
    return fixed.startsWith(widget.returnBase);
  }

  Map<String, dynamic> _normalizeResult(String url) {
    final fixed = _fixUrl(url);
    final uri = Uri.parse(fixed);

    final qp = uri.queryParameters;

    final paymentId = qp['paymentId'] ?? qp['PaymentId'] ?? qp['Id'] ?? qp['ID'] ?? '';

    final rawStatus = qp['status'] ?? qp['Status'] ?? '';
    final isSuccessFlag = qp['IsSuccess'] ?? qp['isSuccess'];

    String status;
    if (rawStatus.isNotEmpty) {
      status = rawStatus.toString().toLowerCase();
    } else if (isSuccessFlag != null) {
      final val = isSuccessFlag.toString().toLowerCase();
      status = (val == 'true' || val == '1') ? 'success' : 'failed';
    } else {
      status = 'unknown';
    }

    final ref = qp['ref'] ?? qp['Ref'] ?? qp['CustomerReference'] ?? '';

    return {
      'message': 'Payment result received.',
      'paymentId': paymentId,
      'status': status,
      'ref': ref,
      'url': fixed, // helpful for debugging/logging
    };
  }

  Future<void> _pingBackendOnce(String url) async {
    final fixed = _fixUrl(url);

    // ensure ping happens once per matched url
    if (_matchedUrl == fixed) return;
    _matchedUrl = fixed;

    try {
      log('📡 [WebView] Pinging backend: $fixed');
      await http.get(Uri.parse(fixed)).timeout(const Duration(seconds: 8));
      log('✅ [WebView] Backend ping done');
    } catch (e) {
      log('⚠️ [WebView] Backend ping failed: $e');
    }
  }

  Future<void> _closeWithNormalized(String url, {required String source}) async {
    if (_closing) return;
    _closing = true;

    final normalized = _normalizeResult(url);
    log('✅ [WebView] ($source) Matched returnBase. normalized=$normalized');

    // 1) Ensure backend gets hit even if WebView navigation gets interrupted
    await _pingBackendOnce(url);

    // 2) Give backend some time to commit DB changes
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(normalized);
    }
  }

  bool _handlePossibleReturnUrl(String url, {required String source}) {
    log('🔎 [WebView] ($source) checking url: $url');

    if (!_isReturnUrl(url)) return false;

    // DO NOT pop immediately; close via ping+delay once
    _closeWithNormalized(url, source: source);
    return true;
  }

  @override
  void initState() {
    super.initState();

    log('🧭 [WebView] init with initialUrl=${widget.initialUrl}');
    log('🧭 [WebView] returnBase=${widget.returnBase}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            log('➡️ [WebView] onNavigationRequest: $url');

            final handled = _handlePossibleReturnUrl(url, source: 'onNavigationRequest');

            // IMPORTANT:
            // We allow navigation to proceed so the backend endpoint gets hit by WebView.
            // We will close shortly after via _closeWithNormalized.
            if (handled) return NavigationDecision.navigate;

            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url ?? '';
            if (url.isEmpty) return;

            log('🔄 [WebView] onUrlChange: $url');
            _handlePossibleReturnUrl(url, source: 'onUrlChange');
          },
          onPageStarted: (url) {
            log('⏳ [WebView] onPageStarted: $url');
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            log('🏁 [WebView] onPageFinished: $url');
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            log('❌ [WebView] WebResourceError: ${error.errorCode} - ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
        shadowColor: Colors.grey.shade300,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        elevation: 0,
        title: Text(
          'Payment',
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.blackColor(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
