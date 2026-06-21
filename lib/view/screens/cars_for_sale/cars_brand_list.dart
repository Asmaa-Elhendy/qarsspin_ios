import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/search_controller.dart';

import '../../../controller/brand_controller.dart';
import '../../../controller/notifications_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ad_container.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/car_card.dart';
import '../../widgets/car_list_grey_bar.dart';
import '../../widgets/cars_list_app_bar.dart';
import '../general/find_me_car.dart';
import 'dart:io' show Platform;

class CarsBrandList extends StatefulWidget {
  String brandName;
  String postKind;
  NotificationsController notificationsController;
  CarsBrandList(this.notificationsController,{required this.postKind, required this.brandName, super.key});

  @override
  State<CarsBrandList> createState() => _CarsBrandListState();
}

class _CarsBrandListState extends State<CarsBrandList> {
  bool isGrid = true; // controls which view to show
  String searchResult = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("btrandName = ${widget.brandName}");
  }
  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: carListAppBar(widget.notificationsController,notificationCount: 3,context: context),
      body: GetBuilder<BrandController>(builder: (controller) {
        return Stack(
          children: [
            Column(
              children: [
                AdContainer(//update banner
                  bigAdHome: true,
                  targetPage: 'Cars For Sale - Makes Page',
                ),
                8.verticalSpace,
                carListGreyBar(widget.notificationsController,
                    listCars: widget.brandName != lc.qar_spin_showroom &&
                        widget.brandName != lc.personal_cars,
                    listCarsInQarsSpinShowRoom:
                        widget.brandName == lc.qar_spin_showroom,
                    personalsCars: widget.brandName == lc.personal_cars,

                    onSearchResult: (result) {
                      //  Get.find<MySearchController>().fetchCarMakes();
                      setState(() {
                        searchResult = result ?? "";
                      });
                    },
                    context: context,
                    title: controller.currentMakeName==""?lc.all_cars:widget.brandName,
                    squareIcon: true,
                    onSwap: () {
                      setState(() {
                        isGrid = !isGrid; // toggle view
                      });
                    }),
                8.verticalSpace,
                controller.loadingMode?SizedBox():
                controller.carsList.isNotEmpty
                    ? Expanded(
                    child: isGrid
                        ? listAsAGread(controller.carsList)
                        : listAsAList(controller.carsList))
                    : noResultFoud(lc)
              ],
            ),
            if(controller.loadingMode)
              Positioned.fill(

                child: Container(
                  color: AppColors.black.withOpacity(0.5),
                  child: Center(
                    child: AppLoadingWidget(
                      title: lc.loading,
                    ),
                  ),
                ),
              )

          ],
        );
      }),
    );
  }

  Widget listAsAGread(cars) {
    return Padding(
        padding:
        EdgeInsets.symmetric(horizontal: 13.w, vertical: 8), //update asmaa
        child: GridView.builder(
            itemCount: cars.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              mainAxisSpacing: 28.h,
              crossAxisSpacing: 10.w, //update asmaa
              childAspectRatio: Platform.isAndroid ? 0.775 : 0.72, // adjust as needed ios / android
            ),
            itemBuilder: (context, index) {

              return carCard(
                  context: context,
                  w: 192.w,
                  h: 245.h,
                  car: cars[index],
                  large: false,
                  postKind: widget.postKind);
            }));
  }

  Widget listAsAList(cars) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              carCard(
                w: double.infinity, // full width
                context: context,
                h: 300.h,
                car: cars[index],
                postKind: widget.postKind,
                large:
                true, // you can use this flag if your card has different styles for list
              ),
              8.verticalSpace
            ],
          );
        },
      ),
    );
  }

  Widget noResultFoud(lc) {
    return Column(
      children: [
        55.verticalSpace,
        Center(
          child: Text(
            lc.no_result,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontFamily: fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 18.sp),
          ),
        ),
        24.verticalSpace,
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                lc.sorry,
                style: TextStyle(
                    color: AppColors.blackColor(context),
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 13.sp),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                lc.sorry_notify,
                style: TextStyle(
                    color: AppColors.blackColor(context),
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 13.sp),
              ),
            ),
            33.verticalSpace,
            Center(
              child: InkWell(
                onTap: () {
                  Get.to(FindMeACar());
                },
                child: Container(
                  //width: 180.w,
                  height: 55.h,
                  margin: EdgeInsets.symmetric(horizontal: 120.w),
                  padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(context),
                    borderRadius:
                    BorderRadius.circular(4), // optional rounded corners
                  ),
                  child: Center(
                    child: Text(
                      lc.find_me_car,
                      style: TextStyle(
                        color: AppColors.black,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
