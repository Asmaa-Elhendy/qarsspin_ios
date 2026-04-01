import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/my_ads/my_ad_data_layer.dart';
import 'package:qarsspin/view/screens/auth/registration_screen.dart';
import 'package:qarsspin/view/screens/favourites/favourite_screen.dart';
import 'package:qarsspin/view/screens/my_ads/my_ads_main_screen.dart';

import 'package:qarsspin/controller/auth/auth_controller.dart';
import 'package:qarsspin/controller/my_ads/my_ad_getx_controller.dart';
import '../../../controller/brand_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localization.dart';
import '../my_offers_screen.dart';
import '../notifications/notifications.dart';

class MyAccount extends StatefulWidget {
  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {

  final authController2 = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.blackColor(context),
            size: 24.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lc.title_Personal_Information,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontFamily: 'Gilroy',
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),

      // ✅ هنا مفيش ScrollView ثابتة؛ بنختار حسب حالة الـ user
      body: Obx(() {
        if (authController.registered) {
          // 👈 مسجل → نرجّع الـ ListView زي ما هو مع نفس الـ Padding الخارجي
          return Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 16.h,
              bottom: 16.h,
            ),
            child: bodyWithRegistered(context, lc),
          );
        } else {
          // 👈 مش مسجل → نفس الكود القديم: Scroll + Padding + Column
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 16.h,
              ),
              child: bodyWithoutRegister(context, lc),
            ),
          );
        }
      }),
    );
  }

  Widget bodyWithoutRegister(context, lc) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.profile(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: Text(
                lc.register_account,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor(context),
                ),
              ),
              trailing: Image.asset(
                "assets/images/arrow.png",
                scale: 1.8,
              ),
              onTap: () {
                Get.to(RegistrationScreen());
              },
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: Text(
              lc.lbl_notifications,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Image.asset(
              "assets/images/arrow.png",
              scale: 1.8,
            ),
            onTap: () {
              Get.to(NotificationsPage());
            },
          ),
        ],
      ),
    );
  }

  Widget bodyWithRegistered(context, lc) {
    final myAdsController = Get.put(MyAdCleanController(MyAdDataLayer()));

    // 👇 مفيش أي تغيير في الديزاين هنا؛ نفس الـ ListView اللي عندك
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.profile(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.lightGrayColor(context),
                    child: Icon(Icons.person, size: 80.w, color: Colors.black),
                  ),
                  8.verticalSpace,
                  Obx(
                        () => Text(
                      "${lc.active_ads} ${myAdsController.activeAdsCountNew}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.shadowColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              16.horizontalSpace,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      authController2.userFullName ?? "Guest",
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      authController2.getCurrentUser()['mobileNumber'] ?? "",
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        24.verticalSpace,
        buildMenuItem(
          icon: Icons.notifications,
          title: lc.lbl_notifications,
          iconColor: Colors.red,
          context: context,
          onTap: () {
            Get.to(NotificationsPage());
          },
          lc: lc,
        ),
        buildMenuItem(
          icon: Icons.local_offer,
          title: lc.lbl_my_offers,
          context: context,
          onTap: () {
            Get.to(OffersScreen());
          },
          lc: lc,
        ),
        buildMenuItem(
          icon: Icons.campaign,
          title: lc.adv_lbl,
          onTap: () {
            Get.to(MyAdsMainScreen());
          },
          context: context,
          lc: lc,
        ),
        buildMenuItem(
          onTap: () {
            Get.find<BrandController>().switchLoading();
            Get.find<BrandController>().getFavList();
            Get.to(FavouriteScreen());
          },
          icon: Icons.favorite,
          title: lc.fav_lbl,
          context: context,
          lc: lc,
        ),
        buildMenuItem(
          icon: Icons.notifications_active,
          title: lc.person_notification,
          context: context,
          lc: lc,
        ),
        const SizedBox(height: 20),
        buildMenuItem(
          icon: Icons.logout,
          title: lc.lbl_sign_out,
          lc: lc,
          context: context,
          onTap: () async {
            final authController = Get.find<AuthController>();
            await authController.clearUserData();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationScreen(),
              ),
            );
          },
        ),
        buildMenuItem(
          icon: Icons.delete_outline,
          title: lc.delete_account,
          context: context,
          lc: lc,
        ),
      ],
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    VoidCallback? onTap,
    context,
    required lc,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? AppColors.blackColor(context)),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: Image.asset(
            "assets/images/arrow.png",
            scale: 1.8,
          ),
          onTap: onTap,
        ),
        title == lc.lbl_sign_out || title == lc.delete_account
            ? const SizedBox()
            : Divider(
          height: 1,
          color: AppColors.divider(context),
        ),
      ],
    );
  }
}
