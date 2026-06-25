import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/auth/auth_controller.dart';
import 'package:qarsspin/view/widgets/auth_widgets/register_dialog.dart';
import 'package:qarsspin/view/widgets/car_details/qars_apin_bottom_navigation_bar.dart';
import 'package:qarsspin/controller/communications.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/l10n/app_localizations.dart';
import 'package:qarsspin/model/car_model.dart';
import 'package:qarsspin/model/specification.dart';
import 'package:qarsspin/view/screens/get_loan.dart';
import 'package:qarsspin/view/widgets/ads/dialogs/loading_dialog.dart';
import 'package:qarsspin/view/widgets/bottom_offer_bar.dart';
import 'package:qarsspin/view/widgets/buttons/requesr_report_button.dart';
import 'package:qarsspin/view/widgets/car_card.dart';
import 'package:qarsspin/view/widgets/car_details/tab_bar.dart';
import 'package:qarsspin/view/widgets/car_image.dart';
import 'package:qarsspin/view/widgets/offer_dialog.dart';
import 'package:qarsspin/view/widgets/texts/texts.dart';

import '../../../controller/auth/unregister_func.dart';
import '../../../controller/const/base_url.dart';

class CarDetails extends StatefulWidget {
  final String postKind;
  final int id;
  final String sourcekind;
  final String mobile;

  const CarDetails({
    required this.mobile,
    required this.sourcekind,
    required this.id,
    required this.postKind,
    super.key,
  });

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  final authController = Get.find<AuthController>();

  bool is360FullScreen = false;
  bool _isShareLoading = false;

  String? _lastCachedShareImageUrl;

  void _cacheShareImageIfNeeded(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) return;

    final String url = imageUrl.trim();

    if (_lastCachedShareImageUrl == url) return;

    _lastCachedShareImageUrl = url;

    () async {
      try {
        await DefaultCacheManager().downloadFile(url);
      } catch (_) {
        // Ignore cache errors. Share will fallback normally.
      }
    }();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lc = AppLocalizations.of(context)!;

