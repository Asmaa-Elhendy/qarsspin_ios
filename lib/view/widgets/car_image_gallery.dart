import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'video_view.dart';

/// Full-screen image gallery for the car-detail page.
///
/// Opens when the user taps any of the thumbnails in `CarImage`.
/// Features:
///   • Swipe left/right to move between photos (PageView).
///   • Pinch to zoom / double-tap to zoom in-out, drag to pan
///     (Flutter's built-in `InteractiveViewer` — no extra package).
///   • Video items in the list render through the existing
///     `VideoItem` widget instead of trying to be zoomable.
///   • Close button top-right returns to the detail page.
///   • Page counter at the bottom (e.g. "2 / 7") + dot row.
class CarImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const CarImageGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<CarImageGallery> createState() => _CarImageGalleryState();
}

class _CarImageGalleryState extends State<CarImageGallery> {
  late final PageController _pageController;
  late int _current;
  // Independent `TransformationController` per page so zooming one
  // photo doesn't carry the transform over to the next swipe.
  final Map<int, TransformationController> _transforms =
      <int, TransformationController>{};
  // Tracks whether the CURRENT page's image is zoomed past 1×. When
  // true we disable the PageView's horizontal scroll so a two-finger
  // pinch or one-finger pan doesn't get eaten by a page-swipe. Kicks
  // back to false as soon as the user returns to identity (pinch out
  // or double-tap to reset).
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _current);
    // Prime the transform controller for the initial page so its
    // listener is attached before the first tap.
    _controllerFor(_current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Disposing the controller detaches all listeners, so we don't
    // need a separate removeListener pass.
    for (final t in _transforms.values) {
      t.dispose();
    }
    super.dispose();
  }

  /// Returns (and lazily creates) the transformation controller for a
  /// page. Attaches a listener on first creation so we can toggle
  /// `_isZoomed` when the user zooms in / out of that page.
  TransformationController _controllerFor(int index) {
    return _transforms.putIfAbsent(index, () {
      final t = TransformationController();
      t.addListener(() {
        // Only the CURRENT page's zoom state controls the PageView's
        // physics. Ignore listener callbacks fired for offscreen
        // pages so a stale zoom on another page doesn't lock the
        // swipe.
        if (index != _current) return;
        final bool zoomed = t.value.getMaxScaleOnAxis() > 1.01;
        if (zoomed != _isZoomed && mounted) {
          setState(() => _isZoomed = zoomed);
        }
      });
      return t;
    });
  }

  /// Called from `onPageChanged` — swap the "current" transform so
  /// the swipe-lock state reflects the newly-visible page.
  void _syncZoomStateForCurrent() {
    final t = _transforms[_current];
    final bool zoomed = t == null ? false : t.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomed);
    }
  }

  bool _isVideo(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') ||
        u.endsWith('.mov') ||
        u.endsWith('.avi') ||
        u.endsWith('.webm');
  }

  /// Double-tap resets the zoom of the current page — matches the
  /// pattern users expect from photo viewers (Google Photos, iOS
  /// Photos, etc.). If the image is already at identity we leave it
  /// alone so the tap doesn't feel like a no-op.
  void _handleDoubleTap(int index) {
    final t = _controllerFor(index);
    if (t.value != Matrix4.identity()) {
      t.value = Matrix4.identity();
    } else {
      // Zoom in ~2× centered on the middle.
      t.value = Matrix4.identity()..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              // Lock horizontal page swipes while the current image
              // is zoomed in — otherwise a pinch or pan gesture on
              // the photo gets stolen by the PageView and the user
              // ends up on the next slide instead of zooming.
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _current = i);
                // Reset the swipe-lock for the freshly-visible page
                // so if the previous page was zoomed, we don't stay
                // locked on the new (identity-scale) page.
                _syncZoomStateForCurrent();
              },
              itemBuilder: (context, index) {
                final url = widget.images[index];
                if (_isVideo(url)) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: VideoItem(url: url),
                    ),
                  );
                }
                return GestureDetector(
                  onDoubleTap: () => _handleDoubleTap(index),
                  child: InteractiveViewer(
                    transformationController: _controllerFor(index),
                    minScale: 1.0,
                    maxScale: 5.0,
                    clipBehavior: Clip.none,
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Close button, top-right on a semi-transparent black
            // circle so it stays legible over both dark and light
            // photos.
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

            // Bottom bar: page counter + dot row.
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_current + 1} / ${widget.images.length}',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        widget.images.length,
                        (i) {
                          final bool active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  // ignore: deprecated_member_use
                                  : Colors.white.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
