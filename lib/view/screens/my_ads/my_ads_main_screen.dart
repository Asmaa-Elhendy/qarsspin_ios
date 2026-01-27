import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'dart:io' show Platform;
import '../../../controller/ads/data_layer.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../controller/my_ads/my_ad_data_layer.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../l10n/app_localization.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/my_ads/my_ad_card.dart';

class MyAdsMainScreen extends StatefulWidget {
  const MyAdsMainScreen({super.key});

  @override
  State<MyAdsMainScreen> createState() => _MyAdsMainScreenState();
}

class _MyAdsMainScreenState extends State<MyAdsMainScreen> {
  final authController = Get.find<AuthController>();
  late final MyAdCleanController controller;
  bool _isLoading = false;
 double req360Amount=0;
 double featuredAmount=0;
  @override
  void initState() {
    super.initState();
    _initializeController();
    _setupLoadingListener();
    final paymentController = Get.find<PaymentController>();
    final services = paymentController.individualQarsServices;
    // خدمة 360
    final request360Service = services.firstWhereOrNull(
          (s) => s.qarsServiceName == 'Request to 360',
    );
    if (request360Service != null) {
      req360Amount = request360Service.qarsServicePrice.toDouble();
    }
    // خدمة Feature Ad
    final featureService = services.firstWhereOrNull(
          (s) => s.qarsServiceName == 'Request to feature',
    );
    if (featureService != null) {
      featuredAmount = featureService.qarsServicePrice.toDouble();
    }
  }

  void _setupLoadingListener() {
    ever(controller.isLoadingMyAds, (isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading as bool;
        });
      }
    });

    // Initial check
    if (controller.isLoadingMyAds.value == true) {
      _isLoading = true;
    }
  }

  Future<void> _initializeController() async {
    try {
      controller = Get.put(MyAdCleanController(MyAdDataLayer()));
      if (authController.registered) {
        await _fetchMyAds();
      }
    } catch (e) {
      print('Error initializing controller: $e');
    }
  }

  Future<void> _fetchMyAds() async {
    log('herreeeeeeeeeeeeeeeeee ${authController.userFullName!}');
    if (authController.userName != null && authController.userName!.isNotEmpty) {
      await controller.fetchMyAds(
        userName: authController.userFullName!,
        ourSecret: ourSecret,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.blackColor(context),
            size: 24.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lc.adv_lbl,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blackColor(context),
                fontFamily: 'Gilroy',
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "${lc.active_ads} ${controller.activeAdsCount} ${lc.of_lbl} ${controller.myAds.length}",
              style: TextStyle(
                color: AppColors.blackColor(context),
                fontFamily: 'Gilroy',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )),
        backgroundColor: AppColors.background(context),
        toolbarHeight: Platform.isAndroid?60.h:68.h,
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
      ),

      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          // Main content
          Obx(() {
            if (controller.myAdsError.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.myAdsError.value!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchMyAds,
                      child: Text(lc.retry),
                    ),
                  ],
                ),
              );
            }

            if (controller.myAds.isEmpty && !_isLoading) {
              return Center(
                child: Text(
                  'No ads available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchMyAds,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.myAds.length,
                itemBuilder: (context, index) {
                  final ad = controller.myAds[index];
                  return MyAdCard(
                    authController.userName!,
                    ad,
                    context,
                    onShowLoader: () => setState(() => _isLoading = true),
                    onHideLoader: () => setState(() => _isLoading = false),
                    // req360Price: req360Amount,
                    // featuredPrice: featuredAmount,

                  );
                },
              ),
            );
          }),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Center(
                child: AppLoadingWidget(
                  title: 'Loading...',
                ),
              ),
            ),
        ],
      ),
    );
  }
}