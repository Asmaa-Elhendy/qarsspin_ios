import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/specs/specs_controller.dart';
import 'package:qarsspin/controller/specs/specs_data_layer.dart';
import 'package:qarsspin/view/widgets/ads/dialogs/loading_dialog.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/specs.dart';
import '../../widgets/my_ads/edit_name.dart';

class SpecsManagemnt extends StatefulWidget {
  final String postId;
  const SpecsManagemnt({required this.postId});

  @override
  State<SpecsManagemnt> createState() => _SpecsManagemntState();
}

class _SpecsManagemntState extends State<SpecsManagemnt> {
  late SpecsController specsController;

  bool _isGlobalLoading = false;

  void _showGlobalLoader() {
    if (mounted) {
      setState(() => _isGlobalLoading = true);
    }
  }

  void _hideGlobalLoader() {
    if (mounted) {
      setState(() => _isGlobalLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    specsController = Get.put(
      SpecsController(SpecsDataLayer()),
      tag: 'specs_${widget.postId}',
    );

    // اربط حالة التحميل باللودر
    ever(specsController.isLoadingSpecs, (isLoading) {
      if (isLoading == true) {
        _showGlobalLoader();
      } else {
        _hideGlobalLoader();
      }
    });

    // check أول مرة
    if (specsController.isLoadingSpecs.value == true) {
      _showGlobalLoader();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      specsController.fetchSpecsForPost(postId: widget.postId);
    });
  }

  @override
  void dispose() {
    Get.delete<SpecsController>(tag: 'specs_${widget.postId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Scaffold(
      /// 🔹 AppBar نفس ستايل MyAccount
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.blackColor(context),
            size: 24.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lc.specs_management,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontFamily: 'Gilroy',
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
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
      ),
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Column(
            children: [

              /// AppBar
              // Container(
              //   height: 88.h,
              //   padding: EdgeInsets.only(top: 13.h, left: 14.w),
              //   decoration: BoxDecoration(
              //     color: AppColors.background(context),
              //     boxShadow: [
              //       BoxShadow( //update asmaa
              //         color: AppColors.blackColor(context).withOpacity(0.2),
              //         spreadRadius: 1,
              //         blurRadius: 5.h,
              //         offset: Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         onTap: () => Navigator.pop(context),
              //         child: Icon(
              //           Icons.arrow_back_outlined,
              //           color: AppColors.blackColor(context),
              //           size: 30.w,
              //         ),
              //       ),
              //       105.horizontalSpace,
              //       Center(
              //         child: Text(
              //           lc.specs_management,
              //           style: TextStyle(
              //             color: AppColors.blackColor(context),
              //             fontFamily: 'Gilroy',
              //             fontSize: 16.sp,
              //             fontWeight: FontWeight.w800,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              22.verticalSpace,

              /// Specs list
              Expanded(
                child: Obx(() {
                  if (specsController.specsError.value != null) {
                    return _buildErrorState(specsController);
                  }

                  if (specsController.specs.isEmpty &&
                      !specsController.isLoadingSpecs.value) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: specsController.specs.length,
                    itemBuilder: (context, index) {
                      return specsContainer(lc,specsController.specs[index],context,specsController,_showGlobalLoader,_hideGlobalLoader,false);
                    },
                  );
                }),
              ),
            ],
          ),

          /// Loader يغطي الشاشة بالكامل
          if (_isGlobalLoading)
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: AppLoadingWidget(
                    title: lc.loading,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
Widget _buildErrorState(specsController) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: AppColors.danger, size: 48.w),
        16.verticalSpace,
        Text('Error loading specs',
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600)),
        8.verticalSpace,
        Text(
          specsController.specsError.value!,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Gilroy',
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        16.verticalSpace,
        ElevatedButton(
          onPressed: () => specsController.refreshSpecs(),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, color: Colors.grey, size: 48.w),
        16.verticalSpace,
        Text('No specs found',
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600)),
        8.verticalSpace,
        Text(
          'This post has no specifications',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Gilroy',
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget specsContainer(lc,Specs spec,BuildContext context,specsController,_showGlobalLoader,_hideGlobalLoader,bool fromCreateAd) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    margin: EdgeInsets.only(bottom: 18.h),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(context),
      border: Border.all(color: AppColors.lightGray, width: 2.h),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Get.locale?.languageCode=='ar'?spec.specHeaderSl:spec.specHeaderPl,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontFamily: 'Gilroy',
                fontSize: 14.sp,
                fontWeight: FontWeight.w800)),
        5.verticalSpace,
        Text(
          spec.specValuePl.isEmpty || spec.specValuePl == " "
              ? lc.hidden
              : Get.locale?.languageCode=='ar'?spec.specValueSl:spec.specValuePl,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontFamily: 'Gilroy',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        5.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => EditSpecsName(spec: spec,fromCreateAd:fromCreateAd),
                    );
                  },
                  child: SizedBox(
                    width: 23.w,
                    height: 28.h,
                    child: Image.asset(
                      "assets/images/edit3.png",
                      color: AppColors.blackColor(context),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                8.horizontalSpace,

              ],
            ),
            InkWell(
              onTap: () async {
                _showGlobalLoader();
                if (fromCreateAd) {
                  specsController.clearLocal(
                    specId: spec.specId,
                  );
                } else {
                  // Use API update for specs management flow
                  await specsController.updateSpecValue(
                    postId: spec.postId,
                    specId: spec.specId,
                    specValue: " ",
                  );
                }
                _hideGlobalLoader();
              },
              child: Icon(Icons.delete_outlined,
                  color: Color(0xffEC6D64), size: 24.w),
            ),
          ],
        )
      ],
    ),
  );
}