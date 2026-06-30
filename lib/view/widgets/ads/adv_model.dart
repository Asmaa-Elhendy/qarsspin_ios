import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/l10n/l10n.dart';
import 'package:qarsspin/view/widgets/my_ads/my_ad_card.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/add_options_model.dart';




class AdvertisementOptionsModal extends StatefulWidget {
  final VoidCallback onShowroomAdPressed;
  final VoidCallback onPersonalAdPressed;

  const AdvertisementOptionsModal({
    Key? key,
    required this.onShowroomAdPressed,
    required this.onPersonalAdPressed,
  }) : super(key: key);

  @override
  _AdvertisementOptionsModalState createState() => _AdvertisementOptionsModalState();
}

class _AdvertisementOptionsModalState extends State<AdvertisementOptionsModal> {
  late List<OptionItem> showroomOptions;
  late List<OptionItem> personalOptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lc = AppLocalizations.of(context)!;
    showroomOptions = [
      OptionItem(text: lc.getText('free_ads'), isChecked: true),
      OptionItem(text: lc.getText('free_360'), isChecked: true),
      OptionItem(text: lc.getText('after_sale_commission'), isChecked: true),
      OptionItem(text: lc.getText('private_seller_info'), isChecked: true),
    ];

    personalOptions = [
      OptionItem(text: lc.getText('standard_advertise'), isChecked: false),
      OptionItem(text: lc.getText('show_contact_details'), isChecked: false),
      OptionItem(text: lc.getText('upload_pictures_videos'), isChecked: false),
      OptionItem(text: lc.getText('optional_360_session'), isChecked: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    final lc = AppLocalizations.of(context)!;

    return Container(
      //  height: height*.7,
      margin: EdgeInsets.symmetric(horizontal: width*.04),
      decoration: BoxDecoration(
        color: AppColors.background(context), // 👈 خلفية واضحة للكروت
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCard(
              width: width,
              height: height,
              title: lc.free_personal_ad,
              options: personalOptions,
              buttonText: lc.post_ad,
              onPressed: () {
                // final checkedOptions = personalOptions.where((opt) => opt.isChecked).toList();
                // debugPrint('Checked options: ${checkedOptions.map((e) => e.text).toList()}');
                widget.onPersonalAdPressed();
              },
              icon: "assets/images/plus.svg",
              onOptionToggled: (index) {
                setState(() {
                  personalOptions[index].toggle();
                });
              },
            ),
            SizedBox(height: height*.015),

            _buildCard(
              width: width,
              height: height,
              title: lc.qars_spin_showroom_adv,
              options: showroomOptions,
              buttonText: lc.request_appointment,

              onPressed: () {
                // final checkedOptions = showroomOptions.where((opt) => opt.isChecked).toList();
                // debugPrint('Checked options: ${checkedOptions.map((e) => e.text).toList()}');
                widget.onShowroomAdPressed();
              },
              icon: 'assets/images/calender.svg',
              onOptionToggled: (index) {
                setState(() {
                  //         showroomOptions[index].toggle();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<OptionItem> options,
    required String buttonText,
    required VoidCallback onPressed,
    required double width,
    required double height,
    required String icon,
    required Function(int) onOptionToggled,
  }) {
    return
      Card(
        margin: EdgeInsets.only(top: height*.004), // ✅ يمنع أي فراغ خارجي
        color: AppColors.cardBackground(context),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        clipBehavior: Clip.antiAlias, // 👈 مهم جداً

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5), // هنا الحل، padding للعنوان
              width: double.infinity,
              color: Color(0xff7b7b7b),

              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal:width*.04),
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: height*.01),
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return GestureDetector(
                      onTap: () => onOptionToggled(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 4.2.h,),
                                option.isChecked ?    Icon(
                                  Icons.check_box ,
                                  color:  Color(0xff00ff00),
                                  size: 15.w,
                                ):Container(
                                  margin: EdgeInsets.only(left: width*.003),
                                  color: Colors.black,width: 11.w
                                  ,height:12.h,),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  fontSize: width * 0.034,
                                  //  fontWeight: FontWeight.bold,
                                  color:  AppColors.blackColor(context),
                                  decoration: option.isChecked ? null : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: height*.01),
                  Padding(
                    padding:  EdgeInsets.only(bottom: 10.h),
                    child: Center(
                      child: SizedBox(width: width*.71,
                        height: height*.052,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Color(0xfff6c42d),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          onPressed: onPressed,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                icon,
                                width: width * .053,

                              ),SizedBox(width: width*.02,),
                              Text(buttonText,style: TextStyle(color: Colors.black,fontSize:16.w,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
  }
}