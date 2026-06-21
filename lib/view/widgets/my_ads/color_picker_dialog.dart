import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/view/widgets/my_ads/yellow_buttons.dart';

import '../../../l10n/app_localizations.dart';
import 'dialog.dart';

class ColorData {
  final int colorId;
  final String hexCode;
  final String namePL;
  final String nameSL;
  final bool isExterior;
  final int displayOrder;
  final Color color;

  ColorData({
    required this.colorId,
    required this.hexCode,
    required this.namePL,
    required this.nameSL,
    required this.isExterior,
    required this.displayOrder,
  }) : color = Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
}

class ColorPickerDialog extends StatefulWidget {
  final List<ColorData> colors;
  final ColorData initialColor;
  final String title;

  const ColorPickerDialog({
    Key? key,
    required this.colors,
    required this.initialColor,
    required this.title,
  }) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late ColorData selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              constraints: BoxConstraints(
                maxHeight: 400.h,
                maxWidth: 400.w,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                itemCount: widget.colors.length,
                itemBuilder: (context, index) {
                  final colorData = widget.colors[index];
                  final isSelected = colorData.colorId == selectedColor.colorId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = colorData;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorData.color,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                            : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Color name
                          Positioned(
                            bottom: 4,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5.r),
                                  bottomRight: Radius.circular(5.r),
                                ),
                              ),
                              child: Text(
                                Get.locale?.languageCode=='ar'?colorData.nameSL:colorData.namePL,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Selection indicator
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 130.w
                  ,child: cancelButton(() => Navigator.pop(context, null),lc.btn_Cancel,false),),

                // TextButton(
                //   onPressed: () => Navigator.pop(context, null),
                //   style: TextButton.styleFrom(
                //     padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                //   ),
                //   child: Text(
                //     "CANCEL",
                //     style: TextStyle(
                //       color: Colors.grey.shade600,
                //       fontSize: 14.sp,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
                yellowButtons(title:lc.select,onTap:() => Navigator.pop(context, selectedColor)

                    ,w: 130.w, context: context),
                // ElevatedButton(
                //   onPressed: () => Navigator.pop(context, selectedColor),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8.r),
                //     ),
                //   ),
                //   child: Text(
                //     "SUBMIT",
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 14.sp,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Utility function to show color picker dialog
Future<ColorData?> showColorPickerDialog({
  required BuildContext context,
  required List<ColorData> colors,
  required ColorData initialColor,
  required String title,
}) async {
  return await showDialog<ColorData>(
    context: context,
    builder: (context) => ColorPickerDialog(
      colors: colors,
      initialColor: initialColor,
      title: title,
    ),
  );
}