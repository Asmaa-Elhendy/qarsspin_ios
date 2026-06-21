import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/auth/auth_controller.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/model/rental_car_model.dart';
import 'package:qarsspin/view/widgets/auth_widgets/register_dialog.dart';

import '../../../controller/communications.dart';
import '../../../controller/const/base_url.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/car_image.dart';
import '../../widgets/rental_cars/info.dart';
import '../../widgets/rental_cars/price_table.dart';
import '../../widgets/rental_cars/rental_bottom_bar.dart';
import '../../widgets/texts/texts.dart';

class RentalCarDetails extends StatefulWidget {
  final RentalCar rentalCar;
  const RentalCarDetails({required this.rentalCar, super.key});

  @override
  State<RentalCarDetails> createState() => _RentalCarDetailsState();
}

class _RentalCarDetailsState extends State<RentalCarDetails> {
  final authController = Get.find<AuthController>();

  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // Allow all orientations for this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait-only when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _shareRentalCar(
    AppLocalizations lc,
    RentalCarsController rentalController,
  ) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final RentalCar car = widget.rentalCar;

    final String carName = isArabic
        ? car.carNameSL.trim()
        : car.carNamePL.trim();

    final String category =
        isArabic ? car.categoryNameSL.trim() : car.categoryNamePL.trim();
    final String exteriorColor = isArabic
        ? car.exteriorColorNameSL.trim()
        : car.exteriorColorNamePL.trim();
    final String interiorColor = isArabic
        ? car.interiorColorNameSL.trim()
        : car.interiorColorNamePL.trim();
    final String description = isArabic
        ? car.technicalDescriptionSL.trim()
        : car.technicalDescriptionPL.trim();

    final Map<String, String> extraInfo = <String, String>{};
    if (car.availableForWeeklyRent == 1) {
      extraInfo['Rent per week'] = '${car.rentPerWeek} ${lc.currency_Symbol}';
    }
    if (car.availableForMonthlyRent == 1) {
      extraInfo['Rent per month'] = '${car.rentPerMonth} ${lc.currency_Symbol}';
    }
    if (car.availableForLease == 1) {
      extraInfo['Available for lease'] = 'Yes';
    }

    final List<MapEntry<String, String>> specs = rentalController.spec
        .map((s) => MapEntry<String, String>(s.key, s.value))
        .toList();

    shareCarFromQarsSpin(
      carName: carName,
      year: car.manufactureYear.toString(),
      price: '${car.rentPerDay} ${lc.currency_Symbol}',
      priceLabel: 'Rent per day',
      adCode: car.postCode,
      category: category,
      mileage: '${car.mileage} km',
      exteriorColor: exteriorColor,
      interiorColor: interiorColor,
      description: description,
      sourceKind: car.sourceKind,
      imageUrl: car.rectangleImageUrl,
      extraInfo: extraInfo,
      specifications: specs,
    );
  }

  Future<void> _toggleRentalFavorite(
      RentalCarsController controller,
      ) async {
    if (!authController.registered) {
      showDialog(
        context: context,
        builder: (_) => RegisterDialog(),
      );
      return;
    }

    final bool oldValue = controller.isRentalFavorite(widget.rentalCar.postId);
    final bool newValue = !oldValue;

    await controller.alterRentalFavorite(
      add: newValue,
      postId: widget.rentalCar.postId,
    );
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return GetBuilder<RentalCarsController>(
      builder: (rentalController) {
        return OrientationBuilder(
          builder: (context, orientation) {
            bool isLandscape = orientation == Orientation.landscape;

            final bool isFavorite =
            rentalController.isRentalFavorite(widget.rentalCar.postId);

            return Scaffold(
              backgroundColor: AppColors.background(context),
              appBar: isLandscape
                  ? null
                  : PreferredSize(
                preferredSize: Size.fromHeight(88.h),
                child: Container(
                  height: 88.h,
                  padding: EdgeInsets.only(
                    top: 13.h,
                    left: 14.w,
                    right: 14.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // Lock portrait BEFORE popping to prevent rotation flicker
                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_outlined,
                          color: AppColors.blackColor(context),
                          size: 30.w,
                        ),
                      ),
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
                        children: [
                          InkWell(
                            onTap: () {
                              _shareRentalCar(lc, rentalController);
                            },
                            child: SizedBox(
                              width: 25.w,
                              child: Image.asset(
                                "assets/images/share.png",
                                fit: BoxFit.cover,
                                color: AppColors.blackColor(context),
                              ),
                            ),
                          ),
                          18.horizontalSpace,
                          // InkWell(
                          //   onTap: () {
                          //     _toggleRentalFavorite(rentalController);
                          //   },
                          //   child: Theme.of(context).brightness ==
                          //       Brightness.dark
                          //       ? Icon(
                          //     Icons.favorite,
                          //     color: isFavorite
                          //         ? AppColors.primary
                          //         : AppColors.notFavorite(context),
                          //   )
                          //       : isFavorite
                          //       ? Icon(
                          //     Icons.favorite,
                          //     color: AppColors.primary,
                          //   )
                          //       : Icon(
                          //     Icons.favorite_border,
                          //     color:
                          //     AppColors.blackColor(context),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: isLandscape
                  ? null
                  : RentalBottomNaviagtion(
                phone: widget.rentalCar.ownerMobile,
                rentalCar: widget.rentalCar,
              ),
              body: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFullScreen = !isFullScreen;
                      });
                    },
                    child: SizedBox(
                      height: isLandscape || isFullScreen
                          ? MediaQuery.of(context).size.height
                          : 250.h,
                      width: double.infinity,
                      child: CarImage(
                        allImages: [
                          widget.rentalCar.spin360Url ?? "",
                          widget.rentalCar.rectangleImageUrl ?? "",
                          widget.rentalCar.videoUrl ?? ""
                        ],
                      ),
                    ),
                  ),
                  if (!(isLandscape || isFullScreen))
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RentalCarInfo(car: widget.rentalCar),
                              Divider(
                                thickness: .7.h,
                                color: AppColors.divider(context),
                              ),
                              Text(
                                lc.rental_prices,
                                style: TextStyle(
                                  color: AppColors.blackColor(context),
                                  fontSize: 14.sp,
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Divider(
                                thickness: .7.h,
                                color: AppColors.divider(context),
                              ),
                              SizedBox(height: 16.h),
                              PriceTable(car: widget.rentalCar),
                              Divider(
                                thickness: .7.h,
                                color: AppColors.black,
                              ),
                              4.verticalSpace,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 55.w),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        column(
                                          lc.chassis_number,
                                          widget.rentalCar.chassisNumber,
                                          lc,
                                        ),
                                        Spacer(),
                                        column(
                                          lc.year,
                                          widget.rentalCar.manufactureYear
                                              .toString(),
                                          lc,
                                        )
                                      ],
                                    ),
                                    30.verticalSpace,
                                    Row(
                                      children: [
                                        column(
                                          lc.mileage,
                                          widget.rentalCar.mileage.toString(),
                                          lc,
                                        ),
                                        Spacer(),
                                        column(
                                          lc.for_leasing,
                                          widget.rentalCar.availableForLease == 0
                                              ? lc.value_No
                                              : lc.value_Yes,
                                          lc,
                                        )
                                      ],
                                    ),
                                    30.verticalSpace,
                                    Row(
                                      children: [
                                        column(
                                          lc.exterior,
                                          widget.rentalCar.mileage.toString(),
                                          lc,
                                          color: true,
                                        ),
                                        Spacer(),
                                        column(
                                          lc.interior,
                                          widget.rentalCar.mileage.toString(),
                                          lc,
                                          color: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              16.verticalSpace,
                              headerText(lc.specifications, context),
                              8.verticalSpace,
                              GetBuilder<RentalCarsController>(
                                builder: (controller) {
                                  return specifications(controller.spec);
                                },
                              ),
                            ],
                          ),
                        ),
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

  column(key, value, lc, {bool color = false}) {
    return Column(
      children: [
        SizedBox(width: 140.w, child: Center(child: boldGrey(key))),
        4.verticalSpace,
        SizedBox(
          width: 88.w,
          child: Center(
            child: color
                ? Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: key == lc.exterior
                    ? widget.rentalCar.colorExterior
                    : widget.rentalCar.colorInterior,
                border: Border.all(color: AppColors.darkGray),
              ),
            )
                : headerText(value, context),
          ),
        ),
      ],
    );
  }

  Widget specifications(List spec) {
    return Column(
      children: [
        for (var s in spec) specificationsRow(s.key, s.value),
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
              border: Border.all(color: AppColors.extraLightGray, width: 1),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontSize: 16.sp,
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
              border: Border.all(color: AppColors.extraLightGray, width: 1),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}