import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/specs/specs_controller.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';
import 'package:qarsspin/view/widgets/ads/dialogs/loading_dialog.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/specs.dart';

class EditSpecsName extends StatefulWidget {
  final Specs spec;
  final bool fromCreateAd;
  const EditSpecsName({required this.spec,required this.fromCreateAd, super.key});

  @override
  State<EditSpecsName> createState() => _EditSpecsNameState();
}

class _EditSpecsNameState extends State<EditSpecsName> {
  final TextEditingController _newNameController = TextEditingController();

  // Loading state for update operation
  bool _isLoadingUpdate = false;

  /// Show loading dialog
  void _showLoadingDialog() {
    setState(() {
      _isLoadingUpdate = true;
    });
  }

  /// Hide loading dialog
  void _hideLoadingDialog() {
    if (mounted) {
      setState(() {
        _isLoadingUpdate = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _newNameController.text=widget.spec.specValuePl.isEmpty?'':widget.spec.specValuePl;
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Dialog(
            backgroundColor: Colors.grey.shade200, // grey background
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

            child: Container(
              // width: 800.w,
              height: 160.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.black, width: 2.3.h),
                borderRadius: BorderRadius.circular(8),

              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 6.h,horizontal: 16.w),
                child: Column(
//l
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Title
                    Center(
                      child: Text(
                        Get.locale?.languageCode=='ar'?widget.spec.specHeaderSl:widget.spec.specHeaderPl,
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14.sp, fontFamily:fontFamily,fontWeight: FontWeight.w800),
                      ),
                    ),
                    10.verticalSpace,

                    Container(
                      height: 40.h,
                      decoration: BoxDecoration(

                        border: Border.all(color: AppColors.lightGray),
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _newNameController,

                        style: TextStyle(fontSize: 15.w,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,  // ← Added this line
                        decoration: InputDecoration(
                          hintText: "",contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none
                          ),
                        ),
                      ),
                    ),
                    12.verticalSpace,/// Buttons Row
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: yellowButtons(context:context,title: lc.btn_Cancel, onTap: (){
                            FocusManager.instance.primaryFocus?.unfocus();

                            Navigator.pop(context);
                          }, w: double.infinity, grey: true),
                        ),
                        SizedBox(width: 7.w),
                        Flexible(
                          child: yellowButtons(context:context,title:lc.btn_Confirm, onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            Navigator.pop(context);
                            _showLoadingDialog();
                            final controller = Get.find<SpecsController>(tag: 'specs_${widget.spec.postId}');
                            final success =widget.fromCreateAd?
                            controller.updateLocal(specId: widget.spec.specId, specValuePl: _newNameController.text)
                                :
                            await controller.updateSpecValue(
                              postId: widget.spec.postId,
                              specId: widget.spec.specId,
                              specValue: _newNameController.text,
                            );
                            _hideLoadingDialog();

                            // if (success) {
                            //   Navigator.pop(context);
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text('Failed to update spec value'),
                            //       backgroundColor: Colors.red,
                            //     ),
                            //   );
                            // }
                          }, w: double.infinity),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
          if (_isLoadingUpdate)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: AppLoadingWidget(
                    title: 'Loading...\n Please Wait...'
                ),
              ),
            ),
        ],
      ),
    );
  }
}