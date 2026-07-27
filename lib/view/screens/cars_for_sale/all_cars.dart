import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/brand_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../controller/notifications_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ad_container.dart';
import '../../widgets/car_list_grey_bar.dart';
import '../../widgets/cars_list_app_bar.dart';
import '../../widgets/main_card.dart';
import 'cars_brand_list.dart';

class AllCars extends StatefulWidget {
  NotificationsController notificationsController;
  AllCars(this.notificationsController);

  @override
  State<AllCars> createState() => _AllCarsState();
}

class _AllCarsState extends State<AllCars> {
  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: carListAppBar(widget.notificationsController,notificationCount: 3,context: context),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AdContainer(//update banner
            bigAdHome: true,
            targetPage: 'Cars For Sale - List Page',
          ),
          8.verticalSpace,
          carListGreyBar(widget.notificationsController,onSearchResult:(_){},title: lc.all_makes,context: context,makes: true),
          8.verticalSpace,
          GetBuilder<BrandController>(
            init: BrandController(),
            builder: (controller) {
              // Hide makes with 0 cars — the user shouldn't see a brand
              // tile that leads to an empty listing. The synthetic
              // "All Cars" entry (index 0 of the raw list) carries the
              // aggregated total, so it stays visible.
              final visibleBrands = controller.carBrands
                  .where((b) => b.make_count > 0)
                  .toList();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GridView.builder(
                  shrinkWrap: true, // مهم جدا داخل ListView
                  physics: NeverScrollableScrollPhysics(), // تمرير ListView
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.w,
                  ),
                  itemCount: visibleBrands.length,
                  itemBuilder: (context, index) {
                    final brand = visibleBrands[index];
                    return HomeServiceCard(
                      onTap: () {
                        final currentLocaleName = AppLocalizations.of(context)!.localeName;
                        print("current loca;$currentLocaleName");
                        controller.switchLoading();
                        controller.getCars(  // in case care for sale list
                          make_id: brand.id,
                          makeName: brand.name,
                        );
                        Get.to(CarsBrandList(
                          widget.notificationsController,
                            postKind: "CarForSale", //makes only in car for sale
                            brandName:  Get.locale?.languageCode=='ar'?brand.slName:brand.name));
                      },
                      brand: true,
                      title: Get.locale?.languageCode=='ar'? brand.slName:brand.name,
                      imageAsset: brand.imageUrl,
                      large: false,
                      make_count: brand.make_count,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}