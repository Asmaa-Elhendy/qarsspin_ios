import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/view/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../controller/auth/auth_controller.dart';
import '../../../controller/const/app_strings.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localization.dart';
import '../../widgets/ads/dialogs/otp_dialog.dart';
import '../../widgets/auth_widgets/country_dropdown.dart';
import '../../widgets/auth_widgets/custom_text_field.dart' as e;

class RegisterPage extends StatefulWidget {
  String code;
  String country;
  String mobile;
  RegisterPage({required this.code,required this.country,required this.mobile});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  // Country code and phone number state
  String _selectedCountry = 'QA';
  String _selectedCountryPrefix = '974';

  final List<Map<String, String>> _countries = [
    {'name': AppStrings.countryQatar, 'code': 'QA', 'prefix': '974'},
    {'name': AppStrings.countrySaudiArabia, 'code': 'SA', 'prefix': '966'},
    {'name': AppStrings.countryBahrain, 'code': 'BH', 'prefix': '973'},
    {'name': AppStrings.countryUAE, 'code': 'AE', 'prefix': '971'},
    {'name': AppStrings.countryOman, 'code': 'OM', 'prefix': '968'},
    {'name': AppStrings.countryKuwait, 'code': 'KW', 'prefix': '965'},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
  String? _firebaseToken;
  bool _isLoadingToken = true;
  bool _isLoadingToken2 = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mobileController.text = widget.mobile;
    _selectedCountry = widget.code;
    _selectedCountryPrefix = widget.country;
    _initializeFirebaseAndGetToken();

  }
  Future<void> _initializeFirebaseAndGetToken() async {
    try {
      // No need to show loading, just try to get the token in the background
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get the token in the background
      FirebaseMessaging.instance.getToken().then((token) {
        if (mounted) {
          setState(() {
            _firebaseToken = token;
          });
        }
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      // Don't show any error to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    double height = MediaQuery
        .of(context)
        .size
        .height;

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
          lc.register,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          //key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text(
                  lc.full_name,
                  style: TextStyle(
                    fontSize: 17.w,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                e.CustomTextField(
                  controller: _nameController,
                  hintText: lc.enter_full_name,

                ),
                const SizedBox(height: 8),
                Text(
                  lc.email,
                  style: TextStyle(
                    fontSize: 17.w,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                e.CustomTextField(
                  controller: _emailController,
                  hintText: lc.enter_email,
                  keyboardType: TextInputType.emailAddress,

                ),
                const SizedBox(height: 8),
                Text(
                  lc.country,
                  style: TextStyle(
                    fontSize: 17.w,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Text(
                          _selectedCountry
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+$_selectedCountryPrefix',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lc.mbl_number,
                  style: TextStyle(
                    fontSize: 17.w,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          _mobileController.text,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: height * .05,
                  child: GestureDetector(
                    onTap: () async {
                      final token = _firebaseToken ?? '';

                      if (_nameController.text.isEmpty ||
                          _mobileController.text.isEmpty ||
                          _emailController.text.isEmpty) {
                        showErrorAlert(lc.please_fill_fields, context);
                        return;
                      }

                      if (!mounted) return;

                      setState(() {
                        _isLoading = true;
                      });
                      final authController = Get.find<AuthController>();
                      //                      try {//k
                      //                        final response = await authController.registerUser(
                      //                          userName:_selectedCountryPrefix+_mobileController.text,
                      //                          fullName: _nameController.text,
                      //                          email: _emailController.text,
                      //                          mobileNumber: _mobileController.text,
                      //                          selectedCountry: _selectedCountry,
                      //                          firebaseToken: token,
                      //                          preferredLanguage: 'en',
                      //                          ourSecret: ourSecret,
                      //                        );
                      // log('$response     ${_selectedCountry +_selectedCountryPrefix+_mobileController.text}');
                      //                        if (response['Code'] == 'OK') {
                      //                          if (mounted) {
                      //                            final prefs = await SharedPreferences.getInstance();
                      //                            await prefs.setString('mobileNumber', _mobileController.text);
                      //
                      //                            // Save full name from the response if available
                      //                            if (response['Code'] == 'OK' && response['Data'] != null && response['Data'].isNotEmpty) {
                      //                              final userData = response['Data'][0];
                      //                              if (userData['Full_Name'] != null) {
                      //                                await prefs.setString('fullName', userData['Full_Name']);
                      //                              }
                      //                            }
                      //
                      //                            // Show success and navigate
                      //                            if (mounted) {
                      //                              showSuccessDialog(
                      //                                title: 'Success',
                      //                                message: 'Registration successful!',
                      //                                context: context,
                      //                                onConfirm: () {
                      //                                  Navigator.pushReplacement(
                      //                                    context,
                      //                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                      //
                      //                                  );
                      //                                },
                      //                              );
                      //                            }
                      //                          }
                      //                        } else {
                      //                          // Handle error response
                      //                          final errorMessage = response['Desc'] ?? 'Registration failed';
                      //                          if (mounted) {
                      //                            showErrorAlert(errorMessage, context);
                      //                          }
                      //                        }
                      //                      } catch (e) {
                      //                        if (mounted) {
                      //                          showErrorAlert('An error occurred during registration: $e', context);
                      //                        }
                      //                      } finally {
                      //                        setState(() {
                      //                          _isLoading = false;
                      //                        });
                      //                      }
                      try {
                        final response = await authController.registerUser(
                          userName: _selectedCountryPrefix + _mobileController.text,
                          fullName: _nameController.text,
                          email: _emailController.text,
                          mobileNumber: _mobileController.text,
                          selectedCountry: _selectedCountry,
                          firebaseToken: token,
                          preferredLanguage: 'en',
                          ourSecret: ourSecret,
                        );

                        log('Registration response: $response');

                        if (response['success'] == true) {
                          // Save user data
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('username', _mobileController.text);
                          String fullName='';
                          if (response['Data'] != null && response['Data'] is List && response['Data'].isNotEmpty) {
                            final userData = response['Data'][0];
                            if (userData['Full_Name'] != null) {
                              fullName=userData['Full_Name'];
                              await prefs.setString('fullName', userData['Full_Name']);
                              await prefs.setString('Mobile', userData['Mobile']);
                              await prefs.setString('Email', userData['Email']);
                            }
                          }
                          // To get the current value
// To update the value
                          Get.find<AuthController>().updateRegisteredStatus(true,_mobileController.text,fullName,_mobileController.text,_emailController.text);  // or false

                          // Navigate to home and remove all previous routes
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                                  (route) => false,
                            );
                          }
                        } else {
                          // Show error message
                          final errorMessage = response['message'] ?? 'Registration failed';
                          log('Registration error: $errorMessage');
                          if (mounted) {
                            showErrorAlert(errorMessage, context);
                          }
                        }
                      } catch (e) {
                        log('Unexpected error: $e');
                        if (mounted) {
                          showErrorAlert('An unexpected error occurred: $e', context);
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lc.register,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
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


  void showSuccessDialog({
    required String title,
    required String message,
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    var lc = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(//h
            title:  Text(lc.confirmation),
            content: Text(lc.register_success),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child:  Text(
                  lc.ok_lbl,
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
            ],
          ),
    );
  }
}