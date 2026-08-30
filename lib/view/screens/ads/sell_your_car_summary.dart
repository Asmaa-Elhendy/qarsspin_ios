import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/const/colors.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Review-before-submit page for the Sell-Your-Car v2 create flow.
///
/// The Sell-Your-Car v2 screen navigates here after form validation
/// passes but BEFORE any submission call fires. This screen renders a
/// preview of what the user is about to publish (cover, headline
/// stats, price, chosen boosts, payment totals) and exposes the same
/// two actions the v2 form used to have at its own bottom:
///
///   • "Save as draft" — invokes `widget.onSaveAsDraft`, which the parenthh
///     wires to `_submitAd(shouldPublish: false)`.
///   • "Publish"       — invokes `widget.onPublish`, which the parent wires
///     to `_submitAd(shouldPublish: true)`.
///
/// The buttons keep their old names on purpose (user request) even
/// though the mockup shows "Pay Now / Publish Ad & Pay Later" — same
/// business logic, same submission methods, same backend flow.
///
/// Back navigation returns the user to the form with all their state
/// intact (v2 pushes to this screen instead of replacing).
class SellYourCarSummary extends StatefulWidget {
  final String? coverImage;
  final String make;
  final String carClass;
  final String model;
  final String year;
  final String mileage;
  final Color? exteriorColor;
  final String? exteriorColorName;
  final String askingPrice;
  final bool isRequest360;
  final bool isFeaturedPost;
  final VoidCallback onSaveAsDraft;
  final VoidCallback onPublish;

  const SellYourCarSummary({
    Key? key,
    required this.coverImage,
    required this.make,
    required this.carClass,
    required this.model,
    required this.year,
    required this.mileage,
    required this.exteriorColor,
    required this.exteriorColorName,
    required this.askingPrice,
    required this.isRequest360,
    required this.isFeaturedPost,
    required this.onSaveAsDraft,
    required this.onPublish,
  }) : super(key: key);

  @override
  State<SellYourCarSummary> createState() => _SellYourCarSummaryState();
}

class _SellYourCarSummaryState extends State<SellYourCarSummary> {
  static const Color _brand = Color(0xFFF2C230);

