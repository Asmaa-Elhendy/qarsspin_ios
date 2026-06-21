import 'dart:async'; // ✅ ADDED: for Completer (to wait for dialogs)
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/ads/ad_getx_controller_create_ad.dart';
import '../../../../controller/ads/data_layer.dart';
import '../../../../controller/auth/auth_controller.dart';
import '../../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../../controller/my_ads/my_ad_data_layer.dart';
import '../../../../controller/payments/payment_controller.dart';
import '../../../../controller/specs/specs_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/create_ad_model.dart';
import '../../../../model/payment/payment_method_model.dart';

import '../../my_ads/dialog.dart' as dialog;
import '../../payments/payment_methods_dialog.dart';
import '../dialogs/contact_info_dialog.dart';

/// Bilingual status text for the current submission stage.
/// Returns Arabic when the current GetX locale is `ar`, English otherwise.
String _stageText(String key) {
  final bool isAr = Get.locale?.languageCode == 'ar';
  switch (key) {
    case 'submitting':
      return isAr ? 'جاري إرسال بيانات الإعلان...' : 'Submitting ad details...';
    case 'cover':
      return isAr ? 'جاري رفع صورة الغلاف...' : 'Uploading cover photo...';
    case 'gallery':
      return isAr ? 'جاري رفع الصور...' : 'Uploading photos...';
    case 'specs':
      return isAr ? 'جاري رفع المواصفات...' : 'Uploading specifications...';
    case 'video':
      return isAr ? 'جاري رفع الفيديو...' : 'Uploading video...';
    case 'payment':
      return isAr ? 'جاري معالجة الدفع...' : 'Processing payment...';
    case 'finalizing':
      return isAr ? 'جاري إنهاء العملية...' : 'Finalizing...';
    default:
      return '';
  }
}

class AdSubmissionService {
  static Future<void> submitAd({
    required bool shouldPublish,
    required bool isRequest360,
    required bool isFeaturedPost,
    required BuildContext context,
    required List<String> images,
    required String coverImage,
    required String? videoPath,
    required String make,
    required String carClass,
    required String model,
    required String type,
    required String year,
    required String warranty,
    required String askingPrice,
    required String minimumPrice,
    required String mileage,
    required String plateNumber,
    required String chassisNumber,
    required String description,
    required Color exteriorColor,
    required Color interiorColor,
    required bool videoChanged,
    required Function() showLoadingDialog,
    required Function(String, String, {bool isPublished}) showSuccessDialog,
    required Function(String) showErrorDialog,
    required Function() hideLoadingDialog,
    required Function() navigateToMyAds,
    Function(String)? updateLoadingStatus,
    String? postId,
    bool coverPhotoChanged = false,
  }) async {
    try {
      showLoadingDialog();

      await _submitOrUpdateAd(
        shouldPublish: shouldPublish,
        isRequest360: isRequest360,
        isFeaturedPost: isFeaturedPost,
        context: context,
        images: images,
        coverImage: coverImage,
        videoPath: videoPath,
        make: make,
        carClass: carClass,
        model: model,
        type: type,
        year: year,
        warranty: warranty,
        askingPrice: askingPrice,
        minimumPrice: minimumPrice,
        mileage: mileage,
        plateNumber: plateNumber,
        chassisNumber: chassisNumber,
        description: description,
        exteriorColor: exteriorColor,
        interiorColor: interiorColor,
        videoChanged: videoChanged,
        showLoadingDialog: showLoadingDialog,
        showSuccessDialog: showSuccessDialog,
        showErrorDialog: showErrorDialog,
        hideLoadingDialog: hideLoadingDialog,
        navigateToMyAds: navigateToMyAds,
        updateLoadingStatus: updateLoadingStatus,
        postId: postId,
        coverPhotoChanged: coverPhotoChanged,
      );
    } catch (e) {
      hideLoadingDialog();
      showErrorDialog('An error occurred while submitting your ad. Please try again.');
    }
  }

