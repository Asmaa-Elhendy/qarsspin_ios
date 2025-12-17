import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/view/widgets/car_details/snack_bar.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';

import '../../../controller/auth/auth_controller.dart';
import '../../../controller/search_controller.dart';
import '../../../l10n/app_localization.dart';
import '../../../model/global_model.dart';
import '../../widgets/auth_widgets/register_dialog.dart';

class FindMeACar extends StatefulWidget {
  const FindMeACar({super.key});

  @override
  State<FindMeACar> createState() => _FindMeACarState();
}

class _FindMeACarState extends State<FindMeACar> {
  final makeController = TextEditingController();
  final classController = TextEditingController();
  final modelController = TextEditingController();
  final typeController = TextEditingController();
  final fromYearController = TextEditingController();
  final toYearController = TextEditingController();
  final fromPriceController = TextEditingController();
  final toPriceController = TextEditingController();
  final commentController = TextEditingController();
  String selctedMakeId = "0";
  String selectedClassId = "0";
  String selectedModelId = "0";
  String selectedTypeId = "0";
  List<GlobalModel> years = List.generate(
    30,
        (index) {
      final year = (2024 - index).toString();
      return GlobalModel(id: int.parse(year), name: year);
    },
  );
  List<GlobalModel> makes = [];
  List<GlobalModel> classes = [];
  List<GlobalModel> types = [];
  List<GlobalModel> models = [];


  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: GetBuilder<MySearchController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 88.h, // same as your AppBar height
                    padding: EdgeInsets.only(top: 13.h,left: 14.w),
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
                    child: Row(


                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // go back
                          },
                          child: Icon(
                            Icons.arrow_back_outlined,
                            color: AppColors.blackColor(context),
                            size: 30.w,
                          ),
                        ),
                        130.horizontalSpace,
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                lc.find_me_car,
                                style: TextStyle(
                                  color: AppColors.blackColor(context),
                                  fontFamily: 'Gilroy',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              //
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.verticalSpace,
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child:  Text(
                      lc.find_car_notify,
                      style: TextStyle(
                        color: AppColors.blackColor(context),
                        fontFamily: 'Gilroy',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  24.verticalSpace,
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8.w),

                    child: Container(
                      height: .7.h,
                      decoration: BoxDecoration(
                        color: AppColors.divider(context),

                      ),
                    ),
                  ),
                  20.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        buildSearchableDropdown(
                          viewLabel:lc.choose_make,
                          label: "Choose Make",
                          items: controller.makes,
                          myController: makeController,
                          searchController: controller, // مررت الكنترولر هنا
                        ),
                        buildSearchableDropdown(
                          key: ValueKey(controller.classes.length), // 👈 key مرتبطة بالقائمة
                          viewLabel: lc.choose_class,
                          label: "Choose Class",

                          items: controller.classes,
                          myController: classController,
                          searchController: controller,
                        ),
                        buildSearchableDropdown(
                          viewLabel: lc.choose_model,
                          label: "Choose Model",
                          items: controller.models,
                          myController: modelController,
                          searchController: controller,
                          key: ValueKey(controller.models.length),
                        ),
                        buildSearchableDropdown(
                          viewLabel: lc.choose_type,
                          label: "Choose Type",
                          items: controller.types,
                          myController: typeController,
                          searchController: controller,
                          key: ValueKey(controller.types.length),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 30.w,
                          children: [
                            Expanded(
                              child: buildSearchableDropdown(
                                  viewLabel: lc.from_year,
                                  label: "From Year",
                                  items: years,
                                  myController: fromYearController,
                                  searchController: controller),
                            ),
                            Expanded(
                              child: buildSearchableDropdown(
                                  viewLabel: lc.to_year,
                                  label: "To Year",
                                  items: years,
                                  myController: toYearController,
                                  searchController: controller),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 30.w,
                          children: [
                            Expanded(
                              child: buildTextField(lc.from_price, fromPriceController,
                                  keyboardType: TextInputType.number),
                            ),
                            Expanded(
                              child: buildTextField(lc.to_price, toPriceController,
                                  keyboardType: TextInputType.number),
                            ),


                          ],
                        ),
                        50.verticalSpace,
                        buildLargeTextField(lc,lc.any_comment, commentController,
                            keyboardType: TextInputType.number),
                        20.verticalSpace,
                        yellowButtons(title: lc.active_notification, onTap: (){
                          final authController = Get.find<AuthController>();

                          if(authController.registered){
                            controller.findMeACar(makeId: selctedMakeId, classId: selectedClassId, modelId: selectedModelId, categoryId: selectedTypeId,  fromYear: fromYearController.text.isEmpty?"0":fromYearController.text,
                              toYear: toYearController.text.isEmpty ? "0" : toYearController.text,
                              minPrice: fromPriceController.text.isEmpty?"0":fromPriceController.text,
                              maxPrice: toPriceController.text.isEmpty?"0":toPriceController.text,);
                            Get.back();
                            showSuccessSnackBar(context, lc.success_request);
                          }else{
                            showDialog(
                              context: context,
                              builder: (_) => RegisterDialog(),
                            );

                          }

                        }, w: double.infinity,context: context),
                        40.verticalSpace


                      ],
                    ),
                  )



                ],
              ),
            );
          }
      ),
    );
  }
  Widget buildSearchableDropdown({
    required String label,
    required String viewLabel,

    required List<GlobalModel> items,
    required TextEditingController myController,
    required MySearchController searchController,
    Key? key, // 👈 دعم الـ key// 👈 الكنترولر الأساسي
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(viewLabel,
              style: TextStyle(
                color: AppColors.blackColor(context),
                fontFamily: 'Gilroy',
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              )),
          10.verticalSpace,
          SizedBox(
            height: 45.h,
            child: TypeAheadField<GlobalModel>(
              key: key, // 👈 هنا

              suggestionsCallback: (pattern) async {
                return items
                    .where((car) =>
                    car.name.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              builder: (context, textController, focusNode) {
                return Container(
                  color: AppColors.white,
                  child: TextField(
                    controller: myController,
                    focusNode: focusNode,
                    onChanged: (val) {
                      textController.text = val;
                      textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: textController.text.length),
                      );
                    },
                    decoration: InputDecoration(
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(
                          color: AppColors.mutedGray,
                          width: .8.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(3), borderSide: BorderSide( color: AppColors.mutedGray, width: .8.w, ), ),
                      suffixIcon: const Icon( Icons.arrow_drop_down_outlined, color: Colors.black, ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 6.w),
                    ),
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                    ),
                  ),
                );
              },
              itemBuilder: (context, suggestion) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                child: Text(
                  suggestion.name,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w300,
                    color: AppColors.mutedGray,
                  ),
                ),
              ),
              onSelected: (suggestion) {
                myController.text = suggestion.name;
                debugPrint("label is: [$label]");

                switch (label) {
                  case "Choose Make":
                    searchController.fetchClasses(suggestion.id);
                    classController.clear();
                    modelController.clear();
                    typeController.clear();
                    selctedMakeId = suggestion.id.toString();
                    break;

                  case "Choose Class":
                    searchController.fetchModels(suggestion.id,selctedMakeId);
                    modelController.clear();
                    typeController.clear();
                    selectedClassId = suggestion.id.toString();
                    break;

                  case "Choose Model":
                    selectedModelId = suggestion.id.toString();
                    break;

                  case "Choose Type":
                    selectedTypeId = suggestion.id.toString();
                    break;
                }
              },
              decorationBuilder: (context, child) {
                return Container(
                  height: 230.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  /// 🔹 Function to build normal TextField
  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.blackColor(context),
              fontFamily: 'Gilroy',
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          10.verticalSpace,
          Container(
            height: 40.h,
            color: AppColors.white,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                  color: AppColors.black,
                  fontFamily: fontFamily
              ),
              decoration: InputDecoration(
                //labelText: label,
                fillColor: AppColors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: AppColors.mutedGray, width: .8.w), // عادي
                ),
                border: const OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.mutedGray),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              cursorColor: AppColors.lightGrayColor(context),
              cursorWidth: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLargeTextField(lc,String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.blackColor(context),
              fontFamily: 'Gilroy',
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          10.verticalSpace,
          Container(
            height: 140.h,
            color: Colors.white,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,

              maxLines: null,
              minLines: 10,
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
              ),

              decoration: InputDecoration(
                fillColor: AppColors.white,
                hintText: lc.comment_hint, // 👈 الهنت
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: AppColors.inputBorder,
                    width: .6.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: AppColors.mutedGray, width: .8.w), // عادي
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 6.w,
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }
}
