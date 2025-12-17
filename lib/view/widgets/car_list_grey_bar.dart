import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:developer';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/controller/search_controller.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';
import 'package:qarsspin/view/widgets/search/search_slide.dart';
import 'package:qarsspin/view/widgets/showrooms_widgets/sort_by_widgets.dart';
import '../../controller/const/colors.dart';
import '../../controller/notifications_controller.dart';
import '../../l10n/app_localization.dart';


Widget carListGreyBar(
    NotificationsController notificationsController,
    {required Function(dynamic)? onSearchResult,
      required context,
      required String title,
      bool squareIcon = false,
      VoidCallback? onSwap,
      bool showroom = false,
      bool listCars = false,
      bool listCarsInQarsSpinShowRoom = false,
      bool personalsCars =false,
      bool rental = false,
      bool makes = false,
      bool carCare = false,
      String partnerKind = "Rent a Car"}) {

  Get.find<MySearchController>();
  var lc = AppLocalizations.of(context)!;


  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
    color: AppColors.greyColor(context) ,
    child: Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: fontFamily,
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        const Spacer(),
        squareIcon || makes
            ? InkWell(
          onTap: () async {
            final result = await showCustomBottomSheet(
                context,
                makes
                    ? "makes"
                    : listCarsInQarsSpinShowRoom
                    ? "Qars spin"
                    : personalsCars
                    ? "Personal Cars"
                    : "listCars",notificationsController
            );
            if (onSearchResult != null) onSearchResult(result);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
            height: 40.h,
            width: 115.w,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/images/new_svg/search.svg",
                  height: 25.h,
                  color: AppColors.black,
                ),
                8.horizontalSpace,
                Text(
                  lc.search,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        )
            : const SizedBox(),
        GestureDetector(
          onTap: () {
            // نفس منطقك السابق
            if (showroom) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => SortBySheet(

                  showroom: true,
                  onConfirm: (selectedSort) {

                    if (showroom) {
                      // "lb_Sort_By_Active_Posts_Desc" - Sort by number of active posts (highest first)
                      // "lb_Sort_By_Avg_Rating_Desc" - Sort by average rating (highest first)
                      // "lb_Sort_By_Visits_Count_Desc" - Sort by number of visits (most visited first)
                      // "lb_Sort_By_Joining_Date_Asc" - Sort by joining date (oldest first)

                      Get.find<ShowRoomsController>().fetchShowrooms(
                          context: context,
                          partnerKind: partnerKind,
                          forSale: partnerKind != "Rent a Car"&&!carCare,
                          sort: selectedSort == "sort_by_post_count"
                              ? "lb_Sort_By_Active_Posts_Desc"
                              : selectedSort == "sort_by_rating"
                              ? "lb_Sort_By_Avg_Rating_Desc"
                              : selectedSort == "sort_by_visits"
                              ? "lb_Sort_By_Visits_Count_Desc"
                              : "lb_Sort_By_Joining_Date_Asc");
                    }
                    // update your screen logic here
                  },
                ),
              );
            } else if (rental) {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => SortBySheet(
                      rentalCar: true,
                      onConfirm: (selectedSort) {

                        Get.find<RentalCarsController>().fetchRentalCars(
                            context: context,

                            sort: selectedSort ==
                                "sort_by_post_date_new"
                                ? "PostDate_Desc"
                                : selectedSort ==
                                "sort_by_post_date_old"
                                ? "PostDate_Asc"
                                : selectedSort ==
                                "sort_by_price_high"
                                ? "Price_Desc"
                                : selectedSort ==
                                "sort_by_price_low"
                                ? "Price_Asc"
                                : selectedSort ==
                                "sort_by_manufacture_year_new"
                                ? "Year_Desc"
                                : "Year_Asc");
                      }));
            }else if(makes){
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => SortBySheet(
                      make: true,
                      onConfirm: (selectedSort) {
                        Get.find<BrandController>().fetchCarMakes(
                            sort: selectedSort ==lc.make_name?"MakeName":"Make_Count"
                        );
                      }));
            }
            else if(carCare){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => SortBySheet(
                  showroom: true,
                  onConfirm: (selectedSort) {
                    if (carCare) {

                      Get.find<ShowRoomsController>().fetchShowrooms(
                          context: context,
                          partnerKind: partnerKind,// car Care
                          sort: selectedSort == "sort_by_post_count"
                              ? "lb_Sort_By_Active_Posts_Desc"
                              : selectedSort == "sort_by_rating"
                              ? "lb_Sort_By_Avg_Rating_Desc"
                              : selectedSort == "sort_by_visits"
                              ? "lb_Sort_By_Visits_Count_Desc"
                              : "lb_Sort_By_Joining_Date_Asc", forSale: partnerKind != "Rent a Car"&&!carCare);
                    }
                    // update your screen logic here
                  },
                ),
              );

            }else if(listCars){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => SortBySheet(
                    carList: true,
                    onConfirm: (selectedSort) {
                      log("carList ${selectedSort}");

                      String currentSourceKind =  Get.find<BrandController>().currentSourceKind;
                      int currentMakeId = Get.find<BrandController>().currentMakeId;
                      String currentMakeName = Get.find<BrandController>().currentMakeName;

                      // switch(currentSourceKind){
                      //   case "All":
                      Get.find<BrandController>().getCars(
                          make_id: currentMakeId, makeName: currentMakeName,
                          sort: selectedSort ==
                              "sort_by_post_date_new"
                              ? "PostDate_Desc"
                              : selectedSort ==
                              "sort_by_post_date_old"
                              ? "PostDate_Asc"
                              : selectedSort ==
                              "sort_by_price_high"
                              ? "Price_Desc"
                              : selectedSort ==
                              "sort_by_price_low"
                              ? "Price_Asc"
                              : selectedSort ==
                              "sort_by_manufacture_year_new"
                              ? "Year_Desc"
                              : "Year_Asc",
                          sourceKind: currentSourceKind

                      );

                    }

                  // Get.find<ShowRoomsController>().fetchShowrooms(
                  //     partnerKind: partnerKind,// car Care
                  //     sort: selectedSort == "Sort By Posts Count"
                  //         ? "lb_Sort_By_Active_Posts_Desc"
                  //         : selectedSort == "Sort By Rating"
                  //         ? "lb_Sort_By_Avg_Rating_Desc"
                  //         : selectedSort == "Sort By Visits"
                  //         ? "lb_Sort_By_Visits_Count_Desc"
                  //         : "lb_Sort_By_Joining_Date_Asc");

                  // update your screen logic here
                  //  },
                ),
              );

              // qar spin show room
              // Get.find<BrandController>().getCars(make_id: 0, makeName: "Qars Spin Showrooms",sourceKind: "Qars spin");
              // personal cars
              // Get.find<BrandController>().getCars(make_id: 0, makeName: "Personal Cars",sourceKind: "Individual");
              //  controller.getCars(  // in case care for sale list
              //    make_id: controller.carBrands[index].id,
              //    makeName: controller.carBrands[index].name,
              //  );

            }
          },
          child: Padding(
            padding: EdgeInsets.only(right: 13.w, left: 3.w),
            child: SvgPicture.asset(
              "assets/images/new_svg/swap.svg",
              height: 25.h,
              color: AppColors.white,
            ),
          ),
        ),
        squareIcon
            ? GestureDetector(
          onTap: onSwap,
          child: SvgPicture.asset(
            "assets/images/new_svg/square.svg",
            height: 25.h,
            color: AppColors.white,
          ),
        )
            : const SizedBox(),
      ],
    ),
  );
}

showCustomBottomSheet(BuildContext context, String myCase,NotificationsController notificationsController) {
  return  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => CustomFormSheet( notificationsController,myCase: myCase),
  );
}
