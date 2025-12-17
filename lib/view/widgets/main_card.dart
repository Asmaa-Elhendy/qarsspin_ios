import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import '../../controller/const/colors.dart';
import '../../l10n/app_localization.dart';



class HomeServiceCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  bool large;
  bool brand;
  int  make_count;
  String fromHome;
  bool fromHomeSmall;
  bool plate;
  String? imageAsset2;
  final VoidCallback? onTap;

  HomeServiceCard({
    Key? key,
    this.brand = false,
    this.plate=false,
    this.imageAsset2="",
    this.make_count =0,
    required this.title,
    this.fromHome='',
    this.fromHomeSmall=false,
    required this.imageAsset,
    required this.large,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    // final screenWidth = MediaQuery.of(context).size.width;
    // final cardSize = (screenWidth - 48 - 16) / 2; // reduce card size: more horizontal padding and spacing
    // final iconSize = cardSize * 0.36;
    // final headerHeight = cardSize * 0.20;
    // final fontSize = cardSize * 0.088;

    return GestureDetector(
      onTap: onTap,
      child:

      plate?Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            //    height: large?126.h :120.h, //update asmaa
            width: large? 55.w: 55.w,
            decoration: BoxDecoration(
              color:AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // stronger shadow
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 35.h,
                  decoration:  BoxDecoration(
                    color: AppColors.topBox(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize:brand?12.w: 13.5.w, //update asmaa
                      color: Colors.white,
                    ),
                  ),
                ),
                brand?
                title==lc.all_cars
                    ? Expanded(
                    child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                        )))
                    :
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageAsset,
                    fit: BoxFit.cover,//j

                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/ic_all_cars.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                )





                    :Expanded(
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child:  fromHome=='true'?
                        SvgPicture.asset(
                          fit: BoxFit.fill,
                          imageAsset,
                          width:Theme.of(context).brightness == Brightness.dark?75.w:title.contains(lc.ads)?65.w:fromHomeSmall?48.58.w: 95.37.w,
                          height:Theme.of(context).brightness == Brightness.dark?87.33.h:title==lc.create_car_ads?85.h :title.contains(lc.ads)?72.h:fromHomeSmall?30:75.33.h,

                        ):  Image.asset(
                          imageAsset,
                          width: 58.w,
                          height: 40.h,

                          fit: BoxFit.contain,
                        )
                    ),
                  ),
                ),
                brand? Center(child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("${make_count} ${lc.cars}",style: TextStyle(color: AppColors.textSecondary(context),fontWeight: FontWeight.bold,fontSize: 14.sp),),
                )):SizedBox()
              ],
            ),
          ),
          Positioned(
              left:fromHomeSmall?57.w:90.w,
              right:6,
              top: 70.h,
              child: SvgPicture.asset(
                fit: BoxFit.fill,
                imageAsset2!,
                width:large?45.w:fromHomeSmall?75.w:88.w,
                height:large?70.h: fromHomeSmall?65.h:100.h,

              ))
        ],
      ):
      Container(
        margin: const EdgeInsets.all(4),
        //    height: large?126.h :120.h, //update asmaa
        width: large? 55.w: 55.w,
        decoration: BoxDecoration(
          color:AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // stronger shadow
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 35.h,
              decoration:  BoxDecoration(
                color: AppColors.topBox(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontFamily,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                  fontSize:brand?12.w: 13.5.w, //update asmaa
                  color: Colors.white,
                ),
              ),
            ),
            brand?
            title==lc.all_cars
                ? Expanded(
                child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                    )))
                :
            Expanded(
              child: CachedNetworkImage(
                imageUrl: imageAsset,
                fit: BoxFit.cover,//j

                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/ic_all_cars.png',
                  fit: BoxFit.contain,
                ),
              ),
            )





                :Expanded(
              child: Center(
                child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child:  fromHome=='true'?
                    SvgPicture.asset(
                      fit: BoxFit.fill,
                      imageAsset,
                      width:Theme.of(context).brightness == Brightness.dark?75.w:title.contains(lc.ads)?65.w:fromHomeSmall?48.58.w: 95.37.w,
                      height:Theme.of(context).brightness == Brightness.dark?87.33.h:title==lc.create_car_ads?85.h :title.contains(lc.ads)?72.h:fromHomeSmall?30:75.33.h,

                    ):  Image.asset(
                      imageAsset,
                      width: 58.w,
                      height: 40.h,

                      fit: BoxFit.contain,
                    )
                ),
              ),
            ),
            brand? Center(child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("${make_count} ${lc.cars}",style: TextStyle(color: AppColors.textSecondary(context),fontWeight: FontWeight.bold,fontSize: 14.sp),),
            )):SizedBox()
          ],
        ),
      ),
    );
  }
}