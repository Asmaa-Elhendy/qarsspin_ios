import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/auth/unregister_func.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/view/screens/auth/my_account.dart';

import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';

class RegisterDialog extends StatefulWidget {
  bool offer;
  bool requestToBuy;
  String price;
  RegisterDialog({this.price = "0",this.requestToBuy = false,this.offer= true,super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {



  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.grey.shade200, // grey background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding:  EdgeInsets.only(top: 22.h,left: 16.w,right: 16.w,bottom: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Title
            Center(
              child: Text(
                lc.not_register,
                style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14.sp, fontWeight: FontWeight.w800,fontFamily: fontFamily),
              ),
            ),
            14.verticalSpace,

            /// Label
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                textAlign: TextAlign.center,
                lc.register_now,

                style: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w300,fontFamily: fontFamily,color: AppColors.black),
              ),
            ),
            14.verticalSpace,


            /// Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonsGray,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child:  Text(lc.btn_Cancel,style: TextStyle(color: AppColors.black),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(MyAccount());
    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child:  Text(lc.register),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}