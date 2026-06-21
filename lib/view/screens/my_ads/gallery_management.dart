import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/controller/const/colors.dart';
import 'package:qarsspin/controller/my_ads/my_ad_getx_controller.dart';
import 'package:qarsspin/model/post_media.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/services.dart';

class GalleryManagement extends StatefulWidget {
  final int postId;

  final String postKind;
  final String userName;

  GalleryManagement({
    required this.postId,

    required this.postKind,
    required this.userName,
  });

  @override
  State<GalleryManagement> createState() => _GalleryManagementState();
}

class _GalleryManagementState extends State<GalleryManagement> {
  final ImagePicker _picker = ImagePicker();
  final MyAdCleanController controller = Get.find<MyAdCleanController>();
  List<File> images = [];
  List<MediaItem> apiImages = [];
  String? currentCoverImage;
  Map<String, dynamic>? postDetails;

  // API secret constant
  static const String ourSecret = '1244';

  // Map to store video controllers for proper disposal
  final Map<String, ChewieController> _videoControllers = {};

  // Track currently playing video URL
  String? _currentlyPlayingVideoUrl;

  /// Check if video file exists locally and return local path if available
  Future<String> _getLocalVideoPath(String networkUrl) async {
    try {
      // Extract filename from network URL
      final Uri uri = Uri.parse(networkUrl);
      final filename = uri.pathSegments.last;

      // Check common local storage paths
      final List<String> possiblePaths = [
        // Application documents directory
        '${(await getApplicationDocumentsDirectory()).path}/$filename',
        // Application temporary directory
        '${(await getTemporaryDirectory()).path}/$filename',
        // External storage directory
        '${(await getExternalStorageDirectory())?.path}/$filename',
        // Downloads directory
        '/storage/emulated/0/Download/$filename',
        '/storage/emulated/0/Downloads/$filename',
        // Movies directory
        '/storage/emulated/0/Movies/$filename',
        // DCIM/Camera directory
        '/storage/emulated/0/DCIM/Camera/$filename',
      ];

      // Check each possible path
      for (final path in possiblePaths) {
        if (path.isNotEmpty) {
          final file = File(path);
          if (await file.exists()) {
            log('🎬 [VIDEO] Found local video file: $path');
            return path;
          }
        }
      }

      log('🎬 [VIDEO] No local file found, using network URL: $networkUrl');
      return networkUrl;
    } catch (e) {
      log('❌ [VIDEO] Error checking local video path: $e');
      return networkUrl;
    }
  }

