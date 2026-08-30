import 'dart:io';
import 'dart:ui' show PathMetric, PathMetrics;

import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../controller/ads/ad_getx_controller_create_ad.dart';
import '../../../controller/ads/data_layer.dart';
import '../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../controller/payments/payment_controller.dart';
import '../../../controller/specs/specs_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/car_category.dart';
import '../../widgets/ads/car_photo_cropper.dart';
import '../../widgets/my_ads/color_picker_dialog.dart' show ColorData;
import '../../widgets/ads/create_ad_widgets/ad_submission_service.dart';
import '../../widgets/ads/create_ad_widgets/validation_methods.dart';
import '../../widgets/ads/dialogs/error_dialog.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import '../../widgets/ads/dialogs/missing_cover_image_dialog.dart';
import '../../widgets/ads/dialogs/missing_fields_dialog.dart';
import '../../widgets/ads/dialogs/success_dialog.dart';
import '../home_screen.dart';
import '../my_ads/my_ads_main_screen.dart';
import 'sell_your_car_summary.dart';

/// Alternate, modern-styled version of the Sell-Your-Car / Edit-Ad screen.
///
/// This file is a **UI-only redesign** — it deliberately reuses every
/// controller, service call, validation method, and submission path the
/// original [SellCarScreen] (`create_new_ad.dart`) already relies on, so
/// business logic is byte-identical. Only the visual composition changes:
/// grouped card sections, a hero cover photo, chip-based body-type,
/// icon-tile specs, boost cards, and a sticky bottom CTA.
///
/// The original screen file is **untouched** — this is a parallel entry
/// point that can be swapped in for demoing the new look without any
/// risk of regressing the current production flow. Push either widget
/// from the caller (e.g. `Get.to(() => SellYourCarV2())`) to compare.
class SellYourCarV2 extends StatefulWidget {
  final dynamic postData;

  SellYourCarV2({this.postData});

  @override
  State<SellYourCarV2> createState() => _SellYourCarV2State();
}

class _SellYourCarV2State extends State<SellYourCarV2> {
  // ────────────────────────────────────────────────────────────────────
  // STATE — mirrored exactly from `create_new_ad.dart`
  // `_SellCarScreenState`. Logic, defaults, and lifecycle behave the
  // same; only the rendering in `build()` changes.
  // ────────────────────────────────────────────────────────────────────

  final List<String> _images = <String>[];
  String? _coverImage;
  String? _videoPath;

  VoidCallback? _makeListener;
  VoidCallback? _classListener;
  String _previousMakeValue = '';
  String _previousClassValue = '';

  bool _isLoadingModifyData = false;

  Color? _exteriorColor;
  Color? _interiorColor;
  // Dedicated text controllers for the two color TypeAhead tiles, so
  // the "typed value" is decoupled from the committed `_exteriorColor`
  // / `_interiorColor`. Kept as fields so the display name persists
  // across rebuilds (edit mode prefill sets these too).
  final TextEditingController _exteriorColorController =
      TextEditingController();
  final TextEditingController _interiorColorController =
      TextEditingController();
  bool _termsAccepted = false;
  bool _infoConfirmed = false;
  bool _isRequest360 = false;
  bool _isFeauredPost = false;

  bool _coverPhotoChanged = false;
  bool _videoChanged = false;

  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _askingPriceController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _minimumPriceController = TextEditingController();
  final TextEditingController _chassisNumberController = TextEditingController();
  final TextEditingController _make_controller = TextEditingController();
  final TextEditingController _model_controller = TextEditingController();
  final TextEditingController _class_controller = TextEditingController();
  final TextEditingController _type_controller = TextEditingController();
  final TextEditingController _year_controller = TextEditingController();
  final TextEditingController _warranty_controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();
  final TextEditingController cylindersController = TextEditingController();
  final TextEditingController transmissionController = TextEditingController();

  late PaymentController paymentController;

  final AdCleanController brandController = Get.put(
    AdCleanController(AdRepository()),
  );

  // Mirrors the top-level `selected_makeID` variable used by the
  // original `FormFieldsSection` when it fetches car models — needed
  // as the second arg to `brandController.fetchCarModels(...)`.
  String _selectedMakeId = '';

  /// Live status text shown under the loading dialog title.
  final ValueNotifier<String> _loadingStatus = ValueNotifier<String>('');

