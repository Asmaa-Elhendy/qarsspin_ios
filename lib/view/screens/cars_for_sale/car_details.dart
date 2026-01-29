import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/specification.dart';
import 'package:qarsspin/view/screens/auth/my_account.dart';
import 'package:qarsspin/view/screens/get_loan.dart';
import 'package:qarsspin/view/widgets/auth_widgets/register_dialog.dart';
import 'package:qarsspin/view/widgets/car_details/qars_apin_bottom_navigation_bar.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../controller/auth/unregister_func.dart';
import '../../../controller/communications.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localization.dart';
import '../../../model/car_model.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/bottom_offer_bar.dart';
import '../../widgets/buttons/requesr_report_button.dart';
import '../../widgets/car_card.dart';
import '../../widgets/car_details/tab_bar.dart';
import '../../widgets/car_image.dart';
import '../../widgets/offer_dialog.dart';
import '../../widgets/texts/texts.dart';
import 'dart:developer';

class CarDetails extends StatefulWidget {
  String postKind;
  int id;
  String sourcekind;

  String mobile;

  CarDetails({required this.mobile,required this.sourcekind,required this.id,required this.postKind,super.key});

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    List<CarModel> carsList = [];
    var lc = AppLocalizations.of(context)!;



    return GetBuilder<BrandController>(builder: (controller) {
      return Scaffold(
        backgroundColor: AppColors.background(context),

        bottomNavigationBar: widget.sourcekind == "Qars Spin"
            ? QarsApinBottomNavigationBar(

          onLoan: (){
            authController.registered? Get.to(GetLoan(car: controller.carDetails)):
            showDialog(
              context: context,
              builder: (_) =>RegisterDialog(),
            );

          },
          onMakeOffer: ()async {
            // Handle make offer
            await showDialog(

              context: context,
              builder: (_) =>authController.registered?  MakeOfferDialog():RegisterDialog(),
            );
          },
          onRequestToBuy: ()async {
            // Handle make offer
            await showDialog(
              context: context,
              builder: (_) =>  authController.registered?MakeOfferDialog(offer: false,requestToBuy: true,price: controller.carDetails.askingPrice,):RegisterDialog(),
            );


          },
        )
            : BottomActionBar(
          onMakeOffer: () async {
            // Handle make offer

            await authController.registered?
            // Get.dialog(
            //     MakeOfferDialog())
            showDialog(
              context: context,
              builder: (_) =>  MakeOfferDialog(),
            )
                :unRegisterFunction(context);
          },
          onWhatsApp: () {
            openWhatsApp(controller.carDetails.ownerMobile, message: "Hello 👋");
            log("moooo${controller.carDetails.ownerMobile} ${widget.id}");
            // Handle WhatsApp
          },
          onCall: () {
            // Handle call
            makePhoneCall(controller.carDetails.ownerMobile);
          },
        ),
        body: controller.oldData?
        Center(
          child: Container(
            color: AppColors.black.withOpacity(0.5),
            child: Center(
              child: AppLoadingWidget(
                title: lc.loading,
              ),
            ),
          ),
        )
            :Column(children: [
          Container(
            height: 100.h, // same as your AppBar height
            padding: EdgeInsets.only(top: 25.h, left: 14.w, right: 14.w),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              boxShadow: [
                BoxShadow( //update asmaa
                  color: AppColors.blackColor(context).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5.h,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // go back
                  },
                  child: Icon(
                    Icons.arrow_back_outlined,
                    color: AppColors.blackColor(context),
                    size: 30.w,
                  ),
                ),
                .5.horizontalSpace,
                Center(
                  child: SizedBox(
                      width: 147.w,
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/balckIconDarkMode.png'
                            : 'assets/images/black_logo.png',
                        fit: BoxFit.cover,
                      )),
                ),
                Row(
                  children: [
                    // InkWell(
                    //   onTap: () {},
                    //   child: SizedBox(
                    //       width: 25.w,
                    //       child: Image.asset(
                    //         "assets/images/share.png",
                    //         fit: BoxFit.cover,
                    //         color: AppColors.blackColor(context),
                    //       )),
                    // ),
                    12.horizontalSpace,
                    InkWell(
                        onTap: () {
                          authController.registered?  controller.alterPostFavorite(add: controller.carDetails.isFavorite!?false:true, postId: widget.id)
                              : showDialog(
                            context: context,
                            builder: (_) =>RegisterDialog(),
                          );
                        },
                        child:  Theme.of(context).brightness == Brightness.dark?Icon(
                          Icons.favorite,
                          color:
                          controller.carDetails.isFavorite!
                              ? AppColors.primary:AppColors.notFavorite(context),
                        ): controller.carDetails.isFavorite!
                            ?Icon(
                          Icons.favorite,color: AppColors.primary,

                        ):Icon(Icons.favorite_border)

                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250.h,
            child: CarImage(
              allImages: controller.postMedia,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  16.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: SizedBox(
                      //height: 800.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize
                            .min, // shrink-wrap instead of expanding
                        children: [
                          blueText(
                              "${controller.carDetails.visitsCount} ${lc.people_view}"),
                          4.verticalSpace,
                          headerText(Get.locale?.languageCode=='ar'?controller.carDetails.carNameSl.trim():controller.carDetails.carNamePl.trim(),context),
                          4.verticalSpace,
                          description(Get.locale?.languageCode=='ar'?controller.carDetails.technical_Description_SL:controller.carDetails.description,context: context),
                          12.verticalSpace,
                          Divider(
                            thickness: .5,
                            color: AppColors.divider(context),
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                greyText(lc.price),
                                2.verticalSpace,
                                price(
                                    "${controller.carDetails.askingPrice} ${lc.currency_Symbol}"),
                                2.verticalSpace,
                                boldGrey(
                                    "${controller.carDetails.offersCount} ${lc.people_made_offer}")
                              ],
                            ),
                          ),
                          Divider(
                            thickness: .5,
                            color: AppColors.divider(context),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 70.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    boldGrey(lc.ad_code),
                                    4.verticalSpace,
                                    headerText(controller.carDetails.postCode,context),
                                  ],
                                ),
                                Column(
                                  children: [
                                    boldGrey(lc.year,
                                    ),
                                    4.verticalSpace,
                                    headerText(
                                        "${controller.carDetails.manufactureYear}",context),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    boldGrey(lc.mileage),
                                    4.verticalSpace,
                                    headerText(controller.carDetails.mileage
                                        .toString(),context),
                                  ],
                                ),
                                Column(
                                  children: [
                                    boldGrey(lc.warranty),

                                    4.verticalSpace,
                                    headerText(controller
                                        .carDetails.warrantyAvailable,context),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize
                                      .min, // shrink-wrap instead of expanding
                                  children: [
                                    boldGrey(lc.exterior),
                                    4.verticalSpace,
                                    Container(
                                      width: 34.w,
                                      height: 34.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.darkGray),
                                          color: controller
                                              .carDetails.exteriorColor),
                                    )
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
                                          color: controller
                                              .carDetails.interiorColor,
                                          border: Border.all(
                                              color: AppColors.darkGray)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          controller.carDetails.sourceKind == 'Qars Spin'
                              ? Center(child: requestReportButton(context,widget.id))
                              : SizedBox(),
                          controller.carDetails.sourceKind == 'Qars Spin'
                              ?Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              12.verticalSpace,
                              Text(
                                lc.specifications,
                                style: TextStyle(
                                    color: AppColors.blackColor(context),
                                    fontFamily: fontFamily,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                              10.verticalSpace,
                              specifications(controller.spec)

                            ],
                          ):SizedBox(),
                          16.verticalSpace,
                          //optional Details
                          controller.carDetails.sourceKind == 'Individual' ||
                              controller.carDetails.sourceKind == 'Partner'
                              ? SizedBox(
                              height: 300.h,
                              child: CustomTabExample(
                                postId: widget.id.toString(),
                                spec: controller.spec,
                                offers: controller.offers,
                              ))
                              : SizedBox(),
                          16.verticalSpace,

                          controller.carDetails.sourceKind == 'Qars Spin' ||
                              controller.carDetails.sourceKind == 'Partner'
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionWithCars("Similar Cars", controller.similarCars),
                              20.verticalSpace,
                              sectionWithCars("Owner's Ads", controller.ownersAds),
                            ],
                          )
                              : SizedBox(),
                          16.verticalSpace
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    });
  }

  Widget sectionWithCars(String title, List<CarModel> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style:  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700,fontFamily: fontFamily,
                color: AppColors.blackColor(context)
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 275.h, // card height

          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 3.h),
            itemCount: cars.length,
            shrinkWrap: true,

            separatorBuilder: (_, __) => SizedBox(width: 4.w),

            itemBuilder: (context, index) {
              return carCard(
                // w: 192.w,
                // h: 235.h,
                  context: context,
                  w: 150.w,
                  h: 50,
                  postKind: widget.postKind,
                  car: cars[index],
                  large: false,
                  tooSmall: true
              );
            },
          ),
        ),
      ],
    );
  }
  Widget specifications(List<Specifications> spec){
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          for(int i =0; i < spec.length;i++)

            specificationsRow(spec[i].key,spec[i].value),
          // specificationsRow("Seats Type","5"),
          // specificationsRow("Slide Roof","Yes"),
          // specificationsRow("Park sensors","yes"),
          // specificationsRow("Camera","yes"),
          // specificationsRow("Bluetooth","Yes"),
          // specificationsRow("Gps","yes"),
          // specificationsRow("Engine Power","2.0"),
          // specificationsRow("Interior Color","Red"),
          // specificationsRow("Fuel Type","Hybrid"),
          // specificationsRow("Transmission","automatic"),
          // specificationsRow("Upholstery Material","Leather And Chamois"),
          // specificationsRow("Steering Wheel features","All Options"),
          // specificationsRow("Wheels","19"),
          // specificationsRow("Headlights","Yes"),
          // specificationsRow("Tail Lights","yes"),
          // specificationsRow("Fog Lamps","Yes"),
          // specificationsRow("Body Type","sedan"),
          //
          // specificationsRow("ABS","Yes"),
          // specificationsRow("Lane Assist","Yes"),
          // specificationsRow("Adaptive Cruise Control","Yes"),
          // specificationsRow("Automatic Emergency","Yes"),
          // specificationsRow("Wireless Charging","Yes"),
          // specificationsRow("Apple Carplay/Android","CarPlay"),
          //
          // specificationsRow("USB Parts","Yes"),
          // specificationsRow("Voice Commands","Yes"),
          // specificationsRow("Exterior Colors","Gray"),
          // specificationsRow("Warranty Period","6 Years"),
          // specificationsRow("Roof Rails","Chamois"),


        ],
      ),
    ) ;
  }
  Widget specificationsRow(String title ,String value){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: .8.h),
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
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 14.sp, color: AppColors.blackColor(context)),

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
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 14.sp, color: AppColors.blackColor(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}