import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/brand_controller.dart';
import '../../../controller/const/base_url.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/navigation_bar.dart';
import '../ads/create_ad_options_screen.dart';
import '../home_screen.dart';
import 'package:qarsspin/view/screens/favourites/favourite_screen.dart';
import '../my_offers_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  int _selectedIndex = 4;

  // ─────────────────────────────────────────────────────────────
  // Contact Information
  // ─────────────────────────────────────────────────────────────

  // Qars Spin WhatsApp / Phone
  static const String _phoneDigits = '97466288388';
  static const String _phoneDisplay = '+974 6628 8388';

  // Business Email
  static const String _businessEmail = 'qarsspin@gmail.com';

  // ─────────────────────────────────────────────────────────────
  // Social Media Links
  // ─────────────────────────────────────────────────────────────

  static const String _facebookUrl =
      'https://www.facebook.com/people/Qars-Spin/pfbid0JQVHTwfkNDbgBRHyaj8WgBfg9GVDkj7mq9cKcDdbe6jRbPkbYboDmi7UGkZQkeUEl/';

  static const String _tiktokUrl =
      'https://www.tiktok.com/@qarsspin';

  static const String _instagramUrl =
      'https://www.instagram.com/qarsspin/';

  static const String _xUrl =
      'https://x.com/qarsspin?s=21';

  // ─────────────────────────────────────────────────────────────
  // Colors
  // ─────────────────────────────────────────────────────────────

  static const Color _brand = Color(0xFFF2C230);
  static const Color _headerBg = Color(0xFF3C3C3C);

  // ─────────────────────────────────────────────────────────────
  // Theme-aware colors
  // ─────────────────────────────────────────────────────────────

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _ink =>
      _isDark ? Colors.white : const Color(0xFF0F0F0F);

  Color get _pageBg =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF6F5F1);

  Color get _cardBg =>
      _isDark ? const Color(0xFF2C2C2C) : Colors.white;

  Color get _iconBadgeBg =>
      _isDark ? const Color(0xFF3D3520) : const Color(0xFFFDF3D6);

  Color get _mutedText =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF888888);

  Color get _labelText =>
      _isDark ? const Color(0xFFD0D0D0) : const Color(0xFF444444);

  Color get _brandGrayText =>
      _isDark ? const Color(0xFF999999) : const Color(0xFFBEBEBE);

  Color get _taglineText =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF7A7A7A);

  // ─────────────────────────────────────────────────────────────
  // Phone
  // ─────────────────────────────────────────────────────────────

  Future<void> _callUs() async {
    final Uri uri = Uri.parse('tel:+$_phoneDigits');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // WhatsApp
  // ─────────────────────────────────────────────────────────────

  Future<void> _openWhatsApp() async {
    final lc = AppLocalizations.of(context)!;

    final String message = Uri.encodeComponent(
      lc.requestAppointmentWhatsappMessage,
    );

    final Uri app = Uri.parse(
      'whatsapp://send?phone=$_phoneDigits&text=$message',
    );

    final Uri web = Uri.parse(
      'https://api.whatsapp.com/send?phone=$_phoneDigits&text=$message',
    );

    try {
      if (await canLaunchUrl(app)) {
        await launchUrl(
          app,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          web,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lc.couldNotOpenWhatsapp),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Email
  // ─────────────────────────────────────────────────────────────

  Future<void> _emailBusiness() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _businessEmail,
     
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No email application is installed on this device.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open email application.',
            ),
          ),
        );
      }
    }
  }
  // ─────────────────────────────────────────────────────────────
  // Social Media
  // ─────────────────────────────────────────────────────────────

  Future<void> _openSocial(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this link'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this link'),
          ),
        );
      }
    }
  }
  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lc = AppLocalizations.of(context)!;

    final double addButtonSize = 60.w;
    final double addIconSize = 26.sp;
    final double addTextSize = 11.sp;

    return Scaffold(
      backgroundColor: _pageBg,

      // ─────────────────────────────────────────────────────────
      // App Bar
      // ─────────────────────────────────────────────────────────

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _headerBg,
        toolbarHeight: 60.h,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          lc.navigation_call_us,
          style: TextStyle(
            fontFamily: 'Gilroy',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────
      // Body
      // ─────────────────────────────────────────────────────────

      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Brand
            _brandBlock(context, lc),

            SizedBox(height: 28.h),

            // Contact
            _sectionHeading(
              lc.contact_section_title,
            ),

            SizedBox(height: 10.h),

            _quickActionsRow(),

            SizedBox(height: 28.h),

            // Business
            _sectionHeading(
              lc.for_business,
            ),

            SizedBox(height: 10.h),

            _businessInquiryCard(),

            SizedBox(height: 28.h),

            // Social
            _sectionHeading(
              lc.social_accounts,
            ),

            SizedBox(height: 14.h),

            _socialRow(),

            SizedBox(height: 24.h),
          ],
        ),
      ),

      // ─────────────────────────────────────────────────────────
      // Floating Add Button
      // ─────────────────────────────────────────────────────────

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      floatingActionButton: GestureDetector(
        onTap: () {
          Get.to(
            CreateNewAdOptions(),
          );
        },
        child: Container(
          width: addButtonSize,
          height: addButtonSize,
          decoration: BoxDecoration(
            color: AppColors.divider(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.background(context),
              width: 3.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: addIconSize,
                ),
                SizedBox(height: 2.h),
                Text(
                  lc.navigation_add,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: addTextSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy',
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────
      // Bottom Navigation
      // ─────────────────────────────────────────────────────────

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,

        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Get.offAll(
                HomeScreen(),
              );
              break;

            case 1:
              Get.offAll(
                OffersScreen(),
              );
              break;

            case 2:
              Get.offAll(
                CreateNewAdOptions(),
              );
              break;

            case 3:
              Get.find<BrandController>().switchLoading();
              Get.find<BrandController>().getFavList();

              Get.offAll(
                FavouriteScreen(),
              );
              break;

            case 4:
              Get.offAll(
                ContactUsScreen(),
              );
              break;
          }
        },

        onAddPressed: () {
          Get.to(
            CreateNewAdOptions(),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Brand Block
  // ─────────────────────────────────────────────────────────────

  Widget _brandBlock(
      BuildContext context,
      AppLocalizations lc,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Qars',
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 34.sp,
                fontWeight: FontWeight.w600,
                color: _brandGrayText,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Spin',
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: _brand,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Text(
            lc.specialized_techno,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: _taglineText,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section Heading
  // ─────────────────────────────────────────────────────────────

  Widget _sectionHeading(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Quick Actions
  // ─────────────────────────────────────────────────────────────

  Widget _quickActionsRow() {
    final lc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.call_outlined,
                title: lc.contact_call_us,
                subtitle: _phoneDisplay,
                onTap: _callUs,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: _quickActionCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: lc.contact_whatsapp,
                subtitle: lc.contact_whatsapp_subtitle,
                onTap: _openWhatsApp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Quick Action Card
  // ─────────────────────────────────────────────────────────────

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 22.h,
          horizontal: 12.w,
        ),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _iconBadgeBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: _brand,
                size: 26,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              title,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Business Inquiry Card
  // ─────────────────────────────────────────────────────────────

  Widget _businessInquiryCard() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: InkWell(
        onTap: _emailBusiness,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 16.h,
            horizontal: 14.w,
          ),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF3D6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.mail_outline,
                  color: _brand,
                  size: 22,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .contact_business_inquiries,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      _businessEmail,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Social Media Row
  // ─────────────────────────────────────────────────────────────

  Widget _socialRow() {
    final lc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Row(
        children: [
          // Facebook
          Expanded(
            child: _socialItem(
              icon: FontAwesomeIcons.facebookF,
              label: lc.contact_social_facebook,
              onTap: () => _openSocial(
                _facebookUrl,
              ),
            ),
          ),

          // X / Twitter
          Expanded(
            child: _socialItem(
              icon: FontAwesomeIcons.xTwitter,
              label: lc.contact_social_twitter,
              onTap: () => _openSocial(
                _xUrl,
              ),
            ),
          ),

          // Instagram
          Expanded(
            child: _socialItem(
              icon: FontAwesomeIcons.instagram,
              label: lc.contact_social_instagram,
              onTap: () => _openSocial(
                _instagramUrl,
              ),
            ),
          ),

          // TikTok
          Expanded(
            child: _socialItem(
              icon: FontAwesomeIcons.tiktok,
              label: lc.contact_social_tiktok,
              onTap: () => _openSocial(
                _tiktokUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Social Item
  // ─────────────────────────────────────────────────────────────

  Widget _socialItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FaIcon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: _labelText,
            ),
          ),
        ],
      ),
    );
  }
}