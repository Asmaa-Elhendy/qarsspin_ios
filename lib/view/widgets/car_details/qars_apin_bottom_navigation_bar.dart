import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../l10n/app_localizations.dart';

class QarsApinBottomNavigationBar extends StatefulWidget {
  final VoidCallback onRequestToBuy;
  final VoidCallback onMakeOffer;
  final VoidCallback onLoan;

   QarsApinBottomNavigationBar({required this.onLoan,required this.onMakeOffer,required this.onRequestToBuy,super.key});

  @override
  State<QarsApinBottomNavigationBar> createState() => _QarsApinBottomNavigationBarState();
}

class _QarsApinBottomNavigationBarState extends State<QarsApinBottomNavigationBar> {

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background(context),

      ),
      child: Row(spacing: 2.w,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          button(lc.btn_request_to_buy, widget.onRequestToBuy, "assets/images/new_svg/requestBuy.svg"),
          button(lc.btn_make_offer, widget.onMakeOffer, "assets/images/new_svg/makeOffer.svg"),
          button(lc.btn_byu_loan, widget.onLoan, "assets/images/new_svg/loan.svg"),

        ],
      ),
    );
  }
  button(title,onTap,image){
    return InkWell(
      onTap: onTap,
      child: Container(

        padding: EdgeInsets.symmetric(horizontal: 22.w,vertical: 8.h),

        decoration: BoxDecoration(
          color: AppColors.primary,
            borderRadius: BorderRadius.circular(6).r


        ),
        child: Row(
          children: [
            SvgPicture.asset(image),
            6.horizontalSpace,
            Text(title,style: TextStyle(
              color: AppColors.black,
              fontSize: 14.sp,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600
            ),)

          ],
        ),
      ),
    );
  }
}
