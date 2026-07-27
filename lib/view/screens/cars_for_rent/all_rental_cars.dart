import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../controller/notifications_controller.dart';
import '../../../controller/rental_cars_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ad_container.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/car_list_grey_bar.dart';
import '../../widgets/cars_list_app_bar.dart';
import '../../widgets/rental_car_card.dart';

class AllRentalCars extends StatefulWidget {
  NotificationsController notificationsController;
  AllRentalCars(this.notificationsController);

  @override
  State<AllRentalCars> createState() => _AllRentalCarsState();
}

class _AllRentalCarsState extends State<AllRentalCars> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreCarsIfNeeded);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreCarsIfNeeded);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreCarsIfNeeded() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 500) {
      Get.find<RentalCarsController>().loadMoreRentalCars(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;


    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: carListAppBar(widget.notificationsController,notificationCount: 3,context: context),
      body:  GetBuilder<RentalCarsController>(
          builder: (controller) {
            return Stack(
              children: [
                Column(
                  children: [
                    AdContainer(//update banner
                      bigAdHome: true,
                      targetPage: 'Cars For Rent - List Page',////not found name in db
                    ),                    8.verticalSpace,
                    carListGreyBar(widget.notificationsController,onSearchResult:(_){},title: lc.all_rental_cars,context: context,squareIcon: true,rental: true),
                    8.verticalSpace,
                    GetBuilder<RentalCarsController>(
                        builder: (controller) {
                          return Expanded(
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20.h,
                                      // crossAxisSpacing: .4.w,
                                      childAspectRatio: .59,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        return RentalCarCard(
                                          car: controller.rentalCars[index],
                                        );
                                      },
                                      childCount: controller.rentalCars.length,
                                    ),
                                  ),
                                ),
                                if (controller.loadingMoreCars)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                    ),

                  ],
                ),
                if(controller.loadingMode)
                  Positioned.fill(

                    child: Container(
                      color: AppColors.black.withOpacity(0.5),
                      child: Center(
                        child: AppLoadingWidget(
                          title: lc.loading,
                        ),
                      ),
                    ),
                  )
              ],
            );
          }
      ),
    );
  }
}
