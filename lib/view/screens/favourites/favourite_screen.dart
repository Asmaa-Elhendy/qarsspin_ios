import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../l10n/app_localization.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/favourites/favourite_car_card.dart';
import '../../widgets/navigation_bar.dart';
import '../ads/create_ad_options_screen.dart';
import '../cars_for_sale/car_details.dart';
import '../general/contact_us.dart';
import '../home_screen.dart';
import '../my_offers_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int _selectedIndex = 3;
  final BrandController _controller = Get.find<BrandController>();
  bool _isLoading = false;

  Future<void> _loadFavorites() async {
    await _controller.getFavList();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          lc.my_fav,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20.w,
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

      body: GetBuilder<BrandController>(
        builder: (controller) {
          _isLoading = controller.loadingMode;

          Widget content;

          if (controller.favoriteList.isEmpty) {
            content = Center(
              child: Text(
                lc.empty_lbl,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            );
          } else {
            content = RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadFavorites,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: 16.h,
                  bottom: kBottomNavigationBarHeight + 16.h,
                ),
                itemCount: controller.favoriteList.length,
                itemBuilder: (context, i) {
                  final fav = controller.favoriteList[i];
                  return GestureDetector(
                    onTap: () {
                      controller.getCarDetails(
                        fav.postKind,
                        fav.postId.toString(),
                        context: context,
                      );
                      Get.to(
                            () => CarDetails(
                          sourcekind: fav.sourceKind,
                          postKind: fav.postKind,
                          mobile: fav.ownerMobile,
                          id: fav.postId,
                        ),
                      );
                    },
                    child: FavouriteCarCard(
                      title: Get.locale?.languageCode == 'ar'
                          ? fav.carNameSl
                          : fav.carNamePl,
                      price: fav.askingPrice,
                      location: "controller.favoriteList[i].",
                      meilage: fav.mileage.toString(),
                      manefactureYear: fav.manufactureYear.toString(),
                      imageUrl: fav.rectangleImageUrl,
                      onHeartTap: () {
                        controller.removeFavItem(fav);
                        controller.alterPostFavorite(
                          add: false,
                          postId: fav.postId,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return Stack(
            children: [
              // Main content (list / empty state)
              content,

              // Loading overlay (نفس فكرة OffersScreen)
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: AppLoadingWidget(
                      title: lc.loading,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

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
              Get.offAll(const FavouriteScreen());
              break;
            case 4:
              Get.offAll(ContactUsScreen());
              break;
          }
        },
        onAddPressed: () {
          Get.to(CreateNewAdOptions());
        },
      ),
    );
  }
}
