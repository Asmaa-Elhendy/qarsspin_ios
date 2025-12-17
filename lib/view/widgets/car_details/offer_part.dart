import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/offer.dart';
import 'dart:developer';

import '../../../controller/auth/auth_controller.dart';
import '../../../l10n/app_localization.dart';
import '../auth_widgets/register_dialog.dart';
import '../offer_dialog.dart';


class OfferPart extends StatelessWidget {
  List<Offer> offers;
  String postID;
  // final List<Map<String, String>> offers = [
  //   {"name": "Jasem", "time": "1 hour ago", "price": "102,000 QAR"},
  //   {"name": "Mhmed", "time": "2 days ago", "price": "100,000 QAR"},
  //   {"name": "Karim", "time": "2 days ago", "price": "98,000 QAR"},
  //   {"name": "Walid", "time": "2 days ago", "price": "86,000 QAR"},
  //   {"name": "Nour", "time": "2 days ago", "price": "83,000 QAR"},
  //   {"name": "Nour", "time": "2 days ago", "price": "83,000 QAR"},
  //   {"name": "Nour", "time": "2 days ago", "price": "83,000 QAR"},
  // ];
  OfferPart({required this.offers,required this.postID});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return  Container(
      color: AppColors.background(context),
      child: Column(
        children: [

          /// List of Offers
          Expanded(
            child: ListView.builder(
              itemCount: offers.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final offer = offers[index];
                log("usern");
                log(offers[index].userName);
                log("mine");
                log(Get.find<AuthController>().userName!);
                return Slidable(
                  enabled: offers[index].userName==Get.find<AuthController>().userFullName!,
                  key: ValueKey(1),

                  // السحب لليسار (Swipe Left)
                  endActionPane: ActionPane(
                    motion: StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async{
                          final authController = Get.find<AuthController>();

                          await showDialog(

                            context: context,
                            builder: (_) =>authController.registered?  MakeOfferDialog(offer:false,update: true,price:offers[index].price,offer_id: offers[index].id.toString(),):RegisterDialog(),
                          );

                        },
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: lc.edit,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          Get.find<BrandController>().deleteOffer(postID:postID,offerId: "${offer.id}", loggedInUser: userName, context: context);
                          print(lc.delete);
                        },
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: lc.delete,
                      ),
                    ],
                  ),

                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.mutedGray,
                          radius: 30.r,
                          child: Icon(Icons.person, color: AppColors.blackColor(context),size: 45.w,),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 85.w,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  offer.userName,
                                  style: TextStyle(
                                      color: AppColors.blackColor(context),
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                offer.dateTime,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 160.w,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.extraLightGray),
                            borderRadius: BorderRadius.circular(6).r,
                            color: AppColors.background(context),
                          ),
                          child: Center(
                            child: Text(
                              "${offer.price} ${lc.currency_Symbol}",
                              style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.w600, fontSize: 14.sp),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// See More Button
          // TextButton.icon(
          //   onPressed: () {},
          //   icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          //   label: Text("See more",
          //       style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          // )
        ],
      ),
    );
  }
}
