
import 'dart:developer' as l;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/auth/secret.dart';
import 'package:qarsspin/view/screens/auth/register_detail.dart';
import 'package:qarsspin/view/screens/home_screen.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../controller/const/app_strings.dart';
import '../../../controller/const/colors.dart';
import '../../../controller/otp_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ads/dialogs/error_dialog.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/ads/dialogs/otp_dialog.dart';
import '../../widgets/auth_widgets/country_dropdown.dart';
import '../../widgets/auth_widgets/custom_text_field.dart';
import '../../widgets/auth_widgets/primary_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _otpSecret;
  int? _otpCount;
  String? _phoneNumber;

  // Country data matching the Android app
  final List<Map<String, String>> _countries = [
    {'name': AppStrings.countryQatar, 'code': 'QA', 'prefix': '974'},
    {'name': AppStrings.countrySaudiArabia, 'code': 'SA', 'prefix': '966'},
    {'name': AppStrings.countryBahrain, 'code': 'BH', 'prefix': '973'},
    {'name': AppStrings.countryUAE, 'code': 'AE', 'prefix': '971'},
    {'name': AppStrings.countryOman, 'code': 'OM', 'prefix': '968'},
    {'name': AppStrings.countryKuwait, 'code': 'KW', 'prefix': '965'},
  ];

  String _selectedCountry = 'QA';
  String _selectedCountryPrefix = '974';
  final _authController = Get.find<AuthController>();

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      _phoneNumber =
      '${_selectedCountry}${_selectedCountryPrefix}${_mobileController.text}';
      _otpSecret =
          (Random().nextInt((9989 - 1001) + 1) + 1001).toString(); // 1001–9989

      // Show OTP in console for testing
      l.log('Phone: $_phoneNumber');
      l.log('OTP for testing: $_otpSecret');

      final response = await _authController.requestOtp(
        userName: _phoneNumber!,
        otpSecret: _otpSecret!,
        ourSecret: ourSecret,
      );

      if (response['success'] == true) {
        l.log('rs************** $response');
        _otpCount = response['Count'] ?? 0;
        l.log('Setting OTP count to: $_otpCount');

        // نحاول نطلع الـ userData من رد الـ API
        Map<String, dynamic>? userData;
        try {
          final data = response['data'];
          if (data != null &&
              data['Data'] != null &&
              (data['Data'] as List).isNotEmpty) {
            userData = (data['Data'][0] as Map).cast<String, dynamic>();
            l.log("res UserName from API: ${userData['UserName']}");
          }
        } catch (e) {
          l.log('Error parsing userData from OTP response: $e');
        }

        // نحدد اللي هنبعته للـ Dialog (من الـ API أو من الفورم كـ fallback)
        final mobileForDialog =
            userData?['UserName']?.toString() ?? _phoneNumber ?? '';
        final nameForDialog = userData?['Full_Name']?.toString() ?? '';
        final emailForDialog = userData?['Email']?.toString() ?? '';

        _showOtpDialog(
          mobileForDialog,
          nameForDialog,
          emailForDialog,
          userData,
        );
      } else {
        _showErrorAlert(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showErrorAlert('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ عدّلنا الدالة دي علشان تستقبل userData من الـ API وتبعتها للـ OTPDialog
  // في أعلى الملف، عرفي الـ Service
//   final OtpService _otpService = OtpService();
// //firebase  otp with twillio
//   Future<void> _requestOtp() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       _phoneNumber = '+97433666718'; // الرقم اللي بنجرب بيه
//       _otpSecret = "FB_VERIFY";       // حلينا مشكلة الـ Null هنا ✅
//       _otpCount = 0;                 // حلينا مشكلة الـ Null هنا ✅
//
//       final response = await _otpService.sendOtp(_phoneNumber!);
//
//       if (response['success'] == true) {
//         _showOtpDialog(
//           _phoneNumber!,
//           '',
//           '',
//           null,
//         );
//       } else {
//         _showErrorAlert(response['message'] ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       l.log("Catch Error: $e"); // عشان نعرف لو فيه error تاني
//       _showErrorAlert('An error occurred. Please try again.');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
  void _showOtpDialog(
      String mobile,
      String name,
      String email,
      Map<String, dynamic>? userData,
      ) {
    final otpController = TextEditingController();
    OTPDialog.show(
      email: email,
      context: context,
      mobile: mobile,
      name: name,
      otpController: otpController,
      otpSecret: _otpSecret!,
      otpCount: _otpCount!,
      isLoading: _isLoading,
      onLoadingChange: (v) => setState(() => _isLoading = v),
      onValidOTP: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomeScreen()),
        );
      },
      onInvalidOTP: () {},
      onRegister: () async {
        // Close the OTP dialog
        Navigator.pop(context);
        // Navigate to registration page and wait for result
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterPage(
              mobile: _mobileController.text,
              country: _selectedCountryPrefix,
              code: _selectedCountry,
            ),
          ),
        );

        // If registration was successful (result is true), navigate to home
        if (result == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  HomeScreen()),
            );
          }
        }
      },
      request: false,
      userData: userData, // 👈 مهم: نمرّر الـ Data للـ OTPDialog
    );
  }

  void _showErrorAlert(String message) {
    ErrorDialog.show(
      context,
      message,
          () {},
      fromOtp: true,
      isModifyMode: false,
    );
  }

  @override
  void initState() {
    super.initState();
    // Clear any previous messages when screen initializes
    _authController.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
        shadowColor: Colors.grey.shade300,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        elevation: 0,
        title: Text(
          lc.title_create_new_account,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Country Selection
                  Text(
                    lc.lbl_your_country,
                    style: TextStyle(
                      fontSize: 17.w,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Country Dropdown
                  CountryDropdown(
                    countries: _countries,
                    onCountrySelected: (country) {
                      setState(() {
                        _selectedCountry = country['code']!;
                        _selectedCountryPrefix = country['prefix']!;
                      });
                    },
                    selectedCountry: _countries.firstWhere(
                          (c) => c['code'] == _selectedCountry,
                      orElse: () => _countries.first,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mobile Number
                  Text(
                    lc.lbl_your_mobile_number,
                    style: TextStyle(
                      fontSize: 17.w,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    hintText: lc.hint_enter_your_mobile_number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      // Basic validation for phone number (adjust as needed)
                      if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value)) {
                        return AppStrings.invalidPhoneNumber;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * .02),
                  // OTP Field (unused now because we use dialog, but نسيبه لو حابب مستقبلاً)
                  if (_showOtpField) ...[
                    const SizedBox(height: 24),
                    Text(
                      lc.verify_msg,
                      style: TextStyle(
                        fontSize: 17.w,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter OTP',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'OTP is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  PrimaryButton(
                    onPressed: _isLoading ? null : _requestOtp,
                    borderRadius: 4,
                    child: Text(
                      lc.register_account_cap,
                      style: TextStyle(
                        fontSize: 17.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: AppLoadingWidget(
                  title: 'Loading...\nPlease Wait...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
