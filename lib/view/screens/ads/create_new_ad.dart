import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/model/car_category.dart';
import '../../../controller/ads/ad_getx_controller_create_ad.dart';
import '../../../controller/ads/data_layer.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../controller/const/colors.dart';
import '../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../l10n/app_localization.dart';
import '../../widgets/ads/create_ad_widgets/form_fields_section.dart';
import '../../widgets/ads/create_ad_widgets/image_upload_section.dart';
import '../../widgets/ads/create_ad_widgets/validation_methods.dart';
import '../../widgets/ads/dialogs/contact_info_dialog.dart';
import '../../widgets/ads/dialogs/error_dialog.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/ads/dialogs/missing_fields_dialog.dart';
import '../../widgets/ads/dialogs/missing_cover_image_dialog.dart';
import '../../widgets/my_ads/dialog.dart' as dialog;
import '../../widgets/ads/dialogs/success_dialog.dart';
import '../../widgets/ads/create_ad_widgets/ad_submission_service.dart';
import '../../screens/my_ads/my_ads_main_screen.dart';
import '../../widgets/payments/payment_methods_dialog.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../model/payment/payment_initiate_request.dart';
import '../../../model/payment/payment_method_model.dart';

class SellCarScreen extends StatefulWidget {
  final dynamic postData;

  SellCarScreen({this.postData});

  @override
  _SellCarScreenState createState() => _SellCarScreenState();
}

class _SellCarScreenState extends State<SellCarScreen> {
  List<String> _images = [];
  String? _coverImage;//jk
  String? _videoPath;

  // Store listener references
  VoidCallback? _makeListener;
  VoidCallback? _classListener;

  // Track previous values to detect actual clearing vs value changes
  String _previousMakeValue = '';
  String _previousClassValue = '';

  String? selectedMake;
  String? selectedModel;
  String? selectedType;
  String? selectedYear;
  String? selectedClass;
  String? selectedunderWarranty;

  // Loading state for modify mode
  bool _isLoadingModifyData = false;

  Color? _exteriorColor;
  Color? _interiorColor;
  bool _termsAccepted = false;
  bool _infoConfirmed = false;
  bool _isRequest360=false;
  bool _isFeauredPost=false;

  String? _originalExteriorColorHex;
  String? _originalInteriorColorHex;

  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _exteriorColorController = TextEditingController();
  final TextEditingController _interiorColorController = TextEditingController();
  final TextEditingController _askingPriceController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();

  final TextEditingController _minimumPriceController = TextEditingController();
  final TextEditingController _chassisNumberController = TextEditingController();

  //new controllers
  final TextEditingController _make_controller = TextEditingController();
  final TextEditingController _model_controller = TextEditingController();
  final TextEditingController _class_controller = TextEditingController();
  final TextEditingController _type_controller = TextEditingController();
  final TextEditingController _year_controller = TextEditingController();
  final TextEditingController _warranty_controller = TextEditingController();
  // final TextEditingController request360Controller = TextEditingController();
  // final TextEditingController requestFeatureController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController fuelTypeController= TextEditingController();
  final TextEditingController cylindersController= TextEditingController();
  final TextEditingController transmissionController= TextEditingController();

  bool _coverPhotoChanged = false;
  bool _videoChanged = false;
  late PaymentController paymentController; // 👈 هنا   to get prices of services

  final AdCleanController brandController = Get.put(
    AdCleanController(AdRepository()),
  );

  void _handleImageSelected(String imagePath) {
    setState(() {
      _images.add(imagePath);
      // If this is the first image, set it as cover
      if (_images.length == 1 && _coverImage == null) {
        _coverImage = imagePath;
      }
    });


  }

  void _handleVideoSelected(String videoPath) {
    log('Video selected: $videoPath');
    setState(() {
      _videoPath = videoPath;
      _videoChanged = true; // Mark video as changed
      log('Video added. Cover image: $_coverImage');
    });
  }

  void _handleCoverChanged(String? imagePath) {
    if (imagePath != null) {
      setState(() {
        _coverImage = imagePath;
      });
    }
  }

  void _handleImageRemoved(int index) {
    setState(() {
      if (index >= 0 && index < _images.length) {
        String removedImage = _images[index];
        _images.removeAt(index);

        // If we removed the cover image
        if (_coverImage == removedImage) {
          _coverImage = _images.isNotEmpty
              ? _images[0]
              : (_videoPath != null ? _videoPath : null);
        }
      }
      // If we're removing the video
      else if (index == -1 && _videoPath != null) {
        // If the current cover is the video, update it
        if (_coverImage == _videoPath) {
          _coverImage = _images.isNotEmpty ? _images[0] : null;
        }
        _videoPath = null;
      }
    });
  }

