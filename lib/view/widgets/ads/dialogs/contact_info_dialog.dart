import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../../l10n/app_localization.dart';


class ContactInfoDialog {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    String? initialFirstName,
    String? initialLastName,
    String? initialMobile,
    String? initialEmail,
    String initialCountry = 'Qatar',
    required bool isRequest360,
    required bool isFeauredPost,
    required double req360Amount,
    required double featuredAmount,
    required double totalAmount,

  }) async {
    var lc = AppLocalizations.of(context)!;

    final firstNameController =
    TextEditingController(text: initialFirstName ?? '');
    final lastNameController =
    TextEditingController(text: initialLastName ?? '');
    final mobileController =
    TextEditingController(text: initialMobile ?? '');
    final emailController =
    TextEditingController(text: initialEmail ?? '');
    final stateController = TextEditingController();
    final cityController = TextEditingController();
    final zipController = TextEditingController();
    final addressController = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String selectedCountry = initialCountry;
    bool saveForFuture = true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor: AppColors.background(context),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            isRequest360?    Text(
                              lc.serviceFee+ ' $req360Amount ' +lc.qarOnlyForRequest360Session,//k
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.black,
                              ),
                            ):SizedBox(),
                            isFeauredPost?     Text(
                              lc.serviceFee+ ' $featuredAmount ' +lc.qarOnlyForFeaturePost,//k
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.black,
                              ),
                            ):SizedBox(),
                          ],
                        ),
                      ),
                      InkWell(
                          onTap: (){Navigator.pop(context);},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.close,color: AppColors.blackColor(context),size: 24.sp,),
                          ))
                    ],),

                  SizedBox(height: 12.h),
                  Text(
                    lc.contactInformation,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lc.pleaseFillAllInformationBelow,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First / Last Name
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(context: context,
                              controller: firstNameController,
                              label: lc.firstName,
                              hint: lc.enterFirstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lc.requiredField;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(context: context,
                              controller: lastNameController,
                              label: lc.lastName,
                              hint:lc.enterLastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lc.requiredField;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mobile / Email
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(context: context,
                              controller: mobileController,
                              label: lc.mobile,
                              hint: lc.enterPhoneNumber,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lc.requiredField;
                                }
                                if (value.length < 7) {
                                  return lc.invalidPhoneNumber;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(context: context,
                              controller: emailController,
                              label: lc.cemail,
                              hint: lc.enterEmailAddress,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lc.requiredField;
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return lc.invalidEmailAddress;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 16),
                      //
                      // // Country / State
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: DropdownButtonFormField<String>(
                      //         isExpanded: true, // مهم عشان يمنع الـ overflow
                      //         value: selectedCountry,
                      //         decoration: _inputDecoration(
                      //           context: context,
                      //           label: 'Country',
                      //           hint: 'Select country',
                      //         ),
                      //         items: const [
                      //           DropdownMenuItem(
                      //             value: 'Qatar',
                      //             child: Text('Qatar'),
                      //           ),
                      //           DropdownMenuItem(
                      //             value: 'Saudi Arabia',
                      //             child: Text('Saudi Arabia'),
                      //           ),
                      //           DropdownMenuItem(
                      //             value: 'UAE',
                      //             child: Text('UAE'),
                      //           ),
                      //         ],
                      //         onChanged: (value) {
                      //           if (value != null) {
                      //             setState(() => selectedCountry = value);
                      //           }
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: _buildTextField(context: context,
                      //         controller: stateController,
                      //         label: 'State',
                      //         hint: 'Enter state',
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),

                      // City / Zip
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _buildTextField(context: context,
                      //         controller: cityController,
                      //         label: 'City',
                      //         hint: 'Enter city',
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: _buildTextField(context: context,
                      //         controller: zipController,
                      //         label: 'ZIP Code',
                      //         hint: 'Enter ZIP code',
                      //         keyboardType: TextInputType.number,
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      //
                      // // Address
                      // _buildTextField(context: context,
                      //   controller: addressController,
                      //   label: 'Address',
                      //   hint: 'Enter your address',
                      //   maxLines: 2,
                      // ),
                      // const SizedBox(height: 8),

                      // Save contact info
                      // Row(
                      //   children: [
                      //     Checkbox(
                      //       value: saveForFuture,
                      //       onChanged: (value) {
                      //         setState(() {
                      //           saveForFuture = value ?? false;
                      //         });
                      //       },
                      //     ),
                      //      Expanded(
                      //       child: Text(
                      //         'Save contact information for future use',
                      //         style: TextStyle(
                      //           fontSize: 13.sp,
                      //           color: Theme.of(context).brightness == Brightness.dark
                      //               ? const Color(0xFF2A2A2A)
                      //               : Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Update the onPressed handler in the ElevatedButton
                    // Update the onPressed handler in the ElevatedButton:
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        // Return only contact info; payment flow will be handled by the caller
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop({
                            'firstName': firstNameController.text.trim(),
                            'lastName': lastNameController.text.trim(),
                            'email': emailController.text.trim(),
                            'mobile': mobileController.text.trim(),
                          });
                        }
                        return;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      lc.proceedToPayment,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // TextField helper
  static Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(
        context: context,
        label: label,
        hint: hint,
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.inputBorder,
        fontSize: 14.sp,
      ),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.inputBorder,
        fontSize: 14.sp,
      ),
      enabled: enabled,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.danger),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.white,
      errorStyle: TextStyle(
        color: AppColors.danger,
        fontSize: 12.sp,
      ),
    );
  }
}
