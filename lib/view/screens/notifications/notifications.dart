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
      // Clear the local unread badge as soon as the user lands on this page.
      // Locally-persisted notifications are considered "seen" once the page
      // is open — the backend unread count is not affected by this call.
      controller.markAllAsRead();
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
        // Trailing "clear all local notifications" action. Only removes
        // locally-persisted notifications (payment / ad-created); API
        // notifications are the server's responsibility and are not touched.
        actions: [
          Obx(() {
            final bool hasLocals = controller.notifications
                .any((n) => n.data?['source'] == 'local');
            if (!hasLocals) return const SizedBox.shrink();
            return IconButton(
              tooltip: lc.btn_delete_all,
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.blackColor(context),
              ),
              onPressed: () => _showDeleteAllDialog(context),
            );
          }),
        ],
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
                // Extra bottom padding so the last notification is
                // fully visible above the system nav bar / home
                // indicator — otherwise the tail of the last card
                // gets clipped and reads as "cut off".
                padding: EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 80.h),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  final bool isLocal =
                      notification.data?['source'] == 'local';
                  debugPrint('📌 Rendering notification ${index + 1}/${controller.notifications.length}: ${notification.title}');

                  // Only locally-persisted notifications are dismissible.
                  // API notifications are the server's source of truth —
                  // a client-side dismiss would immediately reappear on
                  // the next fetch, which is exactly the bug we're
                  // fixing here.
                  if (!isLocal) {
                    return NotificationCard(notification: notification);
                  }

                  // Local notifications carry `id == null`, so the
                  // previous `'notification_$index'` fallback key was
                  // index-based and unstable across list rebuilds. Use
                  // the notification's own fire-time (millisecond
                  // precision) — unique per entry, stable across
                  // rebuilds, and matches what NotificationsStore uses
                  // as the delete identifier.
                  final String dismissKey =
                      'local_${notification.date.millisecondsSinceEpoch}';

                  return Dismissible(
                    key: Key(dismissKey),
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
                      debugPrint(
                        '🗑️ Dismissed local notification @ ${notification.date}',
                      );
                      controller.deleteLocalNotification(notification);
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
            child: Text(lc.btn_Cancel,
              style: TextStyle(color: Colors.black),
            ),

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

    if (confirmed) {
      // Only wipes the locally-persisted notifications — backend
      // notifications belong to the server and are never cleared here.
      await controller.clearAllLocalNotifications();
    }
  }
}