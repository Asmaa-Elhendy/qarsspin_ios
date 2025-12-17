import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import '../../controller/const/colors.dart';
import '../../l10n/app_localization.dart';
import '../../l10n/l10n.dart';
import '../../model/car_model.dart';
import '../screens/cars_for_sale/car_details.dart';
import 'featured_widget.dart';

Widget carCard({
  required CarModel car,
  bool large = false,
  required double w,
  required double h,
  required String postKind,
  bool tooSmall = false,
  required BuildContext context
}) {
// }) {
  double price = double.tryParse(car.askingPrice.toString()) ?? 0.0;
  var lc = AppLocalizations.of(context)!;


  String formattedPrice = NumberFormat.currency(//update currency asmaa
      locale: 'en_US',
      symbol: '',      // empty if you don't want $ sign
      decimalDigits: 0 // remove decimals
  ).format(price);


  return GestureDetector(
    onTap: () {

      if(postKind!=""){
        print("Good job");
        Get.find<BrandController>().switchOldData();
        Get.find<BrandController>().getCarDetails(postKind, car.postId.toString(),context: context);
        Get.to(CarDetails(sourcekind:car.sourceKind,postKind: car.postKind,id: car.postId,mobile: car.ownerMobile));


      }else{
        print("un available source kind");
      }
    },
    child: Padding(
      padding:  EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        width: w,
        height: h, // خلي height متاحة زي ما طلبت
        decoration: BoxDecoration(
          color: AppColors.carCardBackground(context),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:car.tag== "Sold"?AppColors.danger:car.tag=="Inspected"?AppColors.primary:car.tag=="New"?AppColors.success:Colors.transparent,
            width: 1.7.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset.zero, // shadow حول كل الكارد
              blurRadius: 6,
              spreadRadius:0.1 ,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // الصورة
            Stack(
              children: [
                SizedBox(
                  height: 117.h,
                  child: Stack(
                    children: [
                      ClipRRect(

                        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                        child: CachedNetworkImage(
                          //edit placeholder for now asmaa
                          imageUrl: car.rectangleImageUrl.isNotEmpty
                              ? car.rectangleImageUrl
                              : "https://via.placeholder.com/150",
                          height: tooSmall
                              ? 90.h
                              : large
                              ? 150.h
                              : 124.9.h,
                          //i update default height for all cars card car asmaa
                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorWidget: (context, url, error) =>
                              Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                      car.tag!="No Tag"?
                      Positioned(
                          top: 0,
                          left: 45.w,
                          right: 45.w,

                          child: tagContainer(car.tag, context))
                          :SizedBox()
                    ],
                  ),
                ),
                if (car.pinToTop == 1)
                  Positioned(bottom: 3, left: 3.w, child: featuredContainer(context)),
              ],
            ),

            // محتوى الكارد
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: .3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5.h, bottom: 1.h,left: 6.w), // no horizontal padding
                      child: SizedBox(height: 45.h,
                        child: Text(
                          Get.locale?.languageCode=='ar'?car.carNameSl :car.carNamePl.trim(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),

                    SizedBox(height: tooSmall ? .5.h : 4.h),
                    Container(padding: EdgeInsets.only(left: 6.w), //update asmaa
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          carStatus(

                              car.sourceKind == "Individual"
                                  ? CarStatus.personal
                                  : car.sourceKind == "Qars Spin"
                                  ? CarStatus.qarsSpin
                                  : CarStatus.showroom,context
                          ),
                          SizedBox(height: tooSmall?2.h:5.h),
                          Row(
                            children: [
                              Text(
                                "${formattedPrice} " ,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                lc.currency_Symbol,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: tooSmall?4.h:3.h),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/new_svg/ic_calendar.svg',
                                width: 25.w,
                                height:tooSmall?16.h: 18.h,
                                color: AppColors.gray,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                car.manufactureYear.toString(),
                                style: TextStyle(
                                  color: AppColors.mutedGray,
                                  fontSize: tooSmall?12.sp:14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                width: 1.5.w,
                                height: tooSmall?12.h:15.h,
                                color: AppColors.textSecondary(context),
                              )
                              ,
                              SvgPicture.asset(
                                'assets/images/new_svg/ic_mileage.svg',
                                width: 25.w,
                                height: 20.h,
                                color: AppColors.gray,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                car.mileage.toString(),
                                style: TextStyle(
                                  color: AppColors.mutedGray,
                                  fontSize: tooSmall?12.sp:14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget carStatus(CarStatus status,context) {
  var lc = AppLocalizations.of(context)!;


  return Container(
    width: 93.w,   //update asmaa
    height: 23.h,
    padding: EdgeInsets.symmetric(horizontal: 10.w,),//update

    decoration: BoxDecoration(
      color: status == CarStatus.personal
          ? AppColors.success
          : status == CarStatus.showroom
          ? AppColors

          .accent
          : AppColors.divider(context),
    ),

    child: status == CarStatus.qarsSpin
        ? SizedBox(
      width: 40.w,
      height: 23.h,
      child: Image.asset(
        "assets/images/ic_top_logo_colored.png",
        fit: BoxFit.cover,
      ),
    )
        : Center(
      child: Text(
        lc.getText(getCarStatusKey(status)),
        //getCarStatusName(status, lc),
        //lc.translate('CarStatus_${status.name}'),

        style: TextStyle(color: Colors.white, fontSize: 13.sp,fontFamily: fontFamily),
      ),
    ),
  );
}
String getCarStatusKey(CarStatus status) {
  switch (status) {
    case CarStatus.personal:
      return 'carStatus_personal';
    case CarStatus.showroom:
      return 'carStatus_showroom';
    case CarStatus.qarsSpin:
      return 'carStatus_qarsSpin';
  }
}
Widget tagContainer(String tag,context){
  var lc = AppLocalizations.of(context)!;

  return Container(
    //width: 25.w,
    height: 25.h,

    decoration: BoxDecoration(
      color:
      tag== "Sold"?AppColors.danger:tag=="Inspected"?AppColors.primary:tag=="New"?AppColors.success:Colors.transparent,

    ),
    child:  Center(
      child: Text(
        tag== "Sold"?lc.tag_Sold:tag=="Inspected"?lc.tag_Inspected:tag=="New"?lc.tag_New:"",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

}