  // Theme-aware color roles — matches the old form's dark-mode
  // handling so the summary flips cleanly instead of staying stuck
  // on light.
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _isDark ? Colors.white : const Color(0xFF0F0F0F);
  Color get _pageBg =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEFEDE7);
  Color get _sectionBg =>
      _isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get _borderColor =>
      _isDark ? const Color(0xFF404040) : const Color(0xFFE5E5E5);
  Color get _mutedText =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    final paymentController = Get.find<PaymentController>();
    final double price360 =
        paymentController.request360ServicePrice ?? 0;
    final double priceFeatured =
        paymentController.featuredServicePrice ?? 0;

    // Payment Summary is what the SELLER pays to publish this ad —
    // that's only the paid add-ons (360° and/or Featured). The
    // asking price on the vehicle is what the BUYER will eventually
    // pay for the car; the seller isn't being charged it. Previously
    // we mistakenly added widget.askingPrice into Subtotal, which surfaced
    // as a bogus total (e.g. asking 233 + 360° 100 = 333) instead of
    // the correct 100.
    double subtotal = 0;
    if (widget.isRequest360) subtotal += price360;
    if (widget.isFeaturedPost) subtotal += priceFeatured;
    final double total = subtotal;

    // Wrap in AnnotatedRegion so the status bar gets a real color
    // of its own instead of inheriting the AppBar's yellow. Setting
    // `systemOverlayStyle` on the AppBar alone doesn't win on some
    // Android builds — AnnotatedRegion takes precedence.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // statusBarColor: Color(0xFF3C3C3C),
        // statusBarIconBrightness: Brightness.light,
        // statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor:_brand,
        elevation: 0,
        centerTitle: true,
       // iconTheme: IconThemeData(color: _ink),
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor:  AppColors.background(context),//AppColors.background(context),//Color(0xFF3C3C3C),
          // statusBarIconBrightness: Brightness.light,
          // statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          lc.summary_title,
          style: TextStyle(
            fontFamily: 'Gilroy',
            color: _ink,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
            _carPreviewCard(),
            SizedBox(height: 8.h),
            if (widget.isRequest360 || widget.isFeaturedPost) ...[
              _addonsCard(
                lc: lc,
                price360: price360,
                priceFeatured: priceFeatured,
              ),
              SizedBox(height: 8.h),
            ],
            _paymentSummaryCard(subtotal: subtotal, total: total),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(lc),
      ),
    );
  }

  Widget _carPreviewCard() {
    final lc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: _coverImageWidget(),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _carTitle(),
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: _ink,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            lc.summary_listed_vehicle,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF999999),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.calendar_today_outlined,
                  label: lc.summary_year,
                  value: widget.year.isEmpty ? '—' : widget.year,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _statTile(
                  icon: Icons.speed,
                  label: lc.summary_mileage,
                  value: widget.mileage.isEmpty
                      ? '—'
                      : '${_formatWithCommas(widget.mileage)} km',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: null,
                  swatch: widget.exteriorColor ?? const Color(0xFFC0C0C0),
                  label: lc.summary_color,
                  value: (widget.exteriorColorName == null ||
                          widget.exteriorColorName!.isEmpty)
                      ? '—'
                      : widget.exteriorColorName!,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _statTile(
                  icon: Icons.location_on_outlined,
                  label: lc.summary_location,
                  // Location tile is a fixed "Doha, Qatar" — the form
                  // doesn't collect a per-ad location today, so the
                  // summary mirrors the mockup with the app's home
                  // market until location capture ships.
                  value: lc.summary_location_value,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: const Divider(
              height: 1,
              color: Color(0xFFEDEDEA),
            ),
          ),
          Text(
            lc.summary_vehicle_price,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${lc.summary_qar} ${_formatWithCommas(widget.askingPrice.isEmpty ? '0' : widget.askingPrice)}',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: _brand,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverImageWidget() {
    final String? path = widget.coverImage;
    if (path == null || path.isEmpty) {
      return Container(
        color: const Color(0xFFE8DDBF),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            color: Color(0xFFB89A4A), size: 42),
      );
    }
    final bool isUrl = path.startsWith('http');
    return isUrl
        ? Image.network(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);
  }

  Widget _statTile({
    IconData? icon,
    Color? swatch,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 16.sp, color: const Color(0xFF888888)),
          if (swatch != null)
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.grey.shade400, width: 0.8),
              ),
            ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF888888),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addonsCard({
    required AppLocalizations lc,
    required double price360,
    required double priceFeatured,
  }) {
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lc.summary_selected_addons,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _ink,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 12.h),
          if (widget.isRequest360)
            _addonRow(
              label: lc.summary_addon_360,
              price: price360.toStringAsFixed(0),
            ),
          if (widget.isRequest360 && widget.isFeaturedPost) SizedBox(height: 8.h),
          if (widget.isFeaturedPost)
            _addonRow(
              label: lc.summary_addon_feature,
              price: priceFeatured.toStringAsFixed(0),
            ),
        ],
      ),
    );
  }

  Widget _addonRow({required String label, required String price}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF3EB489),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
          ),
          Text(
            '${AppLocalizations.of(context)!.summary_qar} $price',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _brand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSummaryCard(
      {required double subtotal, required double total}) {
    final lc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lc.summary_payment_title,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _ink,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lc.summary_subtotal,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                '${lc.summary_qar} ${_formatWithCommas(subtotal.toStringAsFixed(0))}',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(
              height: 1,
              color: Color(0xFFEDEDEA),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lc.summary_total_due,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              Text(
                '${lc.summary_qar} ${_formatWithCommas(total.toStringAsFixed(0))}',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: _brand,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 16, color: Color(0xFF888888)),
                SizedBox(width: 8.w),
                Text(
                  lc.summary_vat_note,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations lc) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: _sectionBg,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: OutlinedButton(
                onPressed: widget.onSaveAsDraft,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(color: _ink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  lc.save_draft,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: _ink,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 6,
              child: ElevatedButton(
                onPressed: widget.onPublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  (widget.isRequest360 || widget.isFeaturedPost)
                      ? lc.payandpublish
                      : lc.publish,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: _ink,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Joins the picked Make + Class + Model into one headline string,
  /// matching the mockup's "Mercedes-Benz GT 63 S" pattern. Empty
  /// pieces are skipped so we don't render trailing spaces on
  /// partially-filled ads. If nothing is picked, falls back to "—".
  String _carTitle() {
    final parts = <String>[
      if (widget.make.isNotEmpty) widget.make,
      if (widget.carClass.isNotEmpty) widget.carClass,
      if (widget.model.isNotEmpty) widget.model,
    ];
    return parts.isEmpty ? '—' : parts.join(' ');
  }

  String _formatWithCommas(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '0';
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
