import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/communications.dart';
import '../../controller/const/colors.dart';
import '../../l10n/app_localizations.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onMakeOffer;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;


  const BottomActionBar({
    super.key,
    required this.onMakeOffer,
    required this.onWhatsApp,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDC83B), // yellow color
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              icon: Image.asset("assets/images/Group.png"),
              label:  Text(
                lc.make_offer_one_line,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
              onPressed: onMakeOffer,
            ),
          ),
          SizedBox(width: 8.w),
          squareButton(Image.asset("assets/images/whats.png",),onWhatsApp,green: true),

          // InkWell(
          //   onTap: onWhatsApp,
          //   child: SizedBox(
          //     width: 55.w,
          //      height: 55.h,
          //     child: Image.asset("assets/images/whatsgreen.png",
          //       fit: BoxFit.cover,
          //
          //     ),
          //   )
          // ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onCall,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.call, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  squareButton(icon, onTap,{bool green = false}){
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 48.w,
          height: 48.w,
          // padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 12.w),
          decoration: BoxDecoration(
            color:!green? AppColors.primary:AppColors.success,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: icon,
          )
      ),
    );
  }
}
