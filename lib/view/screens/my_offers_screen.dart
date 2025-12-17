import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/widgets/favourites/favourite_car_card.dart';
import 'package:qarsspin/view/widgets/navigation_bar.dart';
import 'package:qarsspin/view/screens/cars_for_sale/car_details.dart';
import 'package:qarsspin/view/widgets/ads/dialogs/loading_dialog.dart';

import '../../controller/auth/auth_controller.dart';
import '../../l10n/app_localization.dart';
import 'ads/create_ad_options_screen.dart';
import 'favourites/favourite_screen.dart';
import 'general/contact_us.dart';
import 'home_screen.dart';



class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  int _selectedIndex = 1;
  final BrandController _controller = Get.find<BrandController>();
  String userName= Get.find<AuthController>().userFullName!;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupLoadingListener();
    _loadOffers();
  }

  void _setupLoadingListener() {
    ever(_controller.isLoadingOffers, (isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading as bool;
        });
      }
    });

    // Initial check
    if (_controller.isLoadingOffers.isTrue) {
      _isLoading = true;
    }
  }

  Future<void> _loadOffers() async {
    await _controller.getMyOffers();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true, // يخلي العنوان في نص العرض
        elevation: 0, // نشيل الشادو الافتراضي
        title: Text(
          lc.lbl_my_offers,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
        flexibleSpace: Container(
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
        ),
      ),
//k

      body: Stack(
        children: [
          // Main Content
          GetBuilder<BrandController>(
            builder: (controller) {
              if (controller.myOffersList.isEmpty) {
                return Center(
                  child: Text(
                    lc.no_offers,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return RefreshIndicator(color: AppColors.primary,
                onRefresh: _loadOffers,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  itemCount: controller.myOffersList.length,
                  itemBuilder: (context, index) {
                    final offer = controller.myOffersList[index];
                    return GestureDetector(
                      onTap: () {
                        controller.getCarDetails(
                          context: context,
                          offer.postKind,
                          offer.postId.toString(),
                        );
                        Get.to(
                              () => CarDetails(
                            sourcekind: offer.sourceKind,
                            postKind: offer.postKind,
                            id: offer.postId,
                            mobile:offer.ownerMobile ,
                          ),
                        );
                      },
                      child: FavouriteCarCard(
                        myOffer: 'Offer',
                        title: Get.locale?.languageCode=='ar'?offer.carNameSl:offer.carNamePl,
                        price: offer.askingPrice,
                        location: '',
                        meilage: '${offer.mileage} ${lc.mileage_Unit}',
                        manefactureYear: offer.manufactureYear.toString(),
                        imageUrl: offer.rectangleImageUrl,
                        onHeartTap: () {
                          // Handle remove offer if needed
                        },
                        onDeleteTap: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  lc.delete_offer,
                                  style: TextStyle(fontSize: 19.w, fontWeight: FontWeight.bold),
                                ),
                                content:  Text(lc.sure_delete_offer),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      lc.btn_Cancel,
                                      style: TextStyle(color: AppColors.textPrimary(context)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.deleteOffer(offerId: offer.offerId.toString(), loggedInUser: userName,context: context);
                                      Navigator.pop(context, true);
                                    },
                                    style: TextButton.styleFrom(//k
                                      foregroundColor: Colors.red,
                                    ),
                                    child:  Text(lc.delete),
                                  ),
                                ],
                              );
                            },
                          );

                          if (result == true) {
                            try {
                              final response = await _controller.deleteOffer(
                                  offerId: offer.postId.toString(),
                                  loggedInUser: _controller.authController.userFullName ?? 'unknown',context: context
                              );

                              if (response['Code'] == 'OK') {
                                Get.snackbar(
                                  lc.success,
                                  lc.offer_deleted,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                // Refresh the offers list
                                await _loadOffers();
                              } else {
                                Get.snackbar(
                                  lc.error_lbl,
                                  response['Desc'] ??lc.failed_delete_offer,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } catch (e) {
                              Get.snackbar(
                                lc.error_lbl,
                                lc.error_on_delete,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color:Colors.black.withOpacity(0.2),
              child:  Center(
                child: AppLoadingWidget(
                  title: lc.loading,
                ),
              ),
            ),

        ],
      )
      ,

      // Bottom Nav Bar
      bottomNavigationBar: CustomBottomNavBar(

        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {

            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Get.offAll(HomeScreen());
              break;
            case 1:
              Get.offAll(OffersScreen());

              break;
            case 2:
              Get.offAll(CreateNewAdOptions());

              break;

            case 3:
              Get.find<BrandController>().switchLoading();
              Get.find<BrandController>().getFavList();
              Get.offAll(FavouriteScreen());
              break;
            case 4:
              Get.offAll(ContactUsScreen());
              break;
          }
        },
        onAddPressed: () {
          // TODO: Handle Add button tap
          Get.to(CreateNewAdOptions());
        },
      ),
    );
  }
}