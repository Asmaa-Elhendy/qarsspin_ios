import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/partner_rating.dart';
import 'package:qarsspin/model/rental_car_model.dart';
import 'package:qarsspin/model/showroom_model.dart';

import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../showrooms_widgets/rating_tab_show_room_detail.dart';
import '../showrooms_widgets/showroom_details_tab_widget.dart';

class CarCareTapBar extends StatefulWidget {
  List<RentalCar> cars;
  String avgRating;
 PartnerRating rate;
 Showroom showroom;
 List<String> gallery;
   CarCareTapBar({required this.gallery,required this.showroom,required this.rate,required this.avgRating,required this.cars,super.key});

  @override
  State<CarCareTapBar> createState() => _CarCareTapBarState();
}

class _CarCareTapBarState extends State<CarCareTapBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print(widget.cars.length);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;


    return Column(children: [
      // --- Tab Bar ---
      Container(
        margin: EdgeInsets.all(16),
        height: 45.h,
        decoration: BoxDecoration(
          color: AppColors.tabBarColor(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          labelColor: AppColors.blackColor(context),
          unselectedLabelColor: AppColors.blackColor(context),
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp),
          tabs: [
            Tab(text: lc.gallery),
            Tab(text: lc.rating),
          ],
        ),
      ),

      // --- Tab Views ---
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [gallery(), rating()],
        ),
      ),
    ]);
  }

  Widget gallery() {
    return GridView.builder(
      //physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w,vertical:4.h ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 👈 3 عربيات في الصف
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.5.h
      ),
      itemCount: widget.gallery.length, // عدد العربيات
      itemBuilder: (_, i) {
        return Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.extraLightGray
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.gallery[i]),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );

  }

  Widget rating() {
    return RatingTabShowRoomDetail(showroom:widget.showroom,avgRating: widget.avgRating,myRate: widget.rate,);
  }
}