    return GetBuilder<BrandController>(
      builder: (controller) {
        if (!controller.oldData) {
          _cacheShareImageIfNeeded(controller.carDetails.rectangleImageUrl);
        }

        return OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            return Scaffold(
              backgroundColor: AppColors.background(context),
              appBar: isLandscape
                  ? null
                  : PreferredSize(
                preferredSize: Size.fromHeight(100.h),
                child: Container(
                  height: 100.h,
                  padding: EdgeInsets.only(
                    top: 25.h,
                    left: 14.w,
                    right: 14.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor(context)
                            .withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5.h,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);

                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: 48.w,
                          height: 48.h,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_outlined,
                              color: AppColors.blackColor(context),
                              size: 30.w,
                            ),
                          ),
                        ),
                      ),

                      .5.horizontalSpace,

                      Center(
                        child: SizedBox(
                          width: 147.w,
                          child: Image.asset(
                            Theme.of(context).brightness ==
                                Brightness.dark
                                ? 'assets/images/balckIconDarkMode.png'
                                : 'assets/images/black_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildShareButton(
                            context: context,
                            controller: controller,
                            lc: lc,
                          ),

                          8.horizontalSpace,

                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              authController.registered
                                  ? controller.alterPostFavorite(
                                add: controller
                                    .carDetails.isFavorite!
                                    ? false
                                    : true,
                                postId: widget.id,
                              )
                                  : showDialog(
                                context: context,
                                builder: (_) => RegisterDialog(),
                              );
                            },
                            child: SizedBox(
                              width: 48.w,
                              height: 48.h,
                              child: Center(
                                child: Theme.of(context).brightness ==
                                    Brightness.dark
                                    ? Icon(
                                  Icons.favorite,
                                  color: controller.carDetails
                                      .isFavorite!
                                      ? AppColors.primary
                                      : AppColors.notFavorite(
                                    context,
                                  ),
                                )
                                    : controller.carDetails.isFavorite!
                                    ? Icon(
                                  Icons.favorite,
                                  color: AppColors.primary,
                                )
                                    : const Icon(
                                  Icons.favorite_border,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: isLandscape
                  ? null
                  : widget.sourcekind == "Qars Spin"
                  ? QarsApinBottomNavigationBar(
                onLoan: () async {
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);

                  authController.registered
                      ? Get.to(
                    GetLoan(
                      car: controller.carDetails,
                    ),
                  )
                      : showDialog(
                    context: context,
                    builder: (_) => RegisterDialog(),
                  );
                },
                onMakeOffer: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => authController.registered
                        ? MakeOfferDialog()
                        : RegisterDialog(),
                  );
                },
                onRequestToBuy: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => authController.registered
                        ? MakeOfferDialog(
                      offer: false,
                      requestToBuy: true,
                      price:
                      controller.carDetails.askingPrice,
                    )
                        : RegisterDialog(),
                  );
                },
              )
                  : BottomActionBar(
                onMakeOffer: () async {
                  await authController.registered
                      ? showDialog(
                    context: context,
                    builder: (_) => MakeOfferDialog(),
                  )
                      : unRegisterFunction(context);
                },
                onWhatsApp: () {
                  openWhatsApp(
                    controller.carDetails.ownerMobile.trim(),
                    message:
                    "Hello 👋 I’m interested in your ${Get.locale?.languageCode == 'ar' ? controller.carDetails.carNameSl.trim() : controller.carDetails.carNamePl.trim()} ${controller.carDetails.manufactureYear}.The AD Code is: ${controller.carDetails.postCode}",
                  );
                },
                onCall: () {
                  makePhoneCall(
                    controller.carDetails.ownerMobile.trim(),
                  );
                },
              ),
              body: controller.oldData
                  ? Center(
                child: Container(
                  color: AppColors.black.withOpacity(0.5),
                  child: Center(
                    child: AppLoadingWidget(
                      title: lc.loading,
                    ),
                  ),
                ),
              )
                  : Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        is360FullScreen = !is360FullScreen;
                      });
                    },
                    child: SizedBox(
                      height: isLandscape || is360FullScreen
                          ? MediaQuery.of(context).size.height
                          : 250.h,
                      width: double.infinity,
                      child: CarImage(
                        allImages: controller.postMedia,
                      ),
                    ),
                  ),

                  if (!(isLandscape || is360FullScreen))
                    Expanded(
                      child: SingleChildScrollView(
                        child: mainContent(controller, lc),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShareButton({
    required BuildContext context,
    required BrandController controller,
    required AppLocalizations lc,
  }) {
    return Builder(
      builder: (shareButtonContext) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 48.w,
            minHeight: 48.h,
          ),
          onPressed: _isShareLoading
              ? null
              : () async {
            setState(() {
              _isShareLoading = true;
            });

            try {
              final bool isArabic = Get.locale?.languageCode == 'ar';
              final carDetails = controller.carDetails;

              final String carName = isArabic
                  ? carDetails.carNameSl.trim()
                  : carDetails.carNamePl.trim();

              final String? description = isArabic
                  ? carDetails.technical_Description_SL
                  : carDetails.description;

              final String? exteriorColor = isArabic
                  ? carDetails.exteriorColorNameSl
                  : carDetails.exteriorColorNamePl;

              final String? interiorColor = isArabic
                  ? carDetails.interiorColorNameSl
                  : carDetails.interiorColorNamePl;

              final Map<String, String> extraInfo = <String, String>{};

              final String? warranty = carDetails.warrantyAvailable;
              if (warranty != null && warranty.trim().isNotEmpty) {
                extraInfo['Warranty'] = warranty.trim();
              }

              final List<MapEntry<String, String>> specs =
              controller.spec
                  .map(
                    (s) => MapEntry<String, String>(
                  s.key,
                  s.value,
                ),
              )
                  .toList();

              await shareCarFromQarsSpin(
                context: shareButtonContext,
                carName: carName,
                year: carDetails.manufactureYear.toString(),
                price: "${carDetails.askingPrice} ${lc.currency_Symbol}",
                adCode: carDetails.postCode,
                mileage: '${carDetails.mileage} km',
                exteriorColor: exteriorColor,
                interiorColor: interiorColor,
                description: description,
                sourceKind: carDetails.sourceKind,
                imageUrl: carDetails.rectangleImageUrl,
                extraInfo: extraInfo,
                specifications: specs,
                onShareSheetWillOpen: () {
                  if (mounted) {
                    setState(() {
                      _isShareLoading = false;
                    });
                  }
                },
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isShareLoading = false;
                });
              }
            }
          },
          icon: _isShareLoading
              ? SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.blackColor(context),
            ),
          )
              : Image.asset(
            "assets/images/share.png",
            width: 25.w,
            height: 25.w,
            fit: BoxFit.contain,
            color: AppColors.blackColor(context),
          ),
        );
      },
    );
  }

  Widget mainContent(BrandController controller, AppLocalizations lc) {
    return Column(
      children: [
        16.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              blueText(
                "${controller.carDetails.visitsCount} ${lc.people_view}",
              ),

              4.verticalSpace,

              headerText(
                Get.locale?.languageCode == 'ar'
                    ? controller.carDetails.carNameSl.trim()
                    : controller.carDetails.carNamePl.trim(),
                context,
              ),

              4.verticalSpace,

              description(
                Get.locale?.languageCode == 'ar'
                    ? controller.carDetails.technical_Description_SL
                    : controller.carDetails.description,
                context: context,
              ),

              12.verticalSpace,

              Divider(
                thickness: .5,
                color: AppColors.divider(context),
              ),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    greyText(lc.price),

                    2.verticalSpace,

                    price(
                      "${controller.carDetails.askingPrice} ${lc.currency_Symbol}",
                    ),

                    2.verticalSpace,

                    boldGrey(
                      "${controller.carDetails.offersCount} ${lc.people_made_offer}",
                    ),
                  ],
                ),
              ),

              Divider(
                thickness: .5,
                color: AppColors.divider(context),
              ),

              carDetailsRow(controller, lc),

              16.verticalSpace,

              if (controller.carDetails.sourceKind == 'Qars Spin')
                Center(
                  child: requestReportButton(context, widget.id),
                ),

              if (controller.carDetails.sourceKind == 'Qars Spin')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.verticalSpace,
                    Text(
                      lc.specifications,
                      style: TextStyle(
                        color: AppColors.blackColor(context),
                        fontFamily: fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    10.verticalSpace,
                    specifications(controller.spec),
                  ],
                ),

              16.verticalSpace,

              if (controller.carDetails.sourceKind == 'Individual' ||
                  controller.carDetails.sourceKind == 'Partner')
                SizedBox(
                  height: 300.h,
                  child: CustomTabExample(
                    postId: widget.id.toString(),
                    spec: controller.spec,
                    offers: controller.offers,
                  ),
                ),

              16.verticalSpace,

              if (controller.carDetails.sourceKind == 'Qars Spin' ||
                  controller.carDetails.sourceKind == 'Partner')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionWithCars(
                      "Similar Cars",
                      controller.similarCars,
                    ),
                    20.verticalSpace,
                    sectionWithCars(
                      "Owner's Ads",
                      controller.ownersAds,
                    ),
                  ],
                ),

              16.verticalSpace,
            ],
          ),
        ),
      ],
    );
  }

  Widget carDetailsRow(BrandController controller, AppLocalizations lc) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  boldGrey(lc.ad_code),
                  4.verticalSpace,
                  headerText(
                    controller.carDetails.postCode,
                    context,
                  ),
                ],
              ),
              Column(
                children: [
                  boldGrey(lc.year),
                  4.verticalSpace,
                  headerText(
                    "${controller.carDetails.manufactureYear}",
                    context,
                  ),
                ],
              ),
            ],
          ),
        ),

        30.verticalSpace,

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  boldGrey(lc.mileage),
                  4.verticalSpace,
                  headerText(
                    controller.carDetails.mileage.toString(),
                    context,
                  ),
                ],
              ),
              Column(
                children: [
                  boldGrey(lc.warranty),
                  4.verticalSpace,
                  headerText(
                    controller.carDetails.warrantyAvailable,
                    context,
                  ),
                ],
              ),
            ],
          ),
        ),

        30.verticalSpace,

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  boldGrey(lc.exterior),
                  4.verticalSpace,
                  Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkGray,
                      ),
                      color: controller.carDetails.exteriorColor,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  boldGrey(lc.interior),
                  4.verticalSpace,
                  Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.carDetails.interiorColor,
                      border: Border.all(
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sectionWithCars(String title, List<CarModel> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: fontFamily,
              color: AppColors.blackColor(context),
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 275.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 3.h),
            itemCount: cars.length,
            shrinkWrap: true,
            separatorBuilder: (_, __) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              return carCard(
                context: context,
                w: 150.w,
                h: 50,
                postKind: widget.postKind,
                car: cars[index],
                large: false,
                tooSmall: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget specifications(List<Specifications> spec) {
    return Column(
      children: [
        for (final s in spec) specificationsRow(s.key, s.value),
      ],
    );
  }

  Widget specificationsRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: .8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 55.h,
            width: 175.w,
            decoration: BoxDecoration(
              color: AppColors.background(context),
              border: Border.all(
                color: AppColors.extraLightGray,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp,
                  color: AppColors.blackColor(context),
                ),
              ),
            ),
          ),

          2.5.horizontalSpace,

          Container(
            height: 55.h,
            width: 175.w,
            decoration: BoxDecoration(
              color: AppColors.background(context),
              border: Border.all(
                color: AppColors.extraLightGray,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp,
                  color: AppColors.blackColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}