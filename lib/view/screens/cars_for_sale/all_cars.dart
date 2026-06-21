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
                  itemCount: controller.carBrands.length,
                  itemBuilder: (context, index) {
                    return HomeServiceCard(
                      onTap: () {
                        final currentLocaleName = AppLocalizations.of(context)!.localeName;
                        print("current loca;$currentLocaleName");
                        controller.switchLoading();
                        controller.getCars(  // in case care for sale list
                          make_id: controller.carBrands[index].id,
                          makeName: controller.carBrands[index].name,
                        );
                        Get.to(CarsBrandList(
                          widget.notificationsController,
                            postKind: "CarForSale", //makes only in car for sale
                            brandName:  Get.locale?.languageCode=='ar'?controller.carBrands[index].slName:controller.carBrands[index].name));
                      },
                      brand: true,
                      title: Get.locale?.languageCode=='ar'? controller.carBrands[index].slName:controller.carBrands[index].name,
                      imageAsset: controller.carBrands[index].imageUrl,
                      large: false,
                      make_count: controller.carBrands[index].make_count,
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