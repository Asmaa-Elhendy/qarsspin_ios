import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';

import '../../../controller/brand_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/navigation_bar.dart';
import '../ads/create_ad_options_screen.dart';
import '../home_screen.dart';
import 'package:qarsspin/view/screens/favourites/favourite_screen.dart';

import '../my_offers_screen.dart';


class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    final double addButtonSize = 60.w;
    final double addIconSize = 26.sp;
    final double addTextSize = 11.sp;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar:  AppBar(
          centerTitle: true,
          backgroundColor: AppColors.background(context),
          toolbarHeight: 60.h,
          shadowColor: Colors.grey.shade300,
          elevation: .4,
          title: Text(
            lc.navigation_call_us,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp
            ),
          )
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        //padding:  EdgeInsets.symmetric(vertical: 2.h,horizontal: 8.w),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Logo
            SizedBox(
              height: 70,
              width: 190,
              child: Image.asset(
                'assets/images/ic_top_logo_colored.png',
                fit: BoxFit.cover,
              ),
            ),
            // 8.verticalSpace,
            Text(
              lc.specialized_techno,
              style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor(context)),
              textAlign: TextAlign.center,
            ),

            4.verticalSpace,
            // Live Chat
             Text(
              lc.live_chat,


              style: TextStyle( fontFamily: fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            blackCircle("assets/images/liveChat.png"),

            const SizedBox(height: 30),

            // Contact Us Section
            Container(
              width: double.infinity,
              padding:  EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.notFavorite(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                   Text(
                    lc.navigation_call_us,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lc.cnt_reason,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      blackCircle("assets/images/telephone-removebg-preview.png"),

                      106.horizontalSpace,
                      blackCircle("assets/images/whatsapp.png"),

                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // For Business Inquiries
             Text(
              lc.for_business,
              style: TextStyle(

                  fontFamily: fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700
              ),
            ),
            const SizedBox(height: 12),
            blackCircle("assets/images/message.png"),

            const SizedBox(height: 30),

            // Social Media Accounts
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.notFavorite(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                   Text(
                    lc.social_accounts,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  12.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      //Image.asset("assets/images/twitter.png"),
                      20.horizontalSpace,
                      SizedBox(
                          width: 47,
                          height: 47,
                          child: Image.asset("assets/images/face.png",

                            fit: BoxFit.contain,
                          )),
                      50.horizontalSpace,
                      SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset("assets/images/twitter.png",

                            fit: BoxFit.contain,
                          )),
                      50.horizontalSpace,
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset("assets/images/instagram.png",


                            fit: BoxFit.contain,
                          )),
                      50.horizontalSpace,
                      SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset("assets/images/tiktok.png",

                            fit: BoxFit.contain,
                          )),

                    ],
                  )
                ],
              ),
            ),
            12.verticalSpace,

          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          Get.to(CreateNewAdOptions());
        },
        child: Container(
          width: addButtonSize,
          height: addButtonSize,
          decoration: BoxDecoration(
            color: AppColors.divider(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.background(context),
              width: 3.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: addIconSize,
                ),
                SizedBox(height: 2.h),
                Text(
                  lc.navigation_add,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: addTextSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy',
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Nav Bar
      bottomNavigationBar: CustomBottomNavBar(

        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {

            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Get.offAll(HomeScreen());
              break;
            case 1:
              Get.offAll(OffersScreen());

              break;
            case 2:
              Get.offAll(CreateNewAdOptions());

              break;

            case 3:
              Get.find<BrandController>().switchLoading();
              Get.find<BrandController>().getFavList();
              Get.offAll(FavouriteScreen());
              break;
            case 4:
              Get.offAll(ContactUsScreen());
              break;
          }
        },
        onAddPressed: () {
          // TODO: Handle Add button tap
          Get.to(CreateNewAdOptions());
        },
      ),

    );
  }

  blackCircle(String assets){
    return CircleAvatar(
      radius: 17,
      backgroundColor: Colors.black,
      child: Center(child: SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(assets,color: Colors.white,

            fit: BoxFit.contain,
          ))),
    );
  }
}