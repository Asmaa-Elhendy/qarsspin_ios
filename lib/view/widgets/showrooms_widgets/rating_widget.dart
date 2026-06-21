import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';

import '../../../l10n/app_localizations.dart';

class RateShowroomSheet extends StatefulWidget {
  final Function(int) onConfirm;

  const RateShowroomSheet({super.key, required this.onConfirm});

  @override
  State<RateShowroomSheet> createState() => _RateShowroomSheetState();
}

class _RateShowroomSheetState extends State<RateShowroomSheet> {
  int selectedRating = 5; // default 5 stars

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    final Map<int, String> ratingWords = {
      5: lc.five_stars,
      4: lc.four_stars,
      3: lc.three_stars,
      2: lc.two_stars,
      1: lc.one_star,
    };
    return Container(
      padding:  EdgeInsets.symmetric(vertical: 25.h, horizontal: 16.w),
      decoration: const BoxDecoration(
        //borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 5.h,
           margin:  EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
           Text(
            lc.rate_room,
            style: TextStyle(
                color: AppColors.black,
                fontSize: 16.sp, fontWeight: FontWeight.w700,fontFamily: fontFamily),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.black,thickness: .5.h,),

          // iOS style scroll picker
          SizedBox(
            height: 220.h,
            child: CupertinoPicker(
              magnification: 1,
              squeeze: 1.1,
              useMagnifier: true,
              scrollController: FixedExtentScrollController(initialItem: 0),
              itemExtent: 40.h,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedRating = 5 - index; // reverse (5 stars at top)
                });
              },
              children: List.generate(5, (index) {
                int stars = 5 - index;
                return Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 60.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ratingWords[stars]!,
                        style:  TextStyle(
                            color: AppColors.black,
                            fontSize: 14.sp,fontFamily: fontFamily,fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(
                          stars,
                              (_) =>  Icon(Icons.star, color: AppColors.primary),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //  yellowButtons(title: "Cancel", onTap: (){}, w: 170.w,grey: true),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.symmetric(horizontal: 18.w,vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.extraLightGray,
                    borderRadius: BorderRadius.circular(4), // optional rounded corners

                  ),
                  child: Center(
                    child: Text(lc.btn_Cancel,

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
              // Expanded(
              //   child: OutlinedButton(
              //     onPressed: () => Navigator.pop(context),
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: Colors.black,
              //       side: const BorderSide(color: Colors.grey),
              //     ),
              //     child: const Text("Cancel"),
              //   ),
              // ),
              const SizedBox(width: 12),
              InkWell(
                onTap: (){
                  widget.onConfirm(selectedRating);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.symmetric(horizontal: 18.w,vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4), // optional rounded corners

                  ),
                  child: Center(
                    child: Text(lc.btn_Confirm,

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
              // Expanded(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.amber,
              //       foregroundColor: Colors.black,
              //     ),
              //     onPressed: () {
              //       widget.onConfirm(selectedRating);
              //       Navigator.pop(context);
              //     },
              //     child: const Text("Confirm"),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
