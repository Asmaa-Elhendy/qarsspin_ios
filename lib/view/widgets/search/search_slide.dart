import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/brand_controller.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/model/global_model.dart';

import '../../../controller/notifications_controller.dart';
import '../../../controller/search_controller.dart';
import '../../../l10n/app_localization.dart';
import '../../screens/cars_for_sale/cars_brand_list.dart';
import '../my_ads/yellow_buttons.dart';

class CustomFormSheet extends StatefulWidget {
  String myCase;
  NotificationsController notificationsController;
  CustomFormSheet(this.notificationsController,{required this.myCase, super.key});

  @override
  State<CustomFormSheet> createState() => _CustomFormSheetState();
}

class _CustomFormSheetState extends State<CustomFormSheet> {
  final makeController = TextEditingController();
  final classController = TextEditingController();
  final modelController = TextEditingController();
  final typeController = TextEditingController();
  final fromYearController = TextEditingController();
  final toYearController = TextEditingController();
  final fromPriceController = TextEditingController();
  final toPriceController = TextEditingController();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("my case=${widget.myCase}");
    // Get.find<MySearchController>().fetchCarMakes();
  }

  @override
  void dispose() {
    makeController.dispose();
    classController.dispose();
    modelController.dispose();
    typeController.dispose();
    fromYearController.dispose();
    toYearController.dispose();
    fromPriceController.dispose();
    toPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return GetBuilder<MySearchController>(
      init: MySearchController(), // يضمن أنه يتعمل init مرة واحدة
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: 900.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.mutedGray, width: 1.h),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8).r,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: Padding(

                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 43.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: AppColors.inputBorder,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    18.verticalSpace,
                    Center(child: title(lc.search)),
                    8.verticalSpace,
                    Divider(color: AppColors.darkGray, thickness: .5.h),
                    16.verticalSpace,
                    form(controller,lc), // 👈 مررت نفس الـ controller
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget title(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  Widget form(MySearchController controller,lc) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
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
          35.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10.w,
            children: [
              cancelButton(() {
                Navigator.pop(context, "");
              }, lc.btn_Cancel),
              searchButton(() {
                Navigator.pop(context);//no data

                switch(widget.myCase){
                  case "listCars":
                    Get.find<BrandController>().switchLoading();
                    Get.find<BrandController>().searchCar(
                        make_id: int.parse(selctedMakeId),
                        makeName: makeController.text,
                        classId: selectedClassId,
                        makeId: selctedMakeId,
                        modelId: selectedModelId,
                        yearMin: fromYearController.text.isEmpty?"0":fromYearController.text,
                        yearMax: toYearController.text.isEmpty ? "0" : toYearController.text
                        ,
                        priceMin: fromPriceController.text.isEmpty?"0":fromPriceController.text,
                        priceMax: toPriceController.text.isEmpty?"0":toPriceController.text,
                        catId: selectedTypeId
                    );
                    break;
                  case "makes":
                    Get.find<BrandController>().switchLoading();
                    Get.find<BrandController>().searchCar(
                        make_id: int.parse(selctedMakeId),
                        makeName: makeController.text,
                        classId: selectedClassId,
                        makeId: selctedMakeId,
                        modelId: selectedModelId,
                        yearMin: fromYearController.text.isEmpty?"0":fromYearController.text,
                        yearMax: toYearController.text.isEmpty ? "0" : toYearController.text,
                        priceMin: fromPriceController.text.isEmpty?"0":fromPriceController.text,
                        priceMax: toPriceController.text.isEmpty?"0":toPriceController.text,
                        catId: selectedTypeId
                    );
                    Get.to(CarsBrandList(widget.notificationsController,brandName: makeController.text,postKind:"CarForSale" ,));
                    break;
                  case "Qars spin":
                    Get.find<BrandController>().switchLoading();
                    Get.find<BrandController>().searchCar(
                      make_id: int.parse(selctedMakeId),
                      makeName: makeController.text,
                      classId: selectedClassId,
                      makeId: selctedMakeId,
                      modelId: selectedModelId,
                      yearMin: fromYearController.text.isEmpty?"0":fromYearController.text,
                      yearMax: toYearController.text.isEmpty ? "0" : toYearController.text
                      ,
                      priceMin: fromPriceController.text.isEmpty?"0":fromPriceController.text,
                      priceMax: toPriceController.text.isEmpty?"0":toPriceController.text,
                      catId: selectedTypeId,
                      sourceKind: "Qars spin",

                    );
                    // Get.find<BrandController>().getCars(make_id: 0, makeName: "Qars Spin Showrooms",sourceKind: "Qars spin");
                    Get.to(CarsBrandList(widget.notificationsController,brandName: "Qars Spin \n Showroom",postKind: "",));
                    break;
                  case "Personal Cars":
                    Get.find<BrandController>().switchLoading();
                    Get.find<BrandController>().searchCar(
                        make_id: int.parse(selctedMakeId),
                        makeName: makeController.text,
                        classId: selectedClassId,
                        makeId: selctedMakeId,
                        modelId: selectedModelId,
                        yearMin: fromYearController.text.isEmpty?"0":fromYearController.text,
                        yearMax: toYearController.text.isEmpty ? "0" : toYearController.text,
                        priceMin: fromPriceController.text.isEmpty?"0":fromPriceController.text,
                        priceMax: toPriceController.text.isEmpty?"0":toPriceController.text,
                        catId: selectedTypeId,
                        sourceKind: "Individual"
                    );
                    Get.to(CarsBrandList(widget.notificationsController,brandName: makeController.text,postKind:"CarForSale" ,));

                }


                //
                // if(widget.myCase=="makes"){
                //
                // }
                // selctedMakeId = "";
                // selectedClassId = "";
                // selectedModelId = "";
                // selectedTypeId = "";
              },lc)
            ],
          )
        ],
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
                color: Colors.black,
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
                return TextField(
                  controller: myController,
                  focusNode: focusNode,
                  onChanged: (val) {
                    textController.text = val;
                    textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: textController.text.length),
                    );
                  },
                  decoration: InputDecoration(
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
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
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
              color: Colors.black,
              fontFamily: 'Gilroy',
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          10.verticalSpace,
          SizedBox(
            height: 40.h,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                //labelText: label,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.mutedGray, width: .8.w), // عادي
                ),
                border: const OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.mutedGray),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              cursorColor: AppColors.lightGray,
              cursorWidth: 1,
            ),
          ),
        ],
      ),
    );
  }

  cancelButton(ontap, title) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: 185.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.extraLightGray,
          borderRadius: BorderRadius.circular(4), // optional rounded corners
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget searchButton(onTap,lc) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 185.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4), // optional rounded corners
        ),
        child: Center(
          child: Text(
            lc.search,
            style: TextStyle(
              color: AppColors.black,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
