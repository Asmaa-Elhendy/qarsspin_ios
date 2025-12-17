import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controller/ads/ad_getx_controller_create_ad.dart';
import '../../../../controller/ads/data_layer.dart';
import '../../../../controller/const/base_url.dart';
import '../../../../controller/const/colors.dart';
import '../../../../controller/payments/payment_controller.dart';
import '../../../../controller/specs/specs_controller.dart';
import '../../../../controller/specs/specs_data_layer.dart';
import '../../../../l10n/app_localization.dart';
import '../../../screens/my_ads/specs_management.dart';
import '../color_picker_field.dart';
import '../drop_Down_field.dart';
import '../text_field.dart';

class FormFieldsSection extends StatefulWidget {
  final dynamic postData;
  final TextEditingController makeController;
  final TextEditingController classController;
  final TextEditingController modelController;
  final TextEditingController typeController;
  final TextEditingController yearController;
  final TextEditingController warrantyController;

  // final TextEditingController request360Controller;
  // final TextEditingController requestFeatureController;
  final TextEditingController askingPriceController;
  final TextEditingController minimumPriceController;
  final TextEditingController mileageController;
  final TextEditingController plateNumberController;
  final TextEditingController chassisNumberController;
  final TextEditingController descriptionController;
  final TextEditingController fuelTypeController;
  final TextEditingController cylindersController;
  final TextEditingController transmissionController;
  final Color exteriorColor;
  final Color interiorColor;
  final Function(Color) onExteriorColorSelected;
  final Function(Color) onInteriorColorSelected;
  final bool termsAccepted;
  final bool infoConfirmed;
  final bool isRequest360;
  final bool isFeaturedPost;

  final ValueChanged<bool?>? onTermsChanged;
  final ValueChanged<bool?>? onInfoChanged;
  final ValueChanged<bool?>? onReq360Changed;
  final ValueChanged<bool?>? onReqFeaturedChanged;
  final Function({bool shouldPublish}) onValidateAndSubmit;
  final VoidCallback? onUnfocusDescription;
  final String priceReq360Api;
  final String priceFeaturedApi;

  const FormFieldsSection({
    Key? key,
    required this.postData,
    required this.makeController,
    required this.classController,
    required this.modelController,
    required this.typeController,
    required this.yearController,
    required this.warrantyController,

    // required this.request360Controller,
    // required this.requestFeatureController,
    required this.askingPriceController,
    required this.minimumPriceController,
    required this.mileageController,
    required this.plateNumberController,
    required this.chassisNumberController,
    required this.descriptionController,
    required this.exteriorColor,
    required this.interiorColor,
    required this.onExteriorColorSelected,
    required this.onInteriorColorSelected,
    required this.fuelTypeController,
    required this.cylindersController,
    required this.transmissionController,
    required this.termsAccepted,
    required this.infoConfirmed,
    required this.onTermsChanged,
    required this.onInfoChanged,
    required this.isRequest360,
    required this.isFeaturedPost,
    required this.onReq360Changed,
    required this.onReqFeaturedChanged,
    required this.onValidateAndSubmit,
    this.onUnfocusDescription,
    required this.priceReq360Api,
    required this.priceFeaturedApi
  }) : super(key: key);

  @override
  _FormFieldsSectionState createState() => _FormFieldsSectionState();
}

class _FormFieldsSectionState extends State<FormFieldsSection> {
  late SpecsController specsController;
  late FocusNode _descriptionFocusNode;
  String selected_makeID='0';

  bool _isGlobalLoading = false;

  void _showGlobalLoader() {
    if (mounted) {
      setState(() => _isGlobalLoading = true);
    }
  }

  void _hideGlobalLoader() {
    if (mounted) {
      setState(() => _isGlobalLoading = false);
    }
  }

  late AdCleanController brandController;
  String? selectedType;

  // Variables to store results of request 360 service and feature your ad
  bool? request360ServiceResult;
  bool? featureYourAdResult;
  late PaymentController paymentController; // 👈 هنا   to get prices of services