  void _populateFieldsFromPostData(dynamic postData) {
    log(' _populateFieldsFromPostData called with data: $postData');

    setState(() {
      // Populate car details from API response

      selectedMake = postData['Make_Name_PL'];
      selectedModel = postData['Model_Name_PL']?.toString();
      selectedYear = postData['Manufacture_Year']?.toString();
      selectedClass = postData['Class_Name_PL']?.toString();
      selectedType = ""; // Default or get from post data if available

      log(' selectedMake: $selectedMake');
      log(' selectedModel: $selectedModel');
      log(' selectedYear: $selectedYear');
      log(' selectedClass: $selectedClass');

      // Populate text controllers with correct API field names
      _mileageController.text = postData['Mileage']?.toString() ?? '';
      _plateNumberController.text = postData['Plate_Number'] ?? '';
      _chassisNumberController.text = postData['Chassis_Number'] ?? '';
      _askingPriceController.text = postData['Asking_Price'] ?? '';
      _minimumPriceController.text = postData['Minimum_Price'] ?? '';



      if (postData['Color_Exterior'] != null) {
        _exteriorColor = Color(int.parse(postData['Color_Exterior'].replaceFirst('#', '0xFF')));
        _originalExteriorColorHex = postData['Color_Exterior'];
        log('✅ Exterior color parsed: $_exteriorColor from ${postData['Color_Exterior']}');
      } else {
        log('❌ Color_Exterior is null in postData');
      }

      if (postData['Color_Interior'] != null) {
        _interiorColor = Color(int.parse(postData['Color_Interior'].replaceFirst('#', '0xFF')));
        _originalInteriorColorHex = postData['Color_Interior'];
        log('✅ Interior color parsed: $_interiorColor from ${postData['Color_Interior']}');
      } else {
        log('❌ Color_Interior is null in postData');
      }



      // Populate warranty with correct API field name
      selectedunderWarranty = (postData['Warranty_isAvailable']?.toString() == '1' || postData['Warranty_isAvailable'] == 1) ? "Yes" : "No";

      // Populate description with correct API field names
      _descriptionController.text = postData['Technical_Description_PL'] ?? postData['Technical_Description_SL'] ?? '';

      // Populate other controllers directly from post data with correct field names
      _make_controller.text = postData['Make_Name_PL'] ?? postData['Make_Name_PL'] ?? '';
      _model_controller.text = postData['Model_Name_PL']?.toString() ?? '';
      _class_controller.text = postData['Class_Name_PL']?.toString() ?? '';
      _year_controller.text = postData['Manufacture_Year']?.toString() ?? '';
      _warranty_controller.text = (postData['Warranty_isAvailable']?.toString() == '1' || postData['Warranty_isAvailable'] == 1) ? "Yes" : "No";

      // Set the type controller directly from post data (for modify mode)
      _type_controller.text = postData['Category_Name_PL']?.toString() ?? '';

      // Find the matching category in the list and set it
      if (_type_controller.text.isNotEmpty) {
        final matchingCategory = brandController.carCategories.firstWhereOrNull(
              (c) => c.name == _type_controller.text,
        );
        if (matchingCategory != null) {
          brandController.selectedCategory.value = matchingCategory;
          log('Category set from post data: ${matchingCategory.name}');
        } else {
          // If category from post data not found in list, keep the text but clear selected cateigory
          brandController.selectedCategory.value = null;
          log('Category from post data not found in list: ${_type_controller.text}');
        }
      } else {
        // Keep empty if post data has empty category
        brandController.selectedCategory.value = null;
        log('Category kept empty as per post data');
      }

      // Load existing image if available
      if (postData['Rectangle_Image_URL'] != null) {
        setState(() {
          _coverImage = postData['Rectangle_Image_URL'];

          // Also add it as the first item in the images list for modify mode
          if (_images.isEmpty) {
            _images.add(postData['Rectangle_Image_URL']);
          } else {
            // If list has items, insert at the beginning
            _images.insert(0, postData['Rectangle_Image_URL']);
          }
        });

        log('Cover image set to: $_coverImage');
        log('Images list updated with Rectangle_Image_URL as first item: $_images');
      }

      // Load gallery images if available
      if (postData['Gallery_Photos'] != null) {
        List<dynamic> galleryPhotos = postData['Gallery_Photos'];
        setState(() {
          for (var photo in galleryPhotos) {
            String photoUrl = photo.toString();
            // Don't add the cover image again if it's already in the gallery
            if (photoUrl != postData['Rectangle_Image_URL'] && !_images.contains(photoUrl)) {
              _images.add(photoUrl);
            }
          }
        });
        log('Gallery images loaded: ${_images.length} total images');
      }

      // Load video if available
      if (postData['Video_URL'] != null) {
        setState(() {
          _videoPath = postData['Video_URL'];
        });
        log('Video loaded: $_videoPath');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // request360Controller.text='No';
    // requestFeatureController.text='No';
    // Check if we're in modify mode with post ID
    if (widget.postData != null && widget.postData['isModifyMode'] == true) {
      // Load post data in the background
      _loadPostDataForModify();
    }
    else if (widget.postData != null) {
      // If we have complete post data, populate the fields (existing behavior)
      _populateFieldsFromPostData(widget.postData!);
    }
    else {
      // Initialize for new ad
      _initializeForNewAd();
    }

    // Add listener to make controller to clear class and model when make is cleared
    _makeListener = () {
      // Only clear if the controller was previously not empty and now is empty
      if (_make_controller.text.isEmpty && _previousMakeValue.isNotEmpty) {
        // Clear class and model when make is cleared
        _class_controller.clear();
        brandController.selectedClass.value = null;
        brandController.carClasses.clear();
        _model_controller.clear();
        brandController.selectedModel.value = null;
        brandController.carModels.clear();
        setState(() {});
      }
      // Update previous value
      _previousMakeValue = _make_controller.text;
    };
    _make_controller.addListener(_makeListener!);

    // Add listener to class controller to clear model when class is cleared
    _classListener = () {
      // Only clear if the controller was previously not empty and now is empty
      if (_class_controller.text.isEmpty && _previousClassValue.isNotEmpty) {
        // Clear model when class is cleared
        _model_controller.clear();
        brandController.selectedModel.value = null;
        brandController.carModels.clear();
        setState(() {});
      }
      // Update previous value
      _previousClassValue = _class_controller.text;
    };
    _class_controller.addListener(_classListener!);
    // 👇 إضافة PaymentController
    try {
      paymentController = Get.find<PaymentController>();
      print('PaymentController found successfully');
    } catch (e) {
      paymentController = Get.put(PaymentController());
      print('Created new PaymentController instance');
    }
  }

  Future<void> _loadPostDataForModify() async {
    final postId = widget.postData?['postId']?.toString();
    final postKind = widget.postData?['postKind'] ?? 'CarForSale';

    if (postId == null) return;

    log('🔍 Starting to load post data for modify mode...');

    // Show loading indicator
    setState(() {
      _isLoadingModifyData = true;
      log('🔍 Loader state set to true');
    });

    // Add a longer delay to ensure the loader is visible
    // await Future.delayed(Duration(milliseconds: 1000));
    // log('🔍 Delay completed, starting API call');

    try {
      // Get the controller and fetch post details
      final myAdController = Get.find<MyAdCleanController>();

      await myAdController.getPostById(
        postKind: postKind,
        postId: postId,
        loggedInUser: widget.postData?['userName'] ?? '', // Get username from postData
      );

      // Check if we got the data successfully
      if (myAdController.postDetails.value != null) {
        log('🔍 Post data loaded successfully for modify mode');
        log('🔍 postDetails.value: ${myAdController.postDetails.value}');

        // Populate the fields with the loaded data
        if (mounted) {
          _populateFieldsFromPostData(myAdController.postDetails.value!);
        }
      } else {
        // Show error message
        if (mounted) {
          Get.snackbar(
            'Error',
            myAdController.postDetailsError.value ?? 'Failed to load post data',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load post data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoadingModifyData = false;
          log('🔍 Loader state set to false');
        });
      }
    }
  }

  void _initializeForNewAd() {
    // New ad creation - clear all controllers and set defaults
    _make_controller.clear();
    _model_controller.clear();
    _class_controller.clear();
    _mileageController.clear();
    _plateNumberController.clear();
    _chassisNumberController.clear();
    _askingPriceController.clear();
    _minimumPriceController.clear();
    _descriptionController.clear();
    _exteriorColorController.clear();
    _interiorColorController.clear();
    fuelTypeController.clear();
    transmissionController.clear();
    cylindersController.clear();

    // Set year to most recent year
    _year_controller.text = (DateTime.now().year + 1).toString();

    // Set warranty default to "No"
    _warranty_controller.text = "No";

    // Wait for categories to load and set type to last category (for new ads only)
    ever(brandController.carCategories, (List<CarCategory> categories) {
      if (categories.isNotEmpty && widget.postData == null) {
        // Only set default for new ads (when postData is null)
        log('Categories loaded in ever() for new ad, count: ${categories.length}');
        log('Last category: ${categories.last.name}');
        _type_controller.text = categories.last.name;
        brandController.selectedCategory.value = categories.last;
        log('Type controller set to: ${_type_controller.text}');
      }
    });

    // Also listen to loading state
    ever(brandController.isLoadingCategories, (bool isLoading) {
      if (!isLoading && brandController.carCategories.isNotEmpty && widget.postData == null) {
        // Only set default for new ads (when postData is null)
        log('Categories finished loading, setting last category for new ad');
        _type_controller.text = brandController.carCategories.last.name;
        brandController.selectedCategory.value = brandController.carCategories.last;
      }
    });

    // Set initial type if categories are already loaded (for new ads only)
    if (brandController.carCategories.isNotEmpty && widget.postData == null) {
      _type_controller.text = brandController.carCategories.last.name;
      brandController.selectedCategory.value = brandController.carCategories.last;
      log('Initial type set to: ${brandController.carCategories.last.name}');
    } else if (widget.postData == null) {
      _type_controller.clear(); // Clear until categories load for new ads
      log('Waiting for categories to load...');
    }

    // Add a delayed check as a fallback (for new ads only)
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && brandController.carCategories.isNotEmpty && _type_controller.text.isEmpty && widget.postData == null) {
        log('Fallback: Setting type after delay for new ad');
        _type_controller.text = brandController.carCategories.last.name;
        brandController.selectedCategory.value = brandController.carCategories.last;
      }
    });

    // Set default colors for new ads
    if (widget.postData == null) {
      _exteriorColor = const Color(0xff800000); // Maroon color
      _interiorColor = const Color(0xff4682B4); // Steel blue color
      print('🎨 [SELL_CAR] Default colors set for new ad: Exterior=Maroon (#800000), Interior=Steel Blue (#4682B4)');
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _exteriorColorController.dispose();
    _interiorColorController.dispose();
    _askingPriceController.dispose();
    _descriptionController.dispose();

    _chassisNumberController.dispose();
    _plateNumberController.dispose();
    // Remove listeners before disposing controllers
    if (_makeListener != null) {
      _make_controller.removeListener(_makeListener!);
    }
    if (_classListener != null) {
      _class_controller.removeListener(_classListener!);
    }

    _make_controller.dispose();
    _model_controller.dispose();
    _class_controller.dispose();
    _type_controller.dispose();
    _year_controller.dispose();
    _warranty_controller.dispose();
    super.dispose();
  }

  /// Validate form and submit ad
  Future<void> _validateAndSubmitForm({bool shouldPublish = false}) async {
    var lc = AppLocalizations.of(context)!;
    // Validate form using validation methods
    bool isValid = ValidationMethods.validateForm(
      postData:widget.postData,
      make: _make_controller.text,
      carClass: _class_controller.text,
      model: _model_controller.text,
      type: _type_controller.text,
      year: _year_controller.text,
      askingPrice: _askingPriceController.text,
      mileage: _mileageController.text,
      description: _descriptionController.text,
      coverImage: _coverImage ?? '',
      termsAccepted: _termsAccepted,
      infoConfirmed: _infoConfirmed,
      isRequest360:_isRequest360,
      isFeaturedPost:_isFeauredPost,
      context: context,
      fuelType:fuelTypeController.text,
      cylinders:cylindersController.text,
      transmission:transmissionController.text,
      showMissingFieldsDialog: _showMissingFieldsAlert,
      showMissingCoverImageDialog: _showMissingCoverImageAlert,
    );

    if (!isValid) return;

    // Validate numeric fields
    bool numericValid = ValidationMethods.validateNumericFields(
      askingPrice: _askingPriceController.text,
      minimumPrice: _minimumPriceController.text,
      mileage: _mileageController.text,
      plateNumber: _plateNumberController.text,
      chassisNumber: _chassisNumberController.text,
      context: context,
      showErrorDialog: _showErrorAlert,
    );

    if (!numericValid) return;

    // Validate manufacture year
    bool yearValid = ValidationMethods.validateManufactureYear(
      year: _year_controller.text,
      context: context,
      showErrorDialog: _showErrorAlert,
    );

    if (!yearValid) return;

    // Submit the ad using the service
    //handle add post with payment
    // if (_isRequest360 || _isFeauredPost) {
    //   final paymentController = Get.find<PaymentController>();
    //
    //   double amount = 0;
    //
    //   _isRequest360 ? amount +=  paymentController.request360ServicePrice! : null;
    //   _isFeauredPost ? amount += paymentController.featuredServicePrice! : null;
    //
    //   // 1) Collect contact info (dialog closes immediately and returns data only)
    //
    //   final contactInfo = await ContactInfoDialog.show(
    //     req360Amount: paymentController.request360ServicePrice!,
    //     featuredAmount: paymentController.featuredServicePrice!,
    //     totalAmount:amount,
    //     context: context,
    //     isRequest360: _isRequest360,
    //     isFeauredPost: _isFeauredPost,
    //   );
    //
    //   if (contactInfo == null) {
    //     // user cancelled contact info
    //   } else
    //   {
    //     try {
    //       // 2) Initiate payment using contact info
    //       final paymentController = Get.find<PaymentController>();
    //       final String customerName = '${(contactInfo['firstName'] ?? '').toString().trim()} ${(contactInfo['lastName'] ?? '').toString().trim()}'.trim();
    //       final String email = (contactInfo['email'] ?? '').toString().trim();
    //       final String mobile = (contactInfo['mobile'] ?? '').toString().trim();
    //         List<int> selectedServiceIDs=[];
    //         if(_isRequest360){
    //           selectedServiceIDs.add(paymentController.request360ServiceId!);
    //         }
    //         if(_isFeauredPost){
    //           selectedServiceIDs.add(paymentController.featuredServiceId!);
    //         }
    //       final result = await paymentController.initiatePayment(
    //         postId: ad.postId,
    //         serviceIds:selectedServiceIDs,
    //         externalUser: Get.find<AuthController>().userName!,
    //         amount: amount,
    //         customerName: customerName.isEmpty ? 'Customer' : customerName,
    //         email: email,
    //         mobile: mobile,
    //       );
    //       log('Payment Initiation Result: $result');
    //
    //       if (result?['IsSuccess'] == true &&
    //           result?['Data'] != null &&
    //           result?['Data']['PaymentMethods'] != null) {
    //         // 3) Map methods and open NewPaymentMethodsDialog
    //         final List<dynamic> methodsRaw = List<dynamic>.from(result!['Data']['PaymentMethods'] as List);
    //         final methods = methodsRaw
    //             .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
    //             .toList();
    //
    //         final userInformationRequest = PaymentInitiateRequest(
    //           postId: postId,
    //           qarsServiceIds: selectedServiceIDs,
    //           amount: amount,
    //           customerName: customerName.isEmpty ? 'Customer' : customerName,
    //           email: email,
    //           mobile: mobile,
    //         );
    //
    //         final methodsPayload = await NewPaymentMethodsDialog.show(
    //           context: context,
    //           paymentMethods: methods,
    //           userInformationRequest: userInformationRequest,
    //           isArabic: Get.locale?.languageCode == 'ar',
    //         );
    //
    //         if (methodsPayload != null) {
    //           Map<String, dynamic>? normalized;
    //           final invoice = methodsPayload['invoice'] as Map<String, dynamic>?;
    //           if (invoice != null) {
    //             final invoiceResult = await InvoiceLinkDialog.show(
    //               context: context,
    //               invoiceId: (invoice['invoiceId'] ?? '').toString(),
    //               paymentId: (invoice['paymentId'])?.toString(),
    //               paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
    //               isArabic: (invoice['isArabic'] == true),
    //             );
    //             normalized = invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
    //           } else {
    //             normalized = methodsPayload['normalizedResult'] as Map<String, dynamic>?;
    //           }
    //
    //           final status = normalized?['status']?.toString();
    //           final paymentId = normalized?['paymentId']?.toString();
    //           final bool success = (status != null && status.toLowerCase() == 'success') || (paymentId != null && paymentId.isNotEmpty);
    //
    //           if (success) {
    //             dialog.SuccessDialog.show(
    //               request: true,
    //               context: context,
    //               title: lc.paymentSucceeded,
    //               message: lc.paymentWasCompleted,
    //               onClose: () { Navigator.pop(context); },
    //               onTappp: () { Navigator.pop(context); },
    //             );
    //             _submitAd(shouldPublish: shouldPublish);
    //           } else
    //           {
    //             dialog.SuccessDialog.show(
    //               request: true,
    //               context: context,
    //               title: lc.payment_failed,
    //               message: lc.paymentWasNotCompleted,
    //               onClose: () { },
    //               onTappp: () { Navigator.pop(context); },
    //             );
    //           }
    //         }
    //       }
    //       else {
    //         dialog.SuccessDialog.show(
    //           request: true,
    //           context: context,
    //           title: lc.payment_failed,
    //           message: (result?['Message'] ?? lc.failedToLoadPaymentMethods).toString(),
    //           onClose: () { Navigator.pop(context); },
    //           onTappp: () { Navigator.pop(context); },
    //         );
    //       }
    //     } catch (e, st) {
    //       log('Payment flow error: $e');
    //       log('Stack: $st');
    //       dialog.SuccessDialog.show(
    //         request: true,
    //         context: context,
    //         title: lc.payment_failed,
    //         message: '${lc.paymentflowfailed} $e',
    //         onClose: () { Navigator.pop(context); },
    //         onTappp: () { Navigator.pop(context); },
    //       );
    //     }
    //   }
    // }
    // else {
      _submitAd(shouldPublish: shouldPublish);//handle add post without payment
  //  }
  }

  /// Show alert for missing fields
  void _showMissingFieldsAlert(String message) {
    MissingFieldsDialog.show(context, [message]);
  }

  /// Show alert for missing cover image
  void _showMissingCoverImageAlert() {
    MissingCoverImageDialog.show(context);
  }

  /// Show loading dialog
  void _showLoadingDialog() {
    LoadingDialog.show(context, isModifyMode: widget.postData != null);
  }

  /// Hide loading dialog
  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Show success dialog
  void _showSuccessDialog(String message, String postId, {bool isPublished = false}) {
    SuccessDialog.show(
      context,
      postId,
      _navigateToMyAds,
      isModifyMode: widget.postData != null,
      isPublished: isPublished,
    );
  }

  /// Show error dialog
  void _showErrorAlert(String message) {
    ErrorDialog.show(
      context,
      message,
          () {
        Navigator.pop(context);
      },
      isModifyMode: widget.postData != null,
    );
  }

  /// Reset all form fields and state
  void _resetForm() {
    // Clear all text controllers
    _make_controller.clear();
    _model_controller.clear();
    _class_controller.clear();
    _type_controller.clear();
    _year_controller.clear();
    _warranty_controller.clear();
    _mileageController.clear();
    _plateNumberController.clear();
    _chassisNumberController.clear();
    _askingPriceController.clear();
    _minimumPriceController.clear();
    _descriptionController.clear();
    fuelTypeController.clear();
    transmissionController.clear();
    cylindersController.clear();

    // Reset other state variables
    setState(() {
      // Clear all images and reset cover image
      _images = []; // Create a new empty list to ensure UI updates
      _coverImage = null;
      _videoPath = null;
      _exteriorColor = const Color(0xff800000); // Reset to default maroon
      _interiorColor = const Color(0xff4682B4); // Reset to default steel blue
      _termsAccepted = false;
      _infoConfirmed = false;
      _isRequest360 = false;
      _isFeauredPost = false;
      _coverPhotoChanged = false;
      _videoChanged = false;

      // Force a rebuild of the image upload section
      _images = [];
    });

    // Reset selected values
    selectedMake = null;
    selectedModel = null;
    selectedType = null;
    selectedYear = null;
    selectedClass = null;
    selectedunderWarranty = null;

    // Reset the brand controller state
    brandController.resetCreateAdState();

    // Reset the form for new ad
    _initializeForNewAd();
  }

  /// Navigate to MyAds screen
  void _navigateToMyAds() {
    // Reset all form fields and state
    _resetForm();

    // Navigate to MyAds screen
    Get.off(() => const MyAdsMainScreen());

    // Refresh My Ads screen
    final auth = Get.find<AuthController>();
    if (auth.userName != null && auth.userName!.isNotEmpty) {
      Get.find<MyAdCleanController>().fetchMyAds(userName: auth.userFullName!, ourSecret: ourSecret);
    }
  }

  /// Unfocus description field to prevent auto-focus
  void _unfocusDescription() {
    FocusScope.of(context).unfocus();
  }

  /// Submit ad to API
  void _submitAd({bool shouldPublish = false}) async {
    // Log the submission
    AdSubmissionService.logAdSubmission(
      make: _make_controller.text,
      carClass: _class_controller.text,
      model: _model_controller.text,
      type: _type_controller.text,
      year: _year_controller.text,
      askingPrice: _askingPriceController.text,
      imageCount: _images.length,
      hasVideo: _videoPath != null && _videoPath!.isNotEmpty,
    );

    // Check if we're in modify mode
    final String? postId = widget.postData?['ID']?.toString() ?? widget.postData?['postId']?.toString();

    if (postId != null && postId.isNotEmpty) {
      // Update mode
      log("beeeeeeeeeeeeeee  ${widget.postData['PostStatus']}");
      await AdSubmissionService.updateAd(
        PostStaus:widget.postData['PostStatus'],
        context: context,
        images: _images,
        coverImage: _coverImage ?? '',
        videoPath: _videoPath,
        make: _make_controller.text,
        carClass: _class_controller.text,
        model: _model_controller.text,
        type: _type_controller.text,
        year: _year_controller.text,
        warranty: _warranty_controller.text,
        askingPrice: _askingPriceController.text,
        minimumPrice: _minimumPriceController.text,
        mileage: _mileageController.text,
        plateNumber: _plateNumberController.text,
        chassisNumber: _chassisNumberController.text,
        description: _descriptionController.text,
        exteriorColor: _exteriorColor ?? Colors.white,
        interiorColor: _interiorColor ?? Colors.white,
        postId: postId,
        coverPhotoChanged: _coverPhotoChanged,
        videoChanged: _videoChanged,
        shouldPublish: shouldPublish,
        showLoadingDialog: _showLoadingDialog,
        showSuccessDialog: _showSuccessDialog,
        showErrorDialog: _showErrorAlert,
        hideLoadingDialog: _hideLoadingDialog,
      );
    } else {
      // Create mode
      await AdSubmissionService.submitAd(
        // request360controller: request360Controller,
        // featureyouradcontroller: requestFeatureController,
        isRequest360:_isRequest360,
        isFeaturedPost:_isFeauredPost,
        shouldPublish: shouldPublish,
        context: context,
        images: _images,
        coverImage: _coverImage ?? '',
        videoPath: _videoPath,
        make: _make_controller.text,
        carClass: _class_controller.text,
        model: _model_controller.text,
        type: _type_controller.text,
        year: _year_controller.text,
        warranty: _warranty_controller.text,
        askingPrice: _askingPriceController.text,
        minimumPrice: _minimumPriceController.text,
        mileage: _mileageController.text,
        plateNumber: _plateNumberController.text,
        chassisNumber: _chassisNumberController.text,
        description: _descriptionController.text,
        exteriorColor: _exteriorColor ?? Colors.white,
        interiorColor: _interiorColor ?? Colors.white,
        videoChanged: _videoChanged,
        showLoadingDialog: _showLoadingDialog,
        showSuccessDialog: _showSuccessDialog,
        showErrorDialog: _showErrorAlert,
        hideLoadingDialog: _hideLoadingDialog,
        navigateToMyAds: _navigateToMyAds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var lc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();

        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),

        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.background(context),
          toolbarHeight: 60.h,
          shadowColor: Colors.grey.shade300,
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
          elevation: 0, // نشيل الشادو الافتراضي

          title: Text(
            widget.postData != null ? lc.modify_car : lc.sell_car,
            style: TextStyle(
              color: AppColors.blackColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * .06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section
                        ImageUploadSection(
                          images: _images,
                          coverImage: _coverImage,
                          videoPath: _videoPath,
                          onImageSelected: _handleImageSelected,
                          onVideoSelected: _handleVideoSelected,
                          onCoverChanged: _handleCoverChanged,
                          onImageRemoved: (index) => _handleImageRemoved(index),
                          isModifyMode: widget.postData != null,
                          onCoverPhotoChanged: (bool changed) {
                            setState(() {
                              _coverPhotoChanged = changed;
                            });
                          },
                          onVideoChanged: (bool changed) {
                            setState(() {
                              _videoChanged = changed;
                            });
                          },
                        ),

                        // // Form Fields Section - Debug logs
                        // Builder(
                        //   builder: (context) {
                        //     log('🎨 Passing colors to FormFieldsSection:');
                        //     log('🎨 _exteriorColor: $_exteriorColor');
                        //     log('🎨 _interiorColor: $_interiorColor');
                        //     log('🎨 exteriorColor parameter: ${_exteriorColor ?? Colors.white}');
                        //     log('🎨 interiorColor parameter: ${_interiorColor ?? Colors.white}');
                        //     return SizedBox.shrink(); // Return empty widget
                        //   },
                        // ),

                        Obx(() {
                          final service360 = paymentController.individualQarsServices
                              .firstWhereOrNull((s) => s.qarsServiceName == 'Request to 360');

                          final priceText360 = service360 != null
                              ? ' ${service360.qarsServicePrice} '
                              : ' ';
                          final featureService = paymentController.individualQarsServices
                              .firstWhereOrNull((s) => s.qarsServiceName == 'Request to feature');

                          final priceTextFeatured = featureService != null
                              ? ' ${featureService.qarsServicePrice} '
                              : ' ';
                          return FormFieldsSection(postData: widget.postData,
                            // request360Controller: request360Controller,
                            // requestFeatureController:requestFeatureController ,
                            isRequest360: _isRequest360,
                            isFeaturedPost: _isFeauredPost,
                            makeController: _make_controller,
                            classController: _class_controller,
                            modelController: _model_controller,
                            typeController: _type_controller,
                            yearController: _year_controller,
                            warrantyController: _warranty_controller,
                            askingPriceController: _askingPriceController,
                            minimumPriceController: _minimumPriceController,
                            mileageController: _mileageController,
                            plateNumberController: _plateNumberController,
                            chassisNumberController: _chassisNumberController,
                            descriptionController: _descriptionController,
                            exteriorColor: _exteriorColor ?? Colors.white,
                            interiorColor: _interiorColor ?? Colors.white,
                            fuelTypeController: fuelTypeController,
                            transmissionController: transmissionController,
                            cylindersController: cylindersController,
                            onExteriorColorSelected: (color) {
                              setState(() { //kتن
                                _exteriorColor = color;
                                log(color.hashCode.toString());
                              });
                            },
                            onInteriorColorSelected: (color) {
                              setState(() {
                                _interiorColor = color;
                                log(color.hashCode.toString());
                              });
                            },
                            termsAccepted: _termsAccepted,
                            infoConfirmed: _infoConfirmed,
                            onTermsChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _termsAccepted = value;
                                });
                              }
                            },
                            onInfoChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _infoConfirmed = value;
                                });
                              }
                            },
                            onReq360Changed: (value) {
                              if (_isRequest360) {
                                if (value != null) {
                                  setState(() {
                                    _isRequest360 = value;
                                    log("36000000 $_isRequest360");
                                  });
                                }
                              }
                              else {
                                dialog.SuccessDialog.show(
                                  request: false,
                                  context: context,
                                  title: lc.ready_pro,
                                  message: lc.msg_360_first+' ${priceText360} '+lc.msg_360_second,
                                  onClose: () {},
                                  onTappp: () async {
                                    Navigator.pop(context);
                                    if (value != null) {
                                      setState(() {
                                        _isRequest360 = value;
                                      });
                                    }
                                  },

                                );
                              }
                            },
                            onReqFeaturedChanged: (value) {
                              if (_isFeauredPost) {
                                if (value != null) {
                                  setState(() {
                                    _isFeauredPost = value;
                                  });
                                }
                              }
                              else {
                                dialog.SuccessDialog.show(
                                  request: false,
                                  context: context,
                                  title: lc.centered_ad,
                                  message:lc.feature_ad_msg_first+' $priceTextFeatured '+lc.feature_ad_msg_second,
                                  onClose: () {},
                                  onTappp: () async {
                                    Navigator.pop(context);
                                    if (value != null) {
                                      setState(() {
                                        _isFeauredPost = value;
                                      });
                                    }
                                  },
                                );
                              }
                            },
                            // priceReq360Api: priceText360,
                            // priceFeaturedApi: priceTextFeatured,
                            onValidateAndSubmit: _validateAndSubmitForm,
                            onUnfocusDescription: _unfocusDescription,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay for modify mode
            if (_isLoadingModifyData)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: AppLoadingWidget(
                    title: lc.loading_car_data,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}