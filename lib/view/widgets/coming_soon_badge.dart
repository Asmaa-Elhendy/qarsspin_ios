import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/const/app_strings.dart';
import '../../controller/const/base_url.dart';
import '../../controller/const/colors.dart';

class ComingSoonBadge extends StatelessWidget {
  final double? width;
  final double? borderRadius;

  const ComingSoonBadge({
    Key? key,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final badgeWidth = width ?? 24.w;
    final radius = Radius.circular(borderRadius ?? 6.r);
    final badgeText = isRtl
        ? '\u{642}\u{631}\u{64A}\u{628}\u{627}\u{64B}'
        : AppStrings.comingSoon;

    return Container(
      width: badgeWidth,
      decoration: BoxDecoration(
      color:   AppColors.danger,


      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RotatedBox(
          quarterTurns: isRtl ? 3 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              badgeText,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontFamily: fontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