  @override
  void initState() {
    super.initState();

    _descriptionFocusNode = FocusNode();

    specsController = Get.put(
      SpecsController(SpecsDataLayer()),
      tag: 'specs_${0}',
    );
    try {
      brandController = Get.find<AdCleanController>();
      print('AdCleanController found successfully');
      print('Categories count: ${brandController.carCategories.length}');
    } catch (e) {
      print('Error finding AdCleanController: $e');
      // Fallback: create a new instance
      brandController = Get.put(AdCleanController(AdRepository()));
      print('Created new AdCleanController instance');
    }
    // 👇 إضافة PaymentController
    try {
      paymentController = Get.find<PaymentController>();
      print('PaymentController found successfully');
    } catch (e) {
      paymentController = Get.put(PaymentController());
      print('Created new PaymentController instance');
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  /// Method to unfocus the description field
  void unfocusDescription() {
    _descriptionFocusNode.unfocus();
    // Also call the callback if provided
    if (widget.onUnfocusDescription != null) {
      widget.onUnfocusDescription!();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var lc = AppLocalizations.of(context)!;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * .02),

        Text(lc.mandatory_choice, style: TextStyle(fontSize: width * .04)),
        SizedBox(height: height * .01),

        // Make Dropdown
        Obx(
              () => CustomDropDownTyping(
            label: "${lc.choose_make}(*)",
            controller: widget.makeController,
            options: brandController.carBrands.map((b) => b.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
            hintText: lc.choose_make,
            onChanged: (value) {
              final selected = brandController.carBrands.firstWhereOrNull(
                    (b) => b.name == value,
              );

              if (selected != null) {
                brandController.selectedMake.value = selected;
                widget.makeController.text = selected.name;
                log("heee   ${widget.makeController.text}");
                brandController.fetchCarClasses(selected.id.toString());
                 selected_makeID=selected.id.toString();
                widget.classController.clear();
                brandController.selectedClass.value = null;
                setState(() {});
              } else if (value.isEmpty) {
                widget.classController.clear();
                brandController.selectedClass.value = null;
                brandController.carClasses.clear();
                widget.modelController.clear();
                brandController.selectedModel.value = null;
                brandController.carModels.clear();
                setState(() {});
              }
            },
          ),
        ),

        SizedBox(height: height * .01),

        // Class Dropdown
        Obx(() {
          return CustomDropDownTyping(
            label: "${lc.choose_class}(*)",
            controller: widget.classController,
            options: brandController.carClasses.map((c) => c.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
            hintText: "",
            onChanged: (value) {
              final selected = brandController.carClasses.firstWhereOrNull(
                    (c) => c.name == value,
              );
              if (selected != null) {
                brandController.selectedClass.value = selected;
                brandController.fetchCarModels(selected.id.toString(),selected_makeID);
                widget.modelController.clear();
                brandController.selectedModel.value = null;
                setState(() {});
              } else if (value.isEmpty) {
                widget.modelController.clear();
                brandController.selectedModel.value = null;
                brandController.carModels.clear();
                setState(() {});
              }
            },
          );
        }),

        SizedBox(height: height * .01),

        // Model Dropdown
        Obx(() {
          return CustomDropDownTyping(
            label: "${lc.choose_model}(*)",
            controller: widget.modelController,
            options: brandController.carModels.map((m) => m.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
            hintText: "",
            onChanged: (value) {
              final selected = brandController.carModels.firstWhereOrNull(
                    (m) => m.name == value,
              );
              if (selected != null) {
                brandController.selectedModel.value = selected;
              }
            },
          );
        }),

        SizedBox(height: height * .01),

        // Car Type Dropdown - Using dynamic categories from API
        GetBuilder<AdCleanController>(
          id: 'car_categories',
          builder: (controller) {
            print(
              'GetBuilder rebuilding for car categories. Count: ${controller.carCategories.length}',
            );
            print('Loading state: ${controller.isLoadingCategories.value}');
            final categoryOptions =
            controller.carCategories.map((c) => c.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
            print('Category options: $categoryOptions');

            return CustomDropDownTyping(
              label: "${lc.choose_type}(*)",
              controller: widget.typeController,
              options: categoryOptions,
              enableSearch: false,
              hintText: "",
              onChanged: (value) {
                print('Type selected: $value');
                final selected = controller.carCategories.firstWhereOrNull(
                      (c) => c.name == value,
                );
                if (selected != null) {
                  controller.selectedCategory.value = selected;
                  widget.typeController.text = selected.name;
                  setState(() {
                    selectedType = selected.name;
                  });
                  print('Selected category: ${selected.id} - ${selected.name}');
                } else if (value.isEmpty) {
                  controller.selectedCategory.value = null;
                  setState(() {
                    selectedType = null;
                  });
                }
              },
            );
          },
        ),

        SizedBox(height: height * .01),

        // Year Dropdown
        CustomDropDownTyping(
          label: "${lc.manufacture_year}(*)",
          controller: widget.yearController,
          options: List.generate(
            51,
                (index) => (DateTime.now().year + 1 - index).toString(),
          ).toList(),
          enableSearch: false,
          hintText: "",
          onChanged: (value) {
            setState(() {
              // Handle year selection if needed
            });
          },
        ),

        SizedBox(height: height * .01),

        // ce
        CustomTextField(
          fromCreateAd: true,
          controller: widget.askingPriceController,
          label: "${lc.price}(*)",
          keyboardType: TextInputType.number,
          cursorColor: AppColors.brandBlue,
          cursorHeight: 25.h,
          hintText: lc.enter_price,
        ),
        SizedBox(height: height * .01),

        // Minimum Price
        CustomTextField(
          fromCreateAd: true,
          controller: widget.minimumPriceController,
          label: lc.mini_biding_price,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.brandBlue,
          cursorHeight: 25.h,
          hintText: lc.enter_mini_price,
        ),
        SizedBox(height: height * .01),

        // Mileage
        CustomTextField(
          fromCreateAd: true,
          controller: widget.mileageController,
          label: "${lc.mileage}(*)",
          keyboardType: TextInputType.number,
          hintText: lc.enter_mileage,
        ),

        SizedBox(height: height * .01),

        // Exterior Color Picker
        ColorPickerField(
          key: Key('exterior_color_${widget.exteriorColor.hashCode}'),
          label: lc.exterior,
          initialColor: widget.exteriorColor,
          onColorSelected: widget.onExteriorColorSelected,
          isExterior: true, // Show exterior colors
        ),

        SizedBox(height: height * .01),

        // Interior Color Picker
        ColorPickerField(
          key: Key('interior_color_${widget.interiorColor.hashCode}'),
          label: lc.interior,
          initialColor: widget.interiorColor,
          onColorSelected: widget.onInteriorColorSelected,
          isExterior: false, // Show interior colors
        ),
        SizedBox(height: height * .01),

        // Plate Number
        CustomTextField(
          fromCreateAd: true,
          controller: widget.plateNumberController,
          label: lc.plate_number,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.brandBlue,
          cursorHeight: 25.h,
          hintText: lc.enter_plate_number,
        ),
        SizedBox(height: height * .01),

        // Chassis Number
        CustomTextField(
          fromCreateAd: true,
          controller: widget.chassisNumberController,
          label: lc.chassis_number,
          keyboardType: TextInputType.text,
          cursorColor: AppColors.brandBlue,
          cursorHeight: 25.h,
          hintText: lc.enter_chassis,
        ),//l
        SizedBox(height: height * .01),
        widget.postData == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  SizedBox(height: height * .02),
            // Text('Car Specifications',style: TextStyle(fontSize: 15.w,
            //    fontWeight: FontWeight.w500,
            //    color: Colors.black87,)),
            //  SizedBox(height: height * .01),
            // GetBuilder<SpecsController>(
            //   builder: (controller) {
            //     return Column(
            //       children: controller.specsStatic.map((spec) {
            //         return specsContainer( spec, context,controller,_showGlobalLoader,_hideGlobalLoader,true);
            //       }).toList(),
            //     );
            //   },
            // ),
            GetBuilder<SpecsController>(
              builder: (controller) {//kjhتن
                return Column(
                  children: [
                    CustomDropDownTyping(
                      label:
                      Get.locale?.languageCode=='ar'?controller.specsStatic[0].specHeaderSl:controller.specsStatic[0].specHeaderPl+'(*)' ,
                      // 👈 اسم الخيار
                      controller:widget.fuelTypeController,
                      // 👈 كل spec له كنترولر خاص
                      options: List<String>.from(
                        controller.specsStatic[0].options ?? [],
                      ),
                      // 👈 ال options بتاعته
                      enableSearch: false,
                      hintText: lc.select,
                      onChanged: (value) {
                        specsController.updateLocal(specId: specsController.specsStatic[0].specId, specValuePl: widget.fuelTypeController.text);
                        // هنا تعملي أي action على اختيار الـ option
                        //  controller.updateSpec(spec['id'], value);
                      },
                    ),
                    SizedBox(height: height * .01),
                    CustomDropDownTyping(
                      label:
                      Get.locale?.languageCode=='ar'?controller.specsStatic[1].specHeaderSl+'(*)' : controller.specsStatic[1].specHeaderPl+'(*)' ,
                      // 👈 اسم الخيار
                      controller: widget.cylindersController,
                      // 👈 كل spec له كنترولر خاص
                      options: List<String>.from(
                        controller.specsStatic[1].options ?? [],
                      ),
                      // 👈 ال options بتاعته
                      enableSearch: false,
                      hintText: lc.select,
                      onChanged: (value) {
                        specsController.updateLocal(specId: specsController.specsStatic[1].specId, specValuePl: widget.cylindersController.text);

                        // هنا تعملي أي action على اختيار الـ option
                        //  controller.updateSpec(spec['id'], value);
                      },
                    ),
                    SizedBox(height: height * .01),
                    CustomDropDownTyping(
                      label:
                      Get.locale?.languageCode=='ar'?controller.specsStatic[2].specHeaderSl+'(*)' :  controller.specsStatic[2].specHeaderPl +'(*)',
                      // 👈 اسم الخيار
                      controller: widget.transmissionController,
                      // 👈 كل spec له كنترولر خاص
                      options: List<String>.from(
                        controller.specsStatic[2].options ?? [],
                      ),
                      // 👈 ال options بتاعته

                      enableSearch: false,
                      hintText: lc.select,
                      onChanged: (value) {
                        specsController.updateLocal(specId: specsController.specsStatic[2].specId, specValuePl: widget.transmissionController.text);

                        // هنا تعملي أي action على اختيار الـ option
                        //  controller.updateSpec(spec['id'], value);
                      },
                    ),
                    SizedBox(height: height * .01),
                    // CustomDropDownTyping(
                    //   label: controller.specsStatic[0].specHeaderPl ?? "Option",   // 👈 اسم الخيار
                    //   controller: TextEditingController(), // 👈 كل spec له كنترولر خاص
                    //   options: List<String>.from(controller.specsStatic[0].options ?? []), // 👈 ال options بتاعته
                    //   enableSearch: false,
                    //   hintText: "Select",
                    //   onChanged: (value) {
                    //     // هنا تعملي أي action على اختيار الـ option
                    //     //  controller.updateSpec(spec['id'], value);
                    //   },
                    // ),
                  ],
                );
              },
            ),
          ],
        )
            : SizedBox(),

        CustomDropDownTyping(
          label: lc.under_warranty,
          controller: widget.warrantyController,
          options: [lc.value_No, lc.value_Yes],
          enableSearch: false,
          hintText: "",
          onChanged: (value) {
            setState(() {
              // Handle warranty selection if needed
            });
          },
        ),
        SizedBox(height: height * .01),

        Text(
          lc.car_desc,
          style: TextStyle(
            fontSize: 15.w,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor(context),
          ),
        ),
        SizedBox(height: height * .01),

        Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.black, width: 0.3), //update color asmaa
              borderRadius: BorderRadius.circular(5),
              color: AppColors.white
          ),
          child: TextField(
            controller: widget.descriptionController,
            focusNode: _descriptionFocusNode,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              fillColor: AppColors.white,

              border: InputBorder.none,
              hintText: lc.enter_desc,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ),
        SizedBox(height: height * .015),

    //  comment payment for now amira
        widget.postData == null
            ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: widget.isRequest360,
                  onChanged: widget.onReq360Changed,
                  activeColor: Colors.black,
                ),

                Expanded(
                  child:
                   Text(
                      // مثال: "Make 360 (150 QAR) Your Ad ..." حسب النصوص عندك
                      // lc.make_360_first + widget.priceReq360Api + lc.make_360_second,
                     lc.make_360_first ,
                      style: TextStyle(
                        fontSize: 14.4.w,
                        fontWeight: FontWeight.bold,
                      ),
                    )

                ),

              ],
            ),
            SizedBox(height: height * .01),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: widget.isFeaturedPost,
                  onChanged: widget.onReqFeaturedChanged,
                  activeColor: Colors.black,
                ),

                Expanded(
                  child:
                    Text(
                      // lc.pin_ad_first + widget.priceFeaturedApi+ lc.pin_ad_second,
                      lc.pin_ad_first ,

                      style: TextStyle(
                        fontSize: 14.4.w,
                        fontWeight: FontWeight.bold,
                      ),
                    )

                ),

              ],
            ),
          ],
        )
            : SizedBox(),
        Row(
          children: [
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: widget.termsAccepted,
              onChanged: widget.onTermsChanged,
              activeColor: Colors.black,
            ),
            Expanded(
              child: Text(
                lc.agreement,
                style: TextStyle(fontSize: 14.4.w, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        // Info Confirmation Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: widget.infoConfirmed,
              onChanged: widget.onInfoChanged,
              activeColor: Colors.black,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  Text(
                    lc.confirm_info,
                    style: TextStyle(
                      fontSize: 14.4.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: height * .01),

        // Save as draft Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.postData == null
                ? SizedBox(
              width: width * .3,
              height: height * .05,
              child: GestureDetector(
                onTap: () => widget.onValidateAndSubmit(shouldPublish: false),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lc.save_draft,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
                : Expanded(
              child: SizedBox(
                height: height * .05,
                child: GestureDetector(
                  onTap: () => widget.onValidateAndSubmit(shouldPublish: false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.postData['PostStatus'].toString() == "Approved"
                          ? lc.republish
                          : lc.save,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: width * .02),
            widget.postData == null
                ? SizedBox(
              width: width * .54,
              height: height * .05,
              child: GestureDetector(
                onTap: () =>
                    widget.onValidateAndSubmit(shouldPublish: true),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lc.publish,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
                : SizedBox(),
          ],
        ),

        SizedBox(height: 10.h),
        Center(
          child: Text(
            lc.condition_agreement,
            style: TextStyle(fontSize: 12.w),
          ),
        ),
        SizedBox(height: height * .04),
      ],
    );
  }
}