  /// Show media selection dialog (Photo/Video)
  Future<void> _showMediaSelectionDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        var lc = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  lc.add_media,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black),
                title: Text(lc.add_img),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(lc);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: Colors.black),
                title: Text(lc.add_video),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(lc);
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Pick video from gallery
  Future<void> _pickVideo(lc) async {
    try {
      // Check if there's already a video
      final apiImages = controller.postMedia.value?.data ?? [];
      final hasVideo = apiImages.any((item) => _isVideoFile(item.mediaFileName));

      if (hasVideo) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lc.only_one_video)),
        );
        return;
      }

      final XFile? videoFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (videoFile != null) {
        log('🎬 [VIDEO] Selected video: ${videoFile.path}');
        await _uploadVideoToApi(File(videoFile.path));
      }
    } catch (e) {
      log('❌ Error picking video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Upload video to API
  Future<void> _uploadVideoToApi(File videoFile) async {
    try {
      // Show loading indicator
      controller.isLoadingMedia.value = true;

      log('🎬 [VIDEO] Uploading video for post ID: ${widget.postId}');

      final success = await controller.uploadPostVideo(
        postId: widget.postId.toString(),
        videoPath: videoFile.path,
        ourSecret: ourSecret,
        skipRefresh: true, // Skip refresh to do it manually like images
      );

      if (success) {
        log('✅ [VIDEO] Video uploaded successfully');
        // Refresh media list to show the new video (same as images)
        await _fetchPostImages();
      } else {
        log('❌ [VIDEO] Video upload failed');
        log('❌ [VIDEO] Upload error details: ${controller.uploadError.value}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload video: ${controller.uploadError.value ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('❌ Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading video: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide loading indicator
      controller.isLoadingMedia.value = false;
    }
  }

  Future<void> _pickImages(lc) async {
    log('🚀 [DEBUG] _pickImages method started!');

    final totalImages =
        images.length + (controller.postMedia.value?.data.length ?? 0);
    if (totalImages >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lc.only_15_img)),
      );
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    log(
      '🚀 [DEBUG] pickMultiImage completed. Files: ${pickedFiles?.length ?? 0}',
    );
    if (pickedFiles != null) {
      log('=== DEBUG: Selected ${pickedFiles.length} images ===');

      // STEP 1: Batch Editing - Edit all images first
      List<File> editedImages = [];

      log('=== STEP 1: Batch Editing Phase ===');
      for (int i = 0; i < pickedFiles.length; i++) {
        final file = pickedFiles[i];
        log(
          '🎨 [EDITING] Opening editor for image ${i + 1}/${pickedFiles.length}: ${file.path}',
        );

        // Edit the image
        log(
          '🎨 [EDITING] About to open ImageEditor for image ${i + 1}/${pickedFiles.length}',
        );
        log('🎨 [EDITING] Image file path: ${file.path}');
        log('🎨 [EDITING] Image file size: ${await file.length()} bytes');

        dynamic editedImage;
        try {
          // Show a snackbar to guide the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${lc.please_edit_img} ${i + 1} ${lc.tap_save}',
              ),
              duration: Duration(seconds: 3),
            ),
          );

          // Wait a bit for the snackbar to show
          await Future.delayed(Duration(milliseconds: 500));

          log('🎨 [EDITING] Opening ImageEditor dialog...');
          editedImage = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ImageEditor(image: File(file.path).readAsBytesSync()),
            ),
          );
          log('🎨 [EDITING] Navigator.push completed successfully');
          log('🎨 [EDITING] User interaction completed - checking result...');
        } catch (e) {
          log('❌ [EDITING] Exception during ImageEditor navigation: $e');
          log('❌ [EDITING] Exception type: ${e.runtimeType}');
          editedImage = null;
        }

        log(
          '🎨 [EDITING] Returned from ImageEditor for image ${i + 1} - Result: ${editedImage != null ? "SUCCESS" : "CANCELLED"}',
        );
        log('🎨 [EDITING] Edited image type: ${editedImage?.runtimeType}');
        log(
          '🎨 [EDITING] Edited image size: ${editedImage?.length ?? 0} bytes',
        );

        // Additional check - sometimes ImageEditor returns empty list or invalid data
        // ImageEditor can return different types: List<int> or _Uint8ArrayView
        bool isValidImage =
            editedImage != null &&
                ((editedImage is List<int> && editedImage.isNotEmpty) ||
                    (editedImage.toString().contains('Uint8Array') &&
                        editedImage.length > 0)) &&
                editedImage.length > 100; // At least 100 bytes

        log('🎨 [EDITING] Is valid image check: $isValidImage');

        if (!isValidImage && editedImage != null) {
          log(
            '⚠️ [EDITING] Image returned null or invalid data - treating as cancelled',
          );
        }

        if (isValidImage) {
          // Create the file with edited image
          // Convert _Uint8ArrayView to List<int> if needed
          List<int> imageBytes;
          if (editedImage is List<int>) {
            imageBytes = editedImage;
          } else {
            // Handle _Uint8ArrayView or other byte array types
            imageBytes = List<int>.from(editedImage);
          }

          final imageFile = File(file.path)..writeAsBytesSync(imageBytes);
          editedImages.add(imageFile);
          log('✅ [EDITING] Image ${i + 1} edited successfully');
          log(
            '✅ [EDITING] Converted ${editedImage.runtimeType} to List<int> (${imageBytes.length} bytes)',
          );
        } else {
          log('❌ [EDITING] Image ${i + 1} cancelled or invalid in editor');

          // Ask user if they want to retry
          bool shouldRetry = await _showRetryDialog(context, i + 1,lc);
          if (shouldRetry) {
            log('🔄 [EDITING] Retrying image ${i + 1}...');
            i--; // Retry the same image
          }
        }
      }

      log(
        '=== STEP 1 COMPLETE: ${editedImages.length} images ready for upload ===',
      );

      // STEP 2: Sequential Uploading - Upload each edited image one by one
      if (editedImages.isNotEmpty) {
        int successCount = 0;
        int failCount = 0;

        log('=== STEP 2: Sequential Upload Phase ===');
        log(
          '📊 [DEBUG] Starting upload loop for ${editedImages.length} images',
        );

        for (int i = 0; i < editedImages.length; i++) {
          final imageFile = editedImages[i];
          log(
            '📤 [UPLOADING] Starting upload for image ${i + 1}/${editedImages.length}: ${imageFile.path}',
          );

          // Show loader for this specific image
          controller.isLoadingMedia.value = true;
          log('⏳ [UPLOADING] Loader ON for image ${i + 1}');

          // Upload this single image with skipRefresh=true
          try {
            log(
              '⏳ [UPLOADING] Calling _uploadImageToApiWithSkipRefresh for image ${i + 1}',
            );
            final success = await _uploadImageToApiWithSkipRefresh(imageFile);
            log(
              '⏳ [UPLOADING] Completed _uploadImageToApiWithSkipRefresh for image ${i + 1} - Result: $success',
            );

            if (success) {
              successCount++;
              log(
                '✅ [UPLOADING] Image ${i + 1} uploaded successfully - Total success: $successCount',
              );
            } else {
              failCount++;
              log(
                '❌ [UPLOADING] Image ${i + 1} upload failed - Total failed: $failCount',
              );
            }
          } catch (e) {
            failCount++;
            log(
              '❌ [UPLOADING] Exception uploading image ${i + 1}: $e - Total failed: $failCount',
            );
          }

          // Hide loader after this image is done
          controller.isLoadingMedia.value = false;
          log('⏳ [UPLOADING] Loader OFF for image ${i + 1}');

          // Small delay before processing next image
          log('⏳ [UPLOADING] Waiting 500ms before next image...');
          await Future.delayed(const Duration(milliseconds: 500));
          log('⏳ [UPLOADING] Delay completed, moving to next image if any');
        }

        log(
          '=== STEP 2 COMPLETE: Upload results - Success: $successCount, Failed: $failCount ===',
        );

        // Show final result message
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Successfully uploaded $successCount image${successCount > 1 ? 's' : ''}!",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (failCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${lc.upload_failed} $failCount ${lc.image}${Get.locale?.languageCode=='ar'?failCount > 1 ? 's' : '':''}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Final refresh to make sure everything is up to date (ONLY ONCE at the end)
        if (successCount > 0) {
          log('🔄 [FINAL] Refreshing media list after all uploads...');
          await controller.fetchPostMedia(widget.postId.toString());
        }
      } else {
        log('=== STEP 2: No images to upload ===');
      }
    }
  }

  Future<bool> _showRetryDialog(BuildContext context, int imageNumber,lc) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lc.cancel_edit_img),
        content: Text(
          '${lc.image} $imageNumber ${lc.was_cancelled}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(lc.skip, style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              lc.retry,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _uploadImageToApiWithSkipRefresh(File imageFile) async {
    log('🔍 Starting upload with skipRefresh for: ${imageFile.path}'); //lhjjن

    try {
      log(
        '📤 Calling controller.uploadPostGalleryPhoto with skipRefresh=true...',
      );
      final success = await controller.uploadPostGalleryPhoto(
        postId: widget.postId.toString(),
        photoFile: imageFile,
        ourSecret: ourSecret,
        skipRefresh: true, // Skip refresh after each upload
      );

      if (success) {//k
        log('✅ Upload SUCCESS for: ${imageFile.path}');
      } else {
        log('❌ Upload FAILED for: ${imageFile.path}');
      }

      return success;
    } catch (e) {
      log('❌ EXCEPTION during upload for ${imageFile.path}: $e');
      return false;
    }
  }

  void _swapImages(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= images.length) return;
    setState(() {
      final temp = images[oldIndex];
      images[oldIndex] = images[newIndex];
      images[newIndex] = temp;
    });
  }

  void _swapApiImages(int oldIndex, int newIndex) {
    final apiImages = controller.postMedia.value?.data ?? [];
    if (newIndex < 0 || newIndex >= apiImages.length) return;

    setState(() {
      final temp = apiImages[oldIndex];
      apiImages[oldIndex] = apiImages[newIndex];
      apiImages[newIndex] = temp;

      // Update the controller's postMedia to reflect the change
      if (controller.postMedia.value != null) {
        final updatedPostMedia = PostMedia(
          code: controller.postMedia.value!.code,
          desc: controller.postMedia.value!.desc,
          count: controller.postMedia.value!.count,
          data: List<MediaItem>.from(apiImages),
        );
        controller.postMedia.value = updatedPostMedia;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    log('🔄 [INIT] GalleryManagement initialized');
    log('🔄 [INIT] Post ID: ${widget.postId}');
    log('🔄 [INIT] Post Kind: ${widget.postKind}');
    log('🔄 [INIT] User Name: ${widget.userName}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only fetch data if we haven't already loaded it
    if (postDetails == null) {
      // Start both fetches in parallel
      final fetchDetails = _fetchPostDetails();
      final fetchImages = _fetchPostImages();
      
      // When post details complete, try to set cover image immediately
      fetchDetails.then((_) {
        log('✅ [INIT] _fetchPostDetails completed');
        // If images are already loaded, try to set cover image
        if (controller.postMedia.value != null) {
          _trySetCoverImageFromMedia();
        }
      }).catchError((error) {
        log('❌ [INIT] Error in _fetchPostDetails: $error');
      });
      
      // When images complete, try to set cover image if not already set
      fetchImages.then((_) {
        log('✅ [INIT] _fetchPostImages completed');
        _trySetCoverImageFromMedia();
      }).catchError((error) {
        log('❌ [INIT] Error in _fetchPostImages: $error');
      });
    }
  }
  
  // Helper method to try setting the cover image from media if not already set
  void _trySetCoverImageFromMedia() {
    if (currentCoverImage == null || currentCoverImage!.isEmpty) {
      final postMedia = controller.postMedia.value;
      if (postMedia != null && postMedia.data.isNotEmpty) {
        final firstMedia = postMedia.data.firstWhere(
          (media) => media.mediaUrl != null && media.mediaUrl!.isNotEmpty,
          orElse: () => postMedia.data.first,
        );
        
        if (firstMedia.mediaUrl != null && firstMedia.mediaUrl!.isNotEmpty) {
          setState(() {
            currentCoverImage = firstMedia.mediaUrl;
            log('🔄 [COVER_IMAGE] Set cover image from first media item: $currentCoverImage');
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all video controllers to prevent memory leaks
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  // Method to load cover image from postDetails (similar to create_new_ad.dart)
  void _loadCoverImageFromPostDetails(lc) {
    log('🖼️ [COVER_IMAGE] Loading cover image from post details...');
    
    // First, try to get cover image from post details if available
    if (postDetails != null && postDetails!.isNotEmpty) {
      log('📦 [COVER_IMAGE] Post details found. Keys: ${postDetails!.keys}');
      
      // Check multiple possible keys for the cover image URL
      final possibleKeys = [
        'Rectangle_Image_URL',
        'RectangleImageURL',
        'rectangle_image_url',
        'cover_image',
        'coverImage',
        'CoverImage',
        'Image_URL',
        'image_url',
        'main_image',
        'Main_Image',
      ];
      
      String? coverImageUrl;
      
      // Try to find the cover image URL in any of the possible keys
      for (var key in possibleKeys) {
        if (postDetails!.containsKey(key) && postDetails![key] != null && postDetails![key].toString().isNotEmpty) {
          coverImageUrl = postDetails![key].toString();
          log('✅ [COVER_IMAGE] Found cover image URL in key "$key": $coverImageUrl');
          break;
        }
      }
      
      if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
        log('✅ [COVER_IMAGE] Valid cover image URL found in post details');
        setState(() {
          currentCoverImage = coverImageUrl;
          log('🔄 [COVER_IMAGE] currentCoverImage set to: $currentCoverImage');
        });
        return; // Exit early if we found a cover image
      } else {
        log('⚠️ [COVER_IMAGE] No valid cover image URL found in post details');
        log('📋 [COVER_IMAGE] Available keys and values:');
        postDetails!.forEach((key, value) {
          log('   - $key: $value');
        });
      }
    } else {
      log('⚠️ [COVER_IMAGE] postDetails is null or empty');
    }
    
    // If we reach here, we couldn't find a cover image in post details
    // Try to use the first media item as cover image if available
    final postMedia = controller.postMedia.value;
    if (postMedia != null && postMedia.data.isNotEmpty) {
      final firstMedia = postMedia.data.first;
      final mediaUrl = firstMedia.mediaUrl;
      
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        log('🖼️ [COVER_IMAGE] Using first media item as cover: $mediaUrl');
        setState(() {
          currentCoverImage = mediaUrl;
          log('🔄 [COVER_IMAGE] currentCoverImage set to first media item: $currentCoverImage');
        });
        
        // Optionally update the post details with this cover image
        if (postDetails != null) {
          postDetails!['cover_image'] = mediaUrl;
          log('📝 [COVER_IMAGE] Updated postDetails with cover_image');
        }
      } else {
        log('⚠️ [COVER_IMAGE] First media item has no valid URL');
      }
    } else {
      log('⚠️ [COVER_IMAGE] No media items available to use as cover');
    }
  }

  Future<void> _fetchPostImages() async {
    log('Fetching images for post ID: ${widget.postId}');
    await controller.fetchPostMedia(widget.postId.toString());
  }

  Future<void> _fetchPostDetails() async {
    var lc = AppLocalizations.of(context)!;
    log('🔍 [FETCH] ===== START FETCHING POST DETAILS =====');
    log('🔍 [FETCH] Post ID: ${widget.postId}');
    log('🔍 [FETCH] Post Kind: ${widget.postKind}');
    log('🔍 [FETCH] User Name: ${widget.userName}');

    try {
      log('🔍 [FETCH] Calling controller.getPostById...');
      log('🔍 [FETCH] Controller: ${controller.runtimeType}');
      
      // Log the current state before the call
      log('🔍 [FETCH] Before getPostById - isLoadingPostDetails: ${controller.isLoadingPostDetails.value}');
      log('🔍 [FETCH] Before getPostById - postDetails: ${controller.postDetails.value}');
      
      await controller.getPostById(
        postKind: widget.postKind,
        postId: widget.postId.toString(),
        loggedInUser: widget.userName,
      );
      
      // Log the state after the call
      log('🔍 [FETCH] After getPostById - isLoadingPostDetails: ${controller.isLoadingPostDetails.value}');
      log('🔍 [FETCH] After getPostById - postDetails: ${controller.postDetails.value}');
      log('🔍 [FETCH] After getPostById - postDetailsError: ${controller.postDetailsError.value}');

      // Check if post details were fetched successfully
      if (controller.postDetails.value != null) {
        log('✅ [FETCH] Post details fetched successfully');
        log('📋 [FETCH] Post details keys: ${controller.postDetails.value!.keys}');
        
        // Log all post details for debugging with more details
        log('📋 [FETCH] ===== POST DETAILS =====');
        bool hasImageUrl = false;
        
        controller.postDetails.value!.forEach((key, value) {
          // Log all keys and values
          if (value != null) {
            if (value.toString().length < 100) {
              log('📋 [FETCH] $key: $value (${value.runtimeType})');
            } else {
              log('📋 [FETCH] $key: [${value.runtimeType} with length ${value.toString().length}]');
            }
            
            // Check if this is an image URL
            if ((key.toString().toLowerCase().contains('image') || 
                 key.toString().toLowerCase().contains('photo') ||
                 key.toString().toLowerCase().contains('cover') ||
                 key.toString().toLowerCase().contains('rectangle')) &&
                value.toString().startsWith('http')) {
              hasImageUrl = true;
              log('🖼️ [FETCH] Found potential cover image URL in key "$key": $value');
            }
          } else {
            log('📋 [FETCH] $key: null');
          }
        });
        
        if (!hasImageUrl) {
          log('⚠️ [FETCH] No image URL found in post details');
          
          // Log all keys that might contain image URLs
          final imageKeys = controller.postDetails.value!.keys.where((key) => 
            key.toString().toLowerCase().contains('image') || 
            key.toString().toLowerCase().contains('photo') ||
            key.toString().toLowerCase().contains('cover') ||
            key.toString().toLowerCase().contains('rectangle')
          ).toList();
          
          if (imageKeys.isNotEmpty) {
            log('🖼️ [FETCH] Potential image URL keys found:');
            for (var key in imageKeys) {
              log('🖼️ [FETCH] - $key: ${controller.postDetails.value![key]}');
            }
          } else {
            log('❌ [FETCH] No potential image URL keys found in post details');
          }
        }

        // Store post details in local variable
        log(' [FETCH] Storing post details in state...');
        setState(() {
          postDetails = controller.postDetails.value;
        });

        // Load cover image from postDetails
        log(' [FETCH] Loading cover image...');
        _loadCoverImageFromPostDetails(lc);

        // Now fetch the media/images for this post
        log(' [FETCH] Fetching post media...');
        await controller.fetchPostMedia(widget.postId.toString());

        log(' [FETCH] Post media fetched successfully');
      } else {
        log(' [FETCH] Failed to fetch post details: controller.postDetails.value is null');
        log(' [FETCH] Falling back to fetching media only...');
        // Fallback to just fetching media if post details fail
        await controller.fetchPostMedia(widget.postId.toString());
      }
    } catch (e, stackTrace) {
      log(' [FETCH] Error fetching post details: $e');
      log(' [FETCH] Stack trace: $stackTrace');
      // Fallback to just fetching media if there's an error
      log(' [FETCH] Falling back to fetching media only due to error...');
      await controller.fetchPostMedia(widget.postId.toString());
    }
  }

  /// Helper method to check if media file is a video (.mp4)
  bool _isVideoFile(String fileName) {
    return fileName.toLowerCase().endsWith('.mp4');
  }

  /// Toggle video playback inline in the card
  Future<void> _toggleVideoPlayback(String videoUrl,lc) async {
    log('🎬 [VIDEO] Toggling video playback for: $videoUrl');

    try {
      // If this video is already playing, stop it
      if (_currentlyPlayingVideoUrl == videoUrl) {
        log('🎬 [VIDEO] Stopping video: $videoUrl');
        _stopCurrentVideo();
        return;
      }

      // Stop any currently playing video
      _stopCurrentVideo();

      // Check if we already have a controller for this video
      if (!_videoControllers.containsKey(videoUrl)) {
        log('🎬 [VIDEO] Creating new controller for: $videoUrl');
        // Create video controller with error handling
        final videoController = VideoPlayerController.network(videoUrl);

        try {
          await videoController.initialize();
          log('✅ [VIDEO] Video initialized successfully');
        } catch (initError) {
          log('❌ [VIDEO] Failed to initialize video: $initError');
          videoController.dispose();

          // Check if error is due to high resolution or device capabilities
          if (initError.toString().contains('NO_EXCEEDS_CAPABILITIES') ||
              initError.toString().contains('resolution') ||
              initError.toString().contains('format') ||
              initError.toString().contains('capabilities')) {
            log('🎬 [VIDEO] High resolution video detected, launching external player');
            await _launchVideoPlayerExternally(videoUrl,lc);
            return;
          }
          return;
        }

        // Create chewie controller with better error handling
        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
          looping: false,
          aspectRatio: videoController.value.aspectRatio,
          allowFullScreen: false, // Disable fullscreen for inline playback
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.danger,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.lightBlue,
          ),
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            log('❌ [VIDEO] Chewie error: $errorMessage');
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 50),
                    SizedBox(height: 10),

                    Text(
                      lc.video_not_play,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      lc.over_video,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _stopCurrentVideo();
                        _launchVideoPlayerExternally(videoUrl,lc);
                      },
                      child: Text(lc.open_external_player),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Store the controller
        _videoControllers[videoUrl] = chewieController;
      } else {
        log('🎬 [VIDEO] Using existing controller for: $videoUrl');
      }

      // Set this video as currently playing
      setState(() {
        _currentlyPlayingVideoUrl = videoUrl;
      });

      log('🎬 [VIDEO] Video set as currently playing: $videoUrl');

    } catch (e) {
      log('❌ [VIDEO] Error toggling video playback: $e');
    }
  }

  /// Stop the currently playing video
  void _stopCurrentVideo() {
    if (_currentlyPlayingVideoUrl != null) {
      final controller = _videoControllers[_currentlyPlayingVideoUrl];
      if (controller != null) {
        controller.pause();
        controller.videoPlayerController.seekTo(Duration.zero);
      }
      setState(() {
        _currentlyPlayingVideoUrl = null;
      });
      log('🎬 [VIDEO] Stopped current video');
    }
  }


  /// Launch video player using external app as fallback
  Future<void> _launchVideoPlayerExternally(String videoUrl,lc) async {
    log('🎬 [VIDEO] Launching external video player for URL: $videoUrl');

    try {
      final Uri uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        log('❌ [VIDEO] Could not launch URL: $videoUrl');
        Get.snackbar(
          lc.error_lbl,
          lc.no_video_app,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log('❌ [VIDEO] Error launching video player: $e');
      Get.snackbar(
        lc.error_lbl,
        lc.field_video,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(MediaItem mediaItem,lc) async {
    final isVideo = _isVideoFile(mediaItem.mediaFileName);
    final mediaType = isVideo ? 'video' : 'image';

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${lc.delete} $mediaType',style: TextStyle(fontSize: 19.w,fontWeight: FontWeight.bold)),
        content: Text('${lc.delete_generally_confirm} $mediaType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              lc.btn_Cancel,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child:  Text(lc.delete),
          ),

        ],
      ),
    ) ??
        false;
  }

  Future<bool> _deleteApiImage(String mediaId) async {
    try {
      // Find the media item to check if it's a video
      final apiImages = controller.postMedia.value?.data ?? [];
      final mediaItem = apiImages.firstWhere(
            (item) => item.mediaId.toString() == mediaId,
        orElse: () => apiImages.first,
      );

      // If it's a video, dispose its controller
      if (_isVideoFile(mediaItem.mediaFileName)) {
        final controller = _videoControllers[mediaItem.mediaUrl];
        if (controller != null) {
          controller.dispose();
          _videoControllers.remove(mediaItem.mediaUrl);
        }
      }

      final success = await controller.deletePostGalleryPhoto(
        mediaId: mediaId,
        postId: widget.postId.toString(),
        ourSecret: ourSecret, // Using the same secret as other API calls
      );
      return success;
    } catch (e) {
      log('❌ Error deleting API image: $e');
      return false;
    }
  }


  /// Pick cover image from gallery
  Future<void> _pickCoverImageFromGallery(lc) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await _uploadAndSetCoverImage(imageFile,lc);
      }
    } catch (e) {
      log('❌ Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image from gallery'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Upload image and set as cover
  Future<void> _uploadAndSetCoverImage(File imageFile,lc) async {
    try {
      // Show ONE loading indicator for the entire process
      controller.isLoadingMedia.value = true;

      // Step 1: Upload the cover image (this will also refresh media internally)
      final uploadSuccess = await controller.uploadCoverImage(
        postId: widget.postId.toString(),
        photoFile: imageFile,
        ourSecret: ourSecret,
      );

      if (!uploadSuccess) {
        log('❌ [DEBUG] Upload failed');
        return;
      }

      // Step 2: Get the uploaded image URL from the already refreshed media
      final updatedApiImages = controller.postMedia.value?.data ?? [];
      String newCoverUrl = '';

      if (updatedApiImages.isNotEmpty) {
        newCoverUrl = updatedApiImages.last.mediaUrl;
        log('✅ [DEBUG] Found uploaded image URL: $newCoverUrl');
      } else {
        log('❌ [DEBUG] No images found after upload');
        return;
      }

      // Step 3: Update the cover image reference
      final updateSuccess = await controller.updateCoverImage(
        postId: widget.postId.toString(),
        newCoverImageUrl: newCoverUrl,
        ourSecret: ourSecret,
      );
//
      if (updateSuccess) {
        // Step 4: Refresh details - this will update the state including currentCoverImage
        await _fetchPostDetails();

        log('✅ [DEBUG] Cover image updated successfully: $currentCoverImage');
      } else {
        log('❌ [DEBUG] Failed to update cover image reference');
      }
    } catch (e) {
      log('❌ Error in cover image process: $e');
    } finally {
      // Hide loading indicator - process complete
      controller.isLoadingMedia.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.blackColor(context),
            size: 24.w,
          ),
          onPressed: () {
            controller.isLoadingMedia.value = false;
            final myAdsController = Get.find<MyAdCleanController>();
            myAdsController.silentRefreshMyAds();
            myAdsController.disableLoaderForReturn();
            Navigator.pop(context);
          },
        ),
        title: Obx(() {
          final apiImages = controller.postMedia.value?.data ?? [];
          final videoCount = apiImages.where((item) => _isVideoFile(item.mediaFileName)).length;
          final imageCount = apiImages.where((item) => !_isVideoFile(item.mediaFileName)).length;
          final totalImages = images.length + imageCount;

          String displayText = "${totalImages + 1} ${lc.of_lbl} 15 ${lc.images}"; // +1 for cover
          displayText += " ${lc.and} $videoCount ${lc.of_lbl} 1 ${lc.video}";

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lc.gallery_management,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontFamily: 'Gilroy',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                displayText,
                style: TextStyle(
                  color: AppColors.blackColor(context),
                  fontFamily: 'Gilroy',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: InkWell(
              onTap: () {
                final apiImages = controller.postMedia.value?.data ?? [];
                final hasVideo = apiImages.any((item) => _isVideoFile(item.mediaFileName));

                if (hasVideo) {
                  _pickImages(lc);
                } else {
                  _showMediaSelectionDialog();
                }
              },
              child: Image.asset("assets/images/add.png", scale: 25.w),
            ),
          ),
        ],
        backgroundColor: AppColors.background(context),
        toolbarHeight: Platform.isAndroid ? 60.h : 68.h,
        flexibleSpace: Container(
          decoration: BoxDecoration(//l
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow(//h
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),

      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Column(
            children: [//kf
              /// Header
              // Container(
              //   height: 106.h,
              //   padding: EdgeInsets.only(top: 13.h, left: 14.w),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.2),
              //         blurRadius: 5.h,
              //         spreadRadius: 1,
              //         offset: Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     spacing: 66.w,
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       InkWell(
              //         onTap: () {
              //           // Turn off any active loaders and silent refresh my ads before going back
              //           controller.isLoadingMedia.value = false;
              //           final myAdsController = Get.find<MyAdCleanController>();
              //           myAdsController.silentRefreshMyAds();
              //           myAdsController.disableLoaderForReturn();
              //           Navigator.pop(context);
              //         },
              //         child: Icon(
              //           Icons.arrow_back_outlined,
              //           color: Colors.black,//تالتgf
              //           size: 30.w,
              //         ),
              //       ),
              //       Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             lc.gallery_management,
              //             style: TextStyle(
              //               color: Colors.black,
              //               fontFamily: fontFamily,
              //               fontSize: 16.sp,
              //               fontWeight: FontWeight.w800,
              //             ),
              //           ),
              //           SizedBox(height: 3),
              //           Obx(() {
              //             final apiImages = controller.postMedia.value?.data ?? [];
              //             final videoCount = apiImages.where((item) => _isVideoFile(item.mediaFileName)).length;
              //             final imageCount = apiImages.where((item) => !_isVideoFile(item.mediaFileName)).length;
              //             final totalImages =
              //                 images.length +
              //                     imageCount;
              //             //khk
              //             String displayText = "${totalImages+1} ${lc.of_lbl} 15 ${lc.images}}";//1 for add cover photo to count images
              //             displayText += " ${lc.and} $videoCount ${lc.of_lbl} 1 ${lc.video}";
              //
              //
              //
              //             return Text(
              //               displayText,
              //               style: TextStyle(
              //                 color: Colors.black,
              //                 fontFamily: fontFamily,
              //                 fontSize: 14.sp,
              //                 fontWeight: FontWeight.w800,
              //               ),
              //             );
              //           }),
              //         ],
              //       ),
              //       InkWell(
              //         onTap: () {
              //           // Check if there's already a video in media
              //           final apiImages = controller.postMedia.value?.data ?? [];
              //           final hasVideo = apiImages.any((item) => _isVideoFile(item.mediaFileName));
              //
              //           if (hasVideo) {
              //             // If video exists, directly pick images (old behavior)
              //             _pickImages(lc);
              //           } else {
              //             // If no video, show selection dialog
              //             _showMediaSelectionDialog();
              //           }
              //         },
              //         child: Image.asset("assets/images/add.png", scale: 25.w),
              //       ),
              //     ],
              //   ),
              // ),

              10.verticalSpace,

              //  16.verticalSpace,

              /// Images List
              Expanded(
                child: Obx(() {
                  if (controller.mediaError.value != null) {
                    return Center(//l
                      child: Text(
                        '${lc.error_loading_image}: ${controller.mediaError.value}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final apiImages = controller.postMedia.value?.data ?? [];

                  log(' [BUILD] Found ${apiImages.length} API images');
                  log(' [BUILD] Found ${images.length} local images');

                  final allImages = [
                    ...apiImages.map(
                          (mediaItem) => _buildApiImageItem(mediaItem, lc),
                    ),
                    ...images.map((file) => _buildLocalImageItem(file)),
                  ];


                  // Show cover image even if media list is empty
                  if (allImages.isEmpty && currentCoverImage != null && currentCoverImage!.isNotEmpty) {
                    log(' [BUILD] Rendering ONLY cover image (no other images)');
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: 1, // Only show cover image
                      separatorBuilder: (_, __) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return _buildApiImageItem(
                          MediaItem(
                            mediaId: 0,
                            mediaFileName: 'CoverPhotoForPostGalleryManagement',
                            mediaUrl: currentCoverImage!,
                            displayOrder: 0,
                          ),
                          lc,
                        );
                      },
                    );
                  }

                  // Show "No images found" only if no cover image either
                  if (allImages.isEmpty && (currentCoverImage == null || currentCoverImage!.isEmpty)) {
                    return Center(child: Text(lc.no_img));
                  }

                  // Only show cover image if it exists
                  if (currentCoverImage != null && currentCoverImage!.isNotEmpty) {
                    log(' [BUILD] Rendering cover image + ${allImages.length} other images');
                    
                    // Verify the cover image URL is valid
                    try {
                      log(' [BUILD] Cover image URL: $currentCoverImage');
                      final uri = Uri.parse(currentCoverImage!);
                      log(' [BUILD] Parsed cover image URI: $uri');
                    } catch (e) {
                      log(' [BUILD] Invalid cover image URL: $e');
                    }
                    
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: allImages.length + 1,
                      separatorBuilder: (_, __) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          log(' [BUILD] Building cover image item at index 0');
                          return _buildApiImageItem(
                            MediaItem(
                              mediaId: 0,
                              mediaFileName: 'CoverPhotoForPostGalleryManagement',
                              mediaUrl: currentCoverImage!,
                              displayOrder: 0,
                            ),
                            lc,
                          );
                        }
                        log(' [BUILD] Building gallery image at index ${index - 1}');
                        return allImages[index - 1];
                      },
                    );
                  } else {
                    log(' [BUILD] No cover image to display, showing only gallery images');
                    // Show only gallery images without cover image
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: allImages.length,
                      separatorBuilder: (_, __) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return allImages[index];
                      },
                    );
                  }
                }),
              ),
            ],
          ),

          /// 🌟 Global Loader يغطي الشاشة كلها زي SpecsManagement
          Obx(() {
            if (controller.isLoadingMedia.value) {
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: AppLoadingWidget(
                      //kjjkj
                      title: lc.loading,
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildApiImageItem(MediaItem mediaItem,lc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaItem.mediaFileName == 'CoverPhotoForPostGalleryManagement')
          Stack(
            children: [
              Image.asset("assets/images/featured.png"),
              Positioned(
                left: 20.w,
                child: Center(
                  child: const Text(
                    "Cover",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        Container(
          width: double.infinity,
          height: 300.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              width: 2,
              color:
              mediaItem.mediaFileName ==
                  'CoverPhotoForPostGalleryManagement'
                  ? AppColors.danger
                  : Colors.grey,
            ),
          ),
          child: Stack(
            children: [
              /// Network Image or Video Player
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: _isVideoFile(mediaItem.mediaFileName)
                      ? Container(
                    color: Colors.black,
                    child: _currentlyPlayingVideoUrl == mediaItem.mediaUrl
                        ? Container(
                      // Show inline video player
                      child: Chewie(
                        controller: _videoControllers[mediaItem.mediaUrl]!,
                      ),
                    )
                        : GestureDetector(
                      // Show video preview with play button
                      onTap: () {
                        _toggleVideoPlayback(mediaItem.mediaUrl,lc);
                      },
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_filled, color: Colors.white, size: 60),
                              SizedBox(height: 10),
                              Text(
                                'Tap to Play Video',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      : Image.network(
                    mediaItem.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// Delete Icon
              (mediaItem.mediaFileName == 'CoverPhotoForPostGalleryManagement')
                  ? Positioned(
                right: 8.w,
                top: 8.h,
                child: GestureDetector(
                  onTap: () async {
                    await _pickCoverImageFromGallery(lc);
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Color(0xffEC6D64),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 28.w,
                    ),
                  ),
                ),
              )
                  : Positioned(
                right: 8.w,
                top: 8.h,
                child: GestureDetector(
                  onTap: () async {
                    final apiImages =
                        controller.postMedia.value?.data ?? [];
                    final index = apiImages.indexOf(mediaItem);
                    if (index != -1) {
                      // Show confirmation dialog
                      final shouldDelete =
                      await _showDeleteConfirmationDialog(mediaItem,lc);
                      if (shouldDelete) {
                        final success = await _deleteApiImage(
                          mediaItem.mediaId.toString(),
                        );
                        if (success) {
                          // Remove from local list immediately for better UX
                          setState(() {
                            apiImages.removeAt(index);
                            // Update the controller's postMedia to reflect the change
                            if (controller.postMedia.value != null) {
                              final updatedPostMedia = PostMedia(
                                code: controller.postMedia.value!.code,
                                desc: controller.postMedia.value!.desc,
                                count:
                                controller.postMedia.value!.count - 1,
                                data: List<MediaItem>.from(apiImages),
                              );
                              controller.postMedia.value =
                                  updatedPostMedia;
                            }
                          });
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text('Image deleted successfully'),
                          //     backgroundColor: Colors.green,
                          //   ),
                          // );
                        } else {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text('Failed to delete image'),
                          //     backgroundColor: Colors.red,
                          //   ),
                          //   );
                        }
                      }
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Color(0xffEC6D64),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28.w,
                    ),
                  ),
                ),
              ),

              /// Up Arrow
              (mediaItem.mediaFileName == 'CoverPhotoForPostGalleryManagement')
                  ? SizedBox():     Positioned(
                left: 8.w,
                top: 8.h,
                child: GestureDetector(
                  onTap: () {
                    final apiImages = controller.postMedia.value?.data ?? [];
                    final index = apiImages.indexOf(mediaItem);
                    if (index > 0) {
                      _swapApiImages(index, index - 1);
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 48.h,
                    padding: EdgeInsets.all(12).r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset("assets/images/up-arrow.png"),
                  ),
                ),
              ),

              /// Down Arrow
              (mediaItem.mediaFileName == 'CoverPhotoForPostGalleryManagement')
                  ? SizedBox():    Positioned(
                left: 8.w,
                bottom: 8.h,
                child: GestureDetector(
                  onTap: () {
                    final apiImages = controller.postMedia.value?.data ?? [];
                    final index = apiImages.indexOf(mediaItem);
                    if (index < apiImages.length - 1) {
                      _swapApiImages(index, index + 1);
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 48.h,
                    padding: EdgeInsets.all(12).r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset("assets/images/down-arrow.png"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalImageItem(File image) {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          /// Delete Icon
          Positioned(
            right: 8.w,
            top: 8.h,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  images.remove(image);
                });
              },
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Color(0xffEC6D64),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28.w,
                ),
              ),
            ),
          ),

          /// Up Arrow
          Positioned(
            left: 8.w,
            top: 8.h,
            child: GestureDetector(
              onTap: () {
                final index = images.indexOf(image);
                if (index > 0) {
                  _swapImages(index, index - 1);
                }
              },
              child: Container(
                width: 40.w,
                height: 48.h,
                padding: EdgeInsets.all(12).r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset("assets/images/up-arrow.png"),
              ),
            ),
          ),

          /// Down Arrow
          Positioned(
            left: 8.w,
            bottom: 8.h,
            child: GestureDetector(
              onTap: () {
                final index = images.indexOf(image);
                if (index < images.length - 1) {
                  _swapImages(index, index + 1);
                }
              },
              child: Container(
                width: 40.w,
                height: 48.h,
                padding: EdgeInsets.all(12).r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset("assets/images/down-arrow.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}