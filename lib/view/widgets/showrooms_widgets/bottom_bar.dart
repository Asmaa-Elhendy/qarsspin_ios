import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/showroom_model.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';

import '../../../controller/brand_controller.dart';
import '../../../controller/communications.dart';
import '../../../controller/const/base_url.dart';
import '../../../controller/notifications_controller.dart';
import '../../../controller/rental_cars_controller.dart';
import '../../../controller/showrooms_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/cars_for_rent/all_rental_cars.dart';
import '../../screens/cars_for_sale/cars_brand_list.dart';

class ShowRoomBottomBar extends StatelessWidget {
  Showroom showRoom;
  bool carCare;
  bool rental;
  NotificationsController notificationsController;
  ShowRoomBottomBar(
    this.rental,
    this.notificationsController, {
    required this.carCare,
    required this.showRoom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Container(
      //width: double.infinity,
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
      decoration: BoxDecoration(color: AppColors.background(context)),
      child: Row(
        spacing: 18.w,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !carCare
              ? carButton(() {
                  if (rental) {
                    Get.find<RentalCarsController>().switchLoading();
                  } else {
                    Get.find<BrandController>().switchLoading();
                  }

                  Get.find<ShowRoomsController>().fetchCarsOfShowRooms(
                    context: context,
                    showroomName: showRoom.partnerNamePl,
                    forSale: rental ? false : true,
                    postId: "0",
                    sourceKind: "Partner",
                    partnerid: showRoom.partnerId.toString(),
                    userName: userName,
                    overrideSourceKind: showRoom.isQarsSpinPartner ? "Qars Spin" : null,
                  );

                  if (rental) {
                    Get.to(AllRentalCars(notificationsController));
                  } else {
                    Get.to(
                      CarsBrandList(
                        notificationsController,
                        brandName: showRoom.partnerNamePl,
                        postKind: "CarForSale",
                      ),
                    );
                  }

                  //Get.find<RentalCarsController>().switchLoading();

                  //Get.find<RentalCarsController>().setRentalCars(showRoom.rentalCars??[]);
                  //Get.to(AllRentalCars(notificationsController));
                }, "${lc.cars}(${showRoom.carsCount})")
              : SizedBox(),
          //20.horizontalSpace,
          squareButton(
            Icon(
              Icons.location_on_rounded,
              color: AppColors.whiteColor(context),
              size: 30.w,
            ),
            () {
              openMap(showRoom.mapsUrl);
            },
          ),
          //20.horizontalSpace,
          squareButton(
            Image.asset(
              "assets/images/whats.png",
              color: AppColors.whiteColor(context),
            ),
            () {
              openWhatsApp(showRoom.contactWhatsApp, message: "Hello 👋");
            },
            green: true,
          ),

          //20.horizontalSpace,
          carCare
              ? InkWell(
                  onTap: () {
                    makePhoneCall(showRoom.contactPhone);
                  },
                  child: Container(
                    width: 220.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // optional rounded corners
                    ),
                    child: Center(child: Icon(Icons.call)),
                  ),
                )
              : squareButton(
                  Icon(
                    Icons.call,
                    color: AppColors.whiteColor(context),
                    size: 30.w,
                  ),
                  () {
                    makePhoneCall(showRoom.contactPhone);
                  },
                ),
        ],
      ),
    );
  }

  Widget carButton(onTap, title) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 160.w,
        height: 100.h,

        // padding: EdgeInsets.symmetric(horizontal: 35.w,vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4), // optional rounded corners
        ),
        child: Center(
          child: Text(
            title,

            style: TextStyle(
              color: AppColors.black,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  squareButton(icon, onTap, {bool green = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 105.h,
        // padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 12.w),
        decoration: BoxDecoration(
          color: !green ? AppColors.primary : AppColors.success,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
