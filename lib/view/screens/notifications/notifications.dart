import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/const/colors.dart';

import '../../../controller/notifications_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/notification_model.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/ads/dialogs/loading_dialog.dart';

class NotificationsPage extends GetView<NotificationsController> {
  NotificationsPage({Key? key}) : super(key: key) {
    // Initialize the controller and load notifications
    Get.put(NotificationsController());
    // Schedule the initial load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔔 Initial notifications load triggered');
      controller.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;
    debugPrint('🔔 Building NotificationsPage');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          lc.lbl_notifications,
          style: TextStyle(
            color: AppColors.blackColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: AppColors.background(context),
        toolbarHeight: 60.h,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow( //update asmaa
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Obx(() {
            debugPrint('🔄 Notifications state updated - Loading: ${controller.isLoading}, Count: ${controller.notifications.length}');

            if (controller.isLoading) {
              debugPrint('⏳ Loading indicator shown');
              return const SizedBox.shrink(); // Empty widget when loading, we'll show the overlay
            }

            if (controller.notifications.isEmpty) {
              debugPrint('ℹ️ No notifications to display');
              return Center(
                child: Text(
                  lc.no_notify,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              );
            }

            debugPrint('✅ Displaying ${controller.notifications.length} notifications');
            if (controller.notifications.isEmpty) {
              debugPrint('ℹ️ No notifications to display');
              return Center(
                child: Text(
                  lc.no_notify,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              );
            }

            debugPrint('✅ Displaying ${controller.notifications.length} notifications');
            return RefreshIndicator(color: AppColors.primary,
              onRefresh: () {
                debugPrint('🔄 Pull-to-refresh triggered');
                return controller.getNotifications();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(12.r),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  debugPrint('📌 Rendering notification ${index + 1}/${controller.notifications.length}: ${notification.title}');
                  return Dismissible(
                    key: Key(notification.id?.toString() ?? 'notification_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.w),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteDialog(context, notification);
                    },
                    onDismissed: (direction) {
                      debugPrint('🗑️ Dismissed notification: ${notification.id}');
                      // controller.deleteNotification(notification);
                    },
                    child: NotificationCard(notification: notification),
                  );
                },
              ),
            );
          }),

          // Loading Overlay
          Obx(() {
            if (controller.isLoading) {
              return Container(
                color: Colors.black.withOpacity(0.2),
                child:  Center(
                  child: AppLoadingWidget(
                    title: lc.loading,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(
      BuildContext context, NotificationModel notification) async {
    var lc = AppLocalizations.of(context)!;
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Notification'),
        content: Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(lc.btn_Cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              lc.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _showDeleteAllDialog(BuildContext context) async {
    var lc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lc.clear_all_notifications_message),
        content: Text(lc.delete_notification_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(lc.btn_Cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              lc.btn_delete_all,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}