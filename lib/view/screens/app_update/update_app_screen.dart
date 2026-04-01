import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qarsspin/controller/const/colors.dart';
import '../../../l10n/app_localization.dart';
import '../../../services/app_update_service.dart';

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  // Function to open the store URL dynamically
  void openStore() async {
    final url = Uri.parse(AppUpdateService.getStoreUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Can't open store URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background(context),

      // نفس شكل AppBar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(88.h),
        child: Container(
          height: 88.h,
          padding: EdgeInsets.only(top: 13.h, left: 14.w, right: 14.w),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 147.w,
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/balckIconDarkMode.png'
                    : 'assets/images/black_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.system_update, size: 80.w, color: Colors.grey),

              20.verticalSpace,

              Text(
                l10n.app_outdated,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              12.verticalSpace,

              Text(
                l10n.update_app_message,
                textAlign: TextAlign.center,
              ),

              30.verticalSpace,

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: openStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    l10n.update_now,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}