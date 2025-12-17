import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/screens/my_ads/gallery_management.dart';
import 'package:qarsspin/view/screens/my_ads/specs_management.dart';
import 'package:qarsspin/model/my_ad_model.dart';
import '../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../l10n/app_localization.dart';
import '../../../model/payment/payment_initiate_request.dart';
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
      required double req360Price,
      required double featuredPrice,
    }) {
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

                  final alreadyRequested = await controller.hasExisting360Request(
                    postId: ad.postId, // أو postId as int على حسب نوعك
                    requestType: 'Request 360 Photo Session',
                  );
                 log('allll $alreadyRequested');
                  if (alreadyRequested) {
                    // فيه request موجود بالفعل
                    SuccessDialog.show(
                      request: true,
                      context: context,
                      title: lc.note,
                        message: lc.youHaveRequestedThisServiceBefore,
                      onClose: () {},
                      onTappp: () {},
                    );

                }else {
                    SuccessDialog.show(
                        request: false,
                        context: context,
                        title: lc.ready_pro,
                        message:
                            //comment payment fr now amira
                        // lc.msg_360_first + ' ${req360Price} ' +
                        //     lc.msg_360_second,
                        lc.msg_360_first +' '+lc.msg_360_second,
                        onClose: () {},
                        onTappp: () async {

                          Navigator.pop(context); //j

                          // handle new payment fatoorah backend
                        //comment payment now amira

                          // 1) Collect contact info (dialog closes immediately and returns data only)
                          // final contactInfo = await ContactInfoDialog.show(
                          //   totalAmount: req360Price,
                          //   req360Amount: req360Price,
                          //   //get price from api
                          //   featuredAmount: 0,
                          //   context: context,
                          //   isRequest360: true,
                          //   isFeauredPost: false,
                          // );
                          // if (contactInfo == null) {
                          //   // user cancelled contact info
                          // } else
                          // {
                       //     try {
                              // 2) Initiate payment using contact info
                              // final paymentController = Get.find<
                              //     PaymentController>();
                              // final String customerName = '${(contactInfo['firstName'] ??
                              //     '')
                              //     .toString()
                              //     .trim()} ${(contactInfo['lastName'] ?? '')
                              //     .toString()
                              //     .trim()}'.trim();
                              // final String email = (contactInfo['email'] ?? '')
                              //     .toString()
                              //     .trim();
                              // final String mobile = (contactInfo['mobile'] ??
                              //     '').toString().trim();
                              //
                              // final result = await paymentController
                              //     .initiatePayment(
                              //   amount: req360Price,
                              //   customerName: customerName.isEmpty
                              //       ? 'Customer'
                              //       : customerName,
                              //   email: email,
                              //   mobile: mobile,
                              // );
                              // log('Payment Initiation Result: $result');
                              //
                              // if (result?['IsSuccess'] == true &&
                              //     result?['Data'] != null &&
                              //     result?['Data']['PaymentMethods'] != null) {
                              //   // 3) Map methods and open NewPaymentMethodsDialog
                              //   final List<dynamic> methodsRaw = List<
                              //       dynamic>.from(
                              //       result!['Data']['PaymentMethods'] as List);
                              //   final methods = methodsRaw
                              //       .map((e) =>
                              //       PaymentMethod.fromJson(
                              //       Map<String, dynamic>.from(e)))
                              //       .toList();
                              //
                              //   final userInformationRequest = PaymentInitiateRequest(
                              //     amount: req360Price,
                              //     customerName: customerName.isEmpty
                              //         ? 'Customer'
                              //         : customerName,
                              //     email: email,
                              //     mobile: mobile,
                              //   );
                              //
                              //   final methodsPayload = await NewPaymentMethodsDialog
                              //       .show(
                              //     context: context,
                              //     paymentMethods: methods,
                              //     userInformationRequest: userInformationRequest,
                              //     isArabic: Get.locale?.languageCode == 'ar',
                              //   );
                              //
                              //   if (methodsPayload != null) {
                              //     Map<String, dynamic>? normalized;
                              //     final invoice = methodsPayload['invoice'] as Map<
                              //         String,
                              //         dynamic>?;
                              //     if (invoice != null) {
                              //       final invoiceResult = await InvoiceLinkDialog
                              //           .show(
                              //         context: context,
                              //         invoiceId: (invoice['invoiceId'] ?? '')
                              //             .toString(),
                              //         paymentId: (invoice['paymentId'])
                              //             ?.toString(),
                              //         paymentUrl: (invoice['paymentUrl'] ?? '')
                              //             .toString(),
                              //         isArabic: (invoice['isArabic'] == true),
                              //       );
                              //       normalized =
                              //       invoiceResult?['normalizedResult'] as Map<
                              //           String,
                              //           dynamic>?;
                              //     } else {
                              //       normalized =
                              //       methodsPayload['normalizedResult'] as Map<
                              //           String,
                              //           dynamic>?;
                              //     }
                              //
                              //     final status = normalized?['status']
                              //         ?.toString();
                              //     final paymentId = normalized?['paymentId']
                              //         ?.toString();
                              //     final bool success = (status != null &&
                              //         status.toLowerCase() == 'success') ||
                              //         (paymentId != null &&
                              //             paymentId.isNotEmpty);
                              //    if (success == true) {
                                    // 🟢 نجاح الدفع
                                    final myAdController = Get.find<
                                        MyAdCleanController>();
                                    onShowLoader();
                                    final ok = await myAdController
                                        .request360Session(
                                      userName: userName,
                                      postId: ad.postId.toString(),
                                      ourSecret: ourSecret,
                                    );
                                    onHideLoader();

                                    if (ok) {
                                      SuccessDialog.show(
                                        request: true,
                                        context: context,
                                        title: lc.confirmation,
                                        message: lc.receive_request_msg,
                                        onClose: () {},
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
                               //   }
                               //    else {
                               //      SuccessDialog.show(
                               //        request: true,
                               //        context: context,
                               //        title: lc.payment_failed,
                               //        message: lc.payment_failed_or_cancelled,
                               //        onClose: () {},
                               //        onTappp: () {},
                               //      );
                               //    }
                            //    }
                              }
                           // }
                  // catch (e, st) {
                  //             log('Payment flow error: $e');
                  //             log('Stack: $st');
                  //             dialog.SuccessDialog.show(
                  //               request: true,
                  //               context: context,
                  //               title: lc.payment_failed,
                  //               message: '${lc.paymentflowfailed} $e',
                  //               onClose: () {
                  //                 Navigator.pop(context);
                  //               },
                  //               onTappp: () {
                  //                 Navigator.pop(context);
                  //               },
                  //             );
                  //           }
                          //}

                      //  }



                    );
                  }},
                w: 185.w,
              ),
              yellowButtons(
                context: context,
                title: lc.feature_ad,
                onTap: () async {
                  final controller = Get.find<MyAdCleanController>();

                  final alreadyRequested = await controller.hasExisting360Request(
                    postId: ad.postId, // أو postId as int على حسب نوعك
                    requestType: 'Request to Feature a Post',
                  );
                  log('allll $alreadyRequested');
                  if (alreadyRequested) {
                    // فيه request موجود بالفعل
                    SuccessDialog.show(
                      request: true,
                      context: context,
                      title: lc.note,
                      message: lc.youHaveRequestedThisServiceBefore,
                      onClose: () {},
                      onTappp: () {},
                    );
                  }else{

                    SuccessDialog.show(
                    request: false,
                    context: context,//
                    title: lc.centered_ad,
                    message:                    lc.feature_ad_msg_first+' '+lc.feature_ad_msg_second,
//comment payment now for amira
                        //     lc.feature_ad_msg_first+' $featuredPrice '+lc.feature_ad_msg_second,
                    onClose: () {},
                    onTappp: () async {
                      // 1) Close confirmation dialog
                      Navigator.pop(context);
// new payment way

                      // 1) Collect contact info (dialog closes immediately and returns data only)
                      // final contactInfo = await ContactInfoDialog.show(
                      //   totalAmount: featuredPrice,
                      //   req360Amount: 0, //get price 360
                      //   featuredAmount: featuredPrice,
                      //   context: context,
                      //   isRequest360: true,
                      //   isFeauredPost: false,
                      // );
                      // if (contactInfo == null) {
                      //   // user cancelled contact info
                      // }
                      // else {
                     //   try {
                          // 2) Initiate payment using contact info
                          // final paymentController = Get.find<PaymentController>();
                          // final String customerName = '${(contactInfo['firstName'] ?? '').toString().trim()} ${(contactInfo['lastName'] ?? '').toString().trim()}'.trim();
                          // final String email = (contactInfo['email'] ?? '').toString().trim();
                          // final String mobile = (contactInfo['mobile'] ?? '').toString().trim();
                          //
                          // final result = await paymentController.initiatePayment(
                          //   amount: featuredPrice,
                          //   customerName: customerName.isEmpty ? 'Customer' : customerName,
                          //   email: email,
                          //   mobile: mobile,
                          // );
                          // log('Payment Initiation Result: $result');
                          //
                          // if (result?['IsSuccess'] == true &&
                          //     result?['Data'] != null &&
                          //     result?['Data']['PaymentMethods'] != null) {
                          //   // 3) Map methods and open NewPaymentMethodsDialog
                          //   final List<dynamic> methodsRaw = List<dynamic>.from(result!['Data']['PaymentMethods'] as List);
                          //   final methods = methodsRaw
                          //       .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
                          //       .toList();
                          //
                          //   final userInformationRequest = PaymentInitiateRequest(
                          //     amount: featuredPrice,
                          //     customerName: customerName.isEmpty ? 'Customer' : customerName,
                          //     email: email,
                          //     mobile: mobile,
                          //   );
                          //
                          //   final methodsPayload = await NewPaymentMethodsDialog.show(
                          //     context: context,
                          //     paymentMethods: methods,
                          //     userInformationRequest: userInformationRequest,
                          //     isArabic: Get.locale?.languageCode == 'ar',
                          //   );
                          //
                          //   if (methodsPayload != null) {
                          //     Map<String, dynamic>? normalized;
                          //     final invoice = methodsPayload['invoice'] as Map<String,
                          //         dynamic>?;
                          //     if (invoice != null) {
                          //       final invoiceResult = await InvoiceLinkDialog.show(
                          //         context: context,
                          //         invoiceId: (invoice['invoiceId'] ?? '').toString(),
                          //         paymentId: (invoice['paymentId'])?.toString(),
                          //         paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
                          //         isArabic: (invoice['isArabic'] == true),
                          //       );
                          //       normalized =
                          //       invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
                          //     } else {
                          //       normalized =
                          //       methodsPayload['normalizedResult'] as Map<String, dynamic>?;
                          //     }
                          //
                          //     final status = normalized?['status']?.toString();
                          //     final paymentId = normalized?['paymentId']?.toString();
                          //     final bool success = (status != null &&
                          //         status.toLowerCase() == 'success') ||
                          //         (paymentId != null && paymentId.isNotEmpty);
                            //  if (success == true) {
                                final myAdController = Get.find<MyAdCleanController>();

                                // 3) After successful payment, send request to server
                                onShowLoader();
                                final ok = await myAdController.requestFeatureAd(
                                  userName: userName,
                                  postId: ad.postId.toString(),
                                  ourSecret: ourSecret,
                                );
                                onHideLoader();

                                if (ok) {
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
                          //    }
                          //     else {
                          //       SuccessDialog.show(
                          //         request: true,
                          //         context: context,
                          //         title: lc.payment_failed,
                          //         message: lc.payment_failed_or_cancelled,
                          //         onClose: () {},
                          //         onTappp: () {},
                          //       );
                          //     }
                            }
                    //}
               //   }
               //    catch (e, st) {
               //            log('Payment flow error: $e');
               //            log('Stack: $st');
               //            dialog.SuccessDialog.show(
               //              request: true,
               //              context: context,
               //              title: lc.payment_failed,
               //              message: 'Payment flow failed: $e',
               //              onClose: () {
               //                Navigator.pop(context);
               //              },
               //              onTappp: () {
               //                Navigator.pop(context);
               //              },
               //            );
               //          }
                  //    }
               //     }


                  );
                }},
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