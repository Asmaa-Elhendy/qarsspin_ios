
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../controller/const/colors.dart';

// class DropdownField extends StatelessWidget {
//   final String label;
//   final List<String> items;
//   final String? value;
//   final ValueChanged<String?>? onChanged;
//   final String? hintText;
//
//   const DropdownField({
//     Key? key,
//     required this.label,
//     required this.items,
//     this.value,
//     this.onChanged,
//     this.hintText,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     double width=MediaQuery.of(context).size.width;
//     double height=MediaQuery.of(context).size.height;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize:15.w
//             ,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           height: height*.045,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black,width: 0.3),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(icon: Icon(Icons.arrow_drop_down,color: Colors.black,),
//               isExpanded: true,
//               value: value,
//               hint: hintText != null ? Text(hintText!) : null,
//               items: items.map((String item) {
//                 return DropdownMenuItem<String>(
//                   value: item,
//                   child: Text(
//                     item,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
class CustomDropDownTyping extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String>? onChanged;
  final bool enableSearch;
  final String? hintText;

  const CustomDropDownTyping({
    Key? key,
    required this.label,
    required this.controller,
    required this.options,
    this.onChanged,
    this.enableSearch = true,
    this.hintText,
  }) : super(key: key);

  @override
  State<CustomDropDownTyping> createState() => _CustomDropDownTypingState();
}

class _CustomDropDownTypingState extends State<CustomDropDownTyping> {
  // Tracks whichever FocusNode `TypeAheadField.builder` most recently
  // handed us, so we can attach a single blur listener regardless of
  // how many times the builder rebuilds.
  FocusNode? _wiredFocusNode;

  @override
  void dispose() {
    _wiredFocusNode?.removeListener(_handleBlur);
    super.dispose();
  }

  void _wireFocus(FocusNode focusNode) {
    if (identical(_wiredFocusNode, focusNode)) return;
    _wiredFocusNode?.removeListener(_handleBlur);
    _wiredFocusNode = focusNode;
    focusNode.addListener(_handleBlur);
  }

  /// If the user typed something in the field but never picked a valid
  /// suggestion from the dropdown, the internal text still holds their
  /// stray input while the parent's underlying selection (e.g.
  /// `brandController.selectedMake.value`) is null or stale — which is
  /// exactly what causes the backend to reject the submission with
  /// "Missing Parameter".
  ///
  /// On blur: if the current text is non-empty AND doesn't exactly
  /// match one of the loaded options, wipe it. This forwards through
  /// `onChanged('')` so the parent's own reset logic (which clears the
  /// matching `selectedMake` / dependent dropdowns) fires the same way
  /// it does when a user manually deletes the field contents.
  void _handleBlur() {
    if (_wiredFocusNode?.hasFocus ?? true) return;
    if (!widget.enableSearch) return;
    if (widget.options.isEmpty) return;
    final String text = widget.controller.text.trim();
    if (text.isEmpty) return;
    final bool isValid = widget.options.any((o) => o == text);
    if (isValid) return;

    widget.controller.clear();
    widget.onChanged?.call('');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height * .045,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: Colors.black, width: 0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TypeAheadField<String>(
            key: ValueKey('typeahead_${widget.options.length}_${widget.controller.text}'),
            suggestionsCallback: (pattern) async {
              if (!widget.enableSearch) {
                return widget.options;
              }
              if (pattern.isEmpty) {
                return widget.options;
              }
              return widget.options
                  .where((car) =>
                  car.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            hideOnSelect: true,
            hideOnEmpty: true,
            hideOnError: true,
            builder: (context, controller, focusNode) {
              // Wire up (or re-wire) our blur listener onto whichever
              // FocusNode TypeAheadField is currently using. Idempotent
              // — no-op if we've already attached to this exact node.
              _wireFocus(focusNode);
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      readOnly: !widget.enableSearch,
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
                        hintText: widget.hintText,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              );
            },
            itemBuilder: (context, suggestion) {
              bool isSelected = widget.controller.text == suggestion;
              return Container(
                color: isSelected ? Color(0xFFF5F5F5) : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 18.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
            onSelected: (suggestion) {
              // Ensure the controller text is updated immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.controller.text = suggestion;
                // Call the onChanged callback
                if (widget.onChanged != null) {
                  widget.onChanged!(suggestion);
                }
                // Force immediate UI refresh
                if (mounted) {
                  setState(() {});
                }
              });
            },  direction: VerticalDirection.up, // 👈 This makes the list appear above

            errorBuilder: (context, error) => const SizedBox(),
            loadingBuilder: (context) => const SizedBox(),
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No results found', style: TextStyle(color: Colors.grey)),
            ),
            controller: widget.controller,
            decorationBuilder: (context, child) {
              // Calculate adaptive height based on number of options
              double itemHeight = 40.h; // Height of each item
              double maxHeight = 230.h; // Maximum height
              double minHeight = 80.h;  // Minimum height

              // Calculate required height based on number of options
              double calculatedHeight = widget.options.length * itemHeight;

              // Ensure height is within min and max bounds
              double adaptiveHeight = calculatedHeight.clamp(minHeight, maxHeight);

              return Container(
                height: adaptiveHeight,
                decoration: BoxDecoration(
                  color: Colors.white, // Back to white background
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(4, 4),
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

  @override
  void didUpdateWidget(CustomDropDownTyping oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the options changed, we need to rebuild
    if (oldWidget.options != widget.options) {
      setState(() {});
    }
  }
}