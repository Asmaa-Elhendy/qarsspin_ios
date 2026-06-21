import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controller/const/colors.dart';
import '../../../../l10n/app_localizations.dart';

class AppLoadingWidget extends StatelessWidget {
  final String title;

  const AppLoadingWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3.w,
          ),
          16.verticalSpace,
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog {
  static void show(
    BuildContext context, {
    bool isModifyMode = false,
    ValueNotifier<String>? statusNotifier,
  }) {
    var lc = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(isModifyMode ? lc.update_ad : lc.creating_ad),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: 14),
              Text(
                isModifyMode ? lc.please_wait_update : lc.please_wait_create,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              if (statusNotifier != null)
                ValueListenableBuilder<String>(
                  valueListenable: statusNotifier,
                  builder: (_, value, __) {
                    if (value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        // No actions — the loader auto-dismisses when work completes.
      ),
    );
  }
}