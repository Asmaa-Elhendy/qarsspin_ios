import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/banner_service.dart';
import '../../model/banner_model.dart';

/// Ad banner slot used across the home / listing pages.
///
/// * `bigAdHome: true` → renders as a horizontal **slider** with up to
///   3 banners (fetched via `BannerService.getBannersByPriority`) and
///   dot indicators underneath. When only one banner comes back the
///   dots are hidden.
/// * `bigAdHome: false` → renders a single small banner via the
///   original `getBannerByPriority` path (unchanged behavior).
///
/// The priority fallback chain is identical in both modes:
///   1. type + this page  2. type + global
///   3. filler + this page  4. filler + global
///   5. static local asset (final fallback via `_buildErrorWidget`).
class AdContainer extends StatefulWidget {
  final bool bigAdHome;
  final String targetPage; // e.g., 'Home Page', 'Cars For Sale - List Page'

  const AdContainer({
    Key? key,
    this.bigAdHome = false,
    this.targetPage = 'Global',
  }) : super(key: key);

  @override
  _AdContainerState createState() => _AdContainerState();
}

class _AdContainerState extends State<AdContainer> {
  /// Populated for the big-banner slider (up to 3 items). For the
  /// small-banner variant the first item is the only one used.
  List<BannerModel> _banners = <BannerModel>[];
  bool _isLoading = true;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final BannerService _bannerService = BannerService();
  final Set<int> _trackedImpressions = <int>{};
  // Auto-advance timer for the big-banner slider. Advances every
  // 4 seconds and wraps around at the last page. Only started when
  // there are 2+ banners to rotate through — a single banner just
  // sits still.
  Timer? _autoplay;
  static const Duration _autoplayInterval = Duration(seconds: 4);

  @override
  void dispose() {
    _autoplay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _autoplay?.cancel();
    if (!widget.bigAdHome || _banners.length < 2) return;
    _autoplay = Timer.periodic(_autoplayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final int next = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadBanner() async {
    if (!mounted) return;

    try {
      print('🔄 Loading banners for ${widget.targetPage}...');
      setState(() => _isLoading = true);

      final banners = await _bannerService.getActiveBanners();

      if (!mounted) return;

      if (banners.isEmpty) {
        print('⚠️ No banners received from API');
        setState(() => _isLoading = false);
        return;
      }

      // Debug summary of the raw API response so we can tell at a
      // glance whether the reason a page's slider is short is "no
      // banners in the response" vs. "banners exist but the priority
      // filter dropped them".
      final Map<String, int> typeBreakdown = <String, int>{};
      for (final b in banners) {
        final key = '${b.bannerType}/${b.targetType}';
        typeBreakdown[key] = (typeBreakdown[key] ?? 0) + 1;
      }
      print('🗂 banner API returned ${banners.length} → $typeBreakdown');

      final bannerType = widget.bigAdHome ? 'Big' : 'Small';

      // Big slot pulls up to 3 for the slider; small slot keeps the
      // single-banner behavior it always had.
      final List<BannerModel> matched = widget.bigAdHome
          ? _bannerService.getBannersByPriority(
              banners,
              widget.targetPage,
              bannerType,
              maxCount: 3,
            )
          : [
              if (_bannerService.getBannerByPriority(
                      banners, widget.targetPage, bannerType) !=
                  null)
                _bannerService.getBannerByPriority(
                    banners, widget.targetPage, bannerType)!,
            ];

      if (matched.isNotEmpty) {
        print('✅ Displaying ${matched.length} banner(s) for ${widget.targetPage}');
        // Track impressions once per unique banner id, not on every
        // page swipe.
        _trackImpressionsFor(matched);
      } else {
        print('ℹ️ No matching banner found for current criteria');
      }

      if (mounted) {
        setState(() {
          _banners = matched;
          _currentPage = 0;
          _isLoading = false;
        });
        _startAutoplay();
      }
    } catch (e) {
      print('❌ Error loading banner: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _trackImpressionsFor(List<BannerModel> list) {
    for (final b in list) {
      if (_trackedImpressions.add(b.bannerId)) {
        try {
          _bannerService.trackBannerImpression(b.bannerId);
        } catch (e) {
          print('❌ Error tracking banner impression: $e');
        }
      }
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────

  double get _slotHeight => widget.bigAdHome ? 170.h : 115.h;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_banners.isEmpty) {
      return _buildErrorWidget();
    }

    // Small banner: single-image path, unchanged from before.
    if (!widget.bigAdHome) {
      return _bannerCard(_banners.first);
    }

    // Big banner: horizontal slider with dot indicators laid over
    // the bottom edge of the banner (inside the card). Keeps the
    // whole slot the same height as the single-banner variant so the
    // page layout doesn't shift depending on how many banners the
    // API returned.
    return SizedBox(
      height: _slotHeight + 24.h, // include the card's vertical margin
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _bannerCard(_banners[i]),
          ),
          if (_banners.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20.h, // sit above the card's bottom margin
              child: _dotIndicators(),
            ),
        ],
      ),
    );
  }

  /// Uniform round dots — no width change on activation, only color.
  /// A soft translucent pill sits behind the row so the dots stay
  /// legible on light AND dark banner artwork.
  Widget _dotIndicators() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(_banners.length, (i) {
            final bool active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _bannerCard(BannerModel banner) {
    final String imageUrl = Get.locale?.languageCode == 'ar'
        ? banner.imageUrlSl
        : banner.imageUrlPl;
    return GestureDetector(
      onTap: banner.targetUrlPl.isNotEmpty
          ? () => _launchUrl(banner, banner.targetUrlPl)
          : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        height: _slotHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Error loading banner image: $error');
                    return _buildErrorWidget();
                  },
                )
              : _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return GestureDetector(
      onTap: _loadBanner,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        height: _slotHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/new_svg/Big_ads.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported,
                      size: 40.w, color: Colors.grey[400]),
                ),
              ),
            ),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  size: 16.w,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      height: _slotHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          'assets/images/new_svg/Big_ads.png',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.image_not_supported,
              size: 40.w,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BannerModel banner, String url) async {
    try {
      await _bannerService.trackBannerClick(banner.bannerId);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        log('⚠️ Could not launch URL: $url');
      }
    } catch (e) {
      log('❌ Error during banner click handling: $e');
    }
  }
}
