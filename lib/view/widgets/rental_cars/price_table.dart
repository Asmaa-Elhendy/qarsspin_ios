import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/rental_car_model.dart';

import '../../../l10n/app_localizations.dart';

class PriceTable extends StatelessWidget {
  RentalCar car;
   PriceTable({required this.car,super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return SizedBox(
      height: 160.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(

          children: [
            dataRow(lc.daily, double.parse(car.rentPerDay)==0?"-":car.rentPerDay,lc, true,context),
            4.verticalSpace,
            dataRow(lc.weekly, double.parse(car.rentPerWeek)==0?"-":car.rentPerWeek, lc,false,context),
            4.verticalSpace,
            dataRow(lc.monthly, double.parse(car.rentPerMonth)==0?"-":car.rentPerMonth, lc,true,context),
      
      
          ],
        ),
      ),
    );
  }

  dataRow(String key, value,lc,bool grey,context){
    return Row(
      children: [
        Container(
         width: 170.w,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all( color: AppColors.white, width: 0.2),

            color:  Theme.of(context).brightness == Brightness.dark?AppColors.background(context):
            grey?AppColors.extraLightGray:AppColors.white,

          ),

          child: Center(
            child: Text(key,
            style: TextStyle(
              color: AppColors.blackColor(context),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400
            ),
            ),
          ),
        ),
        Container(
          width: 3.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.transparent
            //color: AppColors.background(context)
          ),
        ),
        Container(
         width: 170.w,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all( color: AppColors.white, width: 0.2),
            color:  Theme.of(context).brightness == Brightness.dark?AppColors.background(context):
            grey?AppColors.extraLightGray:AppColors.white,


          ),

          child: Center(
            child: Text(value=="-"?value:"$value ${lc.currency_Symbol}",
              style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),

      ],
    );
  }
}
