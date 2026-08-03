import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../car_photo_cropper.dart';
import '../image_picker_field.dart';
import '../video_player_widget.dart';

class ImageUploadSection extends StatefulWidget {
  final List<String> images;
  final String? coverImage;
  final String? videoPath;
  final Function(String) onImageSelected;
  final Function(String) onVideoSelected;
  final Function(String) onCoverChanged;
  final Function(int) onImageRemoved;
  final bool isModifyMode;
  final Function(bool) onCoverPhotoChanged;
  final Function(bool)? onVideoChanged;

  const ImageUploadSection({
    Key? key,
    required this.images,
    required this.coverImage,
    required this.videoPath,
    required this.onImageSelected,
    required this.onVideoSelected,
    required this.onCoverChanged,
    required this.onImageRemoved,
    this.isModifyMode = false,
    required this.onCoverPhotoChanged,
    this.onVideoChanged,
  }) : super(key: key);

  @override
  _ImageUploadSectionState createState() => _ImageUploadSectionState();
}

class _ImageUploadSectionState extends State<ImageUploadSection> {
  bool _isVideo(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi');
  }

  bool _isNetworkUrl(String path) {
    return path.startsWith('http');
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.error, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var lc = AppLocalizations.of(context)!;


    return Column(
      children: [
        widget.isModifyMode ?SizedBox(height: height*.02,):   Padding(
          padding: EdgeInsets.symmetric(vertical: height * .01),
          child:  Center(
            child: Text(
              lc.upload_txt,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Cover Image Preview
        if (widget.coverImage != null && widget.coverImage!.isNotEmpty)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: height * .35,
                child: GestureDetector(
                  onTap: widget.isModifyMode ? () async {
                    print('DEBUG: Cover photo tapped in modify mode');
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image == null) {
                      print('DEBUG: No image selected');
                      return;
                    }
                    // Enforce the 4:3 landscape guideline — the user
                    // is walked through a cropper with a locked aspect
                    // ratio before the photo becomes the cover.
                    if (!context.mounted) return;
                    final String? croppedPath =
                        await CarPhotoCropper.cropToCarRatio(
                      context: context,
                      sourcePath: image.path,
                    );
                    if (croppedPath == null) {
                      print('DEBUG: Cropping cancelled');
                      return;
                    }
                    print('DEBUG: Cover photo cropped: $croppedPath');
                    widget.onCoverChanged(croppedPath);
                    widget.onCoverPhotoChanged(true);
                  } : null,
                  child: _isVideo(widget.coverImage!)
                      ? Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, size: 50, color: Colors.grey[600]),
                          SizedBox(height: 10),
                          Text(
                            lc.video_cover,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                      : _isNetworkUrl(widget.coverImage!)
                      ? Image.network(
                    widget.coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                      : Image.file(
                    File(widget.coverImage!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  ),
                ),
              ),
              SizedBox(height: height * .02),
            ],
          ),
        ImagePickerField(
          imagePaths: widget.images,
          coverImage: widget.coverImage,
          videoPath: widget.videoPath,
          maxImages: 15,
          onImageSelected: widget.onImageSelected,
          onVideoSelected: widget.onVideoSelected,
          onCoverChanged: widget.onCoverChanged,
          onImageRemoved: widget.onImageRemoved,
          isModifyMode: widget.isModifyMode,
          onVideoChanged: widget.onVideoChanged,
        ),
      ],
    );
  }//k
}