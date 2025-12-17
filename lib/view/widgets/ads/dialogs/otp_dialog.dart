// import 'dart:developer' as l;
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:math';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../controller/auth/auth_controller.dart';
// import '../../../../controller/const/base_url.dart';
// import '../../../../controller/const/colors.dart';
// import '../../../../l10n/app_localization.dart';
// import 'error_dialog.dart';
//
// class OTPDialog extends StatefulWidget {
//
//   final TextEditingController otpController;
//   final String otpSecret;
//   final int otpCount;
//   final bool isLoading;
//   final Function(bool) onLoadingChange;
//   final VoidCallback onValidOTP;
//   final VoidCallback onInvalidOTP;
//   final VoidCallback onRegister;
//   final bool request; // لتحديد هل هو alert خاص بطلب أو لا
//   final  String mobile;
//   final String name;
//   final String email;
//   const OTPDialog({
//     Key? key,
//     required this.otpController,
//     required this.otpSecret,
//     required this.otpCount,
//     required this.isLoading,
//     required this.onLoadingChange,
//     required this.onValidOTP,
//     required this.onInvalidOTP,
//     required this.onRegister,
//     required this.request,
//     required this.mobile,
//     required this.name,
//     required this.email
//   }) : super(key: key);
//   @override
//   State<OTPDialog> createState() => _OTPDialogState();
//
//   static void show({
//     required   String mobile,
//     required String name,
//     required BuildContext context,
//     required TextEditingController otpController,
//     required String otpSecret,
//     required int otpCount,
//     required bool isLoading,
//     required Function(bool) onLoadingChange,
//     required VoidCallback onValidOTP,
//     required VoidCallback onInvalidOTP,
//     required VoidCallback onRegister,
//     required bool request,
//     required String email,
//
//   })
//   {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => OTPDialog(
//         email: email,
//         mobile:mobile,
//         name:name,
//         otpController: otpController,
//         otpSecret: otpSecret,
//         otpCount: otpCount,
//         isLoading: isLoading,
//         onLoadingChange: onLoadingChange,
//         onValidOTP: onValidOTP,
//         onInvalidOTP: onInvalidOTP,
//         onRegister: onRegister,
//         request: request,
//       ),
//     );
//   }
// }
//
// class _OTPDialogState extends State<OTPDialog> {
//
//   @override
//   Widget build(BuildContext context) {
//     var lc = AppLocalizations.of(context)!;
//
//     return Dialog(
//       backgroundColor: AppColors.toastBackground,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 16.h),
//         height: widget.request ? 270.h : 330.h,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.zero,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               lc.verify_msg,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontFamily: fontFamily,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 15.sp,
//               ),
//             ),
//             8.verticalSpace,
//             Text(
//               lc.enter_otp_msg,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontFamily: fontFamily,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14.sp,
//               ),
//             ),
//             20.verticalSpace,
//             Container(height: 40.h,
//               child: TextField(
//                 controller: widget.otpController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: lc.verify_msg,
//                   hintStyle: TextStyle(color: Colors.grey.shade400),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.1),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                     borderSide: BorderSide(
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                     borderSide: BorderSide(
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   contentPadding:
//                   EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
//                 ),
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             18.verticalSpace,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 cancelButton(() {
//                   Navigator.pop(context);
//                 }, lc.btn_Cancel, widget.request),
//                 10.horizontalSpace,
//                 yellowButtons(
//                   title: lc.btn_Verify,
//                   onTap: () async {
//                     if (widget.otpController.text.isEmpty) {
//                       showErrorAlert('Please enter the OTP',context);
//                       return;
//                     }
//
//                     Navigator.pop(context);
//                     widget.onLoadingChange(true);
//
//                     try {
//                       if (widget.otpController.text == widget.otpSecret) {
//                         l.log('otp count**********${widget.otpCount}');
//                         if (widget.otpCount == 1) {
//                           l.log('here in login******* ${widget.mobile}');
//                           final prefs = await SharedPreferences.getInstance();
//                           await prefs.setString('username',widget.mobile);
//                           await prefs.setString('fullName',  widget.name);
//                           await prefs.setString('Mobile',widget.mobile);
//                           await prefs.setString('Email',  widget.email);
//                           Get.find<AuthController>().updateRegisteredStatus(true,widget.mobile,widget.name,widget.mobile,widget.email);  // or false
//
//                           widget.onValidOTP(); // Navigate to home
//                         } else if (widget.otpCount == 0) {
//                           // For new registration (count = 0), proceed with registration
//                           widget.onRegister();
//                         } else {
//                           // For any other case, just navigate to home
//                           widget.onValidOTP();
//                         }
//                       } else {
//                         showErrorAlert('Invalid OTP. Please try again.', context);
//                         widget.onInvalidOTP();
//                       }
//                     } catch (e) {
//                       showErrorAlert('An error occurred. Please try again.', context);
//                       l.log('OTP Verification Error: $e');
//                     } finally {
//                       widget.onLoadingChange(false);
//                     }
//                   },
//                   context: context,
//                   w: 95.w,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ⬇️ نفس دوال الأزرار المستخدمة في SuccessDialog
// Widget cancelButton(VoidCallback onTap, String title, bool request) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       width: 95.w,
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6.r),
//         border: Border.all(color: Colors.white, width: 1),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: AppColors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: 14.sp,
//         ),
//       ),
//     ),
//   );
// }
//
// Widget yellowButtons({
//   required String title,
//   required VoidCallback onTap,
//   required BuildContext context,
//   required double w,
// }) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       width: w,
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(6.r),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 14.sp,
//         ),
//       ),
//     ),
//   );
// }
//
// void showErrorAlert(String message,BuildContext context) {
//   ErrorDialog.show(
//
//       context,
//       message,
//           () {
//         // Navigator.pop(context);
//       },
//       isModifyMode: false,
//       fromOtp:true);
//
// }
import 'dart:developer' as l;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../controller/auth/auth_controller.dart';
import '../../../../controller/const/base_url.dart';
import '../../../../controller/const/colors.dart';
import '../../../../l10n/app_localization.dart';
import 'error_dialog.dart';

class OTPDialog extends StatefulWidget {
  final TextEditingController otpController;
  final String otpSecret;
  final int otpCount;
  final bool isLoading;
  final Function(bool) onLoadingChange;
  final VoidCallback onValidOTP;
  final VoidCallback onInvalidOTP;
  final VoidCallback onRegister;
  final bool request; // لتحديد هل هو alert خاص بطلب أو لا
  final String mobile;
  final String name;
  final String email;

  /// بيانات المستخدم اللي راجعة من الـ API (مثلاً Data[0])
  final Map<String, dynamic>? userData;

  const OTPDialog({
    Key? key,
    required this.otpController,
    required this.otpSecret,
    required this.otpCount,
    required this.isLoading,
    required this.onLoadingChange,
    required this.onValidOTP,
    required this.onInvalidOTP,
    required this.onRegister,
    required this.request,
    required this.mobile,
    required this.name,
    required this.email,
    this.userData,
  }) : super(key: key);

  @override
  State<OTPDialog> createState() => _OTPDialogState();

  static void show({
    required String mobile,
    required String name,
    required String email,
    required BuildContext context,
    required TextEditingController otpController,
    required String otpSecret,
    required int otpCount,
    required bool isLoading,
    required Function(bool) onLoadingChange,
    required VoidCallback onValidOTP,
    required VoidCallback onInvalidOTP,
    required VoidCallback onRegister,
    required bool request,
    Map<String, dynamic>? userData, // ✅ نمرر الـ Data هنا لو موجودة
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OTPDialog(
        email: email,
        mobile: mobile,
        name: name,
        otpController: otpController,
        otpSecret: otpSecret,
        otpCount: otpCount,
        isLoading: isLoading,
        onLoadingChange: onLoadingChange,
        onValidOTP: onValidOTP,
        onInvalidOTP: onInvalidOTP,
        onRegister: onRegister,
        request: request,
        userData: userData,
      ),
    );
  }
}

class _OTPDialogState extends State<OTPDialog> {
  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.toastBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 16.h),
        height: widget.request ? 270.h : 330.h,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lc.verify_msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 15.sp,
              ),
            ),
            8.verticalSpace,
            Text(
              lc.enter_otp_msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
            20.verticalSpace,
            SizedBox(
              height: 40.h,
              child: TextField(
                controller: widget.otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: lc.verify_msg,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            18.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cancelButton(() {
                  Navigator.pop(context);
                }, lc.btn_Cancel, widget.request),
                10.horizontalSpace,
                yellowButtons(
                  title: lc.btn_Verify,
                  onTap: () async {
                    if (widget.otpController.text.isEmpty) {
                      showErrorAlert('Please enter the OTP', context);
                      return;
                    }

                    Navigator.pop(context);
                    widget.onLoadingChange(true);

                    try {
                      if (widget.otpController.text == widget.otpSecret) {
                        l.log('otp count**********${widget.otpCount}');
                        if (widget.otpCount == 1) {
                          // 🔐 حالة الـ Login
                          l.log('here in login******* ${widget.mobile}');
                          final auth = Get.find<AuthController>();

                          if (widget.userData != null) {
                            // ✅ الأفضل: نخزّن من بيانات الـ API
                            await auth.saveUserFromApiData(widget.userData!);
                          } else {
                            // 🔁 fallback: نفس السلوك القديم (من قيم الـ UI)
                            final prefs =
                            await SharedPreferences.getInstance();
                            await prefs.setString('username', widget.mobile);
                            await prefs.setString('fullName', widget.name);
                            await prefs.setString('Mobile', widget.mobile);
                            await prefs.setString('Email', widget.email);
                            auth.updateRegisteredStatus(
                              true,
                              widget.mobile,
                              widget.name,
                              widget.mobile,
                              widget.email,
                            );
                          }

                          widget.onValidOTP(); // Navigate to home
                        } else if (widget.otpCount == 0) {
                          // New registration → نفذ onRegister
                          widget.onRegister();
                        } else {
                          // أي حالة تانية → اعتبره valid وكمّل
                          widget.onValidOTP();
                        }
                      } else {
                        showErrorAlert(
                            'Invalid OTP. Please try again.', context);
                        widget.onInvalidOTP();
                      }
                    } catch (e) {
                      showErrorAlert(
                          'An error occurred. Please try again.', context);
                      l.log('OTP Verification Error: $e');
                    } finally {
                      widget.onLoadingChange(false);
                    }
                  },
                  context: context,
                  w: 95.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ⬇️ نفس دوال الأزرار المستخدمة في الكود الأصلي
Widget cancelButton(VoidCallback onTap, String title, bool request) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 95.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
    ),
  );
}

Widget yellowButtons({
  required String title,
  required VoidCallback onTap,
  required BuildContext context,
  required double w,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    ),
  );
}

void showErrorAlert(String message, BuildContext context) {
  ErrorDialog.show(
    context,
    message,
        () {},
    isModifyMode: false,
    fromOtp: true,
  );
}