  // ✅ updateAd untouched (زي ما هو عندك) — سيبته كما هو
  static Future<void> updateAd({
    required String PostStaus,
    required BuildContext context,
    required List<String> images,
    required String coverImage,
    required String? videoPath,
    required String make,
    required String carClass,
    required String model,
    required String type,
    required String year,
    required String warranty,
    required String askingPrice,
    required String minimumPrice,
    required String mileage,
    required String plateNumber,
    required String chassisNumber,
    required String description,
    required Color exteriorColor,
    required Color interiorColor,
    required String postId,
    required bool coverPhotoChanged,
    required bool videoChanged,
    required bool shouldPublish,
    required Function() showLoadingDialog,
    required Function(String, String, {bool isPublished}) showSuccessDialog,
    required Function(String) showErrorDialog,
    required Function() hideLoadingDialog,
    Function(String)? updateLoadingStatus,
  }) async {
    try {
      showLoadingDialog();
      updateLoadingStatus?.call(_stageText('submitting'));

      final AdCleanController brandController = Get.find<AdCleanController>();
      final selectedMake = brandController.selectedMake.value;
      final selectedClass = brandController.selectedClass.value;
      final selectedModel = brandController.selectedModel.value;
      final selectedCategory = brandController.selectedCategory.value;

      bool warrantyAvailable = warranty.toLowerCase() == 'yes';

      String exteriorColorHex =
          '#${exteriorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      String interiorColorHex =
          '#${interiorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      CreateAdModel adData = CreateAdModel(
        Owner_Name: Get.find<AuthController>().userFullName,
        Owner_Mobile: Get.find<AuthController>().ownerMobile,
        Owner_Email: Get.find<AuthController>().ownerEmail,
        makeId: selectedMake?.id.toString() ?? '',
        classId: selectedClass?.id.toString() ?? '',
        modelId: selectedModel?.id.toString() ?? '',
        categoryId: selectedCategory?.id.toString() ?? '',
        manufactureYear: year,
        minimumPrice: minimumPrice.isNotEmpty ? minimumPrice : '0',
        askingPrice: askingPrice,
        mileage: mileage,
        plateNumber: plateNumber.isNotEmpty ? plateNumber : '',
        chassisNumber: chassisNumber.isNotEmpty ? chassisNumber : '',
        postDescription: description,
        interiorColor: interiorColorHex,
        exteriorColor: exteriorColorHex,
        warrantyAvailable: warrantyAvailable ? 'yes' : 'no',
        userName: userName,
        ourSecret: ourSecret,
        selectedLanguage: 'en',
      );

      log('Updating ad with data: ${adData.toJson()}');

      final adRepository = AdRepository();
      final response = await adRepository.updateCarAd(
        postId: postId,
        adModel: adData,
      );

      log('API Response: $response');

      if (response['Code'] == 'OK' || response['Code']?.toString().toLowerCase() == 'ok') {
        if (postId.isNotEmpty && coverImage.isNotEmpty && coverPhotoChanged) {
          updateLoadingStatus?.call(_stageText('cover'));
          log('Uploading cover photo for post ID: $postId');
          await adRepository.uploadCoverPhoto(
            postId: postId,
            ourSecret: ourSecret,
            imagePath: coverImage,
          );
          log('Cover photo upload completed');
        } else if (!coverPhotoChanged) {
          log('Cover photo not changed, skipping upload');
        }

        if (postId.isNotEmpty && videoPath != null && videoPath.isNotEmpty && videoChanged) {
          updateLoadingStatus?.call(_stageText('video'));
          log('Uploading video for post ID: $postId');
          await adRepository.uploadVideoForPost(
            postId: postId,
            ourSecret: ourSecret,
            videoPath: videoPath,
          );
          log('Video upload completed');
        } else if (!videoChanged) {
          log('Video not changed, skipping upload');
        }

        updateLoadingStatus?.call(_stageText('finalizing'));
        hideLoadingDialog();

        String successMessage = "Ad updated successfully!\nPost ID: $postId";

        if (PostStaus == "Approved" || PostStaus == "Pending Approval") {
          log('📤 [PUBLISH] Requesting publish for ad: $postId (Mode: Modify)');
          Future.delayed(const Duration(milliseconds: 300), () async {
            try {
              final MyAdCleanController myAdController = Get.find<MyAdCleanController>();
              bool publishSuccess = await myAdController.requestPublishAd(
                userName: userName,
                postId: postId,
                ourSecret: ourSecret,
              );

              if (publishSuccess) {
                String publishSuccessMessage = "$successMessage\n\n📤 Publish request sent successfully!";
                showSuccessDialog(publishSuccessMessage, postId, isPublished: true);
              } else {
                String publishErrorMessage = "$successMessage\n\n⚠️ Failed to send publish request.";
                showSuccessDialog(publishErrorMessage, postId, isPublished: true);
              }
            } catch (e) {
              String publishErrorMessage = "$successMessage\n\n⚠️ Error sending publish request.";
              showSuccessDialog(publishErrorMessage, postId, isPublished: true);
            }
          });
        } else {
          showSuccessDialog(successMessage, postId, isPublished: false);
        }
      } else {
        String errorMessage = response['Desc'] ?? 'Failed to update ad';
        showErrorDialog(errorMessage);
      }
    } catch (e) {
      hideLoadingDialog();
      showErrorDialog('An error occurred while updating your ad. Please try again.');
    }
  }

  // ✅ ADDED: show dialog and WAIT until user closes it (so navigation happens after)
  static Future<void> _showInfoThenContinue({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final completer = Completer<void>();

    dialog.SuccessDialog.show(
      request: true,
      context: context,
      title: title,
      message: message,
      onClose: () {
        if (!completer.isCompleted) completer.complete();
      },
      onTappp: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  // ✅ ADDED: payment status dialog (success/fail) + wait
  static Future<void> _showPaymentStatusThenContinue({
    required BuildContext context,
    required bool success,
    required AppLocalizations lc,
  }) async {
    await _showInfoThenContinue(
      context: context,
      title: success ? lc.paymentSucceeded : lc.payment_failed,
      message: success ? lc.paymentWasCompleted : lc.paymentWasNotCompleted,
    );
  }

  static Future<void> _submitOrUpdateAd({
    required bool shouldPublish,
    required bool isRequest360,
    required bool isFeaturedPost,
    required BuildContext context,
    required List<String> images,
    required String coverImage,
    required String? videoPath,
    required String make,
    required String carClass,
    required String model,
    required String type,
    required String year,
    required String warranty,
    required String askingPrice,
    required String minimumPrice,
    required String mileage,
    required String plateNumber,
    required String chassisNumber,
    required String description,
    required Color exteriorColor,
    required Color interiorColor,
    required bool videoChanged,
    required Function() showLoadingDialog,
    required Function(String, String, {bool isPublished}) showSuccessDialog,
    required Function(String) showErrorDialog,
    required Function() hideLoadingDialog,
    required Function() navigateToMyAds,
    Function(String)? updateLoadingStatus,
    String? postId,
    bool coverPhotoChanged = false,
  }) async {
    try {
      final lc = AppLocalizations.of(context)!;
      updateLoadingStatus?.call(_stageText('submitting'));

      // ✅ IMPORTANT: prevent double pop of loader dialog
      bool loaderHidden = false;
      void hideLoaderOnce() {
        if (!loaderHidden) {
          hideLoadingDialog();
          loaderHidden = true;
        }
      }

      final bool warrantyAvailable = warranty.toLowerCase() == 'yes';

      final String exteriorColorHex =
          '#${exteriorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      final String interiorColorHex =
          '#${interiorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final AdCleanController brandController = Get.find<AdCleanController>();
      final selectedMake = brandController.selectedMake.value;
      final selectedClass = brandController.selectedClass.value;
      final selectedModel = brandController.selectedModel.value;
      final selectedCategory = brandController.selectedCategory.value;

      final CreateAdModel adData = CreateAdModel(
        Owner_Name: Get.find<AuthController>().userFullName,
        Owner_Mobile: Get.find<AuthController>().ownerMobile,
        Owner_Email: Get.find<AuthController>().ownerEmail,
        makeId: selectedMake?.id?.toString() ?? '',
        classId: selectedClass?.id?.toString() ?? '',
        modelId: selectedModel?.id?.toString() ?? '',
        categoryId: selectedCategory?.id?.toString() ?? '',
        manufactureYear: year,
        minimumPrice: minimumPrice.isNotEmpty ? minimumPrice : '0',
        askingPrice: askingPrice,
        mileage: mileage,
        plateNumber: plateNumber.isNotEmpty ? plateNumber : '',
        chassisNumber: chassisNumber.isNotEmpty ? chassisNumber : '',
        postDescription: description,
        interiorColor: interiorColorHex,
        exteriorColor: exteriorColorHex,
        warrantyAvailable: warrantyAvailable ? 'yes' : 'no',
        userName: userName,
        ourSecret: ourSecret,
        selectedLanguage: 'en',
      );

      log('Submitting ad with data: ${adData.toJson()}');

      final adRepository = AdRepository();
      final response = (postId == null)
          ? await adRepository.createCarAd(adModel: adData)
          : await adRepository.updateCarAd(postId: postId, adModel: adData);

      log('API Response: $response');

      if (!(response['Code'] == 'OK' || response['Code']?.toString().toLowerCase() == 'ok')) {
        final errorMessage =
            response['Desc'] ?? 'Failed to ${postId == null ? 'create' : 'update'} ad';
        hideLoaderOnce();
        showErrorDialog(errorMessage);
        return;
      }

      // ✅ we have a postId now
      final String responsePostId = postId ?? response['ID']?.toString() ?? '';

      // =========================
      // ✅ 1) Upload cover
      // =========================
      if (responsePostId.isNotEmpty && coverImage.isNotEmpty) {
        if (postId == null || coverPhotoChanged) {
          updateLoadingStatus?.call(_stageText('cover'));
          log('Uploading cover photo for post ID: $responsePostId');
          await adRepository.uploadCoverPhoto(
            postId: responsePostId,
            ourSecret: ourSecret,
            imagePath: coverImage,
          );
          log('Cover photo upload completed');
        } else {
          log('Cover photo not changed, skipping upload');
        }
      }

      // =========================
      // ✅ 2) Upload gallery (create only)
      // =========================
      if (postId == null && responsePostId.isNotEmpty && images.isNotEmpty) {
        updateLoadingStatus?.call(_stageText('gallery'));
        log('Uploading gallery photos for post ID: $responsePostId');
        await _uploadGalleryPhotos(
          postId: responsePostId,
          images: images,
          coverImage: coverImage,
        );
        log('Gallery photos upload completed');
      }

      // =========================
      // ✅ 3) Upload specs (create only) — BEFORE payment
      // =========================
      if (postId == null && responsePostId.isNotEmpty) {
        try {
          updateLoadingStatus?.call(_stageText('specs'));
          log('Uploading modified specs for post ID: $responsePostId');
          final specsController = Get.find<SpecsController>(tag: 'specs_0');
          await _uploadModifiedSpecs(
            postId: responsePostId,
            specsController: specsController,
          );
          log('Modified specs upload completed');
        } catch (e) {
          log('❌ [SPECS] Could not upload specs: $e');
        }
      }

      // =========================
      // ✅ 4) Upload video — BEFORE payment
      // =========================
      if (responsePostId.isNotEmpty && videoPath != null && videoPath.isNotEmpty) {
        if (postId == null || videoChanged) {
          updateLoadingStatus?.call(_stageText('video'));
          log('Uploading video for post ID: $responsePostId');
          await adRepository.uploadVideoForPost(
            postId: responsePostId,
            ourSecret: ourSecret,
            videoPath: videoPath,
          );
          log('Video upload completed');
        } else {
          log('Video not changed, skipping upload');
        }
      }

      // =========================
      // ✅ 5) PAYMENT AFTER ALL UPLOADS
      // =========================
      if ((isRequest360 || isFeaturedPost) && responsePostId.isNotEmpty) {
        updateLoadingStatus?.call(_stageText('payment'));
        final paymentController = Get.find<PaymentController>();

        double amount = 0;
        if (isRequest360) amount += (paymentController.request360ServicePrice ?? 0);
        if (isFeaturedPost) amount += (paymentController.featuredServicePrice ?? 0);

        final contactInfo = await ContactInfoDialog.show(
          req360Amount: paymentController.request360ServicePrice ?? 0,
          featuredAmount: paymentController.featuredServicePrice ?? 0,
          totalAmount: amount,
          context: context,
          isRequest360: isRequest360,
          isFeauredPost: isFeaturedPost,
        );

        if (contactInfo != null) {
          try {
            final String customerName =
            '${(contactInfo['firstName'] ?? '').toString().trim()} ${(contactInfo['lastName'] ?? '').toString().trim()}'
                .trim();
            final String email = (contactInfo['email'] ?? '').toString().trim();
            final String mobile = (contactInfo['mobile'] ?? '').toString().trim();

            final List<int> selectedServiceIDs = [];
            if (isRequest360) selectedServiceIDs.add(paymentController.request360ServiceId!);
            if (isFeaturedPost) selectedServiceIDs.add(paymentController.featuredServiceId!);

            final result = await paymentController.initiatePayment(
              postId: int.parse(responsePostId),
              serviceIds: selectedServiceIDs,
              externalUser: Get.find<AuthController>().userName!,
              amount: amount,
              customerName: customerName.isEmpty ? 'Customer' : customerName,
              email: email,
              mobile: mobile,
            );

            log('Payment Initiation Result: $result');

            // ✅ FIX: read methods from myFatoorahRawJson
            final bool isOk = result?['myFatoorahRawJson']?['IsSuccess'] == true;
            final methodsRaw = result?['myFatoorahRawJson']?['Data']?['PaymentMethods'];

            if (isOk && methodsRaw is List) {
              final methods = methodsRaw
                  .map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e)))
                  .toList();

              final orderMasterId = result?['masterOrderId'] as int?;
              if (orderMasterId == null) {
                throw Exception('No masterOrderId in payment initiation response');
              }

              // ✅ CLOSE LOADER BEFORE opening payment dialogs
              hideLoaderOnce();

              final methodsPayload = await NewPaymentMethodsDialog.show(
                context: context,
                paymentMethods: methods,
                isArabic: Get.locale?.languageCode == 'ar',
                orderMasterId: orderMasterId,
                initiateResponse: result,
              );

              // ✅ Show payment status dialog BEFORE navigation (and WAIT)
              if (methodsPayload != null) {
                Map<String, dynamic>? normalized;
                final invoice = methodsPayload['invoice'] as Map<String, dynamic>?;
                if (invoice != null) {
                  final invoiceResult = await InvoiceLinkDialog.show(
                    context: context,
                    invoiceId: (invoice['invoiceId'] ?? '').toString(),
                    paymentId: (invoice['paymentId'] ?? '').toString(),
                    paymentUrl: (invoice['paymentUrl'] ?? '').toString(),
                    isArabic: (invoice['isArabic'] == true),
                  );
                  normalized = invoiceResult?['normalizedResult'] as Map<String, dynamic>?;
                } else {
                  normalized = methodsPayload['normalizedResult'] as Map<String, dynamic>?;
                }

                final status = normalized?['status']?.toString();
                final paymentId = normalized?['paymentId']?.toString();

                final bool success =
                    (status != null && status.toLowerCase() == 'success') &&
                        (paymentId != null && paymentId.isNotEmpty);

                // ✅ HERE: show success/fail dialog BEFORE navigation and WAIT
                await _showPaymentStatusThenContinue(
                  context: context,
                  success: success,
                  lc: lc,
                );
              } else {
                // user backed out of payment methods dialog
                await _showInfoThenContinue(
                  context: context,
                  title: lc.payment_failed,
                  message: lc.paymentWasNotCompleted,
                );
              }
            } else {
              // ❌ Methods not available
              log('❌ Payment methods missing or initiation failed.');

              // ✅ CLOSE LOADER ONCE (if still open)
              hideLoaderOnce();

              // ✅ Show fail dialog BEFORE navigation and WAIT
              await _showInfoThenContinue(
                context: context,
                title: lc.payment_failed,
                message: (result?['myFatoorahRawJson']?['Message'] ??
                    result?['Message'] ??
                    lc.failedToLoadPaymentMethods)
                    .toString(),
              );
            }
          } catch (e, st) {
            log('Payment flow error: $e');
            log('Stack: $st');

            hideLoaderOnce();

            // ✅ Show fail dialog BEFORE navigation and WAIT
            await _showInfoThenContinue(
              context: context,
              title: lc.payment_failed,
              message: '${lc.paymentflowfailed} $e',
            );
          }
        } else {
          log('User cancelled contact info dialog.');
          // لو المستخدم cancel هنا، هنكمل عادي (بدون ما نكسر الفلو)
        }
      }

      // =========================
      // ✅ 6) NOW do publish + success + navigation (ONE TIME ONLY)
      // =========================
      updateLoadingStatus?.call(_stageText('finalizing'));
      hideLoaderOnce();

      String successMessage = responsePostId.isNotEmpty
          ? "Ad ${postId == null ? 'created' : 'updated'} successfully!\nPost ID: $responsePostId"
          : "Ad ${postId == null ? 'created' : 'updated'} successfully!";

      if (shouldPublish && responsePostId.isNotEmpty) {
        log('📤 [PUBLISH] Requesting publish for ad: $responsePostId');

        Future.delayed(const Duration(milliseconds: 300), () async {
          try {
            final MyAdCleanController myAdController = Get.find<MyAdCleanController>();
            bool publishSuccess = await myAdController.requestPublishAd(
              userName: userName,
              postId: responsePostId,
              ourSecret: ourSecret,
            );

            if (publishSuccess) {
              String publishSuccessMessage =
                  "$successMessage\n\n📤 Publish request sent successfully!";
              showSuccessDialog(publishSuccessMessage, responsePostId, isPublished: true);
            } else {
              String publishErrorMessage =
                  "$successMessage\n\n⚠️ Failed to send publish request.";
              showSuccessDialog(publishErrorMessage, responsePostId, isPublished: true);
            }
          } catch (e) {
            String publishErrorMessage =
                "$successMessage\n\n⚠️ Error sending publish request.";
            showSuccessDialog(publishErrorMessage, responsePostId, isPublished: true);
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            navigateToMyAds();
          });
        });
      } else {
        showSuccessDialog(successMessage, responsePostId, isPublished: shouldPublish);
        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToMyAds();
        });
      }
    } catch (e) {
      hideLoadingDialog();
      log('Error submitting ad: $e');
      showErrorDialog('An error occurred while submitting your ad. Please try again.');
    }
  }

  static Future<void> _uploadGalleryPhotos({
    required String postId,
    required List<String> images,
    required String coverImage,
  }) async {
    try {
      final MyAdCleanController myAdController = Get.put(
        MyAdCleanController(MyAdDataLayer()),
      );

      final galleryImages = images.where((image) => image != coverImage).toList();

      log('Gallery images to upload: ${galleryImages.length} (excluding cover photo)');

      for (int i = 0; i < galleryImages.length; i++) {
        final imagePath = galleryImages[i];
        final file = File(imagePath);

        if (await file.exists()) {
          log('Uploading gallery photo ${i + 1}/${galleryImages.length}: $imagePath');

          final success = await myAdController.uploadPostGalleryPhoto(
            postId: postId,
            photoFile: file,
            ourSecret: ourSecret,
          );

          if (success) {
            log('✅ Gallery photo ${i + 1} uploaded successfully');
          } else {
            log('❌ Failed to upload gallery photo ${i + 1}: ${myAdController.uploadError.value}');
          }
        } else {
          log('❌ Gallery photo file not found: $imagePath');
        }
      }

      log('Gallery photos upload process completed');
    } catch (e) {
      log('❌ Error uploading gallery photos: $e');
    }
  }

  static void logAdSubmission({
    required String make,
    required String carClass,
    required String model,
    required String type,
    required String year,
    required String askingPrice,
    required int imageCount,
    required bool hasVideo,
  }) {
    log('=== Ad Submission Log ===');
    log('Make: $make');
    log('Class: $carClass');
    log('Model: $model');
    log('Type: $type');
    log('Year: $year');
    log('Asking Price: $askingPrice');
    log('Image Count: $imageCount');
    log('Has Video: $hasVideo');
    log('========================');
  }

  static Future<bool> validateImageFiles({
    required List<String> images,
    required String coverImage,
    required String? videoPath,
    required Function(String) showErrorDialog,
  }) async {
    if (images.isEmpty) {
      showErrorDialog("Please upload at least one image");
      return false;
    }

    if (coverImage.isNotEmpty && !images.contains(coverImage)) {
      showErrorDialog("Cover image must be one of the uploaded images");
      return false;
    }

    if (images.length > 15) {
      showErrorDialog("Maximum 15 images allowed");
      return false;
    }

    if (videoPath != null && videoPath.isNotEmpty) {
      log('Video path provided: $videoPath');
    }

    return true;
  }

  static Future<void> _uploadModifiedSpecs({
    required String postId,
    required SpecsController specsController,
  }) async {
    try {
      log('🔧 [SPECS] Starting upload of modified specs for post ID: $postId');

      final modifiedSpecs = specsController.getModifiedSpecs();
      if (modifiedSpecs.isEmpty) {
        log('🔧 [SPECS] No modified specs to upload');
        return;
      }

      for (final spec in modifiedSpecs) {
        try {
          final success = await specsController.updateSpecValue(
            postId: postId,
            specId: spec.specId,
            specValue: spec.specValuePl.isNotEmpty ? spec.specValuePl : spec.specValueSl ?? '',
          );

          if (success) {
            log('✅ [SPECS] Successfully uploaded spec: ${spec.specHeaderPl}');
          } else {
            log('❌ [SPECS] Failed to upload spec: ${spec.specHeaderPl}');
          }
        } catch (e) {
          log('❌ [SPECS] Error uploading spec ${spec.specHeaderPl}: $e');
        }
      }

      log('✅ [SPECS] Completed uploading modified specs');
    } catch (e) {
      log('❌ [SPECS] Error in _uploadModifiedSpecs: $e');
    }
  }
}
