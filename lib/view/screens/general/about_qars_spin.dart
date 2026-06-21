import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/texts/about_ar.dart';
import '../../widgets/texts/about_en.dart';

class AboutQarsSpin extends StatelessWidget {
  const AboutQarsSpin({super.key});

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
            lc.lbl_about_qars_spin,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Get.locale?.languageCode=='ar'
                ? AboutAr()
                : AboutEn()

          ],
        ),
      ),
    );
  }
}
