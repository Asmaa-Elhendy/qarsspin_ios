import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/ads/ad_getx_controller_create_ad.dart';
import '../../../../controller/ads/data_layer.dart';
import '../../../../controller/auth/auth_controller.dart';
import '../../../../controller/my_ads/my_ad_getx_controller.dart';
import '../../../../controller/my_ads/my_ad_data_layer.dart';
import '../../../../controller/specs/specs_controller.dart';
import '../../../../model/create_ad_model.dart';

class AdSubmissionService {
  // User credentials - these should be moved to a proper configuration/session management

  static Future<void> submitAd({
    required bool shouldPublish,
    // required TextEditingController request360controller,
    // required TextEditingController featureyouradcontroller,
    required bool  isRequest360,
    required bool  isFeaturedPost,
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

    String? postId,
    bool coverPhotoChanged = false,
  }) async {
    try {
      showLoadingDialog();

      // Get the controller instance
      final AdCleanController brandController = Get.find<AdCleanController>();

      // Get selected IDs from the controller
      final selectedMake = brandController.selectedMake.value;
      final selectedClass = brandController.selectedClass.value;
      final selectedModel = brandController.selectedModel.value;
      final selectedCategory = brandController.selectedCategory.value;

      await _submitOrUpdateAd(
        shouldPublish: shouldPublish,
        isRequest360:  isRequest360,
        isFeaturedPost:  isFeaturedPost,
        // request360controller:  request360controller,
        // featureyouradcontroller:  featureyouradcontroller,
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
        postId: postId,
        coverPhotoChanged: coverPhotoChanged,
      );
    } catch (e) {
      hideLoadingDialog();
      showErrorDialog('An error occurred while submitting your ad. Please try again.');
    }
  }

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
  }) async
  {
    try {
      showLoadingDialog();

      // Get the controller instance
      final AdCleanController brandController = Get.find<AdCleanController>();

      // Get selected IDs from the controller
      final selectedMake = brandController.selectedMake.value;
      final selectedClass = brandController.selectedClass.value;
      final selectedModel = brandController.selectedModel.value;
      final selectedCategory = brandController.selectedCategory.value;

      // Convert warranty to boolean
      bool warrantyAvailable = warranty.toLowerCase() == 'yes';

      // Get color values as proper hex strings
      String exteriorColorHex = '#${exteriorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      String interiorColorHex = '#${interiorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      // Create the ad data model
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

      // Submit the ad update to the backend
      final adRepository = AdRepository();
      final response = await adRepository.updateCarAd(
        postId: postId,
        adModel: adData,
      );

      log('API Response: $response');

      if (response['Code'] == 'OK' || response['Code']?.toString().toLowerCase() == 'ok') {
        // Upload cover photo if we have a post ID and cover image AND it was changed
        if (postId.isNotEmpty && coverImage.isNotEmpty && coverPhotoChanged) {
          log('Uploading cover photo for post ID: $postId');
          await adRepository.uploadCoverPhoto(
            postId: postId,
            ourSecret: ourSecret, // Using the same secret as in ad creation
            imagePath: coverImage,
          );
          log('Cover photo upload completed');
        } else if (!coverPhotoChanged) {
          log('Cover photo not changed, skipping upload');
        }

        // Upload video if we have a post ID and video path AND it was changed
        if (postId.isNotEmpty && videoPath != null && videoPath.isNotEmpty && videoChanged) {
          log('Uploading video for post ID: $postId');
          var res= await adRepository.uploadVideoForPost(
            postId: postId,
            ourSecret: ourSecret, // Using the same secret as in ad creation
            videoPath: videoPath,
          );
          log('Video upload completed ${res}');
        } else if (!videoChanged) {
          log('Video not changed, skipping upload');
        }

        // Note: Gallery photos are NOT uploaded during update - only during create

        // Hide loading dialog only after all operations are complete
        hideLoadingDialog();

        String successMessage = "Ad updated successfully!\nPost ID: $postId";
        log("pooooooooooooooooooooooooo $PostStaus");
        // Publish again approved/ pending approval posts (for modify mode)
        if (PostStaus=="Approved"||PostStaus=="Pending Approval") { //here if approved
          log('📤 [PUBLISH] Requesting publish for ad: $postId (Mode: Modify)');

          // Request publish after a short delay
          Future.delayed(Duration(milliseconds: 300), () async {
            try {
              final MyAdCleanController myAdController = Get.find<MyAdCleanController>();
              bool publishSuccess = await myAdController.requestPublishAd(
                userName: userName, // This should come from user session
                postId: postId,
                ourSecret: ourSecret, // This should come from app config
              );

              if (publishSuccess) {
                log('✅ [PUBLISH] Publish request sent successfully for ad: $postId');
                // Update success message to include publish info
                String publishSuccessMessage = "$successMessage\n\n📤 Publish request sent successfully!";
                showSuccessDialog(publishSuccessMessage, postId, isPublished: true);
              } else {
                log('❌ [PUBLISH] Failed to send publish request for ad: $postId');
                String publishErrorMessage = "$successMessage\n\n⚠️ Failed to send publish request.";
                showSuccessDialog(publishErrorMessage, postId, isPublished: true);
              }
            } catch (e) {
              log('❌ [PUBLISH] Error sending publish request: ${e.toString()}');
              String publishErrorMessage = "$successMessage\n\n⚠️ Error sending publish request.";
              showSuccessDialog(publishErrorMessage, postId, isPublished: true);
            }
          });
        }
        else {
          // Show success dialog for draft save
          showSuccessDialog(successMessage, postId, isPublished: false);
        }
      } else {
        String errorMessage = response['Desc'] ?? 'Failed to update ad';
        log('Error response: Code=${response['Code']}, Desc=$errorMessage');
        showErrorDialog(errorMessage);
      }

    } catch (e) {
      hideLoadingDialog();
      log('Error updating ad: $e');
      showErrorDialog('An error occurred while updating your ad. Please try again.');
    }
  }

  static Future<void> _submitOrUpdateAd({
    required shouldPublish,
    // required request360controller,
    // required featureyouradcontroller,
    required bool  isRequest360,
    required bool  isFeaturedPost,
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
    String? postId,
    bool coverPhotoChanged = false,
  }) async
  {
    try {
      // Convert warranty to boolean
      bool warrantyAvailable = warranty.toLowerCase() == 'yes';

      // Get color values as proper hex strings
      String exteriorColorHex = '#${exteriorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      String interiorColorHex = '#${interiorColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      // Define user credentials (these should be properly configured)


      // Get the controller instance
      final AdCleanController brandController = Get.find<AdCleanController>();

      // Get selected IDs from the controller
      final selectedMake = brandController.selectedMake.value;
      final selectedClass = brandController.selectedClass.value;
      final selectedModel = brandController.selectedModel.value;
      final selectedCategory = brandController.selectedCategory.value;

      // Create the ad data model
      CreateAdModel adData = CreateAdModel(
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

      // Submit the ad to the backend
      final adRepository = AdRepository();
      final response;

      if (postId == null) {
        // Create mode
        response = await adRepository.createCarAd(adModel: adData);
      } else {
        // Update mode
        response = await adRepository.updateCarAd(
          postId: postId,
          adModel: adData,
        );
      }

      log('API Response: $response');

      if (response['Code'] == 'OK' || response['Code']?.toString().toLowerCase() == 'ok') {
        String responsePostId = postId ?? response['ID']?.toString() ?? '';

        // Upload cover photo if we have a post ID and cover image
        if (responsePostId.isNotEmpty && coverImage.isNotEmpty) {
          // Only upload cover photo if it's a new post or if cover photo was changed
          if (postId == null || coverPhotoChanged) {
            log('Uploading cover photo for post ID: $responsePostId');
            await adRepository.uploadCoverPhoto(
              postId: responsePostId,
              ourSecret: ourSecret, // Using the same secret as in ad creation
              imagePath: coverImage,
            );
            log('Cover photo upload completed');
          } else {
            log('Cover photo not changed, skipping upload');
          }
        }

        // Upload gallery photos (all images except cover photo) - ONLY IN CREATE MODE
        if (postId == null && responsePostId.isNotEmpty && images.isNotEmpty) {
          log('Uploading gallery photos for post ID: $responsePostId');
          await _uploadGalleryPhotos(
            postId: responsePostId,
            images: images,
            coverImage: coverImage,
          );
          log('Gallery photos upload completed');
        }//k
        // Upload modified specs after gallery photos - ONLY IN CREATE MODE
        log('Uploading modified specs for post ID: $responsePostId');
        // Get the SpecsController instance that was used for the form
        final specsController = Get.find<SpecsController>(tag: 'specs_0');
        await _uploadModifiedSpecs(
          postId: responsePostId,
          specsController: specsController,
        );
        log('Modified specs upload completed');

        // Request 360 photo session - ONLY IN CREATE MODE
        if (postId == null &&
            isRequest360//request360controller.text == "Yes"
            && responsePostId.isNotEmpty) {
          log('Requesting 360 photo session for post ID: $responsePostId');
          await _request360Session(postId: responsePostId);
        }

        // Request to feature ad - ONLY IN CREATE MODE
        if (postId == null &&
            isFeaturedPost//  featureyouradcontroller.text == "Yes"
            && responsePostId.isNotEmpty) {
          log('Requesting to feature ad for post ID: $responsePostId');
          await _requestFeatureAd(postId: responsePostId);
          log('Feature ad request completed');
        }

        // Upload video if we have a post ID and video path
        if (responsePostId.isNotEmpty && videoPath != null && videoPath.isNotEmpty) {
          // Only upload video if it's a new post or if video was changed
          if (postId == null || videoChanged) {
            log('Uploading video for post ID: $responsePostId');
            await adRepository.uploadVideoForPost(
              postId: responsePostId,
              ourSecret: ourSecret, // Using the same secret as in ad creation
              videoPath: videoPath,
            );
            log('Video upload completed');
          } else {
            log('Video not changed, skipping upload');
          }
        }



        // Hide loading dialog only after both operations are complete
        hideLoadingDialog();

        String successMessage = responsePostId.isNotEmpty
            ? "Ad ${postId == null ? 'created' : 'updated'} successfully!\nPost ID: $responsePostId"
            : "Ad ${postId == null ? 'created' : 'updated'} successfully!";

        // Check if we should also request publish (for both create and modify modes)
        if (shouldPublish && responsePostId.isNotEmpty) {
          log('📤 [PUBLISH] Requesting publish for ad: $responsePostId (Mode: ${postId == null ? 'Create' : 'Modify'})');

          // Request publish after a short delay
          Future.delayed(Duration(milliseconds: 300), () async {
            try {
              final MyAdCleanController myAdController = Get.find<MyAdCleanController>();
              bool publishSuccess = await myAdController.requestPublishAd(
                userName: userName, // This should come from user session
                postId: responsePostId,
                ourSecret: ourSecret, // This should come from app config
              );

              if (publishSuccess) {
                log('✅ [PUBLISH] Publish request sent successfully for ad: $responsePostId');
                // Update success message to include publish info
                String publishSuccessMessage = "$successMessage\n\n📤 Publish request sent successfully!";
                showSuccessDialog(publishSuccessMessage, responsePostId, isPublished: true);
              } else {
                log('❌ [PUBLISH] Failed to send publish request for ad: $responsePostId');
                String publishErrorMessage = "$successMessage\n\n⚠️ Failed to send publish request.";
                showSuccessDialog(publishErrorMessage, responsePostId, isPublished: true);
              }
            } catch (e) {
              log('❌ [PUBLISH] Error sending publish request: ${e.toString()}');
              String publishErrorMessage = "$successMessage\n\n⚠️ Error sending publish request.";
              showSuccessDialog(publishErrorMessage, responsePostId, isPublished: true);
            }

            // Navigate after showing publish result
            Future.delayed(Duration(milliseconds: 500), () {
              log('🧭 [NAVIGATION] Executing navigation after publish request');
              navigateToMyAds();
            });
          });
        } else {
          // Show success dialog first
          showSuccessDialog(successMessage, responsePostId, isPublished: shouldPublish);

          // Add a small delay to ensure dialog is shown, then navigate
          Future.delayed(Duration(milliseconds: 500), () {
            log('🧭 [NAVIGATION] Executing navigation after delay');
            navigateToMyAds();
          });
        }
      } else {
        String errorMessage = response['Desc'] ?? 'Failed to ${postId == null ? 'create' : 'update'} ad';
        log('Error response: Code=${response['Code']}, Desc=$errorMessage');
        showErrorDialog(errorMessage);
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
  }) async
  {
    try {
      // Get the MyAdCleanController instance
      final MyAdCleanController  myAdController = Get.put(
        MyAdCleanController (MyAdDataLayer()),
      );

      // Filter out cover photo from images list
      final galleryImages = images.where((image) => image != coverImage).toList();

      log('Gallery images to upload: ${galleryImages.length} (excluding cover photo)');

      // Upload each gallery photo sequentially
      for (int i = 0; i < galleryImages.length; i++) {
        final imagePath = galleryImages[i];
        final file = File(imagePath);

        if (await file.exists()) {
          log('Uploading gallery photo ${i + 1}/${galleryImages.length}: $imagePath');

          final success = await myAdController.uploadPostGalleryPhoto(
            postId: postId,
            photoFile: file,
            ourSecret: ourSecret, // Using the same secret as in ad creation
          );

          if (success) {
            log('✅ Gallery photo ${i + 1} uploaded successfully');
          } else {
            log('❌ Failed to upload gallery photo ${i + 1}: ${myAdController.uploadError.value}');
          }
        } else {//l
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
  })
  {
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
  }) async
  {
    // Check if there are any images
    if (images.isEmpty) {
      showErrorDialog("Please upload at least one image");
      return false;
    }

    // Check if cover image exists in the images list
    if (coverImage.isNotEmpty && !images.contains(coverImage)) {
      showErrorDialog("Cover image must be one of the uploaded images");
      return false;
    }//j

    // Check maximum images limit
    if (images.length > 15) {
      showErrorDialog("Maximum 15 images allowed");
      return false;
    }

    // Check video limit
    if (videoPath != null && videoPath.isNotEmpty) {
      // You can add additional video validation here if needed
      log('Video path provided: $videoPath');
    }

    return true;
  }

  /// Upload modified specs to the server after gallery photos upload
  static Future<void> _uploadModifiedSpecs({
    required String postId,
    required SpecsController specsController,
  }) async {
    try {
      log('🔧 [SPECS] Starting upload of modified specs for post ID: $postId');

      // Log the current state of the controller
      log('🔧 [SPECS] Controller instance: ${specsController.hashCode}');
      log('🔧 [SPECS] Current modified specs count: ${specsController.getModifiedSpecs().length}');

      // Get only the specs that have been modified (non-empty values)
      final modifiedSpecs = specsController.getModifiedSpecs();

      if (modifiedSpecs.isEmpty) {
        log('🔧 [SPECS] No modified specs to upload');
        return;
      }

      log('🔧 [SPECS] Uploading ${modifiedSpecs.length} modified specs');

      // Log all modified specs before uploading
      log('🔧 [SPECS] Modified specs to upload:');
      for (final spec in modifiedSpecs) {
        log('   - ${spec.specId}: ${spec.specHeaderPl} = "${spec.specValuePl}"');
      }

      // Upload each modified spec
      for (final spec in modifiedSpecs) {
        try {
          log('🔧 [SPECS] Uploading spec: ${spec.specHeaderPl} = "${spec.specValuePl}"');

          // Use the existing API method to update spec value
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

  /// Request 360 photo session for the newly created ad
  static Future<void> _request360Session({
    required String postId,
  }) async
  {
    try {
      log('🔄 [360] Starting 360 photo session request for post ID: $postId');

      // Get the MyAdCleanController instance
      final myAdController = Get.find<MyAdCleanController>();

      // Request 360 photo session
      final success = await myAdController.request360Session(
        userName: userName, // You might want to get this from user session
        postId: postId,
        ourSecret: ourSecret, // Using the same secret as in ad creation
      );

      if (success) {
        log('✅ [360] Successfully requested 360 photo session');
      } else {
        log('❌ [360] Failed to request 360 photo session');
      }
    } catch (e) {
      log('❌ [360] Error in _request360Session: $e');
    }
  }

  /// Request to feature the newly created ad
  static Future<void> _requestFeatureAd({
    required String postId,
  }) async
  {
    try {
      log('⭐ [FEATURE] Starting feature ad request for post ID: $postId');

      // Get the MyAdCleanController instance
      final myAdController = Get.find<MyAdCleanController>();

      // Request to feature ad
      final success = await myAdController.requestFeatureAd(
        userName: userName, // You might want to get this from user session
        postId: postId,
        ourSecret: ourSecret, // Using the same secret as in ad creation
      );

      if (success) {
        log('✅ [FEATURE] Successfully requested to feature ad');
      } else {
        log('❌ [FEATURE] Failed to request to feature ad');
      }
    } catch (e) {
      log('❌ [FEATURE] Error in _requestFeatureAd: $e');
    }
  }
}