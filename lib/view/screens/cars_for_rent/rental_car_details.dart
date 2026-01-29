import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/model/car_model.dart';

import '../../../l10n/app_localization.dart';
import '../../../model/rental_car_model.dart';
import '../../widgets/car_image.dart';
import '../../widgets/rental_cars/info.dart';
import '../../widgets/rental_cars/price_table.dart';
import '../../widgets/rental_cars/rental_bottom_bar.dart';
import '../../widgets/showrooms_widgets/dealer_tabs.dart';
import '../../widgets/showrooms_widgets/header_section.dart';
import '../../widgets/texts/texts.dart';

class RentalCarDetails extends StatefulWidget {
  RentalCar rentalCar;
  RentalCarDetails({required this.rentalCar, super.key});

  @override
  State<RentalCarDetails> createState() => _RentalCarDetailsState();
}

class _RentalCarDetailsState extends State<RentalCarDetails> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      bottomNavigationBar: RentalBottomNaviagtion(phone: widget.rentalCar.ownerMobile),
      body: SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 88.h, // same as your AppBar height
              padding: EdgeInsets.only(top: 13.h, left: 14.w, right: 14.w),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25), // shadow color
                    blurRadius: 6, // softens the shadow
                    offset: Offset(0, 2), // moves shadow downward
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // go back
                    },
                    child: Icon(
                      Icons.arrow_back_outlined,
                      color: AppColors.blackColor(context),
                      size: 30.w,
                    ),
                  ),
                  // 105.horizontalSpace,
                  Center(
                    child: SizedBox(
                        width: 147.w,
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/images/balckIconDarkMode.png'
                              : 'assets/images/black_logo.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                  InkWell(
                    onTap: () {},
                    child: SizedBox(
                        width: 25.w,
                        child: Image.asset(
                          "assets/images/share.png",
                          fit: BoxFit.cover,
                          color: AppColors.blackColor(context),
                        )),
                  )
                ],
              ),
            ),
            // ===== 1. Header with 360 preview =====
            // HeaderSection(realImage: widget.rentalCar.spin360Url??"",),
            SizedBox(
              height: 250.h,
              child: CarImage(
                allImages: [widget.rentalCar.spin360Url??"",widget.rentalCar.rectangleImageUrl??"",widget.rentalCar.videoUrl??""],
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RentalCarInfo(
                        car: widget.rentalCar,
                      ),
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: width * .03),
                        child: Divider(
                          thickness: .7.h,
                          color: AppColors.divider(context),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: width * .03),
                        child: Text(
                          lc.rental_prices,
                          style: TextStyle(
                            color: AppColors.blackColor(context),
                            fontSize: 14.sp,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: width * .03),
                        child: Divider(
                          thickness: .7.h,
                          color: AppColors.divider(context),
                        ),
                      ),
                      SizedBox(height: height * .02),
                      PriceTable(car: widget.rentalCar),
                      //24.verticalSpace,
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: width * .03),
                        child: Divider(
                          thickness: .7.h,
                          color: AppColors.black,
                        ),
                      ),
                      4.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 55.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                column(lc.chassis_number,
                                    widget.rentalCar.chassisNumber,lc),
                                Spacer(),
                                column(
                                    lc.year,
                                    widget.rentalCar.manufactureYear
                                        .toString(),lc)
                              ],
                            ),
                            30.verticalSpace,
                            Row(
                              children: [
                                column(lc.mileage,
                                    widget.rentalCar.mileage.toString(),lc),
                                Spacer(),
                                column(
                                    lc.for_leasing,
                                    widget.rentalCar.availableForLease == 0
                                        ? lc.value_No
                                        : lc.value_Yes,lc)
                              ],
                            ),
                            30.verticalSpace,
                            Row(
                              children: [
                                column(lc.exterior,
                                    widget.rentalCar.mileage.toString(),lc,
                                    color: true),
                                Spacer(),
                                column(lc.interior,
                                    widget.rentalCar.mileage.toString(),lc,
                                    color: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,
                      headerText(lc.specifications,context),
                      8.verticalSpace,

                      GetBuilder<RentalCarsController>(
                          builder: (controller) {
                            return specifications(controller.spec);
                          }
                      )

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  column(key, value,lc, {bool color = false}) {
    return Column(
      children: [
        SizedBox(
          width: 140.w,
          child: Center(
            child: boldGrey(key),
          ),
        ),
        4.verticalSpace,
        SizedBox(
          width: 88.w,
          child: Center(
            child: color
                ? Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: key == lc.exterior
                      ? widget.rentalCar.colorExterior
                      : widget.rentalCar.colorInterior,
                  border: Border.all(color: AppColors.darkGray)),
            )
                : headerText(value,context),
          ),
        ),
      ],
    );
  }

  Widget specifications(List spec){
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          for(int i =0; i < spec.length;i++)

            specificationsRow(spec[i].key,spec[i].value),

        ],
      ),
    ) ;
  }
  Widget specificationsRow(String title ,String value){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: .8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            height: 55.h,
            width: 175.w,
            decoration: BoxDecoration(
              color: AppColors.background(context),
              border: Border.all(
                color: AppColors.extraLightGray,
                width: 1,
              ),
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontSize: 16.sp, ),
              ),
            ),
          ),
          2.5.horizontalSpace,
          Container(
            height: 55.h,
            width: 175.w,
            decoration: BoxDecoration(
              color: AppColors.background(context),
              border: Border.all(
                color: AppColors.extraLightGray,
                width: 1,
              ),
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 16.sp, color: AppColors.blackColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
