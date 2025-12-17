import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/rental_car_model.dart';
import 'package:qarsspin/view/widgets/texts/texts.dart';

import '../../../l10n/app_localization.dart';

class RentalCarInfo extends StatelessWidget {
  RentalCar car;
  RentalCarInfo({required this.car,super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;


    return Container(
      color: AppColors.background(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.remove_red_eye,color: AppColors.accent,size: 16.w,),
                    4.horizontalSpace,
                    blueText(car.visitsCount.toString())
                  ],
                ),
                car.tag=="New"? Container(
                  width: 55.w,
                  height: 23.h,
                  // padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 4.h),
                  decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4).r
                  ),
                  child: Center(
                    child: Text(lc.tag_New,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ):SizedBox()

              ],
            ),
          ),
          20.verticalSpace,
          Padding(            padding:  EdgeInsets.symmetric(horizontal: 6.w),
            child:           headerText(Get.locale?.languageCode=='ar'?car.carNameSL.trim():car.carNamePL.trim(),context),

          ),

          16.verticalSpace,
          Padding(            padding:  EdgeInsets.symmetric(horizontal: 6.w),
            child:           description(Get.locale?.languageCode=='ar'?car.technicalDescriptionSL:car.technicalDescriptionPL,context: context),



          ),

          25.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(car.rectangleImageUrl!),
              ),
              16.horizontalSpace,
              headerText(car.ownerName,context),
              Spacer(),
              Column(
                children: [
                  35.verticalSpace,
                  Text(car.createdDateTime,
                    style: TextStyle(
                      color: AppColors.gray,
                      fontFamily: fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),

                  )


                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
