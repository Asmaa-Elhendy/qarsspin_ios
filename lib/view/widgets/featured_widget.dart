import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/const/colors.dart';
import '../../l10n/app_localizations.dart';

Widget featuredContainer(context){
  var lc = AppLocalizations.of(context)!;


  return Container( //update asmaa
    width: 100.w,
    height: 22.h,
    padding: EdgeInsets.symmetric(horizontal: 10.w),

    decoration: BoxDecoration(
        color: AppColors.danger

    ),
    child: Center(
      child: Text(lc.featured,

        style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500
        ),
      ),
    ),

  );
}