import 'dart:developer' as l;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../controller/auth/auth_controller.dart';
import '../../../../controller/const/colors.dart';
import '../../../../l10n/app_localization.dart';
import 'error_dialog.dart';

/// ===============================
/// OTP BYPASS CONFIG
/// ===============================
/// IMPORTANT:
/// Your backend returns username like: QA97455170079
/// So we compare using DIGITS only.
const String kBypassMobileDigits = '97455170079';
const String kBypassOtp = '4444';

class OTPDialog extends StatefulWidget {
  final TextEditingController otpController;
  final String otpSecret;
  final int otpCount;
  final bool isLoading;
  final Function(bool) onLoadingChange;
  final VoidCallback onValidOTP;
  final VoidCallback onInvalidOTP;
  final VoidCallback onRegister;
  final bool request;
  final String mobile; // can be: QA974..., +974..., 974...
  final String name;
  final String email;

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
    Map<String, dynamic>? userData,
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
  /// Extract digits only from any phone format:
  /// "+97455170079" -> "97455170079"
  /// "QA97455170079" -> "97455170079"
  /// "974 5517 0079" -> "97455170079"
  String _digitsOnly(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.trim();
  }

  bool _isBypassUser(String mobileRaw) {
    final digits = _digitsOnly(mobileRaw);
    return digits == kBypassMobileDigits;
  }

  @override
  Widget build(BuildContext context) {
    final lc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.toastBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 16.h),
        height: widget.request ? 270.h : 330.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lc.verify_msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
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
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            18.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _cancelButton(() => Navigator.pop(context), lc.btn_Cancel),
                10.horizontalSpace,
                _verifyButton(context, lc),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyButton(BuildContext context, AppLocalizations lc) {
    return InkWell(
      onTap: () async {
        final enteredOtp = widget.otpController.text.trim();
        if (enteredOtp.isEmpty) {
          showErrorAlert('Please enter the OTP', context);
          return;
        }

        final generatedOtp = widget.otpSecret.trim();

        final bypassUser = _isBypassUser(widget.mobile);

        // ✅ Accept if:
        // 1) normal OTP matches
        // 2) bypass user and entered "4444"
        final isValidOtp = (enteredOtp == generatedOtp) || (bypassUser && enteredOtp == kBypassOtp);

        l.log('🔎 OTP check: mobile=${widget.mobile}, digits=${_digitsOnly(widget.mobile)}, bypass=$bypassUser, entered=$enteredOtp, generated=$generatedOtp');

        if (!isValidOtp) {
          showErrorAlert('Invalid OTP. Please try again.', context);
          widget.onInvalidOTP();
          return;
        }

        // ✅ Success -> close dialog + continue flow
        Navigator.pop(context);
        widget.onLoadingChange(true);

        try {
          l.log('✅ OTP accepted. bypass=$bypassUser');

          if (widget.otpCount == 1) {
            // Login
            final auth = Get.find<AuthController>();

            if (widget.userData != null) {
              await auth.saveUserFromApiData(widget.userData!);
            } else {
              final prefs = await SharedPreferences.getInstance();
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

            widget.onValidOTP();
          } else if (widget.otpCount == 0) {
            widget.onRegister();
          } else {
            widget.onValidOTP();
          }
        } catch (e) {
          l.log('OTP Verification Error: $e');
          showErrorAlert('An error occurred. Please try again.', context);
        } finally {
          widget.onLoadingChange(false);
        }
      },
      child: Container(
        width: 95.w,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          lc.btn_Verify,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _cancelButton(VoidCallback onTap, String title) {
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
        ),//j
      ),
    );
  }
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
