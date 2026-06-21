import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';

import '../../../controller/communications.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../model/rental_car_model.dart';

class RentalBottomNaviagtion extends StatelessWidget {
  String phone;
  RentalCar rentalCar;
  RentalBottomNaviagtion({required this.phone, required this.rentalCar,super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Container(
      height: 90.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 20.h),
      decoration: BoxDecoration(
          color: AppColors.background(context)
      ),
      child: Row(
        spacing: 18.w,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          myButtons(title:
          Row(children: [
            8.horizontalSpace,
            Image.asset("assets/images/callNow.png",scale: .1.w,),
            8.horizontalSpace,
            Text(
              lc.call_now,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.black
              ),
            )
          ],) ,onTap: (){
            makePhoneCall(phone.trim());
          },),
          myButtons(title:Row(children: [
            8.horizontalSpace,
            Image.asset("assets/images/whats.png"),
            8.horizontalSpace,
            Text(
              lc.whats_app,
              style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.white
              ),
            )
          ],), onTap: (){
            openWhatsApp(phone.trim(), message: "Hello 👋,Hi, I’m interested in your ${Get.locale?.languageCode=='ar'?rentalCar.carNameSL.trim():rentalCar.carNamePL.trim()} ${rentalCar.manufactureYear}.The Chassis Number is: ${rentalCar.chassisNumber}");
            //openWhatsApp(phone, message: "Hello 👋");
          },green: true),


        ],
      ),
    );
  }

  Widget myButtons({required Widget title,required var onTap,bool green = false}){

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(horizontal: 22.w,vertical: 12.h),
        decoration: BoxDecoration(
          color: green?AppColors.publish:AppColors.primary,
          borderRadius: BorderRadius.circular(4), // optional rounded corners

        ),
        child: title,
      ),

    );

  }
}