  // ────────────────────────────────────────────────────────────────────
  // LIFECYCLE — same as the original screen. Payment controller,
  // dependent-field listeners, and post-data population all replicate
  // the production behavior.
  // ────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    if (widget.postData != null && widget.postData['isModifyMode'] == true) {
      _loadPostDataForModify();
    } else if (widget.postData != null) {
      _populateFieldsFromPostData(widget.postData!);
    } else {
      _initializeForNewAd();
    }

    _makeListener = () {
      if (_make_controller.text.isEmpty && _previousMakeValue.isNotEmpty) {
        _class_controller.clear();
        brandController.selectedClass.value = null;
        brandController.carClasses.clear();
        _model_controller.clear();
        brandController.selectedModel.value = null;
        brandController.carModels.clear();
        setState(() {});
      }
      _previousMakeValue = _make_controller.text;
    };
    _make_controller.addListener(_makeListener!);

    _classListener = () {
      if (_class_controller.text.isEmpty && _previousClassValue.isNotEmpty) {
        _model_controller.clear();
        brandController.selectedModel.value = null;
        brandController.carModels.clear();
        setState(() {});
      }
      _previousClassValue = _class_controller.text;
    };
    _class_controller.addListener(_classListener!);

    try {
      paymentController = Get.find<PaymentController>();
    } catch (_) {
      paymentController = Get.put(PaymentController());
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _askingPriceController.dispose();
    _descriptionController.dispose();
    _chassisNumberController.dispose();
    _plateNumberController.dispose();
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
    _exteriorColorController.dispose();
    _interiorColorController.dispose();
    _loadingStatus.dispose();
    super.dispose();
  }

  void _initializeForNewAd() {
    _make_controller.clear();
    _model_controller.clear();
    _class_controller.clear();
    _mileageController.clear();
    _plateNumberController.clear();
    _chassisNumberController.clear();
    _askingPriceController.clear();
    _minimumPriceController.clear();
    _descriptionController.clear();
    fuelTypeController.clear();
    transmissionController.clear();
    cylindersController.clear();

    _year_controller.text = (DateTime.now().year + 1).toString();
    _warranty_controller.text = 'No';

    // Safety: if the AdCleanController was created earlier and the
    // initial fetchCarCategories failed / never populated, force one
    // more attempt so the Body-type chips actually show. The
    // controller's onInit only runs the first time it's Get.put, so
    // returning to this screen with an empty list would leave the
    // chips permanently blank without this.
    if (brandController.carCategories.isEmpty) {
      brandController.fetchCarCategories();
    }

    ever(brandController.carCategories, (List<CarCategory> categories) {
      // Force a parent rebuild when the async fetch fills the list,
      // so the Body-type chips render immediately even without an
      // Obx wrapper. (Obx observation on RxList had version-specific
      // quirks — a plain setState here is the reliable path.)
      if (mounted) setState(() {});
      if (categories.isNotEmpty && widget.postData == null) {
        _type_controller.text = categories.last.name;
        brandController.selectedCategory.value = categories.last;
      }
    });

    ever(brandController.isLoadingCategories, (bool isLoading) {
      if (!isLoading &&
          brandController.carCategories.isNotEmpty &&
          widget.postData == null) {
        _type_controller.text = brandController.carCategories.last.name;
        brandController.selectedCategory.value =
            brandController.carCategories.last;
      }
    });

    if (brandController.carCategories.isNotEmpty && widget.postData == null) {
      _type_controller.text = brandController.carCategories.last.name;
      brandController.selectedCategory.value =
          brandController.carCategories.last;
    } else if (widget.postData == null) {
      _type_controller.clear();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted &&
          brandController.carCategories.isNotEmpty &&
          _type_controller.text.isEmpty &&
          widget.postData == null) {
        _type_controller.text = brandController.carCategories.last.name;
        brandController.selectedCategory.value =
            brandController.carCategories.last;
      }
    });
  }

  Future<void> _loadPostDataForModify() async {
    final postId = widget.postData?['postId']?.toString();
    final postKind = widget.postData?['postKind'] ?? 'CarForSale';
    if (postId == null) return;

    setState(() => _isLoadingModifyData = true);

    try {
      final myAdController = Get.find<MyAdCleanController>();
      await myAdController.getPostById(
        postKind: postKind,
        postId: postId,
        loggedInUser: widget.postData?['userName'] ?? '',
      );

      if (myAdController.postDetails.value != null && mounted) {
        _populateFieldsFromPostData(myAdController.postDetails.value!);
      } else if (mounted) {
        Get.snackbar(
          'Error',
          myAdController.postDetailsError.value ?? 'Failed to load post data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load post data: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingModifyData = false);
    }
  }

  void _populateFieldsFromPostData(dynamic postData) {
    setState(() {
      _mileageController.text = postData['Mileage']?.toString() ?? '';
      _plateNumberController.text = postData['Plate_Number'] ?? '';
      _chassisNumberController.text = postData['Chassis_Number'] ?? '';
      _askingPriceController.text = postData['Asking_Price'] ?? '';
      _minimumPriceController.text = postData['Minimum_Price'] ?? '';
      _descriptionController.text = postData['Technical_Description_PL']
          ?? postData['Technical_Description_SL']
          ?? '';

      if (postData['Color_Exterior'] != null) {
        _exteriorColor = Color(
          int.parse(postData['Color_Exterior'].replaceFirst('#', '0xFF')),
        );
        // Backfill the tile's display name from the catalog so the
        // TypeAhead field shows the color name (e.g. "Pearl White")
        // instead of the raw hex when entering edit mode.
        final match = _allColors.firstWhereOrNull(
            (c) => c.isExterior && c.color == _exteriorColor);
        if (match != null) {
          _exteriorColorController.text =
              Get.locale?.languageCode == 'ar' ? match.nameSL : match.namePL;
        }
      }
      if (postData['Color_Interior'] != null) {
        _interiorColor = Color(
          int.parse(postData['Color_Interior'].replaceFirst('#', '0xFF')),
        );
        final match = _allColors.firstWhereOrNull(
            (c) => !c.isExterior && c.color == _interiorColor);
        if (match != null) {
          _interiorColorController.text =
              Get.locale?.languageCode == 'ar' ? match.nameSL : match.namePL;
        }
      }

      _warranty_controller.text =
          (postData['Warranty_isAvailable']?.toString() == '1' ||
                  postData['Warranty_isAvailable'] == 1)
              ? 'Yes'
              : 'No';

      _make_controller.text = postData['Make_Name_PL'] ?? '';
      _model_controller.text = postData['Model_Name_PL']?.toString() ?? '';
      _class_controller.text = postData['Class_Name_PL']?.toString() ?? '';
      _year_controller.text = postData['Manufacture_Year']?.toString() ?? '';
      _type_controller.text = postData['Category_Name_PL']?.toString() ?? '';

      if (_type_controller.text.isNotEmpty) {
        final matchingCategory = brandController.carCategories.firstWhereOrNull(
          (c) => c.name == _type_controller.text,
        );
        brandController.selectedCategory.value = matchingCategory;
      }

      if (postData['Rectangle_Image_URL'] != null) {
        _coverImage = postData['Rectangle_Image_URL'];
        if (_images.isEmpty) {
          _images.add(postData['Rectangle_Image_URL']);
        } else {
          _images.insert(0, postData['Rectangle_Image_URL']);
        }
      }

      if (postData['Gallery_Photos'] != null) {
        final List<dynamic> galleryPhotos = postData['Gallery_Photos'];
        for (final photo in galleryPhotos) {
          final String photoUrl = photo.toString();
          if (photoUrl != postData['Rectangle_Image_URL'] &&
              !_images.contains(photoUrl)) {
            _images.add(photoUrl);
          }
        }
      }

      if (postData['Video_URL'] != null) {
        _videoPath = postData['Video_URL'];
      }
    });
  }

  // ────────────────────────────────────────────────────────────────────
  // VALIDATION + SUBMISSION — identical to the original.
  // ────────────────────────────────────────────────────────────────────

  /// Runs the full field-validation pipeline. Returns `true` only if
  /// every check passes (missing-fields, terms/accuracy, numeric,
  /// manufacture-year). Kept as a separate helper so the create flow
  /// can validate BEFORE navigating to the summary, and the edit
  /// flow / summary buttons can validate again right before submit.
  bool _runValidation() {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    final AdCleanController brandController = Get.find<AdCleanController>();
    final bool makeSelected = brandController.selectedMake.value != null;
    final bool classSelected = brandController.selectedClass.value != null;
    final bool modelSelected = brandController.selectedModel.value != null;
    final bool categorySelected =
        brandController.selectedCategory.value != null;
    final bool isCreate = widget.postData == null;
    final List<String> missing = <String>[];
    // Missing-fields dialog reads better when each entry is just the
    // field name (Make / Class / Model / …) — the surrounding "Please
    // fill in the following required fields:" already reads as an
    // instruction, so prefixing every item with "Choose"/"Select"
    // duplicates the imperative. We build the list with bare labels
    // here instead of reusing the `lc.choose_*` strings that other
    // parts of the app use as headings.
    if (_make_controller.text.isEmpty || !makeSelected) {
      missing.add(lc.v2_field_make);
    }
    if (_class_controller.text.isEmpty || !classSelected) {
      missing.add(lc.v2_field_class);
    }
    if (_model_controller.text.isEmpty || !modelSelected) {
      missing.add(lc.v2_field_model);
    }
    if (_type_controller.text.isEmpty || !categorySelected) {
      missing.add(lc.v2_body_type_label);
    }
    if (_year_controller.text.isEmpty) missing.add(lc.v2_field_year);
    if (_askingPriceController.text.isEmpty) {
      missing.add(lc.v2_field_asking_price);
    }
    if (_mileageController.text.isEmpty) missing.add(lc.mileage);
    if (_exteriorColor == null) missing.add(lc.v2_field_exterior_color);
    if (_interiorColor == null) missing.add(lc.v2_field_interior_color);
    if (isCreate) {
      if (fuelTypeController.text.isEmpty) missing.add(lc.v2_field_fuel);
      if (cylindersController.text.isEmpty) {
        missing.add(lc.v2_field_cylinders);
      }
      if (transmissionController.text.isEmpty) {
        missing.add(lc.v2_field_transmission);
      }
    }
    // Include Terms + Info in the SAME missing-fields dialog so the
    // user sees every unchecked item at once. The shared
    // `ValidationMethods.validateForm` returns after the first
    // failing check, so passing them through it would only surface
    // one at a time (which the user flagged as confusing).
    if (!_termsAccepted) missing.add(lc.v2_terms_missing);
    if (!_infoConfirmed) missing.add(lc.v2_info_missing);
    if (missing.isNotEmpty) {
      MissingFieldsDialog.show(context, missing);
      return false;
    }
    // Cover image gets its own dedicated dialog (different from the
    // generic missing-fields list) — keep that path via
    // ValidationMethods, but pass `termsAccepted: true` and
    // `infoConfirmed: true` since we already checked those above.
    final bool isValid = ValidationMethods.validateForm(
      coverImage: _coverImage ?? '',
      termsAccepted: true,
      infoConfirmed: true,
      context: context,
      termsMessage: lc.please_accept_terms_msg,
      accuracyMessage: lc.please_confirm_accuracy_msg,
      showMissingFieldsDialog: (fields) =>
          MissingFieldsDialog.show(context, fields),
      showMissingCoverImageDialog: () =>
          MissingCoverImageDialog.show(context),
    );
    if (!isValid) return false;
    final bool numericValid = ValidationMethods.validateNumericFields(
      askingPrice: _askingPriceController.text,
      minimumPrice: _minimumPriceController.text,
      mileage: _mileageController.text,
      plateNumber: _plateNumberController.text,
      chassisNumber: _chassisNumberController.text,
      context: context,
      showErrorDialog: _showErrorAlert,
    );
    if (!numericValid) return false;
    final bool yearValid = ValidationMethods.validateManufactureYear(
      year: _year_controller.text,
      context: context,
      showErrorDialog: _showErrorAlert,
    );
    if (!yearValid) return false;
    return true;
  }

  Future<void> _validateAndSubmitForm({bool shouldPublish = false}) async {
    if (!_runValidation()) return;
    _submitAd(shouldPublish: shouldPublish);
  }

  /// Create-flow only: validate the form, and if it passes, push the
  /// Summary page. The summary shows a preview and hosts the actual
  /// Save-as-draft / Publish buttons — nothing is submitted until the
  /// user taps one of those.
  Future<void> _openSummaryFromCreate() async {
    if (!_runValidation()) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellYourCarSummary(
          coverImage: _coverImage,
          make: _make_controller.text,
          carClass: _class_controller.text,
          model: _model_controller.text,
          year: _year_controller.text,
          mileage: _mileageController.text,
          exteriorColor: _exteriorColor,
          // The color TypeAhead tile stores the display name in the
          // controller's text buffer after the user picks — reuse
          // that so the summary shows "Pearl White" / "أبيض" etc.
          exteriorColorName: _exteriorColorController.text.isEmpty
              ? null
              : _exteriorColorController.text,
          askingPrice: _askingPriceController.text,
          isRequest360: _isRequest360,
          isFeaturedPost: _isFeauredPost,
          onSaveAsDraft: () {
            Navigator.of(context).pop();
            _submitAd(shouldPublish: false);
          },
          onPublish: () {
            Navigator.of(context).pop();
            _submitAd(shouldPublish: true);
          },
        ),
      ),
    );
  }

  void _submitAd({bool shouldPublish = false}) async {
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

    final String? postId = widget.postData?['ID']?.toString()
        ?? widget.postData?['postId']?.toString();

    if (postId != null && postId.isNotEmpty) {
      await AdSubmissionService.updateAd(
        PostStaus: widget.postData['PostStatus'],
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
        updateLoadingStatus: _updateLoadingStatus,
        navigateToMyAds: _navigateToMyAds,
      );
    } else {
      await AdSubmissionService.submitAd(
        isRequest360: _isRequest360,
        isFeaturedPost: _isFeauredPost,
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
        updateLoadingStatus: _updateLoadingStatus,
        navigateToMyAds: _navigateToMyAds,
      );
    }
  }

  void _navigateToMyAds() {
    Get.offAll(() =>  HomeScreen()); // أو اسند الـ Route الخاص بالرئيسية لديك
    // 2. فتح شاشة الإعلانات فوق الرئيسية
    Get.to(() => const MyAdsMainScreen());
  }

  void _showErrorAlert(String message) =>
      ErrorDialog.show(context, message, null);


  void _showLoadingDialog() {
    _loadingStatus.value = '';
    showDialog(
      // ✅ استخدام Get.context لضمان الربط بأعلى شاشة في الـ Navigation Stack
      context: Get.context ?? context,
      barrierDismissible: false,
      builder: (_) => Center( // ✅ يضمن التوسيط الكامل رأسياً وأفقياً
        child: Material(
          color: Colors.transparent,
          child: ValueListenableBuilder<String>(
            valueListenable: _loadingStatus,
            builder: (_, value, __) => AppLoadingWidget(title: value),
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    // ✅ إغلاق آمن للدايالوج لمنع إغلاق الشاشات الخاطئة
    if (Get.isDialogOpen == true) {
      Get.back();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _loadingStatus.value = '';
  }
  void _updateLoadingStatus(String s) => _loadingStatus.value = s;

  void _showSuccessDialog(String message, String postId,
      {bool isPublished = false}) {
    SuccessDialog.show(context, postId, null);
  }

  // ────────────────────────────────────────────────────────────────────
  // UI — the new design. Everything below is presentation-only.
  // ────────────────────────────────────────────────────────────────────

  // Brand color never changes across themes — it's the identity.
  static const Color _brand = Color(0xFFF2C230);

  // Theme-aware color roles — resolved lazily against
  // `Theme.of(context).brightness`. Old form used the same pattern
  // via `AppColors.blackColor(context)` etc., so the redesigned page
  // now flips cleanly when the user toggles Dark mode instead of
  // staying stuck on the light palette.
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  /// Primary text color. Black on light, white on dark.
  Color get _ink => _isDark ? Colors.white : const Color(0xFF0F0F0F);

  /// Page background — a soft warm off-white on light, deep grey on
  /// dark. Reads as a hairline divider between the white/dark
  /// section blocks stacked on top of it.
  Color get _pageBg =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEFEDE7);

  /// Section card background — white on light, dark grey on dark.
  Color get _sectionBg =>
      _isDark ? const Color(0xFF2C2C2C) : Colors.white;

  /// Subtle border color between inputs / tiles.
  Color get _borderColor =>
      _isDark ? const Color(0xFF404040) : const Color(0xFFE5E5E5);

  /// Color catalog — mirrors the list baked into `ColorPickerField`
  /// (kept in sync manually since v2 uses its own presentation but the
  /// same catalog + hex codes).
  static final List<ColorData> _allColors = <ColorData>[
    // Exterior
    ColorData(colorId: 1, hexCode: '#FFFFFF', namePL: 'White', nameSL: 'أبيض', isExterior: true, displayOrder: 1),
    ColorData(colorId: 2, hexCode: '#000000', namePL: 'Black', nameSL: 'أسود', isExterior: true, displayOrder: 2),
    ColorData(colorId: 3, hexCode: '#C0C0C0', namePL: 'Silver', nameSL: 'فضي', isExterior: true, displayOrder: 3),
    ColorData(colorId: 4, hexCode: '#808080', namePL: 'Gray', nameSL: 'رمادي', isExterior: true, displayOrder: 4),
    ColorData(colorId: 5, hexCode: '#FF0000', namePL: 'Red', nameSL: 'أحمر', isExterior: true, displayOrder: 5),
    ColorData(colorId: 6, hexCode: '#800000', namePL: 'Maroon', nameSL: 'عنابي', isExterior: true, displayOrder: 6),
    ColorData(colorId: 7, hexCode: '#FFFF00', namePL: 'Yellow', nameSL: 'أصفر', isExterior: true, displayOrder: 7),
    ColorData(colorId: 8, hexCode: '#808000', namePL: 'Olive', nameSL: 'زيتوني', isExterior: true, displayOrder: 8),
    ColorData(colorId: 9, hexCode: '#00FF00', namePL: 'Lime', nameSL: 'ليموني', isExterior: true, displayOrder: 9),
    ColorData(colorId: 10, hexCode: '#008000', namePL: 'Green', nameSL: 'أخضر', isExterior: true, displayOrder: 10),
    ColorData(colorId: 11, hexCode: '#00FFFF', namePL: 'Cyan', nameSL: 'سماوي', isExterior: true, displayOrder: 11),
    ColorData(colorId: 12, hexCode: '#008080', namePL: 'Teal', nameSL: 'تركوازي', isExterior: true, displayOrder: 12),
    ColorData(colorId: 13, hexCode: '#0000FF', namePL: 'Blue', nameSL: 'أزرق', isExterior: true, displayOrder: 13),
    ColorData(colorId: 14, hexCode: '#000080', namePL: 'Navy', nameSL: 'كحلي', isExterior: true, displayOrder: 14),
    ColorData(colorId: 15, hexCode: '#FF00FF', namePL: 'Magenta', nameSL: 'وردي فاتح', isExterior: true, displayOrder: 15),
    ColorData(colorId: 16, hexCode: '#800080', namePL: 'Purple', nameSL: 'أرجواني', isExterior: true, displayOrder: 16),
    ColorData(colorId: 17, hexCode: '#D2691E', namePL: 'Brown', nameSL: 'بني', isExterior: true, displayOrder: 17),
    ColorData(colorId: 18, hexCode: '#F5DEB3', namePL: 'Beige', nameSL: 'بيج', isExterior: true, displayOrder: 18),
    ColorData(colorId: 19, hexCode: '#FF4500', namePL: 'Orange', nameSL: 'برتقالي', isExterior: true, displayOrder: 19),
    ColorData(colorId: 20, hexCode: '#A52A2A', namePL: 'Dark Brown', nameSL: 'بني غامق', isExterior: true, displayOrder: 20),
    ColorData(colorId: 21, hexCode: '#E6E6FA', namePL: 'Lavender', nameSL: 'لافندر', isExterior: true, displayOrder: 21),
    ColorData(colorId: 22, hexCode: '#FA8072', namePL: 'Salmon', nameSL: 'مرجاني', isExterior: true, displayOrder: 22),
    ColorData(colorId: 23, hexCode: '#2F4F4F', namePL: 'Dark Slate Gray', nameSL: 'رمادي أردوازي غامق', isExterior: true, displayOrder: 23),
    ColorData(colorId: 24, hexCode: '#4682B4', namePL: 'Steel Blue', nameSL: 'أزرق فولاذي', isExterior: true, displayOrder: 24),
    // Interior
    ColorData(colorId: 25, hexCode: '#FFFFFF', namePL: 'White', nameSL: 'أبيض', isExterior: false, displayOrder: 1),
    ColorData(colorId: 26, hexCode: '#000000', namePL: 'Black', nameSL: 'أسود', isExterior: false, displayOrder: 2),
    ColorData(colorId: 27, hexCode: '#C0C0C0', namePL: 'Silver', nameSL: 'فضي', isExterior: false, displayOrder: 3),
    ColorData(colorId: 28, hexCode: '#808080', namePL: 'Gray', nameSL: 'رمادي', isExterior: false, displayOrder: 4),
    ColorData(colorId: 29, hexCode: '#D2691E', namePL: 'Brown', nameSL: 'بني', isExterior: false, displayOrder: 5),
    ColorData(colorId: 30, hexCode: '#F5DEB3', namePL: 'Beige', nameSL: 'بيج', isExterior: false, displayOrder: 6),
    ColorData(colorId: 31, hexCode: '#8B4513', namePL: 'Saddle Brown', nameSL: 'بني سرج', isExterior: false, displayOrder: 7),
    ColorData(colorId: 32, hexCode: '#A52A2A', namePL: 'Dark Brown', nameSL: 'بني غامق', isExterior: false, displayOrder: 8),
    ColorData(colorId: 33, hexCode: '#FAEBD7', namePL: 'Antique White', nameSL: 'أبيض قديم', isExterior: false, displayOrder: 9),
    ColorData(colorId: 34, hexCode: '#FFF5EE', namePL: 'Seashell', nameSL: 'صدفي', isExterior: false, displayOrder: 10),
    ColorData(colorId: 35, hexCode: '#2F4F4F', namePL: 'Dark Slate Gray', nameSL: 'رمادي أردوازي غامق', isExterior: false, displayOrder: 11),
    ColorData(colorId: 36, hexCode: '#708090', namePL: 'Slate Gray', nameSL: 'رمادي أردوازي', isExterior: false, displayOrder: 12),
    ColorData(colorId: 37, hexCode: '#4682B4', namePL: 'Steel Blue', nameSL: 'أزرق فولاذي', isExterior: false, displayOrder: 13),
    ColorData(colorId: 38, hexCode: '#778899', namePL: 'Light Slate Gray', nameSL: 'رمادي أردوازي فاتح', isExterior: false, displayOrder: 14),
    ColorData(colorId: 39, hexCode: '#B0C4DE', namePL: 'Light Steel Blue', nameSL: 'أزرق فولاذي فاتح', isExterior: false, displayOrder: 15),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    // Edit-mode loader: matches the "My Advertisements" page look —
    // `AppLoadingWidget(title: 'Loading...')` on a soft black scrim.
    // The header still renders so the screen reads as "Sell Your Car"
    // in-context (not a modal blank), but we skip building the heavy
    // form tree while `_loadPostDataForModify()` runs to keep the
    // perceived load time snappy.
    if (_isLoadingModifyData) {
      return Scaffold(
        backgroundColor: _pageBg,
        body: Container(
          color: Colors.black.withOpacity(0.2),
          child: const SafeArea(
            child: Center(
              child: AppLoadingWidget(title: 'Loading...'),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      // Tapping anywhere outside a text field dismisses the keyboard —
      // matches the original SellCarScreen behavior.
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotosSection(),
                    // Thin page-color strip between sections — reads
                    // as a soft gray divider without needing an
                    // explicit border line.
                    SizedBox(height: 8.h),
                    _buildVehicleSection(),
                    SizedBox(height: 8.h),
                    _buildPriceSection(),
                    SizedBox(height: 8.h),
                    _buildSpecsSection(),
                    // Boost section is create-only. Old
                    // form_fields_section.dart:574 wrapped the entire
                    // 360°/Featured checkboxes block in
                    // `postData == null ? Column(...) : SizedBox()`
                    // so it never appeared in edit mode; we do the
                    // same here.
                    if (widget.postData == null) ...[
                      SizedBox(height: 8.h),
                      _buildBoostSection(),
                    ],
                    SizedBox(height: 8.h),
                    _buildConsentSection(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
      ),
    );
  }

  double get _progress {
    int filled = 0;
    const int total = 8;
    if (_make_controller.text.isNotEmpty) filled++;
    if (_model_controller.text.isNotEmpty) filled++;
    if (_year_controller.text.isNotEmpty) filled++;
    if (_askingPriceController.text.isNotEmpty) filled++;
    if (_mileageController.text.isNotEmpty) filled++;
    if (_exteriorColor != null) filled++;
    if (_interiorColor != null) filled++;
    if (_coverImage != null && _coverImage!.isNotEmpty) filled++;
    return filled / total;
  }

  Widget _buildHeader() {
    final int pct = (_progress * 100).round();
    // Segmented progress bar — 6 short pills of equal width. Filled
    // count is proportional to `_progress`. Matches the modern
    // reference exactly (not a single continuous bar).
    const int _segments = 6;
    final int _filledSegments = (_progress * _segments).round();

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 14.h),
      color: _brand,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back arrow — bare glyph, no chip. Matches PDF.
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(Icons.arrow_back, color: _ink, size: 22),
                ),
              ),
              Text(
                'Sell Your Car',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: _ink.withOpacity(0.75),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: List<Widget>.generate(_segments, (i) {
              final bool filled = i < _filledSegments;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i == _segments - 1 ? 0 : 4.w),
                  decoration: BoxDecoration(
                    color: filled ? _ink : _ink.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? margin, Color? bg}) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.all(12.w),
      child: child,
    );
  }

  // ── Photos ──────────────────────────────────────────────────────────

  Widget _buildPhotosSection() {
    final lc = AppLocalizations.of(context)!;
    final int photosCount = _images.length;

    return Container(
      // Barely-there warm wash on light (cream), dark section bg on
      // dark so it still reads as a distinct block from the
      // page background beneath.
      color: _isDark ? _sectionBg : const Color(0xFFFFFDF7),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                lc.v2_section_photos,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                lc.v2_photos_counter(photosCount),
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9B8548),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildCoverTile(),
          // Strip + caption belong to the create flow only. In edit
          // mode the strip returns an empty SizedBox and the caption
          // is skipped so the section collapses cleanly to just the
          // cover (tap-to-swap).
          if (widget.postData == null) ...[
            SizedBox(height: 10.h),
            _buildThumbnailStrip(),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                lc.v2_cover_photo_hint,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9B8548),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverTile() {
    final Widget content;
    if (_coverImage != null && _coverImage!.isNotEmpty) {
      final bool isUrl = _coverImage!.startsWith('http');
      content = isUrl
          ? Image.network(_coverImage!, fit: BoxFit.cover)
          : Image.file(File(_coverImage!), fit: BoxFit.cover);
    } else {
      content = Container(
        color: const Color(0xFFE8DDBF),
        alignment: Alignment.center,
        child: const Icon(Icons.camera_alt_outlined,
            size: 42, color: Color(0xFFB89A4A)),
      );
    }

    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // Soft warm shadow — gives the cover the same lifted-off-page
          // feel it has in the PDF.
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB89A4A).withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                content,
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 11.sp, color: _brand),
                        SizedBox(width: 4.w),
                        Text(
                          AppLocalizations.of(context)!.v2_cover_badge,
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            color: _brand,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    // Icon color is pinned to near-black because the
                    // badge circle stays white on both light/dark
                    // themes — using theme-aware `_ink` here turned
                    // the icon white-on-white in dark mode.
                    child: const Icon(Icons.swap_horiz,
                        size: 16, color: Color(0xFF0F0F0F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Strip below the cover — matches the PDF layout: at rest the 4
  /// tiles (2 preview slots + video + add-more) share the full row
  /// width evenly, exactly like the cover box above; once a 4th image
  /// is added the strip becomes a horizontal scroller with the tiles
  /// keeping roughly the same size so nothing appears to shrink.
  ///
  /// The video tile shows a real thumbnail (via `VideoThumbnail`) once
  /// picked, and every filled tile carries a small ✕ to remove inline.
  Widget _buildThumbnailStrip() {
    // Mirror the OLD image_picker_field.dart behavior: in modify mode
    // (postData != null) users can only *replace* the cover photo — no
    // adding new gallery images, no swapping the video, and NO empty
    // affordance tiles either. The strip should show ONLY the actual
    // media already attached to the ad — nothing else.
    final bool isEdit = widget.postData != null;
    if (isEdit) return const SizedBox.shrink();

    Widget videoTile() => _VideoThumbTile(
          videoPath: _videoPath,
          brand: _brand,
          ink: _ink,
          onTap: _pickVideo,
          onRemove: () {
            setState(() {
              _videoPath = null;
              _videoChanged = true;
            });
          },
          showRemove: true,
        );

    final List<Widget> tiles = <Widget>[];
    // Create mode — show 2 preview slots (filled or gray placeholder),
    // any extras, the video tile (even empty so users know where
    // video goes), and the +Add affordance.
    for (int i = 0; i < 2; i++) {
      final int imgIndex = i + 1;
      tiles.add(imgIndex < _images.length
          ? _imageThumb(_images[imgIndex], imgIndex)
          : _placeholderTile());
    }
    for (int imgIndex = 3; imgIndex < _images.length; imgIndex++) {
      tiles.add(_imageThumb(_images[imgIndex], imgIndex));
    }
    tiles.add(videoTile());
    if (_images.length < 15) {
      tiles.add(_addMoreSlot());
    }

    final double gap = 9.w;

    // At-rest layout (≤ 4 tiles): split the row evenly using
    // Expanded + AspectRatio(1) — tiles fill the full section width
    // like the cover box above, matching the PDF.
    if (tiles.length <= 4) {
      final List<Widget> row = <Widget>[];
      for (int i = 0; i < tiles.length; i++) {
        if (i > 0) row.add(SizedBox(width: gap));
        row.add(Expanded(
          child: AspectRatio(aspectRatio: 1, child: tiles[i]),
        ));
      }
      return Row(children: row);
    }

    // Scrolling layout (>4 tiles): fixed-size tiles picked to match
    // the at-rest width (≈ (340 - 3×9) / 4 ≈ 78.w). Keeps the visual
    // size roughly the same as the at-rest state so tiles don't jump
    // when the strip starts scrolling.
    const double tileSize = 78;
    return SizedBox(
      height: tileSize.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: tiles.length,
        separatorBuilder: (_, __) => SizedBox(width: gap),
        itemBuilder: (_, i) => SizedBox(
          width: tileSize.w,
          height: tileSize.w,
          child: tiles[i],
        ),
      ),
    );
  }

  Widget _placeholderTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7E1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined,
          color: const Color(0xFFB6B4AA), size: 22.sp),
    );
  }

  Widget _imageThumb(String url, int index, {bool allowRemove = true}) {
    final bool isNet = url.startsWith('http');
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox.expand(
            child: isNet
                ? Image.network(url, fit: BoxFit.cover)
                : Image.file(File(url), fit: BoxFit.cover),
          ),
        ),
        if (allowRemove)
          Positioned(
            top: 3,
            right: 3,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _images.removeAt(index);
                  if (_images.isEmpty) {
                    _coverImage = null;
                  } else if (index == 0) {
                    _coverImage = _images.first;
                  }
                });
              },
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _addMoreSlot() {
    return GestureDetector(
      onTap: _pickAdditionalImage,
      child: CustomPaint(
        // Dashed yellow border, matching the PDF's affordance for the
        // "add more" slot. Solid Border.all() gave a hard rectangle;
        // the dashed painter reads as a placeholder / drop-zone.
        painter: _DashedBorderPainter(
          color: _brand,
          radius: 12,
          dash: 4,
          gap: 3,
          strokeWidth: 1.4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.add, color: const Color(0xFFB45309), size: 24.sp),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _videoPath = file.path;
      _videoChanged = true;
    });
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    if (!mounted) return;
    final String? cropped = await CarPhotoCropper.cropToCarRatio(
      context: context,
      sourcePath: file.path,
    );
    if (cropped == null) return;
    setState(() {
      _coverImage = cropped;
      _coverPhotoChanged = true;
      if (_images.isEmpty) _images.add(cropped);
    });
  }

  Future<void> _pickAdditionalImage() async {
    if (_images.length >= 15) return;
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    if (!mounted) return;
    final String? cropped = await CarPhotoCropper.cropToCarRatio(
      context: context,
      sourcePath: file.path,
    );
    if (cropped == null) return;
    setState(() {
      _images.add(cropped);
      if (_coverImage == null || _coverImage!.isEmpty) {
        _coverImage = cropped;
        _coverPhotoChanged = true;
      }
    });
  }

  // ── Vehicle ─────────────────────────────────────────────────────────

  Widget _buildVehicleSection() {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    // Full-width white block matching the PDF — no rounded corners, no
    // side margin, and the "Vehicle" title sits INSIDE the block at
    // top-left (not floating above it like a chip).
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lc.v2_section_vehicle,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              // First row — Make + Class as inline TypeAhead tiles.
              // Class comes right after Make since it's the second step
              // in the cascade (Make → Class → Model).
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _typeAheadTile(
                      label: lc.v2_field_make,
                      controller: _make_controller,
                      hint: lc.select,
                      optionsGetter: () => brandController.carBrands
                          .map((b) => b.name)
                          .toList()
                        ..sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase())),
                      onSelected: (value) {
                        final selected = brandController.carBrands
                            .firstWhereOrNull((b) => b.name == value);
                        if (selected != null) {
                          brandController.selectedMake.value = selected;
                          _make_controller.text = selected.name;
                          brandController
                              .fetchCarClasses(selected.id.toString());
                          _selectedMakeId = selected.id.toString();
                          _class_controller.clear();
                          brandController.selectedClass.value = null;
                          _model_controller.clear();
                          brandController.selectedModel.value = null;
                          brandController.carModels.clear();
                          setState(() {});
                        }
                      },
                    )),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() => _typeAheadTile(
                      label: lc.v2_field_class,
                      controller: _class_controller,
                      hint: lc.select,
                      optionsGetter: () => brandController.carClasses
                          .map((c) => c.name)
                          .toList()
                        ..sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase())),
                      onSelected: (value) {
                        final selected = brandController.carClasses
                            .firstWhereOrNull((c) => c.name == value);
                        if (selected != null) {
                          brandController.selectedClass.value = selected;
                          _class_controller.text = selected.name;
                          brandController.fetchCarModels(
                              selected.id.toString(), _selectedMakeId);
                          _model_controller.clear();
                          brandController.selectedModel.value = null;
                          setState(() {});
                        }
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Second row — Year (numeric) + Model (last step in the
              // cascade, populated by fetchCarModels after Class is
              // picked).
              Row(
                children: [
                  Expanded(
                    // Year — matches the old CustomDropDownTyping in
                    // form_fields_section.dart:328-342: 51 discrete
                    // options from `DateTime.now().year + 1` down 50
                    // years, no free-text entry.
                    child: _typeAheadTile(
                      label: lc.v2_field_year,
                      controller: _year_controller,
                      hint: '${DateTime.now().year}',
                      optionsGetter: () => List<String>.generate(
                        51,
                        (i) => (DateTime.now().year + 1 - i).toString(),
                      ),
                      onSelected: (value) {
                        _year_controller.text = value;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() => _typeAheadTile(
                      label: lc.v2_field_model,
                      controller: _model_controller,
                      hint: lc.select,
                      optionsGetter: () => brandController.carModels
                          .map((m) => m.name)
                          .toList()
                        ..sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase())),
                      onSelected: (value) {
                        final selected = brandController.carModels
                            .firstWhereOrNull((m) => m.name == value);
                        if (selected != null) {
                          brandController.selectedModel.value = selected;
                          _model_controller.text = selected.name;
                          setState(() {});
                        }
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Body type — horizontal chip row instead of a dropdown.
              // Values still come from the same `AdCleanController`
              // (car_categories), so backend catalog is unchanged; only
              // the presentation switched to pills, matching the PDF.
              //
              // Uses `Obx` instead of `GetBuilder` because
              // `AdCleanController.fetchCarCategories()` only assigns
              // the RxList (`carCategories.assignAll(...)`) and never
              // calls `update(['car_categories'])`. GetBuilder would
              // never rebuild → the chips would sit empty until an
              // unrelated setState in the tree happened to force a
              // rebuild, which is what the user was seeing as a "long
              // delay". Obx auto-subscribes to the Rx read below.
              // Plain access — the `ever` listener in initState calls
              // `setState` when the fetch fills `carCategories`, so
              // this section rebuilds as part of the whole widget and
              // the chips appear the moment the backend responds. No
              // Obx / GetBuilder wrapping needed (both had subtle
              // subscription issues with this particular RxList).
              Builder(builder: (_) {
                final ctrl = brandController;
                // Same alphabetical ordering as the old Type dropdown
                // in form_fields_section.dart (case-insensitive).
                final sortedCats = ctrl.carCategories.toList()
                  ..sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lc.v2_body_type_label,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 38.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: sortedCats.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (_, i) {
                            final cat = sortedCats[i];
                            final bool selected =
                                _type_controller.text == cat.name;
                            return GestureDetector(
                              onTap: () {
                                ctrl.selectedCategory.value = cat;
                                _type_controller.text = cat.name;
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _ink
                                      : const Color(0xFFF0F0EE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: selected
                                        ? _brand
                                        : const Color(0xFF666666),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact PDF-style tile that hosts an inline `TypeAheadField` — the
  /// field itself is the search box, and suggestions drop down as an
  /// overlay directly below (same UX as the original
  /// `CustomDropDownTyping`).
  ///
  /// [optionsGetter] is a closure so we re-read the underlying list
  /// each time the user types — no stale copies.
  ///
  /// Color TypeAhead tile — same visual container as `_typeAheadTile`
  /// (identical border, padding, label position, font) so it sits
  /// flush with the other spec dropdowns like Cylinders / Fuel. Only
  /// visual difference is a small color swatch that appears BEFORE
  /// the value once a color is committed, and inside the suggestion
  /// list rows.
  ///
  /// [selected] is the currently-committed `Color?` from the parent
  /// (`_exteriorColor` / `_interiorColor`). Used to look up the
  /// matching `ColorData` for the prefix swatch and to highlight the
  /// current row in the suggestions dropdown.
  Widget _colorTile({
    required String label,
    required TextEditingController controller,
    required bool isExterior,
    required Color? selected,
    required ValueChanged<Color?> onSelected,
  }) {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    final bool ar = Get.locale?.languageCode == 'ar';
    final List<ColorData> options = _allColors
        .where((c) => c.isExterior == isExterior)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final ColorData? current = selected == null
        ? null
        : options.firstWhereOrNull((c) => c.color == selected);

    String nameOf(ColorData c) => ar ? c.nameSL : c.namePL;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          TypeAheadField<ColorData>(
            controller: controller,
            hideOnEmpty: false,
            hideOnSelect: true,
            hideOnError: true,
            suggestionsCallback: (pattern) {
              final q = pattern.trim().toLowerCase();
              if (q.isEmpty) return options;
              return options
                  .where((c) =>
                      c.namePL.toLowerCase().contains(q) ||
                      c.nameSL.contains(pattern.trim()))
                  .toList();
            },
            builder: (ctx, ctrl, focusNode) {
              // Prefix swatch appears ONLY when the field text matches
              // a committed color name — mirrors `ColorPickerField`
              // behavior (swatch hides while typing a search query).
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: ctrl,
                builder: (_, value, __) {
                  final bool showSwatch = current != null &&
                      value.text == nameOf(current);
                  return Row(
                    children: [
                      if (showSwatch) ...[
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: current.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey.shade400, width: 0.8),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: lc.select,
                            hintStyle: TextStyle(
                              fontFamily: 'Gilroy',
                              color: Colors.grey.shade400,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            suffixIcon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Colors.grey.shade500),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 20, minHeight: 20),
                          ),
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            itemBuilder: (ctx, c) {
              final bool isSel = current?.colorId == c.colorId;
              return Container(
                color:
                    isSel ? const Color(0xFFF5F5F5) : Colors.transparent,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: c.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.shade400, width: 0.8),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        nameOf(c),
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: _ink,
                        ),
                      ),
                    ),
                    if (isSel)
                      Icon(Icons.check, size: 16.sp, color: _brand),
                  ],
                ),
              );
            },
            emptyBuilder: (_) => Padding(
              padding: EdgeInsets.all(12.w),
              child: Text('No results',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
            errorBuilder: (_, __) => const SizedBox.shrink(),
            loadingBuilder: (_) => const SizedBox.shrink(),
            decorationBuilder: (ctx, child) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: _sectionBg,
                child: child,
              );
            },
            onSelected: (c) {
              controller.text = nameOf(c);
              onSelected(c.color);
            },
          ),
        ],
      ),
    );
  }

  /// **Reactivity note:** for tiles whose options come from an
  /// `RxList` (Make/Class/Model), wrap the CALL in `Obx(() => ...)` so
  /// the tile rebuilds when the async fetch fills the list. Tiles that
  /// read from a plain `List` inside a `GetBuilder` (Fuel / Cylinders /
  /// Transmission / Type) MUST NOT be wrapped in Obx — Obx throws
  /// "improper use of GetX" if there is no Rx read at build time.
  Widget _typeAheadTile({
    required String label,
    required TextEditingController controller,
    required List<String> Function() optionsGetter,
    required ValueChanged<String> onSelected,
    String hint = 'Select',
  }) {
    final List<String> options = optionsGetter();
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10.sp, color: const Color(0xFF888888))),
            TypeAheadField<String>(
              key: ValueKey('typeahead_${label}_${options.length}'),
              controller: controller,
              hideOnEmpty: false,
              hideOnSelect: true,
              hideOnError: true,
              suggestionsCallback: (pattern) {
                final query = pattern.trim().toLowerCase();
                if (query.isEmpty) return options;
                return options
                    .where((o) => o.toLowerCase().contains(query))
                    .toList();
              },
              builder: (ctx, ctrl, focusNode) {
                return TextField(
                  controller: ctrl,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                        fontFamily: 'Gilroy',
                        color: Colors.grey.shade400,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: Colors.grey.shade500),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                  ),
                  style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: _ink),
                );
              },
              itemBuilder: (ctx, suggestion) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Text(suggestion,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14.sp,
                          color: _ink)),
                );
              },
              emptyBuilder: (_) => Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  options.isEmpty ? 'Loading…' : 'No results',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              errorBuilder: (_, __) => const SizedBox.shrink(),
              loadingBuilder: (_) => const SizedBox.shrink(),
              decorationBuilder: (ctx, child) {
                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  child: child,
                );
              },
              onSelected: (suggestion) {
                controller.text = suggestion;
                onSelected(suggestion);
              },
            ),
          ],
        ),
      );
  }

  Widget _fieldTile({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF888888))),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _bodyChip(String label) {
    final bool selected = _type_controller.text.toLowerCase() == label.toLowerCase();
    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: GestureDetector(
        onTap: () => setState(() => _type_controller.text = label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? _ink : Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _brand : const Color(0xFF666666),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Price ──────────────────────────────────────────────────────────

  Widget _buildPriceSection() {
    final lc = AppLocalizations.of(context)!;
    // Full-width white block (same shape as the Vehicle section) with
    // two stacked "price cards" inside — asking-price highlighted with
    // a yellow border (the primary CTA), min-bid quiet gray. Same
    // controllers as the old form; only the presentation changed.
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lc.v2_section_price,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 12.h),
          _priceBox(
            label: lc.v2_field_asking_price,
            controller: _askingPriceController,
            highlighted: true,
          ),
          SizedBox(height: 10.h),
          _priceBox(
            label: lc.v2_field_min_bid,
            controller: _minimumPriceController,
            highlighted: false,
          ),
        ],
      ),
    );
  }

  /// One price box in the Price section.
  ///
  /// [highlighted] gives the yellow border + cream tint used on the
  /// asking-price field in the PDF (the more important input). The
  /// unhighlighted variant is a plain neutral card used for min-bid.
  Widget _priceBox({
    required String label,
    required TextEditingController controller,
    required bool highlighted,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFFBEC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? _brand : const Color(0xFFE5E5E5),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF888888),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.v2_field_qar,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: highlighted ? _brand : const Color(0xFF999999),
                ),
              ),
            ],
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
              letterSpacing: -0.3,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              hintStyle: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Specifications ─────────────────────────────────────────────────

  Widget _buildSpecsSection() {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    // Full-width white block matching Vehicle/Price — "Specifications"
    // title lives INSIDE at top-left, 2×2 grid of spec tiles, then a
    // side-by-side Colors row, then the warranty toggle. All wiring
    // (Mileage controller, SpecsController.updateLocal, ColorPicker,
    // warranty controller) is untouched.
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lc.v2_section_specifications,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 12.h),
          // 2×2 spec grid — Mileage + Fuel on top row, Transmission +
          // Cylinders on the bottom row (matches the PDF's reading
          // order). Fuel/Cylinders/Transmission come from
          // `specsStatic[0..2]` — same indices as before.
          //
          // Edit mode: the OLD form_fields_section.dart:426 hid the
          // Fuel/Cylinders/Transmission dropdowns entirely when
          // `postData != null`. We mirror that here — in edit mode
          // Mileage takes the full row alone and the second row is
          // dropped so the three spec dropdowns don't show at all.
          GetBuilder<SpecsController>(
            builder: (specsController) {
              final bool isEdit = widget.postData != null;
              final bool hasSpecs = specsController.specsStatic.isNotEmpty;
              final fuel =
                  hasSpecs ? specsController.specsStatic[0] : null;
              final cyl =
                  hasSpecs && specsController.specsStatic.length > 1
                      ? specsController.specsStatic[1]
                      : null;
              final trans =
                  hasSpecs && specsController.specsStatic.length > 2
                      ? specsController.specsStatic[2]
                      : null;
              final bool ar = Get.locale?.languageCode == 'ar';
              if (isEdit) {
                return _specTile(
                  icon: Icons.speed,
                  label: lc.mileage,
                  controller: _mileageController,
                  hint: '0 km',
                );
              }
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _specTile(
                          icon: Icons.speed,
                          label: lc.mileage,
                          controller: _mileageController,
                          hint: '0 km',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: fuel != null
                            ? _typeAheadTile(
                                label: ar
                                    ? fuel.specHeaderSl
                                    : fuel.specHeaderPl,
                                controller: fuelTypeController,
                                optionsGetter: () =>
                                    List<String>.from(fuel.options ?? []),
                                onSelected: (v) {
                                  fuelTypeController.text = v;
                                  specsController.updateLocal(
                                    specId: fuel.specId,
                                    specValuePl: v,
                                  );
                                  setState(() {});
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: trans != null
                            ? _typeAheadTile(
                                label: ar
                                    ? trans.specHeaderSl
                                    : trans.specHeaderPl,
                                controller: transmissionController,
                                optionsGetter: () =>
                                    List<String>.from(trans.options ?? []),
                                onSelected: (v) {
                                  transmissionController.text = v;
                                  specsController.updateLocal(
                                    specId: trans.specId,
                                    specValuePl: v,
                                  );
                                  setState(() {});
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: cyl != null
                            ? _typeAheadTile(
                                label: ar
                                    ? cyl.specHeaderSl
                                    : cyl.specHeaderPl,
                                controller: cylindersController,
                                optionsGetter: () =>
                                    List<String>.from(cyl.options ?? []),
                                onSelected: (v) {
                                  cylindersController.text = v;
                                  specsController.updateLocal(
                                    specId: cyl.specId,
                                    specValuePl: v,
                                  );
                                  setState(() {});
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 14.h),
          // Colors — label + side-by-side ColorPickerField for
          // exterior / interior. Same widget as before (keeps the
          // catalog, validation, and searchable dropdown), just
          // arranged horizontally to match the PDF.
          Text(
            'Colors',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _colorTile(
                  label: lc.v2_field_exterior,
                  controller: _exteriorColorController,
                  isExterior: true,
                  selected: _exteriorColor,
                  onSelected: (Color? c) {
                    setState(() => _exteriorColor = c);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _colorTile(
                  label: lc.v2_field_interior,
                  controller: _interiorColorController,
                  isExterior: false,
                  selected: _interiorColor,
                  onSelected: (Color? c) {
                    setState(() => _interiorColor = c);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Under warranty — same on/off wiring to
          // _warranty_controller ('Yes'/'No'). Only the outer
          // container styling changed to match the PDF.
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lc.v2_warranty_title,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: _ink,
                        ),
                      ),
                      Text(
                        lc.v2_warranty_subtitle,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                // iOS-style pill toggle — Cupertino renders a proper
                // pill (yellow when on, light gray when off) with a
                // white thumb that slides. Matches the toggle shown
                // in the PDF, unlike Material's default Switch which
                // is bulkier and reads more like an Android control.
                Transform.scale(
                  scale: 0.85,
                  child: CupertinoSwitch(
                    value:
                        _warranty_controller.text.toLowerCase() == 'yes',
                    activeTrackColor: _brand,
                    inactiveTrackColor: const Color(0xFFE5E5E5),
                    thumbColor: Colors.white,
                    onChanged: (v) => setState(() =>
                        _warranty_controller.text = v ? 'Yes' : 'No'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact tile that visually matches `_typeAheadTile` — same border,
  /// same padding, same font — but hosts a plain numeric TextField
  /// (used for Mileage). Kept as its own helper so future numeric
  /// spec fields can share the exact same style.
  Widget _specTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Gilroy',
                color: Colors.grey.shade400,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Boost ──────────────────────────────────────────────────────────

  Widget _buildBoostSection() {
    final lc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                lc.v2_section_boost,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                  letterSpacing: -0.1,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF3D8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  lc.v2_boost_optional,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9B8548),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _boostCard(
            selected: _isRequest360,
            onTap: () => setState(() => _isRequest360 = !_isRequest360),
            icon: Icons.threed_rotation,
            title: lc.v2_boost_360_title,
            subtitle: lc.v2_boost_360_subtitle,
            price: (paymentController.request360ServicePrice ?? 0)
                .toStringAsFixed(0),
          ),
          SizedBox(height: 8.h),
          _boostCard(
            selected: _isFeauredPost,
            onTap: () => setState(() => _isFeauredPost = !_isFeauredPost),
            icon: Icons.push_pin,
            title: lc.v2_boost_feature_title,
            subtitle: lc.v2_boost_feature_subtitle,
            price: (paymentController.featuredServicePrice ?? 0)
                .toStringAsFixed(0),
          ),
        ],
      ),
    );
  }

  /// A single boost card — icon on the left in a rounded square,
  /// title + subtitle in the middle, price + QAR on the right. When
  /// selected the whole card gets a yellow border + soft cream tint
  /// and the icon tile inverts (dark ink bg, yellow glyph); matches
  /// the PDF. No trailing checkbox — the yellow border alone reads
  /// as "on".
  Widget _boostCard({
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFBEC) : Colors.white,
          border: Border.all(
            color: selected ? _brand : const Color(0xFFE5E5E5),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    selected ? _brand : const Color(0xFFF0F0EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? _ink : const Color(0xFF888888),
                size: 22,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.v2_field_qar,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),

                // Small selection indicator on the right — dark ink
                // filled square with a yellow check when the boost is
                // on, empty gray-bordered square when off. Restored on
                // user request; the yellow outer border alone wasn't
                // enough of a "selected" signal.

              ],
            ),
            SizedBox(width: 12.w),

            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                // Pinned to near-black on both themes so the
                // yellow check inside stays visible in dark
                // mode (theme-aware `_ink` turned the fill
                // white, which flattened the checkbox).
                color: selected
                    ? const Color(0xFF0F0F0F)
                    : Colors.white,
                border: selected
                    ? null
                    : Border.all(
                    color: const Color(0xFFDDDDDD), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: selected
                  ? Icon(Icons.check, size: 14, color: _brand)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Consent ────────────────────────────────────────────────────────

  Widget _buildConsentSection() {
    final lc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
      child: Column(
        children: [
          _consentRow(
            checked: _termsAccepted,
            label: lc.v2_consent_terms,
            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          ),
          SizedBox(height: 10.h),
          _consentRow(
            checked: _infoConfirmed,
            label: lc.v2_consent_info,
            onTap: () => setState(() => _infoConfirmed = !_infoConfirmed),
          ),
        ],
      ),
    );
  }

  Widget _consentRow({
    required bool checked,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: checked ? _brand : Colors.white,
              border: Border.all(
                color: checked ? _brand : const Color(0xFFDDDDDD),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            // Check glyph pinned to near-black — the yellow fill is
            // constant in both themes, so `_ink` (white in dark)
            // would look muddy against the yellow.
            child: checked
                ? const Icon(Icons.check,
                    size: 14, color: Color(0xFF0F0F0F))
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────

  int get _totalDue {
    int t = 0;
    if (_isRequest360) {
      t += (paymentController.request360ServicePrice ?? 0).toInt();
    }
    if (_isFeauredPost) {
      t += (paymentController.featuredServicePrice ?? 0).toInt();
    }
    return t;
  }

  Widget _buildBottomBar() {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    final bool isEdit = widget.postData != null;

    // Bottom-bar logic:
    //   Create mode: ONE full-width "Submit" button — validates the
    //     form and navigates to the Summary page (no submission yet).
    //     The old Save-as-draft / Publish pair lives on the summary
    //     page and calls back into `_submitAd` with the same booleans.
    //   Edit mode: ONE full-width primary button — "RePublish" when
    //     the ad's PostStatus is "Approved", "Save" otherwise.
    //     Matches the OLD form_fields_section.dart edit-mode layout.
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: _sectionBg,
        border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEdit
              ? () => _validateAndSubmitForm(shouldPublish: false)
              : _openSummaryFromCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brand,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
          ),
          child: Text(
            isEdit
                ? (widget.postData!['PostStatus'].toString() == 'Approved'
                    ? lc.republish
                    : lc.save)
                : lc.v2_submit_button,
            style: TextStyle(
                fontFamily: 'Gilroy',
                color: _ink,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail tile for the video slot in the Photos strip.
///
/// Behavior:
/// • Empty state — black tile with a video-camera glyph. Tap opens the
///   video picker.
/// • Filled state — a real frame from the video (generated once via
///   `VideoThumbnail.thumbnailFile`) with a play-overlay and a ✕ button
///   to remove. Tap picks a replacement.
///
/// Kept as its own `StatefulWidget` so the async thumbnail generation
/// only runs when the underlying video path changes, without forcing
/// the parent form to rebuild the strip for every step.
class _VideoThumbTile extends StatefulWidget {
  final String? videoPath;
  final Color brand;
  final Color ink;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  // In edit mode the video is read-only — parent passes false so the
  // ✕ overlay is hidden. Defaults to true for create mode.
  final bool showRemove;

  const _VideoThumbTile({
    required this.videoPath,
    required this.brand,
    required this.ink,
    required this.onTap,
    required this.onRemove,
    this.showRemove = true,
  });

  @override
  State<_VideoThumbTile> createState() => _VideoThumbTileState();
}

class _VideoThumbTileState extends State<_VideoThumbTile> {
  String? _thumbPath;
  String? _resolvedFor;

  @override
  void initState() {
    super.initState();
    _generateIfNeeded();
  }

  @override
  void didUpdateWidget(_VideoThumbTile old) {
    super.didUpdateWidget(old);
    if (old.videoPath != widget.videoPath) {
      _thumbPath = null;
      _resolvedFor = null;
      _generateIfNeeded();
    }
  }

  Future<void> _generateIfNeeded() async {
    final String? p = widget.videoPath;
    if (p == null || p.isEmpty) return;
    if (_resolvedFor == p) return;
    _resolvedFor = p;
    try {
      final String? t = await VideoThumbnail.thumbnailFile(
        video: p,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 50,
      );
      if (!mounted) return;
      if (t != null) setState(() => _thumbPath = t);
    } catch (_) {
      // Fall back to the plain black tile below.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideo =
        widget.videoPath != null && widget.videoPath!.isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(
              child: hasVideo && _thumbPath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_thumbPath!), fit: BoxFit.cover),
                        Container(color: Colors.black.withOpacity(0.25)),
                        Center(
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: widget.brand,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.play_arrow_rounded,
                                size: 18, color: widget.ink),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: widget.ink,
                      alignment: Alignment.center,
                      child: Icon(
                        hasVideo
                            ? Icons.play_arrow_rounded
                            : Icons.videocam_outlined,
                        color: widget.brand,
                        size: 24,
                      ),
                    ),
            ),
          ),
          if (hasVideo && widget.showRemove)
            Positioned(
              top: 3,
              right: 3,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.close, size: 13, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rounded-rectangle dashed border painter for the +add tile.
///
/// `Border.all(...)` only draws solid strokes, and the PDF spec calls
/// for a dashed yellow outline. Walking the RRect perimeter and
/// drawing `dash`px strokes separated by `gap`px keeps the corners
/// crisp at the given [radius].
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}
