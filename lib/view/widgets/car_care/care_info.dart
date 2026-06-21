import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/showroom_model.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../auth_widgets/register_dialog.dart';

class CareInfo extends StatelessWidget {
  Showroom show;
  CareInfo({required this.show,super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 48.r,

                backgroundImage: NetworkImage(show.logoUrl),

              ),
              16.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Get.locale?.languageCode=='ar'?show.partnerNameSl :show.partnerNamePl,
                    style: TextStyle(
                        color: AppColors.blackColor(context),
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp
                    ),
                  ),
                  4.verticalSpace,
                  Row(
                    children: [
                      Text("${lc.join_data}: ${show.joiningDate}",
                        style: TextStyle(
                            color: AppColors.inputBorder,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp
                        ),
                      ),
                      45.horizontalSpace,
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye,color: AppColors.accent,size: 18.w,),
                          4.horizontalSpace,
                          Text(show.visitsCount.toString(),
                            style: TextStyle(
                                color: AppColors.mutedGray,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     yellowButtons(title: lc.follow, onTap: (){
                  //       final authController = Get.find<AuthController>();
                  //       if(authController.registered){
                  //
                  //       }else{
                  //         showDialog(
                  //           context: context,
                  //           builder: (_) => RegisterDialog(),
                  //         );
                  //       }
                  //
                  //     }, w: 110.w,context:context),
                  //
                  //     8.horizontalSpace,
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(lc.followers,
                  //           style: TextStyle(
                  //               color: AppColors.mutedGray,
                  //               fontFamily: fontFamily,
                  //               fontWeight: FontWeight.w800,
                  //               fontSize: 13.sp
                  //           ),
                  //         ),
                  //
                  //         2.verticalSpace,
                  //         Row(
                  //           children: [
                  //             Text(show.followersCount.toString(),
                  //               style: TextStyle(
                  //                   color: AppColors.mutedGray,
                  //                   fontFamily: fontFamily,
                  //                   fontWeight: FontWeight.w800,
                  //                   fontSize: 13.sp
                  //               ),
                  //             ),
                  //             50.horizontalSpace,
                  //             Row(
                  //               children: List.generate(5, (index) {
                  //                 return Icon(
                  //                   Icons.star,
                  //                   color: index < double.parse(show.avgRating) ? AppColors.primary : AppColors.mutedGray,
                  //                   size: 20.w,
                  //                 );
                  //               }),
                  //             )
                  //             // for(int i =0;i<5;i++)
                  //             //   Icon(Icons.star,color: AppColors.mutedGray,size: 20.w,)
                  //           ],
                  //         ),
                  //
                  //       ],
                  //     )
                  //   ],
                  // )
                  GetBuilder<ShowRoomsController>(
                      builder: (showRoomController) {
                        return Row(
                          children: [
                            yellowButtons(title: showRoomController.following?lc.un_follow:lc.follow, onTap: (){
                              final authController = Get.find<AuthController>();
                              if(authController.registered){
                                //follow-unfollow the partner
                                if(showRoomController.following){
                                  //un_follow
                                  showRoomController.unFollow(show.partnerId);
                                }else{
                                  //follow
                                  showRoomController.follow(show.partnerId);
                                }


                              }else{
                                showDialog(
                                  context: context,
                                  builder: (_) => RegisterDialog(),
                                );
                              }

                            }, w: 119.w,context:context),

                            8.horizontalSpace,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lc.followers,
                                  style: TextStyle(
                                      color: AppColors.mutedGray,
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.sp
                                  ),
                                ),

                                2.verticalSpace,
                                Row(
                                  children: [
                                    Text(show.followersCount.toString(),
                                      style: TextStyle(
                                          color: AppColors.mutedGray,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.sp
                                      ),
                                    ),
                                    50.horizontalSpace,
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          color: index < double.parse(show.avgRating) ? AppColors.primary : AppColors.mutedGray,
                                          size: 20.w,
                                        );
                                      }),
                                    )
                                    // for(int i =0;i<5;i++)
                                    //   Icon(Icons.star,color: AppColors.mutedGray,size: 20.w,)
                                  ],
                                ),

                              ],
                            )
                          ],
                        );
                      }
                  )],
              )

            ],
          ),
          16.verticalSpace,
          Text(Get.locale?.languageCode=='ar'?show.partnerDescSl:show.partnerDescPl,
            style: TextStyle(
                fontSize: 14.sp,
                fontFamily: fontFamily,
                color: AppColors.blackColor(context),
                fontWeight: FontWeight.w300
            ),
          ),
          18.verticalSpace,
          Divider(color: AppColors.divider(context),thickness: .8.h,)
        ],
      ),

    );
  }
}
