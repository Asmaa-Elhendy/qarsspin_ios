import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../controller/const/colors.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String initialUrl;
  final String returnBase;

  const PaymentWebViewPage({super.key, required this.initialUrl, required this.returnBase});

  static Future<Map<String, dynamic>?> open(BuildContext context, {
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
            if (url.startsWith(widget.returnBase)) {
              final uri = Uri.parse(url);
              final paymentId = uri.queryParameters['paymentId'] ?? uri.queryParameters['PaymentId'] ?? '';
              final rawStatus = uri.queryParameters['status'] ?? uri.queryParameters['Status'] ?? '';
              final isSuccessFlag = uri.queryParameters['IsSuccess'] ?? uri.queryParameters['isSuccess'];
              String status;
              if (rawStatus.isNotEmpty) {
                status = rawStatus;
              } else if (isSuccessFlag != null) {
                final val = isSuccessFlag.toString().toLowerCase();
                status = (val == 'true' || val == '1') ? 'Success' : 'Failed';
              } else {
                status = 'Unknown';
              }
              final normalized = {
                'message': 'Payment result received.',
                'paymentId': paymentId,
                'status': status,
              };
              log('✅ [WebView] Matched returnBase. normalized=$normalized');
              Navigator.of(context).pop(normalized);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url ?? '';
            if (url.isEmpty) return;
            log('🔄 [WebView] onUrlChange: $url');
            if (url.startsWith(widget.returnBase)) {
              final uri = Uri.parse(url);
              final paymentId = uri.queryParameters['paymentId'] ?? uri.queryParameters['PaymentId'] ?? '';
              final rawStatus = uri.queryParameters['status'] ?? uri.queryParameters['Status'] ?? '';
              final isSuccessFlag = uri.queryParameters['IsSuccess'] ?? uri.queryParameters['isSuccess'];
              String status;
              if (rawStatus.isNotEmpty) {
                status = rawStatus;
              } else if (isSuccessFlag != null) {
                final val = isSuccessFlag.toString().toLowerCase();
                status = (val == 'true' || val == '1') ? 'Success' : 'Failed';
              } else {
                status = 'Unknown';
              }
              final normalized = {
                'message': 'Payment result received.',
                'paymentId': paymentId,
                'status': status,
              };
              log('✅ [WebView] onUrlChange matched returnBase. normalized=$normalized');
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(normalized);
              }
            }
          },
          onPageStarted: (url) {
            log('⏳ [WebView] onPageStarted: $url');
            setState(() => _loading = true);
          },
          onPageFinished: (url) {
            log('🏁 [WebView] onPageFinished: $url');
            setState(() => _loading = false);
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
          elevation: 0, // نشيل الشادو الافتراضي بتاع الـ AppBar
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
              onPressed: () => _controller.reload(), // نفس اللوجيك
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // نفس اللوجيك
            ),
          ],
        ),

        body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
        ],
      ),
    );
  }
}
