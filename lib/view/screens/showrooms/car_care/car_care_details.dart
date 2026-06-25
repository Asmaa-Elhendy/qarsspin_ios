
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';
import 'package:qarsspin/model/showroom_model.dart';

import '../../../../controller/communications.dart';
import '../../../../controller/notifications_controller.dart';
import '../../../widgets/car_care/care_info.dart';
import '../../../widgets/car_care/tab_Bar.dart';
import '../../../widgets/showrooms_widgets/bottom_bar.dart';
import '../../../widgets/showrooms_widgets/header_section.dart';

class CarCareDetails extends StatefulWidget {
  final Showroom carCare;
  final bool isCarCare;
  final bool rental;
  final NotificationsController notificationsController;

  const CarCareDetails(
    this.rental,
    this.notificationsController, {
    required this.carCare,
    required this.isCarCare,
    super.key,
  });

  @override
  State<CarCareDetails> createState() => _CarCareDetailsState();
}

class _CarCareDetailsState extends State<CarCareDetails> {
  bool _isShareLoading = false;
  String? _lastCachedShareImageUrl;

  @override
  void initState() {
    super.initState();

    print("in showroomdetails${widget.carCare.rentalCars?.length}");

    _cacheShareImageIfNeeded(_getShareImageUrl());
  }

  String _getShareImageUrl() {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final Showroom showroom = widget.carCare;

    final String banner = isArabic ? showroom.bannerUrlSl : showroom.bannerUrlPl;

    return showroom.logoUrl.trim().isNotEmpty ? showroom.logoUrl : banner;
  }

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

  Future<void> _shareCarCare({
    required BuildContext shareButtonContext,
  }) async {
    setState(() {
      _isShareLoading = true;
    });

    try {
      final bool isArabic = Get.locale?.languageCode == 'ar';
      final Showroom showroom = widget.carCare;

      final String name = isArabic
          ? showroom.partnerNameSl.trim()
          : showroom.partnerNamePl.trim();

      final String branchName = isArabic
          ? showroom.branchNameSl.trim()
          : showroom.branchNamePl.trim();

      final String description = isArabic
          ? showroom.partnerDescSl.trim()
          : showroom.partnerDescPl.trim();

      final String imageUrl = _getShareImageUrl();

      await shareCarCareFromQarsSpin(
        context: shareButtonContext,
        name: name,
        rating: showroom.avgRating,
        type: widget.isCarCare ? 'Car Care service' : 'Showroom',
        branchName: branchName,
        description: description,
        phone: showroom.contactPhone,
        whatsapp: showroom.contactWhatsApp,
        mapsUrl: showroom.mapsUrl,
        joiningDate: showroom.joiningDate,
        visitsCount: showroom.visitsCount,
        activePosts: showroom.activePosts,
        followersCount: showroom.followersCount,
        carsCount: showroom.carsCount,
        imageUrl: imageUrl,
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
  }

  Widget _buildShareButton(BuildContext context) {
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
                  await _shareCarCare(
                    shareButtonContext: shareButtonContext,
                  );
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

  @override
  Widget build(BuildContext context) {
    _cacheShareImageIfNeeded(_getShareImageUrl());

    return Scaffold(
      backgroundColor: AppColors.background(context),
      bottomNavigationBar: ShowRoomBottomBar(
        widget.rental,
        widget.notificationsController,
        showRoom: widget.carCare,
        carCare: widget.isCarCare,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                  color: AppColors.blackColor(context).withOpacity(0.2),
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
                  onTap: () {
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

                Center(
                  child: SizedBox(
                    width: 147.w,
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/balckIconDarkMode.png'
                          : 'assets/images/black_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                _buildShareButton(context),
              ],
            ),
          ),

          HeaderSection(
            realImage: widget.carCare.spin360Url,
          ),

          CareInfo(
            show: widget.carCare,
          ),

          GetBuilder<ShowRoomsController>(
            init: ShowRoomsController(),
            builder: (controller) {
              return Expanded(
                child: SizedBox(
                  height: 600.h,
                  child: CarCareTapBar(
                    rate: controller.partnerRating,
                    showroom: widget.carCare,
                    gallery: controller.gallery,
                    cars: widget.carCare.rentalCars ?? [],
                    avgRating: widget.carCare.avgRating.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

