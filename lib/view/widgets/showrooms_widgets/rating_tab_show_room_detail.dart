import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';
import 'package:qarsspin/model/partner_rating.dart';
import 'package:qarsspin/model/showroom_model.dart';
import 'package:qarsspin/view/widgets/showrooms_widgets/rating_widget.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../auth_widgets/register_dialog.dart';

class RatingTabShowRoomDetail extends StatefulWidget {
  String avgRating;
  PartnerRating? myRate;
  Showroom showroom;
  RatingTabShowRoomDetail({required this.showroom,required this.myRate,required this.avgRating,super.key});

  @override
  State<RatingTabShowRoomDetail> createState() => _RatingTabShowRoomDetailState();
}

class _RatingTabShowRoomDetailState extends State<RatingTabShowRoomDetail> {
  int showroomRating = 0;

  void updateRating(int rating) {
    setState(() {
      showroomRating = rating;
    });
    Get.find<ShowRoomsController>().rateShowroom(partnerId: widget.showroom.partnerId.toString(), rating: rating, countryCode: "QA", ratingSource: "App", userType: "User", username: Get.find<AuthController>().userName!);


    // You can also call your API here
    print("User rated: $rating stars");
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var lc = AppLocalizations.of(context)!;
    return GetBuilder<ShowRoomsController>(
        builder: (controller) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [1, 2, 3, 4, 5]
                    .map((e) =>  Icon(Icons.star, size: 20.w, color: Color(0xFFF6C42D)))
                    .toList(),
              ),
              SizedBox(height: height*.01,),
              Center(child: Text("${controller.partnerRating.total}",style: TextStyle(fontSize: 15.sp,color:AppColors.blackColor(context),fontWeight: FontWeight.w600,fontFamily: fontFamily), )),
              10.verticalSpace,
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: width*.05),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for(int i = 0;i<controller.partnerRating.ratingData.length;i++)
                            RatingLine(width, height,controller.partnerRating.ratingData[i].name,double.parse(controller.partnerRating.ratingData[i].value.toString())),
                          // RatingLine(width, height,'4',0.2),
                          // RatingLine(width, height,'3',0.4),
                          // RatingLine(width, height,'2',0.3),
                          // RatingLine(width, height,'1',0.4),
                        ],
                      ),
                    ),SizedBox(width: width*.08,),
                    Column(
                      children: [
                        Text(widget.avgRating,style: TextStyle(fontSize: width*.11,fontWeight: FontWeight.bold)),

                        Text(lc.out_of_5,style: TextStyle(fontSize: width*.033 ,fontWeight: FontWeight.bold)),


                      ],
                    ),

                  ],
                ),
              ),
              40.verticalSpace,
              InkWell(
                onTap: (){
                  final authController = Get.find<AuthController>();


                  if(authController.registered){
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => RateShowroomSheet(
                        onConfirm: updateRating, // callback to update UI
                      ),
                    );
                  }else{
                    showDialog(
                      context: context,
                      builder: (_) => RegisterDialog(),
                    );
                  }



                },
                child: Container(
                  width: double.infinity,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6).r,
                  ),
                  child: Center(
                    child: Text(
                      lc.rate_room,
                      style: TextStyle(
                          color: AppColors.black,
                          fontFamily: fontFamily,
                          fontSize: 14.sp,fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              )

            ],
          );
        }
    );
  }
}
Widget RatingLine(double width,double height,String text,double value){
  return       Padding(
    padding:  EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
        SizedBox(width: width * .01),
        Icon(Icons.star, size: 15, color: Color(0xFFF6C42D)),
        SizedBox(width: width * .02), // مسافة بسيطة قبل البار
        Expanded( // 👈 هنا يخلي البار ياخد باقي المساحة
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Color(0xfff2f2f2),
            minHeight: height * .005,
            borderRadius: BorderRadius.circular(10),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF6C42D)),
          ),
        ),
      ],
    ),
  );
}