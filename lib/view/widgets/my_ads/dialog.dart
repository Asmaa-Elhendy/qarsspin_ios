import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../payments/payment_methods_dialog.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onClose;
  final dynamic onTap;
  final bool request; //for request 360, feature confirmation alert

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onClose,
    required this.onTap,
    required this.request //for request 360, feature confirmation alert

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.toastBackground,
      shape: RoundedRectangleBorder( // 👈 دي اللي بتشيل أي radius
        borderRadius: BorderRadius.circular(4),
      ),


      //insetPadding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 16.h),
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 25.w,vertical: 16.h),
        height: request?250.h:360.h, //update height of alert when req 360
        decoration: BoxDecoration(
          //color: Colors.white,
          borderRadius: BorderRadius.zero,

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 15.sp,
              ),
            ),
            8.verticalSpace,
            Text(message,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: AppColors.white,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
              ),

            ),
            18.verticalSpace,
            request?
            cancelButton((){
              Navigator.pop(context);
            },lc.btn_Close,request)
                :Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cancelButton((){
                  Navigator.pop(context);
                },lc.btn_Cancel,request),
                10.horizontalSpace,
                yellowButtons(title:lc.btn_Confirm,onTap:onTap,
                    context: context

                    ,w: 95.w)

              ],
            )
          ],//l
        ),

      ),
    );
  }

  // Helper method to show the dialog
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onClose,
    final dynamic onTappp,
    required final bool request //for request 360, feature confirmation alert
  }) {
    bool callbackCalled = false;

    void callOnCloseOnce() {
      if (!callbackCalled && onClose != null) {
        callbackCalled = true;
        onClose();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
          title: title,
          message: message,
          onClose: () {
            Navigator.of(context).pop();
            callOnCloseOnce();
          },
          onTap: onTappp,
          request:request
      ),
    ).then((_) {
      // This will be called when the dialog is dismissed in any way
      callOnCloseOnce();
    });
  }}
cancelButton(ontap,title,reuest){
  return InkWell(
    onTap: ontap,
    child: Container(
      width:reuest?230.w: 95.w,
      padding: EdgeInsets.symmetric(horizontal: 18.w,vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.logoGray,
        borderRadius: BorderRadius.circular(4), // optional rounded corners

      ),
      child: Center(
        child: Text(title,

          style: TextStyle(
            color: AppColors.black,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
          ),
        ),
      ),
    ),

  );
}