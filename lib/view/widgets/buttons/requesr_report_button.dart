import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/view/widgets/auth_widgets/register_dialog.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/general/inspection_report.dart';

Widget requestReportButton(context,id){
  final authController = Get.find<AuthController>();
  var lc = AppLocalizations.of(context)!;


  return GestureDetector(
    onTap: ()async{
      await showDialog(
      context: context,
      builder: (_) =>  authController.registered?InspectioDialog(id: id.toString()):RegisterDialog(),
      );
    },
    child: Container(
      width: 400.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration:BoxDecoration(
        color: AppColors.buttonsGray,
          borderRadius: BorderRadius.circular(4).r


      ),
      child:Center(
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/inspection.png",width: 45.w,height: 40.h,),
          //  2.horizontalSpace,
            Text(lc.inspection_report,
            style: TextStyle(
              color: AppColors.blackColor(context),
              fontFamily: fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 13.sp
            ),
            )
          ],
        ),
      ),
    ),
  );



}