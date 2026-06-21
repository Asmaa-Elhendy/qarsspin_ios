import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/texts/privacy_policy_ar.dart';
import '../../widgets/texts/privacy_policy_texts_en.dart';

class PrivacyPolicey extends StatelessWidget {
  const PrivacyPolicey({super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(

      backgroundColor: AppColors.background(context),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.background(context),
          toolbarHeight: 60.h,
          shadowColor: Colors.grey.shade300,

          elevation: .4,

          title: Text(
            lc.lbl_privacy_policy,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Get.locale?.languageCode=='ar'
                  ?PrivacyPolicyAr()
                  : PrivacyPolicyEn()

            ],
          ),
        ),
      ),
    );
  }
}
