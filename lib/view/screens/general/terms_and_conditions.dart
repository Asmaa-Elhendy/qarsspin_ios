import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../l10n/app_localizations.dart';


class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    // final List<String> paragraphs = const [
    //   "Request to sell a car in our website should be sent by the car Owner or anyone with authorization letter.",
    //   "Request to sell cars for companies or showrooms through the authorized person in that company or showroom.",
    //   "The priority will be given to the cars which have inspection report or to whom are ready to bring their cars to the inspection shop recommend by Qars Spin team.",
    //   "To accept and agree on the terms and conditions Contract shared to you on WhatsApp as the owner of the car or as an authorized person for individual and companies.",
    //   "Qars Spin percent is 1.8% from the Seller and 1.8% from the Buyer (Minimum 1000 QR).",
    //   "In case that Buyer wants a specific inspection for a specific car, payment of the inspection and transferring the car will be paid in advance and Qars Spin team will share the inspection report once it is ready. And in case that the Buyer did not want to buy after the inspection report for any reason, Qars Spin can use the report and post it as an updated inspection report.",
    //   "In the event that a verbal, written, or vocal desire to purchase the car is expressed, Cars Spin is prohibited from continuing with other offers, and the buyer must pay 1.8% of the car's price as a credibility deposit.",
    //   "To buy the car after all parties agreed and sign the contracts, money to be transferred to Qars Spin bank account including the company percent, and after car registration is completed and agreed, the money will be transferred to the Seller's account."
    // ];
    List<String> terms = lc.terms_list.split('|');
    //List<Widget> paragraphWidgets = [];

    // paragraphWidgets.addAll(paragraphs.map((p) {
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
    //     child: Text(
    //       " - $p",
    //       style:  TextStyle(
    //         color: AppColors.blackColor(context),
    //         fontSize: 15,
    //         height: 1.4, // تباعد الأسطر أشبه بالصورة
    //       ),
    //     ),
    //   );
    // }).toList());

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.background(context),
          toolbarHeight: 60.h,
          shadowColor: Colors.grey.shade300,

          elevation: .4,

          title: Text(
            lc.lbl_terms_and_conditions,
            style: TextStyle(
                color: AppColors.blackColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: terms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "- ",
                              style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.blackColor(context)),
                            ),
                            Expanded(
                              child: Text(
                                terms[index],
                                style: TextStyle(height: 1.5,fontFamily: fontFamily,color: AppColors.blackColor(context)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          ],
        ),
      ),

    );
  }
}
