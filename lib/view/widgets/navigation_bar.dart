// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../controller/const/colors.dart';
// import '../../l10n/app_localizations.dart';
// import 'dart:io' show Platform;
// class CustomBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onTabSelected;
//   final VoidCallback onAddPressed;
//
//   const CustomBottomNavBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onTabSelected,
//     required this.onAddPressed,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final double barHeight =Platform.isAndroid?60:65.0;//60
//
//     final double addButtonSize = 60.0;
//     final double iconSize = 24.0;
//     final double labelFontSize = 10.0;
//     var lc = AppLocalizations.of(context)!;
//
//
//     return Container(
//
//       child: Stack(
//         clipBehavior: Clip.none, // Allow the add button to overflow
//         alignment: Alignment.bottomCenter,
//         children: [
//           Container(
//             height: barHeight,
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(
//                     index: 0,
//                     label: lc.navigation_home,
//                     isSelected: selectedIndex == 0,
//                     iconSize: iconSize,
//                     labelFontSize: labelFontSize,
//                     context: context
//                 ),
//
//                 _buildNavItem(
//                     index: 1,
//                     label: lc.navigation_offers,
//                     isSelected: selectedIndex == 1,
//                     iconSize: iconSize,
//                     labelFontSize: labelFontSize,
//                     context: context
//                 ),
//
//                 // Invisible placeholder for the add button
//                 Opacity(
//                   opacity: 0,
//                   child: _buildNavItem(
//                       index: 2,
//                       label: lc.navigation_add,
//                       isSelected: false,
//                       iconSize: iconSize,
//                       labelFontSize: labelFontSize,
//                       context: context
//
//                   ),
//                 ),
//
//                 _buildNavItem(
//                     index: 3,
//                     label: lc.navigation_favorites,
//                     isSelected: selectedIndex == 3,
//                     iconSize: iconSize,
//                     labelFontSize: labelFontSize,
//                     context: context
//                 ),
//
//                 _buildNavItem(
//                     index: 4,
//                     label: lc.navigation_call_us,
//                     isSelected: selectedIndex == 4,
//                     iconSize: iconSize,
//                     labelFontSize: labelFontSize,
//                     context: context
//                 ),
//               ],
//             ),
//           ),
//
//
//           Positioned(
//             bottom:Platform.isAndroid?20.h: 30.h,
//             child: GestureDetector(
//               onTap: onAddPressed,
//               child: Container(
//                 width: addButtonSize,
//                 height: addButtonSize,
//                 decoration: BoxDecoration(
//                   color: AppColors.divider(context), // Using navBarGray color
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppColors.background(context), width: 3.w), // Using navBarWhite constant
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.add,
//                         color: Colors.white, // White icon
//                         size: 26.w, // Slightly smaller icon
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         lc.navigation_add,
//                         style: TextStyle(
//                           color: Colors.white, // White text
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Gilroy',
//                           height: 1.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required int index,
//     required String label,
//     required bool isSelected,
//     required double iconSize,
//     required double labelFontSize,
//     required BuildContext context
//   }) {
//     final iconColor = isSelected ? AppColors.divider(context) : AppColors.white;
//
//     Widget iconWidget;
//
//     if (index == 0) {
//       // Home - Flutter Icon
//       iconWidget = Icon(
//         Icons.home ,
//         color:  isSelected ?AppColors.divider(context):AppColors.white,
//         size: iconSize,
//       );
//       // Get.offAll(HomeScreen());
//     } else if (index == 3) {
//       // Favorite - Flutter Icon
//       iconWidget = Icon(
//         Icons.favorite,
//         color:  isSelected ?AppColors.divider(context):AppColors.white,
//         size: iconSize,
//       );
//     } else {
//       // Offers and Contact - Image Assets
//       final imagePath = switch (index) {
//         1 => 'assets/images/ic_offers.png',    // Offers
//         4 => 'assets/images/ic_contact.png',   // Contact
//         _ => 'assets/images/ic_offers.png',    // Default (shouldn't happen)
//       };
//
//       iconWidget = ColorFiltered(
//         colorFilter: ColorFilter.mode(
//           iconColor,
//           BlendMode.srcIn,
//         ),
//         child: Image.asset(
//           imagePath,
//           width: iconSize,
//           height: iconSize,
//           fit: BoxFit.contain,
//         ),
//       );
//     }
//
//     return GestureDetector(
//       onTap: () => onTabSelected(index),
//       behavior: HitTestBehavior.opaque,
//       child: Padding(
//         padding:  EdgeInsets.only(bottom:Platform.isAndroid? 0:4.sp),
//         child: Container(
//         //h
//           padding:  EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,//j
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 iconWidget,
//                 const SizedBox(height: 2),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: isSelected ? AppColors.divider(context) : AppColors.white,
//                     fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
//                     fontSize: labelFontSize,
//                     fontFamily: 'Gilroy',
//                     letterSpacing: -0.2,
//                     height: 1.0,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../controller/const/colors.dart';
// import '../../l10n/app_localizations.dart';
//
// class CustomBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onTabSelected;
//   final VoidCallback onAddPressed;
//
//   const CustomBottomNavBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onTabSelected,
//     required this.onAddPressed,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final lc = AppLocalizations.of(context)!;
//
//     final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
//     final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
//
//     final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     /*
//       ارتفاع شريط التنقل:
//       - Android أقل شوية
//       - iOS أعلى شوية بسبب الـ home indicator
//       - SafeArea محسوبة عشان الزرار ما ينزلش تحت
//     */
//     final double navBarHeight = isIOS ? 66.h : 60.h;
//
//     /*
//       حجم زرار Add:
//       clamp معناها:
//       لا يقل عن 54
//       لا يزيد عن 62
//       ويتغير حسب عرض الشاشة
//     */
//     final double addButtonSize = (screenWidth * 0.145).clamp(54.0, 62.0);
//
//     final double iconSize = (screenWidth * 0.058).clamp(22.0, 26.0);
//     final double labelFontSize = (screenWidth * 0.026).clamp(9.0, 11.0);
//
//     /*
//       مكان زرار Add:
//       مربوط بارتفاع الـ nav bar
//       ومعمول له تعديل بسيط حسب iOS/Android
//     */
//     final double addButtonBottom = navBarHeight - (addButtonSize / 2) + (isIOS ? 2.h : 0);
//
//     return Container(
//       padding: EdgeInsets.only(bottom: bottomSafeArea),
//       color: Colors.transparent,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.bottomCenter,
//         children: [
//           Container(
//             height: navBarHeight,
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(
//                   index: 0,
//                   label: lc.navigation_home,
//                   isSelected: selectedIndex == 0,
//                   iconSize: iconSize,
//                   labelFontSize: labelFontSize,
//                   context: context,
//                   isIOS: isIOS,
//                 ),
//
//                 _buildNavItem(
//                   index: 1,
//                   label: lc.navigation_offers,
//                   isSelected: selectedIndex == 1,
//                   iconSize: iconSize,
//                   labelFontSize: labelFontSize,
//                   context: context,
//                   isIOS: isIOS,
//                 ),
//
//                 Expanded(
//                   child: Opacity(
//                     opacity: 0,
//                     child: GestureDetector(
//                       onTap: () {},
//                       behavior: HitTestBehavior.opaque,
//                       child: Container(
//                         height: double.infinity,
//                         padding: EdgeInsets.only(
//                           top: 4.h,
//                           bottom: isIOS ? 5.h : 3.h,
//                           left: 2.w,
//                           right: 2.w,
//                         ),
//                         child: Center(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.add,
//                                 color: AppColors.white,
//                                 size: iconSize,
//                               ),
//                               SizedBox(height: 2.h),
//                               Text(
//                                 lc.navigation_add,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: AppColors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: labelFontSize,
//                                   fontFamily: 'Gilroy',
//                                   letterSpacing: -0.2,
//                                   height: 1.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 _buildNavItem(
//                   index: 3,
//                   label: lc.navigation_favorites,
//                   isSelected: selectedIndex == 3,
//                   iconSize: iconSize,
//                   labelFontSize: labelFontSize,
//                   context: context,
//                   isIOS: isIOS,
//                 ),
//
//                 _buildNavItem(
//                   index: 4,
//                   label: lc.navigation_call_us,
//                   isSelected: selectedIndex == 4,
//                   iconSize: iconSize,
//                   labelFontSize: labelFontSize,
//                   context: context,
//                   isIOS: isIOS,
//                 ),
//               ],
//             ),
//           ),
//
//           Positioned(
//             bottom: addButtonBottom,
//             child: GestureDetector(
//               onTap: onAddPressed,
//               child: Container(
//                 width: addButtonSize,
//                 height: addButtonSize,
//                 decoration: BoxDecoration(
//                   color: AppColors.divider(context),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppColors.background(context),
//                     width: 3.w,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.add,
//                         color: Colors.white,
//                         size: (addButtonSize * 0.43).clamp(24.0, 28.0),
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         lc.navigation_add,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: (addButtonSize * 0.18).clamp(10.0, 12.0),
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Gilroy',
//                           height: 1.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required int index,
//     required String label,
//     required bool isSelected,
//     required double iconSize,
//     required double labelFontSize,
//     required BuildContext context,
//     required bool isIOS,
//   }) {
//     final iconColor = isSelected ? AppColors.divider(context) : AppColors.white;
//
//     Widget iconWidget;
//
//     if (index == 0) {
//       iconWidget = Icon(
//         Icons.home,
//         color: iconColor,
//         size: iconSize,
//       );
//     } else if (index == 3) {
//       iconWidget = Icon(
//         Icons.favorite,
//         color: iconColor,
//         size: iconSize,
//       );
//     } else {
//       final imagePath = switch (index) {
//         1 => 'assets/images/ic_offers.png',
//         4 => 'assets/images/ic_contact.png',
//         _ => 'assets/images/ic_offers.png',
//       };
//
//       iconWidget = ColorFiltered(
//         colorFilter: ColorFilter.mode(
//           iconColor,
//           BlendMode.srcIn,
//         ),
//         child: Image.asset(
//           imagePath,
//           width: iconSize,
//           height: iconSize,
//           fit: BoxFit.contain,
//         ),
//       );
//     }
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTabSelected(index),
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           height: double.infinity,
//           padding: EdgeInsets.only(
//             top: 4.h,
//             bottom: isIOS ? 5.h : 3.h,
//             left: 2.w,
//             right: 2.w,
//           ),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 iconWidget,
//                 SizedBox(height: 2.h),
//                 Flexible(
//                   child: Text(
//                     label,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: iconColor,
//                       fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
//                       fontSize: labelFontSize,
//                       fontFamily: 'Gilroy',
//                       letterSpacing: -0.2,
//                       height: 1.0,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/const/colors.dart';
import '../../l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onAddPressed;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lc = AppLocalizations.of(context)!;

    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final double screenWidth = MediaQuery.of(context).size.width;

    /*
      ارتفاع شريط التنقل:
      - Android أقل شوية
      - iOS أعلى شوية بسبب الـ home indicator
      - SafeArea محسوبة عشان الزرار ما ينزلش تحت
    */
    final double navBarHeight = isIOS ? 66.h : 60.h;

    final double iconSize = (screenWidth * 0.058).clamp(22.0, 26.0);
    final double labelFontSize = (screenWidth * 0.026).clamp(9.0, 11.0);

    return Container(
    //  padding: EdgeInsets.only(bottom: bottomSafeArea),
     // color: AppColors.primary,
      child: Container(
        height: navBarHeight,
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              label: lc.navigation_home,
              isSelected: selectedIndex == 0,
              iconSize: iconSize,
              labelFontSize: labelFontSize,
              context: context,
              isIOS: isIOS,
            ),

            _buildNavItem(
              index: 1,
              label: lc.navigation_offers,
              isSelected: selectedIndex == 1,
              iconSize: iconSize,
              labelFontSize: labelFontSize,
              context: context,
              isIOS: isIOS,
            ),

            // مكان فاضي في النص لزرار Add اللي هيبقى FloatingActionButton
            Expanded(
              child: IgnorePointer(
                child: Container(
                  height: double.infinity,
                ),
              ),
            ),

            _buildNavItem(
              index: 3,
              label: lc.navigation_favorites,
              isSelected: selectedIndex == 3,
              iconSize: iconSize,
              labelFontSize: labelFontSize,
              context: context,
              isIOS: isIOS,
            ),

            _buildNavItem(
              index: 4,
              label: lc.navigation_call_us,
              isSelected: selectedIndex == 4,
              iconSize: iconSize,
              labelFontSize: labelFontSize,
              context: context,
              isIOS: isIOS,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required bool isSelected,
    required double iconSize,
    required double labelFontSize,
    required BuildContext context,
    required bool isIOS,
  }) {
    final iconColor = isSelected ? AppColors.divider(context) : AppColors.white;

    Widget iconWidget;

    if (index == 0) {
      iconWidget = Icon(
        Icons.home,
        color: iconColor,
        size: iconSize,
      );
    } else if (index == 3) {
      iconWidget = Icon(
        Icons.favorite,
        color: iconColor,
        size: iconSize,
      );
    } else {
      final imagePath = switch (index) {
        1 => 'assets/images/ic_offers.png',
        4 => 'assets/images/ic_contact.png',
        _ => 'assets/images/ic_offers.png',
      };

      iconWidget = ColorFiltered(
        colorFilter: ColorFilter.mode(
          iconColor,
          BlendMode.srcIn,
        ),
        child: Image.asset(
          imagePath,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          padding: EdgeInsets.only(
            top: 4.h,
            bottom: isIOS ? 5.h : 3.h,
            left: 2.w,
            right: 2.w,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                SizedBox(height: 2.h),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: labelFontSize,
                      fontFamily: 'Gilroy',
                      letterSpacing: -0.2,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}