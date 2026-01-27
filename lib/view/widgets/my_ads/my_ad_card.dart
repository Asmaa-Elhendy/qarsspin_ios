import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/auth/auth_controller.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/screens/my_ads/gallery_management.dart';
import 'package:qarsspin/view/screens/my_ads/specs_management.dart';
import 'package:qarsspin/model/my_ad_model.dart';
import '../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../controller/payments/payment_helper.dart';
import '../../../l10n/app_localization.dart';
import '../../../model/payment/payment_method_model.dart';
import '../../screens/ads/create_new_ad.dart';
import '../../widgets/my_ads/dialog.dart';
import '../../widgets/my_ads/yellow_buttons.dart';
import 'package:qarsspin/view/widgets/payments/payment_methods_dialog.dart';

import '../ads/dialogs/contact_info_dialog.dart';

import '../../widgets/my_ads/dialog.dart' as dialog;


String fontFamily =Get.locale?.languageCode=='ar'?'noor':'Gilroy';
Widget MyAdCard(
    String userName,
    MyAdModel ad,
    BuildContext context, {
      required VoidCallback onShowLoader,
      required VoidCallback onHideLoader,
      // required double req360Price,
      // required double featuredPrice,
    }) {
  final paymentController = Get.find<PaymentController>();
  var lc = AppLocalizations.of(context)!;
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
    padding: EdgeInsets.only(bottom: 12.h),
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.background(context),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.white),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 8,
          spreadRadius: 2,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 260.h,
          child: ad.rectangleImageUrl != null
              ? Image.network(
            ad.rectangleImageUrl!,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/images/car2-removebg-preview.png",
                fit: BoxFit.fill,
              );
            },
          )
              : Image.asset(
            "assets/images/logo_the_q.png",
            fit: BoxFit.fill,
          ),
        ),5.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ad.postKind,
                  style: TextStyle(
                    color: AppColors.blackColor(context),
                    fontFamily: fontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Flexible(
              //   child:
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: AppColors.extraLightGray.withOpacity(.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  ad.postStatus,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14.sp,
                    color: AppColors.blackColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              //   ),
              5.horizontalSpace,
              GetBuilder<MyAdCleanController>(
                builder: (controller) {
                  return InkWell(
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              lc.delete_ad,
                              style: TextStyle(
                                fontSize: 19.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content:  Text(lc.delete_ad_confirm_msg),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  lc.btn_Cancel,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child:  Text(lc.delete),
                              ),
                            ],
                          );
                        },
                      );

                      if (result == true) {
                        try {
                          onShowLoader();
                          await controller.deleteAd(
                            ad.postId.toString(),
                            userName,
                          );
                        } finally {
                          onHideLoader();
                        }
                      }
                    },
                    child: Icon(
                      Icons.delete_outline,
                      color: const Color(0xffEC6D64),
                      size: 27.w,
                    ),
                  );
                },
              )
            ],
          ),
        ),
        ad.postStatus == 'Rejected' ?  Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(ad.rejectedReason??'',

              //  'upload the car photos and publish the post then request for 360',

              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              softWrap: true,
            )):SizedBox(),5.verticalSpace
        ,
        6.verticalSpace,

        /// أزرار (360 و Feature)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              yellowButtons(
                context: context,
                title: lc.request_360,
                onTap: () async {
                  final controller = Get.find<MyAdCleanController>();

                //   final alreadyRequested = await controller.hasExisting360Request(
                //     postId: ad.postId, // أو postId as int على حسب نوعك
                //     requestType: 'Request 360 Photo Session',
                //   );
                //  log('allll $alreadyRequested');
                //   if (alreadyRequested) {
                //     // فيه request موجود بالفعل
                //     SuccessDialog.show(
                //       request: true,
                //       context: context,
                //       title: lc.note,
                //         message: lc.youHaveRequestedThisServiceBefore,
                //       onClose: () {},
                //       onTappp: () {},
                //     );
                //
                // }
                  final decision = await controller.checkQarsDecision(
                    postId: ad.postId,
                    requestType: 'Request 360 Photo Session',
                  );

                  if (decision == QarsDecision.completed) {
                    SuccessDialog.show(
                      request: true,
                      context: context,
                      title: lc.note,
                      message: lc.youHaveRequestedThisServiceBefore, // "you already have this service"
                      onClose: () {},
                      onTappp: () {},
                    );
                  } else if (decision == QarsDecision.pending) {
                    SuccessDialog.show(
                      request: true,
                      context: context,
                      title: lc.note,
                      message: lc.wait_admin_approval,
                      onClose: () {},
                      onTappp: () {},
                    );
                  }
                  else {

                  SuccessDialog.show(
                        request: false,
                        context: context,
                        title: lc.ready_pro,
                        message:
                        lc.msg_360_first + ' ${paymentController.request360ServicePrice} ' +
                            lc.msg_360_second,
                        onClose: () {},
                        onTappp: () async {

                          Navigator.pop(context); //j

                          // handle new payment fatoorah backend


                    //      1) Collect contact info (dialog closes immediately and returns data only)
                          final contactInfo = await ContactInfoDialog.show(
                            totalAmount: paymentController.request360ServicePrice!,
                            req360Amount: paymentController.request360ServicePrice!,
                            //get price from api
                            featuredAmount: 0,
                            context: context,
                            isRequest360: true,
                            isFeauredPost: false,
                          );
                          if (contactInfo == null) {
                            // user cancelled contact info
                          } else
                          {
                           try {
                           //   2) Initiate payment using contact info
                              final paymentController = Get.find<
                                  PaymentController>();
                              final String customerName = '${(contactInfo['firstName'] ??
                                  '')
                                  .toString()
                                  .trim()} ${(contactInfo['lastName'] ?? '')
                                  .toString()
                                  .trim()}'.trim();
                              final String email = (contactInfo['email'] ?? '')
                                  .toString()
                                  .trim();
                              final String mobile = (contactInfo['mobile'] ??
                                  '').toString().trim();

                              final result = await paymentController
                                  .initiatePayment(
                                postId: ad.postId,
                                serviceIds: [paymentController.request360ServiceId!],
                                amount: paymentController.request360ServicePrice!,
                                customerName: customerName.isEmpty
                                    ? 'Customer'
                                    : customerName,
                                email: email,
                                mobile: mobile,
                                externalUser: Get.find<AuthController>().userName!
                              );
                              log('Payment Initiation Result: $result');

                              if (result?['myFatoorahRawJson']?['IsSuccess'] == true &&
                                  result?['myFatoorahRawJson']?['Data'] != null &&
                                  result?['myFatoorahRawJson']?['Data']['PaymentMethods'] != null) {
                                // 3) Map methods and open NewPaymentMethodsDialog
                                final List<dynamic> methodsRaw = List<
                                    dynamic>.from(
                                    result!['myFatoorahRawJson']['Data']['PaymentMethods'] as List);
                                final methods = methodsRaw
                                    .map((e) =>
                                    PaymentMethod.fromJson(
                                    Map<String, dynamic>.from(e)))
                                    .toList();

                                final orderMasterId = result?['masterOrderId'] as int?;
                                if (orderMasterId == null) {
                                  throw Exception('No orderMasterId in payment initiation response');
                                }

                                final methodsPayload = await NewPaymentMethodsDialog
                                    .show(
                                  context: context,
                                  paymentMethods: methods,
                                  isArabic: Get.locale?.languageCode == 'ar',
                                  orderMasterId: orderMasterId,
                                  initiateResponse: result,
                                );

                                if (methodsPayload != null) {
                                  Map<String, dynamic>? normalized;
                                  final invoice = methodsPayload['invoice'] as Map<
                                      String,
                                      dynamic>?;
                                  if (invoice != null) {
                                    final invoiceResult = await InvoiceLinkDialog
                                        .show(
                                      context: context,
                                      invoiceId: (invoice['invoiceId'] ?? '')
                                          .toString(),
                                      paymentId: (invoice['paymentId']??'')
                                          ?.toString(),
                                      paymentUrl: (invoice['paymentUrl'] ?? '')
                                          .toString(),
                                      isArabic: (invoice['isArabic'] == true),
                                    );
                                    normalized =
                                    invoiceResult?['normalizedResult'] as Map<
                                        String,
                                        dynamic>?;
                                  } else {
                                    normalized =
                                    methodsPayload['normalizedResult'] as Map<
                                        String,
                                        dynamic>?;
                                  }
                              log("after my fatoorah $normalized");
                                  final status = normalized?['status']
                                      ?.toString();
                                  final paymentId = normalized?['paymentId']
                                      ?.toString();
                                  final bool success = (status != null &&
                                      status.toLowerCase() == 'success') &&
                                      (paymentId != null &&
                                          paymentId.isNotEmpty);
                                 if (success == true) {
                                    // 🟢 نجاح الدفع

                                      SuccessDialog.show(
                                        request: true,
                                        context: context,
                                        title: lc.confirmation,
                                        message: lc.receive_request_msg,
                                        onClose: () {},
                                        onTappp: () {},
                                      );
                                    }

                                  else {
                                    SuccessDialog.show(
                                      request: true,
                                      context: context,
                                      title: lc.payment_failed,
                                      message: lc.payment_failed_or_cancelled,
                                      onClose: () {},
                                      onTappp: () {},
                                    );
                                  }
                               }
                              }
                           }
                  catch (e, st) {
                              log('Payment flow error: $e');
                              log('Stack: $st');
                              dialog.SuccessDialog.show(
                                request: true,
                                context: context,
                                title: lc.payment_failed,
                                message: '${lc.paymentflowfailed} $e',
                                onClose: () {
                                  Navigator.pop(context);
                                },
                                onTappp: () {
                                  Navigator.pop(context);
                                },
                              );
                            }
                          }

                       }



                    );
                  }},
              //  handle with new check service before api
                // //new way with new check request
                // onTap: () async {
                //   final serviceId = paymentController.request360ServiceId;
                //   final price = paymentController.request360ServicePrice;
                //
                //   if (serviceId == null || price == null) {
                //     SuccessDialog.show(
                //       request: true,
                //       context: context,
                //       title: lc.info,
                //       message: 'Service data is loading, please try again.',
                //       onClose: () {},
                //       onTappp: () {},
                //     );
                //     return;
                //   }
                //
                //   await handleServiceTap(
                //     context: context,
                //     lc: lc,
                //     paymentController: paymentController,
                //     postId: ad.postId,
                //     userName: userName,
                //     qarsServiceId: serviceId,
                //     servicePrice: price,
                //     isRequest360: true,
                //     isFeatured: false,
                //     confirmTitle: lc.ready_pro,
                //     confirmMessage: lc.msg_360_first + ' $price ' + lc.msg_360_second,
                //   );
                // },

                w: 185.w,
              ),
              yellowButtons(
                context: context,
                title: lc.feature_ad,
                onTap: () async {
                  final controller = Get.find<MyAdCleanController>();

                  // final alreadyRequested = await controller.hasExisting360Request(
                  //   postId: ad.postId, // أو postId as int على حسب نوعك
                  //   requestType: 'Request to Feature a Post',
                  // );
                  // log('allll $alreadyRequested');
                  // if (alreadyRequested) {
                  //   // فيه request موجود بالفعل
                  //   SuccessDialog.show(
                  //     request: true,
                  //     context: context,
                  //     title: lc.note,
                  //     message: lc.youHaveRequestedThisServiceBefore,
                  //     onClose: () {},
                  //     onTappp: () {},
                  //   );

                final decision = await controller.checkQarsDecision(
              postId: ad.postId,
                requestType: "Request to Feature a Post",
              );

            if (decision == QarsDecision.completed) {
  SuccessDialog.show(
  request: true,
  context: context,
  title: lc.note,
  message: lc.youHaveRequestedThisServiceBefore, // "you already have this service"
  onClose: () {},
  onTappp: () {},
  );
  } else if (decision == QarsDecision.pending) {
    SuccessDialog.show(
      request: true,
      context: context,
      title: lc.note,
      message: lc.wait_admin_approval,
      onClose: () {},
      onTappp: () {},
    );
  } else {

                    SuccessDialog.show(
                    request: false,
                    context: context,//
                    title: lc.centered_ad,
                    message:       //             lc.feature_ad_msg_first+' '+lc.feature_ad_msg_second,
//comment payment now for amira
                             lc.feature_ad_msg_first+' ${paymentController.featuredServicePrice} '+lc.feature_ad_msg_second,
                    onClose: () {},
                    onTappp: () async {
                      // 1) Close confirmation dialog
                      Navigator.pop(context);
// new payment way

                      // 1) Collect contact info (dialog closes immediately and returns data only)
                      final contactInfo = await ContactInfoDialog.show(
                        totalAmount: paymentController.featuredServicePrice!,
                        req360Amount: 0, //get price 360
                        featuredAmount: paymentController.featuredServicePrice!,
                        context: context,
                        isRequest360: false,
                        isFeauredPost: true,
                      );
                      if (contactInfo == null) {
                        // user cancelled contact info
                      }
                      else {
                       try {
                        //  2) Initiate payment using contact info
                       //   final paymentController = Get.find<PaymentController>();
                          final String customerName = '${(contactInfo['firstName'] ?? '').toString().trim()} ${(contactInfo['lastName'] ?? '').toString().trim()}'.trim();
                          final String email = (contactInfo['email'] ?? '').toString().trim();
                          final String mobile = (contactInfo['mobile'] ?? '').toString().trim();

                          final result = await paymentController .initiatePayment(
                      postId: ad.postId,
                      serviceIds: [paymentController.featuredServiceId!],
                      amount: paymentController.featuredServicePrice!,
                      customerName: customerName.isEmpty
                      ? 'Customer'
                          : customerName,
                      email: email,
                      mobile: mobile,
                      externalUser: Get.find<AuthController>().userName!
                      );
                          log('Payment Initiation Result: $result');

                          if (result?['myFatoorahRawJson']?['IsSuccess'] == true &&
                              result?['myFatoorahRawJson']?['Data'] != null &&
                              result?['myFatoorahRawJson']?['Data']['PaymentMethods'] != null) {

                            final List<dynamic> methodsRaw = List<dynamic>.from(
                              result!['myFatoorahRawJson']['Data']['PaymentMethods'] as List,
                            );

                            final methods = methodsRaw
                                .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
                                .toList();

                            // Get the orderMasterId from the result
                            final orderMasterId = result['masterOrderId'] as int?;
                            if (orderMasterId == null) {
                              throw Exception('No orderMasterId in payment initiation response');
                            }

                            // Show payment methods dialog with the initiated payment data
                            final methodsPayload = await NewPaymentMethodsDialog.show(
                              context: context,
                              paymentMethods: methods,
                              isArabic: Get.locale?.languageCode == 'ar',
                              orderMasterId: orderMasterId,
                              initiateResponse: result,
                            );

                            if (methodsPayload != null) {
                              Map<String, dynamic>? normalized;
                              final invoice = methodsPayload['invoice'] as Map<String,
                                  dynamic>?;
                              if (invoice != null) {
                                final invoiceResult = await InvoiceLinkDialog.show(
                                  context: context,
                                  invoiceId: (invoice['invoiceId'] ?? '').toString(),
                                  paymentId: (invoice['paymentId'])?.toString(),
                                  paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
                                  isArabic: (invoice['isArabic'] == true),
                                );
                                normalized =
                                invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
                              } else {
                                normalized =
                                methodsPayload['normalizedResult'] as Map<String, dynamic>?;
                              }

                              final status = normalized?['status']?.toString();
                              final paymentId = normalized?['paymentId']?.toString();
                              final bool success =
                                  (status != null && status.toLowerCase() == 'success') &&
                                      (paymentId != null && paymentId.isNotEmpty);

                              if (success == true) {

                                  SuccessDialog.show(
                                    request: true,
                                    context: context,
                                    title: lc.confirmation,
                                    message:lc.receive_request_msg,
                                    onClose: () {},
                                    onTappp: () {},
                                  );
                                }
                                else {
                                  SuccessDialog.show(
                                    request: true,
                                    context: context,
                                    title: lc.cancellation,
                                    message: lc.request_failed,
                                    onClose: () {},
                                    onTappp: () {},
                                  );
                                }
                            }

                 }}
                  catch (e, st) {
                          log('Payment flow error: $e');
                          log('Stack: $st');
                          dialog.SuccessDialog.show(
                            request: true,
                            context: context,
                            title: lc.payment_failed,
                            message: 'Payment flow failed: $e',
                            onClose: () {
                              Navigator.pop(context);
                            },
                            onTappp: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                     }
                   }


                  );
                }},
       //       handle with new check service before api
                //handel new way foe check request
                // onTap: () async {
                //   final serviceId = paymentController.featuredServiceId;
                //   final price = paymentController.featuredServicePrice;
                //
                //   if (serviceId == null || price == null) {
                //     SuccessDialog.show(
                //       request: true,
                //       context: context,
                //       title: lc.info,
                //       message: 'Service data is loading, please try again.',
                //       onClose: () {},
                //       onTappp: () {},
                //     );
                //     return;
                //   }
                //
                //   await handleServiceTap(
                //     context: context,
                //     lc: lc,
                //     paymentController: paymentController,
                //     postId: ad.postId,
                //     userName: userName,
                //     qarsServiceId: serviceId,
                //     servicePrice: price,
                //     isRequest360: false,
                //     isFeatured: true,
                //     confirmTitle: lc.centered_ad,
                //     confirmMessage: lc.feature_ad_msg_first + ' $price ' + lc.feature_ad_msg_second,
                //   );
                // },

                w: 185.w,
              ),
            ],
          ),
        ),
        6.verticalSpace,

        /// أزرار (Modify, Specs, Gallery, Publish)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: yellowButtons(
                        context: context,
                        title: lc.modify,
                        onTap: () {
                          Get.to(
                            SellCarScreen(
                              postData: {
                                'postId': ad.postId.toString(),
                                'postKind': ad.postKind ?? 'CarForSale',
                                'isModifyMode': true,
                                'userName': ad.userName,
                                'PostStatus':ad.postStatus
                              },
                            ),
                          );

                        },
                        w: double.infinity,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: yellowButtons(
                        context: context,
                        title: lc.specs,
                        onTap: () {
                          Get.to(SpecsManagemnt(postId: ad.postId.toString()));
                        },
                        w: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: yellowButtons(
                        context: context,
                        title: lc.gallery,
                        onTap: () {
                          // Navigate to GalleryManagement and auto-refresh when returning
                          Get.to(
                            GalleryManagement(
                              postId: ad.postId,
                              postKind: ad.postKind,
                              userName: ad.userName,
                            ),
                          )?.then((_) {//j
                            // Auto-refresh MyAdsMainScreen when returning from GalleryManagement
                            log('✅ [DEBUG] Returned from GalleryManagement, silent refreshing MyAdsMainScreen');
                            final controller = Get.find<MyAdCleanController>();
                            controller.silentRefreshMyAds(); // Silent refresh without loader
                          });
                        },
                        w: double.infinity,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: yellowButtons(
                        context: context,
                        title: lc.publish,
                        onTap: () async {
                          if(ad.postStatus!="Pending Approval"){
                            final myAdController = Get.find<MyAdCleanController>();

                            onShowLoader();
                            final ok = await myAdController.requestPublishAd(
                              userName: userName,
                              postId: ad.postId.toString(),
                              ourSecret: ourSecret,
                            );
                            onHideLoader();

                            if (ok) {
                              // Show success dialog and refresh ads when it's closed
                              SuccessDialog.show(
                                request: true,
                                context: context,
                                title: lc.confirmation,
                                message:
                                lc.receive_request_msg,
                                onClose: () {//l
                                  // Refresh the ads list when the dialog is closed
                                  print('🔄 [REFRESH] Closing dialog, refreshing ads...');
                                  final myAdController = Get.find<MyAdCleanController>();
                                  myAdController.fetchMyAds(userName: userName, ourSecret: ourSecret);
                                  print('🔄 [REFRESH] Ads refresh initiated');//k
                                },
                                onTappp: () {},
                              );
                            } else {
                              SuccessDialog.show(
                                request: true,
                                context: context,
                                title: lc.cancellation,
                                message: lc.request_failed,
                                onClose: () {},
                                onTappp: () {},
                              );
                            }
                          }else{
                            SuccessDialog.show(
                              request: true,
                              context: context,
                              title: lc.info,
                              message:
                              lc.waiting_ad_approval,
                              onClose: () {//l
                                // Refresh the ads list when the dialog is closed
                                print('🔄 [REFRESH] Closing dialog, refreshing ads...');
                                // final myAdController = Get.find<MyAdCleanController>();
                                // myAdController.fetchMyAds();
                                print('🔄 [REFRESH] Ads refresh initiated');//k
                              },
                              onTappp: () {},
                            );
                          }

                        },
                        green: true,
                        w: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        6.verticalSpace,

        /// التاريخ
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            "${lc.creation_date} ${ad.createdDateTime.split(' ')[0]} - ${lc.ex_date} ${ad.expirationDate.split(' ')[0]}",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5.sp,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}