import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../controller/const/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../my_ads/color_picker_dialog.dart';

/// Searchable color picker with a color swatch prefix.
///
/// Styled to match `CustomDropDownTyping` (the make/model/spec dropdowns
/// used elsewhere on the Sell-Your-Car / Edit-Ad page) so all form fields
/// on the page share the same font, border, height, and dropdown popup
/// look. Uses `flutter_typeahead` for the same behavior as those other
/// dropdowns.
///
/// Public API is unchanged (`label`, `initialColor`, `onColorSelected`,
/// `isExterior`, `showLabel`, `modify`) so no call sites need to change.
class ColorPickerField extends StatefulWidget {
  final String label;
  // Nullable so the widget can signal "user cleared this field with X"
  // by calling `onColorSelected(null)`. Parent form treats null as
  // "no color picked" for required-field validation.
  final ValueChanged<Color?> onColorSelected;
  final Color? initialColor;
  final bool showLabel;
  bool modify;
  final bool isExterior;

  ColorPickerField({
    Key? key,
    required this.label,
    this.modify = false,
    required this.onColorSelected,
    this.initialColor,
    this.showLabel = true,
    this.isExterior = true,
  }) : super(key: key);

  @override
  _ColorPickerFieldState createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late ColorData _selectedColorData;
  late List<ColorData> _filteredColors;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeColors();
    // Only pre-fill the text if the parent actually gave us a color.
    // On the create-ad flow the parent now passes null until the user
    // picks — leaving the field empty so the "Select color" hint
    // shows. Edit mode passes the car's saved color and it renders
    // normally.
    if (widget.initialColor != null) {
      _controller.text = _displayName(_selectedColorData);
    }
    // Natural field behavior — no blur-restore, no original-color
    // cache. If the user hits X and taps out, the field stays empty
    // (hint "Select color" shows). Marked as required in the parent
    // via the `*` in the label; validation is the parent form's job.
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeColors() {
    final List<ColorData> allColors = [
      // Exterior colors
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

      // Interior colors
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

    _filteredColors = allColors
        .where((color) => color.isExterior == widget.isExterior)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final Color initial = widget.initialColor ?? _filteredColors.first.color;
    _selectedColorData = _filteredColors.firstWhere(
      (c) => c.color == initial,
      orElse: () => _filteredColors.first,
    );
  }

  String _displayName(ColorData c) =>
      Get.locale?.languageCode == 'ar' ? c.nameSL : c.namePL;

  Widget _swatch(Color color, {double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Container styled identically to `CustomDropDownTyping` so the
        // color picker sits flush with make/model/spec dropdowns on the
        // same form: same height, border, radius, background, padding.
        Container(
          height: height * .045,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: Colors.black, width: 0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TypeAheadField<ColorData>(
            controller: _controller,
            focusNode: _focusNode,
            hideOnSelect: true,
            hideOnEmpty: false,
            hideOnError: true,
            // Show ALL options when the field is empty or when the current
            // text matches the selected color exactly (i.e. user just
            // opened the dropdown without editing). Otherwise filter by
            // substring in either language.
            suggestionsCallback: (pattern) async {
              final String q = pattern.trim();
              if (q.isEmpty || q == _displayName(_selectedColorData)) {
                return _filteredColors;
              }
              final String lower = q.toLowerCase();
              return _filteredColors.where((c) {
                return c.namePL.toLowerCase().contains(lower) ||
                    c.nameSL.contains(q);
              }).toList();
            },
            builder: (context, controller, focusNode) {
              return Row(
                children: [
                  // Show the swatch ONLY when the current field text
                  // exactly matches the committed color's name.
                  //
                  // That means the swatch is hidden in every state where
                  // the user hasn't yet committed a color that matches
                  // what's on screen:
                  //   • empty field (pressed X) — nothing selected
                  //   • typing a search query ("bro") — search is not a
                  //     commit; the previous swatch would be misleading
                  // It reappears the moment the field text is back to a
                  // committed name — either via picking from the dropdown
                  // (which updates both `_selectedColorData` and the text)
                  // or via the blur-restore that snaps the text back to
                  // the committed name.
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      final bool matchesCommitted =
                          value.text == _displayName(_selectedColorData);
                      if (!matchesCommitted) return SizedBox(width: 0);
                      return Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: _swatch(_selectedColorData.color, size: 16),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: AppColors.brandBlue,
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        // Localized — pulls "Select color" / "اختر اللون"
                        // from the app's active locale. Falls back to
                        // English if the localizations aren't wired in.
                        hintText: AppLocalizations.of(context)?.select_color
                            ?? 'Select color',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  // Clear button — mirrors the web mock. Only shows when
                  // there is text to clear. Clearing empties the text so
                  // the suggestions list rebuilds to show ALL options and
                  // the user can start typing to filter or scroll to pick.
                  // Also notifies the parent via `onColorSelected(null)`
                  // so its stored color is cleared too — required-field
                  // validation depends on this to catch "user cleared
                  // and never re-picked" before letting a submission
                  // through with the stale previous color.
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return InkWell(
                        onTap: () {
                          controller.clear();
                          focusNode.requestFocus();
                          widget.onColorSelected(null);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 18.sp,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 1,
                    height: 18,
                    color: Colors.grey.shade300,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              );
            },
            itemBuilder: (context, suggestion) {
              final bool isSelected =
                  suggestion.colorId == _selectedColorData.colorId;
              return Container(
                color: isSelected
                    ? const Color(0xFFF5F5F5)
                    : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      _swatch(suggestion.color, size: 16),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _displayName(suggestion),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: Colors.blue, size: 18.sp),
                    ],
                  ),
                ),
              );
            },
            onSelected: (ColorData suggestion) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedColorData = suggestion;
                });
                _controller.text = _displayName(suggestion);
                widget.onColorSelected(suggestion.color);
                log('Selected color: ${suggestion.namePL} (${suggestion.hexCode})');
              });
            },
            errorBuilder: (context, error) => const SizedBox(),
            loadingBuilder: (context) => const SizedBox(),
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            // Popup styling matches `CustomDropDownTyping`: white bg,
            // 6-pixel radius, soft drop shadow at (4,4) offset.
            decorationBuilder: (context, child) {
              const double itemHeight = 44;
              const double maxHeight = 260;
              const double minHeight = 80;
              final double calculated = _filteredColors.length * itemHeight;
              final double adaptiveHeight =
                  calculated.clamp(minHeight, maxHeight);
              return Container(
                height: adaptiveHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }
}

