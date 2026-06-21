import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/l10n/l10n.dart';

import '../../../l10n/app_localizations.dart';

class SortBySheet extends StatefulWidget {
  final Function(String) onConfirm;
  bool showroom;
  bool rentalCar;
  bool make;
  bool carList;

   SortBySheet({this.carList = false,this.showroom=false,this.rentalCar=false,this.make=false,super.key, required this.onConfirm});

  @override
  State<SortBySheet> createState() => _SortBySheetState();
}

class _SortBySheetState extends State<SortBySheet> {
  List<String> sortResult = [];
  // final List<String> sortOptions = [
  //   "Sort By Posts Count",
  //   "Sort By Rating",
  //   "Sort By Visits",
  //   "Sort By joining Date",
  // ];
  // final List<String> sortCarsOptions = [
  //   "Sort By Post Date(Newest First)",
  //   "Sort By Post Date (Oldest First)",
  //   "Sort By Price(From High To Low)",
  //   "Sort By Price (From Low To High)",
  //   "Sort By Manufacture Year (Newest First)",
  //   "Sort By Manufacture Year (Oldest First)",
  // ];
  // final List<String> sortMakes = [
  //   "MakeName",
  //   "Ads Count"
  // ];
  final List<String> sortOptions = [
    "sort_by_post_count",
    "sort_by_rating",
    "sort_by_visit",
    "sort_by_date",
  ];

  final List<String> sortCarsOptions = [
    "sort_by_post_date_new",
    "sort_by_post_date_old",
    "sort_by_price_high",
    "sort_by_price_low",
    "sort_by_manufacture_year_new",
    "sort_by_manufacture_year_old",
  ];

  final List<String> sortMakes = [
    "make_name",
    "ads_count",
  ];


  int selectedIndex = 0; // default first option
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.showroom){
      sortResult = sortOptions;
    }else if(widget.rentalCar || widget.carList){
      sortResult = sortCarsOptions;
    }else if(widget.make){
      sortResult = sortMakes;
    }
  }

  @override
  Widget build(BuildContext context) {

    var lc = AppLocalizations.of(context)!;
    final translatedSortResult = sortResult.map((key) {
      switch (key) {
        case "sort_by_post_count":
          return lc.sort_by_post_count;
        case "sort_by_rating":
          return lc.sort_by_rating;
        case "sort_by_visit":
          return lc.sort_by_visits;
        case "sort_by_date":
          return lc.sort_by_date;
        case "sort_by_post_date_new":
          return lc.sort_by_post_date_new;
        case "sort_by_post_date_old":
          return lc.sort_by_post_date_old;
        case "sort_by_price_high":
          return lc.sort_by_price_high;
        case "sort_by_price_low":
          return lc.sort_by_price_low;
        case "sort_by_manufacture_year_new":
          return lc.sort_by_manufacture_year_new;
        case "sort_by_manufacture_year_old":
          return lc.sort_by_manufacture_year_old;
        case "make_name":
          return lc.make_name;
        case "ads_count":
          return lc.ads_count;
        default:
          return key;
      }
    }).toList();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // top drag handle
          Container(
            width: 40.w,
            height: 5.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text(
            lc.sort_result,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.black, thickness: .5.h),

          // iOS style scroll picker
          SizedBox(
            height: 220.h,
            child: CupertinoPicker(
              magnification: 1,
              squeeze: 1.1,
              useMagnifier: true,
              scrollController: FixedExtentScrollController(initialItem: selectedIndex,),
              itemExtent: 40.h,
              onSelectedItemChanged: (index) {

                setState(() {
                  selectedIndex = index;
                });
              },
              // selectionOverlay: Container(
              //   decoration: BoxDecoration(
              //     color: AppColors.extraLightGray,
              //     borderRadius: BorderRadius.circular(4),
              //
              //   ),
              // ),
              children: List.generate(sortResult.length, (index) {

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        translatedSortResult[index],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.black,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.extraLightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      lc.btn_Cancel,
                      style: TextStyle(
                        color: AppColors.black,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  widget.onConfirm(sortResult[selectedIndex]);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      lc.apply,
                      style: TextStyle(
                        color: AppColors.black,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}


