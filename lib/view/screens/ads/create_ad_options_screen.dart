import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/auth/unregister_func.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ads/adv_model.dart';
import '../../widgets/main_card.dart';
import '../auth/my_account.dart';
import '../general/main_menu.dart';
import 'create_new_ad.dart';//j
import 'sell_your_car_v2.dart';

class CreateNewAdOptions extends StatefulWidget {
  @override
  State<CreateNewAdOptions> createState() => _CreateNewAdOptionsState();
}

class _CreateNewAdOptionsState extends State<CreateNewAdOptions> {
  bool show = false;
  int notificationCount = 3;
  final authController = Get.find<AuthController>();

  Future<void> _openRequestAppointmentWhatsApp(BuildContext context) async {
    final lc = AppLocalizations.of(context)!;

    final String message = Uri.encodeComponent(
      lc.requestAppointmentWhatsappMessage,
    );

    final Uri whatsappAppUrl = Uri.parse(
      'whatsapp://send?phone=97466288388&text=$message',
    );

    final Uri whatsappWebUrl = Uri.parse(
      'https://api.whatsapp.com/send?phone=97466288388&text=$message',
    );

    try {
      final bool canOpenWhatsApp = await canLaunchUrl(whatsappAppUrl);

      if (canOpenWhatsApp) {
        await launchUrl(
          whatsappAppUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          whatsappWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lc.couldNotOpenWhatsapp),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(

        centerTitle: true, // يخلي العنوان في نص العرض
        elevation: 0, // نشيل الشادو الافتراضي
        title: Text(
          lc.create_new_Ad,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: AppColors.background(context),
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
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 14.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(height: 200),
              GridView.count(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 3,
                crossAxisSpacing: 5,
                childAspectRatio: 1.2,
                children: [
                  HomeServiceCard(
                    onTap: () {
                      setState(() {
                        show = true;
                      });
                    },
                    title: lc.create_car_ads,fromHome: 'true',
                    imageAsset:
                    Get.locale?.languageCode=='ar'? 'assets/images/Dark mode icons/QS D-Mode-21.svg':
                    Theme.of(context).brightness == Brightness.dark?
                    'assets/images/Dark mode icons/QS D-Mode-01.svg' :'assets/images/new_svg/home1.svg',

                    large: false,//f
                  ),
                  HomeServiceCard(
                    onTap: () {
                      setState(() {
                        //show = true;
                      });
                    },
                    title: lc.create_bike_ad,fromHome: 'true',
                    plate: true,//l

                    imageAsset:
                    Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-05.svg' :'assets/images/new_svg/bikes.svg',
                    large: false,
                  ),
                  HomeServiceCard(
                    onTap: (){
                      setState(() {
                        // show = true;
                      });
                    },
                    plate: true,

                    title: lc.create_caravan_ad,
                    imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-06.svg' :'assets/images/new_svg/caravans.svg',
                    large: false,fromHome: 'true',
                  ),
                  HomeServiceCard(
                    onTap: (){
                      setState(() {
                        show = true;
                      });
                    },
                    plate: true,

                    title: lc.create_plate_ad,
                    imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-07.svg' :'assets/images/new_svg/plates.svg',
                    fromHome: 'true',
                    large: false,
                  ),
                ],
              ),
              24.verticalSpace,
              show
                  ? AdvertisementOptionsModal(
                onShowroomAdPressed: () {

                  if(authController.registered){
                    //when request appointment when registered
                    _openRequestAppointmentWhatsApp(context);

                  }
                  else{unRegisterFunction(context);}
                },
                onPersonalAdPressed: () {
                  if(authController.registered){
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => SellCarScreen(),
                    //   ),
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellYourCarV2(),
                      ),
                    );}
                  else{
                    unRegisterFunction(context);
                  }
                },
              )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
