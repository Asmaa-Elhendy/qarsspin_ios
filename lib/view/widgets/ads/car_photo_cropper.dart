import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';

/// Locks all car-photo uploads to the standard **4:3 landscape** ratio
/// enforced by the marketplace guideline
/// (recommended source resolution: 1600×1200 or larger).
///
/// Wrap every `image_picker` call site with [cropToCarRatio] — the
/// picker returns a raw local path, and this helper turns it into a
/// cropped local path that always matches the ratio used by every
/// car-card widget in the app. When the user cancels the cropping UI
/// this returns `null`.
class CarPhotoCropper {
  /// The single aspect ratio car photos are cropped to across the app.
  /// Kept as one CropAspectRatio so if it ever changes we only edit here.
  static const CropAspectRatio _carRatio =
      CropAspectRatio(ratioX: 4, ratioY: 3);

  /// Opens the cropper on [sourcePath] with the 4:3 ratio locked (the
  /// user can pan and zoom the image within the frame but cannot change
  /// the aspect ratio). Returns the new local file path, or `null` if
  /// the user backed out.
  ///
  /// The toolbar title is pulled from `AppLocalizations.crop_to_ratio_title`,
  /// so it renders in Arabic on `ar` locale and English on `en` — matching
  /// the rest of the app's copy.
  static Future<String?> cropToCarRatio({
    required BuildContext context,
    required String sourcePath,
  }) async {
    final AppLocalizations lc = AppLocalizations.of(context)!;
    final String title = lc.crop_to_ratio_title;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      compressQuality: 90,
      // Downstream API stays as-is (no format conversion) — we only
      // adjust the dimensions.
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.black,
          statusBarColor: AppColors.primary,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          // Locking the aspect ratio to a single preset AND setting
          // `lockAspectRatio: true` prevents the user from selecting a
          // different ratio in the toolbar — the frame stays 4:3 no
          // matter what.
          aspectRatioPresets: const <CropAspectRatioPreset>[
            CropAspectRatioPreset.ratio4x3,
          ],
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: title,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          aspectRatioPresets: const <CropAspectRatioPreset>[
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
      aspectRatio: _carRatio,
    );

    return cropped?.path;
  }
}
