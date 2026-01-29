import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qarsspin/view/widgets/video_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CarImage extends StatefulWidget {
  List<String> allImages;
  CarImage({required this.allImages,super.key});

  @override
  State<CarImage> createState() => _CarImageState();
}

class _CarImageState extends State<CarImage> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition for Android

    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
    if(widget.allImages[0]!=""){
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted) // allow JS (required for 360 player)
        ..loadRequest(Uri.parse(
            widget.allImages[0]));

    }


  }
  bool isVideo(String url) {
    return url.toLowerCase().endsWith(".mp4") ||
        url.toLowerCase().endsWith(".mov") ||
        url.toLowerCase().endsWith(".avi") ||
        url.toLowerCase().endsWith(".webm");
  }
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return widget.allImages[0]!=""? Container(
        width: double.infinity,
        height: 250.h,


        child: WebViewWidget(controller: _controller,


        )
    ):StatefulBuilder(
      builder: (context, setState) {
        int currentIndex = 1;

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250.h,
              child: PageView.builder(
                controller: controller,
                onPageChanged: (index) {
                  setState(() {
                    if(index == 0){
                      index++;
                    }

                    currentIndex = index;
                  });
                },
                itemCount: widget.allImages.length-1,
                itemBuilder: (context, index) {
                  final imageUrl =  widget.allImages[index+1];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isVideo(imageUrl)
                        ? VideoItem(url: imageUrl)
                        :Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 250.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 250.h,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Left arrow (show only if not first image)
            if (currentIndex > 1)
              Positioned(
                left: 10,
                child: _arrowButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),

            // Right arrow (show only if not last image)
            if (currentIndex < widget.allImages.length - 1)
              Positioned(
                right: 10,
                child: _arrowButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: () {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}




// Widget carImage(List<String> allImages) {
//   final PageController controller = PageController();
//
//   return allImages[0]!=""? Container(
//       width: double.infinity,
//       height: 250.h,
//
//
//       child: WebViewWidget(controller: _controller,
//
//
//       )
//   ):StatefulBuilder(
//     builder: (context, setState) {
//       int currentIndex = 0;
//
//       return Stack(
//         alignment: Alignment.center,
//         children: [
//           SizedBox(
//             width: double.infinity,
//             height: 250.h,
//             child: PageView.builder(
//               controller: controller,
//               onPageChanged: (index) {
//                 setState(() {
//                   currentIndex = index;
//                 });
//               },
//               itemCount: allImages.length,
//               itemBuilder: (context, index) {
//                 final imageUrl = allImages[index];
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     imageUrl,
//                     width: double.infinity,
//                     height: 250.h,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       width: double.infinity,
//                       height: 250.h,
//                       color: Colors.grey.shade200,
//                       alignment: Alignment.center,
//                       child: const Icon(Icons.image_not_supported,
//                           color: Colors.grey),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Left arrow (show only if not first image)
//           if (currentIndex > 0)
//             Positioned(
//               left: 10,
//               child: _arrowButton(
//                 icon: Icons.arrow_back_ios_new,
//                 onPressed: () {
//                   controller.previousPage(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                 },
//               ),
//             ),
//
//           // Right arrow (show only if not last image)
//           if (currentIndex < allImages.length - 1)
//             Positioned(
//               right: 10,
//               child: _arrowButton(
//                 icon: Icons.arrow_forward_ios,
//                 onPressed: () {
//                   controller.nextPage(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                 },
//               ),
//             ),
//         ],
//       );
//     },
//   );
// }

Widget _arrowButton({required IconData icon, required VoidCallback onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}


// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// Widget carImage(List<String> allImages){
//   return Container(
//     width: double.infinity,
//     height: 250.h,
//    child: ListView.separated(
//       scrollDirection: Axis.horizontal,
//       itemCount: allImages.length,
//       separatorBuilder: (_, __) => const SizedBox(width: 8),
//       itemBuilder: (context, index) {
//         final imageUrl = allImages[index];
//
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.network(
//             imageUrl,
//             width: 250,
//             height: 180,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => Container(
//               width: 250,
//               height: 180,
//               color: Colors.grey.shade200,
//               alignment: Alignment.center,
//               child: const Icon(Icons.image_not_supported, color: Colors.grey),
//             ),
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 width: 250,
//                 height: 180,
//                 alignment: Alignment.center,
//                 child: const CircularProgressIndicator(strokeWidth: 2),
//               );
//             },
//           ),
//         );
//       },
//     ),
//     // child: Image.network(path,
//     // fit: BoxFit.cover,
//     //   errorBuilder: (context, error, stackTrace) => Container(
//     //     height: 150,
//     //     width: double.infinity,
//     //     color: Colors.grey.shade200,
//     //     alignment: Alignment.center,
//     //     child: const Icon(Icons.image_not_supported, color: Colors.grey),
//     //   ),
//     //   // loadingBuilder: (context, child, loadingProgress) {
//     //   //   if (loadingProgress == null) return child;
//     //   //   return Container(
//     //   //     height: 160,
//     //   //     width: double.infinity,
//     //   //     alignment: Alignment.center,
//     //   //     child: const CircularProgressIndicator(strokeWidth: 2),
//     //   //   );
//     //   // },
//     //
//     // ),
//   );
//
//
// }