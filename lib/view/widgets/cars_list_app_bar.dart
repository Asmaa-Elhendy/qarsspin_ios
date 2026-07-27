import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/view/screens/notifications/notifications.dart';

import '../../controller/const/colors.dart';
import '../../controller/notifications_controller.dart';


 carListAppBar(NotificationsController notificationsController,{required int notificationCount,required BuildContext context}){

  return AppBar(
    centerTitle: true,
    backgroundColor:AppColors.background(context),
    toolbarHeight: 60.h,
    elevation: 0,
    //shadowColor: AppColors.shadowColor(context),
    shadowColor: Colors.grey.shade300,
    // elevation: 3,

    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        boxShadow: [
          BoxShadow( //update asmaa
            color: AppColors.blackColor(context).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5.h,
            offset: Offset(0, 2),
          ),
        ],
      ),
    ),
    leading: GestureDetector(
      onTap: () {
        Navigator.pop(context);
       // Get.back();
      },
      child: Icon(Icons.arrow_back,
          color: Theme.of(context).iconTheme.color),
    ),
    title: SizedBox(
      height: 140,
      width: 140,
      child: Image.asset(
        Theme.of(context).brightness == Brightness.dark
            ? 'assets/images/balckIconDarkMode.png'
            : 'assets/images/black_logo.png',
        fit: BoxFit.cover,
      ),
    ),
    actions: [
      SizedBox(
        width: 64, // give Stack a stable box inside AppBar actions
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The tappable "Q" icon
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Image.asset(
                  'assets/images/logo_the_q.png',
                  width: 40.w,
                  height: 35.h,
                ),
              ),
            ),

            // The badge MUST be a direct child of Stack.
            //
            // Read `notificationCount` (unread, backend + local) rather than
            // `notifications.length` (total list size). This lets the badge
            // drop after `markAllAsRead()` on the notifications page, which
            // changes the unread counters but does NOT change the list length.
            //
            // The badge is always visible — even when the count is 0 —
            // per product decision. To hide it when empty, guard on
            // `count == 0` and return `SizedBox.shrink()` here.
            Obx(() {
              final count = notificationsController.notificationCount;
              debugPrint('🔔 Notification count: $count');

              return PositionedDirectional(
                // works for both LTR/RTL without manual left/right logic
                start: 6.w,
                top: 10.h,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsPage()),
                    );
                  },
                  child: Container(
                    height: 17.h,
                    width: 18.w,
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 8),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ],

  );

 }