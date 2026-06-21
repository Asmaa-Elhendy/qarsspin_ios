import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/car_model.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';
import 'package:qarsspin/view/widgets/texts/texts.dart';

import '../../controller/brand_controller.dart';
import '../../controller/calculate_loan.dart' as loan_calc;
import '../../controller/const/colors.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/car_details/slider.dart';
import '../widgets/car_details/snack_bar.dart';


class GetLoan extends StatefulWidget {
  CarModel car;
   GetLoan({required this.car,super.key});

  @override
  State<GetLoan> createState() => _GetLoanState();
}

class _GetLoanState extends State<GetLoan> {
  bool firstChecked = false;
  bool secondChecked = false;
  bool calcMode = false;

  final TextEditingController _offerController = TextEditingController();
  final monthsNotifier = ValueNotifier<int>(6);

  double _monthlyPayment = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;

  List<Map<String, dynamic>> _amortizationSchedule = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offerController.text="";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _offerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),

        centerTitle: true, // يخلي العنوان في نص العرض
        elevation: 0, // نشيل الشادو الافتراضي
        leading:  GestureDetector(
          onTap: () {
            Navigator.pop(context); // go back
          },
          child: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.blackColor(context),
            size: 30.w,
          ),
        ),
        title: Text(
          lc.get_loan,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.w700,
            fontFamily: fontFamily,
            fontSize: 16.sp,
          ),
        ),
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
        padding: EdgeInsets.symmetric(horizontal: 22.w,vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            blueText("${lc.ad_code}: ${widget.car.postCode}"),
            8.verticalSpace,
            headerText(Get.locale?.languageCode=='ar'?widget.car.carNameSl:widget.car.carNamePl,context),
            8.verticalSpace,
            description(Get.locale?.languageCode=='ar'?widget.car.technical_Description_SL:widget.car.description,small: true,context: context),
            8.verticalSpace,
            price("${lc.price}: ${widget.car.askingPrice} ${lc.currency_Symbol}",small:true),
            14.verticalSpace,
            Divider(color: AppColors.black,thickness: .5.h,),
            8.verticalSpace,
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w),
              child: calcMode?calculateMode(lc)
                  :Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lc.describe_your_self,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor(context)
                    ),
                  ),
                  8.verticalSpace,
                  Padding(padding: EdgeInsets.symmetric(horizontal: 14.w),

                  child: twoCheckBox(lc),
                  ),
                  24.verticalSpace,
                  Text(
                    lc.down_payment,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor(context)
                    ),
                  ),
                  8.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(

                            border: Border.all(color: AppColors.inputBorder),
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: TextField(
                            controller: _offerController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center, // 👈 center text inside TextField
                            style: TextStyle(
                              fontFamily: fontFamily,fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: AppColors.black
                            ),

                            decoration: InputDecoration(
                              hintText: "",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 40.h,
                        width: 65.w,
                        padding:  EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.inputBorder,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Center(
                          child:  Text(
                           lc.currency_Symbol,
                            style: TextStyle(fontSize: 16.sp,
                              color: AppColors.black,
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.w700,),
                          ),
                        ),
                      ),
                    ],
                  ),
                  35.verticalSpace,
                  Text(
                    lc.loan_installments,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor(context)
                    ),
                  ),
                  12.verticalSpace,
                  LoanInstallmentsSlider(monthsNotifier: monthsNotifier,),
                  35.verticalSpace,
                  GestureDetector(
                    onTap: (){
                      _calculateLoan(lc);
                      setState(() {
                        calcMode = true;
                      });
                    },
                    child: Container(

                      width: double.infinity,
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6.r),

                      ),
                      child: Center(
                        child:Text(lc.calculate,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: fontFamily
                        ),
                        ),
                      ),
                    ),
                  )


                ],
              ),
            )



          ],
        ),
      ),
    );
  }
  Widget twoCheckBox(lc){
    return Column(
      children: [
        customCheckboxTile(
          title: lc.qatari_national,
          checked: firstChecked,
          onChanged: (value) {
            setState(() {
              if(value) {
                firstChecked = value;
                secondChecked = !firstChecked;
              }
            });
          },
        ),
        customCheckboxTile(
          title: lc.resident_qatar,
          checked: secondChecked,
          onChanged: (value) {
            setState(() {
              if(value) {
                secondChecked = value;
                firstChecked = !secondChecked;
              }
            });
          },
        ),
      ],
    );

  }
  Widget customCheckboxTile({
    required String title,
    required bool checked,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Row(
        children: [
          // Custom checkbox using image
          checked
              ? Image.asset(
            "assets/images/select.png",
            width: 24.w,
            height: 24.h,
            color: AppColors.blackColor(context),

          )
              : Image.asset(
            "assets/images/unselect.png",
            width: 24.w,
            height: 24.h,
            color: AppColors.blackColor(context),
          ),
          4.horizontalSpace,
          Text(
            title,
            style:  TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
  Widget calculateMode(lc){
    // double annualInterestRate = 5.0; // Default 5% if not provided
    // final monthlyRate = (annualInterestRate / 12) / 100;
    // final rateFactor = pow(1 + monthlyRate, termInMonths).toDouble();
    // final monthlyPayment = principal * (monthlyRate * rateFactor) / (rateFactor - 1);
    // double totalPayment = monthlyPayment * termInMonths;

    // loanAmount = Car Price - Down Payment
    // Monthly Payment = loanAmount * ((annualRate / 12 / 100) * (1 + (annualRate / 12 / 100))^monthsNotifier.value) / ((1 + r)^monthsNotifier.value - 1)

    double value = double.parse(widget.car.askingPrice)/monthsNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        containerWithValue(lc.legal_status, firstChecked?lc.qatari_national:lc.resident_qatar),
        containerWithValue(lc.down_payment, "${_offerController.text==""?"-":_offerController.text} ${lc.currency_Symbol}"),
        containerWithValue(lc.loan_installments_count, "${monthsNotifier.value} ${lc.month_number}"),
        containerWithValue(lc.loan_installments, " ${_monthlyPayment} ${lc.currency_Symbol}"),
        containerWithValue(lc.total_loan_value, " ${_totalPayment} ${lc.currency_Symbol}"),
        22.verticalSpace,
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.w),
          child:         hintText(lc.loan_figure,context),

        ),

        16.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12.w,
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  calcMode = false;
                });
              },
              child: Container(
                width: 180.w,
                height: 55.h,
                decoration: BoxDecoration(
                  color:AppColors.textSecondary(context),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(lc.re_calculate,

                    style: TextStyle(
                      color: AppColors.black,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),

                ),
              ),
            ),
            InkWell(
              onTap: ()async{
                bool check = false;
                if(firstChecked||secondChecked){
                  check = true;
                }else{
                  false;
                }
                setState(() {

                });


                double value = double.parse(widget.car.askingPrice)/monthsNotifier.value;

                setState(() {
                  calcMode = false;
                });
                String code =  await Get.find<BrandController>().buyWithLoan(downPayment: _offerController.text, installmentsCount: "${_monthlyPayment}", nationality: firstChecked?"I Am Qatari National":"I Am A Resident In Qatar");
                code=="OK"?  showSuccessSnackBar(context,lc.request_success):
                showSuccessSnackBar(context,lc.wnt_wrg);

              },
              child: Container(
                width: 180.w,
                height: 55.h,
                decoration: BoxDecoration(
                  color:AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(lc.btn_Send_Request,

                    style: TextStyle(
                      color: AppColors.black,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),

                ),
              ),
            )

          ],
        )






      ],
    );
  }
  Widget containerWithValue(title,value){
    return Padding(
      padding:  EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontFamily: fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700
          ),),
      8.verticalSpace,
      Container(
      height: 40.h,
      decoration: BoxDecoration(

      border: Border.all(color: AppColors.inputBorder),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Text(value,
          style: TextStyle(
              color: AppColors.black,
              fontFamily: fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700
          ),),
      ),
      )

        ],
      ),
    );
  }

  void _calculateLoan(lc) {
    final price = double.tryParse(widget.car.askingPrice) ?? 0;
    final downPayment = double.tryParse(_offerController.text) ?? 0;
    final term = monthsNotifier.value ?? 48;
    final rate = 5.0;

    final principal = price - downPayment;

    if (principal <= 0) {
      // Show error if principal is 0 or negative
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(lc.invalid_loan)),
      );
      return;
    }

    // Calculate everything
    final monthlyPayment = loan_calc.LoanCalculator.calculateMonthlyPayment(
      principal,
      rate,
      term,
    );

    final totalPayment = loan_calc.LoanCalculator.calculateTotalPayment(
      monthlyPayment,
      term,
    );

    final totalInterest = loan_calc.LoanCalculator.calculateTotalInterest(
      principal,
      totalPayment,
    );

    // Generate the schedule
    final schedule = loan_calc.LoanCalculator.generateAmortizationSchedule(
      principal,
      rate,
      term,
    );

    // Update the state
    setState(() {
      _monthlyPayment = double.parse(monthlyPayment.toStringAsFixed(2));
      _totalPayment = double.parse(totalPayment.toStringAsFixed(2));
      _totalInterest = double.parse(totalInterest.toStringAsFixed(2));
      _amortizationSchedule = schedule; // This updates the schedule

      // Debug print to verify
      debugPrint('Schedule generated with ${_amortizationSchedule.length} payments');
      if (_amortizationSchedule.isNotEmpty) {
        debugPrint('First payment: ${_amortizationSchedule[0]}');
      }
    });
  }}

